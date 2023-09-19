// Programa   : REPRUPTURA
// Fecha/Hora : 31/03/2004 08:56:50
// Propósito  : Generar lista de Campos del Order by
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicación : Generador de Reportes
// Tabla      : DPREPORTE

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL cList  :="",I,aCampos,U
  LOCAL cSelect:=""  // Lista de Campos SELECT
  LOCAL cOrder :=""  // Lista del OrderBy
  LOCAL aSelect:={}
  LOCAL aTodos :={}
  LOCAL aTables:={}

  IF ValType(oGenRep)!="O"
     RETURN .F.
  ENDIF

  FOR I=1 TO LEN(oGenRep:aSelect)
     AADD(aSelect,UPPE(ALLTRIM(oGenRep:aSelect[I,1])))
     AADD(aTables,UPPE(ALLTRIM(oGenRep:aSelect[I,4])))
  NEXT I

  FOR I=1 TO LEN(oGenRep:aOrderBy)
     cOrder:=cOrder+IIF(I=1,"",",")+oGenRep:aOrderBy[I,1]
  NEXT I

  FOR I:=1 TO LEN(oGenRep:aRuptura)
     aCampos:=_VECTOR(oGenRep:aRuptura[I,2],"+")
     AEVAL(aCampos,{|a,n|a:=UPPE(a),a:=STRTRAN(a,"OCURSOR:",""),aCampos[n]:=a,AADD(aTodos,a)})
  NEXT I

  /*
  // Buscará en Select para buscar en cada lista
  */
  cList:=""
  FOR I=1 TO LEN(aSelect)
     FOR U=1 TO LEN(aTodos)
       IF aSelect[I]$aTodos[U] .AND. !aSelect[I]$cList
          cList:=cList+IIF(Empty(cList),"",",")+ALLTRIM(aTables[I])+"."+ALLTRIM(aSelect[I])
       ENDIF
     NEXT U
  NEXT I

  IF Left(cOrder,Len(cList))=cList
     cList:=""
  ELSE
    cList:=cList+IIF(Empty(cOrder),"",",")
  ENDIF

  // Order Adicional By para Las Rupturas de Control
  oGenRep:cOrderRupt:=cList  

RETURN .T.
//
