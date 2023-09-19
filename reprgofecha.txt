// Programa   : REPRGOFECHA
// Fecha/Hora : 20/02/2015 19:57:32
// Propósito  : Funcionalidad con Rango de Fechas
// Creado Por : Juan Navas
// Llamado por: Rango del Reporte
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField,cTitle,nPeriodo,cWhere,oControl)
   LOCAL aData,dDesde,dHasta,aFechas,lDialog:=.T.,dFecha:=CTOD(""),lOk:=.F.
   LOCAL dDesdeRep:=CTOD(""),dHastaRep:=CTOD(""),oBrwRep:=NIL
   LOCAL aPoint   :={1,1},oCol,nRow,nCol,nWidth:=100,nHeight:=200

  
   DEFAULT cTable :="DPMOVINV",;
           cField :="MOV_FECHA"

   DEFAULT cTitle  :="Fechas de [" +GetFromVar("{oDp:"+cTable+"}")+"]",;
           nPeriodo:=10

   DEFAULT oDp:aDataRgo:={},;
           oDp:oGenRep :=NIL

   oDp:aFechas:={}

   IF LEN(oDp:aDataRgo)=3 

      dDesdeRep:=oDp:aDataRgo[1]
      dHastaRep:=oDp:aDataRgo[2]
      oBrwRep  :=oDp:aDataRgo[3]
      cTitle   :=oBrwRep:aArrayData[oBrwRep:nArrayAt,1]

   ENDIF   

   IF LEN(oDp:aDataRgo)=2 
      dDesdeRep:=oDp:aDataRgo[1]
      dHastaRep:=oDp:aDataRgo[2]
   ENDIF

   IF oBrwRep<>NIL

     oBrwRep:nColSel:=1

     oCol    := oBrwRep:aCols[oBrwRep:nColSel]
     nRow    := ( ( oBrwRep:nRowSel - 1 ) * oBrwRep:nRowHeight ) + oBrwRep:HeaderHeight() + 2
     nCol    := oCol:nDisplayCol + 3
     nWidth  := oCol:nWidth - 4
     nHeight := oBrwRep:nRowHeight - 4
     aPoint  := { nRow, nCol }
     aPoint  := ClientToScreen( oBrwRep:hWnd, aPoint )

     aPoint[1]:=aPoint[1]+17
     aPoint[2]:=aPoint[2]-5


   ENDIF

//? oControl:ClassName()

   IF ValType(oControl)="O"
     aPoint:=AdjustWnd( oControl, nWidth, nHeight )

// ? aPoint[1],aPoint[2]
//   oWnd  :=oBtn:oWnd
   ENDIF


   oDp:cWhereText:=""

   IF !Empty(oDp:aDataRgo)
     cWhere:=EJECUTAR("REPLISTWHERE",cTable,NIL,NIL,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cField)
   ENDIF

   aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

   dDesde :=aFechas[1]
   dHasta :=aFechas[2]

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cTable,cField,cWhere),NIL,cTable,cField)

   dFecha:=ViewData(aData,cTitle)

RETURN dFecha

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB, nLin:=160
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"REPRGOFECHA.EDT","oRgoFch",.F.,lDialog)

   oRgoFch:CreateWindow(NIL,NIL,NIL,550,850+58)

   oRgoFch:lMsgBar    :=.F.
   oRgoFch:cPeriodo   :=aPeriodos[nPeriodo]
   oRgoFch:cPeriodoRep:=oRgoFch:cPeriodo
   oRgoFch:nPeriodo   :=nPeriodo
   oRgoFch:cNombre    :=""
   oRgoFch:dDesde     :=dDesde
   oRgoFch:dHasta     :=dHasta
   oRgoFch:dFecha     :=CTOD("")
   oRgoFch:cWhere     :=cWhere
   oRgoFch:cTable     :=cTable
   oRgoFch:cField     :=cField
   oRgoFch:lDialog    :=lDialog
   oRgoFch:oBrwRep    :=oBrwRep
   oRgoFch:nClrPane   :=oDp:nGris2

   oRgoFch:cPeriodoRep:=cPeriodo
   oRgoFch:dDesdeRep  :=dDesdeRep
   oRgoFch:dHastaRep  :=dHastaRep
   oRgoFch:cWhereText :=oDp:cWhereText

   oRgoFch:cWhere_  :=cWhere
   oRgoFch:cSql     :=oDp:cSql

   oRgoFch:oBrw:=TXBrowse():New( oRgoFch:oDlg )
   oRgoFch:oBrw:SetArray( aData, .T. )
   oRgoFch:oBrw:SetFont(oFont)

   oRgoFch:oBrw:lFooter     := .T.
   oRgoFch:oBrw:lHScroll    := .F.
   oRgoFch:oBrw:nHeaderLines:= 1
   oRgoFch:oBrw:nDataLines  := 1
   oRgoFch:oBrw:nFooterLines:= 1

   oRgoFch:aData            :=ACLONE(aData)

   AEVAL(oRgoFch:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
 
   oCol:=oRgoFch:oBrw:aCols[1]
   oCol:cHeader      :='Fecha'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRgoFch:oBrw:aArrayData ) } 
   oCol:nWidth       := 70+10

   oCol:=oRgoFch:oBrw:aCols[2]
   oCol:cHeader      :='Mes'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRgoFch:oBrw:aArrayData ) } 
   oCol:nWidth       := 50+30

   oCol:=oRgoFch:oBrw:aCols[3]
   oCol:cHeader      :='Día'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRgoFch:oBrw:aArrayData ) } 
   oCol:nWidth       := 60+5

   oCol:=oRgoFch:oBrw:aCols[4]
   oCol:cHeader      :='Año'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRgoFch:oBrw:aArrayData ) } 
   oCol:nWidth       := 35+3

   oCol:=oRgoFch:oBrw:aCols[5]
   oCol:cHeader      :='Cant.'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRgoFch:oBrw:aArrayData ) } 
   oCol:nWidth       := 45
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData     :={|nMonto|nMonto:= oRgoFch:oBrw:aArrayData[oRgoFch:oBrw:nArrayAt,5],FDP(nMonto,'9999')}
   oCol:cFooter      :=FDP(aTotal[5],'999999')

   oRgoFch:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oRgoFch:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRgoFch:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                            nClrText:=0,;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, oDp:nClrPane1, oDp:nClrPane2) } }

   oRgoFch:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRgoFch:oBrw:bClrFooter          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}



   oRgoFch:oBrw:bLDblClick:={|oBrw|oRgoFch:RUNCLICK() }

 //oRgoFch:oBrw:bChange:={||oRgoFch:BRWCHANGE()}
   oRgoFch:oBrw:CreateFromCode()


  //
  // Campo : Periodo para el Rango y Criterio
  //

  @ 2, nLin COMBOBOX oRgoFch:oPeriodoRep  VAR oRgoFch:cPeriodoRep ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                FONT oFont;
                ON CHANGE oRgoFch:LEEFECHASREP()

  ComboIni(oRgoFch:oPeriodoRep )

  @ 23, nLin+43  BUTTON oRgoFch:oBtn PROMPT " < " SIZE 28,20;
                 FONT oFont;
                 PIXEL;
                 ACTION (EJECUTAR("PERIODOMAS",oRgoFch:oPeriodoRep:nAt,oRgoFch:oDesdeRep,oRgoFch:oHastaRep,-1))

  @ 23, nLin+73 BUTTON oRgoFch:oBtn PROMPT " > " SIZE 28,20;
                 FONT oFont;
                 PIXEL;
                 ACTION (EJECUTAR("PERIODOMAS",oRgoFch:oPeriodoRep:nAt,oRgoFch:oDesdeRep,oRgoFch:oHastaRep,+1))

  @ 2, nLin+116 BMPGET oRgoFch:oDesdeRep  VAR oRgoFch:dDesdeRep;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRgoFch:oDesdeRep ,oRgoFch:dDesdeRep);
                SIZE 76,20;
                WHEN .T. .OR. (oRgoFch:oPeriodoRep:nAt=LEN(oRgoFch:oPeriodoRep:aItems));
                FONT oFont

   oRgoFch:oDesdeRep:cToolTip:="F6: Calendario"


  @ 23, nLin+116 BMPGET oRgoFch:oHastaRep  VAR oRgoFch:dHastaRep;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRgoFch:oHastaRep,oRgoFch:dHastaRep);
                SIZE 76,20;
                WHEN .T. .OR. (oRgoFch:oPeriodoRep:nAt=LEN(oRgoFch:oPeriodoRep:aItems));
                FONT oFont

   oRgoFch:oHastaRep:cToolTip:="F6: Calendario"

   @ 01, nLin+194 BUTTON oRgoFch:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               PIXEL;
               ACTION oRgoFch:RUNFECHAS()

   @ 3,40 SAY "Periodo"

   @ 4,40 SAY "Desde"
   @ 4,60 SAY "Hasta"

   @ 5,1 GET oRgoFch:oWhere VAR oRgoFch:cWhereText MULTI

   oRgoFch:Activate({||oRgoFch:ViewDatBar(),oRgoFch:oBrw:GoBottom(.T.),oRgoFch:oDlg:Move(aPoint[1],aPoint[2],NIL,NIL,.T.)})

   IF !lOk
      oRgoFch:dFecha:=CTOD("")
   ENDIF

RETURN oRgoFch:dFecha

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oRgoFch:oDlg
   LOCAL nLin:=0

   IF oRgoFch:lDialog
      oRgoFch:oDlg:Move(100,0,NIL,NIL,.T.)
   ENDIF

   oRgoFch:oBrw:GoBottom(.T.)
   oRgoFch:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -10 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION oRgoFch:RUNCLICK()


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oRgoFch:oBrw);
          WHEN LEN(oRgoFch:oBrw:aArrayData)>1 

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oRgoFch:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


 DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRgoFch:oBrw:GoTop(),oRgoFch:oBrw:Setfocus())


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRgoFch:oBrw:PageDown(),oRgoFch:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRgoFch:oBrw:PageUp(),oRgoFch:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRgoFch:oBrw:GoBottom(),oRgoFch:oBrw:Setfocus())


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRgoFch:Close()

  oRgoFch:oBrw:SetColor(0,oDp:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRgoFch:oBar:=oBar

  nLin:=160

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

   oRgoFch:dFecha :=oRgoFch:oBrw:aArrayData[oRgoFch:oBrw:nArrayAt,1]

   oDp:aFechas:={oRgoFch:dFecha,oRgoFch:dFecha}

   lOk:=.T.
   oRgoFch:Close()

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BREDOBCOLEE",cWhere)
  oRep:cSql  :=oRgoFch:cSql
  oRep:cTitle:=oRgoFch:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRgoFch:oPeriodo:nAt,cWhere

  oRgoFch:nPeriodo:=nPeriodo

  IF oRgoFch:oPeriodo:nAt=LEN(oRgoFch:oPeriodo:aItems)

     oRgoFch:oDesde:ForWhen(.T.)
     oRgoFch:oHasta:ForWhen(.T.)
     oRgoFch:oBtn  :ForWhen(.T.)

     DPFOCUS(oRgoFch:oDesde)

  ELSE

     oRgoFch:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRgoFch:oDesde:VarPut(oRgoFch:aFechas[1] , .T. )
     oRgoFch:oHasta:VarPut(oRgoFch:aFechas[2] , .T. )

     oRgoFch:dDesde:=oRgoFch:aFechas[1]
     oRgoFch:dHasta:=oRgoFch:aFechas[2]

     cWhere:=oRgoFch:HACERWHERE(oRgoFch:dDesde,oRgoFch:dHasta,oRgoFch:cTable,oRgoFch:cField,oRgoFch:cWhere)

     oRgoFch:LEERDATA(cWhere,oRgoFch:oBrw,oRgoFch:cTable,oRgoFch:cField)

  ENDIF

//  oRgoFch:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cTable,cField,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun   :=.F.,;
           cWhere_:=""

   IF !Empty(dDesde)

     cWhere:=GetWhereAnd(cField,dDesde,dHasta)

   ELSE

     IF !Empty(dHasta)
       cWhere:=GetWhereAnd(cField,dDesde,dHasta)
     ENDIF

   ENDIF

   IF !Empty(cWhere)
      cWhere:=cWhere+IF(Empty(cWhere_),""," AND ")+cWhere_
   ELSE
      cWhere:=cWhere_
   ENDIF

   IF lRun
     oRgoFch:LEERDATA(cWhere,oRgoFch:oBrw,cTable,cField)
     oRgoFch:oWhere:Refresh(.T.)
   ENDIF

RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cTable,cField)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}

   DEFAULT cWhere:=""

   cSql:=" SELECT "+cField+",0,0,YEAR("+cField+"), COUNT(*) AS CUANTOS "+;
         " FROM "+cTable
 
   IF !Empty(cWhere)
      cSql:=cSql+ " WHERE "+cWhere
   ENDIF

   cSql:=cSql+" GROUP BY "+cField

   aData:=ASQL(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF


   AEVAL(aData,{|a,n| aData[n,2]:=CMES(a[1]),;
                      aData[n,3]:=CSEMANA(a[1])})


   IF ValType(oBrw)="O"

      oRgoFch:cSql   :=cSql
      oRgoFch:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
      
      oCol:=oRgoFch:oBrw:aCols[4]
      oCol:cFooter      :=FDP(aTotal[4],'99999')
      oCol:=oRgoFch:oBrw:aCols[4]
     

      oRgoFch:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oRgoFch:oBar:aControls,{|o,n| o:ForWhen(.T.)})

//      oRgoFch:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
/*
  LOCAL cFileMem:="USER\BREDOBCOLEE.MEM",V_nPeriodo:=oRgoFch:nPeriodo
  LOCAL V_dDesde:=oRgoFch:dDesde
  LOCAL V_dHasta:=oRgoFch:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"
*/
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
RETURN NIL

/*
// Asignar Rango
*/
FUNCTION SETRANGO()
RETURN .T.

FUNCTION LEEFECHASREP()
  LOCAL nPeriodo:=oRgoFch:oPeriodoRep:nAt,cWhere

  oRgoFch:nPeriodoRep:=nPeriodo

  IF oRgoFch:oPeriodoRep:nAt=LEN(oRgoFch:oPeriodoRep:aItems)

     oRgoFch:oDesdeRep:ForWhen(.T.)
     oRgoFch:oHastaRep:ForWhen(.T.)
     oRgoFch:oBtn  :ForWhen(.T.)

     DPFOCUS(oRgoFch:oDesdeRep)

  ELSE

     oRgoFch:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRgoFch:oDesdeRep:VarPut(oRgoFch:aFechas[1] , .T. )
     oRgoFch:oHastaRep:VarPut(oRgoFch:aFechas[2] , .T. )

     oRgoFch:dDesdeRep:=oRgoFch:aFechas[1]
     oRgoFch:dHastaRep:=oRgoFch:aFechas[2]

  ENDIF

RETURN .T.

FUNCTION RUNFECHAS()

   lOk:=.T.
   oDp:aFechas:={oRgoFch:dDesdeRep,oRgoFch:dHastaRep}

   IF ValType(oRgoFch:oBrwRep)="O"
      oRgoFch:oBrwRep:aArrayData[oRgoFch:oBrwRep:nArrayAt,2]:=oRgoFch:dDesdeRep
      oRgoFch:oBrwRep:aArrayData[oRgoFch:oBrwRep:nArrayAt,3]:=oRgoFch:dHastaRep
      oRgoFch:oBrwRep:DrawLine(.T.)
   ENDIF

   oRgoFch:dFecha:=oRgoFch:dDesdeRep
   oRgoFch:Close()

RETURN .T.
// EOF


