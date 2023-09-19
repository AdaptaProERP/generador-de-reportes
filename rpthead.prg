// Programa   : RPTHEAD
// Fecha/Hora : 18/05/2021 23:26:06
// Propósito  : Crear CRYSTAL\FILE.DBF
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oRun)
   LOCAL cFileDbf,nSalida,cFileHead,oCursor,cFileSql,cTitle

   IF oRun=NIL
      RETURN .T.
   ENDIF

   cTitle  :=oRun:oGenRep:REP_DESCRI

   cFileDbf:=Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"
   nSalida :=IIF(oRun:nOut=8,1,2)

   IF IsDigit(Left(cFileDbf,1)) // Si el Primer Digito es 0-9
      cFileDbf:="T"+cFileDbf
   ENDIF

   cFileSql:="TEMP\REP_"+ALLTRIM(oRun:oGenRep:REP_CODIGO)+".SQL"
   cFileDbf :=oDp:cPathCrp+cFileDbf

   IF oCursor=NIL
      oCursor:=OpenTable(oRun:oGenRep:cSql,.T.)
   ENDIF

   oCursor:CTODBF(cFileDbf) // CopytoDbf(oCursor,cFileDbf,NIL,"DBFCDX")
   DPWRITE(cFileSql,oCursor:cSql)

   cFileHead:=RPTHEAD(oRun,cFileDbf)

RETURN .T.

/*
// Genera el Archivo de Cabezera para el Reporte Crystal
*/
FUNCTION RPTHEAD(oRun,cFile)
   LOCAL aHead:={},I,uValue

   cFile:=STRTRAN(cFile,".DBF","_.DBF")

   DEFAULT cTitle:=""

   AADD(aHead,{"REPTITLE",PADR(cTitle    ,100)})

   // Sucursal funciona como Empresa y Evita modificar los Formatos CRYSTAL

   DEFAULT oDp:lSucComoEmp:=.F.

   IF oDp:lSucComoEmp
       oDp:cEmpresa:=oDp:cSucDESCRI
   ENDIF

   // Aqui van todos los Valores del Rango y Criterio //

   FOR I=1 TO LEN(oRun:aRango)

     uValue:=oRun:aRango[I,1]+" [Todos]"

     IF I<=LEN(oRun:oGenRep:aRango)

       IF oRun:oGenRep:aRango[I,6]:lEmpty .OR. !Empty(oRun:aRango[I,2])
        uValue:=oRun:aRango[I,1]+" Desde: "+CTOO(oRun:aRango[I,2],"C")+" Hasta: "+CTOO(oRun:aRango[I,3],"C")
       ENDIF

       AADD(aHead,{"RANGO"+STRZERO(I,2),uValue})

     ELSE

      AADD(aHead,{"RANGO"+STRZERO(I,2),""})

     ENDIF

   NEXT I

   FOR I=1 TO LEN(oRun:aCriterio)
     uValue:=oRun:aCriterio[I,3]
     uValue:=IIF(Empty(uValue),"Todos",uValue)
     uValue:=ALLTRIM(oRun:aCriterio[I,1])+" "+ALLTRIM(oRun:aCriterio[I,2])+" "+CTOO(uValue,"C")
     AADD(aHead,{"CRITERIO"+STRZERO(I,2),uValue})
   NEXT I

   cFile:=ALLTRIM(cFile)

   // CreateHead(cFile,aHead,oRun:cTitle) // Genera los Datos del Encabezado
   EJECUTAR("CREATEHEAD",cFile,aHead,oRun:cTitle) // Genera los Datos del Encabezado

   CLOSE ALL

RETURN cFile
// EOF

