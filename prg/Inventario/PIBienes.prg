#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "ZoomImage.ch"
#include "splitter.ch"
#include "vmenu.ch"
#include "AutoGet.ch"

static oReport
Static oBiImage

function Bienes()

   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "BiState","", oApp():cIniFile)
   local nOrder := Val(GetPvProfString("Browse", "BiOrder","1", oApp():cIniFile))
   local nRecno := Val(GetPvProfString("Browse", "BiRecno","1", oApp():cIniFile))
   local nSplit := Val(GetPvProfString("Browse", "BiSplit","102", oApp():cIniFile))
   local oCont
   local i

   if oApp():oDlg != NIL
      if oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
         retu nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   if ! Db_OpenAllInv()
      retu nil
   endif

   select BI
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de elementos de inventario')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "BI"

   // ojo falta la categoría
   aBrowse   := { { {|| BI->BiDenomi }, i18n("Identificador"), 150, 0, NIL },;
      { {|| BI->BiMarca }, i18n("Marca"), 120, 0, NIL },;
      { {|| BI->BiCategor }, i18n("Categoría"), 120, 0, NIL },;
      { {|| BI->BiModelo }, i18n("Modelo"), 120, 0, NIL },;
		{ {|| BI->BiUnidades }, i18n("Unidades"),60, AL_RIGHT, "@E 999,999" },;
      { {|| BI->BiNserie }, i18n("Num. Serie"), 120, 0, NIL },;
      { {|| BI->BiUbicaci }, i18n("Ubicación"), 120, 0, NIL },;
      { {|| DToC(BI->BiFCompra) }, i18n("F. Compra"), 120, 0, NIL },;
      { {|| DToC(BI->BiFFGarant) }, i18n("F. Garantía"), 150, 0, NIL },;
      { {|| BI->BiPrecio }, i18n("Precio"), 120, AL_RIGHT, "@E 999,999.99" },;
      { {|| BI->BiTienda }, i18n("Tienda"), 150, 0, NIL },;
		{ {|| iif(BI->BiApunte==.t.,'SI','NO') }, i18n("Apunte"), 150, 0, NIL },;
      { {|| BI->BiTags }, i18n("Etiquetas"), 150, 0, NIL } }

   for i := 1 to Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
      if aBrowse[i,5] != NIL
         oCol:cEditPicture := aBrowse[i,5]
      endif
   next

   for i := 1 to Len(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| BIEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   next

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont(oCont,"BI"), RefreshBiImage() }
   oApp():oGrid:bKeyDown := {|nKey| BiTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )

   BI->(dbSetOrder(nOrder))
   BI->(dbGoto(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(BI->(ordKeyNo()),'@E 999,999')+" / "+tran(BI->(ordKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_INVENT" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 295 OF oApp():oDlg  ;
      color CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  inventario " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION BiEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION BiEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION BiBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION BiBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION BiImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

	DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Anotar apunte"      ;
      IMAGE "16_Apuntes"           ;
      ACTION BiApunte(oApp():oGrid,oApp():oDlg)            ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Bienes" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "MaState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
      ITEMS ' Denominación ', ' Marca ', ' Categoría', ' Ubicación', ' Fecha de compra', ' Fecha de garantía' ;
      ACTION ( nOrder := oApp():oTab:nOption,;
      BI->(dbSetOrder(nOrder)),;
      oApp():oGrid:Refresh(.T.),;
      RefreshCont(oCont,"BI") )

   @ 00, nSplit SPLITTER oApp():oSplit ;
      VERTICAL ;
      PREVIOUS CONTROLS oCont, oBar, oBiImage ;
      HINDS CONTROLS oApp():oGrid, oApp():oTab ;
      SIZE 1, oApp():oDlg:nGridBottom + oApp():oTab:nHeight PIXEL ;
      OF oApp():oDlg ;
      _3DLOOK ;
      UPDATE

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      on INIT ( ResizeWndMain(), BiBarImage(oBar, nSplit), oApp():oGrid:SetFocus() );
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString("Browse","BiState",oApp():oGrid:SaveState(),oApp():cIniFile),;
      WritePProString("Browse","BiOrder",LTrim(Str(BI->(ordNumber()))),oApp():cIniFile),;
      WritePProString("Browse","BiRecno",LTrim(Str(BI->(RecNo()))),oApp():cIniFile),;
      WritePProString("Browse","BiSplit",LTrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

return nil
/*-----------------------------------------------------------------------------*/
function BiBarImage(oBar, nBrwSplit)
	// oBiImage := TImage():New(285,10,(2*nBrwSplit)-40,(2*nBrwSplit)-40,,,.t.,oBar,,,,,,,,,.t.,,)
	oBiImage := TZoomImage():New(285,10,(2*nBrwSplit)-40,(2*nBrwSplit)-40,,,.t.,oBar,,,,.t.,,,,,.t.,,)
	//oBiImage:lStretch := .f.
	if File(lfn2sfn(rtrim(BI->BiImagen)))
      oBiImage:LoadBmp(lfn2sfn(rtrim(BI->BiImagen)))
   endif
return nil
/*-----------------------------------------------------------------------------*/
function RefreshBiImage()
	if File(lfn2sfn(rtrim(BI->BiImagen)))
		oBiImage:Show()
      oBiImage:LoadBmp(lfn2sfn(rtrim(BI->BiImagen)))
   else
		oBiImage:Hide()
	endif
	oBiImage:Refresh()
return nil

/*_____________________________________________________________________________*/

function BiEdita(oGrid,nMode,oCont,oParent)

   local oDlg
   local aTitle := { i18n( "Añadir un elemento al inventario" ),;
      					i18n( "Modificar un elemento al inventario"),;
      					i18n( "Duplicar un elemento al inventario") }
   local aGet[21]
   local cBiDenomi,;
      cBiMarca,;
      cBiCategor,;
      cBiModelo,;
		nBiUnidades,;
      cBiNSerie,;
      cBiUbicaci,;
      dBiFCompra,;
      dBiFFGarant,;
      nBiPrecio,;
		lBiApunte,;
      cBiTienda,;
      cBiObserv,;
      cBiTags	,;
		cBiImagen
   local nRecPtr  := BI->(RecNo())
   local nOrden   := BI->(ordNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .F.
	local oTags, i
	local aTags 	:= {}
	local aTagsB   := {}

   if BI->(Eof()) .AND. nMode != 1
      retu nil
   endif
   oApp():nEdit ++

   if nMode == 1
      BI->(dbAppend())
      nRecAdd := BI->(RecNo())
   endif
	cBiDenomi 	:= BI->BiDenomi
   cBiMarca		:= BI->BiMarca
	cBiCategor 	:= BI->BiCategor
   cBiModelo   := BI->BiModelo
	nBiUnidades := BI->BiUnidades
   cBiNSerie   := BI->BiNserie
   cBiUbicaci  := BI->BiUbicaci
   dBiFCompra 	:= BI->BiFCompra
	dBiFFGarant	:= BI->BiFFGarant
   nBiPrecio	:= BI->BiPrecio
	lBiApunte 	:= BI->BiApunte
   cBiTienda	:= BI->BiTienda
   cBiObserv	:= BI->BiObserv
	cBiImagen   := BI->BiImagen
   cBiTags		:= BI->BiTags
   aTags       := iif(At(';',cBiTags)!=0, hb_ATokens( cBiTags, ";"), {})
	if Len(aTags) > 1
      ASize( aTags, Len(aTags)-1)
      for i:=1 to Len(aTags)
         aTags[i] := AllTrim(aTags[i])
         AAdd(aTagsB, aTags[i])
      next
   endif

   if nMode == 3
      BI->(DbAppend())
      nRecAdd := BI->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "BIEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cBiDenomi  ;
      ID 101 OF oDlg UPDATE            ;
      VALID BiClave( cBiDenomi, aGet[1], nMode, 1 )

	REDEFINE AUTOGET aGet[2] VAR cBiMarca	;
		DATASOURCE {}						;
		FILTER MaList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 102 OF oDlg UPDATE            	;
		VALID MaClave( cBiMarca, aGet[2], 4, 1 )

	REDEFINE BUTTON aGet[3] ID 103 OF oDlg ;
      ACTION MaSeleccion( cBiMarca, aGet[2], oDlg )

   REDEFINE GET aGet[4] VAR cBiModelo  ;
      ID 104 OF oDlg UPDATE

	REDEFINE GET aGet[21] VAR nBiUnidades  ;
      PICT '@E 999,999' ID 125 OF oDlg UPDATE

   REDEFINE GET aGet[5] VAR cBiNSerie  ;
      ID 105 OF oDlg UPDATE

   REDEFINE AUTOGET aGet[6] VAR cBiCategor	;
		DATASOURCE {}						;
		FILTER CaList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 106 OF oDlg UPDATE            	;
		VALID CaClave( cBiCategor, aGet[6], 4, 1 )
	REDEFINE BUTTON aGet[7] ID 107 OF oDlg ;
      ACTION CaSeleccion( cBiCategor, aGet[6], oDlg )

	REDEFINE AUTOGET aGet[8] VAR cBiUbicaci;
		DATASOURCE {}						;
		FILTER UbList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 108 OF oDlg UPDATE            	;
		VALID UbClave( cBiUbicaci, aGet[8], 4, 1 )
	REDEFINE BUTTON aGet[9] ID 109 OF oDlg ;
		ACTION UbSeleccion( cBiCategor, aGet[8], oDlg )

   REDEFINE GET aGet[10] VAR dBiFCompra ;
      ID 111 OF oDlg UPDATE
	REDEFINE BUTTON aGet[11] ID 112 OF oDlg ;
      ACTION SelecFecha(@dBiFCompra,aGet[10])

   REDEFINE GET aGet[12] VAR dBiFFGarant ;
      ID 113 OF oDlg UPDATE
	REDEFINE BUTTON aGet[13] ID 114 OF oDlg ;
      ACTION SelecFecha(@dBiFFGarant,aGet[12])

	REDEFINE GET aGet[14] VAR nBiPrecio ;
      PICTURE "@E 9,999,999.99"        ;
      ID 115 OF oDlg

	REDEFINE CHECKBOX aGet[20] VAR lBiApunte ;
      ID 123 OF oDlg WHEN .f.

   REDEFINE AUTOGET aGet[15] VAR cBiTienda	;
		DATASOURCE {}						;
		FILTER TiList( uDataSource, cData, Self );     
		HEIGHTLIST 100 ;
		ID 116 OF oDlg UPDATE            	;
		VALID TiClave( cBiTienda, aGet[15], 4, 1 )
	//REDEFINE GET aGet[15] VAR cBiTienda ;
   //   ID 116 OF oDlg UPDATE 				;
	//	VALID TiClave( cBiTienda, aGet[15], 4, 1)
	REDEFINE BUTTON aGet[16] ID 117 OF oDlg ;
      ACTION TiSeleccion( cBiTienda, aGet[15], oDlg )

	oTags := TTagEver():Redefine(118, oDlg, , aTags )
	oTags:SetFont(oApp():oFont)

	REDEFINE BUTTON aGet[17]     ;
			ID 119 OF oDlg UPDATE  ;
			ACTION EtSeleccion( @aTags, oTags, oDlg )

	REDEFINE GET aGet[18] VAR cBiObserv ;
      ID 120 OF oDlg MEMO

	REDEFINE ZOOMIMAGE aGet[19] FILE "" ID 121 OF oDlg

	if File(lfn2sfn(rtrim(cBiImagen)))
		aGet[19]:LoadBmp(lfn2sfn(rtrim(cBiImagen)))
	endif

	REDEFINE BUTTON aGet[20];
      ID 122 OF oDlg			;
      ACTION BiGetImagen( aGet[19], @cBiImagen )

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( aTags:=oTags:aItems, oDlg:end( IDOK ) )

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
         BI->(DbGoTo(nRecPtr))
      else
         BI->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el número de bienes en la marca
      if Upper(RTrim(BI->BiMarca)) != Upper(RTrim(cBiMarca))
         select MA
			MA->(ordSetFocus(1))
         MA->(dbSeek(Upper(cBiMarca)))
         replace MA->MaInven with MA->MaInven + 1
         if nMode == 2
            MA->(dbSeek(Upper(BI->BiMarca)))
            replace MA->MaInven with MA->MaInven - 1
         endif
      endif
      // ___ actualizo el número de bienes en la categoría
      if Upper(RTrim(BI->BiCategor)) != Upper(RTrim(cBiCategor))
         select CA
			CA->(ordSetFocus(1))
         CA->(dbSeek(Upper(cBiCategor)))
         replace CA->CaInven with CA->CaInven + 1
         if nMode == 2
            CA->(dbSeek(Upper(BI->BiCategor)))
            replace CA->CaInven with CA->CaInven - 1
         endif
      endif
		// ___ actualizo el número de bienes en la ubicación
      if Upper(RTrim(BI->BiUbicaci)) != Upper(RTrim(cBiUbicaci))
         select UB
			UB->(ordSetFocus(1))
         UB->(dbSeek(Upper(cBiUbicaci)))
         replace UB->UbInven with UB->UbInven + 1
         if nMode == 2
            UB->(dbSeek(Upper(BI->BiUbicaci)))
            replace UB->UbInven with UB->UbInven - 1
         endif
      endif
		// ___ actualizo el número de bienes en la tienda
      if Upper(RTrim(BI->BiTienda)) != Upper(RTrim(cBiTienda))
         select TI
			TI->(ordSetFocus(1))
         TI->(dbSeek(Upper(cBiTienda)))
         replace TI->TiInven with TI->TiInven + 1
         if nMode == 2
            TI->(dbSeek(Upper(BI->BiTienda)))
            replace UB->UbInven with UB->UbInven - 1
         endif
      endif
		// ___ actualizo el número de bienes en etiquetas __________//
		select ET
		ET->(dbSetOrder(1))
		if Len(aTags) > 0
			for i := 1 to Len(aTags)
				// TTagEver transforma aTags en un array multidimensional
				if ValType(aTags[i]) == 'A'
					aTags[i] := aTags[i,1]
				endif
				ET->(dbSeek(Upper(RTrim(aTags[i]))))
				replace ET->EtInven with ET->EtInven + 1
			next
			ET->(dbCommit())
			if nMode == 2
				for i := 1 to Len(aTagsB)
					ET->(dbSeek(Upper(AllTrim(aTagsB[i]))))
					replace ET->EtInven with ET->EtInven - 1
				next
			endif
		endif
      // ___ guardo el registro _______________________________________________//
		Replace BI->BiDenomi		  with cBiDenomi
		Replace BI->BiMarca		  with cBiMarca
		Replace BI->BiCategor	  with cBiCategor
		Replace BI->BiModelo		  with cBiModelo
		Replace BI->BiUnidades	  with nBiUnidades
		Replace BI->BiNserie		  with cBiNSerie
		Replace BI->BiUbicaci	  with cBiUbicaci
		Replace BI->BiFCompra	  with dBiFCompra
		Replace BI->BiFFGarant	  with dBiFFGarant
		Replace BI->BiPrecio		  with nBiPrecio
		Replace BI->BiTienda		  with cBiTienda
		Replace BI->BiObserv		  with cBiObserv
		Replace BI->BiImagen		  with cBiImagen
		cBiTags := ''
      if Len(aTags) > 0
         for i := 1 to Len(aTags)
            cBiTags := cBiTags + aTags[i]+'; '
         next
      endif
	   Replace BI->BiTags		  with cBiTags
      BI->(DbCommit())
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         BI->(DbGoTo(nRecAdd))
         BI->(DbDelete())
         BI->(DbPack())
         BI->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT BI
   if oCont != NIL
      RefreshCont(oCont,"BI")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif
*/

return lReturn
/*_____________________________________________________________________________*/

function biGetImagen( oImage, cImagen )
	local cImageFile
	cImageFile := cGetfile32( i18n("Archivos de imagen") + ;
									  " (bmp,jpg,gif,png,dig,pcx,tga,rle) | " + ;
									  "*.bmp;*.jpg;*.gif;*.png;*.dig;*.pcx;*.tga;*.rle |",;
									  i18n("Indica la ubicación de la imagen"),,oApp():cInvImgPath,, .t. )

	if ! empty(cImageFile) .and. File(lfn2sfn(rtrim(cImageFile)))
		oImage:LoadBmp(lfn2sfn(rtrim(cImageFile)))
		cImagen := cImageFile
	endif

return NIL
/*_____________________________________________________________________________*/

function BiBorra(oGrid,oCont)

   local nRecord := BI->(RecNo())
   local nNext, i
	local aTags := {}

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este elemento del inventario ?") + CRLF + ;
         (Trim(BI->BiDenomi)))
		// ___ actualizo el número de bienes en la marca
		if ! empty(BI->BiMarca)
	   	select MA
			MA->(dbgotop())
	   	if MA->(dbSeek(Upper(BI->BiMarca)))
	   		replace MA->MaInven with MA->MaInven - 1
			endif
		endif
	   // ___ actualizo el número de bienes en la categoría
		if ! empty(BI->BiCategor)
	   	select CA
			CA->(dbgotop())
	   	if CA->(dbSeek(Upper(BI->BiCategor)))
	   		replace CA->CaInven with CA->CaInven - 1
			endif
		endif
		// ___ actualizo el número de bienes en la ubicación
		if ! empty(BI->BiUbicaci)
	   	select UB
			UB->(dbgotop())
	   	if UB->(dbSeek(Upper(BI->BiUbicaci)))
	   		replace UB->UbInven with UB->UbInven - 1
			endif
		endif
		// ___ actualizo el número de bienes en la tienda
		if ! empty(BI->BiTienda)
	   	select TI
			TI->(dbgotop())
	   	if TI->(dbSeek(Upper(BI->BiTienda)))
	   		replace TI->TiInven with TI->TiInven - 1
			endif
		endif
		// ___ actualizo el número de bienes en etiquetas __________//
		aTags := iif(At(';',BI->BiTags)!=0, hb_ATokens( BI->BiTags, ";"), {})
		if Len(aTags) > 1
			ASize( aTags, Len(aTags)-1)
			for i:=1 to Len(aTags)
				ET->(dbGoTop())
				if ET->( dbSeek( Upper(Alltrim(aTags[i] )) ) )
					replace ET->EtInven with ET->EtInven - 1
				endif
			next
		endif
      select BI
      BI->(dbSkip())
      nNext := BI->(RecNo())
      BI->(dbGoto(nRecord))
      BI->(dbDelete())
      BI->(DbPack())
      BI->(dbGoto(nNext))
      if BI->(Eof()) .OR. nNext == nRecord
         BI->(dbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"BI")
   endif

   oApp():nEdit --
   oGrid:Refresh(.T.)
   oGrid:SetFocus(.T.)

return nil
/*_____________________________________________________________________________*/

function BiTecla(nKey,oGrid,oCont,oDlg)

   do case
   case nKey==VK_RETURN
      BiEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      BiEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      BiBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   otherwise
      if nKey >= 96 .AND. nKey <= 105
         BIBusca(oGrid,Str(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(Chr(nKey))
         BIBusca(oGrid,Chr(nKey),oCont,oDlg)
      endif
   endcase

return nil
/*_____________________________________________________________________________*/

function BiBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := BI->(ordNumber())
   local nRecno   := BI->(RecNo())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .F.
   local lFecha   := .F.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de elemento de inventario")
   oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE say prompt i18n( "Introduzca la denominación" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Denominación" )+":" ID 21 OF Odlg
      cGet     := Space(50)
   elseif nOrder == 2
      REDEFINE say prompt i18n( "Introduzca la marca" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Marca" )+":" ID 21 OF Odlg
      cGet     := Space(40)
   elseif nOrder == 3
      REDEFINE say prompt i18n( "Introduzca la categoría" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Categoría" )+":" ID 21 OF Odlg
      cGet     := Space(40)
	elseif nOrder == 4
      REDEFINE say prompt i18n( "Introduzca la ubicación" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Ubicación" )+":" ID 21 OF Odlg
      cGet     := Space(40)
	elseif nOrder == 5
      REDEFINE say prompt i18n( "Introduzca la fecha de compra" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Fecha de compra" )+":" ID 21 OF Odlg
      cGet     := CtoD('')
		lFecha   := .t.
	elseif nOrder == 6
      REDEFINE say prompt i18n( "Introduzca la fecha de fin de garantía" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "F. de fin garantía" )+":" ID 21 OF Odlg
      cGet     := CtoD('')
		lFecha   := .t.
   endif

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   if cChr != NIL
      if ! lFecha
         cGet := cChr+SubStr(cGet,1,Len(cGet)-1)
      else
         cGet := CToD(cChr+' -  -    ')
      endif
   endif

   if ! lFecha
      REDEFINE get oGet var cGet picture "@!" ID 101 OF oDlg 
   else
      REDEFINE get oGet var cGet ID 101 OF oDlg 
   endif

   if cChr != NIL
      oGet:bGotFocus := {|| oGet:SetPos(2) }
   endif

   REDEFINE BUTTON ID IDOK OF oDlg ;
      prompt i18n( "&Aceptar" )   ;
      ACTION (lSeek := .T., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      prompt i18n( "&Cancelar" )  ;
      ACTION (lSeek := .F., oDlg:End())

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      on INIT ( DlgCenter(oDlg,oApp():oWndMain) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   if lSeek
      if ! lFecha
         cGet := RTrim( Upper( cGet ) )
      else
         cGet := DToS( cGet )
      end if
      MsgRun('Realizando la búsqueda...', oApp():cAppName+oApp():cVersion, ;
         {|| BiWildSeek(nOrder, RTrim(Upper(cGet)), aBrowse ) } )
      if Len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún elemento del inventario.")
      else
         BiEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   BI->(ordSetFocus(nOrder))

   RefreshCont( oCont, "BI" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return nil
/*_____________________________________________________________________________*/
function BiWildSeek(nOrder, cGet, aBrowse)

   local nRecno   := BI->(RecNo())

   do case
   case nOrder == 1
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet $ Upper(BI->BiDenomi)
            AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
   case nOrder == 2
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet $ Upper(BI->BiMarca)
             AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
   case nOrder == 3
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet $ Upper(BI->BiCategor)
             AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
   case nOrder == 4
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet $ Upper(BI->BiUbicaci)
             AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
	case nOrder == 5
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet == BI->BiFCompra
             AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
	case nOrder == 5
      BI->(dbGoTop())
      do while ! BI->(Eof())
         if cGet == BI->BiFFGarant
             AAdd(aBrowse, {Bi->BiDenomi, BI->BiMarca, BI->BiCategor })
         endif
         BI->(dbSkip())
      enddo
   end case
   BI->(dbGoto(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper(aAut1[1]) < Upper(aAut2[1]) } )

return nil
/*_____________________________________________________________________________*/

function BiEncontrados(aBrowse, oParent)

   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := BI->(RecNo())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .F.)
   oBrowse:aCols[1]:cHeader := "Denominación"
   oBrowse:aCols[2]:cHeader := "Marca"
   oBrowse:aCols[3]:cHeader := "Categoría"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   oBrowse:aCols[3]:nWidth  := 140
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   BI->(ordSetFocus(1))
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {||BI->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      BiEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| iif(nKey==VK_RETURN,(CL->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      BiEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := {|| BI->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (BI->(dbGoto(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      on init DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function BiClave( cBien, oGet, nMode, nTag )

   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .F.
   local nRecno   := BI->( RecNo() )
   local nOrder   := BI->( ordNumber() )
   local nArea    := Select()

   if Empty( cBien )
      if nMode == 4 .OR. nTag == 2
         return .T.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         return .F.
      endif
   endif

	select BI
   BI->( dbSetOrder( nTag ) )
   BI->( dbGoTop() )

   if BI->( dbSeek( Upper( cBien ) ) )
      do case
      case nMode == 1 .OR. nMode == 3
         lReturn := .F.
         MsgStop("Elemento existente.")
      case nMode == 2
         if BI->( RecNo() ) == nRecno
            lReturn := .T.
         else
            lReturn := .F.
            MsgStop("Elemento existente.")
         endif
      case nMode == 4
			IF ! oApp():thefull
				Registrame()
			ENDIF
         lReturn := .T.
      end case
   else
      if nMode < 4
         lReturn := .T.
      endif
   endif

   if lReturn == .F.
      iif(nTag==1,oGet:cText(Space(40)),oGet:cText(Space(15)))
   else
      oGet:cText( cBien )
   endif

   BI->( dbSetOrder( nOrder ) )
   BI->( dbGoto( nRecno ) )

   select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function BiImprime(oGrid,oParent)

   local nRecno   := BI->(RecNo())
   local nOrder   := BI->(ordSetFocus())
   local aCampos  := { "BIDENOMI", "BICATEGOR", "BIMARCA", "BIMODELO", "BIUNIDADES", "BINSERIE",;
      "BIUBICACI", "BIFCOMPRA", "BIFFGARANT", "BIPRECIO", "BITIENDA", "BITAGS" }
   local aTitulos := { "Denominación", "Categoría", "Marca", "Modelo", "Unidades", "Nº Serie",;
      "Ubicación", "F. Compra", "F. Fin Gar.", "Precio", "Tienda", "Etiquetas " }
   local aWidth   := { 40, 40, 40, 40, 10, 20, 40, 10, 10, 12, 40, 60 }
   local aShow    := { .T., .T., .T., .t., .T., .T., .T., .T., .T., .T., .T., .T. }
   local aPicture := { "NO","NO","NO","NO","@E999,999","NO","NO","NO","NO","@E 9,999,999.99","NO","NO" }
   local aTotal   := { .F.,.F.,.F.,.F.,.f.,.F.,.F.,.F.,.F.,.t.,.F., .F. }
   local oInforme
	local aGet[15], aSay[7]
	local cCategor, cEtiqueta, cUbicaci, cMarca, cTienda
	local lPeriodo := .f.
   local dInicio  := CtoD('')
	local dFinal   := CtoD('')

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "BI" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio var oInforme:nRadio ID 300,301,302,303,304,305 OF oInforme:oFld:aDialogs[1]

	REDEFINE SAY aSay[1] ID 120 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aGet[1] VAR cCategor ;
      ID 121 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 2
   REDEFINE BUTTON aGet[2] ID 122 OF oInforme:oFld:aDialogs[1] ;
      ACTION CaSeleccion(@cCategor,aGet[1]) ;
      WHEN oInforme:nRadio == 2

	REDEFINE SAY aSay[2] ID 123 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aGet[3] VAR cEtiqueta ;
      ID 124 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 3
   REDEFINE BUTTON aGet[4] ID 125 OF oInforme:oFld:aDialogs[1] ;
      ACTION EtSeleccion(,aGet[3],,@cEtiqueta) ;
      WHEN oInforme:nRadio == 3

	REDEFINE SAY aSay[3] ID 126 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aGet[5] VAR cUbicaci ;
      ID 127 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 4
   REDEFINE BUTTON aGet[6] ID 128 OF oInforme:oFld:aDialogs[1] ;
      ACTION UbSeleccion(@cUbicaci,aGet[5]) ;
      WHEN oInforme:nRadio == 4

	REDEFINE SAY aSay[4] ID 129 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aGet[7] VAR cMarca ;
      ID 130 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 5
   REDEFINE BUTTON aGet[8] ID 131 OF oInforme:oFld:aDialogs[1] ;
      ACTION MaSeleccion(@cMarca,aGet[7]) ;
      WHEN oInforme:nRadio == 5

	REDEFINE SAY aSay[5] ID 132 OF oInforme:oFld:aDialogs[1]
   REDEFINE GET aGet[9] VAR cTienda ;
      ID 133 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN oInforme:nRadio == 6
   REDEFINE BUTTON aGet[10] ID 134 OF oInforme:oFld:aDialogs[1] ;
      ACTION TiSeleccion(@cTienda,aGet[9]) ;
      WHEN oInforme:nRadio == 6

	REDEFINE SAY aSay[6] ID 151 OF oInforme:oFld:aDialogs[1]
	REDEFINE SAY aSay[7] ID 154 OF oInforme:oFld:aDialogs[1]

	REDEFINE CHECKBOX aGet[11] VAR lPeriodo ;
   	ID 150 OF oInforme:oFld:aDialogs[1]

   REDEFINE GET aGet[12] VAR dInicio ;
      ID 152 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aGet[13] ID 153 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dInicio,aGet[12]) ;
      WHEN lPeriodo

   REDEFINE GET aGet[14] VAR dFinal  ;
      ID 155 OF oInforme:oFld:aDialogs[1] UPDATE ;
      WHEN lPeriodo
   REDEFINE BUTTON aGet[15] ID 156 OF oInforme:oFld:aDialogs[1] ;
      ACTION SelecFecha(@dFinal,aGet[14]) ;
      WHEN lPeriodo

   oInforme:Folders()

   if oInforme:Activate()
      BI->(dbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
			if ! lPeriodo
         	ACTIVATE REPORT oInforme:oReport ;
            	on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            	oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            	oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            	oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
         oInforme:End(.T.)
		elseif oInforme:nRadio == 2
			oInforme:Report()
			oInforme:cTitulo3 := "Bienes de la categoría: "+Rtrim(cCategor)
			if ! lPeriodo
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiCategor)) == Upper(Rtrim(cCategor)) ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiCategor)) == Upper(Rtrim(cCategor)) .AND. dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
			oInforme:End(.T.)
		elseif oInforme:nRadio == 3
			oInforme:Report()
			oInforme:cTitulo3 := "Bienes de la etiqueta: "+Rtrim(cEtiqueta)
			if ! lPeriodo
				ACTIVATE REPORT oInforme:oReport ;
					FOR AT(Upper(Rtrim(cEtiqueta)),Upper(BI->BiTags)) != 0 ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR AT(Upper(Rtrim(cEtiqueta)),Upper(BI->BiTags)) != 0 .AND. dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
			oInforme:End(.T.)
		elseif oInforme:nRadio == 4
			oInforme:Report()
			oInforme:cTitulo3 := "Bienes de la ubicación: "+Rtrim(cUbicaci)
			if ! lPeriodo
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiUbicaci)) == Upper(Rtrim(cUbicaci)) ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiUbicaci)) == Upper(Rtrim(cUbicaci)) .AND. dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
			oInforme:End(.T.)
		elseif oInforme:nRadio == 5
			oInforme:Report()
			oInforme:cTitulo3 := "Bienes de la marca: "+Rtrim(cMarca)
			if ! lPeriodo
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiMarca)) == Upper(Rtrim(cMarca)) ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiMarca)) == Upper(Rtrim(cMarca)) .AND. dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
			oInforme:End(.T.)
		elseif oInforme:nRadio == 6
			oInforme:Report()
			oInforme:cTitulo3 := "Bienes de la tienda: "+Rtrim(cTienda)
			if ! lPeriodo
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiTienda)) == Upper(Rtrim(cTienda)) ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			else
				if oInforme:cTitulo3 == nil
					oInforme:cTitulo3 := "Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				else
					oInforme:cTitulo3 := oInforme:cTitulo3 + " ** Periodo de "+DtoC(dInicio)+" a "+DtoC(dFinal)
				endif
				ACTIVATE REPORT oInforme:oReport ;
					FOR Upper(Rtrim(BI->BiTienda)) == Upper(Rtrim(cTienda)) .AND. dInicio <= BI->BiFCompra .AND. BI->BiFCompra <= dFinal ;
					on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
					oInforme:oReport:Say(1, 'Total inventario: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
					oInforme:oReport:EndLine() )								//          oInforme:oReport:EndLine() )
			endif
			oInforme:End(.T.)
      endif
   endif
   BI->(dbGoto(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

return nil
//_____________________________________________________________________________//

function BiApunte(oGrid, oDlg)
	if BI->BiApunte == .t.
		MsgInfo("Ya hay anotado un apunte del elemento del inventario.")
		retu nil
   elseif ! Db_Open("IVA","IV")
      retu nil
   elseif ! Db_Open("APUNTES","AP")
      close IV
		retu nil
   elseif ! Db_Open("GASTOS","GA")
      close IV
		Close AP
      retu nil
   elseif ! Db_Open("PROVEED","PR")
      close IV
		close AP
		close GA
      retu nil
   elseif ! Db_Open("ACTIVIDA","AC")
      close IV
		close AP
		close GA
		close PR
      retu nil
	elseif ! Db_Open("CUENTAS","CC")
      close IV
		close AP
		close GA
		close PR
		close AC
      retu nil
   endif

	// APGEdita1(oGrid,5,oCont,oParent,lCont,oAcMenu,aActividad,dPeFecha)
	if APGEdita1(,5,,oDlg,.f.,,,) == .t.
		replace BI->BiApunte with .t.
	endif
	close IV
	close AP
	close GA
	close PR
	close AC
	close CC
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

return nil

/*_____________________________________________________________________________*/