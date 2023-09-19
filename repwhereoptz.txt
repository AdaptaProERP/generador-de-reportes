// Programa   : REPWHEREOPTZ
// Fecha/Hora : 24/09/2009 22:54:55
// Propósito  : Optimizar Consultas SQL
// Creado Por : Juan Navas
// Llamado por: REPBUILDWERE
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aFields,aTablas)
   LOCAL aIndex:={},I,nAt,aClave:={},aNew:={},aUltimos:={}
 
   DEFAULT aTablas:={"DPDOCCLI"}

   IF Empty(aFields)

      aFields:={}
      AADD(aFields,{"DOC_NUMERO",[DOC_NUMERO="0000001"],""})
      AADD(aFields,{"DOC_TIPDOC",[DOC_TIPDOC="FAC"]    ,""})
      AADD(aFields,{"DOC_CODSUC",[DOC_CODSUC="000001"] ,""})
         
   ENDIF

   aIndex:=ASQL("SELECT IND_CLAVE,IND_INDICE,0 AS CERO FROM DPINDEX WHERE "+GetWhereOr("IND_TABLA",aTablas))
   AEVAL(aIndex,{|a,n| aIndex[n,3]:=0})

   // Remueve los Rangos y Criterios que estan Vacios	
   ADEPURA(aFields,{|a,n| Empty(a[2]) })

//   AEVAL( aFields,{|a,n| AADD(aFields[n],"") ,;
//                         AADD(aFields[n],"") })

   IF Empty(aIndex)
      RETURN aFields
   ENDIF

   // Buscamos en cual de los Indices hay mayor Coindencia en los Campos

   FOR I=1 TO LEN(aFields)

      nAt    :=ASCAN(aIndex,{|a,n| aFields[I,1]$a[1] })

      IF nAt>0
         aIndex[nAt,3]:=aIndex[nAt,3]+1
      ENDIF

   NEXT I

// ? cTabla
// ViewArray(aIndex)

   ADEPURA(aIndex,{|a,n| Empty(a[3]) })

   IF Empty(aIndex)
      RETURN aFields
   ENDIF

   // Ordenamos de Menor hacia mayor y el Ultimo es quie tiene la Mayor Cantidad
   // de Coincidencias.
   aIndex:=ASORT(aIndex,,, { |x, y| x[3] < y[3] })

   // Busca el Ultimo y lo convierte en Arreglos 
   aClave:=_VECTOR(ATAIL(aIndex)[1],",")

   IF Empty(aClave)
      RETURN aFields
   ENDIF

   AEVAL(aFields,{|a,n| aFields[n,1]:=ALLTRIM(a[1])})

   FOR I=1 TO LEN(aClave)

      nAt:=ASCAN(aFields,{|a,n|a[1]=aClave[I]})

      IF nAt>0
        AADD(aNew,ACLONE(aFields[nAt]))
        ARREDUCE(aFields,nAt)
      ENDIF

   NEXT I

   // Agrega los campos de Manera Residual
   AEVAL(aFields,{|a,n| AADD(aNew,a)})

//   ViewArray(aNew)
//   ViewArray(aFields)

RETURN aNew
// EOF

