#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"
#include "AutoGet.ch"

STATIC oReport

function Periodicos()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "PeState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "PeOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "PeRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "PeSplit","102", oApp():cIniFile))
   local oCont
   local i
   local aActividad := {}
   local oAcMenu
   local bAction
   local aPeriod := {"Anual", "Semestral", "Trimestral", "Bimestral", "Mensual"}

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

   SELECT PE
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de apuntes periódicos')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "PE"

   aBrowse   := { { { || PE->PeActivida }, i18n("Actividad"), 150, AL_LEFT, NIL },;
                  { { || PE->PeFUltimo }, i18n("Último ap."), 150, AL_LEFT, NIL },;
                  { { || PE->PeFProximo }, i18n("Próximo ap."), 150, AL_LEFT, NIL },;
                  { { || aPeriod[Max(PE->PePeriodic,1)] }, i18n("Periodicidad"), 120, AL_LEFT, NIL },;
                  { { || PE->PeConcepto }, i18n("Concepto"), 120, AL_LEFT, NIL },;
                  { { || PE->PeImpTotal }, i18n("Importe total"), 120, AL_RIGHT, "@E 999,999.99" },;
                  { { || IIF(PE->PeTipo=='I',PE->PeCliente,PE->PeProveed) }, i18n("Pagador / Perceptor"), 120, AL_LEFT, NIL },;
                  { { || IIF(PE->PeTipo=='I',PE->PeCatIngr,PE->PeCatGast) }, i18n("Tipo Ingreso / Gasto"), 120, AL_LEFT, NIL },;
                  { { || PE->PeCuenta }, i18n("Cuenta"), 120, AL_LEFT, NIL },;
                  { { || PE->PeCliente }, i18n("Pagador"), 120, AL_LEFT, NIL },;
                  { { || PE->PeCatIngr }, i18n("Tipo Ingreso"), 120, AL_LEFT, NIL },;
                  { { || PE->PeProveed  }, i18n("Perceptor"), 120, AL_LEFT, NIL },;
                  { { || PE->PeCatGast  }, i18n("Tipo Gasto"), 120, AL_LEFT, NIL } }

   for i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
		oCol:bEditValue :=  aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
		if aBrowse[i,5] != NIL
			oCol:cEditPicture := aBrowse[i,5]
		endif
   next

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource("16_INGRESO")
   oCol:AddResource("16_GASTO")
	oCol:Cargo         := { || IIF(PE->PeTipo=='I',"Ingreso","Gasto") }
   oCol:cHeader       := i18n("Tipo")
   oCol:bBmpData      := { || IIF(PE->PeTipo=='I',1,2) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   for i := 1 to Len(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| IIF(PE->PeTipo=='I',;
												PeIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu ),;
												PeGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu )) }
   next

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"PE") }
   oApp():oGrid:bKeyDown := {|nKey| PeTecla(nKey,oApp():oGrid,oCont,oApp():oDlg, oAcMenu) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:bClrStd := {|| { iif( PE->PeTipo == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
   oApp():oGrid:bClrRowFocus := { || { iif( PE->PeTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }	 
   oApp():oGrid:bClrSelFocus := { || { iif( PE->PeTipo == "I", oApp():cClrIng, oApp():cClrGas ), oApp():nClrHL } }

   oApp():oGrid:RestoreState( cState )

   PE->(DbSetOrder(nOrder))
   PE->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 17 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(PE->(OrdKeyNo()),'@E 999,999')+" / "+tran(PE->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_PERIODICO" 

   @ 24, 05 VMENU oBar SIZE nSplit-10, 185 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar ;
      CAPTION "  apuntes periodicos" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo Ingreso Periódico"      ;
      IMAGE "16_INGRESO"           ;
      ACTION PeIEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oAcMenu );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo Gasto Periódico"        ;
      IMAGE "16_GASTO"             ;
      ACTION PeGEdita( oApp():oGrid, 1, oCont, oApp():oDlg, oAcMenu );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar apunte periódico"   ;
      IMAGE "16_modif"             ;
      ACTION IIF(PE->PeTipo=="I",PeIEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu ),PeGEdita( oApp():oGrid, 2, oCont, oApp():oDlg, oAcMenu ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar apunte periódico"    ;
      IMAGE "16_duplica"           ;
      ACTION IIF(PE->PeTipo=="I",PeIEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oAcMenu ),PeGEdita( oApp():oGrid, 3, oCont, oApp():oDlg, oAcMenu ));
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar apunte periódico" ;
      IMAGE "16_borrar"            ;
      ACTION PeBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar apunte periódico"      ;
      IMAGE "16_busca"             ;
      ACTION PeBusca(oApp():oGrid,,oCont,oApp():oDlg, oAcMenu)  ;
      LEFT 10

   MENU oAcMenu POPUP 2007
      MENUITEM "Todas las actividades" ;
         ACTION ( PE->(DbClearFilter()), PeUpdFilter( 0, oCont, oAcMenu, oBar ));
         CHECKED
      SEPARATOR
      For i := 1 to Len(aActividad)
         bAction := PeFilter(aActividad, i, oCont, oAcMenu, oBar)
         MENUITEM RTrim(aActividad[i]) BLOCK bAction
      Next
   ENDMENU

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir apuntes periódicos"   ;
      IMAGE "16_imprimir"          ;
      ACTION PeApImprime(oApp():oGrid, oApp():oDlg, oAcMenu) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Previsión de ingresos y gastos"   ;
      IMAGE "16_PREVISION"         ;
      ACTION PePrevision(oApp():oGrid, oApp():oDlg, oAcMenu) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
   INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Filtrar por actividad" ;
      IMAGE "16_ACTIVIDAD"         ;
      MENU oAcMenu                 ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Apuntes periódicos" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PeState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS " Actividad "," F. Ultimo Ap. "," F. Próximo Ap. "," Concepto "," Cuenta "," Tipo Ingreso "," Pagador "," Tipo Gasto "," Perceptor ";
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              PE->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"PE") )

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
              WritePProString("Browse","PeState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","PeOrder",Ltrim(Str(PE->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","PeRecno",Ltrim(Str(PE->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","PeSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := nil, oApp():oGrid := nil, oApp():oTab := nil, .t. )

return nil
/*_____________________________________________________________________________*/
function PeFilter(aActividad, i, oCont, oAcMenu, oBar)
return { || PE->(DbSetFilter( {|| PE->PeActivida==aActividad[i] })), PeUpdFilter(i, oCont, oAcMenu, oBar) }

function PeUpdFilter(i, oCont, oAcMenu, oBar)
   local j
   PE->(DbGoTop())
   RefreshCont(oCont,"PE")
   oApp():oGrid:Refresh(.t.)
   For j:=1 to Len(oAcMenu:aItems)
      oAcMenu:aItems[j]:SetCheck(.f.)
   Next
   if i==0
      oAcMenu:aItems[1]:SetCheck(.t.)
      oBar:cTitle := "apuntes periódicos"
   else
      oAcMenu:aItems[i+2]:SetCheck(.t.)
      oBar:cTitle := "apuntes periódicos [filtrado]"
   endif
   oBar:Refresh()
return nil
//---------------------------------------------------------------------------//

function PeIEdita(oGrid,nMode,oCont,oParent,oAcMenu)
   local lCont := nMode == 1

   PeIEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu)
   do while lCont
      APIEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu)
   enddo

return NIL
function PeIEdita1(oGrid,nMode,oCont,oParent,lCont,oAcMenu)
   local oDlg
   local aTitle   := { i18n( "Añadir un ingreso periódico" )   ,;
                       i18n( "Modificar un ingreso periódico") ,;
                       i18n( "Duplicar un ingreso periódico") ,;
 							  i18n( "Añadir un ingreso periódico" )  }
   local aGet[35]
   local lAcIVA   := .t.
	local lAcREquiv:= .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)
   local aPeriod  := {"Anual", "Semestral", "Trimestral", "Bimestral", "Mensual"}

   local cPeNumero   ,;
         cPeConcepto ,;
			cPeCuenta	,;
         nPeImpNeto  ,;
         cPeObserv   ,;
         cPeCliente  ,;
         cPeCatIngr  ,;
         cPeIvaRep   ,;
         cPeRecIng   ,;
         nPeGastosFi ,;
         nPeImpTotal ,;
         cPeActivida ,;
         nPePeriodic ,;
         cPePeriodic ,;
         cPeMeses    ,;
         dPeFUltimo  ,;
         dPeFProximo

   local nTIVA, nTRecEq
   local nRecPtr  := PE->(RecNo())
   local nOrden   := PE->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
   local lFilter  := ! (oAcMenu:aItems[1]:lChecked)
   local i
   local aMeses[12]

   if PE->(EOF()) .AND. nMode != 1
      retu NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      PE->(DbAppend())
      nRecAdd   := PE->(RecNo())
      Replace PE->PePeriodic With 1
      Replace PE->PeMeses With "000000000000"
   endif

   cPeConcepto := PE->PeConcepto
   cPeActivida := iif(nMode==1,oApp():cActividad,PE->PeActivida)
	cPeCuenta	:= PE->PeCuenta
   nPeImpNeto  := PE->PeImpNeto
   cPeObserv   := PE->PeObserv
   cPeCliente  := PE->PeCliente
   cPeCatIngr  := PE->PeCatIngr
   cPeIvaRep   := Tran(PE->PeIvaRep,"@E99.99")
   nPeImpTotal := PE->PeImpTotal
   nPeGastosFi := PE->PeGastosFi
   cPeRecIng   := Tran(PE->PeRecIng,"@E99.99")
   nPePeriodic := PE->PePeriodic
   cPePeriodic := aPeriod[Max(nPePeriodic,1)]
   cPeMeses    := PE->PeMeses
   dPeFUltimo  := PE->PeFUltimo
   dPeFProximo := PE->PeFProximo
   for i := 1 to 12
      aMeses[i] := SubStr(cPeMeses,i,1)=='1'
   next

   nTIVA       := nPeImpNeto * VAL(cPeIvaRep) / 100
   nTRecEq     := nPeImpNeto * VAL(cPeRecIng) / 100

   if nMode != 1
      AC->(DbSetOrder(2))
      AC->(DbGoTop())
      AC->(DbSeek(Upper(cPeActivida)))
      lAcIva := AC->AcIva
      else
      if lFilter
         for i:=1 to Len(oAcMenu:aItems)
            if oAcMenu:aItems[i]:lChecked
               cPeActivida := oAcMenu:aItems[i]:cPrompt
            endif
         next
      endif
   endif

   if nMode == 3
      PE->(DbAppend())
      nRecAdd := PE->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "PEIEDIT" OF oParent;
      TITLE aTitle[ nMode ]
      oDlg:SetFont(oApp():oFont)

   REDEFINE AUTOGET aGet[01] VAR cPeActivida	;
      DATASOURCE {}						;
      FILTER AcList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 101 OF oDlg UPDATE            		;
      VALID AcClave( cPeActivida, aGet[01], 4, aGet, @lAcIVA, @lAcREquiv );
      COLOR oApp():cClrIng, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK ;
      WHEN ! lFilter

   REDEFINE BUTTON aGet[02] ID 102 OF oDlg ;
      ACTION AcSeleccion( cPeActivida, aGet[01], oDlg, aGet, @lAcIVA );
      WHEN ! lFilter

   REDEFINE AUTOGET aGet[03] VAR cPeCliente ;
      DATASOURCE {}						;
      FILTER ClList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 103 OF oDlg UPDATE                ;
      VALID ClClave( cPeCliente, aGet[03], 4, 1 );
      COLOR oApp():cClrIng, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

  	REDEFINE BUTTON aGet[04] ID 104 OF oDlg ;
      ACTION ClSeleccion( cPeCliente, aGet[3], oDlg )

   REDEFINE AUTOGET aGet[05] VAR cPeCatIngr ;
      DATASOURCE {}						;
      FILTER InList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE            ;
      VALID InClave( cPeCatIngr, aGet[5], 4, 2 );
      COLOR oApp():cClrIng, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

  	REDEFINE BUTTON aGet[06] ID 106 OF oDlg ;
      ACTION InSeleccion( cPeCatIngr, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[34] VAR cPeCuenta	;
      DATASOURCE {}						;
      FILTER CcList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 134 OF oDlg UPDATE            		;
		VALID CcClave( cPeCuenta, aGet[34], 4, aGet );
      COLOR oApp():cClrIng, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[35] ID 135 OF oDlg ;
		ACTION ccSeleccion( cPeCuenta, aGet[34], oDlg, aGet )

   REDEFINE GET aGet[07] VAR cPeConcepto;
      ID 107 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[08] VAR nPeImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 108 OF oDlg                   ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[8]:bValid := { || PeRecalc(nPeImpNeto, cPeIvaRep, nTIVA, cPeRecIng, nTRecEq, nPeImpTotal,aGet,oDlg,.f.) }
   aGet[8]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[8] ), .T. ) }

   REDEFINE COMBOBOX aGet[10] VAR cPeIvaRep ITEMS aIVA ;
      ID 109 OF oDlg ;
      ON CHANGE PeRecalc(nPeImpNeto, cPeIvaRep, nTIVA, cPeRecIng, nTRecEq, nPeImpTotal,aGet,oDlg,.f.);
      COLOR oApp():cClrIng, CLR_WHITE  ;
      WHEN lAcIVA

   REDEFINE GET aGet[09] VAR nTIVA    ;
      ID 110 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cPeRecIng ITEMS aRecEq ;
      ID 111 OF oDlg ;
      ON CHANGE PeRecalc(nPeImpNeto, cPeIvaRep, nTIVA, cPeRecIng, nTRecEq, nPeImpTotal,aGet,oDlg,.f.);
      COLOR oApp():cClrIng, CLR_WHITE ;
      WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTRecEq   ;
      ID 112 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[13] VAR nPeImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 113 OF oDlg UPDATE               ;
      COLOR oApp():cClrIng, CLR_WHITE
   aGet[13]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[13] ), .T. ) }

   REDEFINE BUTTON aGet[14] ID 114 OF oDlg ;
      ACTION PeRecalc(nPeImpNeto, cPeIvaRep, nTIVA, cPeRecIng, nTRecEq, nPeImpTotal,aGet,oDlg,.t.) ;
      WHEN lAcIva UPDATE
   aGet[14]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nPeGastosFi  ;
   PICTURE "@E 9,999,999.99"           ;
   ID 115 OF oDlg UPDATE               ;
   COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[16] VAR cPeObserv    ;
   MULTILINE ID 116 OF oDlg UPDATE     ;
   COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE COMBOBOX aGet[17] VAR cPePeriodic ITEMS aPeriod ;
   ID 117 OF oDlg

   REDEFINE CHECKBOX aGet[18] VAR aMeses[1] ID 118 OF oDlg
   REDEFINE CHECKBOX aGet[19] VAR aMeses[2] ID 119 OF oDlg
   REDEFINE CHECKBOX aGet[20] VAR aMeses[3] ID 120 OF oDlg
   REDEFINE CHECKBOX aGet[21] VAR aMeses[4] ID 121 OF oDlg
   REDEFINE CHECKBOX aGet[22] VAR aMeses[5] ID 122 OF oDlg
   REDEFINE CHECKBOX aGet[23] VAR aMeses[6] ID 123 OF oDlg
   REDEFINE CHECKBOX aGet[24] VAR aMeses[7] ID 124 OF oDlg
   REDEFINE CHECKBOX aGet[25] VAR aMeses[8] ID 125 OF oDlg
   REDEFINE CHECKBOX aGet[26] VAR aMeses[9] ID 126 OF oDlg
   REDEFINE CHECKBOX aGet[27] VAR aMeses[10] ID 127 OF oDlg
   REDEFINE CHECKBOX aGet[28] VAR aMeses[11] ID 128 OF oDlg
   REDEFINE CHECKBOX aGet[29] VAR aMeses[12] ID 129 OF oDlg

   REDEFINE GET aGet[30] VAR dPeFUltimo   ;
   ID 130 OF oDlg UPDATE               ;
   COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[31] ID 131 OF oDlg ;
   ACTION SelecFecha(@dPeFUltimo,aGet[30])

   REDEFINE GET aGet[32] VAR dPeFProximo  ;
   ID 132 OF oDlg UPDATE               ;
   COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[33] ID 133 OF oDlg ;
   ACTION SelecFecha(@dPeFProximo,aGet[32])

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
      if nMode == 2 .OR. nMode == 4
         PE->(DbGoTo(nRecPtr))
         else
         PE->(DbGoTo(nRecAdd))
      endif
      // ___ guardo el registro _______________________________________________//

      Replace PE->PeTipo     with "I"
      Replace PE->PeConcepto with cPeConcepto
      Replace PE->PeActivida with cPeActivida
		Replace PE->PeCuenta	  with cPeCuenta
      Replace PE->PeImpNeto  with nPeImpNeto
      Replace PE->PeObserv   with cPeObserv
      Replace PE->PeCliente  with cPeCliente
      Replace PE->PeCatIngr  with cPeCatIngr
      Replace PE->PeIvaRep   with VAL(StrTran(cPeIvaRep,",","."))
      Replace PE->PeImpTotal with nPeImpTotal
      Replace PE->PeGastosFi with nPeGastosFi
      Replace PE->PeRecIng   with VAL(StrTran(cPeRecIng,",","."))
      nPePeriodic := AScan(aPeriod, cPePeriodic)
      Replace PE->PePeriodic with nPePeriodic
      cPeMeses    := ''
      for i := 1 to 12
         cPeMeses := cPeMeses + iif(aMeses[i],'1','0')
      next
      Replace PE->PeMeses    with cPeMeses
      Replace PE->PeFUltimo  with dPeFUltimo
      Replace PE->PeFProximo with dPeFProximo

      PE->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         PE->(DbGoTo(nRecAdd))
         PE->(DbDelete())
         PE->(DbPack())
         PE->(DbGoTo(nRecPtr))
		elseif nMode == 4
			PE->(DbGoTo(nRecPtr))
			PE->(DbDelete())
			PE->(DbPack())
      endif
   endif

   SELECT PE
   if oCont != NIL
      RefreshCont(oCont,"PE")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//

function PeGEdita(oGrid,nMode,oCont,oParent,oAcMenu)
   local lCont := nMode == 1

   PeGEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu)
   do while lCont
      PeGEdita1(oGrid,nMode,oCont,oParent,@lCont,oAcMenu)
   enddo

return NIL
function PeGEdita1(oGrid,nMode,oCont,oParent,lCont,oAcMenu)
   local oDlg
   local aTitle   := { i18n( "Añadir un gasto periódico" ) ,;
                     i18n( "Modificar un gasto periódico") ,;
                     i18n( "Duplicar un gasto periódico")  ,;
	                  i18n( "Añadir un gasto periódico")  	}
   local aGet[35]
   local lAcIVA   := .t.
   local aIVA     := EjIvaArray("I", oApp():cEjercicio)
   local aRecEq   := EjIvaArray("E", oApp():cEjercicio)
   local aPeriod  := {"Anual", "Semestral", "Trimestral", "Bimestral", "Mensual"}

   local cPeNumero   ,;
         cPeConcepto ,;
         nPeImpNeto  ,;
         cPeObserv   ,;
         cPeProveed  ,;
         cPeCatGast  ,;
         cPeIvaSop   ,;
         cPeRecGas   ,;
         nPeGastosFi ,;
         nPeImpTotal	,;
         cPeActivida ,;
			cPeCuenta	,;
         nPePeriodic ,;
         cPePeriodic ,;
         cPeMeses    ,;
         dPeFUltimo  ,;
         dPeFProximo

   local nTIVA, nTRecEq
   local nRecPtr  := PE->(RecNo())
   local nOrden   := PE->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
   local lFilter  := ! (oAcMenu:aItems[1]:lChecked)
   local i
   local aMeses[12]

   if PE->(EOF()) .AND. nMode != 1
      retu NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      PE->(DbAppend())
      nRecAdd   := PE->(RecNo())
      Replace PE->PePeriodic With 1
      Replace PE->PeMeses With "000000000000"
   endif

   cPeConcepto := PE->PeConcepto
   cPeActivida := iif(nMode==1,oApp():cActividad,PE->PeActivida)
	cPeCuenta	:= PE->PeCuenta
   nPeImpNeto  := PE->PeImpNeto
   cPeObserv   := PE->PeObserv
   cPeProveed  := PE->PeProveed
   cPeCatGast  := PE->PeCatGast
   cPeIvaSop   := Tran(PE->PeIvaSop,"@E99.99")
   nPeImpTotal := PE->PeImpTotal
   nPeGastosFi := PE->PeGastosFi
   cPeRecGas   := Tran(PE->PeRecGas,"@E99.99")
   nPePeriodic := PE->PePeriodic
   cPePeriodic := aPeriod[Max(nPePeriodic,1)]
   cPeMeses    := PE->PeMeses
   dPeFUltimo  := PE->PeFUltimo
   dPeFProximo := PE->PeFProximo
   for i := 1 to 12
      aMeses[i] := SubStr(cPeMeses,i,1)=='1'
   next

   nTIVA       := nPeImpNeto * VAL(cPeIvaSop) / 100
   nTRecEq     := nPeImpNeto * VAL(cPeRecGas) / 100

   if nMode != 1
      AC->( DbSetOrder( 2 ) )
      AC->( DbGoTop() )
      AC->(DbSeek(Upper(cPeActivida)))
      lAcIva := AC->AcIva
      else
      if lFilter
         for i:=1 to Len(oAcMenu:aItems)
            if oAcMenu:aItems[i]:lChecked
               cPeActivida := oAcMenu:aItems[i]:cPrompt
            endif
         next
      endif
   endif

   if nMode == 3
      PE->(DbAppend())
      nRecAdd := Pe->(RecNo())
   endif

   // oAGet():Load()

   DEFINE DIALOG oDlg RESOURCE "PEGEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE AUTOGET aGet[01] VAR cPeActivida	;
      DATASOURCE {}						;
      FILTER AcList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 101 OF oDlg UPDATE            		;
      VALID AcClave( cPeActivida, aGet[01], 4, aGet, @lAcIVA );
      COLOR oApp():cClrGas, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK ;
      WHEN ! lFilter

   REDEFINE BUTTON aGet[02] ID 102 OF oDlg ;
      ACTION AcSeleccion( cPeActivida, aGet[01], oDlg, aGet, @lAcIVA );
      WHEN ! lFilter

   REDEFINE AUTOGET aGet[03] VAR cPeProveed  ;
      DATASOURCE {}						;
		FILTER PrList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
      ID 103 OF oDlg UPDATE                ;
      VALID PrClave( cPeProveed, aGet[03], 4, 1 );
		COLOR oApp():cClrGas, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK


   REDEFINE BUTTON aGet[04] ID 104 OF oDlg ;
      ACTION PrSeleccion( cPeProveed, aGet[3], oDlg )

   REDEFINE AUTOGET aGet[05] VAR cPeCatGast  ;
      DATASOURCE {}						;
      FILTER GaList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 105 OF oDlg UPDATE                ;
      VALID GaClave( cPeCatGast, aGet[05], 4, 2 );
      COLOR oApp():cClrGas, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[06] ID 106 OF oDlg ;
      ACTION GaSeleccion( cPeCatGast, aGet[5], oDlg )

   REDEFINE AUTOGET aGet[34] VAR cPeCuenta	;
      DATASOURCE {}						;
      FILTER CcList( uDataSource, cData, Self );     
      HEIGHTLIST 100 ;
      ID 134 OF oDlg UPDATE            		;
		VALID CcClave( cPeCuenta, aGet[34], 4, aGet );
      COLOR oApp():cClrGas, CLR_WHITE ;
      GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
      GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
      LINECOLOR oApp():nClrHL ;
      ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[35] ID 135 OF oDlg ;
		ACTION ccSeleccion( cPeCuenta, aGet[34], oDlg, aGet )

   REDEFINE GET aGet[07] VAR cPeConcepto;
      ID 107 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[08] VAR nPeImpNeto ;
      PICTURE "@E 9,999,999.99"        ;
      ID 108 OF oDlg                   ;
      COLOR oApp():cClrGas, CLR_WHITE
   aGet[8]:bValid := { || PeRecalc(nPeImpNeto, cPeIvaSop, nTIVA, cPeRecGas, nTRecEq, nPeImpTotal,aGet,oDlg,.f.) }
   aGet[8]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[8] ), .T. ) }

   REDEFINE COMBOBOX aGet[10] VAR cPeIvaSop ITEMS aIVA ;
      ID 109 OF oDlg ;
      ON CHANGE PeRecalc(nPeImpNeto, cPeIvaSop, nTIVA, cPeRecGas, nTRecEq, nPeImpTotal,aGet,oDlg,.f.);
      COLOR oApp():cClrGas, CLR_WHITE  ;
      WHEN lAcIVA

   REDEFINE GET aGet[09] VAR nTIVA    ;
      ID 110 OF oDlg UPDATE WHEN .f.  ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE COMBOBOX aGet[12] VAR cPeRecGas ITEMS aRecEq ;
      ID 111 OF oDlg ;
      ON CHANGE PeRecalc(nPeImpNeto, cPeIvaSop, nTIVA, cPeRecGas, nTRecEq, nPeImpTotal,aGet,oDlg,.f.);
      COLOR oApp():cClrGas, CLR_WHITE ;
      WHEN lAcIVA

   REDEFINE GET aGet[11] VAR nTRecEq   ;
      ID 112 OF oDlg UPDATE WHEN .f.   ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[13] VAR nPeImpTotal  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 113 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE
   aGet[13]:bKeyDown = {|nKey| IIF( nKey == VK_SPACE, ShowCalculator( aGet[13] ), .T. ) }

   REDEFINE BUTTON aGet[14] ID 114 OF oDlg ;
      ACTION PeRecalc(nPeImpNeto, cPeIvaSop, nTIVA, cPeRecGas, nTRecEq, nPeImpTotal,aGet,oDlg,.t.) ;
      WHEN lAcIva UPDATE
   aGet[14]:cTooltip := "realizar desglose del total"

   REDEFINE GET aGet[15] VAR nPeGastosFi  ;
      PICTURE "@E 9,999,999.99"           ;
      ID 115 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[16] VAR cPeObserv    ;
      MULTILINE ID 116 OF oDlg UPDATE     ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE COMBOBOX aGet[17] VAR cPePeriodic ITEMS aPeriod ;
   ID 117 OF oDlg

   REDEFINE CHECKBOX aGet[18] VAR aMeses[1] ID 118 OF oDlg
   REDEFINE CHECKBOX aGet[19] VAR aMeses[2] ID 119 OF oDlg
   REDEFINE CHECKBOX aGet[20] VAR aMeses[3] ID 120 OF oDlg
   REDEFINE CHECKBOX aGet[21] VAR aMeses[4] ID 121 OF oDlg
   REDEFINE CHECKBOX aGet[22] VAR aMeses[5] ID 122 OF oDlg
   REDEFINE CHECKBOX aGet[23] VAR aMeses[6] ID 123 OF oDlg
   REDEFINE CHECKBOX aGet[24] VAR aMeses[7] ID 124 OF oDlg
   REDEFINE CHECKBOX aGet[25] VAR aMeses[8] ID 125 OF oDlg
   REDEFINE CHECKBOX aGet[26] VAR aMeses[9] ID 126 OF oDlg
   REDEFINE CHECKBOX aGet[27] VAR aMeses[10] ID 127 OF oDlg
   REDEFINE CHECKBOX aGet[28] VAR aMeses[11] ID 128 OF oDlg
   REDEFINE CHECKBOX aGet[29] VAR aMeses[12] ID 129 OF oDlg

   REDEFINE GET aGet[30] VAR dPeFUltimo   ;
      ID 130 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[31] ID 131 OF oDlg ;
      ACTION SelecFecha(@dPeFUltimo,aGet[30])

   REDEFINE GET aGet[32] VAR dPeFProximo  ;
      ID 132 OF oDlg UPDATE               ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[33] ID 133 OF oDlg ;
      ACTION SelecFecha(@dPeFProximo,aGet[32])

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
      if nMode == 2 .OR. nMode == 4
         PE->(DbGoTo(nRecPtr))
      else
         PE->(DbGoTo(nRecAdd))
      endif
      // ___ guardo el registro _______________________________________________//

      Replace PE->PeTipo     with "G"
      Replace PE->PeConcepto with cPeConcepto
      Replace PE->PeActivida with cPeActivida
		Replace PE->PeCuenta	  with cPeCuenta
      Replace PE->PeImpNeto  with nPeImpNeto
      Replace PE->PeObserv   with cPeObserv
      Replace PE->PeProveed  with cPeProveed
      Replace PE->PeCatGast  with cPeCatGast
      Replace PE->PeIvaSop   with VAL(StrTran(cPeIvaSop,",","."))
      Replace PE->PeImpTotal with nPeImpTotal
      Replace PE->PeGastosFi with nPeGastosFi
      Replace PE->PeRecGas   with VAL(StrTran(cPeRecGas,",","."))
      nPePeriodic := AScan(aPeriod, cPePeriodic)
      Replace PE->PePeriodic with nPePeriodic
      cPeMeses    := ''
      for i := 1 to 12
         cPeMeses := cPeMeses + iif(aMeses[i],'1','0')
      next
      Replace PE->PeMeses    with cPeMeses
      Replace PE->PeFUltimo  with dPeFUltimo
      Replace PE->PeFProximo with dPeFProximo

      PE->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         PE->(DbGoTo(nRecAdd))
         PE->(DbDelete())
         PE->(DbPack())
         PE->(DbGoTo(nRecPtr))
      elseif nMode == 4
         PE->(DbGoTo(nRecPtr))
         PE->(DbDelete())
         PE->(DbPack())
      endif
   endif

   SELECT PE
   if oCont != NIL
      RefreshCont(oCont,"PE")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn

/*_____________________________________________________________________________*/

function PeBorra(oGrid,oCont)
   local nRecord := PE->(Recno())
   local nNext
   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este "+iif(PE->PeTipo=="I","ingreso","gasto")+" periódico ?")+CRLF+;
               "Concepto: "+PE->PeConcepto)
      SELECT PE
      PE->(DbSkip())
      nNext := PE->(Recno())
      PE->(DbGoto(nRecord))
      PE->(DbDelete())
      PE->(DbPack())
      PE->(DbGoto(nNext))
      if PE->(EOF()) .or. nNext == nRecord
         PE->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"PE")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
//-----------------------------------------------------------------------//

function PeTecla(nKey,oGrid,oCont,oDlg,oAcMenu)
Do case
   case nKey==VK_RETURN
      if PE->PeTipo == "I"
         PeIEdita(oGrid,2,oCont,oDlg,oAcMenu)
      else
         PeGEdita(oGrid,2,oCont,oDlg,oAcMenu)
      endif
   case nKey==VK_DELETE
      PeBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
EndCase
return nil
//-----------------------------------------------------------------------//

function PeBusca( oGrid, cChr, oCont, oParent, oAcMenu )
   local nOrder   := PE->(OrdNumber())
   local nRecno   := PE->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
   TITLE i18n("Búsqueda de apuntes")
   oDlg:oFont  := oApp():oFont

   switch nOrder
   case 1
      REDEFINE SAY PROMPT i18n( "Introduzca la actividad" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Actividad:" ) ID 21 OF Odlg
      cGet := space(60)
      exit
   case 2
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha del último apunte" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha:" ) ID 21 OF Odlg
      cGet := CtoD('')
      lFecha := .t.
      exit
   case 3
      REDEFINE SAY PROMPT i18n( "Introduzca la fecha del próximo apunte" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Fecha:" ) ID 21 OF Odlg
      cGet := CtoD('')
      lFecha := .t.
      exit
   case 4
      REDEFINE SAY PROMPT i18n( "Introduzca el concepto" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Concepto:" ) ID 21 OF Odlg
      cGet := space(90)
      exit
   case 5
      REDEFINE SAY PROMPT i18n( "Introduzca la cuenta" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Cuenta:" ) ID 21 OF Odlg
      cGet := space(20)
      exit
   case 6
      REDEFINE SAY PROMPT i18n( "Introduzca el tipo de ingreso" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Tipo Ingreso:" ) ID 21 OF Odlg
      cGet := space(40)
      exit
   case 7
      REDEFINE SAY PROMPT i18n( "Introduzca el pagador" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Pagador:" ) ID 21 OF Odlg
      cGet := space(40)
      exit
   case 8
      REDEFINE SAY PROMPT i18n( "Introduzca el tipo de gasto" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Tipo Gasto:" ) ID 21 OF Odlg
      cGet := space(40)
      exit
   case 9
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

   REDEFINE BUTTON ID IDOK OF oDlg  ;
   PROMPT i18n( "&Aceptar" )     ;
   ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
   PROMPT i18n( "&Cancelar" )    ;
   ACTION (lSeek := .f., oDlg:End())

   // sysrefresh()

   ACTIVATE DIALOG oDlg ;
   ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if lSeek
      if ! lFecha
         CursorWait()
         MsgRun('Realizando la búsqueda...', oApp():cVersion, ;
         { || PeWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
         CursorArrow()
         if len(aBrowse) == 0
            MsgStop("No se ha encontrado ningun apunte periódico.")
            PE->(DbGoTo(nRecno))
            else
            PeEncontrados(aBrowse, oApp():oDlg, oAcMenu)
         endif
      else
         if ! PE->(DbSeek(DtoS(cGet)))
            msgAlert( i18n( "Apunte periódico no encontrado." ) )
            PE->(DbGoTo(nRecno))
         endif
      endif
   endif

   PE->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "PE" )
   oGrid:refresh()
   oGrid:setFocus()
   oApp():nEdit--

return NIL
//-----------------------------------------------------------------------//

function PeWildSeek(nOrder, cGet, aBrowse)
   local nRecno := PE->(Recno())
   switch nOrder
      case 1
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeActivida)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 4
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeConcepto)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 5
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeCuenta)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 6
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeCatIngr)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 7
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeCliente)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 8
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeCatGast)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
      case 9
         PE->(DbGoTop())
         do while ! PE->(Eof())
            if cGet $ upper(PE->PeProveed)
               aadd(aBrowse, { PE->PeFUltimo, PE->PeFProximo, PE->PeActivida, PE->PeTipo, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->(Recno()) })
            endif
            PE->(DbSkip())
         enddo
         exit
   end
   PE->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| DtoS(aAut1[1]) < DtoS(aAut2[1]) } )
return nil
//-----------------------------------------------------------------------//

function PeEncontrados(aBrowse, oParent, oAcMenu)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := PE->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
   TITLE i18n( "Resultado de la búsqueda" ) ;
   OF oParent
   oDlg:oFont  := oApp():oFont

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader  := "F. Ultimo"
   oBrowse:aCols[1]:nWidth   := 62
   oBrowse:aCols[2]:cHeader  := "F. Próximo"
   oBrowse:aCols[2]:nWidth   := 62
   oBrowse:aCols[3]:cHeader  := "Actividad"
   oBrowse:aCols[3]:nWidth   := 130
   oBrowse:aCols[4]:cHeader  := "I/G"
   oBrowse:aCols[4]:nWidth   := 24
   oBrowse:aCols[5]:cHeader  := "Concepto"
   oBrowse:aCols[5]:nWidth   := 190
   oBrowse:aCols[6]:cHeader  := "Importe"
   oBrowse:aCols[6]:nWidth   := 75
   oBrowse:aCols[6]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[6]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[7]:lHide    := .t.
   oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,4] == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
	oBrowse:bClrSelFocus := {|| { CLR_WHITE, iif( aBrowse[oBrowse:nArrayAt,4] == "I", oApp():cClrIng, oApp():cClrGas ) } }
   oBrowse:lHScroll  := .f.
   oBrowse:nRowHeight:= 20

   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
      aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||PE->(DbGoTo(aBrowse[oBrowse:nArrayAt, 7])),;
         IIF(PE->PeTipo=='I',;
         PEIEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu ),;
         PEGEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu )),;
      PE->(DbGoTo(aBrowse[oBrowse:nArrayAt,7])) } })
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,PE->(DbGoTo(aBrowse[oBrowse:nArrayAt, 7])),;
      IIF(PE->PeTipo=='I',;
      APIEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu ),;
   APGEdita( oApp():oGrid, 2, , oApp():oDlg, oAcMenu )))}
   oBrowse:bChange    := { || PE->(DbGoTo(aBrowse[oBrowse:nArrayAt, 7])) }

   oDlg:oClient := oBrowse

   REDEFINE BUTTON oBtnOk ;
   ID IDOK OF oDlg     ;
   ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
   ID IDCANCEL OF oDlg ;
   ACTION (PE->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
   ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil
//-----------------------------------------------------------------------//

function PeApImprime(oGrid,oParent,oAcMenu)
   local nRecno   := PE->(Recno())
   local nOrder   := PE->(OrdSetFocus())
   local aCampos  := { "PETIPO", "PEACTIVIDA" , "PECONCEPTO", "PEIMPNETO", "PECLIENTE", "PECATINGR" ,;
                       "PEFULTIMO", "PEFPROXIMO", "PERECING", "PEIVAREP", "PEGASTOSFI", "PEIMPTOTAL",;
                       "PEPROVEED", "PECATGAST", "PERECGAS", "PEIVASOP" }
   local aTitulos := { "Apunte", "Actividad", "Concepto", "Imp. Neto", "Cliente", "Tipo Ing.",;
                       "F. Ultimo Ap.", "F. Próximo Ap.", "Rec. Ing.", "IVA Rep.", "Gastos Fin.", "Imp. Total",;
                       "Proveedor", "Tipo Gas.", "Rec. Gas.", "IVA Sop."  }
   local aWidth   := { 5, 40, 40, 15, 20, 20, 15, 15, 15, 15, 15, 20, 15, 15, 15, 15 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO","PE01","NO","NO","NO","NO","NO","NO","NO","PE02","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .t., .f., .f., .f., .f., .f.,.f.,.f., .t., .f., .f., .f., .f. }
   local oInforme
   local aControls[11]
   local aSay[4]
   local lGroup1  := .f.
   local cApCatIngr
   local lGroup2  := .f.
   local cApCliente
   local lPeriodo := .f.
   local dInicio, dFinal
   local aIng1    := {}
   local aIng2    := {}
   local aGas1    := {}
   local aGas2    := {}
   local nAt
   local nTotal   := 0
   local cActividad, i
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PEAP" )
   if ! oAcMenu:aItems[1]:lChecked
      for i:=1 to Len(oAcMenu:aItems)
         if oAcMenu:aItems[i]:lChecked
            cActividad := oAcMenu:aItems[i]:cPrompt
         endif
      next
   endif
   if cActividad != nil
      oInforme:cTitulo2:=cActividad
   endif
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   //REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
   //REDEFINE SAY aSay[2] ID 140 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[1] ID 151 OF oInforme:oFld:aDialogs[1]
   REDEFINE SAY aSay[2] ID 154 OF oInforme:oFld:aDialogs[1]

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
      if oInforme:nRadio == 1
         PE->(DbGoTop())
         oInforme:Report()
         if ! lPeriodo
            ACTIVATE REPORT oInforme:oReport
         endif
         oInforme:End(.t.)
      endif
      PE->(DbSetOrder(nOrder))
      PE->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//_____________________________________________________________________________*/

function PeRecalc(nApImpNeto, cApIva, nTIVA, cApRec, nTRecEq, nApImpTotal, aGet, oDlg, lDesglose)

   if lDesglose
      nApImpNeto  := nApImpTotal / (1+((VAL(cApIva)+VAL(cApRec))/100))
      nTIVA       := nApImpNeto * VAL(cApIva) / 100
      nTRecEq     := nApImpNeto * VAL(cApRec) / 100
      aGet[08]:cText(nApImpNeto)
      aGet[11]:cText(nTRecEq)
      aGet[09]:cText(nTIVA)
   else
      nTIVA       := nApImpNeto * VAL(cApIva) / 100
      nTRecEq     := nApImpNeto * VAL(cApRec) / 100
      nApImpTotal := nApImpNeto + nTIVA + nTRecEq

      aGet[09]:cText(nTIVA)
      aGet[11]:cText(nTRecEq)
      aGet[13]:cText(nApImpTotal)
   endif
   oDlg:Update()
return .t.
//_____________________________________________________________________________*/

function PePrevision(oGrid,oParent,oAcMenu)
   local nRecno   := PE->(Recno())
   local nOrder   := PE->(OrdSetFocus())
   local oDlg, aGet[9]
   local dInicio  := CtoD('01/01/'+oApp():cEjercicio)
   local dFinal   := CtoD('31/12/'+oApp():cEjercicio)
   local dMes
   local aBrowse  := {}
   local oBrowse, oBtnPrint, oBtnCancel
   local aSay[7]
   local nSumIng  := 0
   local nSumGas  := 0
   local oInforme
   local i

   oApp():nEdit ++
   DEFINE DIALOG oDlg RESOURCE "PEPREV01" OF oParent;
      TITLE "Previsión de ingresos y gastos por fecha"
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
      PE->(DbGoTop())
      while ! PE->(EoF())
         dMes := dInicio
         while dMes <= dFinal
            if SubStr(PE->PeMeses,Month(dMes),1)=='1'
               aadd(aBrowse,{PE->PeTipo, CtoD(StrZero(Day(PE->PeFUltimo),2)+'-'+StrZero(Month(dMes),2)+'-'+Str(Year(dMes),4)),;
                    PE->PeActivida, PE->PeConcepto, tran(PE->PeImpTotal,"@E 999,999.99"), PE->PeCuenta })
               if PE->PeTipo == 'I'
                  nSumIng += PE->PeImpTotal
               else
                  nSumGas += PE->PeImpTotal
               endif
            endif
            dMes += nDiasMes(dMes)
         enddo
         PE->(DbSkip())
      enddo
      PE->(DbSetOrder(nOrder))
      PE->(DbGoTo(nRecno))
      ASort( aBrowse,,, { |a1, a2| DtoS(a1[2]) < DtoS(a2[2]) } )
      DEFINE DIALOG oDlg RESOURCE "PEPREV02" ;
         TITLE i18n( "Previsión de ingresos y gastos" ) ;
         OF oParent
         oDlg:oFont  := oApp():oFont

         oBrowse := TXBrowse():New( oDlg )
         oBrowse:SetArray(aBrowse, .f.)
         oBrowse:aCols[1]:cHeader  := "I/G"
         oBrowse:aCols[1]:nWidth   := 30
         oBrowse:aCols[1]:nDataStrAlign := AL_CENTER
         oBrowse:aCols[1]:nHeadStrAlign := AL_CENTER
         oBrowse:aCols[2]:cHeader  := "Fecha Ap."
         oBrowse:aCols[2]:nWidth   := 62
         oBrowse:aCols[3]:cHeader  := "Actividad"
         oBrowse:aCols[3]:nWidth   := 110
         oBrowse:aCols[4]:cHeader  := "Concepto"
         oBrowse:aCols[4]:nWidth   := 180
         oBrowse:aCols[5]:cHeader  := "Importe"
         oBrowse:aCols[5]:nWidth   := 75
         oBrowse:aCols[5]:nDataStrAlign := AL_RIGHT
         oBrowse:aCols[5]:nHeadStrAlign := AL_RIGHT
         oBrowse:aCols[6]:cHeader  := "Cuenta"
         oBrowse:aCols[6]:nWidth   := 75
         Ut_BrwRowConfig( oBrowse )
         oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,1] == "I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
   		oBrowse:bClrSelFocus := {|| { CLR_WHITE, iif( aBrowse[oBrowse:nArrayAt,1] == "I", oApp():cClrIng, oApp():cClrGas ) } }
         oBrowse:lHScroll  := .t.
         oBrowse:nRowHeight:= 20

         oBrowse:CreateFromResource( 110 )
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
               TITLE  " "," ","Informe de previsión de Ingresos y gastos",;
                  "Periodo desde "+DtoC(dInicio)+" - "+DtoC(dFinal) CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser;
               FOOTER ' ', i18n("Fecha:")+" " + dTOc( date() ) + "   "+i18n("Página.:")+" " + str( oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + " - Relación de pagos previstos" PREVIEW
               i := 1
               COLUMN TITLE "I/G"   	  DATA aBrowse[i,1] SIZE  5 FONT 1
               COLUMN TITLE "Fecha Ap."  DATA aBrowse[i,2] SIZE 10 FONT 1
               COLUMN TITLE "Actividad"  DATA aBrowse[i,3] SIZE 28 FONT 1
               COLUMN TITLE "Concepto"   DATA aBrowse[i,4] SIZE 28 FONT 1
               COLUMN TITLE "Importe"    DATA aBrowse[i,5] SIZE 14 FONT 1 RIGHT
               COLUMN TITLE "Cuenta"     DATA aBrowse[i,6] SIZE 10 FONT 1
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
               ON END ( oReport:StartLine(), oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, 'Suma Ingresos: ', 1),;
                        oReport:Say(5, Transform(nSumIng, "@E 999,999.99"), 1, 1),;
                        oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, 'Suma Gastos: ', 1),;
                        oReport:Say(5, Transform(nSumGas, "@E 999,999.99"), 1, 1),;
                        oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:EndLine(),;
                        oReport:StartLine(),;
                        oReport:Say(4, 'Suma Ingresos - Gastos: ', 1),;
                        oReport:Say(5, Transform(nSumIng-nSumGas, "@E 999,999.99"), 1, 1),;
                        oReport:EndLine())
            oInforme:End(.f.)
         endif
   endif
   oApp():nEdit --
   PE->(DbSetOrder(nOrder))
   PE->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil