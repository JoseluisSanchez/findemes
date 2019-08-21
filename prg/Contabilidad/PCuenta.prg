**
* PROYECTO ...: Hemerot
* COPYRIGHT ..: (c) alanit software
* URL ........: www.alanit.com
**

#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "Splitter.ch"
#include "vMenu.ch"

//_____________________________________________________________________________//

function Cuentas()
   local oBar
   local oCol
	local aBrowse
   local cState := GetPvProfString("Browse", "CcState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "CcOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "CcRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "CcSplit","102", oApp():cIniFile))
   local oCont
   local i
	local aCCTipo:= {"Corriente", "Crédito"}

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

   SELECT CC
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de cuentas corrientes')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )
	// Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "CC"

   aBrowse   := { { { || CC->CcCuenta }, i18n("Cuenta"), 150, AL_LEFT, NIL },;
						{ { || CC->Ccbanco }, i18n("Banco"), 90, AL_LEFT, NIL },;
						{ { || CC->CcNCuenta }, i18n("Nº Cuenta"), 90, AL_LEFT, "9999.9999.99.9999999999" },;
						{ { || aCCTipo[Max(CC->CcTipo,1)] }, i18n("Tipo cuenta"), 90, AL_LEFT, NIL },;
						{ { || CC->CcFApertu }, i18n("F.Apertura"), 150, AL_LEFT, NIL },;
                  { { || CC->CcSaldoIn }, i18n("Saldo Inicial"), 120, AL_RIGHT, "@E 99,999,999.99" },;
 						{ { || CC->CcFUltimo }, i18n("F.Ultimo"), 150, AL_LEFT, NIL },;
						{ { || CC->CcSaldoAc }, i18n("Saldo Actual"), 120, AL_RIGHT, "@E 99,999,999.99" } }

   FOR i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      // oCol:bStrData := aBrowse[ i, 1 ]
		oCol:bEditValue :=  aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
		if aBrowse[i,5] != NIL
			oCol:cEditPicture := aBrowse[i,5]
		endif
      oCol:bLDClickData  := {|| CcEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| CcEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"CC") }
   oApp():oGrid:bKeyDown := {|nKey| CcTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:bClrStd 	 := {|| { oApp():cClrCC, CLR_WHITE } }
	oApp():oGrid:bClrRowFocus := { || { oApp():cClrCC, oApp():nClrHL } }	 
	oApp():oGrid:bClrSelFocus := { || { oApp():cClrCC, oApp():nClrHL } }
   oApp():oGrid:RestoreState( cState )

   CC->(DbSetOrder(nOrder))
   CC->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont   ;
      CAPTION tran(CC->(OrdKeyNo()),'@E 999,999')+" / "+tran(CC->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24            ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_CUENTA"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 190 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar       ;
      CAPTION "  cuentas corrientes" ;
      HEIGHT 24               ;
		COLOR GetSysColor(9), oApp():nClrBar 

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 10 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nueva"              ;
      IMAGE "16_nuevo"             ;
      ACTION CcEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION CcEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION CcBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION CcBusca(oApp():oGrid,,oCont) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION CcImprime(oApp():oDlg);
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Comprobar saldo"    ;
      IMAGE "16_selecc"             ;
      ACTION CcSaldo( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver apuntes"     ;
      IMAGE "16_apuntes"        ;
      ACTION CcApuntes( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver traspasos"      ;
      IMAGE "16_traspasos"         ;
      ACTION CcTraspasos( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

/*
   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), oApp():oGrid:ToExcel(), CursorArrow());
      LEFT 10
*/

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Cuentas corrientes" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "CcState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Cuentas ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              CC->(DbSetOrder(nOrder)),;
              CC->(DbGoTop())         ,;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont, "CC") )

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
              WritePProString("Browse","CcState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","CcOrder",Ltrim(Str(Cc->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","CcRecno",Ltrim(Str(Cc->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","CcSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, .t. )

return NIL
//_____________________________________________________________________________//

function CcEdita( oGrid, nMode, oCont, oParent, cCuenta )
   local oDlg, oFld, oBmp
   local aTitle := { i18n( "Añadir cuenta corriente" )   ,;
                     i18n( "Modificar cuenta corriente") ,;
                     i18n( "Duplicar cuenta corriente") }
   local aGet[9]
   local cCcCuenta, cCcBanco, cCcNCuenta, nCcTipo, dCcFApertu, nCcSaldoIn, dCcFUltimo, nCcSaldoAc
   local nRecPtr  := CC->(RecNo())
   local nOrden   := CC->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if CC->(EOF()) .AND. nMode != 1
      retu NIL
   endif

   oApp():nEdit ++

   if nMode == 1
      CC->(DbAppend())
      nRecAdd  := CC->(RecNo())
		if cCuenta != NIL
			replace CC->CcCuenta with cCuenta
		endif
   endif
   cCcCuenta	:= CC->CcCuenta
	cCcBanco		:= CC->CcBanco
	cCcNCuenta	:= CC->CcNCuenta
	nCcTipo 		:= Max(1,CC->CCTipo)
	dCcFApertu	:= CC->CcFApertu
	nCcSaldoIn	:= CC->CcSaldoIn
	dCcFUltimo	:= CC->CcFUltimo
	nCcSaldoAc	:= CC->CcSaldoAc

	if nMode == 3
      CC->(DbAppend())
      nRecAdd := Cc->(RecNo())
   endif

   if oParent == NIL
      oParent := oApp():oDlg
   endif

   DEFINE DIALOG oDlg RESOURCE "CcEDIT"   ;
      TITLE aTitle[ nMode ]               ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY ID 201 OF oDlg
   REDEFINE GET aGet[1] VAR cCcCuenta    ;
      ID 101 OF oDlg UPDATE              ;
      VALID CcClave( cCcCuenta, aGet[1], nMode );
      COLOR oApp():cClrCc, CLR_WHITE

   REDEFINE SAY ID 202 OF oDlg
   REDEFINE GET aGet[2] VAR cCcBanco     ;
      ID 102 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE

   REDEFINE SAY ID 203 OF oDlg
   REDEFINE GET aGet[3] VAR cCcNCuenta   ;
		PICTURE "9999.9999.99.9999999999"  ;
      ID 103 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		VALID ValidaCuenta(cCcNCuenta)

	REDEFINE SAY ID 208 OF oDlg
	REDEFINE RADIO aGet[9] VAR nCCTipo ID 109, 110 OF oDlg

	REDEFINE SAY ID 204 OF oDlg
   REDEFINE GET aGet[4] VAR dCcFApertu   ;
      ID 104 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN nMode == 1
   REDEFINE BUTTON aGet[5] ID 105 OF oDlg ;
      ACTION SelecFecha(@dCcFApertu,aGet[4]) ;
		WHEN nMode == 1

	REDEFINE SAY ID 205 OF oDlg
   REDEFINE GET aGet[6] VAR nCcSaldoIn   ;
      ID 106 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN nMode == 1

	REDEFINE SAY ID 206 OF oDlg
   REDEFINE GET aGet[7] VAR dCcFUltimo   ;
      ID 107 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN .f.

	REDEFINE SAY ID 207 OF oDlg
   REDEFINE GET aGet[8] VAR nCcSaldoAc   ;
      ID 108 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN .f.

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
      lReturn := .t.
      if nMode == 2
         CC->(DbGoTo(nRecPtr))
      else
         CC->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo la cuenta en los apuntes y apuntes periódicos _______//
      if nMode == 2
         if CC->CcCuenta != cCcCuenta
            msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
                  { || CcCambiaClave( cCcCuenta, CC->CcCuenta ) } )
         endif
      endif
      // ___ guardo el registro _______________________________________________//
      Select CC
      Replace CC->CcCuenta		with cCcCuenta
      Replace CC->CcBanco		with cCcBanco
		Replace CC->CcNCuenta	with cCcNCuenta
		Replace CC->CcTipo  		with nCcTipo
		Replace CC->CCFApertu	with dCcFApertu
		Replace CC->CCSaldoIn	with nCCSaldoIn
		if nMode == 1
			Replace CC->CCFUltimo	with dCcFApertu
			Replace CC->CCSaldoAc	with nCCSaldoIn
		endif
      CC->( DbCommit() )
      if cCuenta != NIL
         cCuenta := CC->CcCuentar
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         CC->(DbGoTo(nRecAdd))
         CC->(DbDelete())
         CC->(DbPack())
         CC->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT CC

   if oCont != NIL
      RefreshCont(oCont,"CC")
   endif
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

   oApp():nEdit --

return lReturn
//_____________________________________________________________________________//

function CcBorra(oGrid,oCont)
   local nRecord  := CC->(Recno())
   local cKeyNext
   local nAuxRecno
   local nAuxOrder

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta cuenta ?") + CRLF + ;
                (trim(CC->CcCuenta)))
      msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || CcCambiaClave( SPACE(20), CC->CcCuenta ) } )
      // borrado de la tipo de documento
      CC->(DbSkip())
      cKeyNext := CC->(OrdKeyVal())
      CC->(DbGoto(nRecord))
      CC->(DbDelete())
      CC->(DbPack())
      if cKeyNext != NIL
         CC->(DbSeek(cKeyNext))
      else
         CC->(DbGoBottom())
      endif
   endif
   if oCont != NIL
      RefreshCont(oCont,"CC")
   endif

   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil
//_____________________________________________________________________________//

function CcTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      CcEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      CcEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      CcBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         CcBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         CcBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase

return nil

//_____________________________________________________________________________//

function CcSeleccion( cGasto, oControl, oParent )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := CC->( RecNo() )
   local nOrder := CC->( OrdNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""
	local aCcTipo:= {"Corriente", "Crédito"}

   oApp():nEdit ++
   CC->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "CcAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de cuentas" )      ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "CC"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || CC->CcCuenta }
   oCol:cHeader  := i18n( "Cuenta" )
   oCol:nWidth   := 100
   oCol := oBrowse:AddCol()
   oCol:bStrData := { || aCcTipo[Max(CC->CcTipo,1)] }
   oCol:cHeader  := i18n( "Tipo" )
   oCol:nWidth   := 80
   oCol := oBrowse:AddCol()
   oCol:bStrData := { || Tran(CC->CcSaldoAc,"@E 99,999,999.99") }
   oCol:cHeader  := i18n( "Saldo" )
   oCol:nWidth   := 90
	oCol:nDataStrAlign := AL_RIGHT
   oCol:nHeadStrAlign := AL_RIGHT

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| InTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }
	oBrowse:bClrSelFocus := { || { oApp():cClrCC, { { 1, RGB( 220, 235, 252 ), RGB( 193, 219, 252 ) } } } }
	// oBrowse:bClrSelFocus := {|| { CLR_WHITE, oApp():cClrCC } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION CcEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION CcEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION CcBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION CcBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      oControl:cText := CC->CcCuenta
   endif

   SetIni( , "Browse", "CcAux", oBrowse:SaveState() )
   CC->( DbSetOrder( nOrder ) )
   CC->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return nil
//_____________________________________________________________________________//

function CcHaySaldo( cCuenta, nImporte, nMode, cCuentaAnt, nImporteAnt, cApIvaSop, nTIVA, cApRecGas, nTRecEq, nApImpTotal,aGet,oDlg )
	local lHaySaldo := .t.
	if nMode != 2
		CC->(DbSeek(Upper(cCuenta)))
		if (nImporte > CC->CcSaldoAc) .and. (CC->CcTipo==1)
			MsgStop("No hay saldo suficiente en la cuenta."+CRLF+"El saldo de la cuenta es de "+tran(CC->CcSaldoAc,"@E 999,999.99"))
			lHaySaldo := .f.
		endif
	else
		if cCuenta == cCuentaAnt
			CC->(DbSeek(Upper(cCuenta)))
			if ((nImporte - nImporteAnt) > CC->CcSaldoAc) .and. (CC->CcTipo==1)
				MsgStop("No hay saldo suficiente en la cuenta."+CRLF+"El saldo de la cuenta es de "+tran(CC->CcSaldoAc,"@E 999,999.99"))
				lHaySaldo := .f.
			endif
		else
			CC->(DbSeek(cCuenta))
			if (nImporte > CC->CcSaldoAc) .and. (CC->CcTipo==1)
				MsgStop("No hay saldo suficiente en la cuenta."+CRLF+"El saldo de la cuenta es de "+tran(CC->CcSaldoAc,"@E 999,999.99"))
				lHaySaldo := .f.
			endif
		endif
	endif
	if lHaySaldo == .t. .and. aGet != NIL
		ApRecalc(nImporte, cApIvaSop, nTIVA, cApRecGas, nTRecEq, nApImpTotal, aGet, oDlg, .f.)
	endif
return lHaySaldo
//_____________________________________________________________________________//

function CcBusca( oGrid, cChr, oCont, oParent )
   local nOrder   := CC->(OrdNumber())
   local nRecno   := CC->(Recno())
   local oDlg, oGet, cPicture
   local aSay1    := "Introduzca la cuenta corriente a buscar"
   local aSay2    := "Cuenta corriente:"
   local cGet     := space(40)
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA'   ;
      TITLE i18n("Búsqueda de cuenta corriente") OF oParent
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT aSay1 ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2 ID 21 OF Odlg

   //__ si he pasado un caracter lo meto en la cadena a buscar ________________//

   if cChr != NIL
      if .NOT. lFecha
         cGet := cChr+SubStr(cGet,1,len(cGet)-1)
      else
         cGet := CtoD(cChr+' -  -    ')
      endif
   endif

   if ! lFecha
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg COLOR oApp():cClrCC, CLR_WHITE
   else
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg COLOR oApp():cClrCC, CLR_WHITE
   endif

   if cChr != NIL
      oGet:bGotFocus := { || ( oGet:SetColor( CLR_BLACK, RGB(255,255,127) ), oGet:SetPos(2) ) }
   endif

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION oDlg:End()

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if lSeek
      if ! lFecha
         cGet := rTrim( upper( cGet ) )
      else
         cGet := dTOs( cGet )
      end if
      MsgRun('Realizando la búsqueda...', oApp():cAppName+oApp():cVersion, ;
         { || CcWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ninguna cuenta corriente")
      else
         CcEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   CC->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "CC" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function CcWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := CC->(Recno())

   do case
      case nOrder == 1
         CC->(DbGoTop())
         do while ! CC->(eof())
            if cGet $ upper(CC->CcCuenta)
               aadd(aBrowse, { CC->CcCuenta })
            endif
            CC->(DbSkip())
         enddo
   end case
   CC->(DbGoTo(nRecno))
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/
function CcEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := CC->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Cuenta corriente"
   oBrowse:aCols[1]:nWidth  := 220
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
   Cc->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||CC->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           CcEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(Cc->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     CcEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || GA->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (GA->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

//_____________________________________________________________________________//

function CcCambiaClave( cVar, cOld )

   local nOrder
   local nRecNo
   // cambio la cuenta de apuntes
   Select AP
   nRecno := AP->(RecNo())
   nOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApCuenta    ;
      with cVar            ;
      for Upper(Rtrim(AP->ApCuenta)) == Upper(rtrim(cOld))
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
	// cambio la cuenta de apuntes periódicos
   Select PE
   nRecno := PE->(RecNo())
   nOrder := PE->(OrdNumber())
   PE->(DbSetOrder(0))
   PE->(DbGoTop())
   Replace PE->PeCuenta    ;
      with cVar            ;
      for Upper(Rtrim(PE->PeCuenta)) == Upper(rtrim(cOld))
   PE->(DbSetOrder(nOrder))
   PE->(DbGoTo(nRecno))
	// cambio la cuenta de transferencias
	Select TR
	nRecno := TR->(RecNo())
	nOrder := TR->(OrdNumber())
	TR->(DbSetOrder(0))
	TR->(DbGoTop())
	Replace TR->TrCC1    ;
		with cVar            ;
		for Upper(Rtrim(TR->TrCC1)) == Upper(rtrim(cOld))
	TR->(DbGoTop())
	Replace TR->TrCC2    ;
		with cVar            ;
		for Upper(Rtrim(TR->TrCC2)) == Upper(rtrim(cOld))
	TR->(DbSetOrder(nOrder))
	TR->(DbGoTo(nRecno))

return nil

//_____________________________________________________________________________//

function CcClave( cCuenta, oGet, nMode )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
	//				5 clave ajena obligatoria
   local lReturn  := .f.
   local nRecno   := CC->( RecNo() )
   local nOrder   := CC->( OrdNumber() )
   local nArea    := Select()

   if Empty( cCuenta )
      if nMode == 4 .or. nMode == 5
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT CC
   CC->( DbSetOrder( 1 ) )
   CC->( DbGoTop() )

   if CC->( DbSeek( UPPER( cCuenta ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Cuenta existente.")
         Case nMode == 2
            if CC->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Cuenta existente.")
            endif
         Case nMode == 4 .OR. nMode == 5
				IF ! oApp():thefull
					Registrame()
				ENDIF
            lReturn := .t.
      END CASE
   else
      if nMode < 4 .or. nMode == 5
         lReturn := .t.
      else
         if MsgYesNo("Cuenta inexistente. ¿ Desea darla de alta ahora? ")
            lReturn := CcEdita( , 1, , , @cCuenta )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      oGet:cText( space(20) )
   else
      oGet:cText( cCuenta )
   endif

   CC->( DbGoTo( nRecno ) )
   Select (nArea)
return lReturn
//_____________________________________________________________________________//

function CcApuntes( oGrid, oParent )
   local cApCuenta := CC->CcCuenta
	local nApOrder  := AP->(OrdSetFocus())
	local nApRecno  := AP->(RecNo())
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT AP
	AP->(DbSetOrder(4))
	AP->(DbGoTop())
   if ! AP->(DbSeek(upper(cApCuenta)))
      MsgStop("La cuenta no aparece en ningún apunte.")
      RETU NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Apuntes de la cuenta: '+rtrim(cApCuenta) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApCuenta) == upper(cApCuenta)
         aadd(aBrowse, { AP->ApTipo, AP->ApFecha, AP->ApActivida, AP->ApConcepto, tran(AP->ApImpTotal,"@E 999,999.99"), AP->(Recno())  })
      endif
      AP->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[2]) < dtos(aApu2[2]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader  := "Tipo"
   oBrowse:aCols[1]:nWidth   := 20
   oBrowse:aCols[2]:cHeader  := "Fecha"
   oBrowse:aCols[2]:nWidth   := 60
   oBrowse:aCols[3]:cHeader  := "Actividad"
   oBrowse:aCols[3]:nWidth   := 140
   oBrowse:aCols[4]:cHeader  := "Concepto"
   oBrowse:aCols[4]:nWidth   := 220
   oBrowse:aCols[5]:cHeader  := "Importe total"
   oBrowse:aCols[5]:nWidth   := 80
   oBrowse:aCols[5]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[5]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[6]:lHide    := .t.

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || (AP->(DbGoTo(aBrowse[oBrowse:nArrayAt,6])),;
            iif(aBrowse[oBrowse:nArrayAt,1]=="I", ApIEdita1(,2,,oDlg,.f.), ApGEdita1(,2,,oDlg,.f.))) } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { iif( aBrowse[oBrowse:nArrayAt,1]=="I", oApp():cClrIng, oApp():cClrGas ), CLR_WHITE } }
   // oBrowse:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

	AP->(DbSetOrder(nApOrder))
	AP->(DbGoTo(nApRecno))

   SELECT CC
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return NIL

//_____________________________________________________________________________//

function CcTraspasos( oGrid, oParent )
	local cTrCuenta := CC->CcCuenta
	local nTrOrder  := Tr->(OrdSetFocus())
	local nTrRecno  := Tr->(RecNo())
	local oDlg, oBrowse, oCol
	local aBrowse := {}

	SELECT TR

	TR->(DbGoTop())
	do while ! TR->(EOF())
		if upper(TR->TrCC1) == upper(cTrCuenta) .or. upper(TR->TrCC2) == upper(cTrCuenta)
			aadd(aBrowse, { TR->TrCC1, TR->TrCC2, TR->TrFecha, tran(TR->TrImporte,"@E 999,999.99"), TR->(Recno()) })
		endif
		TR->(DbSkip())
	enddo
	if len(aBrowse) == 0
      MsgStop("La cuenta no aparece en ningún traspaso.")
      RETU NIL
	endif
	oApp():nEdit ++

	DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
		TITLE 'Traspasos de la cuenta: '+rtrim(cTrCuenta) OF oParent
	oDlg:SetFont(oApp():oFont)

	ASort( aBrowse,,, { |aTr1, aTr2| dtos(aTr1[3]) < dtos(aTr2[3]) } )
	oBrowse := TXBrowse():New( oDlg )
	Ut_BrwRowConfig( oBrowse )
	oBrowse:SetArray(aBrowse, .f.)
	oBrowse:aCols[1]:cHeader  := "Cuenta origen"
	oBrowse:aCols[1]:nWidth   := 90
	oBrowse:aCols[2]:cHeader  := "Cuenta destino"
	oBrowse:aCols[2]:nWidth   := 90
	oBrowse:aCols[3]:cHeader  := "Fecha"
	oBrowse:aCols[3]:nWidth   := 90
	oBrowse:aCols[4]:cHeader  := "Importe"
	oBrowse:aCols[4]:nWidth   := 220
	oBrowse:aCols[4]:nDataStrAlign := AL_RIGHT
	oBrowse:aCols[4]:nHeadStrAlign := AL_RIGHT
	oBrowse:aCols[5]:lHide    := .t.

	aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || (TR->(DbGoTo(aBrowse[oBrowse:nArrayAt,5])),;
			TrEdita(,2,,oDlg,.f.)) } } )

	oBrowse:lHScroll := .f.
	oBrowse:SetRDD()
	oBrowse:CreateFromResource( 110 )
	oDlg:oClient := oBrowse
	oBrowse:nRowHeight := 20
	oBrowse:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }

	REDEFINE BUTTON ID IDOK OF oDlg ;
		PROMPT i18n( "&Aceptar" )   ;
		ACTION oDlg:End()

	ACTIVATE DIALOG oDlg ;
		ON INIT DlgCenter(oDlg,oApp():oWndMain)

	TR->(DbSetOrder(nTrOrder))
	TR->(DbGoTo(nTrRecno))

	SELECT CC
	oGrid:Refresh()
	oGrid:SetFocus(.t.)
	oApp():nEdit --
return NIL

//_____________________________________________________________________________//

function CcSaldo(oGrid, oParent)
   local cCcCuenta 	:= CC->CcCuenta
   local nCcSaldoIn 	:= CC->CcSaldoIn
	local nCcSaldoAc	:= nCcSaldoIn
	local dCcFUltimo	:= CC->CcFApertu
	local nApOrder  := AP->(OrdSetFocus())
	local nApRecno  := AP->(RecNo())
	local nTrOrder  := TR->(OrdSetFocus())
	local nTrRecno  := TR->(RecNo())

	if CC->(OrdKeyCount()) == 0
		MsgStop("No hay ninguna cuenta dada de alta.")
		retu nil
	endif
	SELECT AP
	AP->(DbSetOrder(4))
	AP->(DbGoTop())

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApCuenta) == upper(cCcCuenta) .AND. AP->ApFecha >= CC->CcFApertu
			if (AP->ApTipo == 'I')
				nCcSaldoAc := nCcSaldoAc + AP->ApImpTotal
			elseif (AP->ApTipo == 'G')
				nCcSaldoAc := nCcSaldoAc - AP->ApImpTotal
			endif
			if AP->ApFecha > dCcFUltimo
				dCcFUltimo := AP->ApFecha
			endif
      endif
      AP->(DbSkip())
   enddo
	TR->(DbGoTop())
   do while ! TR->(EOF())
      if upper(TR->TrCC1) == upper(cCcCuenta) .AND. TR->TrFecha >= CC->CcFApertu
			nCcSaldoAc := nCcSaldoAc - TR->TrImporte
			if TR->TrFecha > dCcFUltimo
				dCcFUltimo := TR->TrFecha
			endif
      endif
		if upper(TR->TrCC2) == upper(cCcCuenta) .AND. TR->TrFecha >= CC->CcFApertu
			nCcSaldoAc := nCcSaldoAc + TR->TrImporte
			if TR->TrFecha > dCcFUltimo
				dCcFUltimo := TR->TrFecha
			endif
      endif
      TR->(DbSkip())
   enddo
	if CC->CcSaldoAc != nCcSaldoAc
		if msgYesNo("El saldo real de la cuenta es "+tran(nCcSaldoAc, "@E 9,999,999.99")+"€."+CRLF+;
				"¿ Desea modificarlo en la cuenta ?")
			Cc->CcSaldoAc := nCcSaldoAc
		endif
	endif
	if CC->CcFUltimo != dCcFUltimo
		if msgYesNo("La fecha real del último apunte o taspaso es "+DtoC(dCcFUltimo)+"."+CRLF+;
				"¿ Desea modificarlo en la cuenta ?")
			Cc->CcFUltimo := dCcFUltimo
		endif
	endif
	AP->(DbSetOrder(nApOrder))
	AP->(DbGoTo(nApRecno))
	TR->(DbSetOrder(nApOrder))
	TR->(DbGoTo(nApRecno))
	MsgInfo("Comprobación de saldo finalizada.")
	SELECT CC
   oGrid:Refresh()
   oGrid:SetFocus(.t.)

return nil
//_____________________________________________________________________________//
function CcImprime( oGrid )
   local nRecno   := CC->(Recno())
   local nOrder   := CC->(OrdSetFocus())
   local aCampos  := { "CcCuenta", "CcBanco", "CcNCuenta", "CcFApertu", "CcSaldoIn", "CcFUltimo", "CcSaldoAc" }
   local aTitulos := { "Cuenta", "Banco", "Nº Cuenta", "F. Apertura", "S. Inicial", "F. Ultimo", "S. Actual"  }
   local aWidth   := { 40, 20, 20, 12, 12, 12, 12 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t.	}
   local aPicture := { "NO", "NO", "NO", "NO", "@E 9,999,999.99", "NO", "@E 9,999,999.99" }
   local aTotal   := { .f., .f., .f., .f., .t., .f., .t. }
   local oInforme

   Select CC
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "CC" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      CC->(DbGoTop())
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                  oInforme:oReport:Say(1, 'Total cuentas: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                  oInforme:oReport:EndLine() )
      oInforme:End(.t.)
      CC->(DbGoTo(nRecno))
   endif

   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return nil

//_____________________________________________________________________________//

function CcIsDbfEmpty()
   local lReturn := .f.
   if CC->( ordKeyVal() ) == nil
      msgStop( i18n( "No hay ninguna cuenta corriente registrada." ) )
      lReturn := .t.
   endif

RETURN lReturn
//_____________________________________________________________________________//
//
function ValidaCuenta(Cuenta)
   local lReturn := .t.
   local nControl1, nControl2 as numeric
   local nresto1, nresto2 as numeric

	if Len(Rtrim(Cuenta))<23
      MsgStop("Cuenta incorrecta. Por favor revisela.")
		retu .f.
	endif

   nControl1 := Val(SubStr(Cuenta,1,1))*4+;
                Val(SubStr(Cuenta,2,1))*8+;
                Val(SubStr(Cuenta,3,1))*5+;
                Val(SubStr(Cuenta,4,1))*10+;
                Val(SubStr(Cuenta,6,1))*9+;
                Val(SubStr(Cuenta,7,1))*7+;
                Val(SubStr(Cuenta,8,1))*3+;
                Val(SubStr(Cuenta,9,1))*6
   nResto1 := 11 - (nControl1%11)
   if nResto1 == 11
      nResto1 := 0
   elseif nResto1 == 10
      nResto1 := 1
   endif
   nControl2 := Val(SubStr(Cuenta,14,1))*1+;
                Val(SubStr(Cuenta,15,1))*2+;
                Val(SubStr(Cuenta,16,1))*4+;
                Val(SubStr(Cuenta,17,1))*8+;
                Val(SubStr(Cuenta,18,1))*5+;
                Val(SubStr(Cuenta,19,1))*10+;
                Val(SubStr(Cuenta,20,1))*9+;
                Val(SubStr(Cuenta,21,1))*7+;
                Val(SubStr(Cuenta,22,1))*3+;
                Val(SubStr(Cuenta,23,1))*6
   nresto2 := 11 - (nControl2%11)
   if nResto2 == 11
      nResto2 := 0
   elseif nResto2 == 10
      nResto2 := 1
   endif
   if nResto1 != Val(Substr(Cuenta,11,1)) .OR. ;
      nResto2 != Val(Substr(Cuenta,12,1))
      MsgStop("Cuenta incorrecta. Por favor revísela.")
      lReturn := .f.
   endif
return lReturn

function CcList( aList, cData, oSelf )
   local aNewList := {}
   CC->( dbSetOrder(1) )
   CC->( dbGoTop() )
   while ! CC->(Eof())
      if at(Upper(cdata), Upper(CC->CcCuenta)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { CC->CcCuenta } )
      endif 
      CC->(DbSkip())
   enddo
return aNewlist

// _____________________________________________________________________________//

FUNCTION CcIngreso(cCuenta, nImporte, dFecha)
   LOCAL cAlias   := Alias()
   SELECT CC
   IF CC->( dbSeek( Upper( cCuenta ) ) )
      REPLACE CC->CcSaldoAc WITH CC->CcSaldoAc + nImporte
      IF CC->CcFUltimo < dFecha
         REPLACE CC->CcFUltimo WITH dFecha
      ENDIF
      CC->(dbCommit())
   ELSEIF ! Empty(cCuenta) 
      MsgAlert( Rtrim(cCuenta)+'* Cuenta no encontrada.' )
   ENDIF
   SELECT (cAlias)
   RETURN NIL

FUNCTION CcDisposic(cCuenta, nImporte, dFecha)
   LOCAL cAlias   := Alias()
   SELECT CC
   IF CC->( dbSeek( Upper( cCuenta ) ) )
      REPLACE CC->CcSaldoAc WITH CC->CcSaldoAc - nImporte
      IF CC->CcFUltimo < dFecha
         REPLACE CC->CcFUltimo WITH dFecha
      ENDIF
      CC->(dbCommit())
   ELSEIF ! Empty(cCuenta)
      MsgAlert( Rtrim(cCuenta)+'* Cuenta no encontrada.' )
   ENDIF
   SELECT (cAlias)
   RETURN NIL
// _____________________________________________________________________________//