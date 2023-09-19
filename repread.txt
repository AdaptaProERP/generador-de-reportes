// Programa     : REPREAD
// Descompilado : c:\dpsgev51\DPXBASE\repread.dxb

#INCLUDE  "DPXBASE.CH"


FUNCTION MAIN(oGenRep,lDelete)
LOCAL oIni,lComp:=.F.
LOCAL cFileScr,aDevice
LOCAL oDb:=OpenOdbc(oDp:cDsnConfig)

 lDelete := If(lDelete == nil,.F.,lDelete )

 IF oGenRep=NIL
  RETURN NIL
 ENDIF 

 // Cuando se modifica el reporte debe actualizar *.REP 30/06/2021
 IF oGenRep:nOption=3
   oIni:=UpGradeRep(oGenRep)
 ENDIF

 IF Empty(oGenRep:REP_PARAM)
    oGenRep:REP_PARAM :=SQLGET("DPREPORTES","REP_PARAM","REP_CODIGO"+GetWhere("=",oGenRep:REP_CODIGO),NIL,oDb)
    oGenRep:cParameter:=oGenRep:REP_PARAM
 ENDIF

 IF !Empty(oGenRep:cParameter) .OR. !FILE(oGenRep:cFileIni)
   DPWRITE(oGenRep:cFileIni,STRSQLOFF(oGenRep:cParameter))
 ENDIF 

 lComp:=(LEN(MEMOREAD(oGenRep:cFileIni))==LEN(oGenRep:REP_PARAM))

 oIni:=Tini():New(oGenRep:cFileIni )

 IF oGenRep:nOption=0 .AND. (ALLTRIM(oIni:Get("HEAD","HORA" ,"" ))<>ALLTRIM(oGenRep:REP_HORA ) .OR. !lComp)
   MSGRUN("Actualizando Reporte "+oGenRep:REP_CODIGO,"Espere....",{|| oIni:=UpGradeRep(oGenRep)})
 ENDIF 


 aDevice:=oIni:Get("HEAD","DEVICE","")

 IF EMPTY(aDevice)
  aDevice:="1,1,1,1,0,1,0,1,1,1,1,0,0"
 ENDIF 

 aDevice:=MACROEJE("{"+aDevice+"}")

 IF LEN(aDevice)<12
   AADD(aDevice,1)
   AADD(aDevice,1)
   AADD(aDevice,0)
 ENDIF 

 oGenRep:lPreview :=(aDevice[01]=1)
 oGenRep:lPrinter :=(aDevice[02]=1)
 oGenRep:lVentana :=(aDevice[03]=1)
 oGenRep:lTxtWnd :=(aDevice[04]=1)
 oGenRep:lExcel :=(aDevice[05]=1)
 oGenRep:lDbf :=(aDevice[06]=1)
 oGenRep:lHtml :=(aDevice[07]=1)
 oGenRep:lCrystalP:=(aDevice[08]=1)
 oGenRep:lCrystalW:=(aDevice[09]=1)
 oGenRep:lPdfView :=(aDevice[10]=1)
 oGenRep:lPdfFile :=(aDevice[11]=1)
 oGenRep:lBrowse  :=(aDevice[12]=1)

 oGenRep:nFijar       :=oIni:Get("HEAD","NFIJAR" ,3 )
 oGenRep:cSql         :=oIni:Get("HEAD","SQL" ,"" )
 oGenRep:cSqlSelect   :=oIni:Get("HEAD","SQLSELECT","" )
 oGenRep:cSqlInnerJoin:=oIni:Get("HEAD","SQLINNER","" )
 oGenRep:cSqlOrderBy  :=oIni:Get("HEAD","SQLORDER","" )
 oGenRep:cSqlGroupBy  :=oIni:Get("HEAD","SQLGROUP","" )
 oGenRep:cOrderRupt   :=oIni:Get("HEAD","ORDERRUPT","" )
 oGenRep:lGroupBy     :=oIni:Get("HEAD","GROUPBY" ,.F.)
 oGenRep:lSum :=oIni:Get("HEAD","SUM" ,.T.)
 oGenRep:lDescend :=(" DESC " $ oGenRep:cSqlOrderBy+" ")
 oGenRep:cRgoCriAndOr :=oIni:Get("HEAD","REP_RGOCRIANDOR"," AND ")
 oGenRep:cFieldUpdate := If(oGenRep:cFieldUpdate == nil,"",oGenRep:cFieldUpdate )
 oGenRep:cTableUpdate := If(oGenRep:cTableUpdate == nil,"",oGenRep:cTableUpdate )

 oGenRep:lUpServer  :=.T.
 oGenRep:lDownServer:=.T.

IF Empty(oGenRep:cRgoCriAndOr)
 oGenRep:cRgoCriAndOr:=" AND "
ENDIF 

 oGenRep:REP_PRTMOD :=oIni:Get("HEAD","REP_PRTMOD","")
 oGenRep:REP_RPTTYPE:=oIni:Get("HEAD","REP_RPTTYPE","")
 oGenRep:REP_PRINTER:=oIni:Get("HEAD","REP_PRINTER","")
 oGenRep:REP_MAIL :=oIni:Get("HEAD","REP_MAIL" ,.F.)
 READSELECT(oGenRep,oIni)
 READORDER(oGenRep,oIni)
 READCOLS(oGenRep,oIni)
 READLINKS(oGenRep,oIni)
 READRUPT(oGenRep,oIni)
 READRANGO(oGenRep,oIni)
 READCRIT(oGenRep,oIni)
 READRPT(oGenRep,oIni)
 cFileScr:=STRTRAN(oGenRep:cFileIni,".REP",".SRE")

IF FILE(cFileScr) .AND. EMPTY(oGenRep:cMemo)
 oGenRep:cMemo:=MemoRead(cFileScr)
ENDIF 

 oGenRep:GetTablas()

IF lDelete
 FERASE(oGenRep:cFileIni)
ENDIF 

RETURN .T.

FUNCTION READSELECT(oGenRep,oIni)
LOCAL cSelect,aSelect,I
 cSelect:=oIni:Get("HEAD","SELECT","")
 cSelect:=REPSINLLAVES(cSelect)
 aSelect:=_VECTOR(cSelect,CHR(8))
FOR I=1 TO LEN(aSelect)
 aSelect[I]:=_VECTOR(aSelect[I],",")
 AADD(aSelect[I],"")
NEXT 
 oGenRep:aSelect:=ACLONE(aSelect)
RETURN .T.

FUNCTION READORDER(oGenRep,oIni)
LOCAL cOrder,aOrder,I
 cOrder :=oIni:Get("HEAD","ORDERBY","")
 aOrder :=_VECTOR(cOrder,";")
FOR I=1 TO LEN(aOrder)
 aOrder[I]:=MACROEJE(aOrder[I])
 AADD(aOrder[I],"")
NEXT 
 oGenRep:aOrderBy:=ACLONE(aOrder)
RETURN .T.

FUNCTION READLINKS(oGenRep,oIni)
LOCAL cLinks,aLinks,I
 cLinks:=oIni:Get("HEAD","LINKS","")
 aLinks:=_VECTOR(cLinks,";")
FOR I=1 TO LEN(aLinks)
 aLinks[I] :=MACROEJE(aLinks[I])
 aLinks[I,2]:=GetTableName(aLinks[I,1])
 aLinks[I,4]:=GetTableName(aLinks[I,3])
NEXT 
 oGenRep:aLinks:=ACLONE(aLinks)

 //ViewArray(oGenRep:aLinks)
RETURN .T.

FUNCTION READCOLS(oGenRep,oIni)
LOCAL nCol:=0,I,cCol
LOCAL cField:="",cTitle1:="",cTitle2:="",cExp:="",cExp2:="",cExp3:="",cType:="",cTable:="",cPicture:=""
LOCAL nLen:=0,nDec:=0,nAling:=0,lTotal:=.F.,nSize:=0
LOCAL aCols:={},oCol
 nCol:=oIni:Get("HEAD","COLS",nCol)
FOR I=1 TO nCol
 oCol:=TCOL():New(oGenRep)
 cCol :="COL"+STRZERO(I,2)
 cField :=oIni:Get(cCol,"FIELD" ,cField )
 cTitle1 :=oIni:Get(cCol,"TITLE1",cTitle1 )
 cTitle2 :=oIni:Get(cCol,"TITLE2",cTitle2 )
 cExp :=oIni:Get(cCol,"EXP" ,cExp )
 cExp2 :=oIni:Get(cCol,"EXP2" ,cExp2 )
 cExp3 :=oIni:Get(cCol,"EXP3" ,cExp3 )
 cType :=oIni:Get(cCol,"TYPE" ,cType )
 cTable :=oIni:Get(cCol,"TABLE" ,cTable )
 cPicture:=oIni:Get(cCol,"PICTURE",cPicture)
 nLen :=oIni:Get(cCol,"LEN" ,nLen )
 nSize :=oIni:Get(cCol,"SIZE" ,nSize )
 nDec :=oIni:Get(cCol,"DEC" ,nDec )
 nAling :=oIni:Get(cCol,"ALING" ,nAling )
 lTotal :=oIni:Get(cCol,"TOTAL" ,lTotal )
 oCol:=TCOL():New(oGenRep)
 oCol:cExp :=cExp
 oCol:cExp2 :=cExp2
 oCol:cExp3 :=cExp3
 oCol:cTitle1 :=cTitle1
 oCol:cTitle2 :=cTitle2
 oCol:cType :=cType
 oCol:cField :=cField
 oCol:cTable :=cTable
 oCol:cPicture:=cPicture
 oCol:nDec :=nDec
 oCol:nLen :=nLen
 oCol:nSize :=nSize
 oCol:nAling :=nAling
 oCol:lTotal :=lTotal
 AADD(aCols,{cField,cType,nLen,cTitle1,cField,cTable,oCol})
NEXT 
 oGenRep:aCols:=ACLONE(aCols)
RETURN NIL

FUNCTION READRUPT(oGenRep,oIni)
LOCAL I,oRup,cRup,nRup:=0
 oGenRep:aRuptura:={}
 nRup:=oIni:Get("HEAD","RUPT",nRup)
FOR I=1 TO nRup
 oRup:=TRUP():New()
 cRup:="RUP"+STRZERO(I,2)
 oRup:cTitle :=oIni:Get(cRup,"TITLE" ,"" )
 oRup:cExp :=oIni:Get(cRup,"EXP" ,"" )
 oRup:cRepres :=oIni:Get(cRup,"REPRES" ,"" )
 oRup:lPage :=oIni:Get(cRup,"PAGE" ,.T.)
 oRup:lLines :=oIni:Get(cRup,"LINES" ,.T.)
 oRup:lNewLine :=oIni:Get(cRup,"NEWLINE",.T.)
 oRup:lSumariza:=oIni:Get(cRup,"SUMARIZA",.T.)
 AADD(oGenRep:aRuptura,{oRup:cTitle,oRup:cExp,oRup})
NEXT 
RETURN NIL

FUNCTION READRANGO(oGenRep,oIni)
LOCAL I,oRgo,cRgo,nCol:=0,aLine
 nCol:=oIni:Get("HEAD","RANGOS",nCol)
 oGenRep:aRango:={}
FOR I=1 TO nCol
 aLine:=ARRAY(6)
 cRgo :="RGO"+STRZERO(I,2)
 aLine[1]:=oIni:Get(cRgo,"FIELD" ,"" )
 aLine[2]:=oIni:Get(cRgo,"TYPE" ,"" )
 aLine[3]:=oIni:Get(cRgo,"LEN" ,0 )
 aLine[4]:=oIni:Get(cRgo,"TABLE" ,"" )
 aLine[5]:=oIni:Get(cRgo,"TITLE" ,"" )
 oRgo:=TRGO():New(oGenRep)
 oRgo:uRgoIni:=NIL
 oRgo:uRgoFin:=NIL
 oRgo:cField :=oIni:Get(cRgo,"FIELD" ,"" )
 oRgo:cTitle :=oIni:Get(cRgo,"TITLE" ,"" )
 oRgo:cType :=oIni:Get(cRgo,"TYPE" ,"" )
 oRgo:cTable :=oIni:Get(cRgo,"TABLE" ,"" )
 oRgo:cPicture :=oIni:Get(cRgo,"PICTURE","" )
 oRgo:cWhen :=oIni:Get(cRgo,"WHEN" ,"" )
 oRgo:cValid :=oIni:Get(cRgo,"VALID" ,"" )
 oRgo:cAction :=oIni:Get(cRgo,"ACTION" ,"" )
 oRgo:cRgoIni :=oIni:Get(cRgo,"RGOINI" ,"" )
 oRgo:cRgoFin :=oIni:Get(cRgo,"RGOFIN" ,"" )
 oRgo:cMsg :=oIni:Get(cRgo,"MSG" ,"" )
 oRgo:cOperator:=oIni:Get(cRgo,"OPERATOR","" )
 oRgo:nEditType:=oIni:Get(cRgo,"EDITTYPE",0 )
 oRgo:nDec :=oIni:Get(cRgo,"DEC" ,0 )
 oRgo:nLen :=oIni:Get(cRgo,"LEN" ,0 )
 oRgo:lZero :=oIni:Get(cRgo,"ZERO" ,.T. )
 oRgo:lList :=oIni:Get(cRgo,"LIST" ,.T. )
 oRgo:lEmpty :=oIni:Get(cRgo,"EMPTY" ,.T. )

IF Left(oRgo:cRgoIni,1,1)="["
 oRgo:cRgoIni:=ALLTRIM(oRgo:cRgoIni)
 oRgo:cRgoIni:=SUBS(oRgo:cRgoIni,2,LEN(oRgo:cRgoIni)-2)
ENDIF 


IF ALLTRIM(oGenRep:cTableUpdate)==ALLTRIM(oRgo:cTable) .AND. ALLTRIM(oGenRep:cFieldUpdate)==ALLTRIM(oRgo:cField)
 oRgo:nLen:=SQLFIELDLEN(oRgo:cTable,oRgo:cField)
ENDIF 

 aLine[6]:=oRgo
 AADD(oGenRep:aRango,aLine)
NEXT 
RETURN NIL

FUNCTION READCRIT(oGenRep,oIni)
LOCAL I,oCri,cCri,nCol:=0,aLine
 nCol:=oIni:Get("HEAD","CRITERIOS",nCol)
 oGenRep:aCriterio:={}
FOR I=1 TO nCol
 aLine:=ARRAY(6)
 cCri :="CRI"+STRZERO(I,2)
 aLine[1]:=oIni:Get(cCri,"FIELD" ,"" )
 aLine[2]:=oIni:Get(cCri,"TYPE" ,"" )
 aLine[3]:=oIni:Get(cCri,"LEN" ,0 )
 aLine[4]:=oIni:Get(cCri,"TABLE" ,"" )
 aLine[5]:=oIni:Get(cCri,"TITLE" ,"" )
 oCri:=TCri():New(oGenRep)
 oCri:uCriIni:=NIL
 oCri:uCriFin:=NIL
 oCri:cField :=oIni:Get(cCri,"FIELD" ,"" )
 oCri:cTitle :=oIni:Get(cCri,"TITLE" ,"" )
 oCri:cType   :=oIni:Get(cCri,"TYPE" ,"" )
 oCri:cTable   :=oIni:Get(cCri,"TABLE" ,"" )
 oCri:cPicture :=oIni:Get(cCri,"PICTURE","" )
 oCri:cWhen   :=oIni:Get(cCri,"WHEN" ,"" )
 oCri:cValid  :=oIni:Get(cCri,"VALID" ,"" )
 oCri:cAction :=oIni:Get(cCri,"ACTION" ,"" )
 oCri:cCriIni :=oIni:Get(cCri,"CRIINI" ,"" )
 oCri:cMsg    :=oIni:Get(cCri,"MSG" ,"" )
 oCri:cOperator:=oIni:Get(cCri,"OPERATOR","" )
 oCri:cRelation:=oIni:Get(cCri,"RELATION","" )
 oCri:nEditType:=oIni:Get(cCri,"EDITTYPE",0 )
 oCri:nDec     :=oIni:Get(cCri,"DEC" ,0 )
 oCri:nLen     :=oIni:Get(cCri,"LEN" ,0 )
 oCri:lZero    :=oIni:Get(cCri,"ZERO" ,.T. )
 oCri:lList    :=oIni:Get(cCri,"LIST" ,.T. )
 oCri:lEmpty   :=oIni:Get(cCri,"EMPTY" ,.T. )

IF ALLTRIM(oGenRep:cTableUpdate)==ALLTRIM(oCri:cTable) .AND. ALLTRIM(oGenRep:cFieldUpdate)==ALLTRIM(oCri:cField)
 oCri:nLen:=SQLFIELDLEN(oCri:cTable,oCri:cField)
ENDIF 


IF Empty(oCri:cOperator)
 oCri:cOperator:="AND"
ENDIF 


IF Empty(oCri:cRelation)
 oCri:cRelation:="="
ENDIF 

 aLine[6]:=oCri
 AADD(oGenRep:aCriterio,aLine)
NEXT 
RETURN NIL

FUNCTION READRPT(oGenRep,oIni)
LOCAL cFileRpt,aFileRpt,I,aNew:={}
LOCAL cBinDir :=LOWER(cFilePath(GetModuleFileName(GetInstance() )))
LOCAL lCrExport:=.F.,cDirOut:="crystal\"
 cFileRpt:=oIni:Get("HEAD","CRYSTAL","")
 aFileRpt:=_VECTOR(cFileRpt,";")
FOR I=1 TO LEN(aFileRpt)
 aFileRpt[I] :=MACROEJE(aFileRpt[I])
 aFileRpt[I,1]:=Lower(aFileRpt[I,1])

IF cBinDir$aFileRpt[I,1]
 aFileRpt[I,1]:=STRTRAN(aFileRpt[I,1],cBinDir,"")
ENDIF 


IF LEN(aFileRpt[I])=3
 AADD(aFileRpt[I],.F.)
ENDIF 


IF !("\"$aFileRpt[I,1])
 aFileRpt[I,1]:=cDirOut+ALLTRIM(aFileRpt[I,1])
ENDIF 


IF !FILE(aFileRpt[I,1])
ENDIF 


IF FILE(aFileRpt[I,1])
 AADD(aNew,ACLONE(aFileRpt[I]))
ENDIF 

NEXT 
 aFileRpt:=ACLONE(aNew)
 oGenRep:aFilesRpt:=ACLONE(aFileRpt)
 oGenRep:aFilesRpt_:=ACLONE(aFileRpt)
RETURN .T.

FUNCTION UPGRADEREP(oGenRep)
  LOCAL oIni
  LOCAL cFileScr:=STRTRAN(oGenRep:cFileIni,".REP",".SRE")
  LOCAL oTable

  oTable:=OpenTable("SELECT REP_FUENTE,REP_PARAM FROM DPREPORTES "+ "WHERE REP_CODIGO"+GetWhere("=",cCodigo),.T.)
  oGenRep:cMemo     :=STRSQLOFF(oTable:REP_FUENTE)
  oGenRep:cParameter:=STRSQLOFF(oTable:REP_PARAM )
  oTable:End()
  DPWRITE(oGenRep:cFileIni,oGenRep:cParameter)
  DPWRITE(cFileScr,oGenRep:cMemo)
  EJECUTAR("REPCOMPILA",oGenRep)
  oIni:=Tini():New(oGenRep:cFileIni )

RETURN oIni

FUNCTION REPSINLLAVES(cMemo)

IF LEFT(ALLTRIM(cMemo),1)="{"
 cMemo:=STRTRAN(cMemo,"};{",CHR(8))
 cMemo:=STRTRAN(cMemo,"}","")
 cMemo:=STRTRAN(cMemo,"{","")
 cMemo:=STRTRAN(cMemo,'","',",")
 cMemo:=STRTRAN(cMemo,"'" ,"")
ENDIF 

RETURN cMemo
