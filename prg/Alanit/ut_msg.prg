**
* PROYECTO ...: Cuaderno de Bitácora
* COPYRIGHT ..: (c) alanit software
* URL ........: www.alanit.com
**

#include "Fivewin.ch"

/*_____________________________________________________________________________*/

FUNCTION msginfo(cText, cCaption)
   LOCAL oDlgInfo, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgInfo RESOURCE "UT_INFO" TITLE cCaption
   oDlgInfo:oFont  := oApp():oFont

   //REDEFINE PAGES oPage ID 110 OF oDlgInfo ;
   //   DIALOGS "UT_INFO_PAGE"
	//oPage:oFont := oApp():oFont

   REDEFINE SAY PROMPT cText ID 10 OF oDlgInfo
   REDEFINE BITMAP oBmp ID 111 OF oDlgInfo RESOURCE "xpinfo" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgInfo  ;
      ACTION oDlgInfo:End()

   ACTIVATE DIALOG oDlgInfo ;
      ON INIT oDlgInfo:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/
FUNCTION msgstop(cText, cCaption)
   LOCAL oDlgStop, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgStop RESOURCE "UT_INFO" TITLE cCaption
   oDlgStop:oFont  := oApp():oFont

   //REDEFINE PAGES oPage ID 110 OF oDlgStop ;
   //   DIALOGS "UT_INFO_PAGE"
	//oPage:oFont := oApp():oFont

   REDEFINE SAY PROMPT cText ID 10 OF oDlgStop
   REDEFINE BITMAP oBmp ID 111 OF oDlgStop RESOURCE "xpstop" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgStop  ;
      ACTION oDlgStop:End()

   ACTIVATE DIALOG oDlgStop ;
      ON INIT oDlgStop:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/

FUNCTION msgAlert(cText,cCaption)
   LOCAL oDlgAlert, oPage
   LOCAL oBmp

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgAlert RESOURCE "UT_INFO" TITLE cCaption
   oDlgAlert:oFont  := oApp():oFont

   //REDEFINE PAGES oPage ID 110 OF oDlgAlert ;
   //   DIALOGS "UT_INFO_PAGE"
	//oPage:oFont := oApp():oFont

   REDEFINE SAY PROMPT cText ID 10 OF oDlgAlert
   REDEFINE BITMAP oBmp ID 111 OF oDlgAlert RESOURCE "xpalert" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgAlert ;
      ACTION oDlgAlert:End()

   ACTIVATE DIALOG oDlgAlert ;
      ON INIT oDlgAlert:Center( oApp():oWndMain )

RETURN Nil

/*_____________________________________________________________________________*/

FUNCTION MsgYesNo(cText, cCaption )
   LOCAL oDlgYesNo, oPage
   LOCAL oBmp
   LOCAL lRet := .t.

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgYesNo RESOURCE "UT_YESNO" TITLE cCaption
   oDlgYesNo:oFont  := oApp():oFont

   //REDEFINE PAGES oPage ID 110 OF oDlgYesNo ;
   //   DIALOGS "UT_YESNO_PAGE"
	//oPage:oFont := oApp():oFont

   REDEFINE SAY PROMPT cText ID 10 OF oDlgYesNo
   REDEFINE BITMAP oBmp ID 111 OF oDlgYesNo RESOURCE "xpquest" TRANSPARENT

   REDEFINE BUTTON ID IDOK OF oDlgYesNo ;
      ACTION (lRet := .t., oDlgYesNo:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlgYesNo ;
      ACTION (lRet := .f., oDlgYesNo:End())

   ACTIVATE DIALOG oDlgYesNo ;
      ON INIT oDlgYesNo:Center( oApp():oWndMain )

RETURN lRet

/*_____________________________________________________________________________*/

FUNCTION c5yesnobig(cText, cCaption)
   LOCAL oDlgYesNo
   LOCAL oBmp
   LOCAL lRet := .t.

   DEFAULT cCaption := oApp():cAppName+oApp():cVersion

   DEFINE DIALOG oDlgYesNo RESOURCE "m5yesnobig" TITLE cCaption
   oDlgYesNo:nStyle := nOr( oDlgYesNo:nStyle, 4 )

   REDEFINE SAY PROMPT cText ID 10 OF oDlgYesNo
   REDEFINE BITMAP oBmp ID 111 OF oDlgYesNo RESOURCE "xpquest" TRANSPARENT

   REDEFINE BUTTON ID 400 OF oDlgYesNo ;
      ACTION (lRet := .t., oDlgYesNo:End())
   REDEFINE BUTTON ID 401 OF oDlgYesNo ;
      ACTION (lRet := .f., oDlgYesNo:End())

   ACTIVATE DIALOG oDlgYesNo ;
      ON INIT oDlgYesNo:Center( oApp():oWndMain )

RETURN lRet

