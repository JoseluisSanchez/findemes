

#xcommand @ <nTop>, <nLeft> VMENU [ <oAch> ] ;
               [ SIZE <nWidth>, <nHeigth> ] ;
               [ <dlg:OF,DIALOG> <oDlg> ] ;
               [ ACTION <uAction,...> ] ;
               [ ON CHANGE <uChange,...> ] ;
               [ FONT <oFont> ] ;
               [ HEIGHT ITEM <nHItem> ] ;
               [ <mode: CENTER, RIGHT, MULTILINE> ] ;
               [ <under: UNDERLINE, INSET, SOLID, XBOX, SOLIDUNDERLINE, BUMP, ETCHED, RAISED> ];
               [ <lBorder: BORDER> ] ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane>[, <nClrPane2> ] ] ] ;
               [ COLORBORDE <nClrBorde> ] ;
               [ COLORSELECT  <nClrTSel> [,<nClrPSel>[,<nClrPSel2> ] ] ] ;
               [ COLOROVER <nClrTxtOver>[, <nClrPOver>[,<nClrPOver2> ] ]  ] ;
               [ MARGIN <nMargen> ] ;
               [ SPEEDS <nSpeed> ] ;
               [ <selmode: NONE, LFILLED, RFILLED, FILLED, LFOLDER, RFOLDER> ] ;
               [ ATTACH TO <oAttach> ] ;
               [ <lVGrad: VERTICALGRADIENT  > ] ;
               [ <lMGrad: MIRROW > ] ;
               [ WATERMARK <cWaterMark> ] ;
      => ;
          [ <oAch> := ] TVMenu():New( <nTop>, <nLeft>, <nWidth>, <nHeigth>, <oDlg> ,;
                           [{|this|<uAction>}]                                     ,;
                           [<nClrText>]                                            ,;
                           [<nClrPane>]                                            ,;
                           [<oFont>]                                               ,;
                           [<.lBorder.>]                                           ,;
                           [<nClrBorde>]                                           ,;
                           [<nHItem>]                                              ,;
                           [ Upper(<(mode)>) ]					   ,;
                           [ Upper(<(under)>) ]					   ,;
                           [ <nMargen> ]					   ,;
                           [ <nClrPSel> ]                                          ,;
                           [ <nSpeed> ]                                            ,;
                           [ Upper(<(selmode)>) ]                                  ,;
                           [{|Self|<uChange>}]                                     ,;
                           [ <nClrTSel> ]                                          ,;
                           [ <oAttach>]                                            ,;
                           [ <nClrTxtOver> ]                                       ,;
                           [ <nClrPOver> ]                                         ,;
                           [ <nClrPOver2> ]                                        ,;
                           [ <nClrPSel2> ]                                         ,;
                           [ <.lVGrad.> ]                                          ,;
                           [ <.lMGrad.> ]                                          ,;
                           [ <nClrPane2> ]                                         ,;
                           [ <cWaterMark>] )


#xcommand REDEFINE VMENU [ <oAch> ] ;
               [ <dlg:OF,DIALOG> <oDlg> ] ;
               [ ACTION <uAction,...> ] ;
               [ ON CHANGE <uChange,...> ] ;
               [ ID <nID> ] ;
               [ FONT <oFont> ] ;
               [ HEIGHT ITEM <nHItem> ] ;
               [ <mode: CENTER, RIGHT, MULTILINE> ] ;
               [ <under: UNDERLINE, INSET, SOLID, XBOX, SOLIDUNDERLINE> ];
               [ <lBorder: BORDER> ] ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane>[, <nClrPane2>] ] ] ;
               [ COLORBORDE <nClrBorde> ] ;
               [ COLORSELECT  <nClrTSel> [,<nClrPSel>[,<nClrPSel2> ] ] ] ;
               [ COLOROVER <nClrTxtOver>[, <nClrPOver>[,<nClrPOver2> ] ]  ] ;
               [ MARGIN <nMargen> ] ;
               [ SPEEDS <nSpeed> ] ;
               [ <selmode: NONE, LFILLED, RFILLED, FILLED, LFOLDER, RFOLDER> ] ;
               [ ATTACH TO <oAttach> ] ;
               [ <lVGrad: VERTICALGRADIENT  > ] ;
               [ <lMGrad: MIRROW > ] ;
      => ;
          [ <oAch> := ] TVMenu():Redefine( <oDlg>,<nID>                            ,;
                           [{|this|<uAction>}]                                     ,;
                           [<nClrText>]                                            ,;
                           [<nClrPane>]                                            ,;
                           [<oFont>]                                               ,;
                           [<.lBorder.>]                                           ,;
                           [<nClrBorde>]                                           ,;
                           [<nHItem>]                                              ,;
                           [ Upper(<(mode)>) ]					   ,;
                           [ Upper(<(under)>) ]					   ,;
                           [ <nMargen> ]					   ,;
                           [ <nClrPSel> ]                                          ,;
                           [ <nSpeed> ]                                            ,;
                           [ Upper(<(selmode)>) ]                                  ,;
                           [{|Self|<uChange>}]                                     ,;
                           [ <nClrTSel>]                                           ,;
                           [ <oAttach>]                                            ,;
                           [ <nClrTxtOver> ]                                       ,;
                           [ <nClrPOver> ]                                         ,;
                           [ <nClrPOver2> ]                                        ,;
                           [ <nClrPSel2> ]                                         ,;
                           [ <.lVGrad.> ]                                          ,;
                           [ <.lMGrad.> ]                                          ,;
                           [ <nClrPane2> ]  )


#xcommand DEFINE TITLE OF <oAch> ;
               [ CAPTION <cCaption> ] ;
               [ HEIGHT <nHTitle> ] ;
               [ FONT <oFont> ] ;
               [ COLOR <nClrText>[,<nClrPane> [,<nClrPane2>[,<nSteps> ] ] ] ] ;
               [ <lVGrad: VERTICALGRADIENT  > ] ;
               [ <lMGrad: MIRROW > ] ;
      	       [ IMGBTN <cBtnUp>[, <cBtnDown>]] ;
               [ IMAGE <cImage> ] ;
               [ ICON <cIcon> ] ;
               [ <mode: CENTER, RIGHT, MULTILINE> ] ;
               [ <lOpenClose:OPENCLOSE > ] ;
               [ RADIOBTN <nRadio> ] ;
               [ <lRndSquare:ROUNDSQUARE > ] ;
               [ RADIOSQUARE <nRadSqr> ] ;
               [ LEFT <nLeftTText> ] ;
               [ LEFTIMAGE <nLeftTImg> ] ;
      => ;
          <oAch>:SetTitle( [ <cCaption>       ]  ,;
                           [ <nHTitle>        ]  ,;
                           [ <oFont>          ]  ,;
                           [ <nClrText>       ]  ,;
                           [ <nClrPane>       ]  ,;
                           [ <nClrPane2>      ]  ,;
                           [ <nSteps>         ]  ,;
                           [ <.lVGrad.>       ]  ,;
                           [ <cImage>         ]  ,;
                           [ Upper(<(mode)>)  ]  ,;
                           [ <cIcon>          ]  ,;
                           [ <cBtnUp>         ]  ,;
                           [ <cBtnDown>       ]  ,;
                           [ <.lOpenClose.>   ]  ,;
                           [ <nRadio>         ]  ,;
                           [ <.lRndSquare.> ]  ,;
                           [ <.lMGrad.>  ]  ,;
                           [ <nRadSqr>        ]  ,;
                           [ <nLeftTText>     ]  ,;
                           [ <nLeftTImg>      ]  )








#xcommand DEFINE VMENUITEM [ <oItem> ] ;
               [ WIDTH <nWidth> ] ;
               [ HEIGHT <nHeigth> ] ;
               [ LEFT <nLeft> ] ;
               [ OF <oAch> ] ;
               [ ACTION <uAction,...> ] ;
               [ <color: COLOR, COLORS> <nClrText> [,<nClrPane>[,<nClrPane2>[,<nSteps>] ] ] ] ;
               [ <lVGrad: VERTICALGRADIENT > ] ;
               [ <lMGrad: MIRROW > ] ;
               [ CAPTION <cCaption> ] ;
	       [ IMAGE <image> [, <imageover> ] ] ;
	       [ <lIcon: ICON> ] ;
	       [ <lGroup: GROUP> ] ;
               [ <separator: SEPARADOR, LINE, INSET, DOTDOT > ] ;
               [ <mode: CENTER, RIGHT, MULTILINE > ] ;
               [ LEFTIMAGE <nLeftImg> ] ;
               [ <imagesite: IMAGECENTER, IMAGERIGHT > ] ;
               [ <lUnderline: UNDERLINE > ] ;
               [ MENU <oPopup> ] ;
               [ COLORSEPARADOR <nColorSep> ];
               [ COLORSELECT <nClrTxtSel>[, <nClrPSel>  ] ] ;
               [ TOOLTIP <cToolTip> ];
	       [ TOP <nTopTxt> ] ;
	       [ WHEN <bWhen,...> ] ;
      => ;
          [ <oItem> := ] TVItem():New( <oAch>              ,;
                                       <cCaption>            ,;
                                       <image>               ,;
                                       <imageover>           ,;
                                       <.lGroup.>            ,;
                                       <nClrText>            ,;
                                       <nClrPane>            ,;
                                       [Upper(<(mode)>)]     ,;
                                       [Upper(<(imagesite)>)],;
                                       <nHeigth>             ,;
                                       <nLeft>               ,;
                                       [Upper(<(separator)>)],;
                                       <nWidth>              ,;
                                       <.lUnderline.>        ,;
                                       <nLeftImg>            ,;
                                       <nClrPane2>           ,;
                                       <.lVGrad.>            ,;
                                       [{|this|<uAction>}]   ,;
                                       <oPopup>              ,;
                                       [<nClrPSel>]    ,;
                                       [<nClrTxtSel>]    ,;
                                       [ <.lMGrad.>]    ,;
                                       [ <nSteps>]           ,;
                                       [ <cToolTip> ]        ,;
                                       <nColorSep>           ,;
                                       [ <.lIcon.>]          ,;
                                       [ <nTopTxt> ]         ,;
                                       [{|Self|<bWhen>} ] )




#xcommand SET DIALOG [ <cResName> ] ;
               [ TO <oxItem> ] ;
      => ;
          <oxItem>:SetDialog( <cResName> )
