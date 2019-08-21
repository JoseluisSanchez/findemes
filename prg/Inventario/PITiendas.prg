#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

STATIC oReport

function Tiendas()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "TiState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "TiOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "TiRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "TiSplit","102", oApp():cIniFile))
   local oCont
   local i

   if oApp():oDlg != NIL
      if oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
         retu NIL
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   if ! Db_OpenAllInv()
      retu NIL
   endif

   SELECT TI
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de tiendas')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "TI"

   // ojo falta la categoría
   aBrowse   := { { { || TI->TiNombre }, i18n("Tienda"), 150, 0 },;
                  { { || TI->TiInven }, i18n("Inventario"), 120, 0 },;
						{ { || TI->TiCif }, i18n("CIF / NIF"), 120, 0 },;
                  { { || TI->TiContacto }, i18n("Contacto"), 120, 0 },;
                  { { || TI->TiDirecc }, i18n("Dirección"), 120, 0 },;
                  { { || TI->TiLocali }, i18n("Localidad"), 120, 0 },;
                  { { || TI->TiTelefono }, i18n("Telefono"), 120, 0 },;
                  { { || TI->TiPais }, i18n("Pais"), 120, 0 },;
                  { { || TI->TiEmail }, i18n("E-mail"), 150, 0 },;
                  { { || TI->TiURL }, i18n("Sitio web"), 150, 0 } }


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
      oCol:bLDClickData  := {|| TiEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"Ti") }
   oApp():oGrid:bKeyDown := {|nKey| TiTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )

   TI->(DbSetOrder(nOrder))
   TI->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(TI->(OrdKeyNo()),'@E 999,999')+" / "+tran(TI->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_TIENDAS" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 195 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  tiendas " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION TiEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION TiEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   //DEFINE VMENUITEM OF oBar        ;
   //   CAPTION "Duplicar"           ;
   //   IMAGE "16_duplica"           ;
   //   ACTION TiEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
   //   LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION TiBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION TiBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION TiImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver inventario"        ;
      IMAGE "16_invent"        ;
      ACTION TiInventario( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_internet"          ;
      ACTION GoWeb(TI->TiUrl)      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_email"             ;
      ACTION GoMail(TI->TiEmail)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Marcas" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "TiState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Tienda ', ' Cif / Nif ', ' Contacto ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              TI->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"TI") )

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
              WritePProString("Browse","TiState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","TiOrder",Ltrim(Str(TI->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","TiRecno",Ltrim(Str(TI->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","TiSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return Nil
/*_____________________________________________________________________________*/

function TiEdita(oGrid,nMode,oCont,oParent,cTienda)
   local oDlg
   local aTitle := { i18n( "Añadir una tienda" )   ,;
                     i18n( "Modificar una tienda") ,;
                     i18n( "Duplicar una tienda") }
   local aGet[12], oSay
   local cTiNombre   ,;
         cTiCif      ,;
         cTiNotas    ,;
         cTiDirecc   ,;
         cTiLocali   ,;
         cTiPais     ,;
         cTiTelefono ,;
         cTiContacto ,;
         cTiEmail    ,;
         cTiUrl

   local nRecPtr  := TI->(RecNo())
   local nOrden   := TI->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if TI->(EOF()) .AND. nMode != 1
      RETU NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      TI->(DbAppend())
      nRecAdd := TI->(RecNo())
   endif

   cTiNombre   := IIF(nMode==1.AND.cTienda!=NIL,cTienda,TI->TiNombre)
   cTiCif      := TI->TiCif
   cTidirecc   := TI->TiDirecc
   cTiLocali   := TI->TiLocali
   cTitelefono := TI->Titelefono
   cTiContacto := TI->TiContacto
   cTiPais     := TI->TiPais
   cTiemail    := TI->TiEmail
   cTiurl      := TI->TiUrl
   cTinotas    := TI->Tinotas

   if nMode == 3
      TI->(DbAppend())
      nRecAdd := TI->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "MAEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

	REDEFINE SAY oSay PROMPT 'Tienda' ID 201 OF oDlg

   REDEFINE GET aGet[1] VAR cTiNombre  ;
      ID 101 OF oDlg UPDATE            ;
      VALID TiClave( cTiNombre, aGet[1], nMode, 1 )

   REDEFINE GET aGet[2] VAR cTiCif     ;
      ID 102 OF oDlg UPDATE            ;
      VALID TiClave( cTiCIF, aGet[2], nMode, 2 )

   REDEFINE GET aGet[3] VAR cTiContacto;
      ID 103 OF oDlg UPDATE

   REDEFINE GET aGet[4] VAR cTiDirecc  ;
      ID 104 OF oDlg UPDATE

   REDEFINE GET aGet[5] VAR cTiLocali  ;
      ID 105 OF oDlg UPDATE

   REDEFINE GET aGet[6] VAR cTipais    ;
      ID 106 OF oDlg UPDATE

   REDEFINE GET aGet[7] VAR cTiTelefono;
      ID 107 OF oDlg UPDATE

   REDEFINE GET aGet[8] VAR cTiEmail  ;
      ID 110 OF oDlg UPDATE

   REDEFINE BUTTON aGet[9]          ;
      ID 111 OF oDlg                ;
      ACTION GoMail( cTiEmail )
   aGet[9]:cTooltip := "enviar e-mail"

   REDEFINE GET aGet[10] VAR cTiURL ;
      ID 112 OF oDlg UPDATE

   REDEFINE BUTTON aGet[11]         ;
      ID 113 OF oDlg                ;
      ACTION GoWeb( cTiURL )
   aGet[11]:ctooltip := "visitar sitio web"

   REDEFINE GET aGet[12] VAR cTiNotas  ;
      MULTILINE ID 114 OF oDlg UPDATE

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
         TI->(DbGoTo(nRecPtr))
      else
         TI->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el nombre del proveedor en los apuntes__________________//
      if nMode == 2
         if cTiNombre != TI->TiNombre
            msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               { || TiCambiaClave( cTiNombre, TI->TiNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      Replace TI->Tinombre   with cTinombre
      Replace TI->TiCif      with cTiCIF
      Replace TI->TiDirecc   with cTidirecc
      Replace TI->TiLocali   with cTiLocali
      Replace TI->Titelefono with cTitelefono
      Replace TI->TiContacto with cTiContacto
      Replace TI->TiPais     with cTiPais
      Replace TI->TiEmail    with cTiemail
      Replace TI->TiUrl      with cTiurl
      Replace TI->Tinotas    with cTinotas
      TI->(DbCommit())
      if cTienda != NIL
         cTienda := TI->TiNombre
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         TI->(DbGoTo(nRecAdd))
         TI->(DbDelete())
         TI->(DbPack())
         TI->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT MA
   if oCont != NIL
      RefreshCont(oCont,"TI")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function TiBorra(oGrid,oCont)
   local nRecord := TI->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta tienda ?") + CRLF + ;
                (trim(TI->TiNombre)))
      msgRun( i18n( "Revisando el fichero de bienes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || TiCambiaClave( space(40), TI->TiNombre ) } )

      SELECT TI
      TI->(DbSkip())
      nNext := TI->(Recno())
      TI->(DbGoto(nRecord))
      TI->(DbDelete())
      TI->(DbPack())
      TI->(DbGoto(nNext))
      if TI->(EOF()) .or. nNext == nRecord
         TI->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"TI")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
/*_____________________________________________________________________________*/

function TiTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      TiEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      TiEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      TiBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         TiBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         TiBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase
return nil
/*_____________________________________________________________________________*/

function TiSeleccion( cTienda, oControl, oParent )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := TI->( RecNo() )
   local nOrder := TI->( OrdNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""

   oApp():nEdit ++
   TI->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "TiAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de tiendas" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "TI"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || TI->TiNombre }
   oCol:cHeader  := i18n( "Tienda" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| TiTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION TiEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION TiEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION TiBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION TiBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      oControl:cText := TI->TiNombre
   endif

   SetIni( , "Browse", "TiAux", oBrowse:SaveState() )
   TI->( DbSetOrder( nOrder ) )
   TI->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return NIL
/*_____________________________________________________________________________*/

function TiBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := TI->(OrdNumber())
   local nRecno   := TI->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de tiendas")
   oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca la tienda" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Tienda" )+":" ID 21 OF Odlg
      cGet     := space(40)
   elseif nOrder == 2
      REDEFINE SAY PROMPT i18n( "Introduzca el CIF/NIF" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "CIF/NIF" )+":" ID 21 OF Odlg
      cGet     := space(15)
   elseif nOrder == 3
      REDEFINE SAY PROMPT i18n( "Introduzca el contacto" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Contacto" )+":" ID 21 OF Odlg
      cGet     := space(40)
   endif

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
         { || TiWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ninguna tienda")
      else
         TiEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   TI->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "TI" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function TiWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := TI->(Recno())

   do case
      case nOrder == 1
         TI->(DbGoTop())
         do while ! TI->(eof())
            if cGet $ upper(TI->TiNombre)
               aadd(aBrowse, {TI->TiNombre, TI->TiCIF, TI->TiContacto })
            endif
            TI->(DbSkip())
         enddo
      case nOrder == 2
         TI->(DbGoTop())
         do while ! TI->(eof())
            if cGet $ upper(TI->TiCIF)
               aadd(aBrowse, {TI->TiNombre, TI->TiCIF, TI->TiContacto })
            endif
            TI->(DbSkip())
         enddo
      case nOrder == 3
         TI->(DbGoTop())
         do while ! TI->(eof())
            if cGet $ upper(TI->TiContacto)
               aadd(aBrowse, {TI->TiNombre, TI->TiCIF, TI->TiContacto })
            endif
            TI->(DbSkip())
         enddo
   end case
   TI->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/

function TiEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := TI->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Tienda"
   oBrowse:aCols[2]:cHeader := "CIF / NIF"
   oBrowse:aCols[3]:cHeader := "Contacto"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   oBrowse:aCols[3]:nWidth  := 140
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   TI->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||TI->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           TiEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(TI->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     TiEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || TI->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (TI->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function TiClave( cTienda, oGet, nMode, nTag )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := TI->( RecNo() )
   local nOrder   := TI->( OrdNumber() )
   local nArea    := Select()

   if Empty( cTienda )
      if nMode == 4 .OR. nTag == 2
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT MA
   TI->( DbSetOrder( nTag ) )
   TI->( DbGoTop() )

   if TI->( DbSeek( UPPER( cTienda ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Tienda existente.")
         Case nMode == 2
            if TI->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Tienda existente.")
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
         if MsgYesNo("Tienda inexistente. ¿ Desea darla de alta ahora? ")
            lReturn := TiEdita( , 1, , , @cTienda )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      iif(nTag==1,oGet:cText(space(40)),oGet:cText(space(15)))
   else
      oGet:cText( cTienda )
   endif

   TI->( DbSetOrder( nOrder ) )
   TI->( DbGoTo( nRecno ) )

   Select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function TiCambiaClave( cNew, cOld )
   local nAuxOrder
   local nAuxRecNo
   cOld := upper(rtrim(cOld))
	// cambio la tienda en el inventario
   Select BI
   nAuxRecno := BI->(RecNo())
   nAuxOrder := BI->(OrdNumber())
   BI->(DbSetOrder(0))
   BI->(DbGoTop())
   Replace BI->BiTienda   ;
      with cNew            ;
      for Upper(Rtrim(BI->BiTienda)) == Upper(rtrim(cOld))
   BI->(DbSetOrder( nAuxOrder ))
   BI->(DbGoTo( nAuxRecno ))
   SELECT TI
return NIL

//_____________________________________________________________________________//

function TiInventario( oGrid, oParent )

	local cTienda := TI->TiNombre
	local oDlg, oBrowse, oCol
	local aBrowse := {}

	select BI
	BI->(dbGoTop())
	do while ! BI->(Eof())
		if Upper(BI->BiTienda) == Upper(cTienda)
			AAdd(aBrowse, { BI->BiDenomi, BI->BiMarca, BI->BiModelo, tran(BI->BiPrecio,"@E 999,999.99"), BI->(RecNo()) })
		endif
		BI->(dbSkip())
	enddo
	if Len(aBrowse) == 0
		MsgStop("La tienda no aparece en el inventario.")
		retu nil
	endif

	oApp():nEdit ++

	DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
		TITLE 'Inventario de la tienda: '+RTrim(cTienda) OF oParent
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

	select TI
	oGrid:Refresh()
	oGrid:SetFocus(.T.)
	oApp():nEdit --

return nil

/*_____________________________________________________________________________*/

function TiImprime(oGrid,oParent)
   local nRecno   := TI->(Recno())
   local nOrder   := TI->(OrdSetFocus())
   local aCampos  := { "TINOMBRE", "TIINVEN", "TICIF", "TICONTACTO", "TIDIRECC", ;
							  "TITELEFONO", "TIlocalI", "TIPAIS", "TIEMAIL", "TIURL" }
   local aTitulos := { "Tienda", "Inventario", "Cif / NIF", "Contacto", "Dirección",;
 							  "Teléfono", "Localidad", "Pais", "e-mail", "Sitio web " }
   local aWidth   := { 40, 15, 15, 40, 40, 40, 20, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","999","NO","NO","NO","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .f., .f., .f., .f., .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "TI" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      TI->(DbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                     oInforme:oReport:Say(1, 'Total tiendas: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                     oInforme:oReport:EndLine() )
         oInforme:End(.t.)
      endif
   endif
   TI->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
RETURN NIL
//_____________________________________________________________________________//

function TiList( aList, cData, oSelf )
   local aNewList := {}
   TI->( dbSetOrder(1) )
   TI->( dbGoTop() )
   while ! TI->(Eof())
      if at(Upper(cdata), Upper(TI->TiNombre)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { TI->TiNombre } )
      endif 
      TI->(DbSkip())
   enddo
return aNewlist
