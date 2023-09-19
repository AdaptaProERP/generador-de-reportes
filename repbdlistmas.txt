// Programa   : REPBDLISTMAS
// Fecha/Hora : 16/05/2013 23:55:31
// Propósito  : Continuar Contra Búsqueda
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN() 
  LOCAL oCol,uValue,nLastKey:=43 ,nAt

  DEFAULT oDp:aBrwFind:={}

  IF Type("oBrw")="U" .OR. Empty(oDp:aBrwFind)
     RETURN NIL
  ENDIF

  oCol  :=oDp:aBrwFind[1]
  uValue:=oDp:aBrwFind[3]
  nAt   :=oDp:aBrwFind[2]

  EJECUTAR("BRWFIND",oCol,uValue,nLastKey,nAt)

RETURN .T.
// EOF
