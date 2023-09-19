// Programa   : REPPRERUN
// Fecha/Hora : 30/04/2004 11:18:12
// Propósito  : Ejecución Antes de Presentar el Formulario de Ejecución
// Creado Por : Juan Navas
// Llamado por: TGENREP():REPRUN()
// Aplicación : Generador de Reportes
// Tabla      : DPREPORTE

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL I,uValue,oRun

  IF ValType(oGenRep)!="O"
      RETURN .F.
  ENDIF

  oRun:=oGenRep:oRun

  FOR I=1 TO LEN(oRun:aRango)
    uValue:=oGenRep:GetPar("RGO_I"+ALLTRIM(STR(I)))
    IF !uValue=NIL
      oRun:aRango[I,2]:=uValue
    ENDIF
    uValue:=oGenRep:GetPar("RGO_F"+ALLTRIM(STR(I)))
    IF !uValue=NIL
      oRun:aRango[I,3]:=uValue
    ENDIF
  NEXT I

  FOR I=1 TO LEN(oRun:aCriterio)
    uValue:=oGenRep:GetPar("RGO_C"+ALLTRIM(STR(I)))
    IF !uValue=NIL
      oRun:aCriterio[I,3]:=uValue
    ENDIF
  NEXT I

RETURN .T.
// EOF
