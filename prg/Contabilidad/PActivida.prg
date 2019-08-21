#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

static oReport

function Actividad()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "AcState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "AcOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "AcRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "AcSplit","102", oApp():cIniFile))
   local oCont
   local i

   if oApp():oDlg != NIL
      if oApp():nEdit > 0
         RETURN NIL
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

	if ! Db_OpenAll()
		retu NIL
	endif

   SELECT AC
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de actividades')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "AC"

   aBrowse   := { { { || AC->AcAnyo }, i18n("Ejercicio"), 50, AL_LEFT },;
                  { { || AC->AcNumero }, i18n("Actividad"), 50, AL_LEFT },;
                  { { || AC->AcActivida }, i18n("Descripción"), 120, AL_LEFT },;
						{ { || iif(AC->AcIVA," SI ", " NO ")}, i18n("Gestión de IVA"), 120, AL_LEFT },;
						{ { || iif(AC->AcREquiv," SI ", " NO ")}, i18n("Gestión de RE"), 120, AL_LEFT } }

   FOR i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource("16_SELECC")
   oCol:AddResource("16_NOSELE")
   oCol:cHeader	:= i18n("Predeterminada")
   oCol:bBmpData  := { || IIF(AC->AcPredeter,1,2) }
	// oCol:Cargo    := { || IIF(EJ->EjAnyo == oApp():cEjercicio,"Si","No") }
   oCol:nWidth        := 65
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| AcEdita( oApp():oGrid, 2, oCont, oApp():oDlg,.f. ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"AC") }
   oApp():oGrid:bKeyDown := {|nKey| AcTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }

   oApp():oGrid:RestoreState( cState )

   AC->(DbSetOrder(nOrder))
   AC->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(AC->(OrdKeyNo()),'@E 999,999')+" / "+tran(AC->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_ACTIVIDAD"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 175 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar ;
      CAPTION "  actividades" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nueva actividad"    ;
      IMAGE "16_nuevo"             ;
      ACTION AcEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar actividad"    ;
      IMAGE "16_modif"             ;
      ACTION AcEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION AcBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION AcBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir actividades";
      IMAGE "16_imprimir"          ;
      ACTION AcImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        	;
		CAPTION "Actividad predeterminada"	;
		IMAGE "16_SELECC"             	;
		ACTION AcPredeterminada( oApp():oGrid, oCont, oApp():oDlg );
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Actividades" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "AcState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS " Año + Actividad ", " Descripción ";
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              AC->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"AC") )

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
              WritePProString("Browse","AcState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","AcOrder",Ltrim(Str(AC->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","AcRecno",Ltrim(Str(AC->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","AcSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return nil
//-----------------------------------------------------------------------//

function AcEdita(oGrid,nMode,oCont,oParent)
   local oDlg
   local aTitle   := { i18n( "Añadir una actividad" )   ,;
                       i18n( "Modificar una actividad") ,;
                       i18n( "Duplicar un ingreso") }
   local aGet[5]

   local cAcAnyo     ,;
         cAcNumero   ,;
         cACActivida ,;
			lAcIVA		,;
			lAcREquiv
   local nRecPtr  := AC->(RecNo())
   local nOrden   := AC->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if AC->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      AC->(DbAppend())
      nRecAdd := AC->(RecNo())
   endif

   cAcAnyo 		:= AC->AcAnyo
	cAcNumero   := AC->AcNumero
	cAcActivida := AC->ACActivida
	lAcIVA		:= AC->AcIVA
	lAcREquiv	:= AC->AcREquiv

   if nMode == 3
      AC->(DbAppend())
      nRecAdd := AC->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "ACEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cAcAnyo    ;
   	PICTURE "9999"							;
      ID 101 OF oDlg UPDATE

   REDEFINE GET aGet[2] VAR cAcNumero  ;
   	PICTURE "99"							;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[3] VAR cAcActivida;
      ID 103 OF oDlg UPDATE	;
		VALID AcClave( cAcActivida, aGet[3], nMode, nil, nil );

   REDEFINE CHECKBOX aGet[4] ;
		VAR lAcIVA ;
		ID 104 OF oDlg

   REDEFINE CHECKBOX aGet[5] ;
		VAR lAcREquiv ;
		ID 105 OF oDlg

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION oDlg:end( IDOK )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION oDlg:end( IDCANCEL )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
      if nMode == 2
         AC->(DbGoTo(nRecPtr))
      else
         AC->(DbGoTo(nRecAdd))
      endif
      if nMode == 2 .AND. AC->AcActivida != cAcActivida
				msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
						{ || AcCambiaClave( cAcActivida, AC->AcActivida ) } )
		endif
      // guardo el registro _______________________________________________//
      Replace AC->AcAnyo     with cAcAnyo
      Replace AC->AcNumero   with cAcNumero
      Replace AC->AcActivida with cACActivida
		Replace AC->AcIVA      with lAcIVA
		Replace AC->AcREquiv   with lAcREquiv
      AC->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         AC->(DbGoTo(nRecAdd))
         AC->(DbDelete())
         AC->(DbPack())
         AC->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT AC
   if oCont != NIL
      RefreshCont(oCont,"AC")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//

function AcCreaCarpeta( AcAnyo, AcNumero, aGet )
   if !lIsDir( lower( oApp():cExePath+AcAnyo+AcNumero ) )
      lMkDir( lower( oApp():cExePath+AcAnyo+AcNumero ) )
      lMkDir( lower( oApp():cExePath+AcAnyo+AcNumero+"\datos\" ) )
      aGet[05]:cText := oApp():cExePath+AcAnyo+AcNumero+"\datos\"
      lMkDir( lower( oApp():cExePath+AcAnyo+AcNumero+"\zip\" ) )
      aGet[07]:cText := oApp():cExePath+AcAnyo+AcNumero+"\zip\"
      lMkDir( lower( oApp():cExePath+AcAnyo+AcNumero+"\xml\" ) )
      aGet[09]:cText := oApp():cExePath+AcAnyo+AcNumero+"\xml\"
      lMkDir( lower( oApp():cExePath+AcAnyo+AcNumero+"\pdf\" ) )
      aGet[11]:cText := oApp():cExePath+AcAnyo+AcNumero+"\pdf\"
   end
return nil
//-----------------------------------------------------------------------//

function AcBorra(oGrid,oCont)
   local nRecord := AC->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta actividad ?")+CRLF+;
                AC->AcAnyo+" "+AC->AcNumero+" "+AC->ACActivida )
     	msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || AcCambiaClave( SPACE(60), AP->ApActivida ) } )
      SELECT AC
      AC->(DbSkip())
      nNext := AC->(Recno())
      AC->(DbGoto(nRecord))

      AC->(DbDelete())
      AC->(DbPack())
      AC->(DbGoto(nNext))
      if AC->(EOF()) .or. nNext == nRecord
         AC->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"AC")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
//-----------------------------------------------------------------------//

function AcTecla(nKey,oGrid,oCont,oDlg,oAcMenu)
	Do case
   case nKey==VK_RETURN
      AcEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_DELETE
      AcBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
	OTHERWISE
		EndCase
return nil
//-----------------------------------------------------------------------//
function AcClave( cActivida, oGet, nMode, aGet, lAcIVA, lAcREquiv )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := AC->( RecNo() )
   local nOrder   := AC->( OrdNumber() )
   local nArea    := Select()

   if Empty( cActivida )
      if nMode == 4
         retu .t.
		else
			MsgStop("Es obligatorio rellenar este campo.")
			retu .f.
      endif
   endif

   SELECT AC
   AC->( DbSetOrder( 2 ) )
   AC->( DbGoTop() )

   if AC->( DbSeek( UPPER( cActivida ) ) )
      do case
			case nMode == 1 .OR. nMode == 3
				lReturn := .f.
				MsgStop("Actividad existente.")
			case nMode == 2
				if IN->( Recno() ) == nRecno
					lReturn := .t.
				else
					lReturn := .f.
					MsgStop("Actividad existente.")
				endif
			case nMode == 4
				IF ! oApp():thefull
					Registrame()
				ENDIF
				lReturn := .t.
				lAcIVA  := AC->AcIva
				lAcREquiv := AC->AcREquiv
      end case
	else
      if nMode < 4
         lReturn := .t.
		else
         if MsgYesNo("Actividad inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := AcEdita( , 1, , , @cActivida )
				if lReturn
					if lAcIVA != nil
						lAcIVA  := AC->AcIva
					endif
					if lAcREquiv != nil
						lAcREquiv := AC->AcREquiv
					endif
				endif
			else
				lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      oGet:cText( space(60) )
	else
		oGet:cText( cActivida )
		if aGet != nil
			aGet[10]:Update()
			aGet[12]:Update()
			// aGet[17]:Update()
		endif
	endif

   AC->( DbGoTo( nRecno ) )
   Select (nArea)
return lReturn

//_____________________________________________________________________________//

function AcCambiaClave( cVar, cOld )

   local nOrder
   local nRecNo

   // cambio el idoma de documentos
   Select AP
   nRecno := AP->(RecNo())
   nOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApActivida  ;
		with cVar            ;
		for Upper(Rtrim(AP->ApActivida)) == Upper(rtrim(cOld))
	AP->(DbSetOrder(nOrder))
	AP->(DbGoTo(nRecno))

return nil

//-----------------------------------------------------------------------//
function AcPredeterminada(oGrid,oCont,oParent)
   local nRecno := AC->(Recno())
	local cActividad := AC->AcActivida

	if MsgYesNo("¿ Desea marcar la actividad "+Rtrim(cActividad)+" como predeterminada ?")
		AC->(DbGoTop())
		replace all AC->AcPredeter with .f.
 		AC->(DbGoTo(nRecno))
		replace AC->AcPredeter with .t.
		oApp():cActividad := cActividad
      WritePProString("Config","Actividad",oApp():cActividad,oApp():cIniFile)
		MsgInfo("Se ha cambiado la actividad predeterminada a "+Rtrim(cActividad)+".")
   endif
return NIL
//_____________________________________________________________________________//

function AcBusca()
return nil

function AcSeleccion( cActivida, oControl, oParent, aGet, lAcIVA, lAcREquiv, oVItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := AC->( RecNo() )
   local nOrder := AC->( OrdNumber() )
   local nArea  := Select()
   local aPoint := iif(oControl!=NIL,AdjustWnd( oControl, 271*2, 150*2 ),{1.3*oVItem:nTop(),oApp():oGrid:nLeft})
   local cBrwState  := ""

   oApp():nEdit ++
	SELECT AC
   AC->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "AcAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
	TITLE i18n( "Selección de tipos de actividades" )      ;
	OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "AC"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || AC->AcActivida }
   oCol:cHeader  := i18n( "Actividades" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| AcTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBNew   ;
		ID 410 OF oDlg       ;
		ACTION AcEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
		ID 411 OF oDlg       ;
		ACTION AcEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
		ID 412 OF oDlg       ;
		ACTION AcBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
		ID 413 OF oDlg       ;
		ACTION AcBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
		ID IDOK OF oDlg            ;
		ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
		ID IDCANCEL OF oDlg        ;
		ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
		ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
		cActivida := AC->AcActivida
		if oControl != NIL
	      oControl:cText := AC->AcActivida
			lAcIVA := AC->AcIVA
			lAcREquiv := AC->AcREquiv
			if aGet != nil
				aGet[10]:Update()
				aGet[12]:Update()
				oParent:Update()
			endif
		endif
   endif

   SetIni( , "Browse", "AcAux", oBrowse:SaveState() )
   AC->( DbSetOrder( nOrder ) )
   AC->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return nil
//-----------------------------------------------------------------------//

function AcImprime(oGrid,oParent)
   local nRecno   := AC->(Recno())
   local nOrder   := AC->(OrdSetFocus())
   local aCampos  := { "ACANYO", "ACNUMERO" , "ACACTIVIDA" }
   local aTitulos := { "Año", "Actividad", "Descripción" }
   local aWidth   := { 5, 15, 40 }
   local aShow    := { .t., .t., .t. }
   local aPicture := { "NO","NO","NO" }
   local aTotal   := { .f., .f., .f. }
   local oInforme
	local nAt

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "AC" )
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()
   if oInforme:Activate()
      if oInforme:nRadio == 1
      	AC->(DbGoTop())
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport
         oInforme:End(.t.)
      endif
      AC->(DbSetOrder(nOrder))
      AC->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return nil

function AcList( aList, cData, oSelf )
   local aNewList := {}
   AC->( dbSetOrder(1) )
   AC->( dbGoTop() )
   while ! AC->(Eof())
      if at(Upper(cdata), Upper(AC->AcActivida)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { AC->AcActivida } )
      endif 
      AC->(DbSkip())
   enddo
return aNewlist
