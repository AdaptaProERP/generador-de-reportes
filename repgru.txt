// Programa   : REPGRU
// Fecha/Hora : 04/10/2004 00:14:22
// Prop¢sito  : Ejecutar Reportes Seg£n Grupos
// Creado Por : Juan Navas
// Llamado por: Men£
// Aplicaci¢n : Todas
// Tabla      : DPREPORTE

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodGru)
  LOCAL cWhere,cDescri,nCuantos,oTable

  IF EMPTY(cCodGru)
     MensajeErr("Es necesario indicar el Grupo de Reporte")
     RETURN .F.
  ENDIF

  cCodGru:=IIF(ValType(cCodGru)="N",STRZERO(cCodGru,8),cCodGru)

  cDescri:=SQLGET("DPGRUREP","GRR_DESCRI","GRR_CODIGO"+GetWhere("=",cCodGru))

  IF EMPTY(cDescri)
     MensajeErr("Grupo de Reporte: ["+cCodGru+"] no Encontrado")
     RETURN .F.
  ENDIF

  cWhere:="REP_GRUPO"+GetWhere("=",cCodGru)

  oTable  :=OpenTable("SELECT COUNT(*) AS CUANTOS FROM DPREPORTES WHERE "+cWhere,.T.)
  nCuantos:=oTable:FieldGet(1)
  oTable:End()

  IF EMPTY(nCuantos) 
     MensajeErr("Grupo de Reporte: ["+cCodGru+"] no Tiene Reportes Asociados")
     RETURN .F.
  ENDIF

  cDescri:="Informes para: "+cDescri

  DPLBX("DPREPGRURUN.LBX",cDescri,cWhere)

RETURN .T.
