// Programa   : REPTOARRAY
// Fecha/Hora : 08/05/2021 21:34:05
// Propósito  : Crear TXT en Arreglo para Reportes hacia Browse
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFile,cTitle)
  LOCAL cMemo,aLines:={},nAt,nHandle,cLine,nLen,cSep,I
  LOCAL oTxtFile,lIni:=.F.
  LOCAL lHead:=.F.,nContar:=0,nIni:=0,aHead:={},aData1:={},aData2:={},aTotal1:={},aTotal2:={},nPos1,nPos2
  LOCAL oFontB
  LOCAL lOrder,lMdi,bRun,aHeader,oRdd

  DEFAULT cFile:="EJEMPLO\rep5565.66.txt"

  DEFINE FONT oFontB NAME "Courier New"   SIZE 0, -14 BOLD


//  ELSE
//     cFile:=oReport:cFile
//  ENDIF

   oTxtFile := TTxtFile():New(cFile, 0)

   WHILE !oTxtFile:Eof()

     nContar++
     cLine := oTxtFile:ReadLine()

     IF ("Í"$cLine) .AND. nIni=0
        nIni:=nContar
        oTxtFile:Skip()
        LOOP
     ENDIF

     IF ("Í"$cLine) .AND. !lIni
        lIni:=.T.
     ENDIF

     IF "gina:"$cLine .AND. "Registros:"$cLine
        lIni:=.F.
        nIni:=0
        oTxtFile:Skip()
        LOOP
     ENDIF

     IF nIni>0
       AADD(aLines,cLine)
     ENDIF

     oTxtFile:Skip()

   ENDDO
   oTxtFile:Close()

   ADEPURA(aLines,{|a,n| Empty(a) .OR. "Ä"$a .OR. "Í"$a })

//    ÍÍ ÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
//    ÄÄ ÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

   cLine:=aLines[1]
   aHead:=_VECTOR(cLine,CHR(1))

   FOR I=1 TO LEN(aLines)

      cLine:=aLines[I]
      cSep :=CHR(1)+"(1)"+CHR(1)

      IF cSep$cLine
        cLine:=ALLTRIM(STRTRAN(cLine,cSep,""))
        AADD(aData1,{cLine,I,"TOTAL"})
        nPos1:=I
      ENDIF

      cSep :=CHR(1)+"(2)"+CHR(1)
      IF cSep$cLine
        cLine:=ALLTRIM(STRTRAN(cLine,cSep,""))
        AADD(aData2,{cLine,I,nPos1})
      ENDIF

      cSep :=CHR(1)+"1"+CHR(1)+"%"
      IF cSep$cLine
        cLine:=ALLTRIM(STRTRAN(cLine,cSep,""))
        AADD(aTotal1,{cLine,I,nPos1})
      ENDIF

      cSep :=CHR(1)+"2"+CHR(1)+"%"
      IF cSep$cLine
        cLine:=ALLTRIM(STRTRAN(cLine,cSep,""))
        AADD(aTotal2,{cLine,I,nPos1})
      ENDIF


//      cLine:=STRTRAN(cLine,CHR(1),"")
      aLines[I]:=STRTRAN(cLine,CHR(1),"")

   NEXT

   FOR I=1 TO LEN(aData1)

      nAt:=ASCAN(aTotal1,{|a,n| aData1[I,2]=a[3]})

      IF nAt>0
         aData1[I,3]:=aTotal1[nAt,1]
      ENDIF 

   NEXT I

// ? oFontB:ClassName()

  oRdd:=ViewArray(aLines,cTitle,lOrder,lMdi,bRun,aHeader,oFontB)
  oRdd:oBrw:SetFont(oFontB)
  oRdd:oBrw:oWnd:Maximize()

//Maximized()
// ewArray(aData1)
// ViewArray(aTotal1)
// ViewArray(aData2)
// ViewArray(aHead)
// 
// ? cLine
// ViewArray(aLines)

/*
  cMemo :=MemoRead(cFile)
  nAt   :=AT("Í",cMemo)

  cMemo :=STRTRAN(cMemo,CRLF,CHR(10))
  aLines:=_VECTOR(cMemo,CHR(10))

//? LEN(cMemo)
// ,CRLF,CHR(10))
//  aLines:=_VECTOR(cMemo,CHR(10))
ViewArray(aLines)
   
? FILE(cFile),LEFT(cMemo,100)
*/
RETURN aData
// EOF
