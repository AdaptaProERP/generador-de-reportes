// Programa   : REPVARPUB
// Fecha/Hora : 19/05/2004 00:11:19
// Propósito  : Variables Públicas
// Creado Por : Juan Navas
// Llamado por: RANGO/CRITERIO
// Aplicación : Generador de Reporte
// Tabla      : DPGENREP

#INCLUDE "DPXBASE.CH"

PROCE REPVARPUB(oGet,cTypeVar)
   LOCAL oDlg,oBrw,oFont,I,uValue,oFontB
   LOCAL nClrPane1:=16770764
   LOCAL nClrPane2:=16566954
   LOCAL nClrText :=0
   LOCAL aDescri  :={"Variable","Descripción","Tipo"}
   LOCAL aLen     :={10,40}
   LOCAL aData    :={}
   LOCAL aTypes   :={"Caracter","Fecha","Numerico","Lógico","Bloque/Código"}
   LOCAL aType    :={"C","D","N","L","B"}
   LOCAL lSelect  :=.F.

   DEFAULT cTypeVar:=""
   // Ninguno

   FOR I=1 TO LEN(oDp:aVarPub)
     IF EMPTY(cTypeVar) .OR. UPPE(Subs(oDp:aVarPub[I,1],5,1))==cTypeVar
        AADD(aData,ACLONE(oDp:aVarPub[I]))
     ENDIF
   NEXT I

   IF EMPTY(aData)
      MensajeErr("No hay Variables de Tipo "+cTypeVar)
      RETURN .F.
   ENDIF

   AEVAL(aData,{|a,n,cType,nAt|cType:=UPPE(Subs(a[1],5,1)),nAt:=ASCAN(aType,cType),AADD(aData[n],aTypes[nAt])})

   DEFINE FONT oFont  NAME "Courier New"   SIZE 0, -14
   DEFINE FONT oFontB NAME "Arial"         SIZE 0, -14 BOLD

   DEFINE DIALOG oDlg TITLE "Variables Públicas" FROM 1,30 TO 34,70;
          COLOR oDp:nGris,NIL

   oBrw:=TXBrowse():New( oDlg )

   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLCELL
   oBrw:SetArray( aData , .T. )
   oBrw:lHScroll            := .F.
   oBrw:lFooter             := .T.
   oBrw:oFont               :=oFont
   
   oBrw:CreateFromCode()
   oBrw:Refresh(.t.)

   oBrw:aCols[1]:nWidth:=140
   oBrw:aCols[2]:nWidth:=350
   oBrw:aCols[3]:nWidth:=120

   FOR I := 1 TO LEN(oBrw:aCols)
      oBrw:aCols[I]:cHeader:=aDescri[I]
      oBrw:aCols[I]:oHeaderFont:=oFontB
   NEXT

   oBrw:bClrStd := {|| {nClrText, iif( oBrw:nArrayAt%2=0, nClrPane1  ,   nClrPane2 ) } }
   oBrw:SetFont(oFont)
   oBrw:bLDblClick:={||lSelect:=.T.,uValue:=oBrw:aArrayData[oBrw:nArrayAt,1],oDlg:End()}

   ACTIVATE DIALOG oDlg ON INIT (RVARBDBAR(oDlg,oBrw),;
                                 oBrw:SetColor(nClrText, nClrPane1))

   IF lSelect .AND. ValType(oGet)="O"
      EVAL(oGet:bSetGet,oBrw:aArrayData[oBrw:nArrayAt,1])
      oGet:Refresh(.T.)
   ENDIF

   STORE NIL TO oBrw,aData,oDlg
   Memory(-1)

RETURN uValue

/*
// Coloca la Barra de Botones
*/
FUNCTION RVARBDBAR(oDlg,oBrw)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado según Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=MIN(LEN(oBrw:aArrayData),14) // Lineas

   AEVAL(oBrw:aCols,{|o|o:nWidth:=MIN(o:nWidth,300),nWidth:=nWidth+o:nWidth+1})

   IF nWidth<150
      nDif:=150-nWidth
      oCol:=oBrw:aCols[Len(oBrw:aCols)]
      oCol:nWidth:=oCol:nWidth+nDif
      nWidth:=nWidth+nDif
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PASTE.BMP";
          ACTION (lSelect:=.T.,oDlg:End())

   oBtn:cToolTip:="Copiar la Variable"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oBrw:GoTop(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oBrw:PageDown(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oBrw:PageUp(),oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oBrw:GoBottom(),oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDlg:End()

  nHeight:=91+oBrw:nRowHeight+(oBrw:nRowHeight*nLines)+1
  nWidth +=0
  nHeight+=10 // 340

  oBar:SetColor(NIL,oDp:nGris)
  oBrw:SetColor(NIL,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(NIL,oDp:nGris) })

  oDlg:Move(90,0,nWidth+9+50,nHeight,.T.)
  oBrw:Move(50,0,nWidth+50,nHeight-85,.t.)

RETURN .T.
// EOF
