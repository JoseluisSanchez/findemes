#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

static oReport

function Categorias()
   local oBar
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "CAState","", oApp():cIniFile)
   local nOrder := Val(GetPvProfString("Browse", "CaOrder","1", oApp():cIniFile))
   local nRecno := Val(GetPvProfString("Browse", "CaRecno","1", oApp():cIniFile))
   local nSplit := Val(GetPvProfString("Browse", "CaSplit","102", oApp():cIniFile))
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

   select CA
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de categorias')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "CA"

   // ojo falta la categoría
   aBrowse   := { { {|| CA->CaNombre }, i18n("Categoría"), 150, 0 },;
      { {|| CA->CaInven }, i18n("Inventario"), 120, 0 } }


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
      oCol:bLDClickData  := {|| CaEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   next

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont(oCont,"CA") }
   oApp():oGrid:bKeyDown := {|nKey| CaTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )

   CA->(dbSetOrder(nOrder))
   CA->(dbGoto(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont ;
      CAPTION tran(CA->(ordKeyNo()),'@E 999,999')+" / "+tran(CA->(ordKeyCount()),'@E 999,999') ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_CATEGOR" ;

   @ 24, 05 VMENU oBar SIZE nSplit-10, 195 OF oApp():oDlg  ;
      color CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "  categorías " ;
      HEIGHT 24 ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 12 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION CaEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION CaEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION CaBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION CaBusca(oApp():oGrid,,oCont,oApp():oDlg)  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION CaImprime(oApp():oGrid,oApp():oDlg)   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver inventario"     ;
      IMAGE "16_invent"            ;
      ACTION CaInventario( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Categorias" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "CaState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
      ITEMS ' Categoría ' ;
      ACTION ( nOrder := oApp():oTab:nOption,;
      CA->(dbSetOrder(nOrder)),;
      oApp():oGrid:Refresh(.T.),;
      RefreshCont(oCont,"CA") )

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
      WritePProString("Browse","CaState",oApp():oGrid:SaveState(),oApp():cIniFile),;
      WritePProString("Browse","CaOrder",LTrim(Str(CA->(ordNumber()))),oApp():cIniFile),;
      WritePProString("Browse","CaRecno",LTrim(Str(CA->(RecNo()))),oApp():cIniFile),;
      WritePProString("Browse","CaSplit",LTrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

return nil
/*_____________________________________________________________________________*/

function CaEdita(oGrid,nMode,oCont,oParent,cCategor)

   local oDlg
   local aTitle := { i18n( "Añadir una categoría" ),;
      i18n( "Modificar una categoría"),;
      i18n( "Duplicar una categoría") }
   local aGet[1]
   local cCaNombre
   local nRecPtr  := CA->(RecNo())
   local nOrden   := CA->(ordNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .F.

   if CA->(Eof()) .AND. nMode != 1
      retu nil
   endif
   oApp():nEdit ++

   if nMode == 1
      CA->(dbAppend())
      nRecAdd := CA->(RecNo())
   endif

   cCaNombre   := iif(nMode==1.AND.cCategor!=NIL,cCategor,CA->CaNombre)

   if nMode == 3
      CA->(dbAppend())
      nRecAdd := CA->(RecNo())
   endif

   DEFINE DIALOG oDlg RESOURCE "CAEDIT" OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE get aGet[1] var cCaNombre  ;
      ID 12 OF oDlg UPDATE             ;
      valid CaClave( cCaNombre, aGet[1], nMode, 1 )

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
         CA->(dbGoto(nRecPtr))
      else
         CA->(dbGoto(nRecAdd))
      endif
      // ___ actualizo el nombre del proveedor en los apuntes__________________//
      if nMode == 2
         if cCaNombre != CA->CaNombre
            msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
               {|| CaCambiaClave( cCaNombre, CA->CaNombre ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//
      replace CA->Canombre   with cCanombre
      CA->(dbCommit())
      if cCategor != NIL
         cCategor := CA->CaNombre
      endif
   else
      lReturn := .F.
      if nMode == 1 .OR. nMode == 3
         CA->(dbGoto(nRecAdd))
         CA->(dbDelete())
         CA->(DbPack())
         CA->(dbGoto(nRecPtr))
      endif
   endif

   select CA
   if oCont != NIL
      RefreshCont(oCont,"CA")
   endif

   oApp():nEdit --
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   endif

return lReturn
/*_____________________________________________________________________________*/

function CaBorra(oGrid,oCont)

   local nRecord := CA->(RecNo())
   local nNext

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar esta categoría ?") + CRLF + ;
         (Trim(CA->CaNombre)))
      msgRun( i18n( "Revisando el fichero de inventario. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         {|| CaCambiaClave( Space(40), CA->CaNombre ) } )

      select CA
      CA->(dbSkip())
      nNext := CA->(RecNo())
      CA->(dbGoto(nRecord))
      CA->(dbDelete())
      CA->(DbPack())
      CA->(dbGoto(nNext))
      if CA->(Eof()) .OR. nNext == nRecord
         CA->(dbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"CA")
   endif

   oApp():nEdit --
   oGrid:Refresh(.T.)
   oGrid:SetFocus(.T.)

return nil
/*_____________________________________________________________________________*/

function CaTecla(nKey,oGrid,oCont,oDlg)

   do case
   case nKey==VK_RETURN
      CaEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      CaEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      CaBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   otherwise
      if nKey >= 96 .AND. nKey <= 105
         CaBusca(oGrid,Str(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(Chr(nKey))
         CaBusca(oGrid,Chr(nKey),oCont,oDlg)
      endif
   endcase

return nil
/*_____________________________________________________________________________*/

function CaSeleccion( cCategoria, oControl, oParent )

   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .F.
   local nRecno := CA->( RecNo() )
   local nOrder := CA->( ordNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   local cBrwState  := ""

   oApp():nEdit ++
   CA->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "CaAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de categorias" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "CA"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| CA->CaNombre }
   oCol:cHeader  := i18n( "Categoría" )
   oCol:nWidth   := 250

   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .F.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := {|nKey| CaTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION CaEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION CaEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION CaBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION CaBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .T., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .F., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      on PAINT oDlg:Move(aPoint[1], aPoint[2],,,.T.)

   if lOK
      oControl:cText := CA->CaNombre
   endif

   SetIni( , "Browse", "CaAux", oBrowse:SaveState() )
   CA->( dbSetOrder( nOrder ) )
   CA->( dbGoto( nRecno ) )
   oApp():nEdit --

   select (nArea)

return nil
/*_____________________________________________________________________________*/

function CaBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := CA->(ordNumber())
   local nRecno   := CA->(RecNo())
   local oDlg, oGet, cGet, cPicture
   local lSeek    := .F.
   local lFecha   := .F.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA' OF oParent  ;
      TITLE i18n("Búsqueda de categorías")
   oDlg:SetFont(oApp():oFont)

   REDEFINE say prompt i18n( "Introduzca la categoría" ) ID 20 OF oDlg
   REDEFINE say prompt i18n( "Categoríar" )+":" ID 21 OF Odlg
   cGet     := Space(40)

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
         {|| CaWildSeek(nOrder, RTrim(Upper(cGet)), aBrowse ) } )
      if Len(aBrowse) == 0
         MsgStop("No se ha encontrado ninguna categoría")
      else
         CaEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   CA->(ordSetFocus(nOrder))

   RefreshCont( oCont, "CA" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return nil
/*_____________________________________________________________________________*/
function CaWildSeek(nOrder, cGet, aBrowse)

   local nRecno   := CA->(RecNo())

   CA->(dbGoTop())
   do while ! CA->(Eof())
      if cGet $ Upper(CA->CaNombre)
         AAdd(aBrowse, {CA->CaNombre, CA->CaInven })
      endif
      CA->(dbSkip())
   enddo

   CA->(dbGoto(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper(aAut1[1]) < Upper(aAut2[1]) } )

return nil
/*_____________________________________________________________________________*/

function CaEncontrados(aBrowse, oParent)

   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := CL->(RecNo())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .F.)
   oBrowse:aCols[1]:cHeader := "Categoría"
   oBrowse:aCols[2]:cHeader := "Inventario"
   oBrowse:aCols[1]:nWidth  := 220
   oBrowse:aCols[2]:nWidth  := 120
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )

   CA->(ordSetFocus(1))
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {||CA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      CaEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| iif(nKey==VK_RETURN,(CA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))),;
      CaEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := {|| CA->(dbSeek(Upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (CA->(dbGoto(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      on init DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function CaClave( cClave, oGet, nMode, nTag )

   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .F.
   local nRecno   := CA->( RecNo() )
   local nOrder   := CA->( ordNumber() )
   local nArea    := Select()

   if Empty( cClave )
      if nMode == 4 .OR. nTag == 2
         return .T.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         return .F.
      endif
   endif

   select CA
   CA->( dbSetOrder( nTag ) )
   CA->( dbGoTop() )

   if CA->( dbSeek( Upper( cClave ) ) )
      do case
      case nMode == 1 .OR. nMode == 3
         lReturn := .F.
         MsgStop("Categoría existente.")
      case nMode == 2
         if CA->( RecNo() ) == nRecno
            lReturn := .T.
         else
            lReturn := .F.
            MsgStop("Categoría existente.")
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
         if MsgYesNo("Categoría inexistente. ¿ Desea darla de alta ahora? ")
            lReturn := CaEdita( , 1, , , @cClave )
         else
            lReturn := .F.
         endif
      endif
   endif

   if lReturn == .F.
      iif(nTag==1,oGet:cText(Space(40)),oGet:cText(Space(15)))
   else
      oGet:cText( cClave )
   endif

   CA->( dbSetOrder( nOrder ) )
   CA->( dbGoto( nRecno ) )

   select (nArea)

return lReturn

/*_____________________________________________________________________________*/

function CaCambiaClave( cNew, cOld )

   local nAuxOrder
   local nAuxRecNo

   cOld := Upper(RTrim(cOld))
   // cambio la tienda en el inventario
   select BI
   nAuxRecno := BI->(RecNo())
   nAuxOrder := BI->(ordNumber())
   BI->(dbSetOrder(0))
   BI->(dbGoTop())
   replace BI->BiCategor   ;
      with cNew            ;
      for Upper(RTrim(BI->BiCategor)) == Upper(RTrim(cOld))
   BI->(dbSetOrder( nAuxOrder ))
   BI->(dbGoto( nAuxRecno ))
   select MA

return nil

//_____________________________________________________________________________//

function CaInventario( oGrid, oParent )

   local cCategor := CA->CaNombre
   local oDlg, oBrowse, oCol
   local aBrowse := {}

   select BI
   BI->(dbGoTop())
   do while ! BI->(Eof())
      if Upper(BI->BiCategor) == Upper(cCategor)
         AAdd(aBrowse, { BI->BiDenomi, BI->BiMarca, BI->BiModelo, tran(BI->BiPrecio,"@E 999,999.99"), BI->(RecNo()) })
      endif
      BI->(dbSkip())
   enddo
   if Len(aBrowse) == 0
      MsgStop("La categoría no aparece en el inventario.")
      retu nil
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Inventario de la categoría: '+RTrim(cCategor) OF oParent
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

   select CA
   oGrid:Refresh()
   oGrid:SetFocus(.T.)
   oApp():nEdit --

return nil

/*_____________________________________________________________________________*/

function CaImprime(oGrid,oParent)
   local nRecno   := CA->(Recno())
   local nOrder   := CA->(OrdSetFocus())
   local aCampos  := { "CANOMBRE", "CAINVEN" }
   local aTitulos := { "Categoría", "Inventario" }
   local aWidth   := { 40, 15 }
   local aShow    := { .t., .t.}
   local aPicture := { "NO","999" }
   local aTotal   := { .f., .f. }
   local oInforme
   local aControls[1]

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "CA" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio var oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      CA->(dbGoTop())
      if oInforme:nRadio == 1
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            on END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say(1, 'Total categorías: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
            oInforme:oReport:EndLine() )
         oInforme:End(.T.)
      endif
   endif
   CA->(dbGoto(nRecno))
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

return nil
//_____________________________________________________________________________//
function CaList( aList, cData, oSelf )
   local aNewList := {}
   CA->( dbSetOrder(1) )
   CA->( dbGoTop() )
   while ! CA->(Eof())
      if at(Upper(cdata), Upper(CA->CaNombre)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { CA->CaNombre } )
      endif 
      CA->(DbSkip())
   enddo
return aNewlist
