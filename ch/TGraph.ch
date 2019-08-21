/*----------------------------------------------------------------------------//
!short: TGRAPH  */

#Define GRAPH_TYPE_BAR   1
#Define GRAPH_TYPE_LINE  2
#Define GRAPH_TYPE_POINT 3
#Define GRAPH_TYPE_PIE   4
#Define GRAPH_TYPE_ALL   5

#Define SERIE_VALUES     1
#Define PERIOD_VALUES    2

#xcommand @ <nRow>, <nCol> GRAPH [ <oGraph> ] ;
               [ <of: OF, WINDOW, DIALOG> <oWnd> ];
               [ SIZE <nWidth>, <nHeight> ] ;
               [ TITLE <cTitle> ] ;
               [ <pixel: PIXEL > ] ;
               [ <l3d: 3D> ] ;
               [ <lxGrid: XGRID> ] ;
               [ <lyGrid: YGRID> ] ;
               [ <lxVal: XVALUES> ] ;
               [ <lyVal: YVALUES> ] ;
               [ <lPopUp: POPUP> ] ;
               [ <lLegends: LEGENDS> ] ;
               [ TYPE <nType> ] ;
        => ;
        [ <oGraph> := ] TGraph():New( <nRow>, <nCol>, <oWnd>, <nWidth>, ;
                <nHeight>, <cTitle>, .f., <.pixel.>, <.l3d.>, <.lxGrid.>, ;
                <.lyGrid.>, <.lxVal.>, <.lyVal.>, <.lPopUp.>, <.lLegends.>, <nType> )

#xcommand REDEFINE GRAPH [ <oGraph> ] ;
               [ ID <nId> ] ;
               [ <of: OF, WINDOW, DIALOG> <oWnd> ];
               [ TITLE <cTitle> ] ;
               [ <l3d: 3D> ] ;
               [ <lxGrid: XGRID> ] ;
               [ <lyGrid: YGRID> ] ;
               [ <lxVal: XVALUES> ] ;
               [ <lyVal: YVALUES> ] ;
               [ <lPopUp: POPUP> ] ;
               [ <lLegends: LEGENDS> ] ;
               [ TYPE <nType> ] ;
	=> ;
        [ <oGraph> := ] TGraph():Redefine( <nId>, <oWnd>, <cTitle>, <.l3d.>, ;
                <.lxGrid.>, <.lyGrid.>, <.lxVal.>, <.lyVal.>, <.lPopUp.>, <.lLegends.>, <nType> )

#xcommand ADD SERIE TO <oGraph> ;
             [ <series: SERIE> <aSerie,...> ] ;
             [ LEGEND <cLegend> ] ;
	     [ COLOR <nClr> ] ;
      =>;
           <oGraph>:AddSerie( [<aSerie>], <cLegend>, <nClr> )

#xcommand SET Y LABELS OF <oGraph> ;
             TO <ayLabels,...>;
      =>;
           <oGraph>:SetYVals( <ayLabels> )

