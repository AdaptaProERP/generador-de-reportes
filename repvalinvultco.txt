// Programa   : REPVALINVULTCO
// Fecha/Hora : 10/12/2009 04:08:10
// Propósito  : Calcular Valor del Inventario para Informes
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCod1,cCod2,cCodSuc,dFecha,cHora,lPromedio,oGenRep)
  LOCAL oTable

  DEFAULT cCod1    :="LG MG 220",;
          lPromedio:=.F.

  MsgMeter( {|oMeter, oText, oDlg, lEnd, oBtn|;
              oTable:=VALINVCAL(oMeter,oText,cCod1,cCod2,cCodSuc,dFecha,cHora,lPromedio,oGenRep),;
             "Calculando Valor del Inventario", "Leyendo Productos"} )

RETURN oTable


PROCE VALINVCAL(oMeter,oText,cCod1,cCod2,cCodSuc,dFecha,cHora,lPromedio,oGenRep)
  LOCAL cWhere:="",cSQL,oTable,nCosto,nExiste


  IF !Empty(cCod1)
     cCod2 :=IIF(Empty(cCod2),cCod1,cCod2)
     cWhere:=DPCONCAT(cWhere," AND ",GetWhereAnd("MOV_CODIGO",cCod1,cCod2))
  ENDIF

  IF !Empty(dFecha) .AND. !Empty(cHora)

      cWhere:=DPCONCAT(cWhere," AND " ,"  ( MOV_FECHA "+GetWhere("<",dFecha)+" "+;
                              "  OR (MOV_FECHA"+GetWhere("=",dFecha)+;
                              " AND MOV_HORA "+GetWhere("<=",cHora)+"))")

   ENDIF

   IF !Empty(dFecha) .AND. Empty(cHora)
      cWhere:=DPCONCAT(cWhere," AND ","MOV_FECHA "+GetWhere("<=",dFecha))
   ENDIF

  cSql    :=" SELECT  INV_CODIGO,INV_DESCRI,MOV_CODSUC,MOV_TIPDOC,MOV_DOCUME,MOV_CODCTA,PRO_NOMBRE,MOV_FECHA,"+;
            "         MOV_HORA,MOV_UNDMED,"+;
            "         MOV_CXUND,MOV_COSTO,MOV_CANTID,MOV_TOTAL,MOV_CODSUC,MOV_UNDMED "+;
            " FROM DPMOVINV "+;
            " LEFT JOIN DPPROVEEDOR ON MOV_CODCTA=PRO_CODIGO "+;
            " INNER JOIN DPINV ON INV_CODIGO=MOV_CODIGO "+; 
            " WHERE  MOV_CONTAB=1 AND MOV_INVACT<>0 "+;
            IF( !Empty(cWhere), " AND "+cWhere, "")+;
            " ORDER BY MOV_CODIGO,MOV_FECHA,MOV_HORA "

  oText:SetText("Leyendo Productos")

  oTable:=OpenTable(cSql,.T.)

  oMeter:SetTotal(oTable:RecCount())


  WHILE !oTable:Eof()

      oMeter:Set(oTable:RecNo())
      oText:SetText("Calculando "+oTable:INV_CODIGO)

      nCosto :=EJECUTAR("INVCOSPRO",oTable:INV_CODIGO,oTable:MOV_UNDMED,oTable:MOV_CODSUC,oTable:MOV_FECHA,oTable:MOV_HORA)
      nExiste:=oDp:nExiste

      IF !lPromedio
         nCosto  :=EJECUTAR("INVCOSULT",oTable:INV_CODIGO,oTable:MOV_UNDMED,oTable:MOV_CODSUC,oTable:MOV_FECHA,oTable:MOV_HORA)
      ENDIF

      oTable:Replace("MOV_COSTO" ,nCosto )
      oTable:Replace("MOV_CANTID",nExiste)
      oTable:Replace("MOV_TOTAL" ,nCosto*nExiste)
      oTable:DbSkip()

  ENDDO


   IF ValType(oGenRep)="O" .AND. (oGenRep:oRun:nOut=6 .OR. oGenRep:oRun:nOut=7 .OR. oGenRep:oRun:nOut=8)

      oTable:CTODBF(oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+".DBF")
      oGenRep:oRun:lFileDbf:=.T. // ya Existe

   ENDIF


RETURN oTable
// EOF
