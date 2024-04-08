// Programa   : DPREPPARAMFIND
// Fecha/Hora : 09/12/2006 14:34:16
// Propósito  : Buscar en Reportes
// Creado Por : Juan Navas
// Llamado por: DPPROGRAG/DPXBASE
// Aplicación : Programación
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()

   LOCAL oDlg,oFontB

   DEFAULT oDp:cText1 :=SPACE(40),;
           oDp:cText2 :=SPACE(40)

   DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -11 BOLD

   DPEDIT():New("Buscar en Parámetros en Reportes","forms\DPPROGFIND.EDT","oRepP",.T.)

   oRepP:lMsgBar:=.F.
   oRepP:nRadio :=1

   @ 0.5,.5 SAY "Texto 1:" RIGHT SIZE 22,08 COLOR  NIL,oDp:nGris FONT oFontB
   @ 1.2,.5 SAY "Texto 2:" RIGHT SIZE 22,08 COLOR  NIL,oDp:nGris FONT oFontB

   @ 0.6,03.8 GET oDp:cText1 SIZE 125,10 FONT oFontB
   @ 1.4,03.8 GET oDp:cText2 SIZE 125,10 FONT oFontB

   @ 02,10  RADIO oRepP:oRadio VAR oRepP:nRadio;
            ITEMS "&AND", "&OR" SIZE 60, 13 

   oDp:oText2:bKeyDown:={|n| oRepP:oBtnSave:ForWhen(.T.),;
                             IF(n=13,oRepP:PRGBUSCAR(),NIL)}

/*
   @ 4,01 BUTTON " Buscar " ACTION oRepP:PRGBUSCAR();
          WHEN !Empty(oDp:cText1+oDp:cText2)

   @ 4,01 BUTTON " Cerrar " ACTION oRepP:Close()
*/
   oRepP:Activate({||oRepP:INICIO()} )

RETURN .T.

FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oRepP:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          WHEN !Empty(oDp:cText1+oDp:cText2);
          ACTION (oRepP:PRGBUSCAR())

   oBtn:cToolTip:="Guardar"

   oRepP:oBtnSave:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION (oRepP:Close()) CANCEL

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })

RETURN .T.


FUNCTION PRGBUSCAR()
   LOCAL cWhere:="REP_PARAM"+GetWhere("=",oDp:cText1)+" OR REP_PARAM "+GetWhere(" LIKE ","%"+ALLTRIM(oDp:cText1)+"%")

   CURSORWAIT()

   IF !Empty(oDp:cText2)

      cWhere:=cWhere +IIF(oRepP:nRadio=1," AND "," OR ")+;
            "REP_PARAM "+GetWhere(" LIKE ","%"+ALLTRIM(oDp:cText2)+"%")
   ENDIF

   IF EMPTY(COUNT("DPREPORTES",cWhere))
      MensajeErr("No hay Programas Encontrados con el Criterio Solicitado")
      RETURN .F.
   ENDIF
   
   CURSORWAIT()
   DPLBX("DPREPORTES",NIL,cWhere)

RETURN .T.
// EOF


