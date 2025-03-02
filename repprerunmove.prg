// Programa   : REPPRERUNMOVE
// Fecha/Hora : 01/03/2025 14:39:24
// Propósito  : Move formulario Generador de Reportes
// Creado Por : Juan Navas
// Llamado por: RunWindow(oRun) desde DPREPRUN
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrm)
  LOCAL oGenRep:=oFrm:oRun:oGenRep
  LOCAL oRun   :=oFrm:oRun
  LOCAL oBrwR  :=oRun:oBrwR
  LOCAL oBrwC  :=oRun:oBrwC
  LOCAL nCantR :=LEN(oBrwR:aArrayData)
  LOCAL nCantC :=LEN(oBrwC:aArrayData)
  LOCAL nTopR  :=0
  LOCAL nTopC  :=0
  LOCAL nMitad :=0

  oDp:nDif:=oDp:aCoors[3]-(200+oFrm:oWnd:nHeight())
  nMitad  :=INT((oDp:nDif+68)/2)
  
  AEVAL(oFrm:oDlg:aControls,{|o,n| o:Move(o:nTop()+15,o:nLeft(),NIL,NIL,.T.)})

  oFrm:oBar:CoorsUpdate()

  oFrm:oWnd:SetSize(NIL,oDp:aCoors[3]-(130+oFrm:oBar:nHeight()),.T.)

  IF nCantR<5 .AND. nCantC>5

    nMitad:=0
    oBrwR:Move(58                          ,128,oBrwR:nWidth(),oBrwR:nHeight()+nMitad/2  ,.T.)
    oBrwC:Move(oBrwR:nTop()+oBrwR:nHeight(),128,oBrwC:nWidth(),oBrwR:nTop()+oBrwC:nHeight()+oDp:nDif+3,.t.)

  ELSE 
  
    oBrwR:Move(58                          ,128,oBrwR:nWidth(),oBrwR:nHeight()+nMitad  ,.T.)
    oBrwC:Move(oBrwR:nTop()+oBrwR:nHeight(),128,oBrwR:nWidth(),oBrwC:nHeight()+nMitad+3,.t.)

  ENDIF

  oFrm:oGrp3:Move(oFrmRun:oGrp3:nTop()+oDp:nDif,005,300,45,.T.)
  oFrm:oGrp2:Move(oFrmRun:oGrp2:nTop()+oDp:nDif,310,290,45,.T.)
  oFrm:oGrp4:Move(oFrmRun:oGrp4:nTop()+oDp:nDif,605,150,45,.T.)

  oFrm:oPrnModel:Move(oFrm:oPrnModel:nTop()+oDp:nDif,310+10,290,20,.T.) 
  oFrm:oSumary:Move(oFrm:oSumary:nTop()+oDp:nDif,605+10,150,20,.T.) 

  oFrm:oCrystal:Move(oFrm:oCrystal:nTop()+oDp:nDif,10,NIL,NIL,.T.)

  EJECUTAR("SETCOLORTOGROUP",oFrm:oDlg,oFrm)

RETURN .T.
// EOF
