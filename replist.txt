// Programa   : REPLIST
// Fecha/Hora : 10/12/2016 10:44:34
// Propósito  : Presentar Browse Contentivos de Filtros previos del Reporte
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb)
   LOCAL I,cOperator

   DEFAULT cTable  :="DPCBTE",;
           oDp:oBrwRepFocus:=NIL,;
           oControl:=oDp:oBrwRepFocus,;
           cWhere  :=""

   cWhere:=EJECUTAR("REPLISTWHERE",cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb)

RETURN EJECUTAR("REPBDLIST",cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb)
// EOF
