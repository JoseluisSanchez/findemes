#include "FiveWin.ch"
#include "Report.ch"
#include "tgraph.ch"
#include "splitter.ch"
#include "vmenu.ch"

STATIC oReport

function Graficos()
   local oBar, oCont
   local nSplit := 102
   local nOrder := 1
	local oAcMenu
	local i
	local aActividad := {}
	local iActividad := 0
	local bAction

   if oApp():oDlg != NIL
      if oApp():nEdit > 0
         retu NIL
         else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   if ! Db_OpenAll()
      retu NIL
   endif

	SELECT AC
	AC->(OrdSetFocus(2))
	AC->(DbGoTop())
	//Aadd(aActividad, "Todas las actividades")
	while ! AC->(Eof())
		Aadd(aActividad, AC->AcActivida)
		AC->(DbSkip())
	enddo
	AC->(DbGoTop())

   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gráficos de apuntes')
   oApp():oWndMain:oClient := oApp():oDlg

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg  ;

   DEFINE TITLE OF oCont ;
      CAPTION '' ;
      HEIGHT 25 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_GRAFICO"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 175 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar ;
      CAPTION "  gráficos" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
   CAPTION "Ingresos y gastos anuales" ;
   IMAGE "16_GRAFICO"              ;
   ACTION ( GrApuntes( 2*nSplit, oAcMenu, aActividad, iActividad ), GetGraphic(1) );
   LEFT 10

   DEFINE VMENUITEM OF oBar        ;
   CAPTION "Ingresos por tipo"     ;
   IMAGE "16_CATING"               ;
   ACTION ( GrCatIngreso( 2*nSplit, oAcMenu, aActividad, iActividad ), GetGraphic(2) );
   LEFT 10

   DEFINE VMENUITEM OF oBar        ;
   CAPTION "Gastos por tipo"       ;
   IMAGE "16_CATGAS"               ;
   ACTION ( GrCatGasto( 2*nSplit, oAcMenu, aActividad, iActividad ), GetGraphic(3) );
   LEFT 10

	MENU oAcMenu POPUP 2007
		MENUITEM "Todas las actividades" ;
			ACTION ( AP->(DbClearFilter()), GrUpdFilter( 0, oCont, oAcMenu, oBar, aActividad, nSplit, @iActividad ), GetActividad(0) );
			CHECKED
		SEPARATOR
		For i := 1 to Len(aActividad)
			bAction := GrFilter(aActividad, i, oCont, oAcMenu, oBar, nSplit, @iActividad)
			MENUITEM RTrim(aActividad[i]) BLOCK bAction
		Next
	ENDMENU

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Filtrar por actividad" ;
		IMAGE "16_ACTIVIDAD"         ;
		MENU oAcMenu					  ;
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
   INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
   CAPTION "Salir"                 ;
   IMAGE "16_salir"                ;
   ACTION oApp():oDlg:End()        ;
   LEFT 10

   //@ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
   //   OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 12 PIXEL OF oApp():oDlg ;
   //   ITEMS " Apuntes por Fecha ", " Tipo Ingreso ", " Cliente ", " Tipo Gasto ", " Proveedor ";
   //   ACTION GrCambia( oApp():oTab:nOption, 2*nSplit )

   @ 00, nSplit SPLITTER oApp():oSplit ;
      VERTICAL ;
      PREVIOUS CONTROLS oCont, oBar ;
      HINDS CONTROLS oApp():oGraph  ;
      SIZE 1, oApp():oDlg:nGridBottom PIXEL ;
      OF oApp():oDlg ;
      _3DLOOK ;
      UPDATE

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT (GrApuntes( 2*nSplit, oAcMenu, aActividad, iActividad ), ResizeWndMain(), oApp():oGraph:SetFocus()) ;
      VALID (oBar:End(), DbCloseAll(), oApp():oDlg := nil, oApp():oGraph := nil, oApp():oTab := nil, checkRes(), .t. )

return Nil
/*_____________________________________________________________________________*/

function GrFilter(aActividad, i, oCont, oAcMenu, oBar, nSplit )
return { || AP->(DbSetFilter( {|| AP->ApActivida==aActividad[i] }, Str(i) )), GrUpdFilter(@i, oCont, oAcMenu, oBar, aActividad, nSplit ) }

function GrUpdFilter(iActividad, oCont, oAcMenu, oBar, aActividad, nSplit)
	local j, nGraphic
	AP->(DbGoTop())
	RefreshCont(oCont,"AP")
	nGraphic := GetGraphic()
	GetActividad(iActividad)

 	//MsgInfo('Filtro '+AP->(DbFilter()))

	switch nGraphic
		case 1
			GrApuntes( 2*nSplit, oAcMenu, aActividad, iActividad )
			exit
		case 2
			GrCatIngreso( 2*nSplit, oAcMenu, aActividad, iActividad )
			exit
		case 3
	      GrCatGasto( 2*nSplit, oAcMenu, aActividad, iActividad )
			exit
	end

	For j:=1 to Len(oAcMenu:aItems)
		oAcMenu:aItems[j]:SetCheck(.f.)
	Next
	if iActividad==0
		oAcMenu:aItems[1]:SetCheck(.t.)
	else
		oAcMenu:aItems[iActividad+2]:SetCheck(.t.)
	endif
	oBar:Refresh()
return nil
//---------------------------------------------------------------------------//
function GetGraphic(n)
	static nGraphic := 1
	if n != NIL
		nGraphic := n
	endif
return nGraphic
//---------------------------------------------------------------------------//
function GetActividad(n)
	static nActividad := 0
	if n != NIL
		nActividad := n
	endif
return nActividad
//---------------------------------------------------------------------------//

function GrApuntes( nSplit, oAcMenu, aActividad, iActividad )
   local aIng := {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
   local aGas := {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
   local aYVals

   SELECT AP
   AP->(DbGoTop())
   while ! AP->(Eof())
		if DtoC(AP->ApFecha) != '  -  -    '
      	if AP->ApTipo == 'I'
      	   aIng[Month(AP->ApFecha)] += AP->ApImpTotal
      	else
      	   aGas[Month(AP->ApFecha)] += AP->ApImpTotal
      	endif
		endif
      AP->(DbSkip())
   enddo
	if oApp():oGraph == nil
      // oApp():oGraph:= TGraph():New(0,nSplit+2,oApp():oDlg,oApp():oDlg:nGridRight - nSplit -2,oApp():oDlg:nGridBottom)
		oApp():oGraph:= TGraph():New(0,nSplit+2,oApp():oDlg,oApp():oDlg:nRight - nSplit -2,oApp():oDlg:nBottom-oApp():nBarHeight-oApp():oWndMain:oMsgBar:nHeight)
	endif
   aYVals := {"Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"}
   oApp():oGraph:cTitle := "Suma de ingresos y gastos por meses (acumulado)"
   oApp():oGraph:cSubTit:=iif(GetActividad()==0, "Todas las actividades", aActividad[GetActividad()])
   oApp():oGraph:cTitY  := "Meses"
   oApp():oGraph:cTitX  := "Importe total"
   //oApp():oGraph:lPopUp := .T.
	oApp():oGraph:aSeries := {}
	oApp():oGraph:aData   := {}
	oApp():oGraph:aSTemp  := {}
	oApp():oGraph:aDTemp  := {}
   oApp():oGraph:AddSerie( aIng, "Ingresos",  oApp():cClrIng )
   oApp():oGraph:AddSerie( aGas, "Gastos", oApp():cClrGas )
   oApp():oGraph:SetYVals(aYVals)
   oApp():oGraph:Refresh(.t.)
   ResizeWndMain()

return nil
//---------------------------------------------------------------------------//

function GrCatIngreso( nSplit, oAcMenu, aActividad, iActividad )
   local aXValues := {}
   local aYValues := {}
   local aYColors := {}
   local aSeries  := {}
   local aData    := {}
   local i
   local nOtros   := 0

   SELECT IN
   IN->(DbGoTop())
   if IN->(EoF())
      MsgStop("No se puede hacer gráficos por tipos de ingresos sin tener ningún tipo de ingreso introducido.")
      retu nil
   endif
   while ! IN->(Eof())
      AAdd(aYValues,RTrim(IN->InCategor))
      AAdd(aYColors, IN->InColor)
      AAdd(aXValues,0.0)
      IN->(DbSkip())
   enddo
   SELECT AP
   AP->(DbGoTop())
   while ! AP->(Eof())
      if AP->ApTipo == 'I'
         if RTrim(AP->ApCatIngr)==""
            nOtros +=  AP->ApImpTotal
         else
            i := AScan(aYValues, RTrim(AP->ApCatIngr),,.t.)
            if i!=0
               aXValues[i] += AP->ApImpTotal
            endif
         endif
      endif
      AP->(DbSkip())
   enddo
   AAdd(aYValues,"_Sin asignar a categoría")
   AAdd(aYColors, IN->RGB(HB_RandomInt(255),HB_RandomInt(255),HB_RandomInt(255)))
   AAdd(aXValues,nOtros)
   // oApp():oGraph:= TGraph():New(0,nSplit+2,oApp():oDlg,oApp():oDlg:nGridRight - nSplit -2,oApp():oDlg:nGridBottom)
   oApp():oGraph:cTitle := "Suma de ingresos por categorias"
	oApp():oGraph:cSubTit:=iif(GetActividad()==0, "Todas las actividades", aActividad[GetActividad()])
   oApp():oGraph:nValues := SERIE_VALUES
   // oGraph:cSubTit:= ""
   oApp():oGraph:cTitY  := "Categorías de ingresos"
   oApp():oGraph:cTitX  := "Importe total"
   oApp():oGraph:nBarSep:= 10
	oApp():oGraph:aSeries := {}
	oApp():oGraph:aData   := {}
	oApp():oGraph:aSTemp  := {}
	oApp():oGraph:aDTemp  := {}
   for i = 1 to Len(aYValues)
      AAdd(aSeries, {aYValues[i],aYColors[i],,})
      AAdd(aData, {aXValues[i]})
   next
   oApp():oGraph:aSeries := aSeries
   oApp():oGraph:aData   := aData
   // oApp():oGraph:SetYVals(aYValues)
   oApp():oGraph:Refresh()
   ResizeWndMain()

return nil
//---------------------------------------------------------------------------//

function GrCatGasto( nSplit, oAcMenu, aActividad, iActividad )
   local aXValues := {}
   local aYValues := {}
   local aYColors := {}
   local aSeries  := {}
   local aData    := {}
   local i
   local nOtros   := 0

   SELECT GA
   GA->(DbGoTop())
   if GA->(EoF())
      MsgStop("No se puede hacer gráficos por tipos de gastos sin tener ningún tipo de gasto introducido.")
      retu nil
   endif
   while ! GA->(Eof())
      AAdd(aYValues,RTrim(GA->GaCategor))
      AAdd(aYColors, GA->GaColor)
      AAdd(aXValues,0.0)
      GA->(DbSkip())
   enddo
   SELECT AP
   AP->(DbGoTop())
   while ! AP->(Eof())
      if AP->ApTipo == 'G'
         if RTrim(AP->ApCatGast)==""
            nOtros +=  AP->ApImpTotal
         else
            i := AScan(aYValues, RTrim(AP->ApCatGast))
            if i!=0
               aXValues[i] += AP->ApImpTotal
            endif
         endif
      endif
      AP->(DbSkip())
   enddo
   AAdd(aYValues,"_Sin asignar a categoría")
   AAdd(aYColors, IN->RGB(HB_RandomInt(255),HB_RandomInt(255),HB_RandomInt(255)))
   AAdd(aXValues,nOtros)
   // oApp():oGraph:= TGraph():New(0,nSplit+2,oApp():oDlg,oApp():oDlg:nGridRight - nSplit -2,oApp():oDlg:nGridBottom)
   oApp():oGraph:cTitle := "Suma de gastos por categorias"
	oApp():oGraph:cSubTit:=iif(GetActividad()==0, "Todas las actividades", aActividad[GetActividad()])
   oApp():oGraph:nValues := SERIE_VALUES
   oApp():oGraph:cTitY  := "Categorías de gastos"
   oApp():oGraph:cTitX  := "Importe total"
   oApp():oGraph:nBarSep:= 10
	oApp():oGraph:aSeries := {}
	oApp():oGraph:aData   := {}
	oApp():oGraph:aSTemp  := {}
	oApp():oGraph:aDTemp  := {}

   for i = 1 to Len(aXValues)
      AAdd(aSeries, {aYValues[i],aYColors[i],,})
      AAdd(aData, {aXValues[i]})
   next
   oApp():oGraph:aSeries := aSeries
   oApp():oGraph:aData   := aData
   // oApp():oGraph:aYVals  := aYValues
   oApp():oGraph:Refresh()
   ResizeWndMain()

return nil
