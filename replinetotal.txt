// Programa   : REPLINETOTAL
// Fecha/Hora : 08/03/2017 02:34:48
// Propósito  : Dibujar Linea de Totales
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oReport,nType, nGrid,nColumns) 
     LOCAL nFor, nColumns, nJoin, nGridRow, nGHeight, nHeight
     LOCAL cChar, cLeft, cRight

     IF nType == NIL .OR. empty(nType) .OR. oReport=NIL
        RETU NIL
     ENDIF

     DEFAULT nGrid := 1 

// GRID_ABOVE

     nJoin       := iif(oReport:lJoin,oReport:nSeparator/2 ,0 )
     nGridRow    := 0
     nGHeight := 0
     cChar       := "³"
     cLeft       := "À"
     cRight      := "Ù"

     nColumns := len(oReport:aColumns)

     IF oReport:lScreen .OR. oReport:lPrinter

               nHeight := Int(oReport:oPenHorz:nWidth*10)

               DO CASE
               CASE nGrid == 0
                    nGridRow    := oReport:nRow
                    nGHeight := Int(nHeight*.5)
               CASE nGrid == 1
                    nGridRow    := oReport:nRow+Int(nHeight*.5)
                    nGHeight := Int(nHeight*.5)
               CASE nGrid == 2
                    nGridRow    := oReport:nRow
                    nGHeight := nHeight
               ENDCASE

               oReport:Grid(nGHeight, nGridRow, cChar)

               FOR nFor := nColumns TO nColumns

                    oReport:oDevice:Line(oReport:nRow+Int(nHeight*.5) ,;
                    oReport:aCols[nFor] - nJoin ,;
                    oReport:nRow+Int(nHeight*.5) ,;
                    oReport:aCols[nFor]+oReport:aColumns[nFor]:nWidth + nJoin ,;
                    oReport:oPenHorz)

               NEXT nFor

     ENDIF

RETURN
