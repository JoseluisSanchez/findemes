#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

STATIC oReport

function Clientes()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "ClState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "ClOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "ClRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "ClSplit","102", oApp():cIniFile))
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

   if ! Db_OpenAll()
      retu NIL
   endif

   SELECT Cl
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de pagadores')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "CL"

   // ojo falta la categoría
   aBrowse   := { { { || Cl->ClNombre }, i18n("Pagador"), 150, 0 },;
                  { { || Cl->ClCif }, i18n("CIF / NIF"), 120, 0 },;
                  { { || Cl->ClContacto }, i18n("Contacto"), 120, 0 },;
                  { { || Cl->ClCategor }, i18n("Cat. Ingreso"), 120, 0 },;
                  { { || Cl->ClDirecc }, i18n("Dirección"), 120, 0 },;
                  { { || Cl->ClLocali }, i18n("Localidad"), 120, 0 },;
                  { { || Cl->ClTelefono }, i18n("Telefono"), 120, 0 },;
                  { { || Cl->ClMovil }, i18n("T. Móvil"), 120, 0 },;
                  { { || Cl->ClFax   }, i18n("Fax"), 120, 0 },;
                  { { || Cl->ClPais }, i18n("Pais"), 120, 0 },;
                  { { || Cl->ClEmail }, i18n("E-mail"), 150, 0 },;
                  { { || Cl->ClURL }, i18n("Sitio web"), 150, 0 } }


   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT

   ADD oCol TO oApp():oGrid DATA CL->ClApuntes ;
      HEADER "Apuntes" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA CL->ClApSuma ;
      HEADER "Suma Apu." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA CL->ClPresupu ;
      HEADER "Presupuestos" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA CL->ClPuSuma ;
      HEADER "Suma Pre." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| ClEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"CL") }
   oApp():oGrid:bKeyDown := {|nKey| ClTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
   oApp():oGrid:bClrRowFocus := { || { oApp():cClrIng, oApp():nClrHL } }	 
	oApp():oGrid:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:MakeTotals()
   oApp():oGrid:bClrFooter := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }

   oApp():oGrid:RestoreState( cState )

   CL->(DbSetOrder(nOrder))
   CL->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(CL->(OrdKeyNo()),'@E 999,999')+" / "+tran(CL->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_CLIENTE" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 195 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  pagadores / clientes " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar  	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION ClEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION ClEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_duplica"           ;
      ACTION ClEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION ClBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION ClBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION ClImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver apuntes"     ;
      IMAGE "16_apuntes"        ;
      ACTION ClApuntes( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver presupuestos"   ;
      IMAGE "16_presupu"           ;
      ACTION ClPresupuestos( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_internet"          ;
      ACTION GoWeb(Cl->ClUrl)      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_email"             ;
      ACTION GoMail(Cl->ClEmail)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Pagadores / Clientes" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PrState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Pagador ', ' Cif / Nif ', ' Contacto ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              CL->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"CL") )

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
              WritePProString("Browse","ClState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","ClOrder",Ltrim(Str(CL->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","ClRecno",Ltrim(Str(CL->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","ClSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return Nil
/*_____________________________________________________________________________*/

function ClEdita(oGrid,nMode,oCont,oParent,cCliente)
   local oDlg
   local aTitle := { i18n( "Añadir un pagador" )   ,;
                     i18n( "Modificar un pagador") ,;
                     i18n( "Duplicar un pagador") }
   local aGet[14]
   local cClNombre   ,;
         cClCif      ,;
         cClCategor  ,;
         cClNotas    ,;
         cClDirecc   ,;
         cClLocali   ,;
         cClPais     ,;
         cClTelefono ,;
         cClMovil    ,;
         cClFax      ,;
         cClContacto ,;
         cClEmail    ,;
         cClUrl

   local nRecPtr  := CL->(RecNo())
   local nOrden   := CL->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if CL->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      CL->(DbAppend())
      nRecAdd := CL->(RecNo())
   endif

   cClNombre   := IIF(nMode==1.AND.cCliente!=NIL,cCliente,CL->ClNombre)
   cClCif      := CL->ClCif
   cCldirecc   := CL->ClDirecc
   cClLocali   := CL->ClLocali
   cCltelefono := CL->Cltelefono
   cClMovil    := CL->ClMovil
   cClFax      := CL->ClFax
   cClContacto := CL->ClContacto
   cClPais     := CL->ClPais
   cClemail    := CL->ClEmail
   cClurl      := CL->ClUrl
   cClnotas    := CL->Clnotas

   if nMode == 3
      CL->(DbAppend())
      nRecAdd := CL->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "CLEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cClNombre  ;
      ID 101 OF oDlg UPDATE            ;
      VALID ClClave( cClNombre, aGet[1], nMode, 1 );
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[2] VAR cClCif     ;
      ID 102 OF oDlg UPDATE            ;
      VALID ClClave( cClCIF, aGet[2], nMode, 2 );
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[3] VAR cClContacto;
      ID 103 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[4] VAR cClDirecc  ;
      ID 104 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[5] VAR cClLocali  ;
      ID 105 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[6] VAR cClpais    ;
      ID 106 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[7] VAR cClTelefono;
      ID 107 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[8] VAR cClMovil   ;
      ID 108 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[9] VAR cClFax     ;
      ID 109 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE GET aGet[10] VAR cClEmail  ;
      ID 110 OF oDlg UPDATE            ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[11]         ;
      ID 111 OF oDlg                ;
      ACTION GoMail( cClEmail )
   aGet[11]:cTooltip := "enviar e-mail"

   REDEFINE GET aGet[12] VAR cClURL ;
      ID 112 OF oDlg UPDATE         ;
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE BUTTON aGet[13]         ;
      ID 113 OF oDlg                ;
      ACTION GoWeb( cClURL )
   aGet[13]:ctooltip := "visitar sitio web"

   REDEFINE GET aGet[14] VAR cClNotas  ;
      MULTILINE ID 114 OF oDlg UPDATE  ;
      COLOR oApp():cClrIng, CLR_WHITE

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
         CL->(DbGoTo(nRecPtr))
      else
         CL->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el nombre del proveedor en los apuntes__________________//
      if nMode == 2
         if cClNombre != CL->ClNombre
            msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               { || ClCambiaClave( cClNombre, CL->ClNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      Replace CL->Clnombre   with cClnombre
      Replace CL->ClCif      with cClCIF
      Replace CL->ClDirecc   with cCldirecc
      Replace CL->ClLocali   with cClLocali
      Replace CL->Cltelefono with cCltelefono
      Replace CL->ClMovil    with cClMovil
      Replace CL->ClFax      with cClFax
      Replace CL->ClContacto with cClContacto
      Replace CL->ClPais     with cClPais
      Replace CL->ClEmail    with cClemail
      Replace CL->ClUrl      with cClurl
      Replace CL->Clnotas    with cClnotas
      CL->(DbCommit())
      if cCliente != NIL
         cCliente := CL->ClNombre
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         CL->(DbGoTo(nRecAdd))
         CL->(DbDelete())
         CL->(DbPack())
         CL->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT CL
   if oCont != NIL
      RefreshCont(oCont,"CL")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function ClBorra(oGrid,oCont)
   local nRecord := CL->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este pagador ?") + CRLF + ;
                (trim(CL->ClNombre)))
      msgRun( i18n( "Revisando el fichero de pagadores. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || ClCambiaClave( space(40), CL->ClNombre ) } )

      SELECT CL
      CL->(DbSkip())
      nNext := CL->(Recno())
      CL->(DbGoto(nRecord))
      CL->(DbDelete())
      CL->(DbPack())
      CL->(DbGoto(nNext))
      if CL->(EOF()) .or. nNext == nRecord
         CL->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"CL")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
/*_____________________________________________________________________________*/

function ClTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      ClEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      ClEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      ClBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         ClBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         ClBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase
return nil
/*_____________________________________________________________________________*/

function ClSeleccion( cCliente, oControl, oParent, oVItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := CL->( RecNo() )
   local nOrder := CL->( OrdNumber() )
   local nArea  := Select()
   local aPoint := iif(oControl!=NIL,AdjustWnd( oControl, 271*2, 150*2 ),{1.3*oVItem:nTop(),oApp():oGrid:nLeft})
   local cBrwState  := ""

   oApp():nEdit ++
   CL->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "ClAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de pagadores" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "CL"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || CL->ClNombre }
   oCol:cHeader  := i18n( "Pagador" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| ClTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
   oBrowse:bClrRowFocus := { || { oApp():cClrIng, oApp():nClrHL } }	 
	oBrowse:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION ClEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION ClEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION ClBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION ClBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      cCliente := CL->ClNombre
      if oControl != NIL
         oControl:cText := CL->ClNombre
      endif
   endif

   SetIni( , "Browse", "ClAux", oBrowse:SaveState() )
   CL->( DbSetOrder( nOrder ) )
   CL->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return NIL
/*_____________________________________________________________________________*/

function ClBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := CL->(OrdNumber())
   local nRecno   := CL->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de pagadores")
   oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el pagador" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Pagador" )+":" ID 21 OF Odlg
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
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg COLOR oApp():cClrIng, CLR_WHITE
   else
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg COLOR oApp():cClrIng, CLR_WHITE
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
         { || ClWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún pagador")
      else
         ClEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   CL->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "CL" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function ClWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := CL->(Recno())

   do case
      case nOrder == 1
         CL->(DbGoTop())
         do while ! CL->(eof())
            if cGet $ upper(CL->ClNombre)
               aadd(aBrowse, {CL->ClNombre, CL->ClCIF, CL->ClContacto })
            endif
            CL->(DbSkip())
         enddo
      case nOrder == 2
         CL->(DbGoTop())
         do while ! CL->(eof())
            if cGet $ upper(CL->ClCIF)
               aadd(aBrowse, {CL->ClNombre, CL->ClCIF, CL->ClContacto })
            endif
            CL->(DbSkip())
         enddo
      case nOrder == 3
         CL->(DbGoTop())
         do while ! CL->(eof())
            if cGet $ upper(CL->ClContacto)
               aadd(aBrowse, {CL->ClNombre, CL->ClCIF, CL->ClContacto })
            endif
            CL->(DbSkip())
         enddo
   end case
   CL->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/

function ClEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := CL->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Pagador"
   oBrowse:aCols[2]:cHeader := "CIF / NIF"
   oBrowse:aCols[3]:cHeader := "Contacto"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   oBrowse:aCols[3]:nWidth  := 140
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   CL->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||CL->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           ClEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(CL->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     ClEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || CL->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (CL->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function ClClave( cCliente, oGet, nMode, nTag )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := CL->( RecNo() )
   local nOrder   := CL->( OrdNumber() )
   local nArea    := Select()

   if Empty( cCliente )
      if nMode == 4 .OR. nTag == 2
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT CL
   CL->( DbSetOrder( nTag ) )
   CL->( DbGoTop() )

   if CL->( DbSeek( UPPER( cCliente ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Pagador existente.")
         Case nMode == 2
            if CL->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Pagador existente.")
            endif
         Case nMode == 4
            lReturn := .t.
            IF ! oApp():thefull
               Registrame()
            ENDIF
      END CASE
   else
      if nMode < 4
         lReturn := .t.
      else
         if MsgYesNo("Pagador inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := ClEdita( , 1, , , @cCliente )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      iif(nTag==1,oGet:cText(space(40)),oGet:cText(space(15)))
   else
      oGet:cText( cCliente )
   endif

   CL->( DbSetOrder( nOrder ) )
   CL->( DbGoTo( nRecno ) )

   Select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function ClCambiaClave( cNew, cOld )
   local nAuxOrder
   local nAuxRecNo
   cOld := upper(rtrim(cOld))
	// cambio el cliente en los apuntes
   Select AP
   nAuxRecno := AP->(RecNo())
   nAuxOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApCliente   ;
      with cNew            ;
      for Upper(Rtrim(AP->ApCliente)) == Upper(rtrim(cOld))
   AP->(DbSetOrder( nAuxOrder ))
   AP->(DbGoTo( nAuxRecno ))
	// cambio el cliente en los presupuestos
   Select PU
   nAuxRecno := PU->(RecNo())
   nAuxOrder := PU->(OrdNumber())
   PU->(DbSetOrder(0))
   PU->(DbGoTop())
   Replace PU->PuCliente   ;
      with cNew            ;
      for Upper(Rtrim(PU->PuCliente)) == Upper(rtrim(cOld))
   PU->(DbSetOrder( nAuxOrder ))
   PU->(DbGoTo( nAuxRecno ))
   SELECT CL
return NIL

//_____________________________________________________________________________//

function ClApuntes( oGrid, oParent )
   local cClNombre := CL->ClNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT AP
	AP->(DbSetOrder(6))
	AP->(DbGoTop())
   if ! AP->(DbSeek(upper(cClNombre)))
      MsgStop("El pagador no aparece en ningún apunte.")
      RETURN NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Apuntes del pagador: '+rtrim(cClNombre) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApCliente) == upper(cClNombre)
         aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApConcepto, AP->ApImpTotal, AP->(Recno()) })
      endif
      AP->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:bClrRowFocus := { || { oApp():cClrIng, oApp():nClrHL } }	 
	oBrowse:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }
   oBrowse:aCols[1]:cHeader  := "Fecha"
   oBrowse:aCols[1]:nWidth   := 70
   oBrowse:aCols[2]:cHeader  := "Actividad"
   oBrowse:aCols[2]:nWidth   := 160
   oBrowse:aCols[3]:cHeader  := "Concepto"
   oBrowse:aCols[3]:nWidth   := 220
   oBrowse:aCols[4]:cHeader  := "Importe total"
   oBrowse:aCols[4]:nWidth   := 80
   oBrowse:aCols[ 4 ]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[ 4 ]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[ 4 ]:cEditPicture  := "@E 999,999.99"
   oBrowse:aCols[ 4 ]:bClrFooter    := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
   oBrowse:aCols[ 4 ]:lTotal   := .t.
   oBrowse:aCols[ 4 ]:nTotal   := 0
   oBrowse:aCols[ 5 ]:lHide    := .T.

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || (AP->(DbGoTo(aBrowse[oBrowse:nArrayAt,5])),;
                                                             ApIEdita1(,2,,oDlg,.f.)) } } )

   oBrowse:lHScroll := .F.
   oBrowse:lFooter  := .T.
   oBrowse:Maketotals()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   SELECT CL
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
RETURN NIL

//_____________________________________________________________________________//

function ClPresupuestos( oGrid, oParent )
   local cClNombre := CL->ClNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT PU
	PU->(DbSetOrder(5))
	PU->(DbGoTop())
   if ! PU->(DbSeek(upper(cClNombre)))
      MsgStop("El pagador no aparece en ningún presupuesto.")
      retu NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Presupuestos del pagador: '+rtrim(cClNombre) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! PU->(EOF())
      if upper(PU->PuCliente) == upper(cClNombre)
         aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuConcepto, PU->PuImpTotal, PU->(Recno()) })
      endif
      PU->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:bClrRowFocus := { || { oApp():cClrIng, oApp():nClrHL } }	 
	oBrowse:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }
   oBrowse:aCols[1]:cHeader  := "Fecha"
   oBrowse:aCols[1]:nWidth   := 70
   oBrowse:aCols[2]:cHeader  := "Actividad"
   oBrowse:aCols[2]:nWidth   := 160
   oBrowse:aCols[3]:cHeader  := "Concepto"
   oBrowse:aCols[3]:nWidth   := 220
   oBrowse:aCols[4]:cHeader  := "Importe total"
   oBrowse:aCols[4]:nWidth   := 80
   oBrowse:aCols[4]:nDataStrAlign := AL_RIGHT
   oBrowse:aCols[4]:nHeadStrAlign := AL_RIGHT
   oBrowse:aCols[4]:cEditPicture  := "@E 999,999.99"
   oBrowse:aCols[4]:bClrFooter    := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
   oBrowse:aCols[4]:lTotal   := .t.
   oBrowse:aCols[4]:nTotal   := 0
   oBrowse:aCols[5]:lHide    := .T.

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || (PU->(DbGoTo(aBrowse[oBrowse:nArrayAt,5])),;
                                                             PuIEdita1(,2,,oDlg,.f.)) } } )

   oBrowse:lHScroll := .F.
   oBrowse:lFooter  := .T.
   oBrowse:Maketotals()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   SELECT CL
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
RETURN NIL
/*_____________________________________________________________________________*/

function ClImprime(oGrid,oParent)
   local nRecno   := CL->(Recno())
   LOCAl nOrder   := CL->(OrdSetFocus())
   local aCampos  := { "CLNOMBRE", "CLCIF", "CLCONTACTO", "CLDIRECC", "CLTELEFONO",;
                       "CLMOVIL", "CLFAX", "CLlocalI", "CLPAIS", "CLEMAIL", "CLURL" }
   local aTitulos := { "Pagador", "Cif / NIF", "Contacto", "Dirección", "Teléfono",;
                       "Movil", "Fax", "Localidad", "Pais", "e-mail", "Sitio web " }
   local aWidth   := { 40, 15, 40, 40, 15, 15, 15, 40, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .f., .f., .f., .f., .f., .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "CL" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      CL->(DbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                     oInforme:oReport:Say(1, 'Total pagadores: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                     oInforme:oReport:EndLine() )
         oInforme:End(.t.)
      endif
   endif
   CL->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
RETURN NIL
//_____________________________________________________________________________//

function ClList( aList, cData, oSelf )
   local aNewList := {}
   CL->( dbSetOrder(1) )
   CL->( dbGoTop() )
   while ! CL->(Eof())
      if at(Upper(cdata), Upper(CL->ClNombre)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { CL->ClNombre } )
      endif 
      CL->(DbSkip())
   enddo
return aNewlist
// _____________________________________________________________________________//

FUNCTION Cl1Mas( cCliente, cTipo, nImporte )

   LOCAL nClRecno := Cl->( RecNo() )
   LOCAL nClOrder := Cl->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT CL
   CL->( ordSetFocus( 1 ) )
   CL->( dbGoTop() )
   IF CL->( dbSeek( Upper( cCliente ) ) )
      IF cTipo == 'A'
         REPLACE CL->ClApuntes WITH CL->ClApuntes + 1
         REPLACE CL->ClApSuma WITH CL->ClApSuma + nImporte 
      ELSEIF cTipo == 'P'
         REPLACE CL->ClPresupu WITH CL->ClPresupu + 1
         REPLACE CL->ClPrSuma WITH CL->ClPrSuma + nImporte 
      ENDIF
   ELSEIF ! Empty(cCliente)
      MsgAlert( 'Pagador no encontrado.' )
   ENDIF
   CL->( dbCommit() )
   CL->( ordSetFocus( nClOrder ) )
   CL->( dbGoto( nClRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION Cl1Menos( cCliente, cTipo, nImporte )

   LOCAL nClRecno := Cl->( RecNo() )
   LOCAL nClOrder := Cl->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT CL
   CL->( ordSetFocus( 1 ) )
   CL->( dbGoTop() )
   IF CL->( dbSeek( Upper( cCliente ) ) )
      IF cTipo == 'A'
         REPLACE CL->ClApuntes WITH CL->ClApuntes - 1
         REPLACE CL->ClApSuma WITH CL->ClApSuma - nImporte 
      ELSEIF cTipo == 'P'
         REPLACE CL->ClPresupu WITH CL->ClPresupu - 1
         REPLACE CL->ClPrSuma WITH CL->ClPrSuma - nImporte
      ENDIF
   ELSEIF ! Empty(cCliente)
      MsgAlert( 'Pagador no encontrado.' )
   ENDIF
   CL->( dbCommit() )
   CL->( ordSetFocus( nClOrder ) )
   CL->( dbGoto( nClRecno ) )
   SELECT ( cAlias )
   RETURN NIL
// _____________________________________________________________________________//
