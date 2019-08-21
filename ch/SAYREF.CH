#ifndef _SAYREF_CH
#define _SAYREF_CH

/*----------------------------------------------------------------------------//
!short: SAYREF  */

#xcommand REDEFINE SAYREF [<oSayRef>] ;
             [ <label: PROMPT, VAR> <cText> ] ;
             [ HREF [ <lMailTo: MAILTO> ] <cHRef> ];
             [ ID <nId> ] ;
             [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
             [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
             [ <update: UPDATE > ] ;
             [ FONT <oFont> ] ;
       => ;
          [ <oSayRef> := ] TSayRef():ReDefine( <nId>, <{cText}>, <oWnd>, ;
              <cHRef>, [<.lMailTo.>], <nClrText>, <nClrBack>, <.update.>, <oFont> )

#xcommand @ <nRow>, <nCol> SAYREF [ <oSayRef> <label: PROMPT,VAR > ] <cText> ;
             [ HREF [ <lMailTo: MAILTO> ] <cHRef> ];
             [ <dlg: OF,WINDOW,DIALOG > <oWnd> ] ;
             [ FONT <oFont> ]  ;
             [ <lCenter: CENTERED, CENTER > ] ;
             [ <lRight:  RIGHT >    ] ;
             [ <lPixel: PIXEL, PIXELS > ] ;
             [ <color: COLOR,COLORS > <nClrText> [,<nClrBack> ] ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ <design: DESIGN >  ] ;
             [ <update: UPDATE >  ] ;
      => ;
          [ <oSayRef> := ] TSayRef():New( <nRow>, <nCol>, <{cText}>,;
             [<oWnd>], <cHRef>, [<.lMailTo.>], <oFont>, <.lCenter.>, <.lRight.>,;
             <.lPixel.>, <nClrText>, <nClrBack>, <nWidth>, <nHeight>,;
             <.design.>, <.update.> )
#ENDIF
