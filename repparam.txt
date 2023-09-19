// Programa   : REPPARAM
// Fecha/Hora : 31/12/2004 14:10:17
// Prop¢sito  : Solicitar los Par metros del Reporte
// Creado Por : Juan Navas
// Llamado por: GENREP
// Aplicaci¢n : Generador de Reportes
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
 
  LOCAL oFont,oFontB,cCodigo:="",nFijar:=4,oDlg,oRadio1,oRadio2,lFijar:=.F.
  LOCAL lPreview:=.T.,lPrinter:=.T.,lVentana:=.T.,lTxtWnd:=.T.,lExcel:=.f.,lDbf:=.t.,lHtml:=.f.,lBrowse:=.F.
  LOCAL lCrystalP:=.T.,lCrystalW:=.T.
  LOCAL nFijarOld:=1,aData:={"PC","USER","ALL"},cModo:="",oData
  LOCAL cRgoCri:=" OR ",nRgoCri:=1,oRgoCri

  IF !oGenRep=NIL

     cCodigo  :=oGenRep:REP_CODIGO

     DEFAULT oGenRep:cRgoCriAndOr:=" OR "

     lPreview :=oGenRep:lPreview
     lPrinter :=oGenRep:lPrinter 
     lVentana :=oGenRep:lVentana 
     lTxtWnd  :=oGenRep:lTxtWnd 
     lExcel   :=oGenRep:lExcel
     lDbf     :=oGenRep:lDbf
     lHtml    :=oGenRep:lHtml 
     lCrystalP:=oGenRep:lCrystalP
     lCrystalW:=oGenRep:lCrystalW
     lBrowse  :=oGenRep:lBrowse

     nFijar   :=oGenRep:nFijar
     nFijarOld:=nFijar
     cRgoCri  :=oGenRep:cRgoCriAndOr // Operador Relacional Entre Rango y Criterio
     nRgoCri  :=IF("OR"$oGenRep:cRgoCriAndOr,1,2) // Operador Relacional Entre Rango y Criterio
  
  ENDIF

  nFijar:=CTOO(nFijar,"N")

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -11 BOLD

  DEFINE DIALOG oDlg TITLE "Parámetros del Reporte: "+cCodigo FROM 0,10 TO 22+3,61;
         COLOR NIL,oDp:nGris

  @ 00.0,.5 GROUP oGrp TO 04.2,28 PROMPT " Modo de Fijar "        FONT oFontB
  @ 04.3,.5 GROUP oGrp TO 09.5,28 PROMPT " Dispositivos Válidos " FONT oFontB
  @ 09.6,.5 GROUP oGrp TO 12.0,28 PROMPT " Operador Relacional Entre Rango y Criterio " FONT oFontB


  @ .5,1 RADIO oRadio1 VAR nFijar;
        PROMPT ansitooem("&Estación (PC) "),"&Usuario","&Todos","&Ninguno"

  AEVAL(oRadio1:aItems,{|o|o:SetFont(oFont)})

  @ 5.3,01.5 CHECKBOX lPreview PROMPT ANSITOOEM("Previsualización.");
                     FONT oFont;
                     SIZE 100,08 

  @ 6.2,01.5 CHECKBOX lPrinter PROMPT ANSITOOEM("Impresora.");
                     FONT oFont;
                     SIZE 100,08

  @ 7.2,01.5 CHECKBOX lVentana PROMPT ANSITOOEM("Ventana.");
                     FONT oFont;
                     SIZE 100,08

  @ 8.2,01.5 CHECKBOX lTxtWnd PROMPT ANSITOOEM("Txt Windows.");
                     FONT oFont;
                     SIZE 100,08

  @ 9.2,01.5 CHECKBOX lExcel PROMPT ANSITOOEM("Excel.");
                     FONT oFont;
                     SIZE 100,08 WHEN .F.

  @05.3,15.5 CHECKBOX lDbf PROMPT ANSITOOEM("DBF.");
                     FONT oFont;
                     SIZE 100,08

  @06.2,15.5 CHECKBOX lHtml PROMPT ANSITOOEM("Html.");
                     FONT oFont;
                     SIZE 100,08  WHEN .F.

  @07.2,15.5 CHECKBOX lCrystalP PROMPT ANSITOOEM("Crystal Preview.");
                     FONT oFont;
                     SIZE 100,08

  @08.2,15.5 CHECKBOX lCrystalW PROMPT ANSITOOEM("Crystal Print.");
                     FONT oFont;
                     SIZE 100,08

  @09.2,15.5 CHECKBOX lBrowse PROMPT ANSITOOEM("Browse");
                      FONT oFont;
                      SIZE 100,08


  @ 10.9,1 RADIO oRgoCri VAR nRgoCri;
        PROMPT " OR "," AND "


  @ 9.5,19 BUTTON " Aceptar " SIZE 35,14;
           ACTION (lFijar:=.T.,oDlg:End());
           FONT oFontB

  @ 9.5,26 BUTTON " Cerrar " SIZE 35,14;
           ACTION oDlg:End();
           FONT oFontB

  ACTIVATE DIALOG oDlg CENTERED

  oFontB:End()
  oFont:End()

  IF lFijar .AND. ValType(oGenRep)="O"

     oGenRep:lPreview    :=lPreview
     oGenRep:lPrinter    :=lPrinter 
     oGenRep:lVentana    :=lVentana
     oGenRep:lTxtWnd     :=lTxtWnd 
     oGenRep:lExcel      :=lExcel   
     oGenRep:lDbf        :=lDbf     
     oGenRep:lHtml       :=lHtml   
     oGenRep:lCrystalP   :=lCrystalP
     oGenRep:lCrystalW   :=lCrystalW
     oGenRep:lBrowse     :=lBrowse

     oGenRep:cRgoCriAndOr:=IF(nRgoCri=1," OR "," AND ")
     oGenRep:nFijar      :=nFijar

     IF !nFijarOld=nFijar

        cModo:=aData[nFijarOld]
        oData:=DATASET("REPORTE"+cCodigo,cModo)
        oData:DelGroup()
        oData:End()

     ENDIF

  ENDIF

RETURN NIL
// EOF
