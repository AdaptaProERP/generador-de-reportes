// Programa   : REPSCRTOSRE
// Fecha/Hora : 07/12/2009 05:29:27
// Propósito  : Cambiar las Extension de los Programas fuentes para los Informes
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aFiles)
  LOCAL aFiles,I

  // Programas fuentes 
  aFiles:=DIRECTORY("REPORT\*.SCR")

  AEVAL(aFiles,{|a,n,cFile| cFile:=STRTRAN(uppe(a[1]),".SCR",".SRE")  ,;
                            IF(!File(cFile) ,__COPYFILE("report\"+a[1],"report\"+cFile), NIL),;
                            ferase("report\"+a[1]) })

  // Compilados
  //aFiles:=DIRECTORY("REPORT\*.DXB")

  aFiles:=DIRECTORY("REPORT\*.RXB")

  AEVAL(aFiles,{|a,n,cFile| cFile:=STRTRAN(uppe(a[1]),".DXB",".RXB")  ,;
                            IF(!File(cFile) ,__COPYFILE("report\"+a[1],"report\"+cFile), NIL),;
                            ferase("report\"+a[1]) })

RETURN aFiles
// EOF
