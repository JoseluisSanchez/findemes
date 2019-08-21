#xcommand @ <nRow>, <nCol> C5CALENDAR <oCalendar>    ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane>] ] ;
               [ <clrtitle: COLORTITLE> <nClrTTitle> [,<nClrPTitle>] ] ;
               [ <clrfocus: COLORFOCUS> <nClrTFoc> [,<nClrPFoc>] ] ;
               [ <dlg:OF,DIALOG> <oDlg>            ] ;
               [ <lBold:       BOLD      >     ] ;
               [ <lClrSun:     HILITE SUNDAYS> ] ;
               [ <lEuropean:   EUROPEAN  >     ] ;
               [ <lGrid:       GRID      >     ] ;
               [ <lHeader:     HEADER    >     ] ;
               [ <lNoBorder:   NOBORDER  >     ] ;
               [ ACTION      <bAction>         ] ;
               [ ALIGN       <cAlign:    TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT > ] ;
               [ ALIGNBMP    <cAlignBmp: TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT  > ] ;
               [ ALIGNPROMPT <cAlignPro: TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT, PLAIN, MULTILINE, MULTICENTER   > ] ;
               [ COLORGRID   <nClrGrid>        ] ;
               [ DATE        <dDate>           ] ;
               [ FONT        <oFont>           ] ;
               [ ON CHANGE   <uChange>         ] ;
               [ PROMPTS     <aPrompts>        ] ;
               [ SIZE <nWidth>, <nHeight>      ] ;
               [ TITLES      <aHeaders>        ] ;
      => ;
  [ <oCalendar> := ] TCalendar():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
                  <oDlg>, <dDate>, <oFont>, <nClrText>, <nClrPane>,;
                  <nClrGrid>, <nClrTFoc>, <nClrPFoc>, ;
                  [\{|dDay|<bAction>\}], !<.lNoBorder.>, <.lBold.>, <.lEuropean.>,;
                  <.lGrid.>, [ Upper(<(cAlign)>) ] ,;
                  <.lHeader.>, <aHeaders> ,;
                  <nClrPTitle>, <nClrTTitle>, <.lClrSun.>, <aPrompts>,;
                  [\{|nOption, dDate|<uChange>\}], [ Upper(<(cAlignBmp)>) ],;
                  [ Upper(<(cAlignPro)>) ] )



#xcommand REDEFINE C5CALENDAR <oCalendar>    ;
               [ ID <nId>                      ] ;
               [ <color:      COLOR, COLORS> <nClrText> [,<nClrPane>] ] ;
               [ <colortitle: COLORTITLE>    <nClrTTitle> [,<nClrPTitle>] ] ;
               [ <colorfocus: COLORFOCUS>    <nClrTFoc> [,<nClrPFoc>] ] ;
               [ <dlg:OF,DIALOG> <oDlg>        ] ;
               [ <lBold:      BOLD      >      ] ;
               [ <lClrSun:    HILITE SUNDAYS>  ] ;
               [ <lEuropean:  EUROPEAN  >      ] ;
               [ <lGrid:      GRID      >      ] ;
               [ <lHeader:    HEADER    >      ] ;
               [ <lNoBorder:  NOBORDER  >      ] ;
               [ ACTION <bAction>              ] ;
               [ ALIGN       <cAlign: TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT  > ] ;
               [ ALIGNBMP    <cAlignBmp: TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT  > ] ;
               [ ALIGNPROMPT <cAlignPro: TOP_LEFT, TOP_CENTER, TOP_RIGHT, LEFT, CENTER, RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT, PLAIN, MULTILINE, MULTICENTER   > ] ;
               [ COLORGRID   <nClrGrid>        ] ;
               [ DATE        <dDate>           ] ;
               [ FONT        <oFont>           ] ;
               [ ON CHANGE   <uChange>         ] ;
               [ PROMPTS     <aPrompts>        ] ;
               [ TITLES      <aHeaders>        ] ;
      => ;
  [ <oCalendar> := ] TCalendar():Redefine( <oDlg>, <nId>,;
                  <dDate>, <oFont>, <nClrText>, <nClrPane>,;
                  <nClrGrid>, <nClrTFoc>, <nClrPFoc>, ;
                  [\{|dDay|<bAction>\}], !<.lNoBorder.>, <.lBold.>, <.lEuropean.>,;
                  <.lGrid.>, [ Upper(<(cAlign)>) ] ,;
                  <.lHeader.>, <aHeaders> ,;
                  <nClrPTitle>, <nClrTTitle>, <.lClrSun.>, <aPrompts> ,;
                  [\{|nOption, dDate|<uChange>\}], [ Upper(<(cAlignBmp)>) ],;
                  [ Upper(<(cAlignPro)>) ] )

#command SET TO DAY <nDay>         ;
            [ OF <oCalendar>     ] ;
            [ BITMAP <cBmp>      ] ;
            [ TOOLTIP <cTooltip> ] ;
            [ MESSAGE <cMsg>     ] ;
            => ;
  <oCalendar>:Set2Day( <nDay>, <cBmp>, <cTooltip>, <cMsg> )

#command ADD TO DAY <nDay>             ;
            [ OF <oCalendar>         ] ;
            [ TOOLTIP <cTooltip>     ] ;
            [ <lNewLine: NONEWLINE > ] ;
            => ;
  <oCalendar>:Add2Day( <nDay>, <cTooltip>, !<.lNewLine.> )


#command SET TOOLTIP OFF TO <oCalendar>   ;
            => ;
    <oCalendar>:lToolTips := .f.

#command SET TOOLTIP ON TO <oCalendar>   ;
            => ;
    <oCalendar>:lToolTips := .t.

#command SET COLOR <nClrText>, <nClrPane> TO DAY <nDay >                           ;
         OF <oCalendar> ;
         => ;
        <oCalendar>:SetClr2Day( <nDay>, <nClrText>, <nClrPane> )


