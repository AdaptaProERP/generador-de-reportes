// Programa   : RETMRUREP      
// Fecha/Hora : 12/06/2005 12:29:55
// Propósito  : Emisión de Retención 1X1000
// Creado Por : Juan Navas
// Llamado por: REPORTE: RETMRU  
// Aplicación : Tesoreria
// Tabla      : DPDOCPRO 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
   LOCAL oTable
   LOCAL cSql,cWhere,cAlias:=ALIAS(),cSqlCli:="",I,cField,cSqlMov,cSqlIva,oSerial,cMemo
   LOCAL aStruct  :={},nAt,aNumDoc:={},aCodCli:={},aFiles:={} // Número de Cotizaciones
   LOCAL aDpCliente:={}
   LOCAL aDpCliZero:={}
   LOCAL cFileDbf  :="",cFileSer,cFileDes,cSerial,cWhere,cSql,cMsg:=""
 
   cFileDbf:=oDp:cPathCrp+"RETRMU"
   cFileSer:=oDp:cPathCrp+"RETRMUDOC"
   cFileDes:=oDp:cPathCrp+"INVTRANSFDES"

   AADD(aFiles,cFileDbf)
   AADD(aFiles,cFileSer)
   AADD(aFiles,cFileDes)

   FOR I=1 TO LEN(aFiles)
      FERASE(aFiles[I]+".DBF")
      IF FILE(aFiles[I]+".DBF") 
         cMsg:=cMsg+IIF(Empty(cMsg),"",CRLF)+;
               "Fichero "+aFiles[I]+".DBF está en uso"
      ENDIF
   NEXT I

   IF !Empty(cMsg)
      MensajeErr(cMsg)
      RETURN .F.
   ENDIF

   IF oGenRep=NIL .OR. !(oGenRep:oRun:nOut=8 .OR. oGenRep:oRun:nOut=9)
      RETURN .F.
   ENDIF

   /*
   // Genera los Datos del Encabezado
   */

   // oGenRep:cSql,CHKSQL(oGenRep:cSql)

   CLOSE ALL

   // oGenRep:cSql:=STRTRAN(oGenRep:cSql," WHERE ", cWhere )
   cWhere:=oGenRep:cWhere
   // cWhere:=IIF(!Empty(cWhere)," WHERE ", "" ) +cWhere

   cSql   :=oGenRep:cSql
   nAt    :=AT(" FROM ",cSql)

   cSql   :="SELECT * FROM "+SUBS(cSql,nAt,LEN(cSql))

   ? CLPCOPY(cSql)

RETURN .T.


   // Sucursal y Almacén Destino
   cSql    :="SELECT TNI_NUMERO,"+;
              SELECTFROM("DPALMACEN" ,.F.)+","+;
              SELECTFROM("DPSUCURSAL",.F.)+;
             " FROM DPSUCURSAL "+;
             " LEFT  JOIN DPINVTRANSF  ON TNI_SUCDES=SUC_CODIGO "+;
             " LEFT  JOIN DPALMACEN    ON TNI_SUCDES=ALM_CODSUC AND TNI_ALMDES=ALM_CODIGO "+;
             " INNER JOIN DPMOVINV     ON TNI_SUCORG=MOV_CODSUC AND TNI_NUMERO=MOV_DOCUME AND TNI_TIPDOC=MOV_TIPDOC "+;
             ""+cWhere

   oTable:=OpenTable(cSql,.T.)
   oTable:CTODBF(cFileDes)
   oTable:End()


   // Datos del Documento

   cSql    :=" SELECT * FROM DPINVTRANSF   "+;
             " LEFT  JOIN DPSUCURSAL   ON TNI_SUCORG=SUC_CODIGO "+;
             " LEFT  JOIN DPALMACEN    ON TNI_SUCORG=ALM_CODSUC AND TNI_ALMORG=ALM_CODIGO "+;
             " LEFT  JOIN DPCENCOS     ON TNI_CENCOS=CEN_CODIGO "+;
             " LEFT  JOIN DPMEMO       ON TNI_NUMMEM=MEM_NUMERO "+;
             " INNER JOIN DPMOVINV     ON TNI_SUCORG=MOV_CODSUC AND TNI_NUMERO=MOV_DOCUME AND "+;
             "                            TNI_ALMORG=MOV_CODALM AND MOV_TIPDOC='TRAN' AND "+;
             "                            MOV_APLORG='T'"+;
             " INNER JOIN DPINV        ON MOV_CODIGO=INV_CODIGO "+;
             " LEFT  JOIN DPGRU        ON INV_GRUPO =GRU_CODIGO "+;
             " LEFT  JOIN DPMARCAS     ON INV_CODMAR=MAR_CODIGO "+;
             " LEFT  JOIN DPUNDMED     ON MOV_UNDMED=UND_CODIGO "+;
             " LEFT  JOIN DPIVATIP     ON MOV_TIPIVA=TIP_CODIGO "+;
             " LEFT  JOIN DPTALLAS     ON INV_TALLAS=TAL_CODIGO "+;
             ""+cWhere

   oTable:=OpenTable(cSql,.T.)

   oTable:AddField("MOV_SERIAL","M",10,0)
   oTable:Replace("MOV_SERIAL",""+CRLF)
   oTable:GoTop()

   WHILE !oTable:Eof()

     cSqlMov:=" SELECT MSR_SERIAL "+;
              " FROM DPMOVSERIAL WHERE "+;
              " MSR_TIPDOC"+GetWhere("=",oTable:MOV_TIPDOC)+" AND "+;
              " MSR_CODSUC"+GetWhere("=",oTable:MOV_CODSUC)+" AND "+;
              " MSR_NUMDOC"+GetWhere("=",oTable:MOV_DOCUME)+" AND "+;
              " MSR_CODCTA"+GetWhere("=",oTable:MOV_CODCTA)

     oSerial:=OpenTable(cSqlMov,.T.)
     cMemo:=""

     WHILE !oSerial:Eof()

       // oDp:cSerialLen :=10
       // oDp:cSerialCant:=4
       // oDp:cSerialSep :=","

       FOR I=1 TO oDp:cSerialCant

          cSerial:=ALLTRIM(oSerial:MSR_SERIAL)
          
          IF (cSerial==oSerial:MSR_SERIAL)

             cMemo:=cMemo + IIF( I=1 .OR. oSerial:Eof() , "" , oDp:cSerialSep )+;
                     RIGHT(oSerial:MSR_SERIAL,oDp:cSerialLen)

          ELSE

             cMemo:=cMemo + IIF( I=1 .OR. oSerial:Eof() , "" , oDp:cSerialSep )+;
                     LEFT(oSerial:MSR_SERIAL,oDp:cSerialLen)

          ENDIF

          oSerial:DbSkip()

       NEXT 

       cMemo:=cMemo+CRLF

     ENDDO

     oSerial:End()
     oTable:REPLACE("MOV_SERIAL",cMemo)

     oTable:DbSkip()

   ENDDO

   oTable:CTODBF(cFileDbf)
   oTable:End()   


   // Movimiento de Seriales

   cSqlMov:=" SELECT "+SELECTFROM("DPMOVSERIAL",.F.)+;
            " FROM DPMOVSERIAL "+;
            " INNER JOIN DPMOVINV ON MSR_CODSUC=MOV_CODSUC AND "+;
            "                        MSR_TIPDOC=MOV_TIPDOC AND "+;
            "                        MSR_NUMDOC=MOV_DOCUME AND "+;
            "                        MSR_CODCTA=MOV_CODCTA "+;
            " INNER JOIN DPINVTRANSF ON TNI_SUCORG=MOV_CODSUC AND "+;
            "                           TNI_NUMERO=MOV_DOCUME AND "+;
            "                           TNI_ALMORG=MOV_CODALM "+;
	      cWhere

   oTable:=OpenTable(cSqlMov,.T.)
   oTable:CTODBF(cFileDbf+"SER.DBF" ,"DBFCDX")
   oTable:End()

   FERASE(cFileDbf+"SER.CDX")
   USE (cFileDbf+"SER.DBF") VIA "DBFCDX" EXCLU NEW
   INDEX ON MSR_NUMDOC+MSR_ITEM TAG "INVTRANSFSER" TO (cFileDbf+"SER.CDX")

   FERASE(cFileDbf+"DES.CDX")
   USE (cFileDbf+"DES.DBF") VIA "DBFCDX" EXCLU NEW
   INDEX ON TNI_NUMERO TAG "INVTRANSFDES" TO (cFileDbf+"DES.CDX")

   oGenRep:oRun:lFileDbf:=.T. // ya Existe

RETURN .T.
// EOF
