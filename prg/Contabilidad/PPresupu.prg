#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"
#include "AutoGet.ch"

STATIC oReport

function Presupuestos()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "PuState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "PuOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "PuRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "PuSplit","102", oApp():cIniFile))
   local oCont
   local i
	local aActividad := {}
	local oPuMenu
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
	while ! AC->(Eof())
		Aadd(aActividad, AC->AcActivida)
		AC->(DbSkip())
	enddo
	AC->(DbGoTop())

	// Atención: el Alias de PRESUPU es PU
   SELECT PU
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de presupuestos')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "PU"

   aBrowse   := { { { || PU->PuActivida }, i18n("Actividad"), 150, AL_LEFT, NIL },;
						{ { || PU->PuFecha }, i18n("Fecha"), 150, AL_LEFT, NIL },;
                  { { || PU->PuConcepto }, i18n("Concepto"), 120, AL_LEFT, NIL },;
                  { { || Pu->PuImpNeto }, i18n("Importe neto"), 120, AL_RIGHT, "@E 999,999.99" },;
						{ { || iif(PU->PuTipo=='I',PU->PuImpNeto*PU->PuIvaRep/100,PU->PuImpNeto*PU->PuIvaSop/100) }, i18n("IVA Rep./Sop."), 120, AL_RIGHT, "@E 999,999.99" },;
                  { { || PU->PuImpTotal }, i18n("Importe total"), 120, AL_RIGHT, "@E 999,999.99" },;
                  { { || IIF(PU->PuTipo=='I',PU->PuCliente,PU->PuProveed) }, i18n("Pagador / Perceptor"), 120, AL_LEFT, NIL },;
                  { { || IIF(PU->PuTipo=='I',PU->PuCatIngr,PU->PuCatGast) }, i18n("Tipo Ingreso / Gasto"), 120, AL_LEFT, NIL },;
						{ { || PU->PuCliente }, i18n("Pagador"), 120, AL_LEFT, NIL },;
						{ { || PU->PuCatIngr }, i18n("Tipo Ingreso"), 120, AL_LEFT, NIL },;
                  { { || PU->PuProveed  }, i18n("Perceptor"), 120, AL_LEFT, NIL },;
                  { { || PU->PuCatGast  }, i18n("Tipo Gasto"), 120, AL_LEFT, NIL } }

   FOR i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
		oCol:bEditValue :=  aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
		if aBrowse[i,5] != NIL
			oCol:cEditPicture := aBrowse[i,5]
		endif
   NEXT

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource("16_INGRESO")
   oCol:AddResource("16_GASTO")
	oCol:Cargo         := { || IIF(PU->PuTipo=='I',"Ingreso","Gasto") }
   oCol:cHeader       := i18n("Tipo")
   oCol:bBmpData      := { || IIF(PU->PuTipo=='I',1,2) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| IIF(PU->PuTipo=="I",;
												PUIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oPuMenu ),;
												PUGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oPuMenu )) }
		oCol:bPopUp        := { | o | PuBrwMenu( o, oApp():oGrid, oCont, oApp():oDlg, oPuMenu, aActividad ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"PU") }
   oApp():oGrid:bKeyDown := {|nKey| PuTecla(nKey,oApp():oGrid,oCont,oApp():oDlg, oPuMenu) }
   oApp():oGrid:nRowHeight  := 21
	oApp():oGrid:bClrStd := {|| { iif( PU->PuTipo == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
	oApp():oGrid:bClrRowFocus := { || { iif( PU->PuTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }	 
	oApp():oGrid:bClrSelFocus := { || { iif( PU->PuTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }
   oApp():oGrid:RestoreState( cState )

   PU->(DbSetOrder(nOrder))
   PU->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 17 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
		CAPTION tran(PU->(OrdKeyNo()),'@E 999,999')+" / "+tran(PU->(OrdKeyCount()),'@E 999,999') ;
		HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
		IMAGE "BB_PRESUPU"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 350 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  presupuestos" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo presupuesto de ingreso"      ;
      IMAGE "16_INGRESO"           ;
      ACTION PUIEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oPuMenu, aActividad );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo presupuesto de gasto"        ;
      IMAGE "16_GASTO"             ;
      ACTION PUGEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oPuMenu, aActividad );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar presupuesto"   ;
      IMAGE "16_modif"             ;
      ACTION IIF(PU->PuTipo=="I",;
					  PUIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oPuMenu, aActividad ),;
					  PUGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oPuMenu, aActividad ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar presupuesto"    ;
      IMAGE "16_duplica"           ;
      ACTION IIF(PU->PuTipo=="I",;
					  PUIEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oPuMenu, aActividad ),;
					  PUGEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oPuMenu, aActividad ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar presupuesto" ;
      IMAGE "16_borrar"            ;
      ACTION PUBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar presupuesto"      ;
      IMAGE "16_busca"             ;
      ACTION PuBusca(oApp():oGrid,,oCont,oApp():oDlg, oPuMenu)  ;
      LEFT 10

   MENU oPuMenu POPUP 2007
		MENUITEM "Todas las actividades" ;
			ACTION ( PU->(DbClearFilter()), PuUpdFilter( 0, oCont, oPuMenu, oBar, aActividad ));
			CHECKED
		SEPARATOR
		For i := 1 to Len(aActividad)
			bAction := PuFilter(aActividad, i, oCont, oPuMenu, oBar)
			MENUITEM RTrim(aActividad[i]) BLOCK bAction
		Next
	ENDMENU

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir presupuestos"   ;
      IMAGE "16_imprimir"          ;
      MENU PuImpMenu(oApp():oGrid, oApp():oDlg, oPuMenu) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Desviación de presupuestos";
		IMAGE "16_DESVIAC"           ;
		MENU PuDesviacMenu(oApp():oGrid, oApp():oDlg, oPuMenu, aActividad) ;
		LEFT 10

   // MENUITEM "Balance anual - por trimestres "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oPuMenu,aActividad, .f.)
   // MENUITEM "Balance anual - por trimestres con saldos"  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oPuMenu,aActividad,.t.)
   // MENUITEM "Balance anual - por meses "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualMens(oGrid,oParent,oPuMenu,aActividad, .f.)
   // MENUITEM "Balance total por periodo" RESOURCE "16_FECHA" ACTION ApBalPeriodo(oGrid,oParent,oPuMenu,aActividad)

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Filtrar por actividad" ;
		IMAGE "16_ACTIVIDAD"         ;
		MENU oPuMenu					  ;
		LEFT 10

   //DEFINE VMENUITEM OF oBar        ;
	//	INSET HEIGHT 18

   //DEFINE VMENUITEM OF oBar        ;
	//	CAPTION "Crear apunte periódico" ;
	//	IMAGE "16_APERIODI"         ;
	//	ACTION ApCreaPer(oApp():oGrid, oApp():oDlg, oCont, oPuMenu) ;
	//	LEFT 10

   //DEFINE VMENUITEM OF oBar        ;
	//	CAPTION "Anotar apuntes periódicos" ;
	//	IMAGE "16_PERIODICO"         ;
	//	ACTION ApAnotaPer(oApp():oGrid, oApp():oDlg, oCont, oPuMenu) ;
	//	LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Presupuestos" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PuState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS " Actividad ", " Fecha ", " Concepto ", " Tipo Ingreso ", " Pagador ", " Tipo Gasto ", " Perceptor ";
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              PU->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"AP") )

   @ 00, nSplit SPLITTER oApp():oSplit ;
      VERTICAL ;
      PREVIOUS CONTROLS oCont, oBar ;
      HINDS CONTROLS oApp():oGrid, oApp():oTab ;
      SIZE 1, oApp():oDlg:nGridBottom + oApp():oTab:nHeight PIXEL ;
      OF oApp():oDlg ;
      _3DLOOK ;
      UPDATE

	ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() );
      VALID ( oApp():oGrid:nLen := 0 ,;
              WritePProString("Browse","PuState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","PuOrder",Ltrim(Str(PU->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","PuRecno",Ltrim(Str(PU->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","PuSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := nil, oApp():oGrid := nil, oApp():oTab := nil, .t. )

return nil
/*_____________________________________________________________________________*/
function PuBrwMenu(oCol, oGrid, oCont, oDlg, oPuMenu, aActividad)
	local oPop

	MENU oPop POPUP 2007
		MENUITEM "Nuevo presupuesto de ingreso" RESNAME "16_INGRESO" ;
			ACTION PUIEdita( oGrid, 1, oCont, oDlg, oPuMenu, aActividad )
		MENUITEM "Nuevo presupuesto de gasto"   RESNAME "16_GASTO" ;
			ACTION PUGEdita( oGrid, 1, oCont, oDlg, oPuMenu, aActividad )
		MENUITEM "Modificar presupuesto"   RESNAME "16_MODIF" ;
   	   ACTION IIF(PU->PuTipo=="I",;
					  PUIEdita( oGrid, 2, oCont, oDlg, oPuMenu, aActividad ),;
					  PUGEdita( oGrid, 2, oCont, oDlg, oPuMenu, aActividad ))
      MENUITEM "Duplicar presupuesto"   RESNAME "16_DUPLICA" ;
   	   ACTION IIF(PU->PuTipo=="I",;
					  PUIEdita( oGrid, 3, oCont, oApp():oDlg, oPuMenu, aActividad ),;
					  PUGEdita( oGrid, 3, oCont, oApp():oDlg, oPuMenu, aActividad ))
		MENUITEM "Borrar presupuesto"   RESNAME "16_BORRAR" ;
   	   ACTION PUBorra( oGrid, oCont )

		//SEPARATOR
	ENDMENU
return oPop
//_____________________________________________________________________________//

function PuFilter(aActividad, i, oCont, oPuMenu, oBar)
return { || PU->(DbSetFilter( {|| PU->PuActivida==aActividad[i] }, Str(i) )), PuUpdFilter(i, oCont, oPuMenu, oBar, aActividad) }

function PuUpdFilter(i, oCont, oPuMenu, oBar, aActividad)
	local j
	PU->(DbGoTop())
	RefreshCont(oCont,"PU")
	oApp():oGrid:Refresh(.t.)
	For j:=1 to Len(oPuMenu:aItems)
		oPuMenu:aItems[j]:SetCheck(.f.)
	Next
	if i==0
		oPuMenu:aItems[1]:SetCheck(.t.)
		oBar:cTitle := "presupuestos"
	else
		oPuMenu:aItems[i+2]:SetCheck(.t.)
		oBar:cTitle := "presupuestos ["+rtrim(aActividad[i])+"]"
	endif
	oBar:Refresh()
return nil
//---------------------------------------------------------------------------//
*/

function PUIEdita(oGrid, nMode, oCont, oParent, oPuMenu, aActividad)
   local lCont := nMode == 1
   PUIEdita1(oGrid,nMode,oCont,oParent,@lCont,oPuMenu,aActividad)
   do while lCont
      PUIEdita1(oGrid,nMode,oCont,oParent,@lCont,oPuMenu,aActividad)
   enddo
return NIL
function PuIEdita1(oGrid,nMode,oCont,oParent,lCont,oPuMenu,aActividad,dPeFecha)
   local oDlg
   local aTitle   := { i18n( "Añadir un presupuesto de ingreso" ) ,;
                     i18n( "Modificar un presupuesto ingreso") ,;
                     i18n( "Duplicar un presupuesto") 	,;
		               i18n( "Anotar presupuesto periódico") }
   local aGet[22]
	local lAcIVA	:= .t. // indica si la actividad gestiona IVA
	local lAcREquiv:= .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)

   local cPuActivida ,;
         cPuConcepto ,;
         dPuFecha    ,;
         nPuImpNeto  ,;
         cPuObserv   ,;
         cPuCliente  ,;
         cPuCatIngr  ,;
         cPuIvaRep   ,;
         cPuRecIng   ,;
         nPuGastosFi ,;
         nPuImpTotal
   local nTIVA, nTRecEq
   local nRecPtr  := PU->(RecNo())
   local nOrden   := PU->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local lFilter	:= .f.
	local i
	local lFecha

   if PU->(EOF()) .AND. nMode > 1 .AND. nMode < 4
      retu NIL
   endif
   oApp():nEdit ++

	if oPuMenu != nil
		if (! oPuMenu:aItems[1]:lChecked)
			lFilter := .t.
		endif
	endif
	/*
   if nMode == 4
      PU->(DbAppend())
      nRecAdd := PU->(RecNo())
		AP->ApConcepto	:= PE->PeConcepto
		AP->ApActivida	:= PE->PeActivida
		AP->ApCuenta 	:= PE->PeCuenta
		AP->ApImpNeto	:= PE->PeImpNeto
   	AP->ApObserv	:= PE->PeObserv
   	AP->ApCliente	:= PE->PeCliente
   	AP->ApCatIngr	:= PE->PeCatIngr
   	AP->ApIvaRep	:= PE->PeIvaRep
   	AP->ApImpTotal	:= PE->PeImpTotal
   	AP->ApGastosFi	:= PE->PeGastosFi
   	AP->ApRecIng	:= PE->PeRecIng
   endif
	*/
   if nMode == 1
      PU->(DbAppend())
      nRecAdd := PU->(RecNo())
   endif
	// cApNumero   := iif(nMode==2,AP->ApNumero,ApSiguiente(aActividad))
   dPuFecha    := iif(nMode==2,PU->PuFecha,date()) // iif(nMode==4,PE->PeFProximo,date())
   cPuConcepto := PU->PuConcepto
	cPuActivida := iif(nMode==1,oApp():cActividad,PU->PuActivida)
   nPuImpNeto  := PU->PuImpNeto
   cPuObserv   := PU->PuObserv
   cPuCliente  := PU->PuCliente
   cPuCatIngr  := PU->PuCatIngr
   cPuIvaRep   := TRAN(PU->PuIvaRep,"@E99.99")
   nPuImpTotal := PU->PuImpTotal
   nPuGastosFi := PU->PuGastosFi
   cPuRecIng  := TRAN(PU->PuRecIng,"@E99.99")
   nTIVA       := nPuImpNeto * VAL(cPuIvaRep) / 100
   nTRecEq     := nPuImpNeto * VAL(cPuRecIng) / 100

	if nMode != 1
		AC->( DbSetOrder( 2 ) )
		AC->( DbGoTop() )
		AC->(DbSeek(Upper(cPuActivida)))
		lAcIva := AC->AcIva
		lAcREquiv := AC->AcREquiv
	else
		if lFilter
			for i:=1 to Len(oPuMenu:aItems)
				if oPuMenu:aItems[i]:lChecked
					cPuActivida := oPuMenu:aItems[i]:cPrompt
				endif
			next
		endif
	endif

   if nMode == 3
      PU->(DbAppend())
      nRecAdd := PU->(RecNo())
      // cApNumero := ApSiguiente(aActividad)
   endif

	DEFINE DIALOG oDlg RESOURCE "PUIEDIT" OF oParent;
      TITLE aTitle[ nMode ]
    oDlg:SetFont(oApp():oFont)

   REDEFINE AUTOGET aGet[19] VAR cPuActivida	;
		DATASOURCE {}						;
		FILTER AcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 119 OF oDlg UPDATE            		;
		VALID AcClave( cPuActivida, aGet[19], 4, aGet, @lAcIVA, @lAcREquiv );
		COLOR oApp():cClrIng, CLR_WHITE 			;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;
		WHEN ! lFilter

   REDEFINE BUTTON aGet[20] ID 120 OF oDlg ;
		ACTION AcSeleccion( cPuActivida, aGet[19], oDlg, aGet, @lAcIVA, @lAcREquiv ) ;
		WHEN ! lFilter

   REDEFINE GET aGet[1] VAR dPuFecha   ;
      ID 101 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION SelecFecha(@dPuFecha,aGet[1])

   REDEFINE AUTOGET aGet[5] VAR cPuCliente ;
		DATASOURCE {}						;
		FILTER ClList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE                ;
      VALID ClClave( cPuCliente, aGet[5], 4, 1 );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[6] ID 106 OF oDlg ;
      ACTION ClSeleccion( cPuCliente, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[7] VAR cPuCatIngr ;
		DATASOURCE {}						;
		FILTER InList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 107 OF oDlg UPDATE            ;
      VALID InClave( cPuCatIngr, aGet[7], 4, 2 );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[8] ID 108 OF oDlg ;
      ACTION InSeleccion( cPuCatIngr, aGet[7], oDlg )

   REDEFINE GET aGet[18] VAR cPuConcepto;
      ID 118 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[9] VAR nPuImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 109 OF oDlg                   ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[9]:bValid := { || PuRecalc(nPuImpNeto, cPuIvaRep, @nTIVA, cPuRecIng, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.) }
   aGet[9]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[9] ), .T. ) }

   REDEFINE COMBOBOX aGet[10] VAR cPuIvaRep ITEMS aIVA ;
      ID 110 OF oDlg ;
      ON CHANGE PuRecalc(nPuImpNeto, cPuIvaRep, @nTIVA, cPuRecIng, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrIng, CLR_WHITE	;
		WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTIVA    ;
      ID 111 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cPuRecIng ITEMS aRecEq ;
      ID 112 OF oDlg ;
      ON CHANGE PuRecalc(nPuImpNeto, cPuIvaRep, @nTIVA, cPuRecIng, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrIng, CLR_WHITE ;
		WHEN lAcREquiv

   REDEFINE GET aGet[13] VAR nTRecEq   ;
      ID 113 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[14] VAR nPuImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 114 OF oDlg UPDATE               ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[14]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[14] ), .T. ) }

   REDEFINE BUTTON aGet[17] ID 117 OF oDlg ;
      ACTION ApRecalc(@nPuImpNeto, cPuIvaRep, @nTIVA, cPuRecIng, @nTRecEq, nPuImpTotal, aGet, oDlg, .t.) ;
		WHEN lAcIva
   aGet[17]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nPuGastosFi  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 115 OF oDlg UPDATE               ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[16] VAR cPuObserv    ;
      MULTILINE ID 116 OF oDlg UPDATE     ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON   ;
      ID    200      ;
      OF    oDlg     ;
      ACTION   ( lCont:= .t., oDlg:end( IDOK ) ) ;
      WHEN lCont

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( lCont := .f., oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( lCont := .f., oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
		lReturn := .t.
      if nMode == 2
         PU->(DbGoTo(nRecPtr))
      else
         PU->(DbGoTo(nRecAdd))
      endif
      // ___ guardo el registro _______________________________________________//
		Replace PU->PuTipo     with "I"
      Replace PU->PuFecha    with dPuFecha
      Replace PU->PuConcepto with cPuConcepto
		Replace PU->PuActivida with cPuActivida
      Replace PU->PuImpNeto  with nPuImpNeto
      Replace PU->PuObserv   with cPuObserv
      Replace PU->PuCliente  with cPuCliente
      Replace PU->PuCatIngr  with cPuCatIngr
      Replace PU->PuIvaRep   with VAL(StrTran(cPuIvaRep,",","."))
      Replace PU->PuImpTotal with nPuImpTotal
      Replace PU->PuGastosFi with nPuGastosFi
      Replace PU->PuRecIng  with VAL(StrTran(cPuRecIng,",","."))
      AP->(DbCommit())
		if nMode != 2
      	// SetIni(oApp():cIniFile, "Config", "SiguienteApunte", cApNumero )
		endif
		if nMode == 4
			// dPeFecha := dApFecha
		endif
   else
      lReturn := .f.
      if nMode != 2
         PU->(DbGoTo(nRecAdd))
         PU->(DbDelete())
         PU->(DbPack())
         PU->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT PU
   if oCont != NIL
      RefreshCont(oCont,"PU")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//
function PUGEdita(oGrid,nMode,oCont,oParent,oPuMenu,aActividad)
   local lCont := nMode == 1
   PUGEdita1(oGrid,nMode,oCont,oParent,@lCont,oPuMenu,aActividad)
   do while lCont
      PUGEdita1(oGrid,nMode,oCont,oParent,@lCont,oPuMenu,aActividad)
   enddo

return NIL
function PUGEdita1(oGrid,nMode,oCont,oParent,lCont,oPuMenu,aActividad,dPeFecha)
   local oDlg
   local aTitle   := { i18n( "Añadir un presupuesto de gasto" )   ,;
                       i18n( "Modificar un presupuesto de gasto") ,;
                       i18n( "Duplicar un presupuesto de gasto")  ,;
	                    i18n( "Anotar presupuesto de gasto periódico") }
   local aGet[22]
	local lAcIVA 	:= .t.
	local lAcREquiv:= .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)

   local cPuNumero   ,;
         dPuFecha    ,;
         cPuConcepto ,;
			cPuCuenta	,;
         nPuImpNeto  ,;
         cPuObserv   ,;
         cPuProveed  ,;
         cPuCatGast  ,;
         cPuSuFactur ,;
         cPuIvaSop   ,;
         cPuRecGas   ,;
         nPuGastosFi ,;
         nPuImpTotal	,;
			cPuActivida
   local nTIVA, nTRecEq
   local nRecPtr  := PU->(RecNo())
   local nOrden   := PU->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local lFilter	:= .f.
	local i
	local lFecha

   if PU->(EOF()) .AND. nMode > 1 .AND. nMode < 4
      retu NIL
   endif
   oApp():nEdit ++

	if oPuMenu != nil
		if (! oPuMenu:aItems[1]:lChecked)
			lFilter := .t.
		endif
	endif

   if nMode == 1
      PU->(DbAppend())
      nRecAdd := PU->(RecNo())
   endif
	/*
	if nMode == 4
      PU->(DbAppend())
      nRecAdd := PU->(RecNo())
		AP->ApConcepto	:= PE->PeConcepto
		AP->ApActivida := PE->PeActivida
		AP->ApCuenta 	:= PE->PeCuenta
		AP->ApImpNeto	:= PE->PeImpNeto
		AP->ApObserv	:= PE->PeObserv
		AP->ApProveed	:= PE->PeProveed
		AP->ApCatGast	:= PE->PeCatGast
		AP->ApIvaSop	:= PE->PeIvaSop
		AP->ApImpTotal	:= PE->PeImpTotal
		AP->ApGastosFi	:= PE->PeGastosFi
		AP->ApRecGas	:= PE->PeRecGas
	endif
	*/
	// cApNumero   := iif(nMode==2,AP->ApNumero,ApSiguiente(aActividad))
   dPuFecha    := iif(nMode==2,PU->PuFecha, date()) //iif(nMode==4,PE->PeFProximo,date()))
   cPUConcepto := PU->PuConcepto
	cPuActivida := iif(nMode==1,oApp():cActividad,PU->PuActivida)
   nPuImpNeto  := PU->PuImpNeto
   cPuObserv   := PU->PuObserv
   cPuProveed  := PU->PuProveed
   cPuCatGast  := PU->PuCatGast
   cPuIvaSop   := Tran(PU->PuIvaSop,"@E99.99")
   nPuImpTotal := PU->PuImpTotal
   nPuGastosFi := PU->PuGastosFi
   cPuRecGas   := Tran(PU->PuRecGas,"@E99.99")
   nTIVA       := nPuImpNeto * VAL(cPuIvaSop) / 100
   nTRecEq     := nPuImpNeto * VAL(cPuRecGas) / 100

	// asigno al actividad en caso de filtro
	if nMode != 1
		AC->( DbSetOrder( 2 ) )
		AC->( DbGoTop() )
		AC->(DbSeek(Upper(cPuActivida)))
		lAcIva 	 := AC->AcIva
		lAcREquiv := AC->AcREquiv
	else
		if lFilter
			for i:=1 to Len(oPuMenu:aItems)
				if oPuMenu:aItems[i]:lChecked
					cPuActivida := oPuMenu:aItems[i]:cPrompt
				endif
			next
		endif
	endif

   if nMode == 3
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
      // cApNumero := ApSiguiente(aActividad)
   endif

   DEFINE DIALOG oDlg RESOURCE "PUGEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE AUTOGET aGet[19] VAR cPuActivida	;
		DATASOURCE {}						;
		FILTER AcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 119 OF oDlg UPDATE            	;
		VALID AcClave( cPuActivida, aGet[19], 4, aGet, @lAcIVA, @lAcREquiv );
		COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;
		WHEN ! lFilter

   REDEFINE BUTTON aGet[20] ID 120 OF oDlg ;
		ACTION AcSeleccion( cPuActivida, aGet[19], oDlg, aGet, @lAcIVA, @lAcREquiv );
		WHEN ! lFilter

   REDEFINE GET aGet[1] VAR dPuFecha   ;
      ID 101 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION SelecFecha(@dPuFecha,aGet[1])

   REDEFINE AUTOGET aGet[5] VAR cPuProveed ;
		DATASOURCE {}						;
		FILTER PrList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE                ;
      VALID PrClave( cPuProveed, aGet[5], 4, 1 );
      COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;

   REDEFINE BUTTON aGet[6] ID 106 OF oDlg ;
      ACTION PrSeleccion( cPuProveed, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[7] VAR cPuCatGast ;
		DATASOURCE {}						;
		FILTER GaList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 107 OF oDlg UPDATE                ;
      VALID GaClave( cPuCatGast, aGet[7], 4, 2 );
      COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;

   REDEFINE BUTTON aGet[8] ID 108 OF oDlg ;
      ACTION GaSeleccion( cPuCatGast, aGet[7], oDlg )

   REDEFINE GET aGet[18] VAR cPuConcepto;
      ID 118 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[9] VAR nPuImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 109 OF oDlg                   ;
      COLOR oApp():cClrGas, CLR_WHITE
	aGet[9]:bValid   := { || PuRecalc(nPuImpNeto, cPuIvaSop, @nTIVA, cPuRecGas, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.) }
   aGet[9]:bKeyDown := { |nKey| IIF(nKey == VK_SPACE, ShowCalculator(aGet[9]), .T.) }

   REDEFINE COMBOBOX aGet[10] VAR cPuIvaSop ITEMS aIVA ;
      ID 110 OF oDlg ;
      ON CHANGE PuRecalc(nPuImpNeto, cPuIvaSop, @nTIVA, cPuRecGas, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrGas, CLR_WHITE	;
		WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTIVA    ;
      ID 111 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cPuRecGas ITEMS aRecEq ;
      ID 112 OF oDlg ;
      ON CHANGE PuRecalc(nPuImpNeto, cPuIvaSop, @nTIVA, cPuRecGas, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrGas, CLR_WHITE ;
		WHEN lAcREquiv

   REDEFINE GET aGet[13] VAR nTRecEq   ;
      ID 113 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[14] VAR nPuImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 114 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE
   aGet[14]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[14] ), .T. ) }

   REDEFINE BUTTON aGet[17] ID 117 OF oDlg ;
      ACTION PuRecalc(@nPuImpNeto, cPuIvaSop, @nTIVA, cPuRecGas, @nTRecEq, @nPuImpTotal, aGet, oDlg, .f.);
		WHEN lAcIva UPDATE
   aGet[17]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nPuGastosFi  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 115 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[16] VAR cPuObserv    ;
      MULTILINE ID 116 OF oDlg UPDATE     ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON   ;
      ID    200      ;
      OF    oDlg     ;
      ACTION   ( lCont:= .t., oDlg:end(IDOK) ) ;
      WHEN lCont

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( lCont:= .f., oDlg:end(IDOK) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( lCont:= .f., oDlg:end(IDCANCEL) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
		lReturn := .t.
      if nMode == 2
         PU->(DbGoTo(nRecPtr))
      else
         PU->(DbGoTo(nRecAdd))
      endif
      // guardo el registro _______________________________________________//
      //Replace AP->ApNumero	  with cApNumero
      Replace PU->PuTipo     with "G"
      Replace PU->PuFecha    with dPuFecha
      Replace PU->PuConcepto with cPuConcepto
		Replace PU->PuActivida with cPuActivida
      Replace PU->PuImpNeto  with nPuImpNeto
      Replace PU->PuObserv   with cPuObserv
      Replace PU->PuProveed  with cPuProveed
      Replace PU->PuCatGast  with cPuCatGast
      Replace PU->PuIvaSop   with VAL(StrTran(cPuIvaSop,",","."))
      Replace PU->PuImpTotal with nPuImpTotal
      Replace PU->PuGastosFi with nPuGastosFi
      Replace PU->PuRecGas   with VAL(StrTran(cPuRecGas,",","."))
      PU->(DbCommit())
		if nMode != 2
      	// SetIni(oApp():cIniFile, "Config", "SiguienteApunte", cApNumero )
		endif
		if nMode == 4
			// dPeFecha := dApFecha
		endif
   else
      lReturn := .f.
      if nMode != 2
         PU->(DbGoTo(nRecAdd))
         PU->(DbDelete())
         PU->(DbPack())
         PU->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT PU
   if oCont != NIL
      RefreshCont(oCont,"PU")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn

/*_____________________________________________________________________________*/

function PuBorra(oGrid,oCont)
   local nRecord := AP->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este presupuesto de "+iif(PU->PuTipo=="I","ingreso","gasto")+" ?")+CRLF+;
               "Fecha: "+DtoC(PU->PuFecha)+" Importe: "+tran(PU->PuImpTotal,"@E 999,999.99") )
      SELECT PU
      PU->(DbSkip())
      nNext := PU->(Recno())
      PU->(DbGoto(nRecord))
      PU->(DbDelete())
      PU->(DbPack())
      PU->(DbGoto(nNext))
      if PU->(EOF()) .or. nNext == nRecord
         PU->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"PU")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
//-----------------------------------------------------------------------//

function PUTecla(nKey,oGrid,oCont,oDlg,oPuMenu)
Do case
   case nKey==VK_RETURN
      if PU->PuTipo == "I"
         PuIEdita(oGrid,2,oCont,oDlg,oPuMenu)
      else
         PuGEdita(oGrid,2,oCont,oDlg,oPuMenu)
      endif
   case nKey==VK_DELETE
      PuBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
EndCase
return nil
//-----------------------------------------------------------------------//

function PuBusca( oGrid, cChr, oCont, oParent, oPuMenu )

   local nOrder   := PU->(OrdNumber())
   local nRecno   := PU->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
	TITLE i18n("Búsqueda de presupuestos")
   oDlg:SetFont(oApp():oFont)

	switch nOrder
		case 1
			REDEFINE SAY PROMPT i18n( "Introduzca la actividad" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Actividad:" ) ID 21 OF Odlg
			cGet := space(60)
			exit
		case 2
			REDEFINE SAY PROMPT i18n( "Introduzca la fecha" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Fecha:" ) ID 21 OF Odlg
			cGet := CtoD('')
			lFecha := .t.
			exit
		case 3
			REDEFINE SAY PROMPT i18n( "Introduzca el concepto" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Concepto:" ) ID 21 OF Odlg
			cGet := space(90)
			exit
		case 4
			REDEFINE SAY PROMPT i18n( "Introduzca el tipo de ingreso" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Tipo Ingreso:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 5
			REDEFINE SAY PROMPT i18n( "Introduzca el pagador" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Pagador:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 6
			REDEFINE SAY PROMPT i18n( "Introduzca el tipo de gasto" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Tipo Gasto:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 7
			REDEFINE SAY PROMPT i18n( "Introduzca el perceptor" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Perceptor:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
	end

	/*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

	if cChr != nil
		if ! lFecha
			cGet := cChr+SubStr(cGet,1,len(cGet)-1)
			else
			cGet := CtoD(cChr+' -  -    ')
		endif
	endif

	if ! lFecha
		REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg // COLOR oApp():cClrIng, CLR_WHITE
		else
		REDEFINE GET oGet VAR cGet ID 101 OF oDlg // COLOR oApp():cClrIng, CLR_WHITE
	endif

	if cChr != nil
		oGet:bGotFocus := { || oGet:SetPos(2) }
	endif

	REDEFINE BUTTON ID IDOK OF oDlg 	;
	PROMPT i18n( "&Aceptar" )   	;
	ACTION (lSeek := .t., oDlg:End())
	REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
	PROMPT i18n( "&Cancelar" )  	;
	ACTION (lSeek := .f., oDlg:End())

	// sysrefresh()

	ACTIVATE DIALOG oDlg ;
	ON INIT DlgCenter(oDlg,oApp():oWndMain)

	if lSeek
		if ! lFecha
			CursorWait()
			MsgRun('Realizando la búsqueda...', oApp():cVersion, ;
			{ || PuWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
			CursorArrow()
			if len(aBrowse) == 0
				MsgStop("No se ha encontrado ningun presupuesto.")
				PU->(DbGoTo(nRecno))
				else
				PuEncontrados(aBrowse, oApp():oDlg, oPuMenu)
			endif
			else
			if ! PU->(DbSeek(DtoS(cGet)))
				msgAlert( i18n( "Presupuesto no encontrado." ) )
				PU->(DbGoTo(nRecno))
			endif
		endif
	endif

	PU->(OrdSetFocus(nOrder))

	RefreshCont( oCont, "PU" )
	oGrid:refresh()
	oGrid:setFocus()
	oApp():nEdit--

return NIL
//-----------------------------------------------------------------------//

function PUWildSeek(nOrder, cGet, aBrowse)
   local nRecno := PU->(Recno())

   switch nOrder
	case 1
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuActivida)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	case 3
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuConcepto)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	case 4
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuCatIngr)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	case 5
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuCliente)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	case 6
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuCatGast)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	case 7
		PU->(DbGoTop())
		do while ! PU->(Eof())
			if cGet $ upper(PU->PuProveed)
				aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuTipo, PU->PuConcepto, tran(PU->PuImpTotal,"@E 999,999.99"), PU->(Recno()) })
			endif
			PU->(DbSkip())
		enddo
		exit
	end
	PU->(DbGoTo(nRecno))
	// ordeno la tabla por el 1 elemento
	ASort( aBrowse,,, { |aAut1, aAut2| DtoS(aAut1[1]) < DtoS(aAut2[1]) } )
return nil
//-----------------------------------------------------------------------//

function PuEncontrados(aBrowse, oParent, oPuMenu)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := AP->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
		TITLE i18n( "Resultado de la búsqueda" ) ;
		OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
	oBrowse:aCols[1]:cHeader  := "Fecha"
	oBrowse:aCols[1]:nWidth   := 62
   oBrowse:aCols[2]:cHeader  := "Actividad"
   oBrowse:aCols[2]:nWidth   := 160
   oBrowse:aCols[3]:cHeader  := "I/G"
   oBrowse:aCols[3]:nWidth   := 24
   oBrowse:aCols[4]:cHeader  := "Concepto"
   oBrowse:aCols[4]:nWidth   := 210
   oBrowse:aCols[5]:cHeader  := "Importe"
   oBrowse:aCols[5]:nWidth   := 75
   oBrowse:aCols[5]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[5]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[6]:lHide    := .t.
	oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,3] == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
	oBrowse:bClrRowFocus := { || { iif( aBrowse[oBrowse:nArrayAt,3] == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }	 
	obrowse:bClrSelFocus := { || { iif( aBrowse[oBrowse:nArrayAt,3] == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }
   oBrowse:lHScroll  := .f.
   oBrowse:nRowHeight:= 20

   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
		aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||PU->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])),;
			IIF(AP->ApTipo=='I',;
			PUIEdita( oApp():oGrid, 2, , oApp():oDlg, oPuMenu ),;
			PUGEdita( oApp():oGrid, 2, , oApp():oDlg, oPuMenu )),;
		PU->(DbGoTo(aBrowse[oBrowse:nArrayAt,6])) } })
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,PU->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])),;
		IIF(PU->ApTipo=='I',;
		PUIEdita( oApp():oGrid, 2, , oApp():oDlg, oPuMenu ),;
		PUGEdita( oApp():oGrid, 2, , oApp():oDlg, oPuMenu )))}
   oBrowse:bChange    := { || PU->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])) }

   oDlg:oClient := oBrowse

   REDEFINE BUTTON oBtnOk ;
	ID IDOK OF oDlg     ;
	ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
	ID IDCANCEL OF oDlg ;
	ACTION (PU->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
	ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil


//-----------------------------------------------------------------------------//
function PuImpMenu(oGrid, oParent, oPuMenu)
	local oPopup
   MENU oPopup POPUP 2007
      MENUITEM "Impresión de presupuestos"  RESOURCE "16_APUNTES" ACTION PuPuImprime(oGrid, oParent, oPuMenu)
      MENUITEM "Impresión de presupuestos de ingresos" RESOURCE "16_INGRESO" ACTION PuInImprime(oGrid, oParent, oPuMenu)
      MENUITEM "Impresión de presupuestos de gastos"   RESOURCE "16_GASTO"   ACTION PuGaImprime(oGrid, oParent, oPuMenu)
   ENDMENU
return oPopUp

//-----------------------------------------------------------------------//
function PuPuImprime(oGrid,oParent,oPuMenu)
   local nRecno   := PU->(Recno())
   local nOrder   := PU->(OrdSetFocus())
   local aCampos  := { "PUTIPO", "PUACTIVIDA", "PUFECHA" , "PUCONCEPTO", "PUIMPNETO", "PUCLIENTE", "PUCATINGR", ;
                       "PURECING", "PUIVAREP", "PUGASTOSFI", "PUIMPTOTAL",;
                       "PUPROVEED", "PUCATGAST", "PURECGAS", "PUIVASOP" }
   local aTitulos := { "Presupuesto", "Actividad", "Fecha", "Concepto", "Imp. Neto", "Cliente", "Tipo Ing.",;
                       "Rec. Ing.", "IVA Rep.", "Gastos Fin.", "Imp. Total",;
                       "Proveedor", "Tipo Gas.", "Rec. Gas.", "IVA Sop."  }
   local aWidth   := { 5, 40, 15, 40, 15, 20, 20, 15, 15, 15, 15, 20, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO", "NO","NO","PU01","NO","NO","NO","NO","NO","PU02","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .t., .f., .f., .f., .f., .t., .t., .f., .f., .f., .f. }
   local oInforme
   local aControls[11]
	local aSay[4]
   local lGroup1  := .f.
   local cPuCatIngr
   local lGroup2  := .f.
   local cPuCliente
   local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := Ctod('')
	local aIng1 	:= {}
	local aIng2 	:= {}
	local aGas1 	:= {}
	local aGas2 	:= {}
	local nAt
	local nTotal 	:= 0
	local cActividad, i

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PUPU" )
	if ! oPuMenu:aItems[1]:lChecked
		for i:=1 to Len(oPuMenu:aItems)
			if oPuMenu:aItems[i]:lChecked
				cActividad := oPuMenu:aItems[i]:cPrompt
			endif
		next
	endif
	if cActividad != nil
		oInforme:cTitulo3 := cActividad
	endif
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302 OF oInforme:oFld:aDialogs[1]

   REDEFINE SAY aSay[1] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[2] ID 154 OF oInforme:oFld:aDialogs[1]

    REDEFINE CHECKBOX aControls[7] VAR lPeriodo ;
   	ID 150 OF oInforme:oFld:aDialogs[1]

   REDEFINE GET aControls[8] VAR dInicio ;
      ID 152 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[9] ID 153 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dInicio,aControls[8]) ;
      WHEN lPeriodo

   REDEFINE GET aControls[10] VAR dFinal  ;
      ID 155 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[11] ID 156 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dFinal,aControls[10]) ;
      WHEN lPeriodo

   oInforme:Folders()
   if oInforme:Activate()
		Select PU
      if oInforme:nRadio == 1
      	PU->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
  	      PU->(DbGoTop())
			while ! PU->(eof())
				if  ! lPeriodo .OR. ( lPeriodo .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal )
					if PU->PuTipo == "I"
						nAt := Ascan(aIng1, PU->PuCatIngr)
						if nAt == 0
							aadd(aIng1,PU->PuCatIngr)
							aadd(aIng2,PU->PuImpNeto)
						else
							aIng2[nAt] += PU->PuImpNeto
						endif
						nTotal += PU->PuImpNeto
					else
						nAt := Ascan(aGas1, PU->PuCatGast)
						if nAt == 0
							aadd(aGas1,PU->PuCatGast)
							aadd(aGas2,PU->PuImpNeto)
						else
							aGas2[nAt] += PU->PuImpNeto
						endif
						nTotal -= PU->PuImpNeto
					endif
				endif
				PU->(DbSkip())
			enddo

			nAt := 1
			oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   		oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   		oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   		oInforme:cTitulo1 := Rtrim(oInforme:cTitulo1)
   		oInforme:cTitulo2 := Rtrim(oInforme:cTitulo2)
			if lPeriodo
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
			endif

   		if oInforme:nDevice == 1
     			REPORT oInforme:oReport ;
				   TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
			     	FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
   			  	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
			     	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
     				CAPTION oApp():cAppName+oApp():cVersion PREVIEW
	   	elseif oInforme:nDevice == 2
		     	REPORT oInforme:oReport ;
				   TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
			     	FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
			     	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
			     	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
			     	CAPTION oApp():cAppName+oApp():cVersion // PREVIEW
   		endif
   			COLUMN TITLE "Tipo Ingreso" DATA iif(nAt<=len(aIng1),aIng1[nAt],"") SIZE 30 FONT 1
   			COLUMN TITLE "Imp. Neto"    DATA iif(nAt<=len(aIng2),aIng2[nAt],"") SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
   			COLUMN TITLE "Tipo Gasto"   DATA iif(nAt<=len(aGas1),aGas1[nAt],"") SIZE 30 FONT 1
   			COLUMN TITLE "Imp. Neto"    DATA iif(nAt<=len(aGas2),aGas2[nAt],"") SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
   		END REPORT

			oInforme:oReport:Cargo := oInforme:cPdfFile

			if oInforme:oReport:lCreated
		      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      		oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
		      oInforme:oReport:oTitle:aFont[2]  := {|| 3 }
      		oInforme:oReport:oTitle:aFont[3]  := {|| 2 }
		      oInforme:oReport:nTopMargin       := 0.1
      		oInforme:oReport:nDnMargin        := 0.1
		      oInforme:oReport:nLeftMargin      := 0.1
      		oInforme:oReport:nRightMargin     := 0.1
		      oInforme:oReport:oDevice:lPrvModal:= .t.
		   endif

		   oInforme:oReport:bSkip := {||( nAt++ )}

     		ACTIVATE REPORT oInforme:oReport WHILE nAt <= max(len(aIng1),len(aGas1)) ;
				ON POSTEND ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(),;
			   oInforme:oReport:StartLine(), ;
				oInforme:oReport:Say(1, 'SALDO..'+Tran(nTotal, '@E 9,999,999.99'), 1 ),;
				oInforme:oReport:EndLine() )

			oInforme:End(.t.)
		elseif oInforme:nRadio == 3
  	      PU->(DbGoTop())
			while ! PU->(eof())
				if  ! lPeriodo .OR. ( lPeriodo .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal )
					if PU->PuTipo == "I"
						nAt := Ascan(aIng1, PU->PuCatIngr)
						if nAt == 0
							aadd(aIng1,PU->PUCatIngr)
							aadd(aIng2,PU->PUImpTotal)
						else
							aIng2[nAt] += PU->PuImpTotal
						endif
						nTotal += PU->PuImpTotal
					else
						nAt := Ascan(aGas1, PU->PuCatGast)
						if nAt == 0
							aadd(aGas1,PU->PuCatGast)
							aadd(aGas2,PU->PuImpTotal)
							else
							aGas2[nAt] += PU->PuImpTotal
						endif
						nTotal -= PU->PuImpTotal
					endif
				endif
				PU->(DbSkip())
			enddo

			nAt := 1
			oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
			oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   		oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   		oInforme:cTitulo1 := Rtrim(oInforme:cTitulo1)
   		oInforme:cTitulo2 := Rtrim(oInforme:cTitulo2)
			if lPeriodo
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
					else
						oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
			endif

   		if oInforme:nDevice == 1
     			REPORT oInforme:oReport ;
				TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
				FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
				HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
				FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
				CAPTION oApp():cAppName+oApp():cVersion PREVIEW
				elseif oInforme:nDevice == 2
		     	REPORT oInforme:oReport ;
				TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
				FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
				HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
				FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
				CAPTION oApp():cAppName+oApp():cVersion // PREVIEW
   		endif

			COLUMN TITLE "Tipo Ingreso" DATA iif(nAt<=len(aIng1),aIng1[nAt],"") SIZE 30 FONT 1
			COLUMN TITLE "Imp. Total"   DATA iif(nAt<=len(aIng2),aIng2[nAt],"") SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
			COLUMN TITLE "Tipo Gasto"   DATA iif(nAt<=len(aGas1),aGas1[nAt],"") SIZE 30 FONT 1
			COLUMN TITLE "Imp. Total"   DATA iif(nAt<=len(aGas2),aGas2[nAt],"") SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT

   		END REPORT

		   oInforme:oReport:Cargo := oInforme:cPdfFile

   		if oInforme:oReport:lCreated
		      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      		oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
		      oInforme:oReport:oTitle:aFont[2]  := {|| 3 }
      		oInforme:oReport:oTitle:aFont[3]  := {|| 2 }
		      oInforme:oReport:nTopMargin       := 0.1
      		oInforme:oReport:nDnMargin        := 0.1
		      oInforme:oReport:nLeftMargin      := 0.1
      		oInforme:oReport:nRightMargin     := 0.1
		      oInforme:oReport:oDevice:lPrvModal:= .t.
		   endif

		   oInforme:oReport:bSkip := {||( nAt++ )}

     		ACTIVATE REPORT oInforme:oReport WHILE nAt <= max(len(aIng1),len(aGas1)) ;
			ON POSTEND ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(),;
			oInforme:oReport:StartLine(), ;
			oInforme:oReport:Say(1, 'SALDO..'+Tran(nTotal, '@E 9,999,999.99'), 1 ),;
			oInforme:oReport:EndLine() )

			oInforme:End(.t.)
   	endif
		PU->(DbSetOrder(nOrder))
      PU->(DbGoTo(nRecno))
   endif
	oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//-----------------------------------------------------------------------//

function PuInImprime(oGrid,oParent,oPuMenu)
   local nRecno   := PU->(Recno())
   local nOrder   := PU->(OrdSetFocus())
   local aCampos  := { "PUACTIVIDA", "PUFECHA", "PUCONCEPTO", "PUIMPNETO", "PUCLIENTE", "PUCATINGR", ;
                       "PURECING", "PUIVAREP", "PUIVAREP", "PUGASTOSFI", "PUIMPTOTAL" }
   local aTitulos := { "Actividad", "Fecha", "Concepto", "Importe", "Cliente", "Tipo Ing.",;
                       "Rec. Eq.", "Tipo IVA", "IVA Rep.", "Gastos Fin.", "Imp. Total" }
   local aWidth   := { 40, 15, 40, 15, 20, 20, 15, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO","@E 9,999,999.99","NO","NO","NO","NO", "PUI1", "@E 9,999,999.99","@E 9,999,999.99" }
   local aTotal   := { .f.,.f., .f., .t., .f., .f., .f., .f., .t., .t., .t. }
   local oInforme
   local aControls[11]
	local aSay[4]
   local lGroup1  := .f.
   local cPuCatIngr
   local lGroup2  := .f.
   local cPuCliente
   local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := CtoD('')
	local cActividad, i

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PUIN" )
	if ! oPuMenu:aItems[1]:lChecked
		for i:=1 to Len(oPuMenu:aItems)
			if oPuMenu:aItems[i]:lChecked
				cActividad := oPuMenu:aItems[i]:cPrompt
			endif
		next
	endif
	if cActividad != nil
		oInforme:cTitulo3 := cActividad
	endif
	oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302, 303, 304 OF oInforme:oFld:aDialogs[1]

	REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[2] ID 140 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[3] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[4] ID 154 OF oInforme:oFld:aDialogs[1]

   REDEFINE CHECKBOX aControls[1] VAR lGroup1 ;
      ID 110 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 2

   REDEFINE GET aControls[2] VAR cPuCatIngr ;
      ID 121 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID InClave( cPuCatIngr, aControls[2], 4, 2 ) ;
      WHEN oInforme:nRadio == 3
   REDEFINE BUTTON aControls[3] ID 122 OF oInforme:oFld:aDialogs[1] ;
      ACTION InSeleccion( cPuCatIngr, aControls[2], oInforme:oFld:aDialogs[1] ) ;
      WHEN oInforme:nRadio == 3

   REDEFINE CHECKBOX aControls[4] VAR lGroup1 ;
      ID 130 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 4

   REDEFINE GET aControls[5] VAR cPuCliente ;
      ID 141 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID ClClave( cPuCliente, aControls[5], 4, 1 ) ;
      WHEN oInforme:nRadio == 5
   REDEFINE BUTTON aControls[6] ID 142 OF oInforme:oFld:aDialogs[1] ;
      ACTION ClSeleccion( cPuCliente, aControls[5], oInforme:oFld:aDialogs[1] )

   REDEFINE CHECKBOX aControls[7] VAR lPeriodo ;
   	ID 150 OF oInforme:oFld:aDialogs[1]

   REDEFINE GET aControls[8] VAR dInicio ;
      ID 152 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[9] ID 153 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dInicio,aControls[8]) ;
      WHEN lPeriodo

   REDEFINE GET aControls[10] VAR dFinal  ;
      ID 155 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[11] ID 156 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dFinal,aControls[10]) ;
      WHEN lPeriodo

   oInforme:Folders()
   if oInforme:Activate()
		Select PU
      if oInforme:nRadio == 1
      	PU->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I"
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
      	PU->(DbSetOrder(4))
  	      PU->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 3
      	PU->(DbSetOrder(4))
      	PU->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. PU->PuCatIngr == cPuCatIngr ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. PU->PuCatIngr == cPuCatIngr .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 4
      	PU->(DbSetOrder(5))
      	PU->(DbGoTop())
         oInforme:Report(lGroup2)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
      	else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
			endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 5
      	PU->(DbSetOrder(5))
      	PU->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. PU->PuCliente == cPuCliente
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "I" .AND. PU->PuCliente == cPuCliente .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 6
			//
			AP->(DbSetOrder(11))
      	AP->(DbGoTop())

			oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   		oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   		oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   		oInforme:cTitulo1 := "IVA Repercutido"
   		oInforme:cTitulo2 := iif(Empty(cActividad),"Todas las actividades",cActividad)
			if lPeriodo
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
			else
				oInforme:cTitulo3 := "Ejercicio "+oApp():cEjercicio
			endif

   		if oInforme:nDevice == 1
     			REPORT oInforme:oReport ;
				   TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
			     	FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
   			  	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
			     	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
     				CAPTION oApp():cAppName+oApp():cVersion PREVIEW
	   	elseif oInforme:nDevice == 2
		     	REPORT oInforme:oReport ;
				   TITLE  " ",oInforme:cTitulo1,oInforme:cTitulo2,oInforme:cTitulo3 CENTERED;
			     	FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
			     	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
			     	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
			     	CAPTION oApp():cAppName+oApp():cVersion
   		endif
   			COLUMN TITLE "Fecha" 	 DATA AP->ApFecha   SIZE 10 FONT 1
   			COLUMN TITLE "Pagador"   DATA AP->ApCliente SIZE 30 FONT 1
   			COLUMN TITLE "Imp. Neto" DATA AP->ApImpNeto SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
				COLUMN TITLE "Tipo IVA"  DATA AP->ApIvaRep  SIZE 12 FONT 1 PICTURE "@E 99.99"       RIGHT
				COLUMN TITLE "Imp. IVA"  DATA AP->ApImpNeto*AP->ApIvaRep/100 SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
				COLUMN TITLE "Gastos"    DATA AP->ApGastosFi SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
				GROUP ON Str(AP->ApIvaRep);
					FOOTER " » Total tipo de IVA » "+oInforme:oReport:aGroups[1]:cValue ; // +"("+ltrim(str(::oReport:aGroups[1]:nCounter))+")" ;
					FONT 1
   		END REPORT

			oInforme:oReport:Cargo := oInforme:cPdfFile

			if oInforme:oReport:lCreated
		      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      		oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
		      oInforme:oReport:oTitle:aFont[2]  := {|| 3 }
      		oInforme:oReport:oTitle:aFont[3]  := {|| 2 }
		      oInforme:oReport:nTopMargin       := 0.1
      		oInforme:oReport:nDnMargin        := 0.1
		      oInforme:oReport:nLeftMargin      := 0.1
      		oInforme:oReport:nRightMargin     := 0.1
		      oInforme:oReport:oDevice:lPrvModal:= .t.
		   endif
			if ! lPeriodo
     			ACTIVATE REPORT oInforme:oReport FOR AP->ApTipo == "I" ;
         		ON POSTGROUP oInforme:oReport:NewLine()
			else
				ACTIVATE REPORT oInforme:oReport FOR AP->ApTipo == "I" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal ;
					ON POSTGROUP oInforme:oReport:NewLine()
			endif
			oInforme:End(.f.) // no guardo el título
		endif
		Select PU
      PU->(DbSetOrder(nOrder))
      PU->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//-----------------------------------------------------------------------//

function PuGaImprime(oGrid,oParent, oPuMenu)
   local nRecno   := PU->(Recno())
   local nOrder   := PU->(OrdSetFocus())
   local aCampos  := { "PUACTIVIDA", "PUFECHA" , "PUCONCEPTO", "PUIMPNETO", "PUPROVEED", "PUCATGAST", ;
                       "PURECGAS", "PUIVASOP", "PUIVASOP", "PUGASTOSFI", "PUIMPTOTAL" }
   local aTitulos := { "Actividad", "Fecha", "Concepto", "Importe", "Proveedor", "Tipo Gas.",;
                       "Rec. Eq.", "Tipo IVA", "IVA Sop.", "Gastos Fin.", "Imp. Total" }
   local aWidth   := { 40, 15, 40, 15, 20, 20, 15, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO", "NO", "NO","@E 9,999,999.99","NO","NO","NO","NO","PUG1", "@E 9,999,999.99","@E 9,999,999.99" }
   local aTotal   := { .f., .f., .f., .t., .f., .f., .f., .f., .t., .t., .t. }
   local oInforme
   local aControls[11]
   local aSay[4]
   local lGroup1  := .f.
   local cPuCatGast
   local lGroup2  := .f.
   local cPuProveed
   local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := CtoD('')
	local cActividad, i
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PUGA" )
	if ! oPuMenu:aItems[1]:lChecked
		for i:=1 to Len(oPuMenu:aItems)
			if oPuMenu:aItems[i]:lChecked
				cActividad := oPuMenu:aItems[i]:cPrompt
			endif
		next
	endif
	if cActividad != nil
		oInforme:cTitulo3:=cActividad
	endif
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302, 303, 304 OF oInforme:oFld:aDialogs[1]

	REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[2] ID 140 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[3] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[4] ID 154 OF oInforme:oFld:aDialogs[1]

   REDEFINE CHECKBOX aControls[1] VAR lGroup1 ;
      ID 110 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 2

   REDEFINE GET aControls[2] VAR cPuCatGast ;
      ID 121 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID GaClave( cPuCatGast, aControls[2], 4, 2 ) ;
      WHEN oInforme:nRadio == 3
   REDEFINE BUTTON aControls[3] ID 122 OF oInforme:oFld:aDialogs[1] ;
      ACTION GaSeleccion( cPuCatGast, aControls[2], oInforme:oFld:aDialogs[1] ) ;
      WHEN oInforme:nRadio == 3

   REDEFINE CHECKBOX aControls[4] VAR lGroup1 ;
      ID 130 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 4

   REDEFINE GET aControls[5] VAR cPuProveed ;
      ID 141 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID PrClave( cPuProveed, aControls[5], 4, 1 ) ;
      WHEN oInforme:nRadio == 5
   REDEFINE BUTTON aControls[6] ID 142 OF oInforme:oFld:aDialogs[1] ;
      ACTION PrSeleccion( cPuProveed, aControls[5], oInforme:oFld:aDialogs[1] )

   REDEFINE CHECKBOX aControls[7] VAR lPeriodo ;
   	ID 150 OF oInforme:oFld:aDialogs[1]

   // REDEFINE SAY aControl[5] ID 131 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aControls[8] VAR dInicio ;
      ID 152 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[9] ID 153 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dInicio,aControls[8]) ;
      WHEN lPeriodo

   // REDEFINE SAY aControl[8] ID 134 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aControls[10] VAR dFinal  ;
      ID 155 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aControls[11] ID 156 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dFinal,aControls[10]) ;
      WHEN lPeriodo

   oInforme:Folders()
   if oInforme:Activate()
		Select PU
      if oInforme:nRadio == 1
      	PU->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G"
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
      	PU->(DbSetOrder(6))
  	      PU->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 3
      	PU->(DbSetOrder(6))
      	PU->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. PU->PuCatGast == cPuCatGast
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. PU->PuCatGast == cPuCatGast .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 4
      	PU->(DbSetOrder(7))
      	PU->(DbGoTop())
         oInforme:Report(lGroup2)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
      	else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
      	endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 5
      	AP->(DbSetOrder(7))
      	AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. PU->PuProveed == cPuProveed
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR PU->PuTipo == "G" .AND. PU->PuProveed == cPuProveed .AND. dInicio <= PU->PuFecha .AND. PU->PuFecha <= dFinal
         endif
         oInforme:End(.t.)
      endif
      PU->(DbSetOrder(nOrder))
      PU->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//_____________________________________________________________________________*/
function PuSiguiente(aActividad)
   local cNextAp
	local nOrder   := AP->(OrdNumber())
   local nRecno   := AP->(Recno())
	local nFilter  := Val(AP->(DbFilter()))

	if nFilter != 0
		AP->(DbClearFilter())
	endif
   AP->(OrdSetFocus(9))
	AP->(DbGoBottom())
	if EoF()
		cNextAp := oApp():cEjercicio+"000000"
   else
		cNextAp := StrZero(VAL(AP->ApNumero)+1,10)
	endif
	if nFilter != 0
		AP->(DbSetFilter( {|| AP->ApActivida==aActividad[nFilter] }, Str(nFilter) ))
	endif
	AP->(OrdSetFocus(nOrder))
	AP->(DbGoTo(nRecno))
return cNextAp
//_____________________________________________________________________________*/
//
function PuRecalc(nPuImpNeto, cPuIva, nTIVA, cPuRec, nTRecEq, nPuImpTotal, aGet, oDlg, lDesglose)
	// ? nPuImpNeto
	// ? cPuIva
   if lDesglose
      nPuImpNeto  := nPuImpTotal / (1+((VAL(StrTran(cPuIva,",","."))+VAL(StrTran(cPuRec,",",".")))/100))
      nTIVA       := nPuImpNeto * VAL(StrTran(cPuIva,",",".")) / 100
      nTRecEq     := nPuImpNeto * VAL(StrTran(cPuRec,",",".")) / 100
      aGet[09]:cText(nPuImpNeto)
      aGet[13]:cText(nTRecEq)
      aGet[11]:cText(nTIVA)
   else
      nTIVA       := nPuImpNeto * VAL(StrTran(cPuIva,",",".")) / 100
      nTRecEq     := nPuImpNeto * VAL(StrTran(cPuRec,",",".")) / 100
      nPuImpTotal := nPuImpNeto + nTIVA + nTRecEq
      aGet[11]:cText(nTIVA)
      aGet[13]:cText(nTRecEq)
      aGet[14]:cText(nPuImpTotal)
   endif
   oDlg:Update()
return .t.
//____________________________________________________________________________//

function PuDesviacMenu(oGrid, oParent, oPuMenu, aActividad)
	local oPopup
   MENU oPopup POPUP 2007
      MENUITEM "Desviación de presupuestos / apuntes en el ejercicio"  RESOURCE "16_EJERCICIO" ACTION PuDesviacEjercicio(oGrid,oParent,oPuMenu,aActividad,.f.)
      MENUITEM "Desviación de presupuestos / apuntes en un periodo" RESOURCE "16_FECHA" ACTION PuDesviacPeriodo(oGrid,oParent,oPuMenu,aActividad,.f.)
   ENDMENU
return oPopUp
//____________________________________________________________________________//

function PuDesviacEjercicio(oGrid,oParent,oPuMenu,aActividad,lSaldos)
   local nApRecno := AP->(Recno())
   local nApOrder := AP->(OrdSetFocus())
	local nPuRecno := PU->(Recno())
   local nPuOrder := PU->(OrdSetFocus())
	local aIngPer  := {}
	local aGasPer  := {}
	local aCatIng  := {}
	local aCatGas  := {}
   local aSumIng  := {}
	local aSumGas  := {}
	local aSumIva	:= {}
	local aCuentas := {}
	local aSaldos  := {}
	local aListado := {}
	local nTrim    := 0
	local lFilter  := .f.
	local cActividad := "Todas las actividades"

   local oInforme
   local i

	// si tengop filtro o una sóla actividad pongo lFilter a true
	if oPuMenu != nil
		if (! oPuMenu:aItems[1]:lChecked) .OR. len(aActividad)==1
			lFilter := .t.
		endif
	endif

	// creo el array de tipos de ingreso
	IN->(OrdSetFocus(1))
	IN->(DbGoTop())
	while ! IN->(eof())
		aadd(aCatIng, Rtrim(IN->InCategor))
 		aadd(aSumIng, {space(5)+Rtrim(IN->InCategor),0,0,0})
		IN->(DbSkip())
	enddo

	// creo el array de tipos de gasto
	GA->(OrdSetFocus(1))
	GA->(DbGoTop())
	while ! GA->(eof())
		aadd(aCatGas, Rtrim(GA->GaCategor))
		aadd(aSumGas, {space(5)+Rtrim(GA->GaCategor),0,0,0})
		GA->(DbSkip())
	enddo

	// creo el array de IVA
	aadd(aSumIva, {"IVA Repercutido - Base",0,0,0})
	aadd(aSumIva, {"IVA Repercutido - Cuota",0,0,0})
	aadd(aSumIva, {"IVA Soportado - Base",0,0,0})
	aadd(aSumIva, {"IVA Soportado - Cuota",0,0,0})
	aadd(aSumIva, {"Diferencia - Base",0,0,0})
	aadd(aSumIva, {"Diferencia - Cuota",0,0,0})

	if lFilter
		cActividad := Rtrim(PU->PuActivida)
		AP->(DbSetFilter( {|| Rtrim(AP->ApActivida)==cActividad }, cActividad ))
	endif
   PU->(DbGoTop())
	while ! PU->(EoF())
		// los presupuestos restan en el total
		if PU->PuTipo == 'I'
			if AScan(aCatIng,Rtrim(Pu->PuCatIngr)) != 0
				aSumIng[AScan(aCatIng,Rtrim(PU->PuCatIngr)),2] += PU->PuImpNeto
				aSumIng[AScan(aCatIng,Rtrim(PU->PuCatIngr)),4] -= PU->PuImpNeto
			endif
			if PU->PuIvaRep != 0
				aSumIva[1,2] += PU->PuImpNeto
				aSumIva[1,4] -= PU->PuImpNeto
				aSumIva[2,2] += PU->PuImpNeto*PU->PuIvaRep/100
				aSumIva[2,4] -= PU->PuImpNeto*PU->PuIvaRep/100
				aSumIva[5,2] += PU->PuImpNeto
				aSumIva[5,4] -= PU->PuImpNeto
				aSumIva[6,2] += PU->PuImpNeto*PU->PuIvaRep/100
				aSumIva[6,4] -= PU->PuImpNeto*PU->PuIvaRep/100
			endif
		else
			if AScan(aCatGas,Rtrim(PU->PuCatGast)) != 0
				aSumGas[AScan(aCatGas,Rtrim(PU->PuCatGast)),2] += PU->PuImpNeto
				aSumGas[AScan(aCatGas,Rtrim(PU->PuCatGast)),4] -= PU->PuImpNeto
			endif
			if PU->PuIvaSop != 0
				aSumIva[3,2] += PU->PuImpNeto
				aSumIva[3,4] -= PU->PuImpNeto
				aSumIva[4,2] += PU->PuImpNeto*PU->PuIvaSop/100
				aSumIva[4,4] -= PU->PuImpNeto*PU->PuIvaSop/100
				aSumIva[5,2] += PU->PuImpNeto
				aSumIva[5,4] -= PU->PuImpNeto
				aSumIva[6,2] += PU->PuImpNeto*PU->PuIvaSop/100
				aSumIva[6,4] -= PU->PuImpNeto*PU->PuIvaSop/100
			endif
		endif
		PU->(DbSkip())
   enddo
   AP->(DbGoTop())
   while ! AP->(EoF())
		if AP->ApTipo == 'I'
			if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),3] += Ap->ApImpNeto
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),4] += Ap->ApImpNeto
			endif
			if AP->ApIvaRep != 0
				aSumIva[1,3] += Ap->ApImpNeto
				aSumIva[1,4] += Ap->ApImpNeto
				aSumIva[2,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[2,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[5,3] += Ap->ApImpNeto
				aSumIva[5,4] += Ap->ApImpNeto
				aSumIva[6,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[6,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
			endif
		else
			if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),3] += AP->ApImpNeto
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),4] += Ap->ApImpNeto
			endif
			if AP->ApIvaSop != 0
				aSumIva[3,3] += Ap->ApImpNeto
				aSumIva[3,4] += Ap->ApImpNeto
				aSumIva[4,3] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[4,4] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[5,3] -= Ap->ApImpNeto
				aSumIva[5,4] -= Ap->ApImpNeto
				aSumIva[6,3] -= Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[6,4] -= Ap->ApImpNeto*Ap->ApIvaSop/100
			endif
		endif
		AP->(DbSkip())
   enddo

	Aadd(aListado,{"Ingresos","","",""})
	aIngPer := {"Total Ingresos",0,0,0}
	for i := 1 to Len(aSumIng)
		Aadd(aListado, aSumIng[i])
		aIngPer[2] += aSumIng[i,2]
		aIngPer[3] += aSumIng[i,3]
		aIngPer[4] += aSumIng[i,4]
		//aIngPer[5] += aSumIng[i,5]
		//aIngPer[6] += aSumIng[i,6]
	next
	Aadd(aListado,{"Gastos","","",""})
	aGasPer := {"Total Gastos",0,0,0}
	for i := 1 to Len(aSumGas)
		Aadd(aListado, aSumGas[i])
		aGasPer[2] += aSumGas[i,2]
		aGasPer[3] += aSumGas[i,3]
		aGasPer[4] += aSumGas[i,4]
		//aGasPer[5] += aSumGas[i,5]
		//aGasPer[6] += aSumGas[i,6]
	next
	Aadd(aListado,{"","","",""})
	Aadd(aListado, aIngPer)
	Aadd(aListado, aGasPer)
	//Aadd(aListado, {"Rendimiento", aIngPer[2]-aGasPer[2],aIngPer[3]-aGasPer[3],;
	//								       aIngPer[4]-aGasPer[4],aIngPer[5]-aGasPer[5],aIngPer[6]-aGasPer[6]})
	Aadd(aListado,{"","","",""})
	Aadd(aListado, aSumIva[1])
	Aadd(aListado, aSumIva[2])
	Aadd(aListado, aSumIva[3])
	Aadd(aListado, aSumIva[4])
	//Aadd(aListado, aSumIva[5])
	//Aadd(aListado, aSumIva[6])

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "PEAP", "" )
   oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
   REPORT oReport ;
      TITLE  " "," ","Desviación anual de presupuestos",iif(lFilter,"["+cActividad+"]","[Todas las actividades]"),;
         "Ejercicio "+oApp():cEjercicio CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
      FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + " - Desviación anual de presupuestos" PREVIEW
      i := 1
      COLUMN TITLE "Concepto"   	  DATA aListado[i,1] SIZE 35 FONT 1
      COLUMN TITLE "Presupuestos"  DATA aListado[i,2] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Apuntes"       DATA aListado[i,3] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Desviación (A-P)"    DATA aListado[i,4] SIZE 18 FONT 1 PICTURE "@E 999,999,999.99" RIGHT

   END REPORT

   oReport:Cargo := oInforme:cPdfFile

   if oReport:lCreated
      oReport:nTitleUpLine := RPT_SINGLELINE
      oReport:nTitleDnLine := RPT_SINGLELINE
      oReport:oTitle:aFont[3] := {|| 2 }
      oReport:nTopMargin   := 0.1
      oReport:nDnMargin    := 0.1
      oReport:nLeftMargin  := 0.1
      oReport:nRightMargin := 0.1
      oReport:oDevice:lPrvModal := .T.
   endif
   oReport:bSkip := {|| i++}
   ACTIVATE REPORT oReport WHILE i <= len(aListado)
   oInforme:End(.f.)

   oApp():nEdit --
   AP->(DbSetOrder(nApOrder))
   AP->(DbGoTo(nApRecno))
	PU->(DbSetOrder(nPuOrder))
   PU->(DbGoTo(nPuRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
//_______________________________________________________________________________//
function PuDesviacPeriodo(oGrid,oParent,oPuMenu,aActividad,lSaldos)
   local nApRecno := AP->(Recno())
   local nApOrder := AP->(OrdSetFocus())
	local nPuRecno := PU->(Recno())
   local nPuOrder := PU->(OrdSetFocus())
   local oDlg, aGet[7]
   local dInicio  := CtoD('01/01/'+oApp():cEjercicio)
   local dFinal   := CtoD('31/12/'+oApp():cEjercicio)
	local aIngPer  := {}
	local aGasPer  := {}
	local aCatIng  := {}
	local aCatGas  := {}
   local aSumIng  := {}
	local aSumGas  := {}
	local aSumIva	:= {}
	local aCuentas := {}
	local aSaldos  := {}
	local aListado := {}
	local nTrim    := 0
	local lFilter  := .f.
	local cActividad := "Todas las actividades"

   local oInforme
   local i

	// si tengop filtro o una sóla actividad pongo lFilter a true
	if oPuMenu != nil
		if (! oPuMenu:aItems[1]:lChecked) .OR. len(aActividad)==1
			lFilter := .t.
		endif
	endif
	oApp():nEdit ++

	DEFINE DIALOG oDlg RESOURCE "APSALDO1" OF oParent;
		TITLE "Desviación presupuestos por fechas"
	oDlg:SetFont(oApp():oFont)

	REDEFINE SAY aGet[1] PROMPT "Introduzca el periodo para la desviación:"ID 100 OF oDlg
	REDEFINE SAY aGet[2] ID 101 OF oDlg
	REDEFINE SAY aGet[3] ID 102 OF oDlg

	REDEFINE GET aGet[4] VAR dInicio ;
		ID 200 OF oDlg UPDATE ;

	REDEFINE BUTTON aGet[5] ID 201 OF oDlg ;
		ACTION SelecFecha(@dInicio,aGet[4])

	REDEFINE GET aGet[6] VAR dFinal  ;
		ID 202 OF oDlg UPDATE

	REDEFINE BUTTON aGet[7] ID 203 OF oDlg ;
		ACTION SelecFecha(@dFinal,aGet[6])

	REDEFINE BUTTON   ;
		ID    IDOK     ;
		OF    oDlg     ;
		ACTION   ( oDlg:end( IDOK ) )

	REDEFINE BUTTON   ;
		ID    IDCANCEL ;
		OF    oDlg     ;
		CANCEL         ;
		ACTION   ( oDlg:end( IDCANCEL ) )

	ACTIVATE DIALOG oDlg ;
		ON INIT DlgCenter(oDlg,oApp():oWndMain)

	if oDlg:nresult != IDOK
		oApp():nEdit --
		retu .f.
	endif

	// creo el array de tipos de ingreso
	IN->(OrdSetFocus(1))
	IN->(DbGoTop())
	while ! IN->(eof())
		aadd(aCatIng, Rtrim(IN->InCategor))
 		aadd(aSumIng, {space(5)+Rtrim(IN->InCategor),0,0,0})
		IN->(DbSkip())
	enddo

	// creo el array de tipos de gasto
	GA->(OrdSetFocus(1))
	GA->(DbGoTop())
	while ! GA->(eof())
		aadd(aCatGas, Rtrim(GA->GaCategor))
		aadd(aSumGas, {space(5)+Rtrim(GA->GaCategor),0,0,0})
		GA->(DbSkip())
	enddo

	// creo el array de IVA
	aadd(aSumIva, {"IVA Repercutido - Base",0,0,0})
	aadd(aSumIva, {"IVA Repercutido - Cuota",0,0,0})
	aadd(aSumIva, {"IVA Soportado - Base",0,0,0})
	aadd(aSumIva, {"IVA Soportado - Cuota",0,0,0})
	aadd(aSumIva, {"Diferencia - Base",0,0,0})
	aadd(aSumIva, {"Diferencia - Cuota",0,0,0})

	if lFilter
		cActividad := Rtrim(PU->PuActivida)
		AP->(DbSetFilter( {|| Rtrim(AP->ApActivida)==cActividad }, cActividad ))
	endif
   PU->(DbGoTop())
	while ! PU->(EoF())
		if dInicio <= PU->PuFecha .and. PU->PuFecha <= dFinal
			// los presupuestos restan en el total
			if PU->PuTipo == 'I'
				if AScan(aCatIng,Rtrim(Pu->PuCatIngr)) != 0
					aSumIng[AScan(aCatIng,Rtrim(PU->PuCatIngr)),2] += PU->PuImpNeto
					aSumIng[AScan(aCatIng,Rtrim(PU->PuCatIngr)),4] -= PU->PuImpNeto
				endif
				if PU->PuIvaRep != 0
					aSumIva[1,2] += PU->PuImpNeto
					aSumIva[1,4] -= PU->PuImpNeto
					aSumIva[2,2] += PU->PuImpNeto*PU->PuIvaRep/100
					aSumIva[2,4] -= PU->PuImpNeto*PU->PuIvaRep/100
					aSumIva[5,2] += PU->PuImpNeto
					aSumIva[5,4] -= PU->PuImpNeto
					aSumIva[6,2] += PU->PuImpNeto*PU->PuIvaRep/100
					aSumIva[6,4] -= PU->PuImpNeto*PU->PuIvaRep/100
				endif
			else
				if AScan(aCatGas,Rtrim(PU->PuCatGast)) != 0
					aSumGas[AScan(aCatGas,Rtrim(PU->PuCatGast)),2] += PU->PuImpNeto
					aSumGas[AScan(aCatGas,Rtrim(PU->PuCatGast)),4] -= PU->PuImpNeto
				endif
				if PU->PuIvaSop != 0
					aSumIva[3,2] += PU->PuImpNeto
					aSumIva[3,4] -= PU->PuImpNeto
					aSumIva[4,2] += PU->PuImpNeto*PU->PuIvaSop/100
					aSumIva[4,4] -= PU->PuImpNeto*PU->PuIvaSop/100
					aSumIva[5,2] += PU->PuImpNeto
					aSumIva[5,4] -= PU->PuImpNeto
					aSumIva[6,2] += PU->PuImpNeto*PU->PuIvaSop/100
					aSumIva[6,4] -= PU->PuImpNeto*PU->PuIvaSop/100
				endif
			endif
		endif
		PU->(DbSkip())
   enddo
   AP->(DbGoTop())
   while ! AP->(EoF())
		if dInicio <= AP->ApFecha .and. AP->ApFecha <= dFinal
			if AP->ApTipo == 'I'
				if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
					aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),3] += Ap->ApImpNeto
					aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),4] += Ap->ApImpNeto
				endif
				if AP->ApIvaRep != 0
					aSumIva[1,3] += Ap->ApImpNeto
					aSumIva[1,4] += Ap->ApImpNeto
					aSumIva[2,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
					aSumIva[2,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
					aSumIva[5,3] += Ap->ApImpNeto
					aSumIva[5,4] += Ap->ApImpNeto
					aSumIva[6,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
					aSumIva[6,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
				endif
			else
				if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
					aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),3] += AP->ApImpNeto
					aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),4] += Ap->ApImpNeto
				endif
				if AP->ApIvaSop != 0
					aSumIva[3,3] += Ap->ApImpNeto
					aSumIva[3,4] += Ap->ApImpNeto
					aSumIva[4,3] += Ap->ApImpNeto*Ap->ApIvaSop/100
					aSumIva[4,4] += Ap->ApImpNeto*Ap->ApIvaSop/100
					aSumIva[5,3] -= Ap->ApImpNeto
					aSumIva[5,4] -= Ap->ApImpNeto
					aSumIva[6,3] -= Ap->ApImpNeto*Ap->ApIvaSop/100
					aSumIva[6,4] -= Ap->ApImpNeto*Ap->ApIvaSop/100
				endif
			endif
		endif
		AP->(DbSkip())
   enddo

	Aadd(aListado,{"Ingresos","","",""})
	aIngPer := {"Total Ingresos",0,0,0}
	for i := 1 to Len(aSumIng)
		Aadd(aListado, aSumIng[i])
		aIngPer[2] += aSumIng[i,2]
		aIngPer[3] += aSumIng[i,3]
		aIngPer[4] += aSumIng[i,4]
		//aIngPer[5] += aSumIng[i,5]
		//aIngPer[6] += aSumIng[i,6]
	next
	Aadd(aListado,{"Gastos","","",""})
	aGasPer := {"Total Gastos",0,0,0}
	for i := 1 to Len(aSumGas)
		Aadd(aListado, aSumGas[i])
		aGasPer[2] += aSumGas[i,2]
		aGasPer[3] += aSumGas[i,3]
		aGasPer[4] += aSumGas[i,4]
		//aGasPer[5] += aSumGas[i,5]
		//aGasPer[6] += aSumGas[i,6]
	next
	Aadd(aListado,{"","","",""})
	Aadd(aListado, aIngPer)
	Aadd(aListado, aGasPer)
	//Aadd(aListado, {"Rendimiento", aIngPer[2]-aGasPer[2],aIngPer[3]-aGasPer[3],;
	//								       aIngPer[4]-aGasPer[4],aIngPer[5]-aGasPer[5],aIngPer[6]-aGasPer[6]})
	Aadd(aListado,{"","","",""})
	Aadd(aListado, aSumIva[1])
	Aadd(aListado, aSumIva[2])
	Aadd(aListado, aSumIva[3])
	Aadd(aListado, aSumIva[4])
	//Aadd(aListado, aSumIva[5])
	//Aadd(aListado, aSumIva[6])

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "PEAP", "" )
   oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
   REPORT oReport ;
      TITLE  " "," ","Desviación de presupuestos",iif(lFilter,"["+cActividad+"]","[Todas las actividades]"),;
         "Periodo "+Dtoc(dInicio)+' a '+Dtoc(dFinal) CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
      FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + " - Desviación de presupuestos en un periodo" PREVIEW
      i := 1
      COLUMN TITLE "Concepto"   	  DATA aListado[i,1] SIZE 35 FONT 1
      COLUMN TITLE "Presupuestos"  DATA aListado[i,2] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Apuntes"       DATA aListado[i,3] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Desviación (A-P)"    DATA aListado[i,4] SIZE 18 FONT 1 PICTURE "@E 999,999,999.99" RIGHT

   END REPORT

   oReport:Cargo := oInforme:cPdfFile

   if oReport:lCreated
      oReport:nTitleUpLine := RPT_SINGLELINE
      oReport:nTitleDnLine := RPT_SINGLELINE
      oReport:oTitle:aFont[3] := {|| 2 }
      oReport:nTopMargin   := 0.1
      oReport:nDnMargin    := 0.1
      oReport:nLeftMargin  := 0.1
      oReport:nRightMargin := 0.1
      oReport:oDevice:lPrvModal := .T.
   endif
   oReport:bSkip := {|| i++}
   ACTIVATE REPORT oReport WHILE i <= len(aListado)
   oInforme:End(.f.)

   oApp():nEdit --
   AP->(DbSetOrder(nApOrder))
   AP->(DbGoTo(nApRecno))
	PU->(DbSetOrder(nPuOrder))
   PU->(DbGoTo(nPuRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
//_______________________________________________________________________________//
