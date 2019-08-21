/*----------------------------------------------------------------------------//
!short: AUTOGET  */

#xcommand REDEFINE AUTOGET [ <oGet> VAR ] <uVar> ;
             [ ID <nId> ] ;
             [ <dlg: OF, WINDOW, DIALOG> <oDlg> ] ;
             [ <help:HELPID, HELP ID> <nHelpId> ] ;
             [ VALID   <ValidFunc> ]       ;
             [ <pict: PICTURE, PICT> <cPict> ] ;
             [ <color:COLOR,COLORS> <nClrFore> [,<nClrBack>] ] ;
             [ FONT <oFont> ] ;
             [ CURSOR <oCursor> ] ;
             [ MESSAGE <cMsg> ] ;
             [ <update: UPDATE> ] ;
             [ WHEN <uWhen> ] ;
             [ ON CHANGE <uChange> ] ;
             [ <readonly: READONLY, NO MODIFY> ] ;
             [ <spin: SPINNER> [ON UP <SpnUp>] [ON DOWN <SpnDn>] [MIN <Min>] [MAX <Max>] ] ;
             [ ITEMS <aItems>] ;
       => ;
          [ <oGet> := ] TAutoGet():ReDefine( <nId>, bSETGET(<uVar>), <oDlg>,;
             <nHelpId>, <cPict>, <{ValidFunc}>, <nClrFore>, <nClrBack>,;
             <oFont>, <oCursor>, <cMsg>, .T., <{uWhen}>,;
             [ \{|nKey,nFlags,Self| <uChange> \}], <.readonly.>,;
             <.spin.>, <{SpnUp}>, <{SpnDn}>, <{Min}>, <{Max}>, <aItems>)

#command @ <nRow>, <nCol> AUTOGET [ <oGet> VAR ] <uVar> ;
            [ <dlg: OF, WINDOW, DIALOG> <oWnd> ] ;
            [ <pict: PICTURE, PICT> <cPict> ] ;
            [ VALID <ValidFunc> ] ;
            [ <color:COLOR,COLORS> <nClrFore> [,<nClrBack>] ] ;
            [ SIZE <nWidth>, <nHeight> ]  ;
            [ FONT <oFont> ] ;
            [ <design: DESIGN> ] ;
            [ CURSOR <oCursor> ] ;
            [ <pixel: PIXEL> ] ;
            [ MESSAGE <cMsg> ] ;
            [ <update: UPDATE> ] ;
            [ WHEN <uWhen> ] ;
            [ <lCenter: CENTER, CENTERED> ] ;
            [ <lRight: RIGHT> ] ;
            [ ON CHANGE <uChange> ] ;
            [ <readonly: READONLY, NO MODIFY> ] ;
            [ <pass: PASSWORD> ] ;
            [ <lNoBorder: NO BORDER, NOBORDER> ] ;
            [ <help:HELPID, HELP ID> <nHelpId> ] ;
            [ ITEMS <aItems>] ;
       => ;
          [ <oGet> := ] TAutoGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
             [<oWnd>], <nWidth>, <nHeight>, <cPict>, <{ValidFunc}>,;
             <nClrFore>, <nClrBack>, <oFont>, <.design.>,;
             <oCursor>, <.pixel.>, <cMsg>, .T., <{uWhen}>,;
             <.lCenter.>, <.lRight.>,;
             [\{|nKey, nFlags, Self| <uChange>\}], <.readonly.>,;
             <.pass.>, [<.lNoBorder.>], <nHelpId>,,,,,,<aItems> )

#command @ <nRow>, <nCol> AUTOGET [ <oGet> VAR ] <uVar> ;
            [ <dlg: OF, WINDOW, DIALOG> <oWnd> ] ;
            [ <pict: PICTURE, PICT> <cPict> ] ;
            [ VALID <ValidFunc> ] ;
            [ <color:COLOR,COLORS> <nClrFore> [,<nClrBack>] ] ;
            [ SIZE <nWidth>, <nHeight> ]  ;
            [ FONT <oFont> ] ;
            [ <design: DESIGN> ] ;
            [ CURSOR <oCursor> ] ;
            [ <pixel: PIXEL> ] ;
            [ MESSAGE <cMsg> ] ;
            [ <update: UPDATE> ] ;
            [ WHEN <uWhen> ] ;
            [ <lCenter: CENTER, CENTERED> ] ;
            [ <lRight: RIGHT> ] ;
            [ ON CHANGE <uChange> ] ;
            [ <readonly: READONLY, NO MODIFY> ] ;
            [ <help:HELPID, HELP ID> <nHelpId> ] ;
            [ <spin: SPINNER> [ON UP <SpnUp>] [ON DOWN <SpnDn>] [MIN <Min>] [MAX <Max>] ] ;
            [ ITEMS <aItems>] ;
       => ;
          [ <oGet> := ] TAutoGet():New( <nRow>, <nCol>, bSETGET(<uVar>),;
             [<oWnd>], <nWidth>, <nHeight>, <cPict>, <{ValidFunc}>,;
             <nClrFore>, <nClrBack>, <oFont>, <.design.>,;
             <oCursor>, <.pixel.>, <cMsg>, .T., <{uWhen}>,;
             <.lCenter.>, <.lRight.>,;
             [\{|nKey, nFlags, Self| <uChange>\}], <.readonly.>,;
             .f., .f., <nHelpId>,;
             <.spin.>, <{SpnUp}>, <{SpnDn}>, <{Min}>, <{Max}>, <aItems> )
