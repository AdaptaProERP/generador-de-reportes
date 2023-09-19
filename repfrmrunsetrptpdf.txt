// Programa   : REPFRMRUNSETRPTPDF
// Fecha/Hora : 23/06/2016 18:21:30
// Propósito  : Obtener solo los Formatos Crystal para PDF
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oFrm)
   LOCAL oRep,aFilesRpt:={},aNamesRpt:={},cNameRpt,bChange:=NIL

   DEFAULT oFrm:=oFrmRun

   IF !ValType(oFrm)="O"
      // Requiere Abrir Factura, Ejecutar Imprimir
      RETURN .F.
   ENDIF

   oRep:=oFrm:oRun:oGenRep

   IF !oRep:nOption=0
      RETURN .F.
   ENDIF

   cNameRpt:=oFrm:oRun:cNameRpt // Reporte Actual

   // Solo en Modo de Efecución debera Remover los Reportes NO CREXPORT

   ADEPURA(oRep:aFilesRpt,{|a,n| !a[4]})
   AEVAL(oRep:aFilesRpt,{|a|AADD(aFilesRpt,a[1]),;
                            AADD(aNamesRpt,a[2])})

   IF Empty(aNamesRpt)
      MsgMemo("Reporte no Tiene Formatos para CREXPORT")
      RETURN .F.
   ENDIF

   oFrmRun:aFilesRpt:=ACLONE(aFilesRpt) // Asume Lista de Archivos RPT para CREXPORT

   // ComboBox Asume lista de Nombres de Formatos por Crystal

   bChange:=oFrm:oCrystal:bChange
   oFrm:oCrystal:SetItems(ACLONE(aNamesRpt))

   COMBOINI(oFrmRun:oCrystal)
   oFrm:oCrystal:bChange:=bChange
   oFrmRun:oCrystal:Refresh(.T.)
   EVAL(oFrmRun:oCrystal:bChange)

   oFrmRun:oWnd:SetText(ALLTRIM(oFrmRun:oWnd:cTitle)+" [ Salida PDF ]")

RETURN
