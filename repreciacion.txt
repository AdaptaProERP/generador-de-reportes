// Programa   : REPRECIACION
// Fecha/Hora : 18/06/2012 10:46:33
// Propósito  : Calculo Automático de Precios
// Creado Por : Juan Navas
// Llamado por: MENU INVENTARIO
// Aplicación : Inventario  
// Tabla      : DPPRECIOS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhereInv)
  LOCAL aFormul:=ASQL("SELECT TPP_CODIGO FROM DPPRECIOTIP WHERE TPP_FORMUL "+GetWhere(" LIKE ","%PRECIO%"))
  LOCAL oBtn,oFont,oFontB,oBrw,oCol,aData,aUnd,oBrwU,nAt

  AEVAL(aFormul,{|a,n| aFormul[n]:=a[1] })

  aData:=ASQL(" SELECT TPP_CODIGO,TPP_DESCRI,0 AS ACTUAL,0 AS PORCEN,0 AS LOGICA FROM DPPRECIOTIP "+;
              IIF( Empty(aFormul) ,""," WHERE NOT "+GetWhereOr("TPP_CODIGO",aFormul))+;
              " ORDER BY TPP_CODIGO ")

  AEVAL(aData,{|a,n|aData[n,5]:=.T. })

  aUnd:=ASQL(" SELECT UND_CODIGO,UND_DESCRI, 0 AS UNO, 0 AS DOS FROM DPUNDMED "+;
              " ORDER BY UND_CODIGO ")

  AEVAL(aUnd,{|a,n|aUnd[n,3]:=.F., aUnd[n,4]:=.F.} )

  nAt:=nAt:=1 // ASCAN(aUnd,{|a,n|"UND"$a[1]})

  IF nAt>0
    aUnd[nAt,3]:=.F.
    aUnd[nAt,4]:=.T.
  ENDIF

  DEFINE FONT oFont NAME "Arial"   SIZE 0, -10 BOLD
 // DEFINE FONT oFontB NAME "Arial"   SIZE 0, -11 BOLD

  DPEDIT():New("Repreciación de "+oDp:DPINV,"FORMS\DPREPRECIA.EDT","oReprec",.T.)

  oReprec:cGruIni  :=SPACE(06)
  oReprec:cGruFin  :=SPACE(06)
  oReprec:cWhereInv:=cWhereInv
  oReprec:nCuantos :=0
  oReprec:lMsgBar  :=.F.
  oReprec:lVerTodos:=.F.

  @ 8,1 GROUP oBtn TO 4, 21.5 PROMPT GetFromVar("{oDp:xDPGRU}")

  @ .1,1 SAY "Desde:"

  @ 1,1 BMPGET oReprec:oGruIni VAR oReprec:cGruIni;
               VALID oReprec:ValGruIni();
               NAME "BITMAPS\FIND.BMP"; 
               ACTION (oDpLbx:=DpLbx("DPGRU",NIL,NIL),;
                       oDpLbx:GetValue("GRU_CODIGO",oReprec:oGruIni)); 
               SIZE 48,10

  @ .1,1 SAY "Hasta:"

  @ 1,1 BMPGET oReprec:oGruFin VAR oReprec:cGruFin;
               VALID oReprec:ValGruFin();
               WHEN !Empty(oReprec:cGruIni);
               NAME "BITMAPS\FIND.BMP"; 
               ACTION (oDpLbx:=DpLbx("DPGRU",NIL,NIL),;
                       oDpLbx:GetValue("GRU_CODIGO",oReprec:oGruFin)); 
               SIZE 48,10

  @ 0,0 SAY oReprec:oSayGruIni PROMPT MYSQLGET("DPGRU","GRU_DESCRI","GRU_CODIGO"+GetWhere("=",oReprec:cGruIni))
  @ 0,0 SAY oReprec:oSayGruFin PROMPT MYSQLGET("DPGRU","GRU_DESCRI","GRU_CODIGO"+GetWhere("=",oReprec:cGruFin))

  @ 5,5 SAY oReprec:oSayProgress PROMPT "Lectura de Productos"
  @ 5,5 SAY oReprec:oSayNum      PROMPT "Registro: 0/0"

  @ 2,2 METER oReprec:oMeter VAR oReprec:nCuantos

  //
  // Campo : TDC_RETIVA
  // Uso   : Retenciones de IVA                      
  //
  @ 10, 1.0 CHECKBOX oReprec:lVerTodos PROMPT "Visualizar Todos"

  oReprec:oBrw:=TXBrowse():New( oReprec:oDlg )
  oReprec:oBrw:SetArray( aData )

  oBrw:=oReprec:oBrw
  oBrw:oFont:=oFontB

  oBrw:lFastEdit:= .T.
  oBrw:lHScroll := .F.
  oBrw:nFreeze  := 3
  oBrw:lRecordSelector:=.F.

  oCol:=oBrw:aCols[1]
  oCol:cHeader   := "Tipo"
  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}

  oCol:=oBrw:aCols[2]
  oCol:cHeader   := "Descripción"
  oCol:nWidth       := 120+60
  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}

  oCol:=oBrw:aCols[3]
  oCol:cHeader   := "% Actual"
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:cEditPicture :="999.99"
  oCol:bStrData     :={|oBrw|oBrw:=oReprec:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,3],"999.99")}
  oCol:nHeadStrAlign:=AL_RIGHT
  oCol:nDataStrAlign:=AL_RIGHT
  oCol:nFootStrAlign:=AL_RIGHT
  oCol:nEditType    :=1
  oCol:bOnPostEdit  :={|oCol,uValue|oReprec:PUTMONTO(oCol,uValue,3)}
  oCol:cFooter      :="0.00"

  oCol:=oBrw:aCols[4]
  oCol:cHeader   := "% Aumentar"
  oCol:nWidth       := 60
  oCol:nDataStrAlign:= AL_RIGHT
  oCol:cEditPicture :="999.99"
  oCol:bStrData     :={|oBrw|oBrw:=oReprec:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,4],"999.99")}
  oCol:nHeadStrAlign:=AL_RIGHT
  oCol:nDataStrAlign:=AL_RIGHT
  oCol:nFootStrAlign:=AL_RIGHT
  oCol:nEditType    :=1
  oCol:bOnPostEdit  :={|oCol,uValue|oReprec:PUTMONTO(oCol,uValue,4)}
  oCol:cFooter      :="0.00"


//  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}

  oCol:=oBrw:aCols[5]
  oCol:cHeader      := "Ok"
  oCol:nWidth       := 25
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrw:=oReprec:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,5],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}
  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oReprec:ChangeAllDoc(oReprec,nRow,nCol,nKey,oCol,.T.)}

  oBrw:bClrStd   := {|oBrw|oBrw:=oReprec:oBrw,nAt:=oBrw:nArrayAt, { iif( oBrw:aArrayData[nAt,5], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrw:nArrayAt%2=0, 11595007 ,  14613246  ) } }

  oBrw:bClrSel     :={|oBrw|oBrw:=oReprec:oBrw, { 65535,  16733011}}

  oReprec:oBrw:CreateFromCode()

  oBrw:bClrHeader  := {|| { 0,  12632256}}

  //
  // Unidades de Medida
  //

  oReprec:oBrwU:=TXBrowse():New( oReprec:oDlg )
  oReprec:oBrwU:SetArray( aUnd )

  oBrwU:=oReprec:oBrwU
  oBrwU:oFont:=oFontB

  oBrwU:lFastEdit:= .T.
  oBrwU:lHScroll := .F.
  oBrwU:nFreeze  := 3
  oBrwU:lRecordSelector:=.F.

  oCol:=oBrwU:aCols[1]
  oCol:cHeader   := "Und"
  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}

  oCol:=oBrwU:aCols[2]
  oCol:cHeader   := "Descripción"
  oCol:nWidth       := 140+40
  oCol:bLDClickData:={||oReprec:DocSelect(oReprec)}

  oCol:=oBrwU:aCols[3]
  oCol:cHeader      := "Crear"
  oCol:nWidth       := 45
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrwU:=oReprec:oBrwU,IIF(oBrwU:aArrayData[oBrwU:nArrayAt,3],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oReprec:PutCrear(3)}
//  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oReprec:ChangeAllDoc(oReprec,nRow,nCol,nKey,oCol,.T.)}

  oCol:=oBrwU:aCols[4]
  oCol:cHeader      := "Calcular"
  oCol:nWidth       := 45
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData    := { ||oBrwU:=oReprec:oBrwU,IIF(oBrwU:aArrayData[oBrwU:nArrayAt,4],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bLDClickData:={||oReprec:PutCrear(4)}
//  oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oReprec:ChangeAllDoc(oReprec,nRow,nCol,nKey,oCol,.T.)}

  oBrwU:bClrStd   := {|oBrwU|oBrwU:=oReprec:oBrwU,nAt:=oBrwU:nArrayAt, { iif( oBrwU:aArrayData[nAt,3], CLR_BLACK,  CLR_GRAY ),;
                                                   iif( oBrwU:nArrayAt%2=0, 16773874 ,  16770790 ) } }

  oBrwU:bClrSel     :={|oBrwU|oBrwU:=oReprec:oBrwU, { 65535,  16733011}}

  oReprec:oBrwU:CreateFromCode()

  oBrwU:bClrHeader  := {|| { 0,  12632256}}
 // oBrwU:bLDClickData:={||oReprec:PrgSelect()}

  oReprec:oFocus:=oBrwU

 // oBrw:bLDClickData:={||oReprec:PrgSelect()}

  oReprec:oFocus:=oBrw

  oReprec:Activate({||oReprec:INICIO()})

RETURN

FUNCTION INICIO()
  LOCAL oCursor,oBar,oBtn
  LOCAL oDlg:=oReprec:oDlg

  DEFINE CURSOR oCursor HAND
  DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor


  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\RUN.BMP";
         ACTION oReprec:HACERPRECIOS()

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XSALIR.BMP";
         ACTION oReprec:Close()

  oReprec:oBrw:SetColor(NIL,14613246)
  oReprec:oBrw:DELCOL(3)

  oReprec:oBrw:nColSel:=3

  oReprec:oBrwU:SetColor(NIL,16773874)
  oReprec:oBrwU:DELCOL(3)
  oReprec:oBrwU:nColSel:=3
  oReprec:oBrwU:SetFont(oFont)

RETURN .T.

FUNCTION HACERPRECIOS()
  LOCAL oCursor,cSql,cWhere:="",I,U,aCodigos:={}
  LOCAL aTipDoc:={},aData:=ACLONE(oReprec:oBrw:aArrayData),oPrecio
  LOCAL cUndMed,cCodMon:=oDp:cMoneda,cCodUsu:=oDp:cUsuario
  LOCAL aUnd:=ACLONE(oReprec:oBrwU:aArrayData),nPrecios:=0,lOk:=.F.
  LOCAL AAA:="",nPrecio:=0,nPrecioInc:=0,X,cWhere:=""
  LOCAL aPrecios:={},aLista:={},cPrecio
  LOCAL aNuevos :={} // Nuevos Precios Calculados con Formulas
  LOCAL aTipPrecio:=ASQL("SELECT TPP_CODIGO,0 AS VAR FROM DPPRECIOTIP ")
  // Indica si los Precios Tinene Formula
  LOCAL lFormul:=(COUNT("DPPRECIOTIP","TPP_FORMUL "+GetWhere(" LIKE ","%PRECIO%")))> 0

  // Reset de Formulas
  oDp:aTipPrecio:=NIL

  IF !Empty(oReprec:cGruIni)
    cWhere:=GetWhereAnd("INV_GRUPO",oReprec:cGruIni,oReprec:cGruFin)
  ENDIF

  FOR I=1 TO LEN(aData)

     IF aData[I,5] .AND. aData[I,4]<>0

        lOk:=.T.

        AADD(aLista,aData[I,1])

     ENDIF

  NEXT I    

  IF !lOk
     MensajeErr("Debe Indicar los Porcentajes")
     RETURN .F.
  ENDIF

  cSql:=" SELECT INV_CODIGO,IME_UNDMED,INV_DESCRI FROM  DPINVMED "+;
        " INNER JOIN DPINV     ON IME_CODIGO=INV_CODIGO "+;
        " LEFT  JOIN DPPRECIOS ON PRE_CODIGO=INV_CODIGO "+;
        " WHERE INV_UTILIZ='V' "+IIF( Empty(cWhere) , "" , " AND "+cWhere )+;
        " AND "+GetWhereOr("PRE_LISTA",aLista)+;
        IIF(Empty(oReprec:cWhereInv), "" ," AND "+oReprec:cWhereInv)+;
        " GROUP BY INV_CODIGO,IME_UNDMED "+;
        " ORDER BY INV_CODIGO,IME_UNDMED "

  oReprec:oSayProgress:SetText("Leyendo "+GetFromVar("{oDp:DPINV}"))

  CursorWait()
  oCursor:=OpenTable(cSql,.T.)

  IF Empty(oCursor:RecCount())
     MensajeErr("No hay Productos según las Condición Solicitada")
     oCursor:End()
     RETURN .F.
  ENDIF

  // Verifica si los Precios Existen, para Agrearlos

  oCursor:Gotop()

  oReprec:oMeter:SetTotal(oCursor:RecCount())

  WHILE !oCursor:Eof()

     oReprec:oSayNum:SetText(LSTR(oCursor:Recno())+"/"+LSTR(oCursor:RecCount()))

     oReprec:oMeter:Set(oCursor:Recno())

     FOR I=1 TO LEN(aUnd)

       // No es necesario Crear
       IF aUnd[I,3+1] 

          oReprec:oSayProgress:SetText("Calculando Precios "+oCursor:INV_CODIGO+" ")

          FOR U=1 TO LEN(aData)

             IF aData[U,5] .AND. aData[U,4]<>0

                oPrecio:=OpenTable("SELECT * FROM DPPRECIOS WHERE "+;
                                   "PRE_CODIGO"+GetWhere( "=" , oCursor:INV_CODIGO)+" AND "+;
                                   "PRE_UNDMED"+GetWhere( "=" , aUnd[I,1]         )+" AND "+;
                                   "PRE_LISTA "+GetWhere( "=" , aData[U,1]        )+" AND "+;
                                   "PRE_CODMON"+GetWhere( "=" , cCodMon           ),,.T.)

                nPrecio:=oPrecio:PRE_PRECIO+PORCEN(oPrecio:PRE_PRECIO,aData[U,4])

                nPrecioInc:=PORCEN(oPrecio:PRE_PRECIO,aData[U,4])

                IF nPrecio>0 .OR. oReprec:lVerTodos

                  AADD(aPrecios,{oCursor:INV_CODIGO,oCursor:INV_DESCRI,aUnd[I,1],aData[U,1],cCodMon,oPrecio:PRE_PRECIO,aData[U,4],nPrecio,nPrecioInc,oPrecio:cWhere})

                  IF lFormul

                     /*
                     // Calcula Precio segun Formula, los Posibles Precios Calculados Vienen en un Arreglo, Precio y Lista
                     // Precio 100+10%= 110
                     */ 

                     aNuevos:=EJECUTAR("DPPRECIOPRECIO",oCursor:INV_CODIGO,aUnd[I,1],aData[U,1],cCodMon,aPrecios,.F.)

                     FOR X=1 TO LEN(aNuevos)
                        AADD(aPrecios,{oCursor:INV_CODIGO,oCursor:INV_DESCRI,aUnd[I,1],aNuevos[X,1],cCodMon,oPrecio:PRE_PRECIO,aData[U,4],aNuevos[X,2],nPrecioInc,aNuevos[X,3]})
                     NEXT

                  ENDIF

                ENDIF

                oPrecio:End()

             ENDIF

           NEXT 

       ENDIF

     NEXT I

     oCursor:DbSkip()

  ENDDO

  oReprec:oSayNum:SetText(LSTR(LEN(aPrecios))+" Procesados")

  EJECUTAR("DPPRECIOSVER",aPrecios)
//  VISUALIZAR(aPrecios)

  oCursor:End()
  
RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION DocSelect()
  LOCAL oBrw:=oReprec:oBrw
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=5
  LOCAL lSelect

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect
  oBrw:RefreshCurrent()

RETURN .T.

FUNCTION ChangeAllDoc()
RETURN .T.

FUNCTION PUTMONTO(oCol,uValue,nCol)

  oReprec:oBrw:aArrayData[oReprec:oBrw:nArrayAt,nCol]:=uValue

  IF nCol=4
    oReprec:oBrw:KeyBoard(VK_DOWN)
  ENDIF

  oReprec:oBrw:DrawLine(.T.)

RETURN .T.

FUNCTION VALGRUINI()

  IF Empty(oReprec:cGruIni)
      RETURN .T.
  ENDIF

  IF !ISMYSQLGET("DPGRU","GRU_CODIGO",oReprec:cGruIni)
     oReprec:oGruIni:KeyBoard(VK_F6)
  ENDIF

  oReprec:oSayGruIni:Refresh(.T.)

RETURN .T.


FUNCTION VALGRUFIN()

  IF Empty(oReprec:cGruFin)
     oReprec:oGruFin:VarPut(oReprec:cGruIni,.T.)
  ENDIF

  IF !ISMYSQLGET("DPGRU","GRU_CODIGO",oReprec:cGruFin) .OR.  oReprec:cGruIni>oReprec:cGruFin
     oReprec:oGruFin:KeyBoard(VK_F6)
  ENDIF

  oReprec:oSayGruFin:Refresh(.T.)

RETURN .T.

FUNCTION PutCrear(nCol)
  LOCAL uValue:=oReprec:oBrwU:aArrayData[oReprec:oBrwU:nArrayAt,nCol]

  DpFocus(oReprec:oBrwU)

  oReprec:oBrwU:aArrayData[oReprec:oBrwU:nArrayAt,nCol]:=!uValue

  oReprec:oBrwU:DrawLine(.T.)

//  IF nCol=4
//    oReprec:oBrwU:KeyBoard(VK_DOWN)
//  ENDIF
  
RETURN .T.

FUNCTION PRECIOSGRABAR()
   LOCAL I,aData:=ACLONE(oRepInv:oBrw:aArrayData),nCuantos:=0,cWhere,oPrecio

   IF !MsgNoYes("Desea Actualizar los Precios de los Productos")
      RETURN .F.
   ENDIF

   CursorWait()

   FOR I=1 TO LEN(aData)

      IF !Empty(aData[I,8])

        // cCodigo,cUndMed,cLista,cMoneda,dFecha,cHora)
        nCuantos++

        EJECUTAR("DPPRECIOSHIS",aData[I,1],aData[I,3],aData[I,4],aData[I,5]),COUNT("DPPRECIOS",aData[I,10])


        IF COUNT("DPPRECIOS",aData[I,10])>0

          SQLUPDATE("DPPRECIOS",{"PRE_PRECIO","PRE_ORIGEN","PRE_NOTIFI","PRE_FECHA","PRE_HORA","PRE_USUARI"},;
                                {aData[I,8]  ,"R"         ,.F.         ,oDp:dFecha ,TIME()    ,oDp:cUsuario},aData[I,10])

        ELSE

          oPrecio:=OpenTable("SELECT * FROM DPPRECIOS",.F.)

          oPrecio:Replace("PRE_CODIGO",aData[I,1]     )
          oPrecio:Replace("PRE_UNDMED",aData[I,3]     )
          oPrecio:Replace("PRE_LISTA" ,aData[I,4]     )
          oPrecio:Replace("PRE_PRECIO",aData[I,8]     )
          oPrecio:Replace("PRE_CODMON",aData[I,5]     )
          oPrecio:Replace("PRE_FECHA" ,oDp:dFecha     )
          oPrecio:Replace("PRE_HORA"  ,TIME()         )
          oPrecio:Replace("PRE_USUARI",oDp:cUsuario   )
          oPrecio:Replace("PRE_ORIGEN","REP"          )
          oPrecio:Replace("PRE_IP"    ,GETHOSTBYNAME())

          oPrecio:Commit()
          oPrecio:End()

        ENDIF

//? CLPCOPY(oDp:cSql)

      ENDIF

   NEXT I

   oRepInv:Close()

   MsgInfo("Proceso Concluido "+CRLF+LSTR(nCuantos)+" Precios Actualizados")

   oReprec:Close()

RETURN NIL

FUNCTION IMPRIMIR()
  LOCAL oRep

//  oPrecio:GUARDAR()

  oRep:=REPORTE("DPPRECIOHIS")
//  oRep:SetRango   (1,oPrecio:cCodigo,oPrecio:cCodigo)
//  oRep:SetCriterio(1,oPrecio:dFecha)
//  oRep:SetCriterio(2,oPrecio:cHora )

RETURN NIL

//EOF

//
