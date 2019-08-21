/*----------------------------------------------------------------------------//
!short: ZoomImage */

#xcommand REDEFINE ZoomImage [ <oBmp> ] ;
             [ ID <nId> ] ;
             [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
             [ <resource: NAME, RESNAME, RESOURCE> <cResName> ] ;
             [ <file: FILE, FILENAME, DISK> <cBmpFile> ] ;
             [ <lClick: ON ClICK, ON LEFT CLICK> <uLClick> ] ;
             [ <rClick: ON RIGHT CLICK> <uRClick> ] ;
             [ <scroll: SCROLL> ] ;
             [ <adjust: ADJUST> ] ;
             [ CURSOR <oCursor> ] ;
             [ MESSAGE <cMsg>   ] ;
             [ <update: UPDATE> ] ;
             [ WHEN <uWhen> ] ;
             [ VALID <uValid> ] ;
       => ;
          [ <oBmp> := ] TZoomImage():ReDefine( <nId>, <cResName>, <cBmpFile>,;
             <oWnd>, [\{ |nRow,nCol,nKeyFlags| <uLClick> \}],;
                     [\{ |nRow,nCol,nKeyFlags| <uRClick> \}],;
             <.scroll.>, <.adjust.>, <oCursor>, <cMsg>, <.update.>,;
             <{uWhen}>, <{uValid}> )
