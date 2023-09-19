// Programa   : REPLISTWHERE
// Fecha/Hora : 10/12/2016 11:31:26
// Propósito  : Crea Clausula Where pare REPLIST, REPFECHA
// Creado Por : Juan Navas
// Llamado por: REPLIST y REPFECHA
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb,cField)
   LOCAL I,cOperator,nAt

   oDp:cWhereText:=""

   DEFAULT cTable  :="DPCBTE",;
           oDp:oBrwRepFocus:=NIL,;
           oControl:=oDp:oBrwRepFocus,;
           cWhere  :="",;
           cField  :=""

//? cField,"Campo que Excluye Necesario en REPRGOFECHA"
//? cTable,aFields,lGroup,cWhere,cTitle,aTitle,cFind,cFilter,cSgdoVal,cOrderBy,oControl,oDb,cField,"c-cfIELD"

   FOR I=1 TO LEN(oDp:oGenRep:aRango)

     IF cTable=oDp:oGenRep:aRango[I,4] .AND. !Empty(oDp:oGenRep:oRun:aRango[I,3]) .AND. cField<>oDp:oGenRep:aRango[I,1]
        cWhere:=cWhere+IF(Empty(cWhere),""," "+oDp:oGenRep:oRun:aRango[I,4]+" ")+GetWhereAnd(oDp:oGenRep:aRango[I,1],oDp:oGenRep:oRun:aRango[I,2],oDp:oGenRep:oRun:aRango[I,3])

        oDp:cWhereText:=oDp:cWhereText+IF(Empty(oDp:cWhereText),"",CRLF)+;
        oDp:oGenRep:oRun:aRango[1,4]+" ("+CTOO(oDp:oGenRep:oRun:aRango[I,2],"C")+" - "+;
                                          CTOO(oDp:oGenRep:oRun:aRango[I,3],"C")+")"


     ENDIF
        
   NEXT I

   FOR I=1 TO LEN(oDp:oGenRep:aCriterio)

     cOperator:=oDp:oGenRep:oRun:aCriterio[I,2]
     nAt      :=AT(" ",cOperator)

     IF nAt>0
       cOperator:=Left(cOperator,AT(" ",cOperator))
     ENDIF

     cOperator:=IF(Empty(cOperator)," = ",cOperator)

     IF cTable=oDp:oGenRep:aCriterio[I,4] .AND. !Empty(oDp:oGenRep:oRun:aCriterio[I,3]) .AND. cField<>oDp:oGenRep:aCriterio[I,1]
        cWhere:=cWhere+IF(Empty(cWhere),""," AND ")+oDp:oGenRep:aCriterio[I,1]+GetWhere(cOperator,oDp:oGenRep:oRun:aCriterio[I,3])

        oDp:cWhereText:=oDp:cWhereText+IF(Empty(oDp:cWhereText),"",CRLF)+;
                         oDp:oGenRep:oRun:aCriterio[I,1]+" "+cOperator+" ("+CTOO(oDp:oGenRep:oRun:aCriterio[I,3],"C")+")"
 
     ENDIF
        
   NEXT I

// ? cWhere

RETURN cWhere
// EOF