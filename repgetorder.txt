// Programa   : REPGETORDER
// Fecha/Hora : 14/03/2004 18:04:27
// Prop¢sito  : Genera el C¢digo Sql para Order By
// Creado Por : Juan Navas
// Llamado por: TGENREP
// Aplicaci¢n : Generador de Informes
// Tabla      : DPREPORTES

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGenRep)
  LOCAL cSql:="",I,aLine,cLine
  LOCAL cTable,cOrder:=""
  LOCAL aOrder
  
  IF ValType(oGenRep)!="O"
      RETURN NIL
  ENDIF

  aOrder:=oGenRep:aOrderBy

  FOR I=1 TO LEN(aOrder)

     aLine :=aOrder[I]
     IF !EMPTY(aLine[4])    
        cTable:=IIF(Empty(oGenRep:aLinks),"",ALLTRIM(aLine[4])+".")
        cOrder:=cOrder+IIF(I=1,"",",")+cTable+aLine[1]
     ENDIF

  NEXT I

  IF !Empty(cOrder)
     cOrder:="ORDER BY "+cOrder
  ENDIF

  IF oGenRep:lDescend
     cOrder:=cOrder+" DESC "
  ENDIF

  oGenRep:cSqlOrderBy:=cOrder // Convierte el OrderBy

RETURN cOrder

// EOF
