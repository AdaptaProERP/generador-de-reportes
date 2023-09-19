// Programa   : REPFIJAR
// Fecha/Hora : 17/05/2004 11:01:36
// Prop¢sito  : Fijar los par metros por usuario
// Creado Por : Juan Navas
// Llamado por: REPRUN
// Aplicaci¢n : Generador de Reportes
// Tabla      : DPGENREP

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL oDlg,oRadio1,oRadio2,nModo:=3,nCompo:=4,oFont,oGrp,oFontB
  LOCAL oData,nFijar:=3
  LOCAL lFijar :=.F.
  LOCAL cCodigo:="CODIGO"
  LOCAL cModo  :="ALL",aData:={"PC","USER","ALL"},cText:=""

  IF ValType(oGenRep)="O"
     cCodigo:=oGenRep:REP_CODIGO
     nFijar :=MAX(oGenRep:nFijar,1)
  ENDIF

  IF nFijar=4
     MensajeErr("Fijar Parámetro no esta Autorizado para Reporte "+cCodigo)
     RETURN .F.
  ENDIF

  DEFAULT nCompo:=4

  cModo   :=aData[nFijar]
  aData   :={"Estación:"+GetHostName(),"Usuario:"+oDp:cUsuario,"Todos"}
  cText   :=aData[nFijar]

  DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

  DEFINE DIALOG oDlg TITLE "Fijar Reporte " FROM 0,10 TO 22-4+4,41;
         COLOR NIL,oDp:nGris

  @ .2 ,.5 GROUP oGrp TO  5, 17 PROMPT " Componentes ["+cText+"]" FONT oFontB
  @ 5.2,.5 GROUP oGrp TO 07, 17 PROMPT " Modo " FONT oFontB
  @ 7.2,.5 GROUP oGrp TO 09, 17 PROMPT " Código " FONT oFontB

  @ 7.2,1 SAY cCodigo FONT oFont

  @ 1,1 RADIO oRadio1 VAR nCompo;
        PROMPT "&Rango","&Criterio",ANSITOOEM("&Par metros"),"&Todos"

  AEVAL(oRadio1:aItems,{|o|o:SetFont(oFont)})

  @ 5.5,1 SAY cText;
          FONT oFontB;
          COLOR NIL,oDp:nGris

  @ 7.5,6  BUTTON " Fijar  " SIZE 35,16;
           ACTION (lFijar:=.T.,oDlg:End());
           FONT oFontB

  @ 7.5,13 BUTTON " Cerrar " SIZE 35,16;
           ACTION oDlg:End();
           FONT oFontB

  ACTIVATE DIALOG oDlg CENTERED

  IF lFijar .AND. ValType(oGenRep)="O"

     REPSAVEFIJ(cCodigo,cModo,nCompo,oGenRep)

  ENDIF

  oGenRep:=NIL

RETURN .T.
/*
// FIJAR
*/
FUNCTION REPSAVEFIJ(cCodigo,cModo,nCompo,oGenRep)
   // Este Siempre Indicar  el Modo

   IF nCompo=1 .OR. nCompo=4
      SAVERGO(cCodigo,cModo,oGenRep)
   ENDIF

   IF nCompo=2 .OR. nCompo=4
      SAVECRI(cCodigo,cModo,oGenRep)
   ENDIF

   IF nCompo=3 .OR. nCompo=4
      SAVEPAR(cCodigo,cModo)
   ENDIF

RETURN .T.
/*
// Graba los Valores del Rango
*/
FUNCTION SAVERGO(cCodigo,cModo,oGenRep)
  LOCAL oRun :=oGenRep:oRun
  LOCAL oRgo,uValIni,uValFin,cExp,I
  LOCAL oData

  oData:=DATASET("REPORTE"+cCodigo,cModo)

  FOR I=1 TO LEN(oRun:aRango)

    oRgo  :=oRun:aRango[I,5]
    uValIni:=oRun:oBrwR:aArrayData[I,2]
    uValFin:=oRun:oBrwR:aArrayData[I,3]
    uValFin:=IIF(Empty(uValFin),uValIni,uVaLFin)

    IF ValType(uValIni)="C" // Recorta Valores
      uValIni:=ALLTRIM(LEFT(uValIni,oRgo:nLen))
      uValFin:=ALLTRIM(LEFT(uValFin,oRgo:nLen))
    ENDIF

    oData:SET(ALLTRIM("RGO_I" +LSTR(I)),uValIni)
    oData:SET(ALLTRIM("RGO_F" +LSTR(I)),uValFin)

    IF UPPE(ALLTRIM(oRun:oBrwR:aArrayData[I,4]))<>"AND"
       oData:SET(ALLTRIM("RGO_RL"+LSTR(I)),oRun:oBrwR:aArrayData[I,4]) // Rango/L¢gico
    ENDIF

  NEXT I

  oData:Save()
  oData:End()

RETURN .T.

/*
// Graba los Valores del Criterio
*/
FUNCTION SAVECRI(cCodigo,cModo,oGenRep)
  LOCAL oRun :=oGenRep:oRun
  LOCAL oCri,uValCri,cExp,I
  LOCAL oData

  oData:=DATASET("REPORTE"+cCodigo,cModo)

  FOR I=1 TO LEN(oRun:aCriterio)

    oCri   :=oRun:aCriterio[I,5]
    uValCri:=oRun:oBrwC:aArrayData[I,3]

    IF ValType(uValCri)="C" // Recorta Valores
      uValCri:=ALLTRIM(LEFT(uValCri,oCri:nLen))
    ENDIF

    oData:SET(ALLTRIM("CRI_C" +LSTR(I)),uValCri)

    IF Left(oRun:oBrwC:aArrayData[I,2],1)!="="
      oData:SET(ALLTRIM("CRI_CR"+LSTR(I)),oRun:oBrwC:aArrayData[I,2])  // Criterio L¢gico
    ENDIF

    IF UPPE(ALLTRIM(oRun:oBrwC:aArrayData[I,4]))<>"AND"
      oData:SET(ALLTRIM("CRI_CL"+LSTR(I)),oRun:oBrwC:aArrayData[I,4])  // Criterio Relaci¢n
    ENDIF

  NEXT I
  oData:Save()
  oData:End(.T.)

RETURN .T.

/*
// Guardar Par metros
*/
FUNCTION SAVEPAR(cCodigo,cModo)
  LOCAL oRun :=oGenRep:oRun
  LOCAL oData

  oData:=DATASET("REPORTE"+cCodigo,cModo)
  oData:nOut    :=oRun:nOut
  oData:lSummary:=oRun:lSummary
  oData:cFileRpt:=STRTRAN(oRun:cFileRpt,"\","/")
  oData:cNameRpt:=oRun:cNameRpt
  oData:Save()
  oData:End(.F.)

RETURN .T.

// EOF
