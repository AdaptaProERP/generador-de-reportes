// Programa   : RETRMUREP      
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
   LOCAL cFileDbf  :="",cFileDoc,cSerial,cWhere,cSql,cMsg:=""
   LOCAL aPagos    :={}
   LOCAL cDocOrg,cTipDoc,cNumDoc,cCodSuc,cCodPro,nRata:=0,nBase:=0

   cFileDbf:=oDp:cPathCrp+ALLTRIM(oGenRep:REP_CODIGO)
   cFileDoc:=oDp:cPathCrp+"RETRMUDOC"
// cFileDes:=oDp:cPathCrp+"INVTRANSFDES"

   AADD(aFiles,cFileDbf)
   AADD(aFiles,cFileDoc)
// AADD(aFiles,cFileDes)

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

   cSql   :="SELECT * "+SUBS(cSql,nAt,LEN(cSql))

   oTable:=OpenTable(cSql,.T.)
   oTable:Replace("RMU_MONTO",MYSQLGET("DPDOCPRO","DOC_NETO","DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                                                             "DOC_TIPDOC"+GetWhere("=","RMU"            )+" AND "+;
                                                             "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                                                             "DOC_NUMERO"+GetWhere("=",oTable:PAG_NUMRMU)))

   oTable:Replace("ENLETRAS",PADR(Enletras(oTable:RMU_MONTO),400))

   WHILE !oTable:Eof()
     AADD(aPagos,oTable:DOC_PAGNUM)
     oTable:DbSkip()
   ENDDO

   oTable:CTODBF(cFileDbf)
   oTable:End()

   // Documentos Pagados en el Comprobante
   cSql:=" SELECT * FROM DPDOCPRO "+;
         " INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO "+;
         " WHERE DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
         "       DOC_TIPTRA='P'    AND "+;
         "       DOC_TIPDOC<>'RMU' AND "+;
         GetWhereOr("DOC_PAGNUM",aPagos)

   oTable:=OpenTable(cSql,.T.)

   oTable:Replace("BASE"  ,0) // Base Imponible
   oTable:Replace("MTORET",0) // Monto Retención

   oTable:Gotop()

   WHILE !oTable:Eof()

       cTipDoc:=oTable:DOC_TIPDOC
       cNumDoc:=oTable:DOC_NUMERO
       cCodSuc:=oTable:DOC_CODSUC
       cCodPro:=oTable:DOC_CODIGO
       nRata  :=0
       nBase  :=0

       EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodPro,cNumDoc,.F.,NIL,NIL,NIL,"C",cDocOrg)

       IF oDp:nBase<>0
         nRata:=RATA(oTable:DOC_NETO,oDp:nNeto)
         nBase:=PORCEN(oDp:nBase,nRata)
       ENDIF

       oTable:Replace("BASE"  ,nBase)
       oTable:Replace("MTORET",PORCEN(nBase,0.1))

       oTable:DbSkip()

   ENDDO

// oTable:Browse()
   oTable:CTODBF(cFileDoc)
   oTable:End()

   FERASE(cFileDoc+".CDX")
   USE (cFileDoc) VIA "DBFCDX" EXCLU NEW
   INDEX ON DOC_PAGNUM TAG "CBTEPAGO" TO (cFileDoc+".CDX")

   oGenRep:oRun:lFileDbf:=.T. // ya Existe

RETURN .T.
// EOF
