#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

STATIC oReport

function Proveedores()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "PrState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "PrOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "PrRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "PrSplit","102", oApp():cIniFile))
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

   if ! Db_OpenAll()
      retu NIL
   endif

   Select PR
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de perceptores')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "PR"

   // ojo falta la categoría
   aBrowse   := { { { || PR->PrNombre }, i18n("Perceptor"), 150, 0 },;
                  { { || PR->PrCif }, i18n("CIF / NIF"), 120, 0 },;
                  { { || PR->PrContacto }, i18n("Contacto"), 120, 0 },;
                  { { || PR->PrCategor }, i18n("Cat. Gasto"), 120, 0 },;
                  { { || PR->PrDirecc }, i18n("Dirección"), 120, 0 },;
                  { { || PR->PrLocali }, i18n("Localidad"), 120, 0 },;
                  { { || PR->PrTelefono }, i18n("Telefono"), 120, 0 },;
                  { { || PR->PrMovil }, i18n("T. Móvil"), 120, 0 },;
                  { { || PR->PrFax   }, i18n("Fax"), 120, 0 },;
                  { { || PR->PrPais }, i18n("Pais"), 120, 0 },;
                  { { || PR->PrEmail }, i18n("E-mail"), 150, 0 },;
                  { { || PR->PrURL }, i18n("Sitio web"), 150, 0 } }


   FOR i := 1 TO Len(aBrowse)
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT

   ADD oCol TO oApp():oGrid DATA PR->PrApuntes ;
      HEADER "Apuntes" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA PR->PrApSuma ;
      HEADER "Suma Apu." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA PR->PrPresupu ;
      HEADER "Presupuestos" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA PR->PrPuSuma ;
      HEADER "Suma Pre." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| PrEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "PR" ) }
   oApp():oGrid:bKeyDown := {| nKey| PrTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }
   oApp():oGrid:bClrRowFocus := {|| { oApp():cClrGas, oApp():nClrHL } }
   oApp():oGrid:bClrSelFocus := {|| { oApp():cClrGas, oApp():nClrHL } }
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:MakeTotals()
   oApp():oGrid:bClrFooter := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
   oApp():oGrid:RestoreState( cState )

   PR->(DbSetOrder(nOrder))
   PR->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(PR->(OrdKeyNo()),'@E 999,999')+" / "+tran(PR->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_PROVEED" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 245 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  perceptores / proveedores" ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION PrEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION PrEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_duplica"           ;
      ACTION PrEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION PrBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION PrBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION PrImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver apuntes"     ;
      IMAGE "16_apuntes"        ;
      ACTION PrApuntes( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

	DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver prespuestos"    ;
      IMAGE "16_presupu"           ;
      ACTION PrPresupuestos( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_internet"          ;
      ACTION GoWeb(PR->PrUrl)      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_email"             ;
      ACTION GoMail(PR->PrEmail)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Perceptores / Proveedores" ), CursorArrow());
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
     ITEMS ' Perceptor ', ' Cif / Nif ', ' Contacto ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              PR->(DbSetOrder(nOrder)),;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont,"PR") )

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
              WritePProString("Browse","PrState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","PrOrder",Ltrim(Str(PR->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","PrRecno",Ltrim(Str(PR->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","PrSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .t. )

return Nil
/*_____________________________________________________________________________*/

function PrEdita(oGrid,nMode,oCont,oParent,cProveed)
   local oDlg
   local aTitle := { i18n( "Añadir un perceptor" )   ,;
                     i18n( "Modificar un perceptor") ,;
                     i18n( "Duplicar un perceptor") }
   local aGet[14]
   local cPrNombre   ,;
         cPrCif      ,;
         cPrCategor  ,;
         cPrNotas    ,;
         cPrDirecc   ,;
         cPrLocali   ,;
         cPrPais     ,;
         cPrTelefono ,;
         cPrMovil    ,;
         cPrFax      ,;
         cPrContacto ,;
         cPrEmail    ,;
         cPrUrl

   local nRecPtr  := PR->(RecNo())
   local nOrden   := PR->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if PR->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif
   oApp():nEdit ++

   if nMode == 1
      PR->(DbAppend())
      nRecAdd := PR->(RecNo())
   endif


   cPrNombre   := IIF(nMode==1.AND.cProveed!=NIL,cProveed,PR->PrNombre)
   cPrCif      := PR->PrCif
   cPrdirecc   := PR->PrDirecc
   cPrLocali   := PR->PrLocali
   cPrtelefono := PR->Prtelefono
   cPrMovil    := PR->PrMovil
   cPrFax      := PR->PrFax
   cPrContacto := PR->PrContacto
   cPrPais     := PR->PrPais
   cPremail    := PR->PrEmail
   cPrurl      := PR->PrUrl
   cPrnotas    := PR->Prnotas

   if nMode == 3
      PR->(DbAppend())
      nRecAdd := PR->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "PREDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cPrNombre  ;
      ID 101 OF oDlg UPDATE            ;
      VALID PrClave( cPrNombre, aGet[1], nMode, 1 );
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[2] VAR cPrCif     ;
      ID 102 OF oDlg UPDATE            ;
      VALID PrClave( cPrCIF, aGet[2], nMode, 2 )   ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[3] VAR cPrContacto;
      ID 103 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[4] VAR cPrDirecc  ;
      ID 104 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[5] VAR cPrLocali  ;
      ID 105 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[6] VAR cPrpais    ;
      ID 106 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[7] VAR cPrTelefono;
      ID 107 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[8] VAR cPrMovil   ;
      ID 108 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[9] VAR cPrFax     ;
      ID 109 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE GET aGet[10] VAR cPrEmail  ;
      ID 110 OF oDlg UPDATE            ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[11]            ;
      ID 111 OF oDlg                   ;
      ACTION GoMail( cPrEmail )
   aGet[11]:cTooltip := "enviar e-mail"

   REDEFINE GET aGet[12] VAR cPrURL ;
      ID 112 OF oDlg UPDATE         ;
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE BUTTON aGet[13]         ;
      ID 113 OF oDlg                ;
      ACTION GoWeb( cPrURL )
   aGet[13]:ctooltip := "visitar sitio web"

   REDEFINE GET aGet[14] VAR cPrNotas  ;
      MULTILINE ID 114 OF oDlg UPDATE  ;
      COLOR oApp():cClrGas, CLR_WHITE

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
         PR->(DbGoTo(nRecPtr))
      else
         PR->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el nombre del perceptor en los apuntes__________________//
      if nMode == 2
         if cPrNombre != PR->PrNombre
            msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               { || PrCambiaClave( cPrNombre, PR->PrNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      Replace PR->Prnombre   with cPrnombre
      Replace PR->PrCif      with cPrCIF
      Replace PR->PrDirecc   with cPrdirecc
      Replace PR->PrLocali   with cPrLocali
      Replace PR->Prtelefono with cPrtelefono
      Replace PR->PrMovil    with cPrMovil
      Replace PR->PrFax      with cPrFax
      Replace PR->PrContacto with cPrContacto
      Replace PR->PrPais     with cPrPais
      Replace PR->PrEmail    with cPremail
      Replace PR->PrUrl      with cPrurl
      Replace PR->Prnotas    with cPrnotas

      PR->(DbCommit())
      if cProveed != NIL
         cProveed := PR->PrNombre
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         PR->(DbGoTo(nRecAdd))
         PR->(DbDelete())
         PR->(DbPack())
         PR->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT PR
   if oCont != NIL
      RefreshCont(oCont,"PR")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function PrBorra(oGrid,oCont)
   local nRecord := PR->(Recno())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este perceptor ?") + CRLF + ;
                (trim(PR->PrNombre)))
      msgRun( i18n( "Revisando el fichero de perceptores. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || PrCambiaClave( space(40), PR->PrNombre ) } )

      SELECT PR
      PR->(DbSkip())
      nNext := PR->(Recno())
      PR->(DbGoto(nRecord))

      PR->(DbDelete())
      PR->(DbPack())
      PR->(DbGoto(nNext))
      if PR->(EOF()) .or. nNext == nRecord
         PR->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"PR")
   endif

   oApp():nEdit --
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)

return nil
/*_____________________________________________________________________________*/

function PrTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      PrEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      PrEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      PrBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         PrBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         PrBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase

return nil
/*_____________________________________________________________________________*/

function PrSeleccion( cProveed, oControl, oParent, oVItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := PR->( RecNo() )
   local nOrder := PR->( OrdNumber() )
   local nArea  := Select()
   local aPoint := iif(oControl!=NIL,AdjustWnd( oControl, 271*2, 150*2 ),{1.3*oVItem:nTop(),oApp():oGrid:nLeft})
   local cBrwState  := ""

   oApp():nEdit ++
   PR->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "PrAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de perceptores" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "PR"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || PR->PrNombre }
   oCol:cHeader  := i18n( "Perceptor" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| PrTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }
   oBrowse:bClrRowFocus := { || { oApp():cClrGas, oApp():nClrHL } }	 
   oBrowse:bClrSelFocus := { || { oApp():cClrGas, oApp():nClrHL } }


   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION PrEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION PrEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION PrBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION PrBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      cProveed := PR->PrNombre
      if oControl != NIL
         oControl:cText := PR->PrNombre
      endif
   endif

   SetIni( , "Browse", "PrAux", oBrowse:SaveState() )
   PR->( DbSetOrder( nOrder ) )
   PR->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return NIL
/*_____________________________________________________________________________*/

function PrBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := PR->(OrdNumber())
   local nRecno   := PR->(Recno())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de perceptores")
   oDlg:SetFont(oApp():oFont)

   if nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el perceptor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Perceptor" )+":" ID 21 OF Odlg
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
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg COLOR oApp():cClrGas, CLR_WHITE
   else
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg COLOR oApp():cClrGas, CLR_WHITE
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
         { || PrWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún perceptor")
      else
         PrEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   PR->(OrdSetFocus(nOrder))

	if oCont != NIL
		RefreshCont( oCont, "PR" )
	endif
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function PrWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := PR->(Recno())

   do case
      case nOrder == 1
         PR->(DbGoTop())
         do while ! PR->(eof())
            if cGet $ upper(PR->PrNombre)
               aadd(aBrowse, {PR->PrNombre, PR->PrCIF, PR->PrContacto })
            endif
            PR->(DbSkip())
         enddo
      case nOrder == 2
         PR->(DbGoTop())
         do while ! PR->(eof())
            if cGet $ upper(PR->PrCIF)
               aadd(aBrowse, {PR->PrNombre, PR->PrCIF, PR->PrContacto })
            endif
            PR->(DbSkip())
         enddo
      case nOrder == 3
         PR->(DbGoTop())
         do while ! PR->(eof())
            if cGet $ upper(PR->PrContacto)
               aadd(aBrowse, {PR->PrNombre, PR->PrCIF, PR->PrContacto })
            endif
            PR->(DbSkip())
         enddo
   end case
   PR->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/

function PrEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := PR->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Perceptor"
   oBrowse:aCols[2]:cHeader := "CIF / NIF"
   oBrowse:aCols[3]:cHeader := "Contacto"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   oBrowse:aCols[3]:nWidth  := 140
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   PR->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||PR->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           PrEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(PR->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     PrEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || PR->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (PR->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function PrClave( cProveed, oGet, nMode, nTag )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := PR->( RecNo() )
   local nOrder   := PR->( OrdNumber() )
   local nArea    := Select()

   if Empty( cProveed )
      if nMode == 4 .OR. nTag == 2
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT PR
   PR->( DbSetOrder( nTag ) )
   PR->( DbGoTop() )

   if PR->( DbSeek( UPPER( cProveed ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Perceptor existente.")
         Case nMode == 2
            if PR->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Perceptor existente.")
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
         if MsgYesNo("Perceptor inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := PrEdita( , 1, , , @cProveed )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      iif(nTag==1,oGet:cText(space(40)),oGet:cText(space(15)))
   else
      oGet:cText( cProveed )
   endif

   PR->( DbSetOrder( nOrder ) )
   PR->( DbGoTo( nRecno ) )

   Select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function PrCambiaClave( cNew, cOld )
   local nAuxOrder
   local nAuxRecNo
   cOld := upper(rtrim(cOld))
   // cambio el proveedor en los apuntes
	Select AP
   nAuxRecno := AP->(RecNo())
   nAuxOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApProveed   ;
      with cNew            ;
      for Upper(Rtrim(AP->ApProveed)) == Upper(rtrim(cOld))
   AP->(DbSetOrder( nAuxOrder ))
   AP->(DbGoTo( nAuxRecno ))
	// cambio el proveedor en los presupuestos
	Select PU
   nAuxRecno := PU->(RecNo())
   nAuxOrder := PU->(OrdNumber())
   PU->(DbSetOrder(0))
   PU->(DbGoTop())
   Replace PU->PuProveed   ;
      with cNew            ;
      for Upper(Rtrim(PU->PuProveed)) == Upper(rtrim(cOld))
   PU->(DbSetOrder( nAuxOrder ))
   PU->(DbGoTo( nAuxRecno ))
   SELECT PR
return NIL

//_____________________________________________________________________________//

function PrApuntes( oGrid, oParent )
   local cProveed := PR->PrNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT AP
	AP->(DbSetOrder(8))
	AP->(DbGoTop())
   if ! AP->(DbSeek(upper(cProveed)))
      MsgStop("El perceptor no aparece en ningún apunte.")
      RETURN NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Apuntes del perceptor: '+rtrim(cProveed) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApProveed) == upper(cProveed)
         aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApConcepto, AP->ApImpTotal, AP->(Recno()) })
      endif
      AP->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:bClrRowFocus := { || { oApp():cClrGas, oApp():nClrHL } }	 
   oBrowse:bClrSelFocus := { || { oApp():cClrGas, oApp():nClrHL } }
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

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || (AP->(DbGoTo(aBrowse[oBrowse:nArrayAt,5])),;
                                                             ApGEdita1(,2,,oDlg,.f.)) } } )

   oBrowse:lHScroll := .F.
   oBrowse:lFooter  := .T.
   oBrowse:Maketotals()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   SELECT PR
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return NIL
/*_____________________________________________________________________________*/

function PrPresupuestos( oGrid, oParent )
   local cProveed := PR->PrNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT PU
	PU->(DbSetOrder(7))
	PU->(DbGoTop())
   if ! PU->(DbSeek(upper(cProveed)))
      MsgStop("El perceptor no aparece en ningún presupuesto.")
      retu NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Presupuestos del perceptor: '+rtrim(cProveed) OF oParent
   oDlg:SetFont(oApp():oFont)

   PU->(DbGoTop())
   do while ! PU->(EOF())
      if upper(PU->PuProveed) == upper(cProveed)
         aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuConcepto, PU->PuImpTotal, PU->(Recno()) })
      endif
      PU->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:bClrRowFocus := { || { oApp():cClrGas, oApp():nClrHL } }	 
   oBrowse:bClrSelFocus := { || { oApp():cClrGas, oApp():nClrHL } }
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
                                                             PuGEdita1(,2,,oDlg,.f.)) } } )
 
   oBrowse:lHScroll := .F.
   oBrowse:lFooter  := .T.
   oBrowse:Maketotals()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse
   oBrowse:nRowHeight := 20
   oBrowse:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   SELECT PR
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return NIL
/*_____________________________________________________________________________*/

function PrImprime(oGrid,oParent)
   local nRecno   := PR->(Recno())
   LOCAl nOrder   := PR->(OrdSetFocus())
   local aCampos  := { "PRNOMBRE", "PRCIF", "PRCONTACTO", "PRDIRECC", "PRTELEFONO",;
                       "PRMOVIL", "PRFAX", "PRlocalI", "PRPAIS", "PREMAIL", "PRURL" }
   local aTitulos := { "Perceptor", "CIF / NIF", "Contacto", "Dirección", "Teléfono",;
                       "Movil", "Fax", "Localidad", "Pais", "e-mail", "Sitio web " }
   local aWidth   := { 40, 15, 40, 40, 15, 15, 15, 40, 20, 20, 20 }
   local aShow    := { .t., .t., .t., .t., .t., .t., .t., .t., .t., .t., .t. }
   local aPicture := { "NO","NO","NO","NO","NO","NO","NO","NO","NO","NO","NO" }
   local aTotal   := { .f., .f., .f., .f., .f., .f., .f., .f., .f., .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PR" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      PR->(DbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                     oInforme:oReport:Say(1, 'Total perceptores: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                     oInforme:oReport:EndLine() )
         oInforme:End(.t.)
      endif
   endif
   PR->(DbGoTo(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return NIL
//_____________________________________________________________________________//

function PrList( aList, cData, oSelf )
   local aNewList := {}
   PR->( dbSetOrder(1) )
   PR->( dbGoTop() )
   while ! PR->(Eof())
      if at(Upper(cdata), Upper(PR->PrNombre)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { PR->PrNombre } )
      endif 
      PR->(DbSkip())
   enddo
return aNewlist
// _____________________________________________________________________________//

FUNCTION Pr1Mas( cProveed, cTipo, nImporte )

   LOCAL nPrRecno := PR->( RecNo() )
   LOCAL nPrOrder := PR->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT PR
   PR->( ordSetFocus( 1 ) )
   PR->( dbGoTop() )
   IF PR->( dbSeek( Upper( cProveed ) ) )
      IF cTipo == 'A'
         REPLACE PR->PrApuntes WITH PR->PrApuntes + 1
         REPLACE PR->PrApSuma WITH PR->PrApSuma + nImporte
      ELSEIF cTipo == 'P'
         REPLACE PR->PrPresupu WITH PR->PrPresupu + 1
         REPLACE PR->PrpuSuma WITH PR->PrPuSuma + nImporte
      ENDIF
   ELSEIF ! Empty(cProveed)
      MsgAlert( 'Perceptor no encontrado.' )
   ENDIF
   PR->( dbCommit() )
   PR->( ordSetFocus( nPrOrder ) )
   PR->( dbGoto( nPrRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION Pr1Menos( cProveed, cTipo, nImporte )

   LOCAL nPrRecno := PR->( RecNo() )
   LOCAL nPrOrder := PR->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT PR
   PR->( ordSetFocus( 1 ) )
   PR->( dbGoTop() )
   IF PR->( dbSeek( Upper( cProveed ) ) )
      IF cTipo == 'A'
         REPLACE PR->PrApuntes WITH PR->PrApuntes - 1
         REPLACE PR->PrApSuma WITH PR->PrApSuma - nImporte
      ELSEIF cTipo == 'P'
         REPLACE PR->PrPresupu WITH PR->PrPresupu - 1
         REPLACE PR->PrPuSuma WITH PR->PrPuSuma - nImporte
      ENDIF
   ELSEIF ! Empty(cProveed)
      MsgAlert( 'Perceptor no encontrado.' )
   ENDIF
   PR->( dbCommit() )
   PR->( ordSetFocus( nPrOrder ) )
   PR->( dbGoto( nPrRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//
