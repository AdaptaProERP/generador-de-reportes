// Programa   : REPBDLISTINI
// Fecha/Hora : 14/07/2015 12:45:06
// Propósito  : Iniciación de Búsqueda por Nombre
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField,cWhere,cText)
    LOCAL cWhereRet:="",cGet1,cGet2,nLen:=0,nDec:=0,nRadio:=1
    LOCAL oGet1,oGet2,oDlg,oFont,oBtn,oRadio

    DEFAULT cTable:="DPCLIENTES",;
            cText :="Nombre",;
            cField:="CLI_NOMBRE",;
            oDp:lLeft:=.F.

    SqlFieldLen(cTable,cField,NIL,@nLen,@nDec)

    cGet1:=SPACE(nLen)  
    cGet2:=SPACE(nLen)

    DEFINE FONT oFont  NAME "MS Sans Serif" SIZE 0, -12 BOLD

    DEFINE DIALOG oDlg;
           TITLE "Buscar "+GetFromVar("{oDp:x"+cTable+"}");
           SIZE 400,200;
          COLOR NIL,oDp:nGris

   oDlg:lHelpIcon:=.F.

   @ 5.8,1 CHECKBOX oDp:lLeft PROMPT ANSITOOEM("Lado Izquierdo") SIZE 140,09;
           FONT oFont

    @ 0.2,1 SAY cText FONT oFont COLOR NIL,oDp:nGris

//  @ 1.8,1 SAY cText+" (2)" FONT oFont

    @ 1.1,.8 GET oGet1 VAR cGet1 SIZE NIL,11 FONT oFont
    @ 2.1,.8 GET oGet2 VAR cGet2 SIZE NIL,11 FONT oFont;
             WHEN !Empty(cGet1)

    oGet1:bKeyDown:={ |nKey| IF(nKey=VK_F6 .AND. !Empty(cGet1+cGet2), BuscarReg() , NIL) }
    oGet2:bKeyDown:={ |nKey| IF(nKey=VK_F6 .AND. !Empty(cGet1+cGet2), BuscarReg() , NIL) }

    @ 03,01 RADIO oRadio VAR nRadio;
            ITEMS "&AND", "&OR";
            SIZE 30, 13;
            WHEN !Empty(cGet2)
 

    @03.7,12 SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XFIND2.BMP",,"BITMAPS\XFINDG2.BMP" NOBORDER;
             LEFT PROMPT "Buscar F6";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (BuscarReg());
             WHEN !Empty(cGet1+cGet2)

    oBtn:cToolTip:="Buscar Registros"
    oBtn:cMsg    :=oBtn:cToolTip

    @03.7,22 SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
             LEFT PROMPT "Cancelar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oDlg:End() CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

    AEVAL(oRadio:aItems,{|o|o:SetFont(oFont) })

    ACTIVATE DIALOG oDlg CENTERED ON INIT (oGet1:SetFocus(),.F.)

RETURN cWhereRet

FUNCTION BuscarReg()

   LOCAL nCount,cScope,cOper:=" LIKE "
   LOCAL cLeft:=IIF(oDp:lLeft,"","%")

   cScope:=cField+GetWhere(cOper,cLeft+ALLTRIM(cGet1)+"%")

   IF !Empty(cGet2)

      cScope:=cScope+ IIF(nRadio=1," AND "," OR ")+;
              cField+GetWhere(cOper,cLeft+ALLTRIM(cGet2)+"%")

   ENDIF

   nCount:=MYCOUNT(cTable,cScope)
 
   IF nCount=0
      MensajeErr("Registros no Encontrados")
      RETURN .F.
   ENDIF

   cWhereRet:=cScope

   oDlg:End()

RETURN .T.
// EOF


