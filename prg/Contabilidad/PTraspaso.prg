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
#include "AutoGet.ch"

//_____________________________________________________________________________//

function Traspasos()
   local oBar
   local oCol
	local aBrowse
   local cState := GetPvProfString("Browse", "TrState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "TrOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "TrRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "TrSplit","102", oApp():cIniFile))
   local oCont
   local i

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
   oApp():oDlg:cTitle := i18n('Gestión de traspasos entre cuentas corrientes')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "TR"

   aBrowse   := { { { || TR->TrCC1 }, i18n("Cuenta origen"), 150, AL_LEFT, NIL },;
						{ { || TR->TrCC2 }, i18n("Cuenta destino"), 150, AL_LEFT, NIL },;
						{ { || TR->TrFecha }, i18n("Fecha traspaso"), 150, AL_LEFT, NIL },;
						{ { || TR->TrImporte }, i18n("Importe"), 120, AL_RIGHT, "@E 99,999,999.99" } }

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
      oCol:bLDClickData  := {|| TrEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| TrEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"TR") }
   oApp():oGrid:bKeyDown := {|nKey| TrTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
	oApp():oGrid:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }
	oApp():oGrid:bClrRowFocus := { || { oApp():cClrCC, oApp():nClrHL } } 
   oApp():oGrid:bClrSelFocus := { || { oApp():cClrCC, oApp():nClrHL } }
   oApp():oGrid:RestoreState( cState )

   TR->(DbSetOrder(nOrder))
   TR->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont   ;
      CAPTION tran(TR->(OrdKeyNo()),'@E 999,999')+" / "+tran(TR->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24            ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_TRASPASOS"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 150 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar       ;
      CAPTION "  traspasos entre cuentas corrientes" ;
      HEIGHT 24               ;
		COLOR GetSysColor(9), oApp():nClrBar 

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 10 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION TrEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION TrEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION TrBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION TrBusca(oApp():oGrid,,oCont) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION TrImprime(oApp():oDlg);
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
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Traspasos entre cuentas corrientes" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "TrState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Cuenta origen ', ' Cuenta destino ', ' Fecha ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              TR->(DbSetOrder(nOrder)),;
              TR->(DbGoTop())         ,;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont, "TR") )

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
              WritePProString("Browse","TrState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","TrOrder",Ltrim(Str(Tr->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","TrRecno",Ltrim(Str(Tr->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","TrSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, .t. )

return NIL
//_____________________________________________________________________________//

function TrEdita( oGrid, nMode, oCont, oParent )
   local oDlg, oFld, oBmp
   local aTitle := { i18n( "Añadir traspaso entre cuentas corrientes" )   ,;
                     i18n( "Modificar traspaso entre cuentas corrientes") ,;
                     i18n( "Duplicar traspasos entre cuentas corrientes") }
   local aGet[9]
   local cTrCc1, cTrCc2, dTrFecha, nTrImporte
   local nRecPtr  := TR->(RecNo())
   local nOrden   := TR->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local nOldImporte

   if TR->(EOF()) .AND. nMode != 1
      retu NIL
   endif

   oApp():nEdit ++

   if nMode == 1
      TR->(DbAppend())
      nRecAdd  := TR->(RecNo())
   endif
   cTrCc1		:= TR->TrCC1
	cTrCc2		:= TR->TrCC2
	dTrFecha		:= TR->TrFecha
	nTrImporte	:= TR->TrImporte
	nOldImporte := TR->TrImporte

	if nMode == 3
      TR->(DbAppend())
      nRecAdd := TR->(RecNo())
   endif

   if oParent == NIL
      oParent := oApp():oDlg
   endif

   DEFINE DIALOG oDlg RESOURCE "TREDIT"   ;
      TITLE aTitle[ nMode ]               ;
      OF oParent
   oDlg:oFont  := oApp():oFont

   REDEFINE SAY ID 201 OF oDlg

	REDEFINE AUTOGET aGet[1] VAR cTrCC1 ;
		DATASOURCE {}							;
		FILTER CcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 101 OF oDlg UPDATE            		;
		VALID CcClave( cTrCC1, aGet[1], 5, aGet );
      COLOR oApp():cClrCC, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[2] ID 110 OF oDlg ;
		ACTION ccSeleccion( cTrCC1, aGet[1], oDlg, aGet )

   REDEFINE SAY ID 202 OF oDlg

	REDEFINE AUTOGET aGet[3] VAR cTrCC2 ;
		DATASOURCE {}							;
		FILTER CcList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 102 OF oDlg UPDATE            		;
		VALID CcClave( cTrCC2, aGet[3], 5, aGet );
      COLOR oApp():cClrCC, CLR_WHITE ;
		GRADLIST { { 1, CLR_WHITE, CLR_WHITE } } ; 
		GRADITEM { { 1, oApp():nClrHL, oApp():nClrHL } } ; 
		LINECOLOR oApp():nClrHL ;
		ITEMCOLOR CLR_BLACK, CLR_BLACK

   REDEFINE BUTTON aGet[4] ID 111 OF oDlg ;
		ACTION ccSeleccion( cTrCC2, aGet[3], oDlg, aGet )

	REDEFINE SAY ID 203 OF oDlg

   REDEFINE GET aGet[5] VAR dTrFecha     ;
      ID 103 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN ! Empty(cTrCc1) .AND. ! Empty(cTrCC2)

   REDEFINE BUTTON aGet[6] ID 112 OF oDlg ;
      ACTION SelecFecha(@dTrFecha,aGet[5]);
		WHEN ! Empty(cTrCc1) .AND. ! Empty(cTrCC2)

	REDEFINE SAY ID 204 OF oDlg
   REDEFINE GET aGet[7] VAR nTrImporte   ;
      ID 104 OF oDlg UPDATE              ;
      COLOR oApp():cClrCc, CLR_WHITE	  ;
		WHEN ! Empty(cTrCc1) .AND. ! Empty(cTrCC2)
	aGet[7]:bValid := { || CcHaySaldo(cTrCC1,nTrImporte,nMode,TR->TrCC1,TR->TrImporte,,,,,,NIL,oDlg) }

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
         TR->(DbGoTo(nRecPtr))
      else
         TR->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo los saldos de las cuentas ______________________________//
		CC->(DbGoTop())
		CC->(DbSeek(Upper(cTrCc1)))
		replace CC->CcSaldoAc with CC->CcSaldoAc + nOldImporte - nTrImporte
		CC->(DbGoTop())
		CC->(DbSeek(Upper(cTrCc2)))
		replace CC->CcSaldoAc with CC->CcSaldoAc - nOldImporte + nTrImporte
		CC->( DbCommit() )
      // ___ guardo el registro _______________________________________________//
      Select TR
      Replace TR->TrCC1			with cTrCC1
		Replace TR->TrCC2			with cTrCC2
		Replace TR->TrFecha		with dTrFecha
		Replace TR->TrImporte	with nTrImporte
      TR->( DbCommit() )
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         TR->(DbGoTo(nRecAdd))
         TR->(DbDelete())
         TR->(DbPack())
         TR->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT TR

   if oCont != NIL
      RefreshCont(oCont,"TR")
   endif
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

   oApp():nEdit --

return lReturn
//_____________________________________________________________________________//

function TrBorra(oGrid,oCont)
   local nRecord  := TR->(Recno())
   local cKeyNext
   local nAuxRecno
   local nAuxOrder

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este traspaso ?") )
      //msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
      //   { || CcCambiaClave( SPACE(20), CC->CcCuenta ) } )
		//
		// ___ actualizo los saldos de las cuentas ______________________________//
		CC->(DbGoTop())
		CC->(DbSeek(Upper(TR->TrCc1)))
		replace CC->CcSaldoAc with CC->CcSaldoAc + TR->TrImporte
		CC->(DbGoTop())
		CC->(DbSeek(Upper(TR->TrCc2)))
		replace CC->CcSaldoAc with CC->CcSaldoAc - TR->TrImporte
		CC->( DbCommit() )
      // ___ borro la transferencia __________________________________________//
		TR->(DbSkip())
      cKeyNext := TR->(OrdKeyVal())
      TR->(DbGoto(nRecord))
      TR->(DbDelete())
      TR->(DbPack())
      if cKeyNext != NIL
         TR->(DbSeek(cKeyNext))
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

function TrTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      TrEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      TrEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      TrBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         TrBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         TrBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase

return nil

//_____________________________________________________________________________//

function TrBusca( oGrid, cChr, oCont, oParent )
   local nOrder   := TR->(OrdNumber())
   local nRecno   := TR->(Recno())
   local oDlg, oGet, cPicture
   local aSay1    := ""
   local aSay2    := ""
   local cGet
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA'   ;
      TITLE i18n("Búsqueda de cuenta corriente") OF oParent
   oDlg:oFont  := oApp():oFont

   if nOrder == 1
      aSay1 := "Introduzca la cuenta de origen"
		aSay2 := "Cuenta Origen"
		cGet  := space(20)
   elseif nOrder == 2
      aSay1 := "Introduzca la cuenta de destino"
		aSay2 := "Cuenta Destino"
		cGet := space(20)
   elseif nOrder == 3
      aSay1 := "Introduzca la fecha del traspaso"
		aSay2 := "Fecha"
		cGet  := space(8)
		lFecha := .t.
   endif

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
         { || TrWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún traspaso")
      else
         TrEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   TR->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "TR" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function TrWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := TR->(Recno())

   do case
      case nOrder == 1
         TR->(DbGoTop())
         do while ! TR->(eof())
            if upper(cGet) $ upper(TR->TrCC1)
        			aadd(aBrowse, { TR->TrCC1, TR->TrCC2, TR->TrFecha, tran(TR->TrImporte,"@E 999,999.99"), TR->(Recno()) })
            endif
            TR->(DbSkip())
         enddo
		case nOrder == 2
         TR->(DbGoTop())
         do while ! TR->(eof())
            if upper(cGet) $ upper(TR->TrCC2)
        			aadd(aBrowse, { TR->TrCC1, TR->TrCC2, TR->TrFecha, tran(TR->TrImporte,"@E 999,999.99"), TR->(Recno()) })
            endif
            TR->(DbSkip())
         enddo
		case nOrder == 1
         TR->(DbGoTop())
         do while ! TR->(eof())
            if cGet == TR->TrFecha
        			aadd(aBrowse, { TR->TrCC1, TR->TrCC2, TR->TrFecha, tran(TR->TrImporte,"@E 999,999.99"), TR->(Recno()) })
            endif
            TR->(DbSkip())
         enddo
   end case
   TR->(DbGoTo(nRecno))
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[3]) < upper(aAut2[3]) } )
return nil
/*_____________________________________________________________________________*/
function TrEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := CC->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:oFont  := oApp():oFont

   oBrowse := TXBrowse():New( oDlg )
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
	Ut_BrwRowConfig( oBrowse )
   oBrowse:CreateFromResource( 110 )
   TR->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||TR->(DbGoTo(aBrowse[oBrowse:nArrayAt, 5])),;
                                                           TrEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(TR->(DbGoto(aBrowse[oBrowse:nArrayAt, 1])),;
                                                     TrEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || TR->(DbGoto(aBrowse[oBrowse:nArrayAt, 1])) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrCC, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (TR->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

//_____________________________________________________________________________//

function TrImprime( oGrid )
   local nRecno   := TR->(Recno())
   local nOrder   := TR->(OrdSetFocus())
   local aCampos  := { "TrCC1", "TrCC2", "TrFecha", "TrImporte" }
   local aTitulos := { "Cuenta origen", "Cuenta destino", "Fecha", "Importe" }
   local aWidth   := { 20, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t.	}
   local aPicture := { "NO", "NO", "NO", "@E 9,999,999.99" }
   local aTotal   := { .f., .f., .f., .f. }
   local oInforme

   Select TR
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "TR" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      TR->(DbGoTop())
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                  oInforme:oReport:Say(1, 'Total traspasos: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                  oInforme:oReport:EndLine() )
      oInforme:End(.t.)
      TR->(DbGoTo(nRecno))
   endif

   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return nil

//_____________________________________________________________________________//

function TrIsDbfEmpty()
   local lReturn := .f.
   if CC->( ordKeyVal() ) == nil
      msgStop( i18n( "No hay ninguna cuenta corriente registrada." ) )
      lReturn := .t.
   endif

RETURN lReturn
//_____________________________________________________________________________//
