// Programa   : REPRESTFIJ
// Fecha/Hora : 17/05/2004 13:54:33
// Prop¢sito  : Restaurar Valores por Fijar
// Creado Por : Juan Navas
// Llamado por: REPRUN
// Aplicaci¢n : Generador de Reportes
// Tabla      : DPDATASET

#INCLUDE "DPXBASE.CH"

FUNCTION REPRESTFIJ(oGenRep)
  LOCAL oRun :=oGenRep:oRun,nT1:=SECONDS()
  LOCAL oData,oRgo,oCri
  LOCAL I,cVar,uDesde,uHasta,uValue,nLen
  LOCAL cModo  :="ALL",aData:={"PC","USER","ALL","Ninguno"},cText:="",nFijar:=1

  IF oGenRep=NIL
    RETURN .T.
  ENDIF

  /*
  // JN 12/12/2016 Ninguno (Para no Proteger de Incidencias FIJAR o RESETEAR valores predefinidos
  */
  IF oGenRep:nFijar=4
     RETURN .F.
  ENDIF

  nFijar :=MAX(oGenRep:nFijar,1)
  cModo  :=aData[nFijar]

  IF !Empty(cModo)

    oData:=DATASET("REPORTE"+oGenRep:REP_CODIGO,cModo)

    IF oData:IsDef("NOUT")

      IF !oData:IsDef("cFileRpt")
        oData:cFileRpt :=oGenRep:aFilesRpt[1,1]
      ENDIF

      oRun:cNameRpt :=oData:cNameRpt
      oRun:nOut     :=oData:nOut
      oRun:lSummary :=oData:lSummary
      oRun:cFileRpt :=oData:cFileRpt

    ENDIF
  
    nLen:=IIF(Empty(oRun:aRango[1,1]),0,LEN(oRun:aRango))

    FOR I=1 TO nLen // LEN(oRun:aRango)

     cVar:="RGO_I"+LSTR(I)
     oRgo:=oRun:aRango[I,5]

     IF oData:IsDef(cVar)
       // .AND. (EMPTY(oRun:aRango[I,2]).OR.EMPTY(oRun:aRango[I,3])) // Rango
       uDesde:=oData:Get(cVar)
       uHasta:=oData:Get("RGO_F"+LSTR(I))
       IF ValType(uDesde)="C" // Recorta Valores
          uDesde:=LEFT(uDesde,oRgo:nLen)
          uHasta:=LEFT(uHasta,oRgo:nLen)
       ENDIF
       oRun:aRango[I,2]:=uDesde
       oRun:aRango[I,3]:=uHasta
    ENDIF

    IF !EMPTY(oRgo:cRgoIni)
       oRun:aRango[I,2]:=MacroEje(oRgo:cRgoIni)
    ENDIF

    IF !EMPTY(oRgo:cRgoFin)
       oRun:aRango[I,3]:=MacroEje(oRgo:cRgoFin)
    ENDIF

    cVar:="RGO_RL"+LSTR(I)
    IF oData:IsDef(cVar) // Criterio
       oRun:aRango[I,4]:=oData:Get("RGO_RL"+LSTR(I))
    ENDIF

   NEXT 

   nLen:=IIF(Empty(oRun:aCriterio[1,1]),0,LEN(oRun:aCriterio))

   FOR I=1 TO nLen // LEN(oRun:aCriterio)
     cVar:="CRI_C"+LSTR(I)
     oCri:=oRun:aCriterio[I,5]

    IF oData:IsDef(cVar) .AND. EMPTY(oCri:cCriIni)
       // .AND. EMPTY(oRun:aCriterio[I,3])
       // Criterio
       uValue:=oData:Get(cVar)
       IF ValType(uValue)="C" // Recorta Valores
          // oCri  :=oRun:aCriterio[I,5]
          uValue:=LEFT(uValue,oCri:nLen)
       ENDIF
       oRun:aCriterio[I,3]:=uValue
    ENDIF

    IF !EMPTY(oCri:cCriIni) 
      oRun:aCriterio[I,3]:=MacroEje(oCri:cCriIni)
    ENDIF

    cVar:="CRI_CR"+LSTR(I)
    IF oData:IsDef(cVar) 
       oRun:aCriterio[I,2]:=oData:Get(cVar)
    ENDIF
    cVar:="CRI_CL"+LSTR(I)
    IF oData:IsDef(cVar) 
       oRun:aCriterio[I,4]:=oData:Get(cVar)
    ENDIF
  NEXT I

  oData:End(.F.)

  ENDIF


RETURN .T.
// EOF
