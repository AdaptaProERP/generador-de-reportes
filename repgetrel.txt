// Programa   :
// Fecha/Hora : 12/04/2004 14:44:13
// Prop¢sito  : Devolver en Array los posibles operadores relacionales
// Creado Por : Juan navas
// Llamado por: Generador de Reportes
// Aplicaci¢n : Generador de Reportes
// Tabla      : DPGENREP

#INCLUDE "DPXBASE.CH"

PROCE REPGETREL(cType)

   LOCAL aRelation :={"= Igual",;
                      "<> Diferente",;
                      "> Mayor que",;
                      "< Menor que",;
                      ">= Mayor o Igual que ",;
                      "<= Menor o Igual que "}

   DEFAULT cType:="C"

   IF cType="C" .OR. cType="M"

       AADD(aRelation,"LIKE[X%] Cadena Iniciada en ")
       AADD(aRelation,"LIKE[%X%] Cadena Asociada en ")
       AADD(aRelation,"NOT_LIKE[X%] Cadena no Iniciada ")
       AADD(aRelation,"NOT_LIKE[%X%] Cadena no Asociada ")

       AADD(aRelation,"IN Incluido en Lista")
       AADD(aRelation,"NOT_IN No Incluido en Lista")

   ENDIF

RETURN aRelation

// EOF
