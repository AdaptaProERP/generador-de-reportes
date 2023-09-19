// Programa   : REPOUTPUTEND
// Fecha/Hora : 13/04/2004 12:25:17
// Prop¢sito  : Define las Salidas del Informe
// Creado Por : Juan Navas
// Llamado por: TREPRUN
// Aplicaci¢n : Generador de Informes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oRun,oCursor)
   LOCAL cFileDbf,cPrvOut
   LOCAL cFileRpt
   LOCAL cMemo
   LOCAL cFileHead,cFileMem,cSalida:=""
   LOCAL nSalida :="",aSalida:={}
   LOCAL uHost   :=oDp:cIp,uUser:=oDp:cLogin, uPass:=oDp:cPass , uBD  :=oDp:cDsnData
   LOCAL uSql    :=oRun:oGenRep:cSql
   LOCAL cTitle  :=oRun:oGenRep:cTitle,nAt,aFilesRpt:={}
   LOCAL cPathExe:=STRTRAN(Lower(oDp:cPathExe),"\","/")
   LOCAL cFileWmf,cMemo:="" // JN 01/05/2017
   LOCAL cFile
   LOCAL aSalida:={}
   
   IF ValType(oRun)!="O"
      RETURN .F.
   ENDIF

   AADD(aSalida,"Previsualización")
   AADD(aSalida,"Impresora")
   AADD(aSalida,"Ventana")
   AADD(aSalida,"Txt Windows")
   AADD(aSalida,"Excel")
   AADD(aSalida,"DBF")
   AADD(aSalida,"Html")
   AADD(aSalida,"Crystal Preview")
   AADD(aSalida,"Crystal Print")
   AADD(aSalida,"Pdf Archivo")
   AADD(aSalida,"Pdf Visualización")

   cSalida:=aSalida[oRun:nOut]

   EJECUTAR("AUDITORIA","DIMP",NIL,oRun:oGenRep:REP_TABLA,oRun:oGenRep:REP_CODIGO,NIL,NIL,NIL,NIL,cSalida)

   IF oRun:nOut=12 // Salida por Browse
      EJECUTAR("REPTOARRAY",oRun:cFileTxt)
      RETURN NIL
   ENDIF



   IF (oRun:oGenRep:lCrystalP .OR. oRun:oGenRep:lCrystalW) .AND. (oRun:oGenRep:lPdfView .OR. oRun:oGenRep:lPdfFile) .AND. ValType(oReport:oDevice)="O"

     FERASE("CRYSTAL\CRYSTAL.MEM")

//   ViewArray(oReport:oDevice:aMeta)

     oGenRep:oRun:nOut:=oGenRep:nOutX

     cMemo:=""
//   AEVAL(oReport:oDevice:aMeta,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),"",",")+[{"]+a+["}]})
     AEVAL(oReport:oDevice:aMeta,{|a,n| cMemo:=cMemo+IF(Empty(cMemo),"",",")+a})

//    ViewArray(oReport:oDevice:aMeta)

      cPrvOrient:=If(oReport:oDevice:nHorzSize() > oReport:oDevice:nVertSize(), 'L', 'P' )
      LMKDIR("PDF")
      cPrvFile  :="PDF\"+Alltrim(oRun:oGenRep:REP_CODIGO)+".PDF"
      cFileMem  :="PDF\PRVTOPDF.MEM"
      cPrvOut   :=oGenRep:nOutX

      DPWRITE("PDF\PDFLIST.TXT",cMemo)

      SAVE TO (cFileMem) ALL LIKE cPrv*

      FERASE(cPrvFile)

      cFile:=oDp:cBin+cPrvFile

      MsgRun("Generando Archivo "+cPrvFile,"Por Favor espere",{||WINEXEC("BIN\DPCRPE.EXE",1)})

      cFile:=oDp:cBin+cPrvFile

      IF oRun:nOut=10
        // Visualizar el PDF
        MensajeErr("Nombre del Archivo "+CLPCOPY(cFile),"Archivo PDF Generado")
      ENDIF

      RETURN .T.
    
   ENDIF

  IF (oRun:nOut=3) // Salida por Ventana
      RepViewTxt(oRun:cFileTxt,oRun:cTitle)  
      Return .T.
   ENDIF

   IF (oRun:nOut=4) // Salida por Txt/Windows NotePad

      CursorWait()
      MemoWrit(oRun:cFileTxt,OEMTOANSI(MemoRead(oRun:cFileTxt)))
      WinExec(  GetWinDir()+ "\NOTEPAD.EXE "+oRun:cFileTxt)
      // EJECUTAR("TESTLPT",oRun:cFileTxt,"LPT1:")
      RETURN .T.

   ENDIF

RETURN .T.
// EOF


