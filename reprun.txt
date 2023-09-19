// Programa   : REPRUN
// Fecha/Hora : 13/03/2004 18:57:29
// Prop¢sito  : Leer Archivo .REP
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicaci¢n : Generador de Reportes
// Tabla      : DPREPORT

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
   LOCAL cMemo:="",oScript,cFileDxb,I,uValue,uValueI,uValueF,cOperator
   LOCAL aTitle:={},aExcluye:={"=","<",">",">=","<=","<>"}
   LOCAL oRun,aSize,oIni,aTables:={}

   IF oGenRep=NIL
      RETURN NIL
   ENDIF

   RELEASE RGO_*

   // Remover Crystal Report

   IF (oGenRep:oRun:nOut=8 .OR. oGenRep:oRun:nOut=9)
      AEVAL(DIRECTORY(oDp:cPathCrp+"*.DBF"),{|a,n| FERASE(oDp:cPathCrp+a[1])})
   ENDIF


   // Crea Variables Publicas para Rango y Criterio
   IF ValType(oGenRep:oRun)="O"
      CREARGOVAR(oGenRep:oRun)
   ENDIF

   IF EMPTY(oGenRep:cMemo) // Programa Fuente
      oGenRep:BuildPrg() // Genera C¢digo Fuente
   ENDIF

   IF EMPTY(oGenRep:cSql)
     oGenRep:cSql:=oGenRep:GetSql()
   ENDIF

   oDp:oGenRep:=oGenRep // Necesario en DpRptBegin(

   // Generar Titulos de Rango/Criterio 
   oRun:=oGenRep:oRun
   oRun:lFileDbf:=.F.   // Indica Tabla Dbf Creada
   oGenRep:aTitle:={}

   FOR I=1 TO LEN(oRun:aRango)

     uValueI:=oRun:aRango[I,2]

     IF !Empty(uValueI)
        uValueF:=oRun:aRango[I,3]
        uValueF:=IIF(Empty(uValueF),uValueI,uValueF)
        uValueI:="<"+oRun:aRango[i,1]+": Desde:"+ALLTRIM(CTOO(uValueI,"C"))+" "
        uValueF:="Hasta:"+ALLTRIM(CTOO(uValueF,"C"))+">"
        AADD(oGenRep:aTitle,[']+uValueI+uValueF+['])
     ENDIF

   NEXT I

   // Titulos de Criterio

   FOR I=1 TO LEN(oRun:aCriterio)

     uValue:=oRun:aCriterio[I,3]

     IF !Empty(uValue)
        cOperator:=Alltrim(oRun:aCriterio[i,2])
        AEVAL(aExcluye,{|a|cOperator:=STRTRAN(cOperator,a,"")})
        uValue   :="<"+oRun:aCriterio[i,1]+" ("+cOperator+" "+ALLTRIM(CTOO(uValue,"C"))+") >"
        AADD(oGenRep:aTitle,[']+uValue+['])
     ENDIF

   NEXT I

   // cFileDxb:=STRTRAN(oGenRep:cFileIni,".REP",".DXB")
   cFileDxb:=STRTRAN(oGenRep:cFileIni,".REP",".RXB")

   // compilado vacio

   aSize:=Directory(cFileDxb)

   IF Empty(aSize) .OR. Asize[1,2]=0

      Ferase(cFileDxb)

      IF FILE(cFileDxb)
        MensajeErr(cFileDxb+" no puede ser Eliminado")
        RETURN .F.
      ENDIF

   ENDIF

   /*
   // JN 02/02/2016, Reset del Inner join cuando se Personaliza en el Reporte, requiere ser Ejecutado Nuevamente
   */

   oIni:=Tini():New( oGenRep:cFileIni )


   //? oGenRep:cFileIni,"cFileINI"
   oGenRep:cSqlInnerJoin:=oIni:Get("HEAD","SQLINNER" ,"" )  // Comando Inner Join

// ? oGenRep:cFileIni,oGenRep:cSqlInnerJoin

   aTables:=EJECUTAR("SQL_ATABLES",oGenRep:cSqlInnerJoin)
   ADEPURA(aTables,{|a,n|Empty(a)})
   AEVAL(aTables,{|a,n| IF("VIEW_"$a,EJECUTAR("ISVISTA",a),NIL)})


// ViewArray(aTables)

   // oGenRep:cSqlInnerJoin,"oGenRep:cSqlInnerJoin"
   // 

   oScript:=TScript():New("")
   oScript:cProgram:=oGenRep:REP_CODIGO
   oScript:Reset()
   oScript:lPreProcess := .T.

   IF !FILE(cFileDxb) 

     IF ValType(oGenRep:oMemo)="O"
       cMemo   :=oGenRep:oMemo:GetText()
     ELSE
        cMemo   :=SQLGET("DPREPORTES","REP_FUENTE","REP_CODIGO"+GetWhere("=",oGenRep:REP_CODIGO))
     ENDIF

     oScript:cClpFlags   := "/i"+Alltrim(oDp:cPathInc)
     oScript:Compile(cMemo)

     IF !Empty(oScript:cError)
        MsgMemo(oScript:cError+CRLF+oDp:cCompile,"Reporte "+oGenRep:REP_CODIGO+" No puede compilar")
        RETURN .F.
     ENDIF

     oScript:SavePCode(cFileDxb)

   ELSE

     oScript:LoadPCode(cFileDxb,.T.)

   ENDIF

   oDp:nOutPut :=oGenRep:oRun:nOut
   oDp:cRptFile:=NIL
   oDp:lPrint  :=(oDp:nOutPut=2)
   oDp:lScreen :=(oDp:nOutPut=1)
   oDp:lSummary:=oGenRep:oRun:lSummary
   oDp:aTitle  :=oGenRep:aTitle
   oDp:aHead   :={}   // Valores del Encabezado, Rangos y Criterios

   oScript:Run(NIL,oGenRep)

   SysRefresh()

   IF ValType(oScript)="O" .AND. !Empty(oScript:cError)
      MensajeErr(oScript:cError,"Reporte :"+oScript:cProgram)
   ENDIF

   oScript:End()

RETURN NIL

/*
// Crear Variables para Rango y Criterio
*/
FUNCTION CREARGOVAR(oRun)
  LOCAL I,oRgo

  FOR I=1 TO LEN(oRun:aRango)

    IF EMPTY(oRun:aRango[I,3])
       oRun:aRango[I,3]:=oRun:aRango[I,2]
       oRgo:=oRun:aRango[I,5]
       IF ValType(oRgo)="O"
         oRgo:uRgoFin:=oRun:aRango[I,2]
       ENDIF
    ENDIF

    PUBLICO("RGO_I"+ALLTRIM(STR(I)),oRun:aRango[I,2])
    PUBLICO("RGO_F"+ALLTRIM(STR(I)),oRun:aRango[I,3])

  NEXT I

  // Variables del Criterio

  FOR I=1 TO LEN(oRun:aCriterio)

    PUBLICO("RGO_C"+ALLTRIM(STR(I)),oRun:aCriterio[I,3])

  NEXT I


RETURN .T.

// EOF
