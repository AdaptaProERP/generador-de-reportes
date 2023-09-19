// Programa   : HTMLHEAD
// Fecha/Hora : 07/12/2018 23:05:57
// Propósito  : Agregar los Valores del Browse hacia el HTML
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrm)
   LOCAL aHead:={}

   IF oFrm=NIL
      RETURN NIL
   ENDIF

   oFrm:aHead:={}

   DEFAULT oFrm:cPeriodo:=NIL,;
           oFrm:dDesde  :=NIL,;
           oFrm:dHasta  :=NIL

   AADD(aHead,{"Consulta",oFrm:oWnd:cTitle})

   IF oFrm:cPeriodo<>NIL
      AADD(aHead,{"Periodo" ,oFrm:cPeriodo})
   ENDIF

IF oFrm:dDesde<>NIL .AND. oFrm:dHasta<>NIL

   AADD(aHead,{"Periodo"   ,DTOC(oFrm:dDesde)+" - "+DTOC(oFrm:dHasta)})

ELSE

   IF oFrm:dDesde<>NIL
      AADD(aHead,{"Desde"   ,oFrm:dDesde})
   ENDIF

   IF oFrm:dHasta<>NIL
       AADD(aHead,{"Hasta"   ,oFrm:dHasta})
   ENDIF

ENDIF

   AADD(aHead,{"Usuario"   ,OPE_NOMBRE(oDp:cUsuario)+" PC "+oDp:cPcName})
   AADD(aHead,{"Fecha"     ,DTOC(oDp:dFecha)+" - "+oDp:cHora})

RETURN aHead
// EOF
