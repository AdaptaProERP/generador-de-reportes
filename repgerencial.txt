// Programa   :REPGERENCIAL
// Fecha/Hora : 26/09/2013 11:32:53
// Propósito  : Sacar DBF para Reporte Gerencial
// Creado Por : Hugo Camesella
// Llamado por: DPREPROTE
// Aplicación : 
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep,cSql)
    LOCAL cFileDbf:="",cFileCdx:="",cSql:="",oTable

    cFileDbf:="CRYSTAL\Resumen-Ventas_CND.DBF"
    cFileCdx:="CRYSTAL\Resumen-Ventas_CND.CDX"

    cSql:="SELECT * FROM DPDIARIO INNER JOIN VIEW_VENCXCHISTORICO ON VEN_FECHA=DIA_FECHA "+oGenRep:cWhere

    oTable:=OpenTable(cSql,.T.)
    oTable:CTODBF(cFileDbf)
    oTable:End()


    cFileDbf:="CRYSTAL\Resumen-Compras_CND.DBF"
    cFileCdx:="CRYSTAL\Resumen-compras_CND.CDX"

    cSql:="SELECT * FROM DPDIARIO INNER JOIN VIEW_COMRESHISTORICO ON COM_FECHA=DIA_FECHA "+oGenRep:cWhere

    oTable:=OpenTable(cSql,.T.)
    oTable:CTODBF(cFileDbf)
    oTable:End()

    cFileDbf:="CRYSTAL\Resumen-Bancos_CND.DBF"
    cFileCdx:="CRYSTAL\Resumen-Bancos_CND.CDX"

    cSql:=" SELECT BCO_CTABAN,BCO_CTABAN,BAN_NOMBRE,MOB_FCHCON," +; 
          " SUM(IF(MOB_FCHCON<>0000-00-00,MOB_MONTO*TDB_SIGNO,0)) AS SALDO,     " +;
          " SUM(IF(TDB_SIGNO=1,MOB_MONTO*TDB_SIGNO,0)) AS MONTO_DEBITO,    " +;
          " SUM(IF(TDB_SIGNO=-1,MOB_MONTO*TDB_SIGNO,0)) AS MONTO_CREDITO,  " +;   
          " SUM(TDB_SIGNO*MOB_MONTO) AS DISPONIBLE    " +;
          " FROM   dpctabancomov  " +;  
          " INNER JOIN DPCTABANCO ON BCO_CTABAN=MOB_CUENTA   " +; 
          " INNER JOIN DPBANCOS  ON BAN_CODIGO=BCO_CODIGO  " +;  
          " INNER JOIN DPBANCOTIP ON TDB_CODIGO=MOB_TIPO  " +;  
          " GROUP BY BCO_CTABAN "
   

    oTable:=OpenTable(cSql,.T.)
    oTable:CTODBF(cFileDbf)
    oTable:End()

RETURN
