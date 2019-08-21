#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

static oReport

function Ejercicio()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "EjState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "EjOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "EjRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "EjSplit","102", oApp():cIniFile))
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

   if ! Db_Open("EJERCICI","EJ")
		DbCloseAll()
		retu .F.
	endif

   if ! Db_Open("IVA","IV")
		DbCloseAll()
		retu .F.
	endif

   SELECT EJ
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de ejercicios')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "EJ"

   aBrowse   := { { { || EJ->EjAnyo }, i18n("Ejercicio"), 50, AL_LEFT },;
                  { { || EJ->EjDbf  }, i18n("Ruta a archivos de datos"), 50, AL_LEFT },;
                  { { || EJ->EjZIP  }, i18n("Ruta a archivos de backup"), 50, AL_LEFT },;
                  { { || EJ->EjXML  }, i18n("Ruta a archivos XML"), 50, AL_LEFT },;
						{ { || EJ->EjXLS  }, i18n("Ruta a archivos XLS"), 50, AL_LEFT },;
                  { { || EJ->EjPDF  }, i18n("Ruta a archivos PDF"), 50, AL_LEFT } }

   oCol := oApp():oGrid:AddCol()
	// oCol:bEditValue :=  { || IIF(EJ->EjAnyo == oApp():cEjercicio,.t.,.f.) }
   oCol:AddResource("16_SELECC")
   oCol:AddResource("16_NOSELE")
   oCol:cHeader	:= i18n("Activo")
   oCol:bBmpData  := { || IIF(EJ->EjAnyo == oApp():cEjercicio,1,2) }
	oCol:Cargo  	:= { || IIF(EJ->EjAnyo == oApp():cEjercicio,"Si","No") }
   oCol:nWidth        := 65
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT


   FOR i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      // oCol:bLDClickData  := {|| AcEdita( oApp():oGrid, 2, oCont, oApp():oDlg,.f. ) }
      oCol:bLDClickData  := {|| EjActiva( oApp():oGrid, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"EJ") }
   oApp():oGrid:bKeyDown := {|nKey| EjTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }

   oApp():oGrid:RestoreState( cState )

   EJ->(DbSetOrder(nOrder))
   EJ->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 17 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(EJ->(OrdKeyNo()),'@E 999,999')+" / "+tran(EJ->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_EJERCICIO"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 175 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))
	oBar:nMargen := 0

   DEFINE TITLE OF oBar ;
      CAPTION "  ejercicios" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        	;
      CAPTION "Nuevo ejercicio"    	;
      IMAGE "16_nuevo"             	;
      ACTION EjEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar         ;
      CAPTION "Modificar ejercicio" ;
      IMAGE "16_modif"              ;
      ACTION EjEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        	;
      CAPTION "Borrar"             	;
      IMAGE "16_borrar"            	;
      ACTION EjBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        	;
      CAPTION "Buscar"             	;
      IMAGE "16_busca"             	;
      ACTION AcBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir ejercicios";
      IMAGE "16_imprimir"          ;
      ACTION EjImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        	;
		CAPTION "Tipos de IVA"	      ;
		IMAGE "16_IVA"                ;
		ACTION EjIva( "I", oApp():oGrid, oCont, oApp():oDlg );
		LEFT 10

	DEFINE VMENUITEM OF oBar        	;
		CAPTION "Tipos de Recargo Equivalencia" ;
		IMAGE "16_RE"                ;
		ACTION EjIva( "E", oApp():oGrid, oCont, oApp():oDlg );
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        	;
		CAPTION "Seleccionar ejercicio"	;
		IMAGE "16_SELECC"             	;
		ACTION EjActiva( oApp():oGrid, oCont, oApp():oDlg );
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
		INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Ejercicios" ), CursorArrow());
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
     ITEMS " Ejercicio " ;
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              EJ->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont, "EJ") )

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
              WritePProString("Browse","EjState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","EjOrder",Ltrim(Str(EJ->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","EjRecno",Ltrim(Str(EJ->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","EjSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return nil
//-----------------------------------------------------------------------//

function EjEdita(oGrid,nMode,oCont,oParent)
   local oDlg
   local aTitle   := { i18n( "Añadir un ejercicio" )   ,;
                       i18n( "Modificar un ejercicio") ,;
                       i18n( "Duplicar un ingreso") }
   local aGet[14]

   local cEjAnyo     ,;
         cEjDBF      ,;
         cEjZIP      ,;
			cEjXML		,;
			cEjPDF		,;
			cEjXLS
   local nRecPtr  := EJ->(RecNo())
   local nOrden   := EJ->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local aCombo   := {'No incorporar datos'}
	local cCombo   := aCombo[1]
	local cOrigen
	local cDestino

   if EJ->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif
   oApp():nEdit ++
   if nMode == 1
		EJ->(DbGoTop())
		while ! EJ->(EoF())
			Aadd(aCombo,EJ->EjAnyo)
			EJ->(DbSkip())
		enddo
      EJ->(DbAppend())
      nRecAdd := EJ->(RecNo())
   endif

   cEjAnyo 	:= EJ->EjAnyo
	cEjDBF	:= EJ->EjDBF
	cEjZIP	:= EJ->EjZIP
	cEjXML	:= EJ->EjXML
	cEjPDF	:= EJ->EjPDF
	cEjXls	:= EJ->EjXLS

   if nMode == 3
      AC->(DbAppend())
      nRecAdd := AC->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "EJEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cEjAnyo    ;
   	PICTURE "9999"							;
      ID 200 OF oDlg UPDATE				;
		VALID EjClave(cEjAnyo, aGet[1], nMode)

   REDEFINE BUTTON aGet[2]  ;
		ID 202 OF oDlg 	    ;
		ACTION EjCreaCarpeta( cEjAnyo, aGet ) ;
		WHEN nMode == 1

   REDEFINE GET aGet[3] VAR cEjDbf    ;
		ID 101 OF oDlg UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[4]	 ;
		ID 111 OF oDlg UPDATE ;
		ACTION GetDir(aGet[3])
   aGet[4]:cTooltip := "seleccionar carpeta de datos"

   REDEFINE GET aGet[5] VAR cEjZip ;
		ID 103 OF oDlg UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[6]  ;
		ID 113 OF oDlg UPDATE ;
		ACTION GetDir(aGet[5])
   aGet[6]:cTooltip := "seleccionar carpeta de backup"

   REDEFINE GET aGet[7] VAR cEjXML ;
		ID 105 OF oDlg PICTURE '@!'
   REDEFINE BUTTON aGet[8]  ;
		ID 115 OF oDlg UPDATE ;
		ACTION GetDir(aGet[7])
   aGet[8]:cTooltip := "seleccionar carpeta para XML"

   REDEFINE GET aGet[9] VAR cEjPdf ;
		ID 107 OF oDlg UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[10] ;
		ID 117 OF oDlg UPDATE ;
		ACTION GetDir(aGet[9])
   aGet[10]:cTooltip := "seleccionar carpeta para PDF"

	REDEFINE GET aGet[11] VAR cEjXls ;
		ID 109 OF oDlg UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[12] ;
		ID 119 OF oDlg UPDATE ;
		ACTION GetDir(aGet[11])
   aGet[12]:cTooltip := "seleccionar carpeta para XLS"

   REDEFINE COMBOBOX aGet[13] VAR cCombo ;
		ID 120 ITEMS aCombo ;
		OF oDlg WHEN nMode == 1

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
		if cCombo != aCombo[1]
			EJ->(DbSeek(cCombo))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"activida.dbf"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"activida.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"activida.cdx"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"activida.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"periodi.dbf"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"periodi.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"periodi.cdx"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"periodi.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"clientes.dbf"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"clientes.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"clientes.cdx"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"clientes.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"gastos.dbf"))    to (Ut_AbsPath(Rtrim(cEjDbf)+"gastos.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"gastos.cdx"))    to (Ut_AbsPath(Rtrim(cEjDbf)+"gastos.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"ingresos.dbf"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"ingresos.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"ingresos.cdx"))  to (Ut_AbsPath(Rtrim(cEjDbf)+"ingresos.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"proveed.dbf"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"proveed.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"proveed.cdx"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"proveed.cdx"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"cuentas.dbf"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"cuentas.dbf"))
			copy file (Ut_AbsPath(Rtrim(EJ->EjDBF)+"cuentas.cdx"))   to (Ut_AbsPath(Rtrim(cEjDbf)+"cuentas.cdx"))
			// tengo que poner en las cuentas el saldo actual como saldo inicial
			if msgYesNo("¿ Desea actualizar los saldos de las cuentas corrientes ?"+CRLF+"El saldo actual de cada cuenta se pondrá como saldo inicial del ejercicio.")
				USE (Ut_AbsPath(Rtrim(cEjDbf)+"cuentas.dbf"))  ;
					INDEX (Ut_AbsPath(Rtrim(cEjDbf)+"cuentas.cdx")) ;
					ALIAS "CC" NEW
				CC->(DbGoTop())
				while ! CC->(EoF())
					replace CC->CcFApertu	with CC->CcFultimo
					replace CC->CcSaldoIn	with CC->CcSaldoAc
					CC->(DbSkip())
				enddo
				Close CC
			endif
		endif
      if nMode == 2
         EJ->(DbGoTo(nRecPtr))
      else
         EJ->(DbGoTo(nRecAdd))
      endif
      // ___ guardo el registro _______________________________________________//
      Replace EJ->EjAnyo     with cEjAnyo
      Replace EJ->EjDBF      with cEjDBF
		Replace EJ->EjXML      with cEjXML
		Replace EJ->EjZIP      with cEjZIP
		Replace EJ->EjPDF      with cEjPDF
		Replace EJ->EjXLS      with cEjXLS
      EJ->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         EJ->(DbGoTo(nRecAdd))
         EJ->(DbDelete())
         EJ->(DbPack())
         EJ->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT EJ
   if oCont != NIL
      RefreshCont(oCont,"EJ")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//

function EjCreaCarpeta( EjAnyo, aGet )
   if !lIsDir( lower( oApp():cExePath+EjAnyo ) )
      lMkDir( lower( oApp():cExePath+EjAnyo ) )
   end
   lMkDir( lower( oApp():cExePath+EjAnyo+"\dbf\" ) )
   aGet[03]:cText := oApp():cExePath+EjAnyo+"\dbf\"
   lMkDir( lower( oApp():cExePath+EjAnyo+"\zip\" ) )
   aGet[05]:cText := oApp():cExePath+EjAnyo+"\zip\"
   lMkDir( lower( oApp():cExePath+EjAnyo+"\xml\" ) )
   aGet[07]:cText := oApp():cExePath+EjAnyo+"\xml\"
   lMkDir( lower( oApp():cExePath+EjAnyo+"\pdf\" ) )
   aGet[09]:cText := oApp():cExePath+EjAnyo+"\pdf\"
	lMkDir( lower( oApp():cExePath+EjAnyo+"\xls\" ) )
   aGet[11]:cText := oApp():cExePath+EjAnyo+"\xls\"
return nil
//-----------------------------------------------------------------------//

function EjBorra(oGrid,oCont)
   local nRecord := Ej->(Recno())
   local nNext
	local aDir := {}
	local iMax, i

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de borrar este ejercicio ?")+CRLF+;
                EJ->EjAnyo )
		if msgYesNo(i18n("¿ Desea borrar los datos del ejercicio ?"+CRLF+EJ->EjDBF))
			aDir := Directory( rtrim(EJ->EjDBF)+"*.*" )
			imax := Len( aDir )
			for i:=1 to imax
         	delete file ( rtrim(EJ->EjDBF)+aDir[i,1] )
			next
			DirRemove(rtrim(EJ->EjDBF))
			DirRemove(rtrim(EJ->EjXML))
			DirRemove(rtrim(EJ->EjZIP))
			DirRemove(rtrim(EJ->EjPDF))
			DirRemove(rtrim(EJ->EjXLS))
		endif
      SELECT EJ
      EJ->(DbSkip())
      nNext := EJ->(Recno())
      EJ->(DbGoto(nRecord))

      EJ->(DbDelete())
      EJ->(DbPack())
      EJ->(DbGoto(nNext))
      if EJ->(EOF()) .or. nNext == nRecord
         EJ->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"EJ")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil

//-----------------------------------------------------------------------//
function EjClave( cAnyo, oGet, nMode )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := EJ->( RecNo() )
   local nOrder   := EJ->( OrdNumber() )
   local nArea    := Select()

   if Empty( cAnyo )
      if nMode == 4
         retu .t.
		else
			MsgStop("Es obligatorio rellenar este campo.")
			retu .f.
      endif
   endif

   SELECT EJ
   EJ->( DbSetOrder( 1 ) )
   EJ->( DbGoTop() )

   if EJ->( DbSeek( cAnyo ) )
      do case
			case nMode == 1 .OR. nMode == 3
				lReturn := .f.
				MsgStop("Ejercicio existente.")
			case nMode == 2
				if EJ->( Recno() ) == nRecno
					lReturn := .t.
				else
					lReturn := .f.
					MsgStop("Ejercicio existente.")
				endif
			case nMode == 4
				IF ! oApp():thefull
					Registrame()
				ENDIF
				lReturn := .t.
      end case
	else
      if nMode < 4
         lReturn := .t.
		else
         if MsgYesNo("Ejercicio inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := EjEdita( , 1, , , @cAnyo )
			else
				lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      oGet:cText( space(4) )
	else
		oGet:cText( cAnyo )
	endif

   EJ->( DbGoTo( nRecno ) )
   Select (nArea)
return lReturn

//-----------------------------------------------------------------------//
function EjBusca()
return nil

function EjSeleccion( cActivida, oControl, oParent, aGet, lAcIVA )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := AC->( RecNo() )
   local nOrder := AC->( OrdNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""

   oApp():nEdit ++
   IN->( dbGoTop() )

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
      oControl:cText := AC->AcActivida
		lAcIVA := AC->AcIVA
		if aGet != nil
			aGet[10]:Update()
			aGet[12]:Update()
			oParent:Update()
			// aGet[17]:Update()
		endif
   endif

   SetIni( , "Browse", "AcAux", oBrowse:SaveState() )
   AC->( DbSetOrder( nOrder ) )
   AC->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return nil
//-----------------------------------------------------------------------//
function EjTecla(nKey,oGrid,oCont,oDlg)
	switch nKey
	   case VK_RETURN
   	   EjActiva(oGrid,oDlg)
   	case VK_DELETE
      	EjBorra(oGrid,oCont)
   	case VK_ESCAPE
      	oDlg:End()
   	// default
	end
return nil
//-----------------------------------------------------------------------//

function EjImprime(oGrid,oParent)
   local nRecno   := EJ->(Recno())
   local nOrder   := EJ->(OrdSetFocus())
   local aCampos  := { "EJANYO", "EJDBF" , "EJXML", "EJZIP", "EJPDF" }
   local aTitulos := { "Año", "Ruta DBF", "Ruta XML", "Ruta ZIP", "Ruta PDF" }
   local aWidth   := { 5, 20, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO", "NO", "NO" }
   local aTotal   := { .f., .f., .f., .f., .f. }
   local oInforme
	local nAt

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "EJ" )
   oInforme:Dialog()
   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()
   if oInforme:Activate()
      if oInforme:nRadio == 1
      	EJ->(DbGoTop())
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport
         oInforme:End(.t.)
      endif
      EJ->(DbSetOrder(nOrder))
      EJ->(DbGoTo(nRecno))
   endif
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
RETURN NIL
//---------------------------------------------------------------------------------------//

function EjActiva(oGrid,oCont,oParent)
   local lreturn
	local cAnyo := EJ->EjAnyo

	if MsgYesNo("¿ Desea cambiar el ejercicio activo a "+cAnyo+" ?")
		oApp():cEjercicio := EJ->EjAnyo

		oApp():cDbfPath   := Rtrim(EJ->EjDbf)
		oApp():cZipPath   := Rtrim(EJ->EjZip)
		oApp():cXMLPath   := Rtrim(EJ->EjXml)
		oApp():cPdfPath   := Rtrim(EJ->EjPdf)

   	oApp():oWndMain:cTitle := oApp():cAppName + oApp():cVersion + " » Ejercicio " + oApp():cEjercicio

      WritePProString("Config","Ejercicio",oApp():cEjercicio,oApp():cIniFile)
      WritePProString("Config","Dbf",oApp():cDbfPath,oApp():cIniFile)
      WritePProString("Config","Zip",oApp():cZipPath,oApp():cIniFile)
      WritePProString("Config","Pdf",oApp():cPdfPath,oApp():cIniFile)
      WritePProString("Config","Xml",oApp():cXMLPath,oApp():cIniFile)

		oApp():cDbfPath := Ut_AbsPath(oApp():cDbfPath)
		oApp():cZipPath := Ut_AbsPath(oApp():cZipPath)
		oApp():cXmlPath := Ut_AbsPath(oApp():cXmlPath)
		oApp():cPdfPath := Ut_AbsPath(oApp():cPdfPath)
		Ut_Actualizar(.f.)
		Ut_Indexar(.t.)
		MsgInfo("Se ha cambiado el ejercicio activo a "+cAnyo+".")
   endif
return NIL
//_____________________________________________________________________________//

function EjIva( clase, oGrid, oCont, oParent )
	local cAnyo := EJ->EjAnyo
	local oDlg, oBrwIVA, oCol
	local oBtn1, oBtn2, oBtn3
	local oBtnOK, oBtnCancel
	local cTitle := iif(clase=="I","IVA del ejercicio ","Recargo de equivalencia del ejercicio ")
	SELECT IV
	IV->(DbSetFilter( {|| IV->IvClase==clase .and. IV->IvAnyo==cAnyo } ))
 	IV->(DbGoTop())
	DEFINE DIALOG oDlg RESOURCE "IVBROWSE" ;
		TITLE cTitle+cAnyo ;
		OF oParent
   oDlg:SetFont(oApp():oFont)

	oBrwIVA := TXBrowse():New( oDlg )
	Ut_BrwRowConfig( oBrwIVA )
   oBrwIVA:cAlias := "IV"

   oCol := oBrwIVA:AddCol()
   oCol:bStrData := { || tran(IV->IvTipo,"@E 99.99")+Space(10) }
   oCol:cHeader  := Space(6)+"Tipo"
   oCol:nWidth   := 90
	oCol:nDataStrAlign := AL_RIGHT
	//oCol:nHeadStrAlign := AL_RIGHT

   oCol := oBrwIVA:AddCol()
   oCol:AddResource("16_SELECC")
   oCol:AddResource("16_NOSELE")
   oCol:cHeader	:= i18n("Vigente")
   oCol:bBmpData  := { || IIF(IV->IvVigente==.t.,1,2) }
   oCol:nWidth        := 65
   oCol:nDataBmpAlign := 2

   oBrwIVA:SetRDD()
   oBrwIVA:CreateFromResource( 100 )
   oBrwIVA:nRowHeight  := 21

   REDEFINE BUTTON oBtn1  ;
		ID 401 OF oDlg     ;
		ACTION EjIVAEdit(clase, oBrwIVA, 1, cAnyo, oDlg)

   REDEFINE BUTTON oBtn2  ;
		ID 402 OF oDlg      ;
		ACTION EjIVAEdit(clase, oBrwIVA, 2, cAnyo, oDlg)

   REDEFINE BUTTON oBtn3  ;
		ID 403 OF oDlg      ;
		ACTION EjIVABorra(clase, oBrwIVA, cAnyo, oDlg)

   REDEFINE BUTTON oBtnOk ;
		ID IDOK OF oDlg     ;
		ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
		ON INIT DlgCenter(oDlg,oApp():oWndMain)

	IV->(DbClearFilter())
	SELECT EJ
	oGrid:Refresh()
return nil

function EjIVAEdit(clase, oBrwIVA,nMode,cAnyo,oParent)
   local oDlg
   local aTitle   := iif(clase=="I", { i18n( "Añadir un tipo de IVA" ) , i18n( "Modificar un tipo de IVA") }, { i18n( "Añadir un tipo de RE" ) , i18n( "Modificar un tipo de RE") } )
   local aGet[3]

   local nIvTipo     ,;
         lIvVigente
   local nRecPtr  := IV->(RecNo())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.
	local oSay
	local cSayPrompt := iif(clase=="I", "Tipo de IVA", "Tipo Recargo Eq.")

   if EJ->(EOF()) .AND. nMode != 1
      retu NIL
   endif
   if nMode == 1
      IV->(DbAppend())
		replace IV->IvClase with clase
		replace IV->IvAnyo with cAnyo
      nRecAdd := IV->(RecNo())
   endif

   nIvTipo 	  := IV->IvTipo
	lIvVigente := IV->IvVigente

   DEFINE DIALOG oDlg RESOURCE "IVEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

	REDEFINE SAY oSay PROMPT cSayPrompt ID 202 OF oDlg
   REDEFINE GET aGet[1] VAR cAnyo      ;
   	PICTURE "9999"							;
      ID 101 OF oDlg WHEN .f.

   REDEFINE GET aGet[2] VAR nIvTipo ;
      ID       102   ;
      PICTURE  "@E 99.99" OF oDlg

	REDEFINE CHECKBOX aGet[3] VAR lIvVigente ID 103 OF oDlg

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
         IV->(DbGoTo(nRecPtr))
      else
         IV->(DbGoTo(nRecAdd))
      endif
      // ___ guardo el registro _______________________________________________//
      Replace IV->IvTipo     with nIvTipo
		Replace IV->IvVigente  with lIvVigente
      IV->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1
         IV->(DbGoTo(nRecAdd))
         IV->(DbDelete())
         IV->(DbPack())
         IV->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT IV

   if oBrwIVA != NIL
      oBrwIVA:Refresh()
      oBrwIVA:SetFocus( .t. )
   endif

return lReturn
//-----------------------------------------------------------------------//
function EjIVABorra(clase, oBrwIVA,cAnyo,oParent)
   local nRecord := IV->(Recno())
   local nNext
	local cMsg := iif(clase=="I","IVA ?","Recargo de equivalencia ?")

   if msgYesNo( "¿ Está seguro de borrar este tipo de "+cMsg+CRLF+;
                tran(IV->IvTipo,"@E 99.99") )
      SELECT IV
      IV->(DbSkip())
      nNext := IV->(Recno())
      IV->(DbGoto(nRecord))

      IV->(DbDelete())
      IV->(DbPack())
      IV->(DbGoto(nNext))
      if IV->(EOF()) .or. nNext == nRecord
         IV->(DbGoBottom())
      endif
   endif
return nil
//_____________________________________________________________________________//

function EjIvaArray(Clase, cAnyo)
	local aIva := {}
	local nArea    := Select()
	Select IV
	IV->(DbGoTop())
	IV->(DbSeek(clase+cAnyo))
	While IV->IvAnyo==cAnyo .and. ! IV->(EOF())
		if IV->IvVigente == .t.
			Aadd(aIva, tran(IV->IvTipo,"@E99.99"))
		endif
		IV->(DbSkip())
	enddo
	Select (nArea)
return aIva