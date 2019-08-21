#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

STATIC oReport

function Etiquetas()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "EtState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "EtOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "EtRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "EtSplit","102", oApp():cIniFile))
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

   if ! Db_OpenAllInv()
      retu NIL
   endif

   SELECT ET
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de etiquetas')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "ET"

   aBrowse   := { { { || ET->EtNombre }, i18n("Etiqueta"), 150, 0 },;
               	{ { || ET->EtInven }, i18n("Inventario"), 120, 0 } }


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
      oCol:bLDClickData  := {|| EtEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"ET") }
   oApp():oGrid:bKeyDown := {|nKey| EtTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )

   ET->(DbSetOrder(nOrder))
   ET->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(ET->(OrdKeyNo()),'@E 999,999')+" / "+tran(ET->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_TAG"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 195 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  etiquetas " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION EtEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION EtEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   //DEFINE VMENUITEM OF oBar        ;
   //   CAPTION "Duplicar"           ;
   //   IMAGE "16_duplica"           ;
   //   ACTION EtEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
   //   LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION EtBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION EtBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION EtImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver inventario"     ;
      IMAGE "16_invent"            ;
      ACTION EtInventario( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Etiquetas" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "EtState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Etiqueta ' ;
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              ET->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"ET") )

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
              WritePProString("Browse","EtState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","EtOrder",Ltrim(Str(ET->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","EtRecno",Ltrim(Str(ET->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","EtSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return Nil
/*_____________________________________________________________________________*/

function EtEdita(oGrid,nMode,oCont,oParent,cEtiqueta)
   local oDlg
   local aTitle := { i18n( "Añadir una etiqueta" )   ,;
                     i18n( "Modificar una etiqueta") ,;
                     i18n( "Duplicar una etiqueta") }
   local aGet[1]
   local cEtNombre
   local nRecPtr  := ET->(RecNo())
   local nOrden   := ET->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if ET->(EOF()) .AND. nMode != 1
      RETU NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      ET->(DbAppend())
      nRecAdd := ET->(RecNo())
   endif

   cEtNombre   := IIF(nMode==1.AND.cEtiqueta!=NIL,cEtiqueta,ET->EtNombre)

   if nMode == 3
      ET->(DbAppend())
      nRecAdd := ET->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "CAEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

	REDEFINE SAY PROMPT "Etiqueta" ID 11 OF oDlg
   REDEFINE GET aGet[1] VAR cEtNombre  ;
      ID 12 OF oDlg UPDATE             ;
      VALID EtClave( cEtNombre, aGet[1], nMode, 1 )

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
         ET->(DbGoTo(nRecPtr))
      else
         ET->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el nombre del proveedor en los apuntes__________________//
      if nMode == 2
         if cEtNombre != ET->EtNombre
            msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               { || EtCambiaClave( cEtNombre, ET->EtNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      Replace ET->Etnombre   with cEtnombre
      ET->(DbCommit())
      if cEtiqueta != NIL
         cEtiqueta := ET->EtNombre
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         ET->(DbGoTo(nRecAdd))
         ET->(DbDelete())
         ET->(DbPack())
         ET->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT CA
   if oCont != NIL
      RefreshCont(oCont,"ET")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function EtBorra(oGrid,oCont)
   local nRecord := ET->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta etiqueta ?") + CRLF + ;
                (trim(ET->EtNombre)))
      msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || CaCambiaClave( space(40), ET->EtNombre ) } )

      SELECT CA
      ET->(DbSkip())
      nNext := ET->(Recno())
      ET->(DbGoto(nRecord))
      ET->(DbDelete())
      ET->(DbPack())
      ET->(DbGoto(nNext))
      if ET->(EOF()) .or. nNext == nRecord
         ET->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"CA")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
/*_____________________________________________________________________________*/

function EtTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      EtEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      EtEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      EtBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         EtBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         EtBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase
return nil
/*_____________________________________________________________________________*/

function EtSeleccion( aItems, oControl, oParent, cItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := ET->( RecNo() )
   local nOrder := ET->( OrdNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""

   oApp():nEdit ++
   ET->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "EtAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de etiquetas" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "ET"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || ET->EtNombre }
   oCol:cHeader  := i18n( "Etiqueta" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| EtTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { CLR_BLACK, CLR_WHITE } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION EtEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION EtEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION EtBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION EtBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
		if aItems != NIL
			if AScan(aItems, RTrim(ET->EtNombre)) == 0
				oControl:Additem(RTrim(ET->EtNombre))
				AAdd(aItems,RTrim(ET->EtNombre))
				oControl:Refresh()
			else
				msgAlert('La etiqueta ya aparece en el bien.')
			endif
		elseif cItem != NIL
			cItem := Rtrim(ET->EtNombre)
			oControl:Refresh()
		endif
   endif

   SetIni( , "Browse", "EtAux", oBrowse:SaveState() )
   ET->( DbSetOrder( nOrder ) )
   ET->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return NIL
/*_____________________________________________________________________________*/

function EtBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := ET->(OrdNumber())
   local nRecno   := ET->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de etiquetas")
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT i18n( "Introduzca la etiqueta" ) ID 20 OF oDlg
   REDEFINE SAY PROMPT i18n( "Etiqueta" )+":" ID 21 OF Odlg
   cGet     := space(40)

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   if cChr != NIL
      if .NOT. lFecha
         cGet := cChr+SubStr(cGet,1,len(cGet)-1)
      else
         cGet := CtoD(cChr+' -  -    ')
      endif
   endif

   if ! lFecha
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg
   else
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg
   endif

   if cChr != NIL
      oGet:bGotFocus := { || oGet:SetPos(2) }
   endif

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION (lSeek := .f., oDlg:End())

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter(oDlg,oApp():oWndMain) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   if lSeek
      if ! lFecha
         cGet := rTrim( upper( cGet ) )
      else
         cGet := dTOs( cGet )
      end if
      MsgRun('Realizando la búsqueda...', oApp():cAppName+oApp():cVersion, ;
         { || EtWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ninguna categoría")
      else
         EtEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   ET->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "ET" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function EtWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := ET->(Recno())

   ET->(DbGoTop())
   do while ! ET->(eof())
      if cGet $ upper(ET->EtNombre)
         aadd(aBrowse, {ET->EtNombre, ET->EtInven })
      endif
      ET->(DbSkip())
   enddo

   ET->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/

function EtEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := ET->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Etiqueta"
   oBrowse:aCols[2]:cHeader := "Inventario"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   ET->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||ET->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           EtEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(ET->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     EtEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || ET->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (ET->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function EtClave( cClave, oGet, nMode, nTag )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := ET->( RecNo() )
   local nOrder   := ET->( OrdNumber() )
   local nArea    := Select()

   if Empty( cClave )
      if nMode == 4 .OR. nTag == 2
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT CA
   ET->( DbSetOrder( nTag ) )
   ET->( DbGoTop() )

   if ET->( DbSeek( UPPER( cClave ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Categoría existente.")
         Case nMode == 2
            if ET->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Categoría existente.")
            endif
         Case nMode == 4
				IF ! oApp():thefull
					Registrame()
				ENDIF
            lReturn := .t.
      END CASE
   else
      if nMode < 4
         lReturn := .t.
      else
         if MsgYesNo("Categoría inexistente. ¿ Desea darla de alta ahora? ")
            lReturn := CaEdita( , 1, , , @cClave )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      iif(nTag==1,oGet:cText(space(40)),oGet:cText(space(15)))
   else
      oGet:cText( cClave )
   endif

   ET->( DbSetOrder( nOrder ) )
   ET->( DbGoTo( nRecno ) )

   Select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function EtCambiaClave( cNew, cOld )
   local nAuxOrder
   local nAuxRecNo
   cOld := upper(rtrim(cOld))
	// cambio la tienda en el inventario
   Select BI
   nAuxRecno := BI->(RecNo())
   nAuxOrder := BI->(OrdNumber())
   BI->(DbSetOrder(0))
   BI->(DbGoTop())
   Replace BI->BiCategor   ;
      with cNew            ;
      for Upper(Rtrim(BI->BiCategor)) == Upper(rtrim(cOld))
   BI->(DbSetOrder( nAuxOrder ))
   BI->(DbGoTo( nAuxRecno ))
   SELECT MA
return NIL

//_____________________________________________________________________________//

function EtInventario( oGrid, oParent )

	local cTag := Rtrim(ET->EtNombre)
	local oDlg, oBrowse, oCol
	local aBrowse := {}

	select BI
	BI->(dbGoTop())
	do while ! BI->(Eof())
		if At(cTag, BI->BiTags) != 0
			AAdd(aBrowse, { BI->BiDenomi, BI->BiMarca, BI->BiModelo, tran(BI->BiPrecio,"@E 999,999.99"), BI->(RecNo()) })
		endif
		BI->(dbSkip())
	enddo
	if Len(aBrowse) == 0
		MsgStop("La etiqueta no aparece en el inventario.")
		retu nil
	endif

	oApp():nEdit ++

	DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
		TITLE 'Inventario de la etiqueta: '+RTrim(cTag) OF oParent
	oDlg:SetFont(oApp():oFont)

	ASort( aBrowse,,, {|aApu1, aApu2| aApu1[1] < aApu2[1] } )
	oBrowse := TXBrowse():New( oDlg )
	Ut_BrwRowConfig( oBrowse )
	oBrowse:SetArray(aBrowse, .F.)
	oBrowse:aCols[1]:cHeader  := "Identificador"
	oBrowse:aCols[1]:nWidth   := 170
	oBrowse:aCols[2]:cHeader  := "Marca"
	oBrowse:aCols[2]:nWidth   := 160
	oBrowse:aCols[3]:cHeader  := "Modelo"
	oBrowse:aCols[3]:nWidth   := 220
	oBrowse:aCols[4]:cHeader  := "Precio"
	oBrowse:aCols[4]:nWidth   := 80
	oBrowse:aCols[4]:nDataStrAlign := AL_RIGHT
	oBrowse:aCols[4]:nHeadStrAlign := AL_RIGHT
	oBrowse:aCols[5]:lHide    := .T.

	AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| (BI->(dbGoto(aBrowse[oBrowse:nArrayAt,5])),;
		BiEdita(,2,,oDlg,.F.)) } } )

	oBrowse:lHScroll := .F.
	oBrowse:SetRDD()
	oBrowse:CreateFromResource( 110 )
	oDlg:oClient := oBrowse
	oBrowse:nRowHeight := 20

	REDEFINE BUTTON ID IDOK OF oDlg ;
		prompt i18n( "&Aceptar" )   ;
		ACTION oDlg:End()

	ACTIVATE DIALOG oDlg ;
		on init DlgCenter(oDlg,oApp():oWndMain)

	select ET
	oGrid:Refresh()
	oGrid:SetFocus(.T.)
	oApp():nEdit --

RETURN NIL

/*_____________________________________________________________________________*/

function EtImprime(oGrid,oParent)
   local nRecno   := ET->(Recno())
   local nOrder   := ET->(OrdSetFocus())
   local aCampos  := { "ETNOMBRE", "ETINVEN" }
   local aTitulos := { "Etiqueta", "Inventario" }
   local aWidth   := { 40, 15 }
   local aShow    := { .t., .t.}
   local aPicture := { "NO","999" }
   local aTotal   := { .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "ET" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      ET->(DbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                     oInforme:oReport:Say(1, 'Total etiquetas: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                     oInforme:oReport:EndLine() )
         oInforme:End(.t.)
      endif
   endif
   ET->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
RETURN NIL
//_____________________________________________________________________________//

