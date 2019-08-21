/*
*   Programmer: Kevin S. Gallagher
*  Description: function to mimic Microsoft's Tip of the day routine
*   CopyRights: Public Domain
*/

#include "fivewin.ch"

procedure TipOfDay(cIniFile, lFromInit )
   local cMessage
   local cTip := "Tip"
   local cShow
   local oDlg
   local oText
   local lNext
   local nNextTip
   local nTotals
   local oMs10Font
   local oBmp, oBtnNext, obtnEnd

   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         msgStop( i18n("No puede acceder a esta opción hasta que no cierre las ventanas abiertas sobre el mantenimiento que está manejando.") )
         RETURN // nil
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   if !file(cIniFile) .or. empty(cIniFile)
      return
   endif

   lNext := Val(GetPvProfString("Options", "ShowTip","1", cIniFile)) != 0
   IF lFromInit .AND. !lNext
      RETURN // nil
   ENDIF

   nTotals  := Val(GetPvProfString("Total Tips","Total Tips","0",cIniFile))
   nNextTip := Val(GetPvProfString("Next Tip","TipNo","0",cIniFile))
   cTip     +=  ltrim(str(nNextTip))
   cMessage := GetPvProfString("Tips", cTip, "Error", cIniFile)

   nNextTip += 1
   if nNextTip > nTotals
      nNextTip := 1
   endif

   if nTotals < nNextTip
      WritePProString("Next Tip", "TipNo", "1",cIniFile)
   else
      WritePProString("Next Tip", "TipNo", ltrim(str(nNextTip)),cIniFile)
   endif

   DEFINE DIALOG oDlg  NAME "TIP" TITLE oApp():cAppName+oApp():cVersion OF oApp():oWndMain // FONT oWndMain:oFont
   oDlg:oFont  := oApp():oFont

   REDEFINE CHECKBOX lNext  ID 104        ;
      ON CHANGE ShowMyTip(lNext,cIniFile) ;
      OF oDlg

   REDEFINE BITMAP oBmp  ID 100 OF oDlg RESOURCE 'TIP' TRANSPARENT

   REDEFINE SAY ID 101 OF oDlg

   REDEFINE BUTTON oBtnNext   ;
      ID    105               ;
      ACTION NextTip(nNextTip,cIniFile,oText)

   REDEFINE BUTTON oBtnEnd    ;
      ID    106               ;
     ACTION oDlg:End()

   REDEFINE GET oText VAR cMessage ID 103 OF oDlg COLOR CLR_BLUE, CLR_WHITE MEMO READONLY

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if !WritePProString( "Next Tip", "TipNo",ltrim(str(nNextTip)),cIniFile)
      MsgStop("Escribiendo al fichero de trucos","error Tips-111")
   endif
return

static procedure NextTip(nNextTip,cIniFile,oText)
   local nTotals
   local cMessage
   local cTip := "Tip"

   nNextTip := Val(GetPvProfString("Next Tip","TipNo","0",cIniFile))
   cTip     += ltrim(str(nNextTip))
   cMessage := GetPvProfString("Tips", cTip, "", cIniFile)

   if empty(cMessage)
      cMessage := "error al leer el truco #Tips-121"  // whatever...
   endif

   oText:cText := cMessage
   oText:Refresh()
   nNextTip += 1

   nTotals  := Val(GetPvProfString("Total Tips","Total Tips","0",cIniFile))

   if nNextTip > nTotals
      nNextTip := 1
   endif

   if nTotals < nNextTip
      WritePProString("Next Tip", "TipNo", "1",cIniFile)
   else
      WritePProString("Next Tip", "TipNo", ltrim(str(nNextTip)),cIniFile)
   endif
return

/*
*     Procedure: ShowMyTip()
*              :
*   Description: Toggles state of if to show tip dialog
*              :
*     Arguments: lNext
*              : cIniFile
*              :
*      Comments: If lNext == 1 means to show tips
*              :    lNext == 0 means do not show tips
*/
static procedure ShowMyTip(lNext,cIniFile)
   if !lNext
      WritePProString("Options", "ShowTip","0", cIniFile)
   else
      WritePProString("Options", "ShowTip","1", cIniFile)
   endif
return
