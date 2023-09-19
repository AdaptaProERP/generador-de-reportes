// Programa   : CTOHTMLHEAD
// Fecha/Hora : 04/07/2018 22:44:56
// Propósito  : Encabezado del Browse
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aData,cTitle)
    LOCAL cLine:="",I,U,cMemo:="",lRun:=.T.,aCols:={},aCols2:={}
    LOCAL cFile :=cFilePath(( GetModuleFileName( GetInstance())))+"TEMP\"+LSTR(SECONDS())+".HTML"
    LOCAL lTitle:=.F.
    LOCAL aHead :={"Parámetro","Valor"}

IF Empty(aData)

    aData:={}
  
    DEFAULT cTitle:="TITULO"
  
    AADD(aData,{"cero","000000"})
    AADD(aData,{"UNO" ,"1"     })

ENDIF

    AEVAL(aData,{|a,n| aData[n,2]:=CTOO(a[2],"C")})

    IF Empty(aCols)
      aCols:={}
      AEVAL(aData[1],{|a,n| AADD(aCols ,{aHead[n] ,LEN(CTOO(a,"C")),ValType(a), DPBUILDPICTURE(12,2),2}) })
//      AEVAL(aData[1],{|a,n| AADD(aCols2,{"CAMPO2"+LSTR(n),LEN(CTOO(a,"C")),ValType(a), DPBUILDPICTURE(12,2),2}) })
    ENDIF

    // Convertir en Cadenas
    FOR U=1 TO LEN(aCols)

      IF aCols[U,3]="N"
        AEVAL(aData,{|a,n| aData[n,U]:=TRANSF(a[U],aCols[U,4])})
      ENDIF

      IF aCols[U,3]="D"
        AEVAL(aData,{|a,n| aData[n,U]:=CTOO(a[U],"C")})
      ENDIF

      IF aCols[U,3]="L"
        AEVAL(aData,{|a,n| aData[n,U]:=CTOO(a[U],"C")})
      ENDIF

    NEXT U

// ViewArray(aCols)
// ViewArray(aData)

/*
    cMemo:=[<html> ]+CRLF+;
           [ <head> ]+CRLF-;
           [ <title>]+cTitle+[</title>]+CRLF+;
           []
*/
    cMemo:=[]+CRLF+;
           [ <meta name="GENERATOR" content="]+oDp:cDpSys+[">]+;
           [ <meta http-equiv="Content-Type" content="text/html; charset=Windows-1252" />]

    // Estilo

    cMemo:=cMemo+CRLF+;
          [<style type="text/css">]+;
          [       thead tr {background-color: ActiveCaption; color: CaptionText;} ]+CRLF+;
          [       th, td {vertical-align: top; font-family: "Tahoma", Arial, Helvetica, sans-serif; font-size: 8pt; padding: 3px; } ]+CRLF+;
          [       table, td {border: 1px solid silver;} ]+CRLF+;
          [       table {border-collapse: collapse;} ]

    // Encabezado

    // Formato Zebra
    cLine:=""

    FOR U=1 TO LEN(aCols)

      cLine:=cLine+IIF(Empty(cLine),"",CRLF)+[        thead.col]+LSTR(U-1)+[ {width: ]+LSTR(aCols[U,2])+[px;}]+;
                     IIF(aCols[U,3]="N" .OR. aCols[U,5]=1,CRLF+[        .col]+LSTR(U-1)+[ {text-align: right;}],"")

    NEXT U


    cMemo:=cMemo+CRLF+cLine

    // Titulo de los Campos
    cMemo:=cMemo+CRLF+[</style>]+CRLF+;
           [</head>]+CRLF+;
           [  <body> ]+CRLF+;
           [   <div id="container">  ]+CRLF+;
           [   <table caption="Creado por DpXbase/CTOHTML"> ]+CRLF+;
           [    <thead> ]+CRLF+;
           []

// Titulo 1
    cMemo:=cMemo+[      <tr> ]+CRLF

    cLine:=""

    FOR U=1 TO LEN(aCols)
      cLine:=cLine+IIF(Empty(cLine),"",CRLF)+[        <th class="col]+LSTR(U-1)+[">]+aCols[U,1]+[</th>]
                                           
    NEXT U

    cMemo:=cMemo+CRLF+cLine+CRLF

    cMemo:=cMemo+[     </tr> ]+CRLF+;
                 []


// Titulo 2
/*
    cMemo:=cMemo+[      <tr> ]+CRLF

    cLine:=""

    FOR U=1 TO LEN(aCols2)
      cLine:=cLine+IIF(Empty(cLine),"",CRLF)+[        <th class="col]+LSTR(U-1)+[">]+aCols2[U,1]+[</th>]
    NEXT U

    cMemo:=cMemo+CRLF+cLine+CRLF

    cMemo:=cMemo+[     </tr> ]+CRLF+;
                 []

*/
// Fin de los Titulos

    cMemo:=cMemo+;
           [   </thead>]+CRLF+;
           [  <tbody>]+CRLF

    FOR I=1 TO LEN(aData)

        cLine:=""

        AEVAL(aCols,{|a,n| cLine:=cLine+IIF(Empty(cLine),[  <tr>]+CRLF,CRLF)+;
             [  <td class="col]+LSTR(n-1)+[">]+ALLTRIM(aData[I,n])+[</td>]})

        cLine:=cLine+CRLF+[ </tr>]

        cMemo:=cMemo+CRLF+cLine
 
    NEXT I


    cMemo:=cMemo+CRLF+;
                 [   </tbody>]+CRLF+;
                 [  </table> ]+CRLF+;
                 [ </div> ]+CRLF+;
                 []

    IF lTitle

       cMemo:=cMemo+CRLF+;
                 [ <p> ]+CRLF+;
                 [ <em>generado ]+DTOC(oDp:dFecha)+[ ]+TIME()+[ por <a href="http://www.datapronet.com/">]+oDp:cDpSys+[</a></em> ]+CRLF+;
                 [ </p> ]+CRLF+;
                 [</body> ]

       cMemo:=cMemo+CRLF+[</html>]

    ENDIF

    // Fin Html
// ? cMemo
/*
    DPWRITE(cFile,cMemo)

    IF lRun

      MsgRun("Ejecutando "+cFile,"Ejecutando"+cFile,;
            {||SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cFile)}) 
    ENDIF
*/
RETURN cMemo
// EOF

