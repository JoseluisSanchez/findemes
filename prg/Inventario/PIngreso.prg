#include "FiveWin.ch"
#include "Report.ch"
#include "Xbrowse.ch"
#include "Splitter.ch"
#include "vMenu.ch"

function Ingresos()
   local oBar
   local oCol
   local cState := GetPvProfString("Browse", "InState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "InOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "InRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "InSplit","102", oApp():cIniFile))
   local oCont
   local i

   if oApp():oDlg != NIL
      if oApp():nEdit > 0
         retu nil
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   endif

   IF ! Db_OpenAll()
      retu NIL
   endif

   SELECT IN
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de ingresos')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "IN"

   ADD oCol TO oApp():oGrid DATA IN->InCategor ;
      HEADER "Tipo de ingreso" WIDTH 320
 
   ADD oCol TO oApp():oGrid DATA IN->InApuntes ;
      HEADER "Apuntes" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA IN->InApSuma ;
      HEADER "Suma Apu." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA IN->InPresupu ;
      HEADER "Presupuestos" PICTURE "@E 999,999" WIDTH 120 TOTAL 0

   ADD oCol TO oApp():oGrid DATA IN->InPuSuma ;
      HEADER "Suma Pre." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := {|| Space( 3 ) }
   oCol:cHeader  := i18n( "Color" )
   oCol:nWidth   := 30
   oCol:bClrStd := {|| { CLR_WHITE, IN->InColor } }
   oCol:bClrSel := {|| { CLR_WHITE, IN->InColor } }
   oCol:bClrSelFocus  := {|| { CLR_WHITE, IN->InColor } }
   
   FOR i := 1 TO Len( oApp():oGrid:aCols ) - 1
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
      oCol:bClrSelFocus := {|| { oApp():cClrIng, oApp():nClrHL } }
      oCol:bLDClickData := {|| InEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := { || RefreshCont(oCont,"IN") }
   oApp():oGrid:bKeyDown := {|nKey| InTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }
   oApp():oGrid:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
   oApp():oGrid:bClrRowFocus := { || { oApp():cClrIng, oApp():nClrHL } }	 
	oApp():oGrid:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:MakeTotals()
   oApp():oGrid:bClrFooter := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
	oApp():oGrid:RestoreState( cState )

   IN->(DbSetOrder(nOrder))
   IN->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont   ;
      CAPTION tran(IN->(OrdKeyNo()),'@E 999,999')+" / "+tran(IN->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24            ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_CATINGRESO"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 190 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar       ;
      CAPTION "  tipos de ingreso" ;
      HEIGHT 24               ;
		COLOR GetSysColor(9), oApp():nClrBar 	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 10 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION InEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION InEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_duplica"           ;
      ACTION InEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION InBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION InBusca(oApp():oGrid,,oCont) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION InImprime(oApp():oDlg)         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver apuntes"     ;
      IMAGE "16_apuntes"        ;
      ACTION InApuntes( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver presupuestos"   ;
      IMAGE "16_presupu"           ;
      ACTION InPresupuestos( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Tipos de ingresos" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "InState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Tipos de ingreso ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              IN->(DbSetOrder(nOrder)),;
              IN->(DbGoTop())         ,;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont, "IN") )

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
              WritePProString("Browse","InState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","InOrder",Ltrim(Str(IN->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","InRecno",Ltrim(Str(IN->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","InSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, .t. )

return nil
//-----------------------------------------------------------------------//

function InEdita( oGrid, nMode, oCont, oParent, cIngreso )
   local oDlg, oFld, oBmp
   local aTitle := { i18n( "Añadir tipo de ingreso" )   ,;
                     i18n( "Modificar tipo de ingreso") ,;
                     i18n( "Duplicar tipo de ingreso") }
   local aGet[3]
   local cInCategor
   local nInColor
   local nRecPtr  := IN->(RecNo())
   local nOrden   := IN->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   IF IN->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif

   oApp():nEdit ++

   if nMode == 1
      IN->(DbAppend())
      nRecAdd  := IN->(RecNo())
   endif

   cInCategor := IIF(nMode==1.AND.cIngreso!=NIL,cIngreso,IN->InCategor)
   nInColor   := iif(nMode==2,IN->InColor,RGB(HB_RandomInt(255),HB_RandomInt(255),HB_RandomInt(255)))

   if nMode == 3
      IN->(DbAppend())
      nRecAdd := IN->(RecNo())
   endif

   IF oParent == NIL
      oParent := oApp():oDlg
   endif

   DEFINE DIALOG oDlg RESOURCE "INEDIT"   ;
      TITLE aTitle[ nMode ]               ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY ID 11 OF oDlg

   REDEFINE GET aGet[1] VAR cInCategor   ;
      ID 12 OF oDlg UPDATE               ;
      VALID InClave( cInCategor, aGet[1], nMode );
      COLOR oApp():cClrIng, CLR_WHITE

   REDEFINE SAY ID 13 OF oDlg

   REDEFINE SAY aGet[2] ID 14 OF oDlg
   aGet[2]:SetColor(nInColor, nInColor)

   REDEFINE BUTTON aGet[3] ID 15 OF oDlg ;
      ACTION ( nInColor := ChooseColor(nInColor),;
 					aGet[2]:SetColor(nInColor,nInColor),;
               aGet[2]:Refresh() )

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

   IF oDlg:nresult == IDOK
      lReturn := .t.
      if nMode == 2
         IN->(DbGoTo(nRecPtr))
      else
         IN->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el tipo de ingreso en los apuntes _______//

      IF nMode == 2
         IF IN->InCategor != cInCategor
            msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
                  { || InCambiaClave( cInCategor, IN->InCategor ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//

      Select IN
      REPLACE IN->InCategor WITH cInCategor
      REPLACE IN->InColor   WITH nInColor
      IN->( dbCommit() )
      IF cIngreso != NIL
         cIngreso := IN->InCategor
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         IN->(DbGoTo(nRecAdd))
         IN->(DbDelete())
         IN->(DbPack())
         IN->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT IN

   if oCont != NIL
      RefreshCont(oCont,"IN")
   endif
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

   oApp():nEdit --

return lReturn
//_____________________________________________________________________________//

function InBorra(oGrid,oCont)
   local nRecord  := IN->(Recno())
   local cKeyNext
   local nAuxRecno
   local nAuxOrder

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este tipo de ingreso ?") + CRLF + ;
                (trim(IN->InCategor)))

      msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || InCambiaClave( SPACE(40), IN->InCategor ) } )

      // borrado de la tipo de documento
      IN->(DbSkip())
      cKeyNext := IN->(OrdKeyVal())
      IN->(DbGoto(nRecord))
      IN->(DbDelete())
      IN->(DbPack())

      if cKeyNext != NIL
         IN->(DbSeek(cKeyNext))
      else
         IN->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"IN")
   endif

   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil
//_____________________________________________________________________________//

function InTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      InEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      InEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      InBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         InBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         InBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase

return nil

//_____________________________________________________________________________//

function InSeleccion( cIngreso, oControl, oParent, oVItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := IN->( RecNo() )
   local nOrder := IN->( OrdNumber() )
   local nArea  := Select()
   local aPoint := iif(oControl!=NIL,AdjustWnd( oControl, 271*2, 150*2 ),{1.3*oVItem:nTop(),oApp():oGrid:nLeft})
   local cBrwState  := ""

   oApp():nEdit ++
   IN->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "InAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de tipos de ingreso" )      ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "IN"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || IN->InCategor }
   oCol:cHeader  := i18n( "Tipos de ingreso" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| InTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
   oCol:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
   oCol:bClrSel := {|| { oApp():cClrIng, oApp():nClrHL } }
   oCol:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION InEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION InEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION InBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION InBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      cIngreso := IN->InCategor
      if oControl != NIL
         oControl:cText := IN->InCategor
      endif
   endif

   SetIni( , "Browse", "InAux", oBrowse:SaveState() )
   IN->( DbSetOrder( nOrder ) )
   IN->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return nil
//_____________________________________________________________________________//

function InBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := IN->(OrdNumber())
   local nRecno   := IN->(Recno())
   local oDlg, oGet, cPicture
   local aSay1    := "Introduzca el tipo de ingreso a buscar"
   local aSay2    := "Tipo ingreso:"
   local cGet     := space(40)
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA'   ;
      TITLE i18n("Búsqueda de tipo de ingreso") OF oParent
   oDlg:SetFont(oApp():oFont)

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
         { || InWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún tipo de ingreso")
      else
         InEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   IN->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "IN" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function InWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := IN->(Recno())

   do case
      case nOrder == 1
         IN->(DbGoTop())
         do while ! IN->(eof())
            if cGet $ upper(IN->InCategor)
               aadd(aBrowse, { IN->InCategor })
            endif
            IN->(DbSkip())
         enddo
   end case
   IN->(DbGoTo(nRecno))
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/
function InEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := IN->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Tipo de ingreso"
   oBrowse:aCols[1]:nWidth  := 220
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
   IN->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||IN->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           InEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(IN->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     InEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || IN->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (IN->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

//_____________________________________________________________________________//

function InCambiaClave( cVar, cOld )

   local nOrder
   local nRecNo

   // cambio la categoria en apuntes
   Select AP
   nRecno := AP->(RecNo())
   nOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApCatIngr   ;
      with cVar            ;
      for Upper(Rtrim(AP->ApCatIngr)) == Upper(rtrim(cOld))
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
	// cambio la categoria presupuestos
   Select PU
   nRecno := PU->(RecNo())
   nOrder := PU->(OrdNumber())
   PU->(DbSetOrder(0))
   PU->(DbGoTop())
   Replace PU->PuCatIngr   ;
      with cVar            ;
      for Upper(Rtrim(PU->PuCatIngr)) == Upper(rtrim(cOld))
   PU->(DbSetOrder(nOrder))
   PU->(DbGoTo(nRecno))
return nil

//_____________________________________________________________________________//

function InClave( cIngreso, oGet, nMode )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := IN->( RecNo() )
   local nOrder   := IN->( OrdNumber() )
   local nArea    := Select()

   if Empty( cIngreso )
      if nMode == 4
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT IN
   IN->( DbSetOrder( 1 ) )
   IN->( DbGoTop() )

   if IN->( DbSeek( UPPER( cIngreso ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Tipo de ingreso existente.")
         Case nMode == 2
            if IN->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Tipo de ingreso existente.")
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
         if MsgYesNo("Tipo de ingreso inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := InEdita( , 1, , , @cIngreso )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      oGet:cText( space(40) )
   else
      oGet:cText( cIngreso )
   endif

   IN->( DbGoTo( nRecno ) )
   Select (nArea)
return lReturn

//_____________________________________________________________________________//

function InApuntes( oGrid, oParent )
   local cInCategor := IN->InCategor
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT AP
	AP->(DbSetOrder(5))
	AP->(DbGoTop())
   if ! AP->(DbSeek(upper(cInCategor)))
      MsgStop("El tipo de ingreso no aparece en ningún apunte.")
      RETURN NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Apuntes del tipo de ingreso: '+rtrim(cInCategor) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApCatIngr) == upper(cInCategor)
         aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApConcepto, AP->ApImpTotal, AP->(Recno()) })
      endif
      AP->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
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
   //obrowse:bClrStd := {|| { oApp():cClrIng, CLR_WHITE } }
   //obrowse:bClrSel := {|| { oApp():cClrIng, oApp():nClrHL } }
   //obrowse:bClrSelFocus := { || { oApp():cClrIng, oApp():nClrHL } }

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

   SELECT IN
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil

//_____________________________________________________________________________//

function InPresupuestos( oGrid, oParent )
   local cInCategor := IN->InCategor
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT PU
	PU->(DbSetOrder(4))
	PU->(DbGoTop())
   if ! PU->(DbSeek(upper(cInCategor)))
      MsgStop("El tipo de ingreso no aparece en ningún presupuesto.")
      RETU NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Presupuestos del tipo de ingreso: '+rtrim(cInCategor) OF oParent
   oDlg:SetFont(oApp():oFont)

   PU->(DbGoTop())
   do while ! PU->(EOF())
      if upper(PU->PuCatIngr) == upper(cInCategor)
         aadd(aBrowse, { PU->PuFecha, PU->PuActivida, PU->PuConcepto, PU->PuImpTotal, PU->(Recno()) })
      endif
      PU->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
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

   SELECT IN
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil
/*_____________________________________________________________________________*/

function InImprime( oGrid )
   local nRecno   := IN->(Recno())
   local nOrder   := IN->(OrdSetFocus())
   local aCampos  := { "InCategor" }
   local aTitulos := { "Tipo de ingreso" }
   local aWidth   := { 40 }
   local aShow    := { .t. }
   local aPicture := { "NO" }
   local aTotal   := { .f. }
   local oInforme

   Select IN
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "IN" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      IN->(DbGoTop())
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                  oInforme:oReport:Say(1, 'Total tipos de ingreso: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                  oInforme:oReport:EndLine() )
      oInforme:End(.t.)
      IN->(DbGoTo(nRecno))
   endif

   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return nil

//_____________________________________________________________________________//

function InIsDbfEmpty()

   local lReturn := .f.

   if IN->( ordKeyVal() ) == nil
      msgStop( i18n( "No hay ningún ingreso registrado." ) )
      lReturn := .t.
   endif

RETURN lReturn

function InList( aList, cData, oSelf )
   local aNewList := {}
   IN->( dbSetOrder(1) )
   IN->( dbGoTop() )
   while ! IN->(Eof())
      if at(Upper(cdata), Upper(IN->InCategor)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { IN->InCategor } )
      endif 
      IN->(DbSkip())
   enddo
return aNewlist
// _____________________________________________________________________________//

FUNCTION In1Mas( cIngreso, cTipo, nImporte )
   LOCAL nInRecno := IN->( RecNo() )
   LOCAL nInOrder := IN->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT IN
   IN->( ordSetFocus( 1 ) )
   IN->( dbGoTop() )
   IF IN->( dbSeek( Upper( cIngreso ) ) )
      IF cTipo == 'A'
         REPLACE IN->InApuntes WITH IN->InApuntes + 1
         REPLACE IN->InApSuma  WITH IN->InApSuma + nImporte 
      ELSEIF cTipo == 'P'
         REPLACE IN->InPresupu WITH IN->InPresupu + 1
         REPLACE IN->InPrSuma  WITH IN->InPrSuma + nImporte
      ENDIF
   ELSEIF ! Empty(cIngreso)
      MsgAlert( cIngreso+'* Tipo de ingreso no encontrado.' )
   ENDIF
   IN->( dbCommit() )
   IN->( ordSetFocus( nInOrder ) )
   IN->( dbGoto( nInRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION In1Menos( cIngreso, cTipo, nImporte )
   LOCAL nInRecno := IN->( RecNo() )
   LOCAL nInOrder := IN->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT IN
   IN->( ordSetFocus( 1 ) )
   IN->( dbGoTop() )
   IF IN->( dbSeek( Upper( cIngreso ) ) )
      IF cTipo == 'A'
         REPLACE IN->InApuntes WITH IN->InApuntes - 1
         REPLACE IN->InApSuma  WITH IN->InApSuma - nImporte 
      ELSEIF cTipo == 'P'
         REPLACE IN->InPresupu WITH IN->InPresupu - 1
         REPLACE IN->InPrSuma  WITH IN->InPrSuma - nImporte
      ENDIF
   ELSEIF ! Empty(cIngreso)
      MsgAlert( cIngreso+'* Tipo de ingreso no encontrado.' )
   ENDIF
   IN->( dbCommit() )
   IN->( ordSetFocus( nInOrder ) )
   IN->( dbGoto( nInRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//
