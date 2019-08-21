#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

static oReport

function Marcas()

   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "MaState","", oApp():cIniFile)
   local nOrder := Val(GetPvProfString("Browse", "MaOrder","1", oApp():cIniFile))
   local nRecno := Val(GetPvProfString("Browse", "MaRecno","1", oApp():cIniFile))
   local nSplit := Val(GetPvProfString("Browse", "MaSplit","102", oApp():cIniFile))
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

   select MA
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de marcas')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "MA"

   // ojo falta la categoría
   aBrowse   := { { {|| MA->MaNombre }, i18n("Marca"), 150, 0 },;
      { {|| MA->MaInven }, i18n("Inventario"), 120, 0 },;
      { {|| MA->MaCif }, i18n("CIF / NIF"), 120, 0 },;
      { {|| MA->MaContacto }, i18n("Contacto"), 120, 0 },;
      { {|| MA->MaDirecc }, i18n("Dirección"), 120, 0 },;
      { {|| MA->MaLocali }, i18n("Localidad"), 120, 0 },;
      { {|| MA->MaTelefono }, i18n("Telefono"), 120, 0 },;
      { {|| MA->MaPais }, i18n("Pais"), 120, 0 },;
      { {|| MA->MaEmail }, i18n("E-mail"), 150, 0 },;
      { {|| MA->MaURL }, i18n("Sitio web"), 150, 0 } }


   for i := 1 to Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   next

   for i := 1 to Len(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| MaEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   next

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont(oCont,"MA") }
   oApp():oGrid:bKeyDown := {|nKey| MaTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )

   MA->(dbSetOrder(nOrder))
   MA->(dbGoto(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(MA->(ordKeyNo()),'@E 999,999')+" / "+tran(MA->(ordKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_MARCAS" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 195 OF oApp():oDlg  ;
      color CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  marcas " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION MaEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION MaEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   //DEFINE VMENUITEM OF oBar        ;
   //   CAPTION "Duplicar"           ;
   //   IMAGE "16_duplica"           ;
   //   ACTION MaEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
   //   LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION MaBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION MaBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION MaImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver inventario"     ;
      IMAGE "16_invent"            ;
      ACTION MaInventario( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_internet"          ;
      ACTION GoWeb(MA->MaUrl)      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_email"             ;
      ACTION GoMail(MA->MaEmail)   ;
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
      ACTION Ut_BrwColConfig( oApp():oGrid, "MaState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
      ITEMS ' Marca ', ' Cif / Nif ', ' Contacto ';
      ACTION ( nOrder := oApp():oTab:nOption,;
      MA->(dbSetOrder(nOrder)),;
      oApp():oGrid:Refresh(.T.),;
      RefreshCont(oCont,"MA") )

   @ 00, nSplit SPLITTER oApp():oSplit ;
      VERTICAL ;
      PREVIOUS CONTROLS oCont, oBar ;
      HINDS CONTROLS oApp():oGrid, oApp():oTab ;
      SIZE 1, oApp():oDlg:nGridBottom + oApp():oTab:nHeight PIXEL ;
      OF oApp():oDlg ;
      _3DLOOK ;
      UPDATE

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      on INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() );
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString("Browse","MaState",oApp():oGrid:SaveState(),oApp():cIniFile),;
      WritePProString("Browse","MaOrder",LTrim(Str(MA->(ordNumber()))),oApp():cIniFile),;
      WritePProString("Browse","MaRecno",LTrim(Str(MA->(RecNo()))),oApp():cIniFile),;
      WritePProString("Browse","MaSplit",LTrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

return nil
/*_____________________________________________________________________________*/

function MaEdita(oGrid,nMode,oCont,oParent,cMarca)

   local oDlg
   local aTitle := { i18n( "Añadir una marca" ),;
      i18n( "Modificar una marca"),;
      i18n( "Duplicar una marca") }
   local aGet[12]
   local cMaNombre,;
      cMaCif,;
      cMaNotas,;
      cMaDirecc,;
      cMaLocali,;
      cMaPais,;
      cMaTelefono,;
      cMaContacto,;
      cMaEmail,;
      cMaUrl

   local nRecPtr  := MA->(RecNo())
   local nOrden   := MA->(ordNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .F.

   if MA->(Eof()) .AND. nMode != 1
      retu nil
   endif
   oApp():nEdit ++

   if nMode == 1
      MA->(dbAppend())
      nRecAdd := MA->(RecNo())
   endif

   cMaNombre   := iif(nMode==1.AND.cMarca!=NIL,cMarca,MA->MaNombre)
   cMaCif      := MA->MaCif
   cMadirecc   := MA->MaDirecc
   cMaLocali   := MA->MaLocali
   cMatelefono := MA->Matelefono
   cMaContacto := MA->MaContacto
   cMaPais     := MA->MaPais
   cMaemail    := MA->MaEmail
   cMaurl      := MA->MaUrl
   cManotas    := MA->Manotas

   if nMode == 3
      MA->(dbAppend())
      nRecAdd := MA->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "MAEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE get aGet[1] var cMaNombre  ;
      ID 101 OF oDlg UPDATE            ;
      valid MaClave( cMaNombre, aGet[1], nMode, 1 )

   REDEFINE get aGet[2] var cMaCif     ;
      ID 102 OF oDlg UPDATE            ;
      valid MaClave( cMaCIF, aGet[2], nMode, 2 )

   REDEFINE get aGet[3] var cMaContacto;
      ID 103 OF oDlg UPDATE

   REDEFINE get aGet[4] var cMaDirecc  ;
      ID 104 OF oDlg UPDATE

   REDEFINE get aGet[5] var cMaLocali  ;
      ID 105 OF oDlg UPDATE

   REDEFINE get aGet[6] var cMapais    ;
      ID 106 OF oDlg UPDATE

   REDEFINE get aGet[7] var cMaTelefono;
      ID 107 OF oDlg UPDATE

   REDEFINE get aGet[8] var cMaEmail  ;
      ID 110 OF oDlg UPDATE

   REDEFINE BUTTON aGet[9]          ;
      ID 111 OF oDlg                ;
      ACTION GoMail( cMaEmail )
   aGet[9]:cTooltip := "enviar e-mail"

   REDEFINE get aGet[10] var cMaURL ;
      ID 112 OF oDlg UPDATE

   REDEFINE BUTTON aGet[11]         ;
      ID 113 OF oDlg                ;
      ACTION GoWeb( cMaURL )
   aGet[11]:ctooltip := "visitar sitio web"

   REDEFINE get aGet[12] var cMaNotas  ;
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
      on init DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
      lReturn := .T.
      if nMode == 2
         MA->(dbGoto(nRecPtr))
      else
         MA->(dbGoto(nRecAdd))
      endif
      // ___ actualizo el nombre del proveedor en los apuntes__________________//
      if nMode == 2
         if cMaNombre != MA->MaNombre
            msgRun( i18n( "Revisando el fichero de inventariio. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               {|| MaCambiaClave( cMaNombre, MA->MaNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      replace MA->Manombre   with cManombre
      replace MA->MaCif      with cMaCIF
      replace MA->MaDirecc   with cMadirecc
      replace MA->MaLocali   with cMaLocali
      replace MA->Matelefono with cMatelefono
      replace MA->MaContacto with cMaContacto
      replace MA->MaPais     with cMaPais
      replace MA->MaEmail    with cMaemail
      replace MA->MaUrl      with cMaurl
      replace MA->Manotas    with cManotas
      MA->(dbCommit())
      if cMarca != NIL
         cMarca := MA->MaNombre
      endif
   else
      lReturn := .F.
      if nMode == 1 .OR. nMode == 3
         MA->(dbGoto(nRecAdd))
         MA->(dbDelete())
         MA->(DbPack())
         MA->(dbGoto(nRecPtr))
      endif
   endif

   select MA
   if oCont != NIL
      RefreshCont(oCont,"MA")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function MaBorra(oGrid,oCont)

   local nRecord := MA->(RecNo())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta marca ?") + CRLF + ;
         (Trim(MA->MaNombre)))
      msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         {|| MaCambiaClave( Space(40), MA->MaNombre ) } )

      select MA
      MA->(dbSkip())
      nNext := MA->(RecNo())
      MA->(dbGoto(nRecord))
      MA->(dbDelete())
      MA->(DbPack())
      MA->(dbGoto(nNext))
      if MA->(Eof()) .OR. nNext == nRecord
         MA->(dbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"MA")
   endif

   oApp():nEdit --
   oGrid:Refresh(.T.)
   oGrid:SetFocus(.T.)

return nil
/*_____________________________________________________________________________*/

function MaTecla(nKey,oGrid,oCont,oDlg)

   do case
   case nKey==VK_RETURN
      MaEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      MaEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      MaBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   otherwise
      if nKey >= 96 .AND. nKey <= 105
         MaBusca(oGrid,Str(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(Chr(nKey))
         MaBusca(oGrid,Chr(nKey),oCont,oDlg)
      endif
   endcase

return nil
/*_____________________________________________________________________________*/

function MaSeleccion( cCliente, oControl, oParent )

   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .F.
   local nRecno := MA->( RecNo() )
   local nOrder := MA->( ordNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""

   oApp():nEdit ++
   MA->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "MaAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de marcas" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "MA"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| MA->MaNombre }
   oCol:cHeader  := i18n( "Marca" )
   oCol:nWidth   := 250

   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .F.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := {|nKey| MaTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { CLR_BLACK, CLR_WHITE } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION MaEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION MaEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION MaBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION MaBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .T., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .F., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      on PAINT oDlg:Move(aPoint[1], aPoint[2],,,.T.)

   if lOK
      oControl:cText := MA->MaNombre
   endif
   SetIni( , "Browse", "MaAux", oBrowse:SaveState() )
   MA->( dbSetOrder( nOrder ) )
   MA->( dbGoto( nRecno ) )
   oApp():nEdit --
   select (nArea)

return nil
/*_____________________________________________________________________________*/

function MaBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := MA->(ordNumber())
   local nRecno   := MA->(RecNo())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .F.
   local lFecha   := .F.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de marcas")
   oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE say prompt i18n( "Introduzca la marca" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Marca" )+":" ID 21 OF Odlg
      cGet     := Space(40)
   elseif nOrder == 2
      REDEFINE say prompt i18n( "Introduzca el CIF/NIF" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "CIF/NIF" )+":" ID 21 OF Odlg
      cGet     := Space(15)
   elseif nOrder == 3
      REDEFINE say prompt i18n( "Introduzca el contacto" ) ID 20 OF oDlg
      REDEFINE say prompt i18n( "Contacto" )+":" ID 21 OF Odlg
      cGet     := Space(40)
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
         {|| MaWildSeek(nOrder, RTrim(Upper(cGet)), aBrowse ) } )
      if Len(aBrowse) == 0
         MsgStop("No se ha encontrado ninguna marca. Revise la ordenación.")
      else
         MaEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   MA->(ordSetFocus(nOrder))

   RefreshCont( oCont, "MA" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return nil
/*_____________________________________________________________________________*/
function MaWildSeek(nOrder, cGet, aBrowse)

   local nRecno   := MA->(RecNo())
   do case
   case nOrder == 1
      MA->(dbGoTop())
      do while ! MA->(Eof())
         if cGet $ Upper(MA->MaNombre)
            AAdd(aBrowse, {MA->MaNombre, MA->MaCIF, MA->MaContacto })
         endif
         MA->(dbSkip())
      enddo
   case nOrder == 2
      MA->(dbGoTop())
      do while ! MA->(Eof())
         if cGet $ Upper(MA->MaCIF)
            AAdd(aBrowse, {MA->MaNombre, MA->MaCIF, MA->MaContacto })
         endif
         MA->(dbSkip())
      enddo
   case nOrder == 3
      MA->(dbGoTop())
      do while ! MA->(Eof())
         if cGet $ Upper(MA->MaContacto)
            AAdd(aBrowse, {MA->MaNombre, MA->MaCIF, MA->MaContacto })
         endif
         MA->(dbSkip())
      enddo
   end case
   MA->(dbGoto(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper(aAut1[1]) < Upper(aAut2[1]) } )

return nil
/*_____________________________________________________________________________*/

function MaEncontrados(aBrowse, oParent)

   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := MA->(RecNo())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .F.)
   oBrowse:aCols[1]:cHeader := "Marca"
   oBrowse:aCols[2]:cHeader := "CIF / NIF"
   oBrowse:aCols[3]:cHeader := "Contacto"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   oBrowse:aCols[3]:nWidth  := 140
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   MA->(ordSetFocus(1))
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {||MA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      MaEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| iif(nKey==VK_RETURN,(MA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      MaEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := {|| MA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (MA->(dbGoto(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      on init DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function MaClave( cMarca, oGet, nMode, nTag )

   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .F.
   local nRecno   := MA->( RecNo() )
   local nOrder   := MA->( ordNumber() )
   local nArea    := Select()

   if Empty( cMarca )
      if nMode == 4 .OR. nTag == 2
         return .T.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         return .F.
      endif
   endif

   select MA
   MA->( dbSetOrder( nTag ) )
   MA->( dbGoTop() )

   if MA->( dbSeek( Upper( cMarca ) ) )
      do case
      case nMode == 1 .OR. nMode == 3
         lReturn := .F.
         MsgStop("Marcar existente.")
      case nMode == 2
         if MA->( RecNo() ) == nRecno
            lReturn := .T.
         else
            lReturn := .F.
            MsgStop("Marca existente.")
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
      else
         if MsgYesNo("Marca inexistente. ¿ Desea darla de alta ahora? ")
            lReturn := MaEdita( , 1, , , @cMarca )
         else
            lReturn := .F.
         endif
      endif
   endif

   if lReturn == .F.
      iif(nTag==1,oGet:cText(Space(40)),oGet:cText(Space(15)))
   else
      oGet:cText( cMarca )
   endif

   MA->( dbSetOrder( nOrder ) )
   MA->( dbGoto( nRecno ) )

   select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function MaCambiaClave( cNew, cOld )

   local nAuxOrder
   local nAuxRecNo

   cOld := Upper(RTrim(cOld))
   // cambio la tienda en el inventario
   select BI
   nAuxRecno := BI->(RecNo())
   nAuxOrder := BI->(ordNumber())
   BI->(dbSetOrder(0))
   BI->(dbGoTop())
   replace BI->BiMarca   ;
      with cNew            ;
      for Upper(RTrim(BI->BiMarca)) == Upper(RTrim(cOld))
   BI->(dbSetOrder( nAuxOrder ))
   BI->(dbGoto( nAuxRecno ))
   select MA

return nil

//_____________________________________________________________________________//

function MaInventario( oGrid, oParent )

	local cMarca := MA->MaNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

   select BI
   BI->(dbGoTop())
   do while ! BI->(Eof())
      if Upper(BI->BiMarca) == Upper(cMarca)
         AAdd(aBrowse, { BI->BiDenomi, BI->BiModelo, BI->BiCategor, tran(BI->BiPrecio,"@E 999,999.99"), BI->(RecNo()) })
      endif
      BI->(dbSkip())
   enddo
   if Len(aBrowse) == 0
      MsgStop("La marca no aparece en el inventario.")
      retu nil
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Inventario de la marca: '+RTrim(cMarca) OF oParent
   oDlg:SetFont(oApp():oFont)

   ASort( aBrowse,,, {|aApu1, aApu2| aApu1[1] < aApu2[1] } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .F.)
   oBrowse:aCols[1]:cHeader  := "Identificador"
   oBrowse:aCols[1]:nWidth   := 170
   oBrowse:aCols[2]:cHeader  := "Modelo"
   oBrowse:aCols[2]:nWidth   := 160
   oBrowse:aCols[3]:cHeader  := "Categoria"
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

   select MA
   oGrid:Refresh()
   oGrid:SetFocus(.T.)
   oApp():nEdit --

return nil

/*_____________________________________________________________________________*/

function MaImprime(oGrid,oParent)
   local nRecno   := MA->(Recno())
   LOCAl nOrder   := MA->(OrdSetFocus())
   local aCampos  := { "MANOMBRE", "MAINVEN", "MACIF", "MACONTACTO", "MADIRECC", ;
							  "MATELEFONO", "MAlocalI", "MAPAIS", "MAEMAIL", "MAURL" }
   local aTitulos := { "Marca", "Inventario", "Cif / NIF", "Contacto", "Dirección",;
 							  "Teléfono", "Localidad", "Pais", "e-mail", "Sitio web " }
   local aWidth   := { 40, 15, 15, 40, 40, 40, 20, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","999","NO","NO","NO","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .f., .f., .f., .f., .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "MA" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio var oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      MA->(dbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say(1, 'Total marcas: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            oInforme:oReport:EndLine() )
         oInforme:End(.T.)
      endif
   endif
   MA->(dbGoto(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

return nil
//_____________________________________________________________________________//

function MaList( aList, cData, oSelf )
   local aNewList := {}
   MA->( dbSetOrder(1) )
   MA->( dbGoTop() )
   while ! MA->(Eof())
      if at(Upper(cdata), Upper(MA->MaNombre)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { MA->MaNombre } )
      endif 
      MA->(DbSkip())
   enddo
return aNewlist
