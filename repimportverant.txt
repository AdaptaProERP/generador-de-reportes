// Programa   : REPIMPORTVERANT
// Fecha/Hora : 19/11/2005 12:11:43
// Propósito  : Importar Reportes desde la Version Anterior
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Definiciones
// Tabla      : TODAS

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL aData:={},nCuantos:=0,oData
  LOCAL I,oFontBrw,oBrw,oCol,oFont,oFontB
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  LOCAL cTitle:="Impotar Reportes desde la Version Anterior"
  LOCAL cFileMem:="MYSQL.MEM"
  LOCAL _MycPass:="",_MycLoging:=""

  EJECUTAR("CONFIGSYSLOAD")
   
  IF FILE(cFileMem)

     REST FROM (cFileMem) ADDI

     _MycPass  :=ENCRIPT(_MycPass  ,.F.)
     _MycLoging:=ENCRIPT(_MycLoging,.F.)

  ENDIF

//  aData:=ASQL("SELECT EMP_CODIGO,EMP_NOMBRE,EMP_BD,EMP_FCHRES,EMP_HORRES,EMP_SELRES FROM DPEMPRESA ORDER BY CONCAT(EMP_FCHRES,EMP_HORRES,EMP_SELRES) DESC ")

  oData:=DATACONFIG("CONFIG","IMPORTBDANT")
  oData:End(.F.)

  AADD(aData,{""    ,""  ,.F.,"","Aplicación",.F.})

  nCuantos:=LEN(aData)

  DEFINE FONT oFontBrw NAME "Tahoma" SIZE 0,-12

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  DpMdi(cTitle,"oRepImpAnt","REPIMPORTVERANT.EDT")

  oRepImpAnt:Windows(0,0,aCoors[3]-160,MIN(780+100,aCoors[4]-10),.T.) // Maximizado

  oRepImpAnt:cPath  :=PADR(oData:Get("PATH"  ,"" ),120)  // CURDRIVE()+":\DPADMWIN\")
  oRepImpAnt:dFchRes:=oData:Get("FCHRES",CTOD(""))
  oRepImpAnt:cHorRes:=oData:Get("HORRES",CTOD(""))
  oRepImpAnt:lSelRes:=oData:Get("SELRES",.T.     )
  oRepImpAnt:cPath  :=STRTRAN(oRepImpAnt:cPath,"\"+"\","\")
  oRepImpAnt:cPath  :=STRTRAN(oRepImpAnt:cPath,"\"+"\","\")
  oRepImpAnt:cPath  :=PADR(oRepImpAnt:cPath,120)
  oRepImpAnt:cBD    :=PADR(oData:Get("BD","ADMCONFIG"),120)
  oRepImpAnt:aVacio :=ACLONE(aData)

//  AADD(aData,{"SYS", oDp:cDpSys ,oDp:cDsnConfig,oRepImpAnt:dFchRes,oRepImpAnt:cHorRes,oRepImpAnt:lSelRes})

  oRepImpAnt:nRecord:=0
  oRepImpAnt:lStruct:=.T.  // No Incluye Estructura de Datos
  oRepImpAnt:cMemo:=""
  oRepImpAnt:lMsgBar:=.F.
  oRepImpAnt:lAutoClose:=.T.
  oRepImpAnt:lBarDef   :=.T.

  oRepImpAnt:cLogin:=_MycLoging
  oRepImpAnt:cPass :=_MycPass  

  oRepImpAnt:lDocCli:=.F.
  oRepImpAnt:cWhereC:=""

  oRepImpAnt:lDocPro:=.F.
  oRepImpAnt:cWhereP=""

  oRepImpAnt:nClrText :=CLR_HBLUE
  oRepImpAnt:nClrText1:=2039583

// oRepImpAnt:cLogin :=PADR(oData:Get("cLogin","root"),20)
// oRepImpAnt:cPass  :=PADR(oData:Get("cPass" ,""    ),20)

  oRepImpAnt:cOut   :=""
  oRepImpAnt:lMsgRun:=.T.
  oRepImpAnt:lRunOk :=.F.
  oRepImpAnt:aFiles :={} // Respaldo con todos los SQL
  oRepImpAnt:nCuantos:=LEN(aData)

  oRepImpAnt:oBrw:=TXBrowse():New( oRepImpAnt:oWnd )
  oBrw:=oRepImpAnt:oBrw

  oBrw:SetArray( aData )
  oBrw:SetFont(oFontBrw)

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3
  oBrw:nHeaderLines:= 2

  oCol:=oBrw:aCols[1]
  oCol:cHeader:="Código"
  oCol:nWidth :=140
  oCol:bLClickHeader     := {|r,c,f,o| SortArray( o, oRepImpAnt:oBrw:aArrayData ) } 

  oCol:=oBrw:aCols[2]
  oCol:cHeader:="Descripción"
  oCol:nWidth :=200+100
  oCol:bLClickHeader     := {|r,c,f,o| SortArray( o, oRepImpAnt:oBrw:aArrayData ) } 

  oCol:=oBrw:aCols[3]
  oCol:cHeader:="Persona"+CRLF+"lizado"
  oCol:nWidth:= 55
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bStrData     :={||""}
  oCol:bLClickHeader     := {|r,c,f,o| SortArray( o, oRepImpAnt:oBrw:aArrayData ) } 

  oCol:bBmpData     :={||oBrw:=oRepImpAnt:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,3],1,2) }
  oCol:nDataStyle   :=oCol:DefStyle( AL_LEFT, .F.)
//  oCol:bLDClickData :={||oRepImpAnt:PrgSelect(oRepImpAnt)}
//  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oRepImpAnt:ChangeAllImp(oRepImpAnt,nRow,nCol,nKey,oCol,.T.)}

  oCol:=oBrw:aCols[4]
  oCol:cHeader:="Fecha"
  oCol:nWidth :=74
  oCol:bLClickHeader     := {|r,c,f,o| SortArray( o, oRepImpAnt:oBrw:aArrayData ) } 

  oCol:=oBrw:aCols[5]
  oCol:cHeader:="Aplicación"
  oCol:nWidth :=150
  oCol:bLClickHeader     := {|r,c,f,o| SortArray( o, oRepImpAnt:oBrw:aArrayData ) } 


  oCol:=oBrw:aCols[6]
  oCol:cHeader:="Importar"
  oCol:nWidth:= 65
  oCol:AddBmpFile("BITMAPS\checkverde.bmp")
  oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
  oCol:bStrData     :={||""}

  oCol:bBmpData     :={||oBrw:=oRepImpAnt:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,6],1,2) }
  oCol:nDataStyle   :=oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData :={||oRepImpAnt:PrgSelect(oRepImpAnt,6)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oRepImpAnt:ChangeAllImp(oRepImpAnt,nRow,nCol,nKey,oCol,.T.)}


  oBrw:bClrStd:={|oBrw|oBrw:=oRepImpAnt:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,6], oRepImpAnt:nClrText ,  oRepImpAnt:nClrText1 ),;
                                               iif( oBrw:nArrayAt%2=0, oRepImpAnt:nClrPane1 ,  oRepImpAnt:nClrPane2  ) } }

  oBrw:bClrSel:={|oBrw|oBrw:=oRepImpAnt:oBrw,{65535,16733011}}

  oRepImpAnt:oBrw:CreateFromCode()
  oRepImpAnt:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRepImpAnt)}

//  oRepImpAnt:BRWRESTOREPAR()

//  oBrw:bClrHeader:={||{0,12632256}}

  oBrw:bClrHeader := {|| {0,oDp:nGrid_ClrPaneH}}
  oBrw:bClrFooter := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  AEVAL(oBrw:aCols,{|o,n|  o:bClrHeader := {|| {0,oDp:nGrid_ClrPaneH}} })


  oRepImpAnt:oWnd:oClient := oRepImpAnt:oBrw

  oRepImpAnt:oFocus:=oBrw
  oRepImpAnt:Activate({||oRepImpAnt:NMCONBAR(oRepImpAnt)})

RETURN oRepImpAnt

// Coloca la Barra de Botones
FUNCTION NMCONBAR(oRepImpAnt)
  LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
  LOCAL nWidth :=0 // Ancho Calculado segœn Columnas
  LOCAL nHeight:=0 // Alto
  LOCAL nLines :=0 // Lineas
  LOCAL oDlg:=oRepImpAnt:oWnd

  DEFINE CURSOR oCursor HAND
  DEFINE BUTTONBAR oBar SIZE 80,170+80 OF oDlg 3D CURSOR oCursor

  DEFINE BUTTON oRepImpAnt:oBtnRun OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\RUN.BMP";
         ACTION oRepImpAnt:RunBackup(oRepImpAnt)

  oRepImpAnt:oBtnRun:cToolTip:="Iniciar Respaldo de Datos"

  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\IMPORTAR.BMP";
         ACTION EJECUTAR("MYSQLMEMIMPORT")

  oBtn:cToolTip:="Importar Credenciales MYSQL.MEM desde Carpeta de Versión Anterior"

  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\XFIND.BMP";
         ACTION EJECUTAR("BRWSETFIND",oRepImpAnt:oBrw)

  oBtn:cToolTip:="Buscar Base de Datos"


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oRepImpAnt:oBrw,oRepImpAnt);
          ACTION EJECUTAR("BRWSETFILTER",oRepImpAnt:oBrw)

  oBtn:cToolTip:="Filtrar Registros"

  IF EJECUTAR("DBISTABLE",oDp:cDsnData,"DPDOCCLI")

    DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\CLIENTE.BMP";
           ACTION oRepImpAnt:IMPDOCCLI()

    oBtn:cToolTip:="Importar Documentos del Cliente"

  ENDIF
  
  IF EJECUTAR("DBISTABLE",oDp:cDsnData,"DPDOCPRO")

    DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\PROVEEDORES.BMP";
           ACTION oRepImpAnt:IMPDOCPRO()

    oBtn:cToolTip:="Importar Documentos del Proveedor"

  ENDIF



  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\xTOP.BMP";
         ACTION (oRepImpAnt:oBrw:GoTop(),oRepImpAnt:oBrw:Setfocus())

  oBtn:cToolTip:="Primera Base de Datos"

  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\xFIN.BMP";
         ACTION (oRepImpAnt:oBrw:GoBottom(),oRepImpAnt:oBrw:Setfocus())

  oBtn:cToolTip:="Ultima Base de Datos"

  DEFINE BUTTON oBtn OF oBar NOBORDER FONT oFont FILENAME "BITMAPS\XSALIR.BMP";
         ACTION oRepImpAnt:Close()

  oBtn:cToolTip:="Cerrar Formulario"

  AEVAL(oBar:aControls,{|o,n|o:cMsg:=o:cToolTip})

  oRepImpAnt:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRepImpAnt:SETBTNBAR(45,45,oBar)

  @ 10,1 SAY "Carpeta Origen de la Versión Anterior"
  @ 11,1 SAY "Base de Datos Origen"

  @ 12,01 METER oRepImpAnt:oMeterR VAR oRepImpAnt:nRecord

  @ 12,1 BMPGET oRepImpAnt:oPath VAR oRepImpAnt:cPath NAME "BITMAPS\FOLDER5.BMP";
                              ACTION (cDir:=cGetDir(oRepImpAnt:cPath),;
                              IIF(!EMPTY(cDir),oRepImpAnt:oPath:VarPut(PADR(cDir,60),.t.),NIL))

  oRepImpAnt:oPath:cToolTip:="Carpeta Destino del Respaldo, Presione F6 para Seleccionar"

  @ 14,1 BMPGET oRepImpAnt:oBD VAR oRepImpAnt:cBD NAME "BITMAPS\DATABASE.BMP";
                              ACTION oRepImpAnt:VERBD(oRepImpAnt:oBD);
                              VALID oRepImpAnt:VALBD()

  oRepImpAnt:oBD:cToolTip:="Base de Datos Origen, Presione F6 para Seleccionar"

  oRepImpAnt:oBD:bkeyDown:={|nkey| IIF(nKey=13, oRepImpAnt:REINICIABRW(),NIL) }

  @ 02,40 GET oRepImpAnt:oMemo VAR  oRepImpAnt:cMemo MULTILINE READONLY SIZE 100,100

//  @ 1,1 CHECKBOX oRepImpAnt:oStruct VAR oRepImpAnt:lStruct PROMPT "Incluye Estructura"
//  oRepImpAnt:oStruct:cToolTip:="Sin estructura el Respaldo es optimo"+CRLF+"sólo será recuperado en Base de datos que si estructura"

  oBar:SetColor(CLR_BLACK,oDp:nGris2)

  BMPGETBTN(oRepImpAnt:oPath) // ,nil,13)
  BMPGETBTN(oRepImpAnt:oBD) // ,nil,13)

 
RETURN .T.

FUNCTION REINICIABRW()

  oRepImpAnt:oBrw:aArrayData:=ACLONE(oRepImpAnt:aVacio)
  oRepImpAnt:oBrw:nArrayAt:=1
  oRepImpAnt:oBrw:nRowSel:=1
  oRepImpAnt:oBrw:GoTop()
  oRepImpAnt:oBrw:Refresh(.F.)

RETURN .T.

// Seleccionar Concepto
FUNCTION PrgSelect(oRepImpAnt,nCol)
  LOCAL oBrw:=oRepImpAnt:oBrw
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL lSelect

  DEFAULT nCol:=6

  IF ValType(oBrw)!="O"
    RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

RETURN .T.

// Exportar Programas
FUNCTION RunBackup(oRepImpAnt)
  LOCAL aSelect:={},cSql,oData,I
  LOCAL nT1  :=Seconds()
  LOCAL cFile,oTable,oOrg,oDes,oDb,cTable,cTableD,cDb:=ALLTRIM(oRepImpAnt:cBD),cWhere,cKey,aKey
  LOCAL oMySql:=oDp:oMySqlCon,aData:={}
  LOCAL aCodigo:={},cSql,U,oIni,aFileRpt:={},aFileExp:={},cFileRep,cFileRpt
  LOCAL cWhere:=""

  oDb:=TMSDataBase():New( oMySql, cDb, .t. )

  cWhere:=""

  IF !Empty(oRepImpAnt:cWhereC) 
     cWhere:=oRepImpAnt:cWhereC
  ENDIF

  IF !Empty(oRepImpAnt:cWhereP) 
     cWhere:=cWhere + IF(Empty(cWhere),""," OR ")+oRepImpAnt:cWhereP
  ENDIF

  IF !Empty(cWhere)
     cWhere:=" WHERE "+cWhere
  ENDIF

// ? cWhere
// RETURN 

  IF Empty(oRepImpAnt:oBrw:aArrayData[1,1])

     aData:=ASQL("SELECT REP_CODIGO,REP_DESCRI,REP_ALTERA,REP_FECHA,REP_APLICA,REP_ALTERA FROM DPREPORTES "+cWhere,oDb)

     IF Empty(aData)
        MensajeErr("No hay Reportes")
        RETURN .T.
     ENDIF

     oRepImpAnt:oBrw:aArrayData:=ACLONE(aData)
     oRepImpAnt:oBrw:Refresh(.T.)
     RETURN .T.

  ENDIF

// ? oDb:ClassName()

  oData:=DATACONFIG("CONFIG","IMPORTBDANT")
  oData:Set("cLogin",oRepImpAnt:cLogin)
  oData:Set("cPass" ,oRepImpAnt:cPass )
  oData:Save()
  oData:End()

  oRepImpAnt:oMeterR:SetTotal(LEN(oRepImpAnt:oBrw:aArrayData))
  oRepImpAnt:cMemo :=""
  oRepImpAnt:cNo   :=""
  oRepImpAnt:cSi   :=""
  oRepImpAnt:aFiles:={}

  oRepImpAnt:cPath:=ALLTRIM(oRepImpAnt:cPath)

  IF !RIGHT(oRepImpAnt:cPath,1)="\"
    oRepImpAnt:cPath:=ALLTRIM(oRepImpAnt:cPath)+"\"
  ENDIF


  FOR I:=1 TO LEN(oRepImpAnt:oBrw:aArrayData)

     IF oRepImpAnt:oBrw:aArrayData[I,6]

       oRepImpAnt:oMeterR:Set(I)

       cTable:=oRepImpAnt:oBrw:aArrayData[I,1]
       cFileRep:=ALLTRIM(oRepImpAnt:cPath)+"REPORT\"+ALLTRIM(cTable)+".REP"

// ? cFileRep,cTable,FILE(cFileRep)

       oIni:=Tini():New( cFileRep)
       cFileRpt:=oIni:Get("HEAD","CRYSTAL" ,"")
       aFileRpt:=_VECTOR(cFileRpt,";")

       FOR U=1 TO LEN(aFileRpt)
         aFileRpt[U] :=STRTRAN(aFileRpt[U],CHR(29),"'")
         aFileRpt[U] :=MACROEJE(aFileRpt[U])
         AADD(aFileExp,ALLTRIM(oRepImpAnt:cPath+aFileRpt[U,1]))
       NEXT U

       AADD(aCodigo,oRepImpAnt:oBrw:aArrayData[I,1])

    ENDIF

  NEXT I

  IF Empty(aCodigo)
     MensajeErr("Necesario seleccionar los Reportes que desea Importar")
     RETURN .T.
  ENDIF

  oRepImpAnt:oMemo:Append("Copiando Crystal Report"+CRLF)

  FOR I=1 TO LEN(aFileExp)

     IF FILE(aFileExp[I])
       cTable:="TEMP\"+cFileNoPath(aFileExp[I])
       oRepImpAnt:oMemo:Append(cTable+" "+LSTR(I)+"/"+LSTR(LEN(aFileExp))+CRLF)
       COPY FILE (aFileExp[I]) TO (cTable)
     ENDIF

  NEXT I

  // ViewArray(aFileExp)
  // Ultima base de datos es CONFIG

  IF !Empty(aFileExp)
    cSql:="SELECT * FROM DPREPORTES WHERE "+GetWhereOr("REP_CODIGO",aCodigo)
    OpenTable(cSql,.T.,oDb):CTODBF("TEMP\DPREPORTES.DBF")
  ENDIF

//  oRepImpAnt:oMemo:Append("Proceso Concluido"+CRLF)

  oData:=DATACONFIG("CONFIG","IMPORTBDANT")
  oData:Set("PATH"  ,oRepImpAnt:cPath  )
  oData:Set("BD"    ,oRepImpAnt:cBD    )
  oData:Save()
  oData:End()

  CursorArrow()

  oDb:Close()

  IF oRepImpAnt:lAutoClose
    oRepImpAnt:Close()
  ENDIF

 EJECUTAR("DPREPIMPORT",CURDRIVE()+":\"+CURDIR()+"\temp\")
//  EJECUTAR("DPREPIMPORT")
//  oImpRep:oDir:VarPut(CURDRIVE()+":\"+CURDIR()+"\temp\",.T.)



RETURN NIL

// Iniciar Exportar Programas
FUNCTION EXPORTRUN(oEdit)
  LOCAL cFileDbf,oData,oCursor,cError:=""

  ? "AQUI DEBE GRABAR LA ULTIMA FECHA DE RESPALDOS"
RETURN .T.

// Cambiar Modulo
FUNCTION PRGCHANGE(oRepImpAnt)
  LOCAL aData,I
RETURN .T.

FUNCTION COPYMODULO(oRepImpAnt,cModulo)
RETURN aData

// Seleccionar Todos los Programas de la Lista
FUNCTION SelectAll(oRepImpAnt)
  LOCAL I,nCol:=5,nCuantos:=0,lSelect:=.T.

  lSelect:=!oRepImpAnt:oBrw:aArrayData[1,5]

  FOR I=1 TO LEN(oRepImpAnt:oBrw:aArrayData)
    oRepImpAnt:oBrw:aArrayData[I,5]:=lSelect
  NEXT I
   
  oRepImpAnt:oBrw:Refresh(.T.)
RETURN .T.

// Selecciona o Desmarca a Todos
FUNCTION ChangeAllImp(oFrm)
  LOCAL oBrw:=oFrm:oBrw
  LOCAL lSelect:=!oBrw:aArrayData[1,6]

  AEVAL(oBrw:aArrayData,{|a,n|oBrw:aArrayData[n,6]:=lSelect})

  oBrw:Refresh(.T.)
RETURN .T.

// Realiza el Backup
FUNCTION MYSQLBACK(cPath,cDB)
RETURN .T.

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oRepImpAnt)


/*
// Ver las Bases de Datos
*/
FUNCTION VERBD(oControl)
  LOCAL cBd   :=ALLTRIM(EVAL(oControl:bSetGet))
  LOCAL nLen  :=LEN(cBd)
  LOCAL cLista:=ALLTRIM(EJECUTAR("MYSQLLISTBD",oControl,EVAL(oControl:bSetGet),oRepImpAnt:cPath))

// ? cBd,"cBd",cLista,cBd

  IF !cBd=cLista
     oRepImpAnt:oBrw:aArrayData:=ACLONE(oRepImpAnt:aVacio)
     oRepImpAnt:oBrw:nArrayAt:=1
     oRepImpAnt:oBrw:nRowSel:=1
     oRepImpAnt:oBrw:GoTop()
     oRepImpAnt:oBrw:Refresh(.F.)
  ENDIF

  IF "GET"$oControl:ClassName() .AND. !Empty(cLista)
     oControl:VarPut(PADR(cLista,nLen),.T.)
  ENDIF

RETURN cLista

FUNCTION VALBD()

RETURN .T.

/*
// Importar Documentos del Cliente
*/

FUNCTION IMPDOCCLI()
  LOCAL aDocCli:=ASQL("SELECT TDC_TIPO FROM DPTIPDOCCLI")

  oRepImpAnt:lDocCli:=.T.

  AEVAL(aDocCli,{|a,n| aDocCli[n]:="DOCCLI"+ALLTRIM(a[1])})

  AADD(aDocCli,"DPRECIBOS")

  oRepImpAnt:aDocCli:=ACLONE(aDocCli)
  oRepImpAnt:cWhereC:=GetWhereOr("REP_CODIGO",aDocCli)

  oRepImpAnt:REINICIABRW()
  oRepImpAnt:RunBackup(oRepImpAnt)

RETURN .T.


FUNCTION IMPDOCPRO()
  LOCAL aDocPro:=ASQL("SELECT TDC_TIPO FROM DPTIPDOCPRO")

  oRepImpAnt:lDocPro:=.T.

  AEVAL(aDocPro,{|a,n| aDocPro[n]:="DOCPRO"+ALLTRIM(a[1])})

  AADD(aDocPro,"DPCBTEPAGO")

  oRepImpAnt:aDocPro:=ACLONE(aDocPro)
  oRepImpAnt:cWhereP:=GetWhereOr("REP_CODIGO",aDocPro)

  oRepImpAnt:REINICIABRW()
  oRepImpAnt:RunBackup(oRepImpAnt)

RETURN .T.



// EOF


