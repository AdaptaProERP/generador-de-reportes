// Programa   : REPFIELDLENUPDATE
// Fecha/Hora : 22/03/2017 16:33:31
// Propósito  : Actualizar longintude de los Campos en los Reportes (Rango y Criterio)
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTable,cField)
   LOCAL cWhere,oTable,oRep,I,cCodigo
   LOCAL aCodigos:={},oTable

   LOCAL aSize,nAlto,nDataLines,aCols,lMsg:=.F.

   DEFAULT cTable:="DPDOCPRO",;
           cField:="DOC_NUMERO"

   cTable:=ALLTRIM(cTable),;
   cField:=ALLTRIM(cField)

   aCodigos:=ASQL("SELECT REP_CODIGO,REP_DESCRI FROM DPREPORTES WHERE REP_PARAM "+GetWhere(" LIKE ","%FIELD="+cField+"%")+" AND "+;
                                                          "REP_PARAM "+GetWhere(" LIKE ","%TABLE="+cTable+"%"))

   IF Empty(aCodigos)
      MsgMemo("No hay Reportes Vinculados con Tabla "+cTable+" Campo "+cField+CRLF+oDp:cSql)
      RETURN .F.
   ENDIF

   nAlto:=30*MIN(LEN(aCodigos),20)
   nAlto:=MAX(80,nAlto)

   lMsg :=EJECUTAR("MSGBROWSE",aCodigos,"Reportes para Actualizar [Tabla="+cTable+" Campo="+cField+"]",aSize,nAlto,nDataLines,aCols,lMsg,NIL)


   IF !lMsg
      RETURN .F.
   ENDIF

   CursorWait()

   FOR I=1 TO LEN(aCodigos)

    cCodigo:=aCodigos[I,1]

    MsgRun("Actualizando Reporte "+cCodigo+" "+LSTR(I)+"/"+LSTR(LEN(aCodigos)))

    oRep:=TGENREP():New()

    oRep:nOption   :=0
    oRep:cCodigo   :=cCodigo
    oRep:cCodigoOld:=cCodigo

    oTable:=OpenTable("SELECT * FROM DPREPORTES WHERE REP_CODIGO"+GetWhere("=",cCodigo),.T.)
    AEVAL(oTable:aFields,{|a,n| OSEND(oRep,a[1],oTable:Fieldget(n))})
    oRep:cFileIni:="Report\"+ALLTRIM(oRep:REP_CODIGO)+".REP"

    oRep:cFieldUpdate:=cField
    oRep:cTableUpdate:=cTable

    oRep:Read()
    oRep:Write()

    SQLUPDATE("DPREPORTES",{"REP_PARAM","REP_FECHA"},;
                           {MEMOREAD(oRep:cFileIni),EJECUTAR("DPFECHASRV")},"REP_CODIGO"+GetWhere("=",cCodigo))

    oTable:End()

    oRep:aCriterio:={}
    oRep:aRango:={}
    oRep:End()

   NEXT I

   MensajeErr("Concluido Proceso de Actualizacion de "+LSTR(LEN(aCodigos))+" Reporte(s)")
   
RETURN NIL
// EIF

