#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "Splitter.ch"
#include "vMenu.ch"

//_____________________________________________________________________________//

function Gastos()
   local oBar
   local oCol
   local cState := GetPvProfString("Browse", "GaState","", oApp():cIniFile)
   local nOrder := VAL(GetPvProfString("Browse", "GaOrder","1", oApp():cIniFile))
   local nRecno := VAL(GetPvProfString("Browse", "GaRecno","1", oApp():cIniFile))
   local nSplit := VAL(GetPvProfString("Browse", "GaSplit","102", oApp():cIniFile))
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

   if ! Db_OpenAll()
      retu NIL
   endif

   SELECT GA
   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de gastos')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   oApp():oGrid:cAlias := "GA"

   ADD oCol TO oApp():oGrid DATA GA->GaCategor ;
      HEADER "Tipo de Gasto" WIDTH 320
  
   ADD oCol TO oApp():oGrid DATA GA->GaApuntes ;
      HEADER "Apuntes" PICTURE "@E 999,999" WIDTH 120 TOTAL 0
 
   ADD oCol TO oApp():oGrid DATA GA->GaApSuma ;
      HEADER "Suma Apu." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0
 
   ADD oCol TO oApp():oGrid DATA GA->GaPresupu ;
      HEADER "Presupuestos" PICTURE "@E 999,999" WIDTH 120 TOTAL 0
 
   ADD oCol TO oApp():oGrid DATA GA->GaPuSuma ;
      HEADER "Suma Pre." PICTURE "@E 999,999.99" WIDTH 120 TOTAL 0
 
   oCol := oApp():oGrid:AddCol()
   oCol:bStrData := {|| Space( 3 ) }
   oCol:cHeader  := i18n( "Color" )
   oCol:nWidth   := 30
   oCol:bClrStd := {|| { CLR_WHITE, GA->GaColor } }
   oCol:bClrSel := {|| { CLR_WHITE, GA->GaColor } }
   oCol:bClrSelFocus  := {|| { CLR_WHITE, GA->GaColor } }
   oCol:bLDClickData  := {|| GaEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   FOR i := 1 TO Len( oApp():oGrid:aCols ) - 1
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }
      oCol:bClrSelFocus := {|| { oApp():cClrGas, oApp():nClrHL } }
      oCol:bLDClickData := {|| GaEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT
 
   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "GA" ) }
   oApp():oGrid:bKeyDown := {| nKey| GaTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:MakeTotals()
   oApp():oGrid:bClrFooter := {|| { oApp():nClrFilter, GetSysColor( 15 ) } }
   oApp():oGrid:RestoreState( cState )

   GA->(DbSetOrder(nOrder))
   GA->(DbGoTo(nRecno))

   @ 02, 05 VMENU oCont SIZE nSplit-10, 18 OF oApp():oDlg

   DEFINE TITLE OF oCont   ;
      CAPTION tran(GA->(OrdKeyNo()),'@E 999,999')+" / "+tran(GA->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 24            ;
		COLOR GetSysColor(9), oApp():nClrBar ; 	
      IMAGE "BB_CATGASTO"

   @ 24, 05 VMENU oBar SIZE nSplit-10, 190 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar       ;
      CAPTION "  tipos de gasto" ;
      HEIGHT 24               ;
		COLOR GetSysColor(9), oApp():nClrBar  	

   DEFINE VMENUITEM OF obar         ;
      HEIGHT 10 SEPARADOR

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_nuevo"             ;
      ACTION GaEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_modif"             ;
      ACTION GaEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_duplica"           ;
      ACTION GaEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_borrar"            ;
      ACTION GaBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_busca"             ;
      ACTION GaBusca(oApp():oGrid,,oCont) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_imprimir"          ;
      ACTION GaImprime(oApp():oDlg);
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver apuntes"     ;
      IMAGE "16_apuntes"        ;
      ACTION GaApuntes( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver presupuestos"   ;
      IMAGE "16_presupu"           ;
      ACTION GaPresupuestos( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 18

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Tipos de gasto" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar columnas" ;
      IMAGE "16_grid"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "GaState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_salir"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 13 PIXEL OF oApp():oDlg ;
     ITEMS ' Tipos de gasto ';
     ACTION ( nOrder := oApp():oTab:nOption  ,;
              GA->(DbSetOrder(nOrder)),;
              GA->(DbGoTop())         ,;
              oApp():oGrid:Refresh(.t.)      ,;
              RefreshCont(oCont, "GA") )

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
              WritePProString("Browse","GaState",oApp():oGrid:SaveState(),oApp():cIniFile) ,;
              WritePProString("Browse","GaOrder",Ltrim(Str(GA->(OrdNumber()))),oApp():cIniFile) ,;
              WritePProString("Browse","GaRecno",Ltrim(Str(GA->(Recno()))),oApp():cIniFile) ,;
              WritePProString("Browse","GaSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cIniFile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, .t. )

return NIL
//_____________________________________________________________________________//

function GaEdita( oGrid, nMode, oCont, oParent, cGasto )
   local oDlg, oFld, oBmp
   local aTitle := { i18n( "Añadir tipo de gasto" )   ,;
                     i18n( "Modificar tipo de gasto") ,;
                     i18n( "Duplicar tipo de gasto") }
   local aGet[3]
   local cGaCategor
   local nGaColor
   local nRecPtr  := GA->(RecNo())
   local nOrden   := GA->(OrdNumber())
   local nRecAdd
   local lDuplicado
   local lReturn  := .f.

   if GA->(EOF()) .AND. nMode != 1
      RETURN NIL
   endif

   oApp():nEdit ++

   if nMode == 1
      GA->(DbAppend())
      nRecAdd  := GA->(RecNo())
   endif

   cGaCategor := IIF(nMode==1.AND.cGasto!=NIL,cGasto,GA->GaCategor)
   nGaColor   := iif(nMode==2,GA->GaColor,RGB(HB_RandomInt(255),HB_RandomInt(255),HB_RandomInt(255)))

   if nMode == 3
      GA->(DbAppend())
      nRecAdd := GA->(RecNo())
   endif

   if oParent == NIL
      oParent := oApp():oDlg
   endif

   DEFINE DIALOG oDlg RESOURCE "GAEDIT"   ;
      TITLE aTitle[ nMode ]               ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY ID 11 OF oDlg
   REDEFINE GET aGet[1] VAR cGaCategor   ;
      ID 12 OF oDlg UPDATE               ;
      VALID InClave( cGaCategor, aGet[1], nMode );
      COLOR oApp():cClrGas, CLR_WHITE

   REDEFINE SAY ID 13 OF oDlg

   REDEFINE SAY aGet[2] ID 14 OF oDlg
   aGet[2]:SetColor(nGaColor, nGaColor)

   REDEFINE BUTTON aGet[3] ID 15 OF oDlg ;
      ACTION ( nGaColor := ChooseColor(nGaColor),;
 					aGet[2]:SetColor(nGaColor,nGaColor),;
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

   if oDlg:nresult == IDOK
      lReturn := .t.
      if nMode == 2
         GA->(DbGoTo(nRecPtr))
      else
         GA->(DbGoTo(nRecAdd))
      endif
      // ___ actualizo el tipo de gasto en los apuntes _______//

      if nMode == 2
         if GA->GaCategor != cGaCategor
            msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
                  { || GaCambiaClave( cGaCategor, GA->GaCategor ) } )
         endif
      endif

      // ___ guardo el registro _______________________________________________//

      Select GA
      Replace GA->GaCategor with cGaCategor
      Replace GA->GaColor   with nGaColor
      GA->( DbCommit() )
      if cGasto != NIL
         cGasto := GA->GaCategor
      endif
   else
      lReturn := .f.
      if nMode == 1 .OR. nMode == 3
         GA->(DbGoTo(nRecAdd))
         GA->(DbDelete())
         GA->(DbPack())
         GA->(DbGoTo(nRecPtr))
      endif
   endif

   SELECT GA

   if oCont != NIL
      RefreshCont(oCont,"GA")
   endif
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif

   oApp():nEdit --

return lReturn
//_____________________________________________________________________________//

function GaBorra(oGrid,oCont)
   local nRecord  := GA->(Recno())
   local cKeyNext
   local nAuxRecno
   local nAuxOrder

   oApp():nEdit ++

   if msgYesNo( i18n("¿ Está seguro de querer borrar este tipo de gasto ?") + CRLF + ;
                (trim(GA->GaCategor)))
      msgRun( i18n( "Revisando el fichero de apuntes. Espere un momento..." ), oApp():cAppName+oApp():cVersion, ;
         { || GaCambiaClave( SPACE(40), GA->GaCategor ) } )
      // borrado de la tipo de documento
      GA->(DbSkip())
      cKeyNext := GA->(OrdKeyVal())
      GA->(DbGoto(nRecord))
      GA->(DbDelete())
      GA->(DbPack())
      if cKeyNext != NIL
         GA->(DbSeek(cKeyNext))
      else
         GA->(DbGoBottom())
      endif
   endif

   if oCont != NIL
      RefreshCont(oCont,"GA")
   endif

   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil
//_____________________________________________________________________________//

function GaTecla(nKey,oGrid,oCont,oDlg)
Do case
   case nKey==VK_RETURN
      GaEdita(oGrid,2,oCont,oDlg)
   case nKey==VK_INSERT
      GaEdita(oGrid,1,oCont,oDlg)
   case nKey==VK_DELETE
      GaBorra(oGrid,oCont)
   case nKey==VK_ESCAPE
      oDlg:End()
   OTHERWISE
      if nKey >= 96 .AND. nKey <= 105
         GaBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
      elseif HB_ISSTRING(CHR(nKey))
         GaBusca(oGrid,CHR(nKey),oCont,oDlg)
      endif
EndCase

return nil

//_____________________________________________________________________________//

function GaSeleccion( cGasto, oControl, oParent, oVItem )
   local oDlg, oBrowse, oCol
   local oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   local lOk    := .f.
   local nRecno := GA->( RecNo() )
   local nOrder := GA->( OrdNumber() )
   local nArea  := Select()
   local aPoint := iif(oControl!=NIL,AdjustWnd( oControl, 271*2, 150*2 ),{1.3*oVItem:nTop(),oApp():oGrid:nLeft})
   local cBrwState  := ""

   oApp():nEdit ++
   GA->( dbGoTop() )

   cBrwState := GetIni( , "Browse", "GaAux", "" )

   DEFINE DIALOG oDlg RESOURCE "DLG_TABLA_AUX" ;
      TITLE i18n( "Selección de tipos de gasto" )      ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )

   Ut_BrwRowConfig( oBrowse )

   oBrowse:cAlias := "GA"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || GA->GaCategor }
   oCol:cHeader  := i18n( "Tipos de gasto" )
   oCol:nWidth   := 250

   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { || lOk := .T., oDlg:End() } } )

   oBrowse:lHScroll := .f.
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oDlg:oClient := oBrowse

   oBrowse:RestoreState( cBrwState )
   oBrowse:bKeyDown := { |nKey| InTecla( nKey, oBrowse, , oDlg ) }
   oBrowse:nRowHeight := 20
	oBrowse:bClrStd      := {|| { oApp():cClrGas, CLR_WHITE } }
	oBrowse:bClrRowFocus := { || { oApp():cClrGas, oApp():nClrHL } }	 
	oBrowse:bClrSelFocus := { || { oApp():cClrGas, oApp():nClrHL } }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION GaEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION GaEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION GaBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION GaBusca( oBrowse,,,oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      cGasto := GA->GaCategor 
      if oControl != NIL
         oControl:cText := GA->GaCategor
      endif
   endif

   SetIni( , "Browse", "GaAux", oBrowse:SaveState() )
   GA->( DbSetOrder( nOrder ) )
   GA->( DbGoTo( nRecno ) )
   oApp():nEdit --

   Select (nArea)
return nil
//_____________________________________________________________________________//

function GaBusca( oGrid, cChr, oCont, oParent )

   local nOrder   := GA->(OrdNumber())
   local nRecno   := GA->(Recno())
   local oDlg, oGet, cPicture
   local aSay1    := "Introduzca el tipo de gasto a buscar"
   local aSay2    := "Tipo gasto:"
   local cGet     := space(40)
   local lSeek    := .f.
   local lFecha   := .f.
   local aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_BUSCA'   ;
      TITLE i18n("Búsqueda de tipo de gasto") OF oParent
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
         { || GaWildSeek(nOrder, rtrim(upper(cGet)), aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún tipo de gasto")
      else
         GaEncontrados(aBrowse, oApp():oDlg)
      endif
   end if
   GA->(OrdSetFocus(nOrder))

   RefreshCont( oCont, "GA" )
   oGrid:refresh()
   oGrid:setFocus()

   oApp():nEdit--

return NIL
/*_____________________________________________________________________________*/
function GaWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := IN->(Recno())

   do case
      case nOrder == 1
         GA->(DbGoTop())
         do while ! GA->(eof())
            if cGet $ upper(GA->GaCategor)
               aadd(aBrowse, { GA->GaCategor })
            endif
            GA->(DbSkip())
         enddo
   end case
   GA->(DbGoTo(nRecno))
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/
function GaEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := GA->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Tipo de gasto"
   oBrowse:aCols[1]:nWidth  := 220
   Ut_BrwRowConfig( oBrowse )

   oBrowse:CreateFromResource( 110 )
   GA->(OrdSetFocus(1))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||GA->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                           GaEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(GA->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))),;
                                                     GaEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || GA->(DbSeek(upper(aBrowse[oBrowse:nArrayAt, 1]))) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20
   oBrowse:bClrStd := {|| { oApp():cClrGas, CLR_WHITE } }

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (GA->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

//_____________________________________________________________________________//

function GaCambiaClave( cVar, cOld )

   local nOrder
   local nRecNo

   // cambio la categoria en apuntes
   Select AP
   nRecno := AP->(RecNo())
   nOrder := AP->(OrdNumber())
   AP->(DbSetOrder(0))
   AP->(DbGoTop())
   Replace AP->ApCatGast   ;
      with cVar            ;
      for Upper(Rtrim(AP->ApCatGast)) == Upper(rtrim(cOld))
   AP->(DbSetOrder(nOrder))
   AP->(DbGoTo(nRecno))
	// cambio la categoria en presupuestos
   Select PU
   nRecno := PU->(RecNo())
   nOrder := PU->(OrdNumber())
   PU->(DbSetOrder(0))
   PU->(DbGoTop())
   Replace PU->PuCatGast   ;
      with cVar            ;
      for Upper(Rtrim(PU->PuCatGast)) == Upper(rtrim(cOld))
   PU->(DbSetOrder(nOrder))
   PU->(DbGoTo(nRecno))
return nil
//_____________________________________________________________________________//

function GaClave( cGasto, oGet, nMode )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lReturn  := .f.
   local nRecno   := GA->( RecNo() )
   local nOrder   := GA->( OrdNumber() )
   local nArea    := Select()

   if Empty( cGasto )
      if nMode == 4
         RETURN .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         RETURN .f.
      endif
   endif

   SELECT GA
   GA->( DbSetOrder( 1 ) )
   GA->( DbGoTop() )

   if GA->( DbSeek( UPPER( cGasto ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lReturn := .f.
            MsgStop("Tipo de gasto existente.")
         Case nMode == 2
            if GA->( Recno() ) == nRecno
               lReturn := .t.
            else
               lReturn := .f.
               MsgStop("Tipo de gasto existente.")
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
         if MsgYesNo("Tipo de gasto inexistente. ¿ Desea darlo de alta ahora? ")
            lReturn := GaEdita( , 1, , , @cGasto )
         else
            lReturn := .f.
         endif
      endif
   endif

   if lReturn == .f.
      oGet:cText( space(40) )
   else
      oGet:cText( cGasto )
   endif

   GA->( DbGoTo( nRecno ) )
   Select (nArea)
return lReturn
//_____________________________________________________________________________//

function GaApuntes( oGrid, oParent )
   local cGaCategor := GA->GaCategor
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT AP
	AP->(DbSetOrder(7))
	AP->(DbGoTop())
   if ! AP->(DbSeek(upper(cGaCategor)))
      MsgStop("El tipo de gasto no aparece en ningún apunte.")
      RETURN NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Apuntes del tipo de gasto: '+rtrim(cGaCategor) OF oParent
   oDlg:SetFont(oApp():oFont)

   AP->(DbGoTop())
   do while ! AP->(EOF())
      if upper(AP->ApCatGast) == upper(cGaCategor)
         aadd(aBrowse, { AP->ApFecha, AP->ApActivida, AP->ApConcepto, AP->ApImpTotal, AP->(Recno()) })
      endif
      AP->(DbSkip())
   enddo
   ASort( aBrowse,,, { |aApu1, aApu2| dtos(aApu1[1]) < dtos(aApu2[1]) } )
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:bClrRowFocus := { || { oApp():cClrGas, oApp():nClrHL } }	 
	oBrowse:bClrSelFocus := { || { oApp():cClrgas, oApp():nClrHL } }
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

   SELECT GA
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return NIL
//_____________________________________________________________________________//

function GaPresupuestos( oGrid, oParent )
   local cGaCategor := GA->GaCategor
   local oDlg, oBrowse, oCol
   local aBrowse := {}

	SELECT PU
	PU->(DbSetOrder(6))
	PU->(DbGoTop())
   if ! PU->(DbSeek(upper(cGaCategor)))
      MsgStop("El tipo de gasto no aparece en ningún presupuesto.")
      RETURN NIL
   endif

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'DLG_DOCUMENTOS'    ;
      TITLE 'Presupuestos del tipo de gasto: '+rtrim(cGaCategor) OF oParent
   oDlg:SetFont(oApp():oFont)

   PU->(DbGoTop())
   do while ! PU->(EOF())
      if upper(PU->PuCatGast) == upper(cGaCategor)
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

   SELECT GA
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return NIL

//_____________________________________________________________________________//

function GaImprime( oGrid )
   local nRecno   := GA->(Recno())
   local nOrder   := GA->(OrdSetFocus())
   local aCampos  := { "GaCategor" }
   local aTitulos := { "Tipo de gasto" }
   local aWidth   := { 40 }
   local aShow    := { .t. }
   local aPicture := { "NO" }
   local aTotal   := { .f. }
   local oInforme

   Select GA
   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "GA" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
      GA->(DbGoTop())
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
                  oInforme:oReport:Say(1, 'Total tipos de gasto: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
                  oInforme:oReport:EndLine() )
      oInforme:End(.t.)
      GA->(DbGoTo(nRecno))
   endif

   oGrid:Refresh()
   oGrid:SetFocus( .t. )
   oApp():nEdit --
return nil

//_____________________________________________________________________________//

function GaIsDbfEmpty()

   local lReturn := .f.

   if GA->( ordKeyVal() ) == nil
      msgStop( i18n( "No hay ningún gasto registrado." ) )
      lReturn := .t.
   endif

RETURN lReturn

function GaList( aList, cData, oSelf )
   local aNewList := {}
   GA->( dbSetOrder(1) )
   GA->( dbGoTop() )
   while ! GA->(Eof())
      if at(Upper(cdata), Upper(GA->GaCategor)) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { GA->GaCategor } )
      endif 
      GA->(DbSkip())
   enddo
return aNewlist
// _____________________________________________________________________________//

FUNCTION Ga1Mas( cGasto, cTipo, nImporte )

   LOCAL nGaRecno := GA->( RecNo() )
   LOCAL nGaOrder := GA->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT GA
   GA->( ordSetFocus( 1 ) )
   GA->( dbGoTop() )
   IF GA->( dbSeek( Upper( cGasto ) ) )
      IF cTipo == 'A'
         REPLACE GA->GaApuntes WITH GA->GaApuntes + 1
         REPLACE GA->GaApSuma WITH GA->GaApSuma + nImporte 
      ELSEIF cTipo == 'P'
         REPLACE GA->GaPresupu WITH GA->GaPresupu + 1
         REPLACE GA->GaPrSuma WITH GA->GaPrSuma + nImporte
      ENDIF
   ELSEIF ! Empty(cGasto)
      MsgAlert( 'Tipo de gasto no encontrado.' )
   ENDIF
   GA->( dbCommit() )
   GA->( ordSetFocus( nGaOrder ) )
   GA->( dbGoto( nGaRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION Ga1Menos( cGasto, cTipo, nImporte )

   LOCAL nGaRecno := GA->( RecNo() )
   LOCAL nGaOrder := GA->( ordNumber() )
   LOCAL cAlias   := Alias()

   SELECT GA
   GA->( ordSetFocus( 1 ) )
   GA->( dbGoTop() )
   IF GA->( dbSeek( Upper( cGasto ) ) )
      IF cTipo == 'A'
         REPLACE GA->GaApuntes WITH GA->GaApuntes - 1
         REPLACE GA->GaApSuma  WITH GA->GaApSuma - nImporte
      ELSEIF cTipo == 'P'
         REPLACE GA->GaPresupu WITH GA->GaPresupu - 1
         REPLACE GA->GaPrSuma  WITH GA->GaPrSuma + nImporte
      ENDIF
   ELSEIF ! Empty(cGasto)
      MsgAlert( 'Tipo de gasto no encontrado.' )
   ENDIF
   GA->( dbCommit() )
   GA->( ordSetFocus( nGaOrder ) )
   GA->( dbGoto( nGaRecno ) )
   SELECT ( cAlias )

   RETURN NIL
// _____________________________________________________________________________//
