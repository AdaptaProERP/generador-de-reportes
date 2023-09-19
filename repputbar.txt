// Programa   : REPPUTBAR
// Fecha/Hora : 10/03/2004 11:04:29
// Prop¢sito  : Colocar la Barra de Botones Para el Generado de Reportes
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicaci¢n : Generador de Reportes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)

     LOCAL oBar,oFont,oBtn

     IF ValType(oGenRep)=NIL
        RETURN .T.
     ENDIF

     DEFINE FONT oFont NAME "Arial"   SIZE 0, -10

     DEFINE BUTTONBAR oBar SIZE 52,60 OF oGenRep:oWnd  3D

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            TOP PROMPT "Datos";
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION oGenRep:EditHead()

    oBtn:bAction :=BlqParam({|oPar1|oPar1:EditHead()},oGenRep)
    oBtn:cToolTip:="Datos del Informe"

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Enlace";
           FILENAME "BITMAPS\LINK.BMP";
           ACTION oGenRep:Links()

    oBtn:cToolTip:="Relaci¢n Entre Tablas"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Links()},oGenRep)
    oBtn:bWhen   :=BlqParam({|oPar1|oPar1:lLinks},oGenRep) // Acceso Enlaces

    oBtn:ForWhen()

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Select";
           FILENAME "BITMAPS\QUERY.BMP";
           ACTION oGenRep:Select()

    oBtn:cToolTip:="Campos del Query [SELECT]"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Select()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Order By";
           FILENAME "BITMAPS\INDEX.BMP";
           ACTION oGenRep:Select()

    oBtn:cToolTip:="Order By Query"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:OrderBy()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar; 
           NOBORDER;
           GROUP;
           FONT oFont;
           TOP PROMPT "Grupos ";
           FILENAME "BITMAPS\BRWCOL.BMP"

    oBtn:cToolTip:="Seleccionar Grupos (Ruptura de Control)"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Ruptura()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar; 
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Columnas ";
           FILENAME "BITMAPS\BRWCOL.BMP"

    oBtn:cToolTip:="Seleccionar Columnas del Informe"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Cols()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Rango";
           FILENAME "BITMAPS\COMPILA.BMP";
           ACTION 1=1

    oBtn:cToolTip:="Rango del Reporte"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Rango()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Crear";
           FILENAME "BITMAPS\PRG.BMP";
           ACTION 1=1

    oBtn:cToolTip:="Generar C¢digo PRG del Reporte"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:BuildPrg()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Ejecutar";
           FILENAME "BITMAPS\RUN.BMP";
           ACTION 1=1

    oBtn:cToolTip:="Ejecutar Reporte "
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Run()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Grabar";
           GROUP;
           FILENAME "BITMAPS\XSAVE.BMP";
           ACTION oGenRep:Close()

    oBtn:cToolTip:="Grabar y Continuar "
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Save()},oGenRep)

    DEFINE BUTTON oBtn;
           OF oBar;
           NOBORDER;
           FONT oFont;
           TOP PROMPT "Salir";
           FILENAME "BITMAPS\XSALIR.BMP";
           ACTION oGenRep:Close()

    oBtn:cToolTip:="Salir del Informe"
    oBtn:bAction :=BlqParam({|oPar1|oPar1:Close()},oGenRep)

    oGenRep:oWnd:Maximize()

RETURN .T.

// EOF
