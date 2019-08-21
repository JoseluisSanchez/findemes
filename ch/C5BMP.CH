#xcommand DEFINE C5BITMAP <oC5Bmp>                ;
           [ BITMAP <cBitmap>   ]                 ;
           [ OF <oWnd>          ]                 ;
           [ <lMask: MASKED>    ]                 ;
           [ AT <nTop>, <nLeft> ]                 ;
           [ MARGIN <nMrgAlign> ]                 ;
     => ;
   <oC5Bmp> := TC5Bitmap():New( <cBitmap>, <oWnd>, <.lMask.>,;
               <nTop>, <nLeft>, <nMrgAlign> )


#xcommand DEFINE MEMORY BITMAP <oC5Bmp>        ;
               [ OF <oWnd>                ]    ;
               [ SIZE <nWidth>,<nHeight>  ]    ;
               [ COLOR <nClrPane>         ]    ;
               [ <lMask: MASKED>          ]    ;
               [ MARGIN <nMrgAlign>       ]    ;
               => ;
  <oC5Bmp> := TC5Bitmap():MakeMem( <nWidth>, <nHeight>, <nClrPane>, <oWnd>,;
                        <.lMask.>, <nMrgAlign> )

#xcommand DRAWBEGIN <oC5Bmp> IN <hDC>  => <oC5Bmp>:BeginPaint( <hDC> )

#xcommand DRAWEND <oC5Bmp>             => <oC5Bmp>:EndPaint()

#xcommand @ <nTop>, <nLeft> DRAW <oC5Bmp> IN <hDC>    ;
       => ;
       <oC5Bmp>:Paint( <hDC>, <nTop>, <nLeft> )

#xcommand SAVESCREEN IN <oC5Bmp>            ;
            [ WITH <hDC>             ]      ;
            [ FROM <nTop>, <nLeft>   ]      ;
            => <oC5Bmp>:SaveScreen( <hDC>, <nTop>, <nLeft>  )

