// Programa   : REPOUTPUT
// Fecha/Hora : 13/04/2004 12:25:17
// Prop¢sito  : Define las Salidas del Informe
// Creado Por : Juan Navas
// Llamado por: TREPRUN
// Aplicaci¢n : Generador de Informes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lBegin,oRun,oCursor)
   LOCAL cFileDbf
   LOCAL cFileRpt
   LOCAL cMemo
   LOCAL cFileHead,cFileMem,cSalida:=""
   LOCAL nSalida,aSalida:={"Previsualización","Impresora","Ventana","Txt Windows","Excel","DBF","Html","Crystal Preview","Crystal Print","Pdf File","Pdf View"}
   LOCAL uHost   :=oDp:cIp,uUser:=oDp:cLogin, uPass:=oDp:cPass , uBD  :=oDp:cDsnData
   LOCAL uSql    :=oRun:oGenRep:cSql
   LOCAL cTitle  :=oRun:oGenRep:cTitle,nAt,aFilesRpt:={}
   LOCAL cPathExe:=STRTRAN(Lower(oDp:cPathExe),"\","/")
   LOCAL cFileWmf,cMemo:="" // JN 01/05/2017
   
   PRIVATE cRpt_Title,cRpt_Out,cRpt_Path,cRpt_Dll,cRpt_Rpt

   PRIVATE cPrvOrient:="",cPrvFile:="" // JN 01/05/2017, Salida Hacia Previe

   DEFAULT lBegin:=.T.

? "REPOUTPUT"

RETURN .T.

   IF ValType(oRun)!="O"
       RETURN .F.
   ENDIF

? lBegin,"lBegin",oRun:nOut,"oRun:nOut"

   IF !lBegin

     cSalida:=aSalida[oRun:nOut]
     EJECUTAR("AUDITORIA","DIMP",NIL,oRun:oGenRep:REP_TABLA,oRun:oGenRep:REP_CODIGO,NIL,NIL,NIL,NIL,cSalida)

   ENDIF

   IF lBegin
     oDp:cFile   :=NIL
     KILLPREVIEW() // Quita el Preview en caso de estar Activo
   ELSE
     oDp:lMysqlNativo:=.F.
   ENDIF

   IF lBegin .AND. (oRun:nOut=3 .OR. oRun:nOut=4) // Salida por TXT
      oRun:cFileTxt:=GETTMPNAME(".TXT")
      oDp:cFile    :=oRun:cFiletxt
      RETURN .T.
   ENDIF

   IF !lBegin .AND. (oRun:nOut=3) // Salida por Ventana
      RepViewTxt(oRun:cFileTxt,oRun:cTitle)  
      Return .T.
   ENDIF

   IF !lBegin .AND. (oRun:nOut=4) // Salida por Txt/Windows NotePad

      CursorWait()
      MemoWrit(oRun:cFileTxt,OEMTOANSI(MemoRead(oRun:cFileTxt)))
      WinExec(  GetWinDir()+ "\NOTEPAD.EXE "+oRun:cFileTxt)
      // EJECUTAR("TESTLPT",oRun:cFileTxt,"LPT1:")
      RETURN .T.

   ENDIF

   FERASE("TEMP\PRVTOPDF.MEM")

   // Salida por PREVIEW, Hacia PDF, los archivos WMF sera agregados a PDF
   IF TYPE("oReport")="O" .AND. "PRINT"$oReport:oDevice:ClassName() .AND. !lBegin

      FERASE("CRYSTAL\CRYSTAL.MEM")

      cMemo:=""
      AEVAL(oReport:oDevice:aMeta,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),"",",")+[{"]+a+["}]})
      ViewArray(oReport:oDevice:aMeta)
      cPrvOrient:=If(oReport:oDevice:nHorzSize() > oReport:oDevice:nVertSize(), 'L', 'P' )
      LMKDIR("PDF")
      cPrvFile  :="PDF\"+Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"
      cFileMem  :="PDF\PRVTOPDF.MEM"

      DPWRITE("PDF\PDFLIST.TXT",cMemo)

      SAVE TO (cFileMem) ALL LIKE cPrv*

      FERASE(cPrvFile)

      MsgRun("Generando Archivo "+cPrvFile,"Por Favor espere",{||WINEXEC("BIN\DPCRPE.EXE",0)})

      RETURN .T.
    
   ENDIF

   IF lBegin .AND. oRun:nOut=6

      cFileDbf:=GETTMPNAME(".DBF")

      oRun:SetMsg("Leyendo Consulta")

      CursorWait()

      IF !oRun:lFileDbf

         IF oCursor=NIL
           oCursor:=OpenTable(oRun:oGenRep:cSql,.T.)
         ENDIF

         oRun:SetMsg("Creando "+cFileDbf)
         oCursor:CTODBF(cFileDbf) // CopytoDbf(oCursor,cFileDbf,NIL,"DBFCDX")
         // Salida por DBF

      ELSE

         cFileDbf:=Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"

         IF IsDigit(Left(cFileDbf,1)) // Si el Primer Digito es 0-9
           cFileDbf:="T"+cFileDbf
         ENDIF

         cFileDbf:=oDp:cPathCrp+cFileDbf

      ENDIF

      IF !ValType(oCursor)="O"
         MensajeErr("oCursor debe ser Objeto, Tipo de Dato es "+VALTYPE(oCursor))
         RETURN .F. 
      ENDIF

      RepViewDbf(cFileDbf,oRun:cTitle,oCursor)  

      IIF(ValType(oCursor)="O",oCursor:End(),NIL)

      RETURN .F.

   ENDIF

   IF lBegin .AND. (oRun:nOut=8 .OR. oRun:nOut=9)
      // Salida por Crystal

      cFileRpt:=oRun:cFileRpt

      // Remueve la Ruta C:\DPADMWIN

      cFileRpt:=STRTRAN(Lower(cFileRpt),cPathExe,"")
      cFileRpt:=STRTRAN(cFileRpt,"\","/")

      cFileDbf:=Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"
      nSalida :=IIF(oRun:nOut=8,1,2)

      IF IsDigit(Left(cFileDbf,1)) // Si el Primer Digito es 0-9
         cFileDbf:="T"+cFileDbf
      ENDIF

      cFileDbf :=oDp:cPathCrp+cFileDbf
      cFileHead:=RPTHEAD(oRun,cFileDbf)

      // ? "AQUI DEBE CREAR ",cFileDbf

      oRun:SetMsg("Leyendo Consulta")

      IF !oRun:lFileDbf

        CursorWait()

        // JN 03/08/2016 Desde el reporte se puede excluir los filtros oGenRep:lExcluye:=.F.

        DEFAULT oRun:oGenRep:lExcluye:=.T.

        IF oCursor=NIL

           oDp:lExcluye:=oRun:oGenRep:lExcluye

           oCursor:=OpenTable(oRun:oGenRep:cSql,.T.)

        ENDIF

        oRun:SetMsg("Creando "+cFileDbf)
        FERASE(cFileDbf)
        oCursor:CTODBF(cFileDbf)

        IF !File(cFileDbf) 

           MensajeErr("Fichero "+cFileDbf+" No pudo ser creado"+CRLF+;
                      "Posiblemente el Archivo esté creado")

           // IF !CopytoDbf(oCursor,cFileDbf,NIL,"DBFCDX",.T.,.T.)
           oCursor:End()
           RETURN .F.

        ENDIF

        oCursor:End()

      ENDIF

//    IF !File(cFileRpt)
//       MensajeErr("Archivo "+cFileRpt+" no Existe")
//       RETURN .F.
//    ENDIF

      oRun:SetMsg("Ejecutando "+cFileRpt)

      IF ".FRX"$UPPE(cFileRpt) // Formulario FoxPro

        // Valores para Personalizar

        SAVE TO FOXREP\FOXPARAM ALL LIKE "U*"

        EJECUTAR("FOXREP",cFileRpt+" "+LSTR(nSalida))

      ELSE

        cFileRpt:=ALLTRIM(UPPER(cFileRpt))
        cFileRpt:=STRTRAN(cFileRpt,"/","\")

        DEFAULT oDp:lCrystalExe:=.T.,;
                oDp:cCrystalDsn:=""

        IF oDp:lCrystalExe

          cRpt_Title  :=ALLTRIM(oRun:cTitle)+" ["+ALLTRIM(oRun:cNameRpt)+"]"
          cRpt_Out    :=nSalida
          cRpt_Path   :="CRYSTAL\"
          cRpt_Dll    :=oDp:cFileDll
          cRpt_Rpt    :=cFileRpt

          cFileRpt    :=STRTRAN(cFileRpt,"/","\")
          cFileMem    :="CRYSTAL\CRYSTAL.MEM"

          SAVE TO (cFileMem) ALL LIKE cRpt*

          AEVAL(oRun:oGenRep:aFilesRpt,{|a,n| AADD(aFilesRpt,cFileNoPath(STRTRAN(a[1],"/","\")))})

          nAt:=ASCAN(aFilesRpt,{|a,n|a=cFileNoPath(cFileRpt)})

/*
// Generación Mediante CREXPORT (Compleja, ya esta implementada)
*/          
          IF nAt>0 .AND. LEN(oRun:oGenRep:aFilesRpt[nAt])>3 .AND. oRun:oGenRep:aFilesRpt[nAt,4]

             DEFAULT oRun:oGenRep:lView   :=.T.,;
                     oRun:oGenRep:cFileOut:=NIL

             IF !EJECUTAR("DSNCRYSTAL") // Verifica el DSN
                MsgMemo("No Existe DSN "+oDp:cCrystalDsn+" para Crystal Report")
                RETURN .F.
             ENDIF

             EJECUTAR("REPCREXPORT",cFileNoPath(cFileRpt),oRun:oGenRep:cFileOut)

? oRun:oGenRep:bPostRun,"oRun:oGenRep:bPostRun"
             IF ValType(oRun:oGenRep:bPostRun)="B"
               EVAL(oRun:oGenRep:bPostRun)
             ENDIF

             RETURN .F.

          ENDIF

/*
// Generación Mediante OLEAUTO, Sencilla, requiere componentes de crystal no suministrados por AdaptaPro
*/          
         
          IF "OLE"$oGenRep:REP_PRTMOD
            EJECUTAR("REPCRYSTALOLE",cRpt_Rpt,cRpt_Title,oGenRep:REP_RPTTYPE)
          ENDIF

          WINEXEC("BIN\DPCRPE.EXE",0)

          IF ValType(oRun:oGenRep:bPostRun)="B" 
             EVAL(oRun:oGenRep:bPostRun)
          ENDIF

        ELSE

          RunRpt(cFileRpt,{cFileDbf,cFileHead},nSalida,ALLTRIM(oRun:cTitle)+" ["+ALLTRIM(oRun:cNameRpt)+"]")

        ENDIF

      ENDIF

      RETURN .F.

   ENDIF

RETURN .T.

/*
// Crear Archivo Temporal
*/
FUNCTION GETTMPNAME(cExt)
  LOCAL cName:="TABLA",I:=0

  DEFAULT cExt:=".DBF"

  lMkDir("TEMP")

  cName:="TEMP\FILE"+cExt
  FERASE(cName)

  WHILE FILE(cName)
    cName:="TEMP\FILE"+STRZERO(I,3)+cExt
    FERASE(cName)
  ENDDO
    
RETURN cName
/*
// Genera el Archivo de Cabezera para el Reporte Crystal
*/
FUNCTION RPTHEAD(oRun,cFile)
   LOCAL aHead:={},I,uValue

   cFile:=STRTRAN(cFile,".DBF","_.DBF")

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
	 // Programa   : REPOUTPUT
// Fecha/Hora : 13/04/2004 12:25:17
// Prop¢sito  : Define las Salidas del Informe
// Creado Por : Juan Navas
// Llamado por: TREPRUN
// Aplicaci¢n : Generador de Informes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lBegin,oRun,oCursor)
   LOCAL cFileDbf
   LOCAL cFileRpt
   LOCAL cMemo
   LOCAL cFileHead,cFileMem,cSalida:=""
   LOCAL nSalida,aSalida:={"Previsualización","Impresora","Ventana","Txt Windows","Excel","DBF","Html","Crystal Preview","Crystal Print"}
   LOCAL uHost:=oDp:cIp,uUser:=oDp:cLogin, uPass:=oDp:cPass , uBD  :=oDp:cDsnData
   LOCAL uSql :=oRun:oGenRep:cSql
   LOCAL cTitle:=oRun:oGenRep:cTitle,nAt,aFilesRpt:={}
   LOCAL cPathExe:=STRTRAN(Lower(oDp:cPathExe),"\","/")
   LOCAL cFileWmf,cMemo:="" // JN 01/05/2017
   
   PRIVATE cRpt_Title,cRpt_Out,cRpt_Path,cRpt_Dll,cRpt_Rpt

   PRIVATE cPrvOrient:="",cPrvFile:="" // JN 01/05/2017, Salida Hacia Previe

   DEFAULT lBegin:=.T.

   IF ValType(oRun)!="O"
       RETURN .F.
   ENDIF

   cSalida:=aSalida[oRun:nOut]

   IF !lBegin
     EJECUTAR("AUDITORIA","DIMP",NIL,oRun:oGenRep:REP_TABLA,oRun:oGenRep:REP_CODIGO,NIL,NIL,NIL,NIL,cSalida)
   ENDIF

   IF lBegin
     oDp:cFile   :=NIL
     KILLPREVIEW() // Quita el Preview en caso de estar Activo
   ELSE
     oDp:lMysqlNativo:=.F.
   ENDIF

   IF lBegin .AND. (oRun:nOut=3 .OR. oRun:nOut=4) // Salida por TXT
      oRun:cFileTxt:=GETTMPNAME(".TXT")
      oDp:cFile    :=oRun:cFiletxt
      RETURN .T.
   ENDIF

   IF !lBegin .AND. (oRun:nOut=3) // Salida por Ventana
      RepViewTxt(oRun:cFileTxt,oRun:cTitle)  
      Return .T.
   ENDIF

   IF !lBegin .AND. (oRun:nOut=4) // Salida por Txt/Windows NotePad

      CursorWait()
      MemoWrit(oRun:cFileTxt,OEMTOANSI(MemoRead(oRun:cFileTxt)))
      WinExec(  GetWinDir()+ "\NOTEPAD.EXE "+oRun:cFileTxt)
      // EJECUTAR("TESTLPT",oRun:cFileTxt,"LPT1:")
      RETURN .T.

   ENDIF

   FERASE("TEMP\PRVTOPDF.MEM")

   // Salida por PREVIEW, Hacia PDF, los archivos WMF sera agregados a PDF
   IF TYPE("oReport")="O" .AND. "PRINT"$oReport:oDevice:ClassName()

      FERASE("CRYSTAL\CRYSTAL.MEM")

      cMemo:=""
      AEVAL(oReport:oDevice:aMeta,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),"",",")+[{"]+a+["}]})
      ViewArray(oReport:oDevice:aMeta)
      cPrvOrient:=If(oReport:oDevice:nHorzSize() > oReport:oDevice:nVertSize(), 'L', 'P' )
      LMKDIR("PDF")
      cPrvFile  :="PDF\"+Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"
      cFileMem  :="PDF\PRVTOPDF.MEM"

      DPWRITE("PDF\PDFLIST.TXT",cMemo)

      SAVE TO (cFileMem) ALL LIKE cPrv*

      FERASE(cPrvFile)

      MsgRun("Generando Archivo "+cPrvFile,"Por Favor espere",{||WINEXEC("BIN\DPCRPE.EXE",0)})

      RETURN .T.
    
   ENDIF

   IF lBegin .AND. oRun:nOut=6

      cFileDbf:=GETTMPNAME(".DBF")

      oRun:SetMsg("Leyendo Consulta")

      CursorWait()

      IF !oRun:lFileDbf

         IF oCursor=NIL
           oCursor:=OpenTable(oRun:oGenRep:cSql,.T.)
         ENDIF

         oRun:SetMsg("Creando "+cFileDbf)
         oCursor:CTODBF(cFileDbf) // CopytoDbf(oCursor,cFileDbf,NIL,"DBFCDX")
         // Salida por DBF

      ELSE

         cFileDbf:=Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"

         IF IsDigit(Left(cFileDbf,1)) // Si el Primer Digito es 0-9
           cFileDbf:="T"+cFileDbf
         ENDIF

         cFileDbf:=oDp:cPathCrp+cFileDbf

      ENDIF

      IF !ValType(oCursor)="O"
         MensajeErr("oCursor debe ser Objeto, Tipo de Dato es "+VALTYPE(oCursor))
         RETURN .F. 
      ENDIF

      RepViewDbf(cFileDbf,oRun:cTitle,oCursor)  

      IIF(ValType(oCursor)="O",oCursor:End(),NIL)

      RETURN .F.

   ENDIF

   IF lBegin .AND. (oRun:nOut=8 .OR. oRun:nOut=9)
      // Salida por Crystal

      cFileRpt:=oRun:cFileRpt

      // Remueve la Ruta C:\DPADMWIN

      cFileRpt:=STRTRAN(Lower(cFileRpt),cPathExe,"")
      cFileRpt:=STRTRAN(cFileRpt,"\","/")

      cFileDbf:=Alltrim(oRun:oGenRep:REP_CODIGO)+".DBF"
      nSalida :=IIF(oRun:nOut=8,1,2)

      IF IsDigit(Left(cFileDbf,1)) // Si el Primer Digito es 0-9
         cFileDbf:="T"+cFileDbf
      ENDIF

      cFileDbf :=oDp:cPathCrp+cFileDbf
      cFileHead:=RPTHEAD(oRun,cFileDbf)

      // ? "AQUI DEBE CREAR ",cFileDbf

      oRun:SetMsg("Leyendo Consulta")

      IF !oRun:lFileDbf

        CursorWait()

        // JN 03/08/2016 Desde el reporte se puede excluir los filtros oGenRep:lExcluye:=.F.

        DEFAULT oRun:oGenRep:lExcluye:=.T.

        IF oCursor=NIL

           oDp:lExcluye:=oRun:oGenRep:lExcluye

           oCursor:=OpenTable(oRun:oGenRep:cSql,.T.)

        ENDIF

        oRun:SetMsg("Creando "+cFileDbf)
        FERASE(cFileDbf)
        oCursor:CTODBF(cFileDbf)

        IF !File(cFileDbf) 

           MensajeErr("Fichero "+cFileDbf+" No pudo ser creado"+CRLF+;
                      "Posiblemente el Archivo esté creado")

           // IF !CopytoDbf(oCursor,cFileDbf,NIL,"DBFCDX",.T.,.T.)
           oCursor:End()
           RETURN .F.

        ENDIF

        oCursor:End()

      ENDIF

//    IF !File(cFileRpt)
//       MensajeErr("Archivo "+cFileRpt+" no Existe")
//       RETURN .F.
//    ENDIF

      oRun:SetMsg("Ejecutando "+cFileRpt)

      IF ".FRX"$UPPE(cFileRpt) // Formulario FoxPro

        // Valores para Personalizar

        SAVE TO FOXREP\FOXPARAM ALL LIKE "U*"

        EJECUTAR("FOXREP",cFileRpt+" "+LSTR(nSalida))

      ELSE

        cFileRpt:=ALLTRIM(UPPER(cFileRpt))
        cFileRpt:=STRTRAN(cFileRpt,"/","\")

        DEFAULT oDp:lCrystalExe:=.T.,;
                oDp:cCrystalDsn:=""

        IF oDp:lCrystalExe

          cRpt_Title  :=ALLTRIM(oRun:cTitle)+" ["+ALLTRIM(oRun:cNameRpt)+"]"
          cRpt_Out    :=nSalida
          cRpt_Path   :="CRYSTAL\"
          cRpt_Dll    :=oDp:cFileDll
          cRpt_Rpt    :=cFileRpt

          cFileRpt    :=STRTRAN(cFileRpt,"/","\")
          cFileMem    :="CRYSTAL\CRYSTAL.MEM"

          SAVE TO (cFileMem) ALL LIKE cRpt*

          AEVAL(oRun:oGenRep:aFilesRpt,{|a,n| AADD(aFilesRpt,cFileNoPath(STRTRAN(a[1],"/","\")))})

          nAt:=ASCAN(aFilesRpt,{|a,n|a=cFileNoPath(cFileRpt)})

/*
// Generación Mediante CREXPORT (Compleja, ya esta implementada)
*/          
          IF nAt>0 .AND. LEN(oRun:oGenRep:aFilesRpt[nAt])>3 .AND. oRun:oGenRep:aFilesRpt[nAt,4]

             DEFAULT oRun:oGenRep:lView   :=.T.,;
                     oRun:oGenRep:cFileOut:=NIL

             IF !EJECUTAR("DSNCRYSTAL") // Verifica el DSN
                MsgMemo("No Existe DSN "+oDp:cCrystalDsn+" para Crystal Report")
                RETURN .F.
             ENDIF

             EJECUTAR("REPCREXPORT",cFileNoPath(cFileRpt),oRun:oGenRep:cFileOut)

             IF ValType(oRun:oGenRep:bPostRun)="B"
               EVAL(oRun:oGenRep:bPostRun)
             ENDIF

             RETURN .F.

          ENDIF

/*
// Generación Mediante OLEAUTO, Sencilla, requiere componentes de crystal no suministrados por AdaptaPro
*/          
         
          IF "OLE"$oGenRep:REP_PRTMOD
            EJECUTAR("REPCRYSTALOLE",cRpt_Rpt,cRpt_Title,oGenRep:REP_RPTTYPE)
          ENDIF

          WINEXEC("BIN\DPCRPE.EXE",0)

          IF ValType(oRun:oGenRep:bPostRun)="B" 
             EVAL(oRun:oGenRep:bPostRun)
          ENDIF

        ELSE

          RunRpt(cFileRpt,{cFileDbf,cFileHead},nSalida,ALLTRIM(oRun:cTitle)+" ["+ALLTRIM(oRun:cNameRpt)+"]")

        ENDIF

      ENDIF

      RETURN .F.

   ENDIF

RETURN .T.

/*
// Crear Archivo Temporal
*/
FUNCTION GETTMPNAME(cExt)
  LOCAL cName:="TABLA",I:=0

  DEFAULT cExt:=".DBF"

  lMkDir("TEMP")

  cName:="TEMP\FILE"+cExt
  FERASE(cName)

  WHILE FILE(cName)
    cName:="TEMP\FILE"+STRZERO(I,3)+cExt
    FERASE(cName)
  ENDDO
    
RETURN cName
/*
// Genera el Archivo de Cabezera para el Reporte Crystal
*/
FUNCTION RPTHEAD(oRun,cFile)
   LOCAL aHead:={},I,uValue

   cFile:=STRTRAN(cFile,".DBF","_.DBF")

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

