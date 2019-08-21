#include "FiveWin.ch"
#include "FileIo.ch"

FUNCTION GenXML()
   IF oApp():oDlg != NIL
      IF oApp():nEdit > 0
         RETURN NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF
   MsgRun('Generando ficheros XML. Espere un momento...', oApp():cAppName, ;
         { || DoXML() } )
   MsgInfo("Proceso terminado."+CRLF+"Los ficheros XML generados se encuentran en "+oApp():cXmlPath)
RETU NIL

FUNCTION DoXML()
   LOCAL aFields
   LOCAL cBuffer
   LOCAL cDbfFile
   LOCAL cXmlFile
   LOCAL cValue
   LOCAL cTable
   LOCAL nHandle
   LOCAL nFields
   LOCAL nField
   LOCAL nPos
   local aCTipo := {"C","N","L","M","D"}
   local aDTipo := {"Character","Numeric","Logical","Memo","Date"}
   local aFiles := {}
   local aDir   := {}
   local i

   aDir  := Directory(oApp():cDbfPath+"*.dbf")
   FOR i := 1 TO LEN( aDir )
      aadd(aFiles, aDir[i,1])
   NEXT

   FOR i := 1 TO Len(aFiles)
      cDbfFile := lower(aFiles[i])
      cXMLFile := oApp():cXmlPath+StrTran( cDbfFile, ".dbf", ".xml" )
      IF FILE( cXmlFile )
         DELETE FILE ( cXmlFile )
      ENDIF

      USE (oApp():cDbfPath+cDbfFile)

      nHandle := fCreate( cXmlFile, FC_NORMAL )

      //------------------
      // Writes XML header
      //------------------
      fWrite( nHandle, [<?xml version="1.0" encoding="ISO-8859-1" ?>] + CRLF )
      fWrite( nHandle, Space( 0 ) + '<ROOT DATABASE="'  + cDbfFile + '">' + CRLF )

      nFields := fCount()
      aFields := dbStruct()
      fWrite( nHandle, Space( 2 ) + "<Structure>"  + CRLF )
      FOR nField := 1 TO LEN(aFields)
         fWrite( nHandle, Space( 2 ) + "<Field>"  + CRLF )
         cBuffer := Space( 2 ) + "<Field_name>"+aFields[nField,1]+"</Field_name>"+CRLF
         fWrite( nHandle, cBuffer )
         cBuffer := Space( 2 ) + "<Field_type>"+aDTipo[AScan(aCTipo,aFields[nField,2])]+"</Field_type>"+CRLF
         fWrite( nHandle, cBuffer )
         IF aFields[nField,2] $ "CN"
            cBuffer := Space( 2 ) + "<Field_length>"+Str(aFields[nField,3])+"</Field_length>"+CRLF
            fWrite( nHandle, cBuffer )
            cBuffer := Space( 2 ) + "<Field_decimals>"+Str(aFields[nField,4])+"</Field_decimals>"+CRLF
            fWrite( nHandle, cBuffer )
         ENDIF
         fWrite( nHandle, Space( 2 ) + "</Field>"  + CRLF )
      NEXT
      fWrite( nHandle, Space( 2 ) + "</Structure>"  + CRLF )
      fWrite( nHandle, Space( 2 ) + "<Data>"  + CRLF )
      DO WHILE .NOT. Eof()
         cBuffer := Space( 2 ) + "<Record>"  + CRLF
         fWrite( nHandle, cBuffer )
         FOR nField := 1 TO nFields
            //-------------------
            // Beginning Record Tag
            //-------------------

            cBuffer:= Space( 4 ) + "<" + FieldName( nField ) + ">"

            DO CASE
               CASE aFields[nField, 2] == "D"
                  cValue := Dtos( FieldGet( nField ))

               CASE aFields[nField, 2] == "N"
                  cValue := Str( FieldGet( nField ))

               CASE aFields[nField, 2] == "L"
                  cValue := If( FieldGet( nField ), "True", "False" )

               OTHERWISE
                  cValue := FieldGet( nField )
            ENDCASE

            //--- Convert special characters
            cValue:= strTran(cValue,"&","&amp;")
            cValue:= strTran(cValue,"<","&lt;")
            cValue:= strTran(cValue,">","&gt;")
            cValue:= strTran(cValue,"'","&apos;")
            cValue:= strTran(cValue,["],[&quot;])

            cBuffer := cBuffer             + ;
                       Alltrim( cValue )   + ;
                       "</"                + ;
                       FieldName( nField ) + ;
                       ">"                 + ;
                       CRLF

            fWrite( nHandle, cBuffer )
         NEXT nField

         //------------------
         // Ending Record Tag
         //------------------
         fWrite( nHandle, Space( 2 ) + "</Record>"  + CRLF )
         SKIP
      ENDDO

      dbCloseAll()
      fWrite( nHandle, Space(0) + "</Data>" + CRLF )
      fWrite( nHandle, Space(0) + "</ROOT>" + CRLF )
      fClose( nHandle )
   NEXT
RETURN NIL
