#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"
#include "AutoGet.ch"

STATIC oReport

function Apuntes()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "ApState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "ApOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "ApRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "ApSplit","102", oApp():cIniFile))
   local oCont
   local i
	local aActividad := {}
	local oAcMenu
	local bAction
	local oApMenu, oVMItem


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

   SELECT AP
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de apuntes')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "AP"

   aBrowse   := { { { || AP->ApActivida }, i18n("Actividad"), 150, AL_LEFT, NIL },;
						{ { || AP->ApFecha }, i18n("Fecha"), 150, AL_LEFT, NIL },;
                  { { || AP->ApNumero }, i18n("Apunte"), 80, AL_LEFT, NIL },;
                  { { || AP->ApConcepto }, i18n("Concepto"), 120, AL_LEFT, NIL },;
                  { { || AP->ApCuenta }, i18n("Cuenta"), 120, AL_LEFT, NIL },;
                  { { || AP->ApImpNeto }, i18n("Importe neto"), 120, AL_RIGHT, "@E 999,999.99" },;
						{ { || iif(AP->ApTipo=='I',AP->ApImpNeto*AP->ApIvaRep/100,AP->ApImpNeto*AP->ApIvaSop/100) }, i18n("IVA Rep./Sop."), 120, AL_RIGHT, "@E 999,999.99" },;
                  { { || AP->ApImpTotal }, i18n("Importe total"), 120, AL_RIGHT, "@E 999,999.99" },;
                  { { || IIF(AP->ApTipo=='I',AP->ApCliente,AP->ApProveed) }, i18n("Pagador / Perceptor"), 120, AL_LEFT, NIL },;
                  { { || IIF(AP->ApTipo=='I',AP->ApCatIngr,AP->ApCatGast) }, i18n("Tipo Ingreso / Gasto"), 120, AL_LEFT, NIL },;
                  { { || IIF(AP->ApTipo=='I',AP->ApMiFactur,AP->ApSuFactur) }, i18n("Mi Factura / Su Factura"), 120, AL_LEFT, NIL },;
						{ { || AP->ApCliente }, i18n("Pagador"), 120, AL_LEFT, NIL },;
						{ { || AP->ApCatIngr }, i18n("Tipo Ingreso"), 120, AL_LEFT, NIL },;
						{ { || AP->ApMiFactur }, i18n("Mi Factura"), 120, AL_LEFT, NIL },;
                  { { || AP->ApProveed  }, i18n("Perceptor"), 120, AL_LEFT, NIL },;
                  { { || AP->ApCatGast  }, i18n("Tipo Gasto"), 120, AL_LEFT, NIL },;
                  { { || AP->ApSuFactur }, i18n("Su Factura"), 120, AL_LEFT, NIL } }

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
		IF i == 6
         oCol:bFooter   := { || ApImpNetoSaldo() }
      END
      IF i == 9
         // oCol:bFooter   := { || ApImpIVASaldo() }
      END
      IF i == 8
         oCol:bFooter   := { || ApImpTotalSaldo() }
      END
   NEXT

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource("16_INGRESO")
   oCol:AddResource("16_GASTO")
	oCol:Cargo         := { || IIF(AP->ApTipo=='I',"Ingreso","Gasto") }
   oCol:cHeader       := i18n("Tipo")
   oCol:bBmpData      := { || IIF(AP->ApTipo=='I',1,2) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| IIF(AP->ApTipo=="I",;
												APIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu ),;
												APGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu )) }
		oCol:bPopUp        := { | o | ApBrwMenu( o, oApp():oGrid, oCont, oApp():oDlg, oAcMenu, aActividad ) }
   NEXT

	oApp():oGrid:SetRDD()
	oApp():oGrid:CreateFromCode()
	oApp():oGrid:bChange  := { || RefreshCont(oCont,"AP") }
	oApp():oGrid:bKeyDown := {|nKey| ApTecla(nKey,oApp():oGrid,oCont,oApp():oDlg, oAcMenu) }
	oApp():oGrid:nRowHeight  := 21
	oApp():oGrid:bClrStd := {|| { iif( AP->ApTipo == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
	oApp():oGrid:bClrRowFocus := { || { iif( AP->ApTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }	 
	oApp():oGrid:bClrSelFocus := { || { iif( AP->ApTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }
	oApp():oGrid:lFooter := .T.
   oApp():oGrid:bChange := {|| ( Refreshcont( oCont, "AP" ), oApp():oGrid:Refresh() ) }
   oApp():oGrid:Maketotals()
   // oApp():oGrid:bClrFooter := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
	oApp():oGrid:bClrFooter := {|| { CLR_GRAY, GetSysColor( 15 ) } }
	oApp():oGrid:RestoreState( cState )

   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 17 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
		CAPTION tran(AP->(OrdKeyNo()),'@E 999,999')+" / "+tran(AP->(OrdKeyCount()),'@E 999,999') ;
		HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
		IMAGE "BB_APUNTE"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 350 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar ;
      CAPTION "  apuntes" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo Ingreso"      ;
      IMAGE "16_INGRESO"           ;
      ACTION APIEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oAcMenu, aActividad );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo Gasto"        ;
      IMAGE "16_GASTO"             ;
      ACTION APGEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oAcMenu, aActividad );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar apunte"   ;
      IMAGE "16_modif"             ;
      ACTION IIF(AP->ApTipo=="I",;
					  APIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu, aActividad ),;
					  APGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu, aActividad ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar apunte"    ;
      IMAGE "16_duplica"           ;
      ACTION IIF(AP->ApTipo=="I",;
					  APIEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oAcMenu, aActividad ),;
					  APGEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oAcMenu, aActividad ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar apunte"      ;
      IMAGE "16_borrar"            ;
      ACTION APBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar apunte"      ;
      IMAGE "16_busca"             ;
      ACTION ApBusca(oApp():oGrid,,oCont,oApp():oDlg, oAcMenu)  ;
      LEFT 10

   MENU oAcMenu POPUP 2007
		MENUITEM "Todas las actividades" ;
			ACTION ( AP->(DbClearFilter()), ApUpdFilter( 0, oCont, oAcMenu, oBar, aActividad ));
			CHECKED
		SEPARATOR
		For i := 1 to Len(aActividad)
			bAction := ApFilter(aActividad, i, oCont, oAcMenu, oBar)
			MENUITEM RTrim(aActividad[i]) BLOCK bAction
		Next
	ENDMENU

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir apuntes"   ;
      IMAGE "16_imprimir"          ;
      MENU ApImpMenu(oApp():oGrid, oApp():oDlg, oAcMenu) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Balance de situación";
		IMAGE "16_BALANCE"           ;
		MENU ApBalMenu(oApp():oGrid, oApp():oDlg, oAcMenu, aActividad) ;
		LEFT 10

   // MENUITEM "Balance anual - por trimestres "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oAcMenu,aActividad, .f.)
   // MENUITEM "Balance anual - por trimestres con saldos"  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oAcMenu,aActividad,.t.)
   // MENUITEM "Balance anual - por meses "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualMens(oGrid,oParent,oAcMenu,aActividad, .f.)
   // MENUITEM "Balance total por periodo" RESOURCE "16_FECHA" ACTION ApBalPeriodo(oGrid,oParent,oAcMenu,aActividad)

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   //DEFINE VMENUITEM OF oBar        ;
	//	CAPTION "Filtrar por actividad" ;
	//	IMAGE "16_ACTIVIDAD"         ;
	//	MENU oAcMenu					  ;
	//	LEFT 10

	MENU oApMenu POPUP 2007
		MENUITEM "Sin filtro" ;
			ACTION ApFiltrar( 0, oCont, oApMenu, oBar, oVMItem );
			CHECKED
		SEPARATOR
      MENUITEM "Filtrar por actividad" ;
         ACTION ApFiltrar( 1, oCont, oApMenu, oBar, oVMitem )
		SEPARATOR
      MENUITEM "Filtrar ingresos"	;
         ACTION ApFiltrar( 2, oCont, oApMenu, oBar, oVMitem )
      MENUITEM "Filtrar por tipo de ingreso" ;
         ACTION ApFiltrar( 3, oCont, oApMenu, oBar, oVMitem )
		MENUITEM "Filtro por pagador" ;
         ACTION ApFiltrar( 4, oCont, oApMenu, oBar, oVMitem )
		SEPARATOR
		MENUITEM "Filtrar gastos"	;
			ACTION ApFiltrar( 5, oCont, oApMenu, oBar, oVMitem )
		MENUITEM "Filtro por tipo de gasto" ;
         ACTION ApFiltrar( 6, oCont, oApMenu, oBar, oVMitem )
		MENUITEM "Filtro por perceptor" ;
         ACTION ApFiltrar( 7, oCont, oApMenu, oBar, oVMitem )
		SEPARATOR
		MENUITEM "Filtro por cuenta bancaria" ;
         ACTION ApFiltrar( 8, oCont, oApMenu, oBar, oVMitem )
	ENDMENU

	DEFINE VMENUITEM oVMItem OF oBar  ;
      CAPTION "Filtrar apuntes"  	 ;
      IMAGE "16_FILTRO"              ;
      MENU oApMenu;
      LEFT 10


   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Crear apunte periódico" ;
		IMAGE "16_APERIODI"         ;
		ACTION ApCreaPer(oApp():oGrid, oApp():oDlg, oCont, oAcMenu) ;
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
		CAPTION "Anotar apuntes periódicos" ;
		IMAGE "16_PERIODICO"         ;
		ACTION ApAnotaPer(oApp():oGrid, oApp():oDlg, oCont, oAcMenu) ;
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Apuntes" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "ApState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS " Actividad ", " Fecha ", " Concepto ", " Cuenta ", " Tipo Ingreso ", " Pagador ", " Tipo Gasto ", " Perceptor ", " Apunte ";
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              AP->(DbSetOrder(nOrder)),;
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
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus(), ApBuscaPer(oApp():oGrid,oApp():oDlg,oCont,oAcMenu) );
      VALID ( oApp():oGrid:nLen := 0 ,;
              WritePProString("Browse","ApState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","ApOrder",Ltrim(Str(AP->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","ApRecno",Ltrim(Str(AP->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","ApSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := nil, oApp():oGrid := nil, oApp():oTab := nil, .t. )

return nil
/*_____________________________________________________________________________*/
function ApBrwMenu(oCol, oGrid, oCont, oDlg, oAcMenu, aActividad)
	local oPop

	MENU oPop POPUP 2007
		MENUITEM "Nuevo ingreso" RESNAME "16_INGRESO" ;
			ACTION APIEdita( oGrid, 1, oCont, oDlg, oAcMenu, aActividad )
		MENUITEM "Nuevo gasto"   RESNAME "16_GASTO" ;
			ACTION APGEdita( oGrid, 1, oCont, oDlg, oAcMenu, aActividad )
		MENUITEM "Modificar apunte"   RESNAME "16_MODIF" ;
   	   ACTION IIF(AP->ApTipo=="I",;
					  APIEdita( oGrid, 2, oCont, oDlg, oAcMenu, aActividad ),;
					  APGEdita( oGrid, 2, oCont, oDlg, oAcMenu, aActividad ))
      MENUITEM "Duplicar apunte"   RESNAME "16_DUPLICA" ;
   	   ACTION IIF(AP->ApTipo=="I",;
					  APIEdita( oGrid, 3, oCont, oApp():oDlg, oAcMenu, aActividad ),;
					  APGEdita( oGrid, 3, oCont, oApp():oDlg, oAcMenu, aActividad ))
		MENUITEM "Borrar apunte"   RESNAME "16_BORRAR" ;
   	   ACTION APBorra( oGrid, oCont )

		//SEPARATOR
	ENDMENU
return oPop
/*_____________________________________________________________________________*/

function ApFilter(aActividad, i, oCont, oAcMenu, oBar)
return { || AP->(DbSetFilter( {|| AP->ApActivida==aActividad[i] }, Str(i) )), ApUpdFilter(i, oCont, oAcMenu, oBar, aActividad) }

function ApUpdFilter(i, oCont, oAcMenu, oBar, aActividad)
	local j
	AP->(DbGoTop())
	RefreshCont(oCont,"AP")
	oApp():oGrid:Refresh(.t.)
	For j:=1 to Len(oAcMenu:aItems)
		oAcMenu:aItems[j]:SetCheck(.f.)
	Next
	if i==0
		oAcMenu:aItems[1]:SetCheck(.t.)
		oBar:cTitle := "apuntes"
	else
		oAcMenu:aItems[i+2]:SetCheck(.t.)
		oBar:cTitle := "apuntes ["+rtrim(aActividad[i])+"]"
	endif
	oBar:Refresh()
return nil

//---------------------------------------------------------------------------// function ApFiltrar( i, oCont, oMenu, oBar, oVMItem)
function ApFiltrar( i, oCont, oMenu, oBar, oVMItem)
   local cActividad:= space(60)
   local cCampo    := space(40)
	local cCuenta   := space(20)
   local j, k
   local aFiltro := {"Actividad", "Ingresos", "Tipo de ingreso", "Pagador", "Gastos", "Tipo de gasto", "Perceptor", "Cuenta bancaria"}
   
   if i == 0
      AP->(DbClearFilter())
		k := 1
   elseif i == 1
		Acseleccion( @cActividad, , oApp():oDlg, , , oVMItem )
      if cActividad != space(60)
      	AP->(DbSetFilter( { || Upper(AP->ApActivida) == Upper(cActividad) } ))
		else
 			AP->(DbClearFilter())
			i := 0
		endif
		k := 3
	elseif i == 2
		AP->(DbSetFilter( { || Upper(AP->ApTipo) == "I" } ))
		k := 5
	elseif i == 3
		InSeleccion( @cCampo, , oApp():oDlg, oVMItem )
		if cCampo != space(40)
			AP->(DbSetFilter( { || Upper(AP->ApCatIngr) == Upper(cCampo) } ))
		else
			AP->(DbClearFilter())
			i := 0
		endif
		k := 6
	elseif i == 4
		Clseleccion( @cCampo, , oApp():oDlg,oVMItem )
		if cCampo != space(40)
			AP->(DbSetFilter( { || Upper(AP->ApCliente) == Upper(cCampo) } ))
		else
			AP->(DbClearFilter())
			i := 0
		endif
		k := 7
	elseif i == 5
		AP->(DbSetFilter( { || Upper(AP->ApTipo) == "G" } ))
		k := 9
	elseif i == 6
		GaSeleccion( @cCampo, , oApp():oDlg, oVMItem )
		if cCampo != space(40)
			AP->(DbSetFilter( { || Upper(AP->ApCatGast) == Upper(cCampo) } ))
		else
			AP->(DbClearFilter())
			i := 0
		endif
		k := 10
	elseif i == 7
		Prseleccion( @cCampo, , oApp():oDlg, oVMItem )
		if cCampo != space(40)
			AP->(DbSetFilter( { || Upper(AP->ApProveed) == Upper(cCampo) } ))
		else
			AP->(DbClearFilter())
			i := 0
		endif
		k := 11
	elseif i == 8
		Ccseleccion( @cCuenta, , oApp():oDlg, oVMItem )
		if cCuenta != space(20)
			AP->(DbSetFilter( { || Upper(AP->ApCuenta) == Upper(cCuenta) } ))
		else
			AP->(DbClearFilter())
			i := 0
		endif
		k := 13
	endif

	AP->(DbGoTop())
	RefreshCont(oCont,"AP")
	oApp():oGrid:Refresh(.t.)
	For j:=1 to Len(oMenu:aItems)
		oMenu:aItems[j]:SetCheck(.f.)
	Next
	if i==0
		oMenu:aItems[1]:SetCheck(.t.)
		oBar:cTitle := "apuntes"
	else
		oMenu:aItems[k]:SetCheck(.t.)
		oBar:cTitle := "apuntes ["+rtrim(aFiltro[i])+"]"
	endif
	oBar:Refresh()
return nil
//_____________________________________________________________________________//


function APIEdita(oGrid, nMode, oCont, oParent, oAcMenu, aActividad)
   local lCont := nMode == 1
   APIEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu,aActividad)
   do while lCont
      APIEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu,aActividad)
   enddo
return NIL
function APIEdita1(oGrid,nMode,oCont,oParent,lCont,oAcMenu,aActividad,dPeFecha)
   local oDlg
   local aTitle   := { i18n( "Añadir un ingreso" ) ,;
                     i18n( "Modificar un ingreso") ,;
                     i18n( "Duplicar un ingreso") 	,;
		               i18n( "Anotar ingreso periódico") }
   local aGet[22]
	local lAcIVA	:= .t. // indica si la actividad gestiona IVA
	local lAcREquiv:= .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)

   local cApNumero   ,;
			cApActivida ,;
         cApConcepto ,;
			cApCuenta	,;
         dApFecha    ,;
         nApImpNeto  ,;
         cApObserv   ,;
         cApCliente  ,;
         cApCatIngr  ,;
         cApMiFactur ,;
         cApIvaRep   ,;
         cApRecIng   ,;
         nApGastosFi ,;
         nApImpTotal
   local nTIVA, nTRecEq
   local nRecPtr  := AP->(RecNo())
   local nOrden   := AP->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local lFilter	:= .f.
	local i
	local lFecha

   if AP->(EOF()) .AND. nMode > 1 .AND. nMode < 4
      retu NIL
   endif
   oApp():nEdit ++

	if oAcMenu != nil
		if (! oAcMenu:aItems[1]:lChecked)
			lFilter := .t.
		endif
	endif

   if nMode == 4
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
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

   if nMode == 1
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
   endif
	cApNumero   := iif(nMode==2,AP->ApNumero,ApSiguiente(aActividad))
   dApFecha    := iif(nMode==2,AP->ApFecha,iif(nMode==4,PE->PeFProximo,date()))
   cApConcepto := AP->ApConcepto
	cApCuenta	:= AP->ApCuenta
	cApActivida := iif(nMode==1,oApp():cActividad,AP->ApActivida)
   nApImpNeto  := AP->ApImpNeto
   cApObserv   := AP->ApObserv
   cApCliente  := AP->ApCliente
   cApCatIngr  := AP->ApCatIngr
   cApMiFactur := AP->ApMiFactur
   cApIvaRep   := TRAN(AP->ApIvaRep,"@E99.99")
   nApImpTotal := AP->ApImpTotal
   nApGastosFi := AP->ApGastosFi
   cApRecIng  := TRAN(AP->ApRecIng,"@E99.99")
   nTIVA       := nApImpNeto * VAL(cApIvaRep) / 100
   nTRecEq     := nApImpNeto * VAL(cApRecIng) / 100

	if nMode != 1
		AC->( DbSetOrder( 2 ) )
		AC->( DbGoTop() )
		AC->(DbSeek(Upper(cApActivida)))
		lAcIva := AC->AcIva
		lAcREquiv := AC->AcREquiv
	else
		if lFilter
			for i:=1 to Len(oAcMenu:aItems)
				if oAcMenu:aItems[i]:lChecked
					cApActivida := oAcMenu:aItems[i]:cPrompt
				endif
			next
		endif
	endif

   if nMode == 3
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
      // cApNumero := ApSiguiente(aActividad)
   endif

	DEFINE DIALOG oDlg RESOURCE "APIEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE AUTOGET aGet[19] VAR cApActivida	;
		DATASOURCE {}						;
		FILTER AcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 119 OF oDlg UPDATE            		;
		VALID AcClave( cApActivida, aGet[19], 4, aGet, @lAcIVA, @lAcREquiv );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;
		WHEN ! lFilter

   REDEFINE BUTTON aGet[20] ID 120 OF oDlg ;
		ACTION AcSeleccion( cApActivida, aGet[19], oDlg, aGet, @lAcIVA, @lAcREquiv ) ;
		WHEN ! lFilter

   REDEFINE GET aGet[1] VAR dApFecha   ;
      ID 101 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION SelecFecha(@dApFecha,aGet[1])

   REDEFINE GET aGet[3] VAR cApMiFactur;
      ID 103 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE
   REDEFINE BUTTON aGet[4] ID 104 OF oDlg ;
      ACTION MsgInfo("Generar número de factura")

   REDEFINE AUTOGET aGet[5] VAR cApCliente ;
		DATASOURCE {}						;
		FILTER ClList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE                ;
      VALID ClClave( cApCliente, aGet[5], 4, 1 );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK
   REDEFINE BUTTON aGet[6] ID 106 OF oDlg ;
      ACTION ClSeleccion( cApCliente, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[7] VAR cApCatIngr ;
		DATASOURCE {}						;
		FILTER InList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 107 OF oDlg UPDATE            ;
      VALID InClave( cApCatIngr, aGet[7], 4, 2 );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK
   REDEFINE BUTTON aGet[8] ID 108 OF oDlg ;
      ACTION InSeleccion( cApCatIngr, aGet[7], oDlg )

   REDEFINE AUTOGET aGet[21] VAR cApCuenta	;
		DATASOURCE {}						;
		FILTER CcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 121 OF oDlg UPDATE            		;
		VALID CcClave( cApCuenta, aGet[21], 4, aGet );
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[22] ID 122 OF oDlg ;
		ACTION ccSeleccion( cApCuenta, aGet[21], oDlg, aGet )

	REDEFINE AUTOGET aGet[18] VAR cApConcepto	;
		DATASOURCE {}						;
		FILTER ApCList( uDataSource, cData, Self, 'I' );     
		HEIGHTLIST 100 ;
		ID 118 OF oDlg UPDATE            		;
      COLOR oApp():cClrIng, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE GET aGet[9] VAR nApImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 109 OF oDlg                   ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[9]:bValid := { || ApRecalc(nApImpNeto, cApIvaRep, @nTIVA, cApRecIng, @nTRecEq, @nApImpTotal, aGet, oDlg, .f.) }
   aGet[9]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[9] ), .T. ) }

   REDEFINE COMBOBOX aGet[10] VAR cApIvaRep ITEMS aIVA ;
      ID 110 OF oDlg ;
      ON CHANGE ApRecalc(nApImpNeto, cApIvaRep, @nTIVA, cApRecIng, @nTRecEq, @nApImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrIng, CLR_WHITE	;
		WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTIVA    ;
      ID 111 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cApRecIng ITEMS aRecEq ;
      ID 112 OF oDlg ;
      ON CHANGE ApRecalc(nApImpNeto, cApIvaRep, @nTIVA, cApRecIng, @nTRecEq, @nApImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrIng, CLR_WHITE ;
		WHEN lAcREquiv

   REDEFINE GET aGet[13] VAR nTRecEq   ;
      ID 113 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[14] VAR nApImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 114 OF oDlg UPDATE               ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[14]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[14] ), .T. ) }

   REDEFINE BUTTON aGet[17] ID 117 OF oDlg ;
      ACTION ApRecalc(@nApImpNeto, cApIvaRep, @nTIVA, cApRecIng, @nTRecEq, nApImpTotal, aGet, oDlg, .t.) ;
		WHEN lAcIva
   aGet[17]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nApGastosFi  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 115 OF oDlg UPDATE               ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[16] VAR cApObserv    ;
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
		IF nMode == 2
         AP->( dbGoto( nRecPtr ) )
         // quito el anterior ingreso
         CcDisposic(AP->ApCuenta, AP->ApImpTotal, dApFecha)
         // pongo el nuevo ingreso
         CcIngreso(cApCuenta, nApImpTotal, dApFecha )
         IF AP->ApCatIngr != cApCatIngr
            In1Menos( AP->ApCatIngr, 'A', AP->ApImpTotal )
            In1Mas( cApCatIngr, 'A', nApImpTotal )
         ENDIF
         IF AP->ApCliente != cApCliente
            Cl1Menos( AP->ApCliente, 'A', AP->ApImpTotal )
            Cl1Mas( cApCliente, 'A', nApImpTotal )
         ENDIF
      ELSE
         // es un apunte nuevo
         CcIngreso(cApCuenta, nApImpTotal, dApFecha )
         In1Mas( cApCatIngr, 'A', nApImpTotal )
         Cl1Mas( cApCliente, 'A', nApImpTotal )
         AP->( dbGoto( nRecAdd ) )
      ENDIF

      // ___ guardo el registro _______________________________________________//
      Replace AP->ApNumero	  with cApNumero
		Replace AP->ApTipo     with "I"
      Replace AP->ApFecha    with dApFecha
      Replace AP->ApConcepto with cApConcepto
		Replace AP->ApActivida with cApActivida
		Replace AP->ApCuenta	  with cApCuenta
      Replace AP->ApImpNeto  with nApImpNeto
      Replace AP->ApObserv   with cApObserv
      Replace AP->ApCliente  with cApCliente
      Replace AP->ApCatIngr  with cApCatIngr
      Replace AP->ApMiFactur with cApMiFactur
      Replace AP->ApIvaRep   with VAL(StrTran(cApIvaRep,",","."))
      Replace AP->ApImpTotal with nApImpTotal
      Replace AP->ApGastosFi with nApGastosFi
      Replace AP->ApRecIng  with VAL(StrTran(cApRecIng,",","."))
      AP->(DbCommit())
		if nMode != 2
      	SetIni(oApp():cIniFile, "Config", "SiguienteApunte", cApNumero )
		endif
		if nMode == 4
			dPeFecha := dApFecha
		endif

   else
      lReturn := .f.
      if nMode != 2
         AP->(DbGoTo(nRecAdd))
         AP->(DbDelete())
         AP->(DbPack())
         AP->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT AP
   if oCont != NIL
      RefreshCont(oCont,"AP")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//
function APGEdita(oGrid,nMode,oCont,oParent,oAcMenu,aActividad)
   local lCont := nMode == 1

   APGEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu,aActividad)
   do while lCont
      APGEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu,aActividad)
   enddo

return NIL
//-----------------------------------------------------------------------//
function APGEdita1(oGrid,nMode,oCont,oParent,lCont,oAcMenu,aActividad,dPeFecha)
   local oDlg
   local aTitle   := { i18n( "Añadir un gasto" )   ,;
                       i18n( "Modificar un gasto") ,;
                       i18n( "Duplicar un gasto")  ,;
	                    i18n( "Anotar gasto periódico"),;
 	                    i18n( "Anotar gasto de inventario") }
   local aGet[22]
	local lAcIVA 	:= .t.
	local lAcREquiv:= .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)

   local cApNumero   ,;
         dApFecha    ,;
         cApConcepto ,;
			cApCuenta	,;
         nApImpNeto  ,;
         cApObserv   ,;
         cApProveed  ,;
         cApCatGast  ,;
         cApSuFactur ,;
         cApIvaSop   ,;
         cApRecGas   ,;
         nApGastosFi ,;
         nApImpTotal	,;
			cApActivida
   local nTIVA, nTRecEq
   local nRecPtr  := AP->(RecNo())
   local nOrden   := AP->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local lFilter	:= .f.
	local i
	local lFecha

   if AP->(EOF()) .AND. nMode > 1 .AND. nMode < 4
      retu NIL
   endif
   oApp():nEdit ++

	if oAcMenu != nil
		if (! oAcMenu:aItems[1]:lChecked)
			lFilter := .t.
		endif
	endif

   if nMode == 1
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
   endif
	if nMode == 4
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
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
	elseif nMode == 5
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
		AP->ApConcepto	:= BI->BiDenomi
		AP->ApObserv	:= BI->BiObserv
		AP->ApProveed	:= BI->Bitienda
		AP->ApCatGast	:= BI->BiCategor
		AP->ApImpTotal	:= BI->BiPrecio
		AP->ApFecha    := BI->BiFCompra
	endif
	cApNumero   := iif(nMode==2,AP->ApNumero,ApSiguiente(aActividad))
   dApFecha    := iif(nMode==2,AP->ApFecha,iif(nMode==4,PE->PeFProximo,date()))
   cApConcepto := AP->ApConcepto
	cApActivida := iif(nMode==1.or.nMode==5,oApp():cActividad,AP->ApActivida)
	cApCuenta	:= AP->ApCuenta
   nApImpNeto  := AP->ApImpNeto
   cApObserv   := AP->ApObserv
   cApProveed  := AP->ApProveed
   cApCatGast  := AP->ApCatGast
   cApSuFactur := AP->ApSuFactur
   cApIvaSop   := Tran(AP->ApIvaSop,"@E99.99")
   nApImpTotal := AP->ApImpTotal
   nApGastosFi := AP->ApGastosFi
   cApRecGas   := Tran(AP->ApRecGas,"@E99.99")
   nTIVA       := nApImpNeto * VAL(cApIvaSop) / 100
   nTRecEq     := nApImpNeto * VAL(cApRecGas) / 100

	// asigno al actividad en caso de filtro
	if nMode != 1
		AC->( DbSetOrder( 2 ) )
		AC->( DbGoTop() )
		AC->(DbSeek(Upper(cApActivida)))
		lAcIva 	 := AC->AcIva
		lAcREquiv := AC->AcREquiv
	else
		if lFilter
			for i:=1 to Len(oAcMenu:aItems)
				if oAcMenu:aItems[i]:lChecked
					cApActivida := oAcMenu:aItems[i]:cPrompt
				endif
			next
		endif
	endif

   if nMode == 3
      AP->(DbAppend())
      nRecAdd := AP->(RecNo())
      // cApNumero := ApSiguiente(aActividad)
   endif

   DEFINE DIALOG oDlg RESOURCE "APGEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

	REDEFINE AUTOGET aGet[19] VAR cApActivida	;
		DATASOURCE {}						;
		FILTER AcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 119 OF oDlg UPDATE            		;
		VALID AcClave( cApActivida, aGet[19], 4, aGet, @lAcIVA, @lAcREquiv );
      COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK ;
		WHEN ! lFilter
   REDEFINE BUTTON aGet[20] ID 120 OF oDlg ;
		ACTION AcSeleccion( cApActivida, aGet[19], oDlg, aGet, @lAcIVA, @lAcREquiv );
		WHEN ! lFilter

   REDEFINE GET aGet[1] VAR dApFecha   ;
      ID 101 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[2] ID 102 OF oDlg ;
      ACTION SelecFecha(@dApFecha,aGet[1])

   REDEFINE GET aGet[3] VAR cApSuFactur;
      ID 103 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE AUTOGET aGet[5] VAR cApProveed ;
		DATASOURCE {}						;
		FILTER PrList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE                ;
      VALID PrClave( cApProveed, aGet[5], 4, 1 );
		COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[6] ID 106 OF oDlg ;
      ACTION PrSeleccion( cApProveed, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[7] VAR cApCatGast ;
		DATASOURCE {}						;
		FILTER GaList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 107 OF oDlg UPDATE                ;
      VALID GaClave( cApCatGast, aGet[7], 4, 2 );
		COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[8] ID 108 OF oDlg ;
      ACTION GaSeleccion( cApCatGast, aGet[7], oDlg )

   REDEFINE AUTOGET aGet[21] VAR cApCuenta	;
		DATASOURCE {}						;
		FILTER CcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 121 OF oDlg UPDATE            		;
		VALID CcClave( cApCuenta, aGet[21], 4, aGet );
		COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[22] ID 122 OF oDlg ;
		ACTION ccSeleccion( cApCuenta, aGet[21], oDlg, aGet )

	REDEFINE AUTOGET aGet[18] VAR cApConcepto	;
		DATASOURCE {}						;
		FILTER ApCList( uDataSource, cData, Self, 'G' );     
		HEIGHTLIST 100 ;
		ID 118 OF oDlg UPDATE            		;
      COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE GET aGet[9] VAR nApImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 109 OF oDlg                   ;
      COLOR oApp():cClrGas, CLR_WHITE
	aGet[9]:bValid := { || CcHaySaldo(cApCuenta,nApImpNeto,nMode,AP->ApCuenta,AP->ApImpNeto,cApIvaSop,nTIVA,cApRecGas,nTRecEq,nApImpTotal,aGet,oDlg) }
   aGet[9]:bKeyDown   := {|nKey| IIF(nKey == VK_SPACE, ShowCalculator(aGet[9]), .T.) }

   REDEFINE COMBOBOX aGet[10] VAR cApIvaSop ITEMS aIVA ;
      ID 110 OF oDlg ;
      ON CHANGE ApRecalc(nApImpNeto, cApIvaSop, @nTIVA, cApRecGas, @nTRecEq, @nApImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrGas, CLR_WHITE	;
		WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTIVA    ;
      ID 111 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cApRecGas ITEMS aRecEq ;
      ID 112 OF oDlg ;
      ON CHANGE ApRecalc(nApImpNeto, cApIvaSop, @nTIVA, cApRecGas, @nTRecEq, @nApImpTotal, aGet, oDlg, .f.);
      COLOR oApp():cClrGas, CLR_WHITE ;
		WHEN lAcREquiv

   REDEFINE GET aGet[13] VAR nTRecEq   ;
      ID 113 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[14] VAR nApImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 114 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE
   aGet[14]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[14] ), .T. ) }

   REDEFINE BUTTON aGet[17] ID 117 OF oDlg ;
      ACTION ApRecalc(@nApImpNeto, cApIvaSop, @nTIVA, cApRecGas, @nTRecEq, nApImpTotal, aGet, oDlg, .t.) ;
		WHEN lAcIva UPDATE
   aGet[17]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nApGastosFi  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 115 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[16] VAR cApObserv    ;
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
		IF nMode == 2
         AP->( dbGoto( nRecPtr ) )
         // quito el anterior gasto
         CcIngreso(AP->ApCuenta, AP->ApImpTotal, dApFecha )
         // pongo el nuevo gasto
         CcDisposic(cApCuenta, nApImpTotal, dApFecha )
         IF AP->ApCatGast != cApCatGast
            Ga1Menos( AP->ApCatGast, 'A', AP->ApImpTotal )
            Ga1Mas( cApCatGast, 'A', nApImpTotal )
         ENDIF
         IF AP->ApProveed != cApProveed
            Pr1Menos( AP->ApProveed, 'A', AP->ApImpTotal )
            Pr1Mas( cApProveed, 'A', nApImpTotal )
         ENDIF
      ELSE
         // pongo el nuevo gasto
         CcDisposic(cApCuenta, nApImpTotal, dApFecha )
         Ga1Mas( cApCatGast, 'A', nApImpTotal )
         Pr1Mas( cApProveed, 'A', nApImpTotal )
         AP->( dbGoto( nRecAdd ) )
      ENDIF

      // guardo el registro _______________________________________________//
      Replace AP->ApNumero	  with cApNumero
      Replace AP->ApTipo     with "G"
      Replace AP->ApFecha    with dApFecha
      Replace AP->ApConcepto with cApConcepto
		Replace AP->ApActivida with cApActivida
		Replace AP->ApCuenta	  with cApCuenta
      Replace AP->ApImpNeto  with nApImpNeto
      Replace AP->ApObserv   with cApObserv
      Replace AP->ApProveed  with cApProveed
      Replace AP->ApCatGast  with cApCatGast
      Replace AP->ApSuFactur with cApSuFactur
      Replace AP->ApIvaSop   with VAL(StrTran(cApIvaSop,",","."))
      Replace AP->ApImpTotal with nApImpTotal
      Replace AP->ApGastosFi with nApGastosFi
      Replace AP->ApRecGas   with VAL(StrTran(cApRecGas,",","."))
      AP->(DbCommit())
		if nMode != 2
      	SetIni(oApp():cIniFile, "Config", "SiguienteApunte", cApNumero )
		endif
		if nMode == 4
			dPeFecha := dApFecha
		endif
   else
      lReturn := .f.
      if nMode != 2
         AP->(DbGoTo(nRecAdd))
         AP->(DbDelete())
         AP->(DbPack())
         AP->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT AP
   if oCont != NIL
      RefreshCont(oCont,"AP")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn

/*_____________________________________________________________________________*/

function ApBorra(oGrid,oCont)
   local nRecord := AP->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este "+iif(AP->ApTipo=="I","ingreso","gasto")+" ?")+CRLF+;
               "Fecha: "+DtoC(AP->ApFecha)+" Importe: "+tran(AP->ApImpTotal,"@E 999,999.99") )
		SELECT CC
		CC->(OrdSetFocus(1))
		if CC->(DbSeek(Upper(AP->ApCuenta)))
			if AP->ApTipo == "I"
				Replace CC->CcSaldoAc with CC->CcSaldoAc - AP->ApImpTotal
			else
				Replace CC->CcSaldoAc with CC->CcSaldoAc + AP->ApImpTotal
			endif
		endif
      SELECT AP
      AP->(DbSkip())
      nNext := AP->(Recno())
      AP->(DbGoto(nRecord))
      AP->(DbDelete())
      AP->(DbPack())
      AP->(DbGoto(nNext))
      if AP->(EOF()) .or. nNext == nRecord
         AP->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"AP")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
//-----------------------------------------------------------------------//

function APTecla(nKey,oGrid,oCont,oDlg,oAcMenu)
Do case
   case nKey==VK_RETURN
      if AP->ApTipo == "I"
         ApIEdita(oGrid,2,oCont,oDlg,oAcMenu)
      else
         ApGEdita(oGrid,2,oCont,oDlg,oAcMenu)
      endif
   case nKey==VK_DELETE
      ApBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
EndCase
return nil
//-----------------------------------------------------------------------//

function ApBusca( oGrid, cChr, oCont, oParent, oAcMenu )

   local nOrder   := AP->(OrdNumber())
   local nRecno   := AP->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
	TITLE i18n("Búsqueda de apuntes")
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
			REDEFINE SAY PROMPT i18n( "Introduzca la cuenta" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Cuenta:" ) ID 21 OF Odlg
			cGet := space(20)
			exit
		case 5
			REDEFINE SAY PROMPT i18n( "Introduzca el tipo de ingreso" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Tipo Ingreso:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 6
			REDEFINE SAY PROMPT i18n( "Introduzca el pagador" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Pagador:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 7
			REDEFINE SAY PROMPT i18n( "Introduzca el tipo de gasto" ) ID 20 OF oDlg
			REDEFINE SAY PROMPT i18n( "Tipo Gasto:" ) ID 21 OF Odlg
			cGet := space(40)
			exit
		case 8
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
		oGet:bGotFocus := { || ( oGet:SetColor( CLR_BLACK, RGB(255,255,127) ), oGet:SetPos(2) ) }
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
			{ || ApWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
			CursorArrow()
			if len(aBrowse) == 0
				MsgStop("No se ha encontrado ningun apunte")
				AP->(DbGoTo(nRecno))
				else
				ApEncontrados(aBrowse, oApp():oDlg, oAcMenu)
			endif
			else
			if ! AP->(DbSeek(DtoS(cGet)))
				msgAlert( i18n( "Apunte no encontrado." ) )
				AP->(DbGoTo(nRecno))
			endif
		endif
	endif

	AP->(OrdSetFocus(nOrder))

	RefreshCont( oCont, "AP" )
	oGrid:refresh()
	oGrid:setFocus()
	oApp():nEdit--

return NIL
//-----------------------------------------------------------------------//

function ApWildSeek(nOrder, cGet, aBrowse)
   local nRecno := AP->(Recno())

   switch nOrder
	case 1
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApActivida)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 3
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApConcepto)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 4
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApCuenta)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 5
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApCatIngr)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 6
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApCliente)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 7
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApCatGast)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	case 8
		AP->(DbGoTop())
		do while ! AP->(Eof())
			if cGet $ upper(AP->ApProveed)
				aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApTipo, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno()) })
			endif
			AP->(DbSkip())
		enddo
		exit
	end
	AP->(DbGoTo(nRecno))
	// ordeno la tabla por el 1 elemento
	ASort( aBrowse,,, { |aAut1, aAut2| DtoS(aAut1[1]) < DtoS(aAut2[1]) } )
return nil
//-----------------------------------------------------------------------//

function APEncontrados(aBrowse, oParent, oAcMenu)
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
	oBrowse:bClrSelFocus := {|| { CLR_WHITE, iif( aBrowse[oBrowse:nArrayAt,3] == "I", oApp():cClrIng, oApp():cClrGas ) } }
   oBrowse:lHScroll  := .f.
   oBrowse:nRowHeight:= 20

   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
		aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||AP->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])),;
			IIF(AP->ApTipo=='I',;
			APIEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu ),;
			APGEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu )),;
		AP->(DbGoTo(aBrowse[oBrowse:nArrayAt,6])) } })
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,AP->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])),;
		IIF(AP->ApTipo=='I',;
		APIEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu ),;
	APGEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu )))}
   oBrowse:bChange    := { || AP->(DbGoTo(aBrowse[oBrowse:nArrayAt, 6])) }

   oDlg:oClient := oBrowse

   REDEFINE BUTTON oBtnOk ;
	ID IDOK OF oDlg     ;
	ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
	ID IDCANCEL OF oDlg ;
	ACTION (AP->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
	ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

//-----------------------------------------------------------------------//
function ApBuscaPer( oGrid, oParent, oCont, oAcMenu )
	local nRecno := AP->(Recno())
	local lEncontrado := .f.

	if ! oApp():lChkPeriod
		retu nil
	endif

	Select PE
	PE->(DbGoTop())
	do while ! PE->(EoF()) .and. ! lEncontrado
		if PE->PeFProximo <= Date() .and. DtoC(PE->PeFProximo)!="  -  -    "
			lEncontrado := .t.
		endif
		PE->(DbSkip())
	enddo
	AP->(DbGoTo(nRecno))

	if lEncontrado
		if MsgYesNo("Hay apuntes periódicos pendientes de anotar."+CRLF+"¿ Desea anotarlos ahora ?")
			ApAnotaPer( oGrid, oParent, oCont, oAcMenu )
		endif
	endif
return nil
//-----------------------------------------------------------------------//
function ApCreaPer( oGrid, oParent, oCont, oAcMenu )
   if msgYesNo("¿ Desea crear un apunte periódico a partir del apunte actual ?")
		PE->(DbAppend())
		Replace PE->PeTipo     with AP->ApTipo
      Replace PE->PeConcepto with AP->ApConcepto
      Replace PE->PeActivida with AP->ApActivida
		Replace PE->PeCuenta	  with AP->ApCuenta
      Replace PE->PeImpNeto  with AP->ApImpNeto
      Replace PE->PeObserv   with AP->ApObserv
      Replace PE->PeCliente  with AP->ApCliente
      Replace PE->PeImpTotal with AP->ApImpTotal
      Replace PE->PeGastosFi with AP->ApGastosFi
      Replace PE->PePeriodic with 1
      Replace PE->PeMeses    with '000000000000'
		if AP->ApTipo == 'I'
      	Replace PE->PeCatIngr  with AP->ApCatIngr
      	Replace PE->PeIvaRep   with AP->ApIvaRep
      	Replace PE->PeRecIng   with AP->ApRecIng
			PeIEdita1(,4,,oParent,.f.,oAcMenu)
		else
			Replace PE->PeCatGast  with AP->ApCatGast
			Replace PE->PeIvaSop   with AP->ApIvaSop
			Replace PE->PeRecGas   with AP->ApRecGas
			PeGEdita1(,4,,oParent,.f.,oAcMenu)
		endif
	endif
return nil
//-----------------------------------------------------------------------//
function ApAnotaPer( oGrid, oParent, oCont, oAcMenu )
   local oDlg, oBrowse, oBtnNext, oBtnCancel, lOk, i
   local nRecno := AP->(Recno())
	local aBrowse := {}

	Select PE
	PE->(DbGoTop())
	do while ! PE->(EoF())
		if PE->PeFProximo <= Date() .and. DtoC(PE->PeFProximo)!= '  -  -    '
			aadd(aBrowse,{PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno())})
		endif
		PE->(DbSkip())
	enddo

	if Len(aBrowse)==0
		MsgAlert("No hay apuntes periódicos pendientes de anotar.")
		retu nil
	endif

	oApp():nEdit ++
   DEFINE DIALOG oDlg RESOURCE "APPERIOD1" ;
		TITLE i18n( "Anotación de apuntes periódicos" ) ;
		OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
	oBrowse:aCols[1]:cHeader  := "Fecha Ap."
	oBrowse:aCols[1]:nWidth   := 62
   oBrowse:aCols[2]:cHeader  := "Actividad"
   oBrowse:aCols[2]:nWidth   := 110
   oBrowse:aCols[3]:cHeader  := "I/G"
   oBrowse:aCols[3]:nWidth   := 30
   oBrowse:aCols[4]:cHeader  := "Concepto"
   oBrowse:aCols[4]:nWidth   := 170
   oBrowse:aCols[5]:cHeader  := "Importe"
   oBrowse:aCols[5]:nWidth   := 75
   oBrowse:aCols[5]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[5]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[6]:lHide    := .t.
   oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,3] == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
   oBrowse:lHScroll  := .f.
   oBrowse:nRowHeight:= 20

   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
	oDlg:oClient := oBrowse

	REDEFINE BUTTON oBtnNext	;
		ID IDOK OF oDlg     		;
		ACTION oDlg:end(IDOK)

   REDEFINE BUTTON oBtnCancel ;
		ID IDCANCEL OF oDlg 		;
		ACTION oDlg:end(IDCANCEL)

   ACTIVATE DIALOG oDlg ;
		ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
		for i := 1 to Len(aBrowse)
			ApAnotaPer2(oGrid, oParent, aBrowse[i], oCont, oAcMenu)
		next
	endif
	oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif
return nil

function ApAnotaPer2(oGrid, oParent, aBrowse, oCont, oAcMenu)
	local dFecha := CtoD('')
	local i, nProximoMes
	local lOk := .f.
	local cPeMeses
	PE->(DbGoTo(aBrowse[6]))
	if aBrowse[3]=='I'
		lOk := APIEdita1(oGrid,4,oCont,oParent,.f.,oAcMenu,,@dFecha)
	else
		lOk := APGEdita1(oGrid,4,oCont,oParent,.f.,oAcMenu,,@dFecha)
	endif
	if lOk
		// se ha anotado el apunte, tengo que asignar proxima fecha
		Select PE
		Replace PE->PeFUltimo  With PE->PeFProximo
		if PE->PePeriodic == 1
			// periodicidad anual
			dFecha := CtoD(SubStr(DtoC(dFecha),1,6)+Str(Year(dFecha)+1,4))
			Replace PE->PeFProximo With dFecha
		else
			// otra periodicidad
			cPeMeses := PE->PeMeses
			nProximoMes := ApPeSigMes(Month(dFecha), cPeMeses)
			? nProximoMes
			if Month(dFecha) < nProximoMes
				// el proximo apunte está en el mismo año
				dFecha := Str(Day(dFecha),2)+'/'+Str(nProximoMes,2)+'/'+Str(Year(dFecha),4)
				Replace PE->PeFProximo With CtoD(dFecha)
			else
				//
				dFecha := Str(Day(dFecha),2)+'/'+Str(nProximoMes,2)+'/'+Str(Year(dFecha)+1,4)
				Replace PE->PeFProximo With CtoD(dFecha)
			endif
			/*
			i := Month(dFecha) + 1
			? i
			do while i!=Month(dFecha) .and. SubStr(cPeMeses,i,1)=='0'
				if i>12
					i:= 1
				else
					i++
				endif
			enddo
			? i
			if i==Month(dFecha)
				MsgAlert("Por favor, revise los meses de anotación del apunte periódico.")
				Replace PE->PeFProximo With CtoD('')
			else
				if Day(dFecha)==31
					dFecha := dFecha - 1
				endif
				if i>Month(dFecha)
					// el proximo apunte está en el mismo año
					dFecha := Str(Day(dFecha),2)+'/'+Str(i,,,.t.)+'/'+Str(Year(dFecha),,,.t.)
					Replace PE->PeFProximo With CtoD(dFecha)
				else
					dFecha := Str(Day(dFecha),2)+'/'+Str(i,,,.t.)+'/'+Str(Year(dFecha)+1,,,.t.)
					Replace PE->PeFProximo With CtoD(dFecha)
				endif
				? PE->PeFProximo
			endif
			*/
		endif
	endif
return nil
//-----------------------------------------------------------------------------//
function ApPeSigMes(i, cMeses)
	local nRet, j
	nRet := 0
	for j := i + 1 to 12
		if SubStr(cMeses, j, 1) == '1' .and. nRet == 0
			nRet := j
		endif
	next
	if nRet == 0
		for j := 1 to i - 1
			if SubStr(cMeses, j, 1) == '1' .and. nRet == 0
				nRet := j
			endif
		next
	endif
return nRet
//-----------------------------------------------------------------------------//
function ApImpMenu(oGrid, oParent, oAcMenu)
	local oPopup
   MENU oPopup POPUP 2007
      MENUITEM "Impresión de apuntes"  RESOURCE "16_APUNTES" ACTION ApApImprime(oGrid, oParent, oAcMenu)
      MENUITEM "Impresión de ingresos" RESOURCE "16_INGRESO" ACTION ApInImprime(oGrid, oParent, oAcMenu)
      MENUITEM "Impresión de gastos"   RESOURCE "16_GASTO"   ACTION ApGaImprime(oGrid, oParent, oAcMenu)
   ENDMENU
return oPopUp

//-----------------------------------------------------------------------//
function ApApImprime(oGrid,oParent,oAcMenu)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
   local aCampos  := { "APTIPO", "APACTIVIDA", "APCUENTA", "APFECHA" , "APCONCEPTO", "APIMPNETO", "APCLIENTE", "APCATINGR", ;
                       "APMIFACTUR", "APRECING", "APIVAREP", "APGASTOSFI", "APIMPTOTAL",;
                       "APPROVEED", "APCATGAST", "APSUFACTUR", "APRECGAS", "APIVASOP" }
   local aTitulos := { "Apunte", "Actividad", "Cuenta", "Fecha", "Concepto", "Imp. Neto", "Cliente", "Tipo Ing.",;
                       "M/Factura", "Rec. Ing.", "IVA Rep.", "Gastos Fin.", "Imp. Total",;
                       "Proveedor", "Tipo Gas.", "S/Factura", "Rec. Gas.", "IVA Sop."  }
   local aWidth   := { 5, 40, 20, 15, 40, 15, 20, 20, 15, 15, 15, 15, 15, 20, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO", "NO","NO","AP01","NO","NO","NO","NO","NO","NO","AP02","NO","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .f., .t., .f., .f., .f., .f., .f., .t., .t., .f., .f., .f., .f., .f. }
   local oInforme
   local aControls[11]
	local aSay[4]
   local lGroup1  := .f.
   local cApCatIngr
   local lGroup2  := .f.
   local cApCliente
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
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "APAP" )
	if ! oAcMenu:aItems[1]:lChecked
		for i:=1 to Len(oAcMenu:aItems)
			if oAcMenu:aItems[i]:lChecked
				cActividad := oAcMenu:aItems[i]:cPrompt
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
		Select AP
      if oInforme:nRadio == 1
      	AP->(DbGoTop())
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
   	         FOR dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
  	      AP->(DbGoTop())
			while ! AP->(eof())
				if  ! lPeriodo .OR. ( lPeriodo .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal )
					if AP->ApTipo == "I"
						nAt := Ascan(aIng1, AP->ApCatIngr)
						if nAt == 0
							aadd(aIng1,AP->ApCatIngr)
							aadd(aIng2,AP->ApImpNeto)
						else
							aIng2[nAt] += AP->ApImpNeto
						endif
						nTotal += AP->ApImpNeto
					else
						nAt := Ascan(aGas1, AP->ApCatGast)
						if nAt == 0
							aadd(aGas1,AP->ApCatGast)
							aadd(aGas2,AP->ApImpNeto)
						else
							aGas2[nAt] += AP->ApImpNeto
						endif
						nTotal -= AP->ApImpNeto
					endif
				endif
				AP->(DbSkip())
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
  	      AP->(DbGoTop())
			while ! AP->(eof())
				if  ! lPeriodo .OR. ( lPeriodo .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal )
					if AP->ApTipo == "I"
						nAt := Ascan(aIng1, AP->ApCatIngr)
						if nAt == 0
							aadd(aIng1,AP->ApCatIngr)
							aadd(aIng2,AP->ApImpTotal)
						else
							aIng2[nAt] += AP->ApImpTotal
						endif
						nTotal += AP->ApImpTotal
					else
						nAt := Ascan(aGas1, AP->ApCatGast)
						if nAt == 0
							aadd(aGas1,AP->ApCatGast)
							aadd(aGas2,AP->ApImpTotal)
							else
							aGas2[nAt] += AP->ApImpTotal
						endif
						nTotal -= AP->ApImpTotal
					endif
				endif
				AP->(DbSkip())
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
		AP->(DbSetOrder(nOrder))
      AP->(DbGoTo(nRecno))
   endif
	oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//-----------------------------------------------------------------------//

function ApInImprime(oGrid,oParent,oAcMenu)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
   local aCampos  := { "APACTIVIDA", "APFECHA", "APCUENTA", "APCONCEPTO", "APIMPNETO", "APCLIENTE", "APCATINGR", ;
                       "APMIFACTUR", "APRECING", "APIVAREP", "APIVAREP", "APGASTOSFI", "APIMPTOTAL" }
   local aTitulos := { "Actividad", "Fecha", "Cuenta", "Concepto", "Importe", "Cliente", "Tipo Ing.",;
                       "Factura", "Rec. Eq.", "Tipo IVA", "IVA Rep.", "Gastos Fin.", "Imp. Total" }
   local aWidth   := { 40, 15, 20, 40, 15, 20, 20, 15, 15, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO", "NO","@E 9,999,999.99","NO","NO","NO","NO","NO", "API1", "@E 9,999,999.99","@E 9,999,999.99" }
   local aTotal   := { .f.,.f., .f., .f., .t., .f., .f., .f., .f., .f., .t., .t., .t. }
   local oInforme
   local aControls[11]
	local aSay[4]
   local lGroup1  := .f.
   local cApCatIngr
   local lGroup2  := .f.
   local cApCliente
   local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := CtoD('')
	local cActividad, i

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "APIN" )
	if ! oAcMenu:aItems[1]:lChecked
		for i:=1 to Len(oAcMenu:aItems)
			if oAcMenu:aItems[i]:lChecked
				cActividad := oAcMenu:aItems[i]:cPrompt
			endif
		next
	endif
	if cActividad != nil
		oInforme:cTitulo3 := cActividad
	endif
	oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302, 303, 304, 305 OF oInforme:oFld:aDialogs[1]

	REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[2] ID 140 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[3] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[4] ID 154 OF oInforme:oFld:aDialogs[1]

   REDEFINE CHECKBOX aControls[1] VAR lGroup1 ;
      ID 110 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 2

   REDEFINE GET aControls[2] VAR cApCatIngr ;
      ID 121 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID InClave( cApCatIngr, aControls[2], 4, 2 ) ;
      WHEN oInforme:nRadio == 3
   REDEFINE BUTTON aControls[3] ID 122 OF oInforme:oFld:aDialogs[1] ;
      ACTION InSeleccion( cApCatIngr, aControls[2], oInforme:oFld:aDialogs[1] ) ;
      WHEN oInforme:nRadio == 3

   REDEFINE CHECKBOX aControls[4] VAR lGroup1 ;
      ID 130 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 4

   REDEFINE GET aControls[5] VAR cApCliente ;
      ID 141 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID ClClave( cApCliente, aControls[5], 4, 1 ) ;
      WHEN oInforme:nRadio == 5
   REDEFINE BUTTON aControls[6] ID 142 OF oInforme:oFld:aDialogs[1] ;
      ACTION ClSeleccion( cApCliente, aControls[5], oInforme:oFld:aDialogs[1] )

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
		Select AP
      if oInforme:nRadio == 1
      	AP->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I"
            	// ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            	//          oInforme:oReport:Say(1, 'Número de ingresos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	//          oInforme:oReport:EndLine() )
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
      	AP->(DbSetOrder(5))
  	      AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
            	// ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            	//          oInforme:oReport:Say(1, 'Número de ingresos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	//          oInforme:oReport:EndLine() )
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 3
      	AP->(DbSetOrder(5))
      	AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. AP->ApCatIngr == cApCatIngr ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
      	      // ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         	   //          oInforme:oReport:Say(1, 'Número de ingresos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	//          oInforme:oReport:EndLine() )
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. AP->ApCatIngr == cApCatIngr .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 4
      	AP->(DbSetOrder(6))
      	AP->(DbGoTop())
         oInforme:Report(lGroup2)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         	   // ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
	            //          oInforme:oReport:Say(1, 'Número de ingresos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
   	         //          oInforme:oReport:EndLine() )
      	else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal ;

      	endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 5
      	AP->(DbSetOrder(6))
      	AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. AP->ApCliente == cApCliente
      	      // ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         	   //          oInforme:oReport:Say(1, 'Número de ingresos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	//          oInforme:oReport:EndLine() )
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "I" .AND. AP->ApCliente == cApCliente .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 6
			// IVA repercutido
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
      AP->(DbSetOrder(nOrder))
      AP->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//-----------------------------------------------------------------------//

function ApGaImprime(oGrid,oParent, oAcMenu)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
   local aCampos  := { "APACTIVIDA", "APFECHA" , "APCUENTA", "APCONCEPTO", "APIMPNETO", "APPROVEED", "APCATGAST", ;
                       "APSUFACTUR", "APRECGAS", "APIVASOP", "APIVASOP", "APGASTOSFI", "APIMPTOTAL" }
   local aTitulos := { "Actividad", "Fecha", "Cuenta", "Concepto", "Importe", "Proveedor", "Tipo Gas.",;
                       "Factura", "Rec. Eq.", "Tipo IVA", "IVA Sop.", "Gastos Fin.", "Imp. Total" }
   local aWidth   := { 40, 15, 20, 40, 15, 20, 20, 15, 15, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO", "NO","NO", "NO","@E 9,999,999.99","NO","NO","NO","NO","NO","APG1", "@E 9,999,999.99","@E 9,999,999.99" }
   local aTotal   := { .f., .f., .f., .f., .t., .f., .f., .f., .f., .f., .t., .t., .t. }
   local oInforme
   local aControls[11]
   local aSay[4]
   local lGroup1  := .f.
   local cApCatGast
   local lGroup2  := .f.
   local cApProveed
   local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := CtoD('')
	local cActividad, i
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "APGA" )
	if ! oAcMenu:aItems[1]:lChecked
		for i:=1 to Len(oAcMenu:aItems)
			if oAcMenu:aItems[i]:lChecked
				cActividad := oAcMenu:aItems[i]:cPrompt
			endif
		next
	endif
	if cActividad != nil
		oInforme:cTitulo3:=cActividad
	endif
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302, 303, 304, 305 OF oInforme:oFld:aDialogs[1]

	REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[2] ID 140 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[3] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[4] ID 154 OF oInforme:oFld:aDialogs[1]

   REDEFINE CHECKBOX aControls[1] VAR lGroup1 ;
      ID 110 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 2

   REDEFINE GET aControls[2] VAR cApCatGast ;
      ID 121 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID GaClave( cApCatGast, aControls[2], 4, 2 ) ;
      WHEN oInforme:nRadio == 3
   REDEFINE BUTTON aControls[3] ID 122 OF oInforme:oFld:aDialogs[1] ;
      ACTION GaSeleccion( cApCatGast, aControls[2], oInforme:oFld:aDialogs[1] ) ;
      WHEN oInforme:nRadio == 3

   REDEFINE CHECKBOX aControls[4] VAR lGroup1 ;
      ID 130 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 4

   REDEFINE GET aControls[5] VAR cApProveed ;
      ID 141 OF oInforme:oFld:aDialogs[1] UPDATE      ;
      VALID PrClave( cApProveed, aControls[5], 4, 1 ) ;
      WHEN oInforme:nRadio == 5
   REDEFINE BUTTON aControls[6] ID 142 OF oInforme:oFld:aDialogs[1] ;
      ACTION PrSeleccion( cApProveed, aControls[5], oInforme:oFld:aDialogs[1] )

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
		Select AP
      if oInforme:nRadio == 1
      	AP->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G"
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 2
      	AP->(DbSetOrder(7))
  	      AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal ;
					ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 3
      	AP->(DbSetOrder(7))
      	AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. AP->ApCatGast == cApCatGast
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. AP->ApCatGast == cApCatGast .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 4
      	AP->(DbSetOrder(8))
      	AP->(DbGoTop())
         oInforme:Report(lGroup2)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G"         ;
      	      ON POSTGROUP (oInforme:oReport:StartLine(), oInforme:oReport:EndLine())
      	else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
      	endif
         oInforme:End(.t.)
      elseif oInforme:nRadio == 5
      	AP->(DbSetOrder(8))
      	AP->(DbGoTop())
         oInforme:Report(lGroup1)
         if ! lPeriodo
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. AP->ApProveed == cApProveed
         else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
	         ACTIVATE REPORT oInforme:oReport ;
   	         FOR AP->ApTipo == "G" .AND. AP->ApProveed == cApProveed .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal
         endif
         oInforme:End(.t.)
		elseif oInforme:nRadio == 6
			// IVA soportado
			AP->(DbSetOrder(10))
      	AP->(DbGoTop())

			oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   		oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   		oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   		oInforme:cTitulo1 := "IVA Soportado"
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
   			COLUMN TITLE "Fecha" 		DATA AP->ApFecha   SIZE 10 FONT 1
   			COLUMN TITLE "Perceptor"   DATA AP->ApProveed SIZE 30 FONT 1
   			COLUMN TITLE "Imp. Neto"   DATA AP->ApImpNeto SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
				COLUMN TITLE "Tipo IVA"    DATA AP->ApIvaSop  SIZE 12 FONT 1 PICTURE "@E 99.99"       RIGHT
				COLUMN TITLE "Imp. IVA"    DATA AP->ApImpNeto*AP->ApIvaSop/100 SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
				COLUMN TITLE "Gastos"      DATA AP->ApGastosFi SIZE 12 FONT 1 PICTURE "@E 9,999,999.99" TOTAL RIGHT
         GROUP ON Str(AP->ApIvaSop);
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
     			ACTIVATE REPORT oInforme:oReport FOR AP->ApTipo == "G" ;
         		ON POSTGROUP oInforme:oReport:NewLine()
			else
				ACTIVATE REPORT oInforme:oReport FOR AP->ApTipo == "G" .AND. dInicio <= AP->ApFecha .AND. AP->ApFecha <= dFinal ;
					ON POSTGROUP oInforme:oReport:NewLine()
			endif
			oInforme:End(.f.)
      endif
      AP->(DbSetOrder(nOrder))
      AP->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//_____________________________________________________________________________*/
function ApSiguiente(aActividad)
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
function ApRecalc(nApImpNeto, cApIva, nTIVA, cApRec, nTRecEq, nApImpTotal, aGet, oDlg, lDesglose)
	// ? nApImpNeto
	// ? cApIva
   if lDesglose
      nApImpNeto  := nApImpTotal / (1+((VAL(StrTran(cApIva,",","."))+VAL(StrTran(cApRec,",",".")))/100))
      nTIVA       := nApImpNeto * VAL(StrTran(cApIva,",",".")) / 100
      nTRecEq     := nApImpNeto * VAL(StrTran(cApRec,",",".")) / 100
      aGet[09]:cText(nApImpNeto)
      aGet[13]:cText(nTRecEq)
      aGet[11]:cText(nTIVA)
   else
      nTIVA       := nApImpNeto * VAL(StrTran(cApIva,",",".")) / 100
      nTRecEq     := nApImpNeto * VAL(StrTran(cApRec,",",".")) / 100
      nApImpTotal := nApImpNeto + nTIVA + nTRecEq
      aGet[11]:cText(nTIVA)
      aGet[13]:cText(nTRecEq)
      aGet[14]:cText(nApImpTotal)
   endif
   oDlg:Update()
return .t.
//____________________________________________________________________________//
function ApBalMenu(oGrid, oParent, oAcMenu, aActividad)
	local oPopup
   MENU oPopup POPUP 2007
      MENUITEM "Balance anual - por trimestres "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oAcMenu,aActividad, .f.)
      MENUITEM "Balance anual - por trimestres con saldos"  RESOURCE "16_EJERCICIO" ACTION ApBalAnualTrim(oGrid,oParent,oAcMenu,aActividad,.t.)
      MENUITEM "Balance anual - por meses "  RESOURCE "16_EJERCICIO" ACTION ApBalAnualMens(oGrid,oParent,oAcMenu,aActividad, .f.)
      MENUITEM "Balance total por periodo" RESOURCE "16_FECHA" ACTION ApBalPeriodo(oGrid,oParent,oAcMenu,aActividad)
   ENDMENU
return oPopUp

function ApBalPeriodo(oGrid,oParent,oAcMenu,aActividad)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
   local oDlg, aGet[7]
   local dInicio  := CtoD('01/01/'+oApp():cEjercicio)
   local dFinal   := CtoD('31/12/'+oApp():cEjercicio)
   local dMes
   local aBrowse  := {}
   local oBrowse, oBtnPrint, oBtnCancel
   local aSay[13]
   local nSumIng  := 0
   local nIvaRep  := 0
	local nSumGas  := 0
	local nIvaSop  := 0
	local lFilter  := .f.
	local cActividad := ""

   local oInforme
   local i

	// si tengop filtro o una sóla actividad pongo lFilter a true
	if oAcMenu != nil
		if (! oAcMenu:aItems[1]:lChecked) .OR. len(aActividad)==1
			lFilter := .t.
		endif
	endif

   oApp():nEdit ++
   DEFINE DIALOG oDlg RESOURCE "APSALDO1" OF oParent;
      TITLE "Balance de situación por fechas"
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY aGet[1] ID 100 OF oDlg
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

   if oDlg:nresult == IDOK
      AP->(DbGoTop())
		if lFilter
			cActividad := Rtrim(AP->ApActivida)
		endif
      while ! AP->(EoF())
         dMes := dInicio
         if dInicio <= AP->ApFecha .and. AP->ApFecha <= dFinal
				if lFilter
					aadd(aBrowse,{AP->ApTipo, AP->ApFecha, iif(AP->ApTipo=='I',AP->ApCliente,AP->ApProveed), iif(AP->ApTipo=='I',AP->ApCatIngr,AP->ApCatGast), tran(AP->ApImpNeto,"@E 999,999.99"), tran(iif(AP->ApTipo=='I',AP->ApImpNeto*AP->ApIvaRep/100,AP->ApImpNeto*AP->ApIvaSop/100),"@E 999,999.99"), AP->ApCuenta })
				else
            	aadd(aBrowse,{AP->ApTipo, AP->ApFecha, AP->ApActivida, iif(AP->ApTipo=='I',AP->ApCatIngr,AP->ApCatGast), tran(AP->ApImpNeto,"@E 999,999.99"), tran(iif(AP->ApTipo=='I',AP->ApImpNeto*AP->ApIvaRep/100,AP->ApImpNeto*AP->ApIvaSop/100),"@E 999,999.99"), AP->ApCuenta })
				endif
            if AP->ApTipo == 'I'
               nSumIng += AP->ApImpNeto
					nIvaRep += AP->ApImpNeto*AP->ApIvaRep/100
            else
               nSumGas += AP->ApImpNeto
					nIvaSop += AP->ApImpNeto*AP->ApIvaSop/100
            endif
         endif
         AP->(DbSkip())
      enddo
      AP->(DbSetOrder(nOrder))
      AP->(DbGoTo(nRecno))
      ASort( aBrowse,,, { |a1, a2| DtoS(a1[2]) < DtoS(a2[2]) } )
      DEFINE DIALOG oDlg RESOURCE "APSALDO2" ;
         TITLE i18n( "Balance de situación: " )+iif(lFilter,"["+cActividad+"]","[Todas las actividades]") ;
         OF oParent
         oDlg:SetFont(oApp():oFont)

         oBrowse := TXBrowse():New( oDlg )
         oBrowse:SetArray(aBrowse, .f.)
         oBrowse:aCols[1]:cHeader  := "I/G"
         oBrowse:aCols[1]:nWidth   := 30
         oBrowse:aCols[1]:nDataStrAlign := AL_CENTER
         oBrowse:aCols[1]:nHeadStrAlign := AL_CENTER
         oBrowse:aCols[2]:cHeader  := "Fecha Ap."
         oBrowse:aCols[2]:nWidth   := 62
			if lFilter
         	oBrowse:aCols[3]:cHeader  := "Pagad./Percept."
			else
				oBrowse:aCols[3]:cHeader  := "Actividad"
			endif
         oBrowse:aCols[3]:nWidth   := 110
         oBrowse:aCols[4]:cHeader  := "Tipo Ing./Gas."
         oBrowse:aCols[4]:nWidth   := 140
         oBrowse:aCols[5]:cHeader  := "I. Neto"
         oBrowse:aCols[5]:nWidth   := 60
         oBrowse:aCols[5]:nDataStrAlign := AL_RIGHT
         oBrowse:aCols[5]:nHeadStrAlign := AL_RIGHT
         oBrowse:aCols[6]:cHeader  := "IVA"
         oBrowse:aCols[6]:nWidth   := 60
         oBrowse:aCols[6]:nDataStrAlign := AL_RIGHT
         oBrowse:aCols[6]:nHeadStrAlign := AL_RIGHT
         oBrowse:aCols[7]:cHeader  := "Cuenta"
         oBrowse:aCols[7]:nWidth   := 60
         Ut_BrwRowConfig( oBrowse )
         oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,1] == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
   		// oBrowse:bClrSelFocus := {|| { CLR_WHITE, iif( aBrowse[oBrowse:nArrayAt,1] == "I", oApp():cClrIng, oApp():cClrGas ) } }
			oBrowse:bClrSelFocus := { || { iif( aBrowse[oBrowse:nArrayAt,1] == "I", oApp():cClrIng, oApp():cClrGas ),;
																 { { 1, RGB( 220, 235, 252 ), RGB( 193, 219, 252 ) } } } }

         oBrowse:lHScroll  := .t.
         oBrowse:nRowHeight:= 20

         oBrowse:CreateFromResource( 200 )
         oDlg:oClient := oBrowse

         REDEFINE SAY aSay[1] PROMPT "Periodo: "+DtoC(dInicio)+" a "+DtoC(dFinal) ID 100 OF oDlg
         REDEFINE SAY aSay[2] ID 101 OF oDlg COLOR oApp():cClrIng, GetSysColor(15)
         REDEFINE SAY aSay[3] PROMPT Transform(nSumIng, "@E 999,999.99") ID 102 OF oDlg;
            COLOR oApp():cClrIng, GetSysColor(15)
         REDEFINE SAY aSay[4] ID 103 OF oDlg COLOR oApp():cClrGas, GetSysColor(15)
         REDEFINE SAY aSay[5] PROMPT Transform(nSumGas, "@E 999,999.99") ID 104 OF oDlg;
            COLOR oApp():cClrGas, GetSysColor(15)
         REDEFINE SAY aSay[6] ID 105 OF oDlg
         REDEFINE SAY aSay[7] PROMPT Transform(nSumIng-nSumGas, "@E 999,999.99") ID 106 OF oDlg
			REDEFINE SAY aSay[8] ID 107 OF oDlg COLOR oApp():cClrIng, GetSysColor(15)
         REDEFINE SAY aSay[9] PROMPT Transform(nIvaRep, "@E 999,999.99") ID 108 OF oDlg;
            COLOR oApp():cClrIng, GetSysColor(15)
         REDEFINE SAY aSay[10] ID 109 OF oDlg COLOR oApp():cClrGas, GetSysColor(15)
         REDEFINE SAY aSay[11] PROMPT Transform(nIvaSop, "@E 999,999.99") ID 110 OF oDlg;
            COLOR oApp():cClrGas, GetSysColor(15)
         REDEFINE SAY aSay[12] ID 111 OF oDlg
         REDEFINE SAY aSay[13] PROMPT Transform(nIvaRep-nIvaSop, "@E 999,999.99") ID 112 OF oDlg

         REDEFINE BUTTON oBtnPrint  ;
            ID IDOK OF oDlg         ;
            ACTION oDlg:end(IDOK)   ;

         REDEFINE BUTTON oBtnCancel ;
            ID IDCANCEL OF oDlg     ;
            ACTION oDlg:end(IDCANCEL)

         ACTIVATE DIALOG oDlg ;
            ON INIT DlgCenter(oDlg,oApp():oWndMain)

         if oDlg:nresult == IDOK
            oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "PEAP", "" )
            oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
            oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
            oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
            REPORT oReport ;
               TITLE  " "," ","Balance de situación",iif(lFilter,"["+cActividad+"]","[Todas las actividades]"),;
                  "Periodo desde "+DtoC(dInicio)+" - "+DtoC(dFinal) CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
               FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + " - Balance de situación" PREVIEW
               i := 1
               COLUMN TITLE "I/G"   	  DATA aBrowse[i,1] SIZE  5 FONT 1
               COLUMN TITLE "Fecha Ap."  DATA aBrowse[i,2] SIZE 10 FONT 1
					if lFilter
						COLUMN TITLE "Pagad./Percept."  DATA aBrowse[i,3] SIZE 28 FONT 1
					else
						COLUMN TITLE "Actividad"  DATA aBrowse[i,3] SIZE 28 FONT 1
					endif
               COLUMN TITLE "Tipo Ing./Gas." DATA aBrowse[i,4] SIZE 28 FONT 1
               COLUMN TITLE "Importe"    DATA aBrowse[i,5] SIZE 12 FONT 1 RIGHT
					COLUMN TITLE "IVA"        DATA aBrowse[i,6] SIZE 12 FONT 1 RIGHT
               COLUMN TITLE "Cuenta"     DATA aBrowse[i,7] SIZE 12 FONT 1
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
            ACTIVATE REPORT oReport WHILE i <= len(aBrowse) ;
               ON END ( oReport:StartLine(),;
								oReport:TotalLine(RPT_DOUBLELINE, 0),;
								oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, space(10)+'Suma Ingresos: ', 1),;
                        oReport:Say(5, Transform(nSumIng, "@E 999,999.99"), 1, 1),;
                        oReport:Say(6, 'IVA Rep.: ', 1),;
                        oReport:Say(7, Transform(nIvaRep, "@E 999,999.99"), 1, 1),;
         					oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, space(10)+'Suma Gastos: ', 1),;
                        oReport:Say(5, Transform(nSumGas, "@E 999,999.99"), 1, 1),;
                        oReport:Say(6, 'IVA Sop.: ', 1),;
                        oReport:Say(7, Transform(nIvaSop, "@E 999,999.99"), 1, 1),;
                        oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, space(10)+'Diferencia: ', 1),;
                        oReport:Say(5, Transform(nSumIng-nSumGas, "@E 999,999.99"), 1, 1),;
								oReport:Say(7, Transform(nIvaRep-nIvaSop, "@E 999,999.99"), 1, 1),;
                        oReport:EndLine())
            oInforme:End(.f.)
         endif
   endif
   oApp():nEdit --
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil

function ApBalAnualTrim(oGrid,oParent,oAcMenu,aActividad, lSaldos)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
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
	if oAcMenu != nil
		if (! oAcMenu:aItems[1]:lChecked) .OR. len(aActividad)==1
			lFilter := .t.
		endif
	endif

	// creo el array de tipos de ingreso
	IN->(OrdSetFocus(1))
	IN->(DbGoTop())
	while ! IN->(eof())
		aadd(aCatIng, Rtrim(IN->InCategor))
 		aadd(aSumIng, {space(5)+Rtrim(IN->InCategor),0,0,0,0,0})
		IN->(DbSkip())
	enddo

	// creo el array de tipos de gasto
	GA->(OrdSetFocus(1))
	GA->(DbGoTop())
	while ! GA->(eof())
		aadd(aCatGas, Rtrim(GA->GaCategor))
		aadd(aSumGas, {space(5)+Rtrim(GA->GaCategor),0,0,0,0,0})
		GA->(DbSkip())
	enddo

	// creo el array de IVA
	aadd(aSumIva, {"IVA Repercutido - Base",0,0,0,0,0})
	aadd(aSumIva, {"IVA Repercutido - Cuota",0,0,0,0,0})
	aadd(aSumIva, {"IVA Soportado - Base",0,0,0,0,0})
	aadd(aSumIva, {"IVA Soportado - Cuota",0,0,0,0,0})
	aadd(aSumIva, {"Diferencia - Base",0,0,0,0,0})
	aadd(aSumIva, {"Diferencia - Cuota",0,0,0,0,0})

	// creo el array de cuentas corrientes
	CC->(OrdSetFocus(1))
	CC->(DbGoTop())
	while ! CC->(eof())
		aadd(aCuentas, Rtrim(CC->CcCuenta))
		aadd(aSaldos, {space(5)+Rtrim(CC->CcCuenta),0,0,0,0,0})
		CC->(DbSkip())
	enddo

   AP->(DbGoTop())
	if lFilter
		cActividad := Rtrim(AP->ApActivida)
	endif
   while ! AP->(EoF())
		nTrim := int((month(AP->ApFecha)-1)/3) + 1
		if AP->ApTipo == 'I'
			if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),nTrim+1] += Ap->ApImpNeto
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),6] += Ap->ApImpNeto
			endif
			if AP->ApIvaRep != 0
				aSumIva[1,nTrim+1] += Ap->ApImpNeto
				aSumIva[1,6] += Ap->ApImpNeto
				aSumIva[2,nTrim+1] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[2,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[5,nTrim+1] += Ap->ApImpNeto
				aSumIva[5,6] += Ap->ApImpNeto
				aSumIva[6,nTrim+1] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[6,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
			endif
			if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),nTrim+1] += Ap->ApImpTotal
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] += Ap->ApImpTotal
			endif
		else
			if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),nTrim+1] += AP->ApImpNeto
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),6] += Ap->ApImpNeto
			endif
			if AP->ApIvaSop != 0
				aSumIva[3,nTrim+1] += Ap->ApImpNeto
				aSumIva[3,6] += Ap->ApImpNeto
				aSumIva[4,nTrim+1] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[4,6] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[5,nTrim+1] -= Ap->ApImpNeto
				aSumIva[5,6] -= Ap->ApImpNeto
				aSumIva[6,nTrim+1] -= Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[6,6] -= Ap->ApImpNeto*Ap->ApIvaSop/100
			endif
			if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),nTrim+1] -= Ap->ApImpTotal
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] -= Ap->ApImpTotal
			endif
		endif
		/*
		do case
			case 1 <= month(AP->ApFecha) .and. month(AP->ApFecha) <=3
	   		if AP->ApTipo == 'I'
					if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),2] += Ap->ApImpNeto
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaRep != 0
						aSumIva[1,2] += Ap->ApImpNeto
						aSumIva[1,6] += Ap->ApImpNeto
						aSumIva[2,2] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[2,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[5,2] += Ap->ApImpNeto
						aSumIva[5,6] += Ap->ApImpNeto
						aSumIva[6,2] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[6,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),2] += Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] += Ap->ApImpTotal
					endif
				else
					if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),2] += AP->ApImpNeto
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaSop != 0
						aSumIva[3,2] += Ap->ApImpNeto
						aSumIva[3,6] += Ap->ApImpNeto
						aSumIva[4,2] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[4,6] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[5,2] -= Ap->ApImpNeto
						aSumIva[5,6] -= Ap->ApImpNeto
						aSumIva[6,2] -= Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[6,6] -= Ap->ApImpNeto*Ap->ApIvaSop/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),2] -= Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] -= Ap->ApImpTotal
					endif
				endif
			case 4 <= month(AP->ApFecha) .and. month(AP->ApFecha) <=6
	   		if AP->ApTipo == 'I'
					if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),3] += Ap->ApImpNeto
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaRep != 0
						aSumIva[1,3] += Ap->ApImpNeto
						aSumIva[1,6] += Ap->ApImpNeto
						aSumIva[2,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[2,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[5,3] += Ap->ApImpNeto
						aSumIva[5,6] += Ap->ApImpNeto
						aSumIva[6,3] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[6,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),3] += Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] += Ap->ApImpTotal
					endif
				else
					if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),3] += Ap->ApImpNeto
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaSop != 0
						aSumIva[3,3] += Ap->ApImpNeto
						aSumIva[3,6] += Ap->ApImpNeto
						aSumIva[4,3] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[4,6] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[5,3] -= Ap->ApImpNeto
						aSumIva[5,6] -= Ap->ApImpNeto
						aSumIva[6,3] -= Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[6,6] -= Ap->ApImpNeto*Ap->ApIvaSop/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),3] -= Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] -= Ap->ApImpTotal
					endif
				endif
			case 7 <= month(AP->ApFecha) .and. month(AP->ApFecha) <=9
	   		if AP->ApTipo == 'I'
					if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),4] += Ap->ApImpNeto
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaRep != 0
						aSumIva[1,4] += Ap->ApImpNeto
						aSumIva[1,6] += Ap->ApImpNeto
						aSumIva[2,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[2,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[5,4] += Ap->ApImpNeto
						aSumIva[5,6] += Ap->ApImpNeto
						aSumIva[6,4] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[6,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),4] += Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] += Ap->ApImpTotal
					endif
				else
					if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),4] += Ap->ApImpNeto
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaSop != 0
						aSumIva[3,4] += Ap->ApImpNeto
						aSumIva[3,6] += Ap->ApImpNeto
						aSumIva[4,4] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[4,6] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[5,4] -= Ap->ApImpNeto
						aSumIva[5,6] -= Ap->ApImpNeto
						aSumIva[6,4] -= Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[6,6] -= Ap->ApImpNeto*Ap->ApIvaSop/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),4] -= Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] -= Ap->ApImpTotal
					endif
				endif
			case 10 <= month(AP->ApFecha) .and. month(AP->ApFecha) <=12
	   		if AP->ApTipo == 'I'
					if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),5] += Ap->ApImpNeto
						aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaRep != 0
						aSumIva[1,5] += Ap->ApImpNeto
						aSumIva[1,6] += Ap->ApImpNeto
						aSumIva[2,5] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[2,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[5,5] += Ap->ApImpNeto
						aSumIva[5,6] += Ap->ApImpNeto
						aSumIva[6,5] += Ap->ApImpNeto*Ap->ApIvaRep/100
						aSumIva[6,6] += Ap->ApImpNeto*Ap->ApIvaRep/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),5] += Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] += Ap->ApImpTotal
					endif
				else
					if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),5] += Ap->ApImpNeto
						aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),6] += Ap->ApImpNeto
					endif
					if AP->ApIvaSop != 0
						aSumIva[3,5] += Ap->ApImpNeto
						aSumIva[3,6] += Ap->ApImpNeto
						aSumIva[4,5] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[4,6] += Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[5,5] -= Ap->ApImpNeto
						aSumIva[5,6] -= Ap->ApImpNeto
						aSumIva[6,5] -= Ap->ApImpNeto*Ap->ApIvaSop/100
						aSumIva[6,6] -= Ap->ApImpNeto*Ap->ApIvaSop/100
					endif
					if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),5] -= Ap->ApImpTotal
						aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),6] -= Ap->ApImpTotal
					endif
				endif
		endcase
		*/
		AP->(DbSkip())
   enddo
	Aadd(aListado,{"Ingresos","","","","",""})
	aIngPer := {"Total ingresos",0,0,0,0,0}
	for i := 1 to Len(aSumIng)
		Aadd(aListado, aSumIng[i])
		aIngPer[2] += aSumIng[i,2]
		aIngPer[3] += aSumIng[i,3]
		aIngPer[4] += aSumIng[i,4]
		aIngPer[5] += aSumIng[i,5]
		aIngPer[6] += aSumIng[i,6]
	next
	Aadd(aListado,{"Gastos","","","","",""})
	aGasPer := {"Total Gastos",0,0,0,0,0}
	for i := 1 to Len(aSumGas)
		Aadd(aListado, aSumGas[i])
		aGasPer[2] += aSumGas[i,2]
		aGasPer[3] += aSumGas[i,3]
		aGasPer[4] += aSumGas[i,4]
		aGasPer[5] += aSumGas[i,5]
		aGasPer[6] += aSumGas[i,6]
	next
	Aadd(aListado,{"","","","","",""})
	Aadd(aListado, aIngPer)
	Aadd(aListado, aGasPer)
	Aadd(aListado, {"Rendimiento", aIngPer[2]-aGasPer[2],aIngPer[3]-aGasPer[3],;
									       aIngPer[4]-aGasPer[4],aIngPer[5]-aGasPer[5],aIngPer[6]-aGasPer[6]})
	Aadd(aListado,{"","","","","",""})
	Aadd(aListado, aSumIva[1])
	Aadd(aListado, aSumIva[2])
	Aadd(aListado, aSumIva[3])
	Aadd(aListado, aSumIva[4])
	Aadd(aListado, aSumIva[5])
	Aadd(aListado, aSumIva[6])

	if lSaldos
		Aadd(aListado,{"","","","","",""})
		Aadd(aListado,{"Saldos de cuentas","","","","",""})
		for i := 1 to Len(aSaldos)
			Aadd(aListado, aSaldos[i])
		next
	endif

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "PEAP", "" )
   oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
   REPORT oReport ;
      TITLE  " "," ","Balance anual de situación",iif(lFilter,"["+cActividad+"]","[Todas las actividades]"),;
         "Ejercicio "+oApp():cEjercicio CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
      FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + " - Balance anual de situación" PREVIEW
      i := 1
      COLUMN TITLE "Concepto"   	  DATA aListado[i,1] SIZE 35 FONT 1
      COLUMN TITLE "1er trimestre" DATA aListado[i,2] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "2o trimestre"  DATA aListado[i,3] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "3er trimestre" DATA aListado[i,4] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "4o trimestre"  DATA aListado[i,5] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Total anual"   DATA aListado[i,6] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
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
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
//_______________________________________________________________________________//

function ApBalAnualMens(oGrid,oParent,oAcMenu,aActividad, lSaldos)
   local nRecno   := AP->(Recno())
   local nOrder   := AP->(OrdSetFocus())
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
	local lFilter  := .f.
	local nTrim    := 0
	local cActividad := "Todas las actividades"

   local oInforme
   local i, t, k
	local aTitCol := { {"Enero", "Febrero", "Marzo"},;
							 {"Abril", "Mayo", "Junio"},;
							 {"Julio", "Agosto", "Septiembre"},;
						    {"Octubre", "Noviembre", "Diciembre"} }

	// si tengop filtro o una sóla actividad pongo lFilter a true
	if oAcMenu != nil
		if (! oAcMenu:aItems[1]:lChecked) .OR. len(aActividad)==1
			lFilter := .t.
		endif
	endif

	// creo el array de tipos de ingreso
	//
	IN->(OrdSetFocus(1))
	IN->(DbGoTop())
	while ! IN->(eof())
		aadd(aCatIng, Rtrim(IN->InCategor))
 		aadd(aSumIng, {space(5)+Rtrim(IN->InCategor),0,0,0,0,0,0,0,0,0,0,0,0,0})
		IN->(DbSkip())
	enddo

	// creo el array de tipos de gasto
	GA->(OrdSetFocus(1))
	GA->(DbGoTop())
	while ! GA->(eof())
		aadd(aCatGas, Rtrim(GA->GaCategor))
		aadd(aSumGas, {space(5)+Rtrim(GA->GaCategor),0,0,0,0,0,0,0,0,0,0,0,0,0})
		GA->(DbSkip())
	enddo

	// creo el array de IVA
	aadd(aSumIva, {"IVA Repercutido - Base",0,0,0,0,0,0,0,0,0,0,0,0,0})
	aadd(aSumIva, {"IVA Repercutido - Cuota",0,0,0,0,0,0,0,0,0,0,0,0,0})
	aadd(aSumIva, {"IVA Soportado - Base",0,0,0,0,0,0,0,0,0,0,0,0,0})
	aadd(aSumIva, {"IVA Soportado - Cuota",0,0,0,0,0,0,0,0,0,0,0,0,0})
	aadd(aSumIva, {"Diferencia - Base",0,0,0,0,0,0,0,0,0,0,0,0,0})
	aadd(aSumIva, {"Diferencia - Cuota",0,0,0,0,0,0,0,0,0,0,0,0,0})

	// creo el array de cuentas corrientes
	CC->(OrdSetFocus(1))
	CC->(DbGoTop())
	while ! CC->(eof())
		aadd(aCuentas, Rtrim(CC->CcCuenta))
		aadd(aSaldos, {space(5)+Rtrim(CC->CcCuenta),0,0,0,0,0,0,0,0,0,0,0,0,0})
		CC->(DbSkip())
	enddo

   AP->(DbGoTop())
	if lFilter
		cActividad := Rtrim(AP->ApActivida)
	endif
   while ! AP->(EoF())
   	if AP->ApTipo == 'I'
			if AScan(aCatIng,Rtrim(AP->ApCatIngr)) != 0
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),month(AP->ApFecha)+1] += Ap->ApImpNeto
				aSumIng[AScan(aCatIng,Rtrim(AP->ApCatIngr)),14] += Ap->ApImpNeto
			endif
			if AP->ApIvaRep != 0
				aSumIva[1,month(AP->ApFecha)+1] += Ap->ApImpNeto
				aSumIva[1,14] += Ap->ApImpNeto
				aSumIva[2,month(AP->ApFecha)+1] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[2,14] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[5,month(AP->ApFecha)+1] += Ap->ApImpNeto
				aSumIva[5,14] += Ap->ApImpNeto
				aSumIva[6,month(AP->ApFecha)+1] += Ap->ApImpNeto*Ap->ApIvaRep/100
				aSumIva[6,14] += Ap->ApImpNeto*Ap->ApIvaRep/100
			endif
			if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),month(AP->ApFecha)+1] += Ap->ApImpTotal
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),14] += Ap->ApImpTotal
			endif
		else
			if AScan(aCatGas,Rtrim(AP->ApCatGast)) != 0
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),month(AP->ApFecha)+1] += AP->ApImpNeto
				aSumGas[AScan(aCatGas,Rtrim(AP->ApCatGast)),14] += Ap->ApImpNeto
			endif
			if AP->ApIvaSop != 0
				aSumIva[3,month(AP->ApFecha)+1] += Ap->ApImpNeto
				aSumIva[3,14] += Ap->ApImpNeto
				aSumIva[4,month(AP->ApFecha)+1] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[4,14] += Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[5,month(AP->ApFecha)+1] -= Ap->ApImpNeto
				aSumIva[5,14] -= Ap->ApImpNeto
				aSumIva[6,month(AP->ApFecha)+1] -= Ap->ApImpNeto*Ap->ApIvaSop/100
				aSumIva[6,14] -= Ap->ApImpNeto*Ap->ApIvaSop/100
			endif
			if AScan(aCuentas,Rtrim(AP->ApCuenta)) != 0
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),month(AP->ApFecha)+1] -= Ap->ApImpTotal
				aSaldos[AScan(aCuentas,Rtrim(AP->ApCuenta)),14] -= Ap->ApImpTotal
			endif
		endif
		AP->(DbSkip())
   enddo
	for t := 1 to 4
		Aadd(aListado,{"Ingresos","","","","",t})
		aIngPer := {"Total ingresos",0,0,0,0,0}
		k := 3*(t-1)+1
		for i := 1 to Len(aSumIng)
			Aadd(aListado, { aSumIng[i,1],aSumIng[i,k+1],aSumIng[i,k+2],aSumIng[i,k+3],aSumIng[i,k+1]+aSumIng[i,k+2]+aSumIng[i,k+3],t } )
			aIngPer[2] += aSumIng[i,k+1]
			aIngPer[3] += aSumIng[i,k+2]
			aIngPer[4] += aSumIng[i,k+3]
			aIngPer[5] += aSumIng[i,k+1] + aSumIng[i,k+2] + aSumIng[i,k+3]
			aIngPer[6] := t
		next
		Aadd(aListado, aIngPer)
		Aadd(aListado,{"Gastos","","","","",t})
		aGasPer := {"Total Gastos",0,0,0,0,0}
		for i := 1 to Len(aSumGas)
			Aadd(aListado, { aSumGas[i,1],aSumGas[i,k+1],aSumGas[i,k+2],aSumGas[i,k+3],aSumGas[i,k+1]+aSumGas[i,k+2]+aSumGas[i,k+3],t })
			aGasPer[2] += aSumGas[i,k+1]
			aGasPer[3] += aSumGas[i,k+2]
			aGasPer[4] += aSumGas[i,k+3]
			aGasPer[5] += aSumGas[i,k+1] + aSumGas[i,k+2] + aSumGas[i,k+3]
			aGasPer[6] := t
		next
		Aadd(aListado, aGasPer)
		Aadd(aListado,{"","","","","",t})
		//Aadd(aListado, aIngPer)
		//Aadd(aListado, aGasPer)
	next

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "PEAP", "" )
   oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
   REPORT oReport ;
      TITLE  " "," ","Balance mensual de situación",iif(lFilter,"["+cActividad+"]","[Todas las actividades]"),;
         "Ejercicio "+oApp():cEjercicio CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
      FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + " - Balance anual de situación" PREVIEW
      i := 1
      COLUMN TITLE "Concepto"   	  DATA aListado[i,1] SIZE 35 FONT 1
      COLUMN TITLE aTitCol[aListado[i,6],1] DATA aListado[i,2] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE aTitCol[aListado[i,6],2] DATA aListado[i,3] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE aTitCol[aListado[i,6],3] DATA aListado[i,4] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      COLUMN TITLE "Total trim."   DATA aListado[i,5] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
		// COLUMN TITLE "Total trim."   DATA aListado[i,6] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
      // COLUMN TITLE "Total anual"   DATA aListado[i,6] SIZE 14 FONT 1 PICTURE "@E 999,999,999.99" RIGHT
		GROUP ON aListado[i,6] ;
			FOOTER " " EJECT
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
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil

FUNCTION ApImpTotalSaldo()
   LOCAL nApRecno := AP->( RecNo() )
   LOCAL nApOrder := AP->( ordNumber() )
   LOCAL cAlias   := Alias()
   LOCAL nSaldo, nIngresos, nGastos
   SELECT AP
   AP->( dbGoTop() )
   SUM AP->ApImpTotal TO nIngresos FOR AP->ApTipo == "I"
   AP->( dbGoTop() )
   SUM AP->ApImpTotal TO nGastos   FOR AP->ApTipo == "G"
   nSaldo := nIngresos - nGastos
   AP->( ordSetFocus( nApOrder ) )
   AP->( dbGoto( nApRecno ) )
   SELECT (cAlias)
	//IF nSaldo > 0
	//	oApp():oGrid:bClrFooter := {|| { oApp():cClrIng, GetSysColor( 15 ) } }
	//ELSE
	//	oApp():oGrid:bClrFooter := {|| { oApp():cClrGas, GetSysColor( 15 ) } }
	//ENDIF

   RETURN Tran(nSaldo, "@E 999,999.99")

FUNCTION ApImpNetoSaldo()
   LOCAL nApRecno := AP->( RecNo() )
   LOCAL nApOrder := AP->( ordNumber() )
   LOCAL cAlias   := Alias()
   LOCAL nSaldo, nIngresos, nGastos
   SELECT AP
   AP->( dbGoTop() )
   SUM AP->ApImpNeto TO nIngresos FOR AP->ApTipo == "I"
   AP->( dbGoTop() )
   SUM AP->ApImpNeto TO nGastos   FOR AP->ApTipo == "G"
   nSaldo := nIngresos - nGastos
   AP->( ordSetFocus( nApOrder ) )
   AP->( dbGoto( nApRecno ) )
   SELECT (cAlias)
   RETURN Tran(nSaldo, "@E 999,999.99")

// { {|| iif( AP->ApTipo == 'I', AP->ApImpNeto * AP->ApIvaRep / 100, AP->ApImpNeto * AP->ApIvaSop / 100 ) }, i18n( "IVA Rep./Sop." ), 120, AL_RIGHT, "@E 999,999.99" }, ;
FUNCTION ApIvaSaldo()
   LOCAL nApRecno := AP->( RecNo() )
   LOCAL nApOrder := AP->( ordNumber() )
   LOCAL cAlias   := Alias()
   LOCAL nSaldo, nIngresos, nGastos
   SELECT AP
   AP->( dbGoTop() )
   // SUM ( AP->ApImpNeto*AP->ApIvaRep/100 ) FOR AP->ApTipo == "I"
   AP->( dbGoTop() )
   // SUM ( AP->ApImpNeto*AP->ApIvaSop/100 ) FOR AP->ApTipo == "G"
   nSaldo := nIngresos - nGastos
   AP->( ordSetFocus( nApOrder ) )
   AP->( dbGoto( nApRecno ) )
   SELECT (cAlias)
   RETURN Tran(nSaldo, "@E 999,999.99")

FUNCTION ApCList( aList, cData, oSelf, IG )
	LOCAL nApRecno := AP->( RecNo() )
   LOCAL nApOrder := AP->( ordNumber() )
   LOCAL cAlias   := Alias()
	LOCAL lNewItem := .t.
	LOCAL uItem
   LOCAL aNewList := {}
   SELECT AP
   AP->( dbGoTop() )
   while ! AP->(Eof())
      if AP->ApTipo == IG .AND. at(Upper(cdata), Upper(AP->ApConcepto)) != 0
			lNewItem := .t.
			for each uItem in aNewList
				if uItem[ 1 ] == AP->ApConcepto 
					lNewItem := .f.
				endif 
			next	
			IF lNewItem == .t.
			   AAdd( aNewList, { AP->ApConcepto } )
			ENDIF
      endif 
      AP->(DbSkip())
   enddo
	AP->(DbGoTo(nApRecno))
	SELECT ( cAlias )
return aNewlist
// _____________________________________________________________________________//
