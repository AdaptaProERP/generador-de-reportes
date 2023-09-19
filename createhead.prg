// Programa   : CREATEHEAD
// Fecha/Hora : 17/02/2014 15:59:19
// Propósito  : Crear Archivo de Cabecera Para los Informes de Crystal Report, extraido de DPWIN32.HRB
// Creado Por : Juan Navas 
// Llamado por: REPOUT
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cFile,aData,cTitulo)
   LOCAL aStruct:={},cType,nLen,nDec,I,cAlias:=ALIAS(),aSave:={},aHead:={}

   DEFAULT aData  :={},;
           cFile  :="TEMPO.DBF",;
           cTitulo:="NO TITULO"

   DEFAULT oDp:cLeyenda1:="",;
           oDp:cLeyenda2:="",;
           oDp:cLeyenda3:=""

   oDp:cSubTitulo1:=ALLTRIM(oDp:cSubTitulo1)
   oDp:cSubTitulo2:=ALLTRIM(oDp:cSubTitulo2)
   oDp:cSubTitulo3:=ALLTRIM(oDp:cSubTitulo3)

   oDp:cRif:=oDp:cRif_

   AADD(aHead,{"RIF"     ,PADR(oDp:cRif  ,12)})
   AADD(aHead,{"NIT"     ,PADR(oDp:cNit  ,12)})
  // AADD(aHead,{"NIL"     ,PADR(oDp:cMintra,12)})
   AADD(aHead,{"MAIL"    ,PADR(oDp:cMail ,140)})
   AADD(aHead,{"WEB "    ,PADR(oDp:cWeb  ,80)})
   AADD(aHead,{"DIR1"    ,PADR(oDp:cDir1 ,80)})     
   AADD(aHead,{"DIR2"    ,PADR(oDp:cDir2 ,80)})
   AADD(aHead,{"DIR3"    ,PADR(oDp:cDir3 ,80)})
   AADD(aHead,{"DIR4"    ,PADR(oDp:cDir4 ,80)})
   AADD(aHead,{"TEL1"    ,PADR(oDp:cTel1 ,12)})
   AADD(aHead,{"TEL2"    ,PADR(oDp:cTel2 ,12)})
   AADD(aHead,{"TEL3"    ,PADR(oDp:cTel3 ,12)})
   AADD(aHead,{"TEL4"    ,PADR(oDp:cTel4 ,12)})
   AADD(aHead,{"CODSUC"  ,oDp:cSucursal      })
   AADD(aHead,{"CODEMP"  ,oDp:cEmpCod        }) // JN 16/07/2013

   // Datos de la Sucursal
   AADD(aHead,{"SUC_NOMBRE"  ,PADR(oDp:cSucDESCRI,120)})
   AADD(aHead,{"SUC_RIF"     ,PADR(oDp:cSucRIF   ,12)})
   AADD(aHead,{"SUC_NIT"     ,PADR(oDp:cSucNIT   ,12)})
   AADD(aHead,{"SUC_MAIL"    ,PADR(oDp:cSucMAIL  ,80)})
   AADD(aHead,{"SUC_WEB "    ,PADR(oDp:cSucWEB   ,80)})
   AADD(aHead,{"SUC_DIR1"    ,PADR(oDp:cSucDIR1  ,80)})     
   AADD(aHead,{"SUC_DIR2"    ,PADR(oDp:cSucDIR2  ,80)})
   AADD(aHead,{"SUC_DIR3"    ,PADR(oDp:cSucDIR3  ,80)})
   AADD(aHead,{"SUC_TEL1"    ,PADR(oDp:cSucTEL1  ,12)})
   AADD(aHead,{"SUC_TEL2"    ,PADR(oDp:cSucTEL2  ,12)})
   AADD(aHead,{"SUC_TEL3"    ,PADR(oDp:cSucTEL3  ,12)}) 


   AADD(aData,{"USUARIO" ,PADR(oDp:cUsuario   ,02) })
   AADD(aData,{"USNOMBRE",PADR(oDp:cUsNombre  ,40) })
   AADD(aData,{"EMPRESA" ,PADR(oDp:cEmpresa   ,60) })
   AADD(aData,{"TITULO"  ,PADR(cTitulo        ,120) })
   AADD(aData,{"SUBTIT1" ,PADR(oDp:cSubTitulo1,250) })
   AADD(aData,{"SUBTIT2" ,PADR(oDp:cSubTitulo2,250) })
   AADD(aData,{"SUBTIT3" ,PADR(oDp:cSubTitulo3,250) })

   // Contenido de campos Memos
   AADD(aData,{"LEYENDA" ,oDp:cLeyenda1,10,"M" }) // Leyenda Generar para todos los Documentos
   AADD(aData,{"LEYENDA2",oDp:cLeyenda2,10,"M" }) // Leyenda tipo de documento
   AADD(aData,{"LEYENDA3",oDp:cLeyenda3,10,"M" }) // Leyenda de Motivos de Documentos

//   oDp:cSubTitulo1:=""
//   oDp:cSubTitulo2:=""
//   oDp:cSubTitulo3:=""
//   oDp:cLeyenda1:=""
//   oDp:cLeyenda2:=""
//   oDp:cLeyenda3:=""
//ViewArray(aData)

   AADD(aData,{"FECHASIS",oDp:dFecha   })        // Fecha del Sistema

   AEVAL(aHead,{|a,n| AADD(aData,a)})

// ViewArray(aData)
// ? oDp:cDir1,"oDp:cDir1"

   FOR I := 1 TO LEN(aData)

      nLen :=0
      nDec :=0
      cType:=ValType(aData[I,2])

      IF LEN(aData[I])>3
        cType:=aData[I,4]
      ENDIF

      IF cType="C"
         nLen:=LEN(ALLTRIM(aData[I,2]))
      ENDIF

      IF cType="D"
         nLen:=8
      ENDIF

      IF cType="L"
         nLen:=1
      ENDIF

      IF cType="N"
         nLen:=LEN(ALLTRIM(STR(aData[I,2])))
         nDec:=aData[I,2]-INT(aData[I,2])
         nDec:=IIF(nDec=0,0,LEN(ALLTRIM(STR(nDec))))
      ENDIF

      IF Len(aData[i])>2 // Longitud Programada
         nLen:=aData[i,3]
//         ? nLen,"nlen"
      ENDIF

      nLen:=MAX(1,nLen)

      IF cType!="U"

        IF cType="M"
           nLen:=10
        ENDIF

        AADD(aStruct,{aData[I,1],cType,nLen,nDec})
        AADD(aSave,aData[I,2])

      ENDIF

   NEXT

//ViewArray(aSave)

   FERASE(cFile)

   IF File(cFile)
      MensajeErr("Archivo: "+cFile+" Posiblemente Abierto")
      RETURN .F.
   ENDIF

   DBCREATE(cFile,aStruct,"DBFCDX")

   USE (cFile) NEW EXCLU VIA "DBFCDX"
   APPEND BLANK

   // AEVAL(aSave,{|a,i|a:=IIF( ValType(a)="C",ANSITOOEM(a),a),FieldPut(i,a)})
   AEVAL(aSave,{|a,i| FieldPut(i,a)})

   USE

   DPSELECT(cAlias)

//? "AQUI ES CREATEHEAD",cFile

RETURN .T.
// EOF
