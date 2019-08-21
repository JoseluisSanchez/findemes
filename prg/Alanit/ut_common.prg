# include "Fivewin.ch"
# include "Report.ch"
# include "DbStruct.ch"
# include "xBrowse.ch"

function AdjustWnd( oBtn, nWidth, nHeight )
   local nMaxWidth, nMaxHeight
   local aPoint

   aPoint := { oBtn:nTop + oBtn:nHeight(), oBtn:nLeft }
   clientToScreen( oBtn:oWnd:hWnd, @aPoint )

   nMaxWidth  := GetSysMetrics(0)
   nMaxHeight := GetSysMetrics(1)

   if  aPoint[2] + nWidth > nMaxWidth
      aPoint[2] := nMaxWidth -  nWidth
   endif

   if  aPoint[1] + nHeight > nMaxHeight
      aPoint[1] := nMaxHeight - nHeight
   endif
return aPoint

/*_____________________________________________________________________________*/

function Setini( cIni, cSection, cEntry, xVar )
   local oIni

   default cIni := oApp():cIniFile

   INI oIni FILE cIni
   set SECTION cSection ;
      ENTRY cEntry      ;
      to xVar           ;
      OF oIni
   ENDINI

return nil

/*_____________________________________________________________________________*/

function Getini( cIni, cSection, cEntry, xDefault )
   local oIni
   local xVar := xDefault

   default cIni := oApp():cIniFile

   INI oIni FILE cIni
   get xVar            ;
      SECTION cSection ;
      ENTRY cEntry     ;
      default xDefault ;
      OF oIni
   ENDINI

return xVar

/*_____________________________________________________________________________*/

function Goweb( cUrl )

   cUrl := Alltrim( cUrl )
   if cURL == ""
      Msgstop( "La dirección web está vacia." )
      return nil
   endif

   if ! Iswinnt()
      Winexec( "start urlto:" + cURL, 0 )
   else
      Winexec( "rundll32.exe url.dll,FileProtocolHandler " + cURL )
   endif

return nil

/*_____________________________________________________________________________*/

function Gomail( cMail )

   cMail := Alltrim( cMail )
   if cMail == ""
      Msgstop( "La dirección de e-mail está vacia." )
      return nil
   endif

   if ! Iswinnt()
      Winexec( "start mailto: " + cMail, 0 )
   else
      Winexec( "rundll32.exe url.dll,FileProtocolHandler mailto:" + cMail )
   endif

return nil
/*_____________________________________________________________________________*/

function Gofile( cFile )

   cFile := Alltrim( cFile )
   if cFile == ""
      Msgstop( "La ruta del fichero está vacia." )
      return nil
   endif

   Winexec( "rundll32.exe url.dll,FileProtocolHandler " + cFile )

return nil

/*_____________________________________________________________________________*/

function Valempty( cDato, oGet )

   if Empty( cDato )
      Msgstop( I18n( "Es obligatorio rellenar este campo." ) )
      oGet:Setfocus()
      return .f.
   end if

return .t.

/*_____________________________________________________________________________*/

function Dlgcoors( oWnd )
   local aCoor[ 7 ]

   aCoor[ 1 ] := 2 * Getsysmetrics( 4 ) + ; // SM_CYCAPTION
   Getsysmetrics( 15 )  + ;  // SM_CYMENU
   2 * Getsysmetrics( 6 ) + ; // SM_CYBORDER
   oWnd:oBar:nHeight  + ;
      oWnd:oMsgBar:nHeight ;
      + 10              // factor de corrección puesto a ojo

   aCoor[ 2 ] := 2 * Getsysmetrics( 5 )   ;  // SM_CXBORDER
   + 12                    // igual que antes

   aCoor[ 3 ] := Getsysmetrics( 4 )  + ; // SM_CYCAPTION
   Getsysmetrics( 15 ) + ;  // SM_CYMENU
   2 * Getsysmetrics( 6 ) + ; // SM_CYBORDER
   oWnd:oBar:nHeight

   aCoor[ 4 ] := 0
   aCoor[ 5 ] := 0
   aCoor[ 6 ] := oWnd:Nheight() - aCoor[ 1 ]
   aCoor[ 7 ] := oWnd:Nwidth()  - aCoor[ 2 ]

return aCoor

/*_____________________________________________________________________________*/

function O2a( cCadena ) ; return Oemtoansi( cCadena )

/*_____________________________________________________________________________*/

function Dlgcenter( oDlg, oWnd )

   oDlg:Center( oWnd )

return nil

/*_____________________________________________________________________________*/

function Swapuparray( aArray, nPos )
   local uTmp

   default nPos   := Len( aArray )

   if nPos <= Len( aArray ) .and. nPos > 1
      uTmp              := aArray[ nPos ]
      aArray[ nPos ]      := aArray[ nPos - 1 ]
      aArray[ nPos - 1 ] := uTmp
   end if

return nil

/*_____________________________________________________________________________*/

function Swapdwarray( aArray, nPos )
   local uTmp

   default nPos   := Len( aArray )

   if nPos < Len( aArray ) .and. nPos > 0
      uTmp              := aArray[ nPos ]
      aArray[ nPos ]      := aArray[ nPos + 1 ]
      aArray[ nPos + 1 ] := uTmp
   end if

return nil

/*_____________________________________________________________________________*/

function Findrec( cAlias, cData, cOrder )
   local nOrder := ( cAlias )->( Ordnumber() )
   local nRecno := ( cAlias )->( Recno()     )
   local lFind  := .f.

   ( cAlias )->( Ordsetfocus( cOrder ) )

   if ( cAlias )->( Dbseek( Upper( cData ) ) )
      lFind := .t.
   end if

   ( cAlias )->( Dbsetorder( nOrder ) )
   ( cAlias )->( Dbgoto( nRecno )     )

return lFind

/*_____________________________________________________________________________*/

function Btitulo( aTitulos, nFor )
return {|| aTitulos[ nFor ] }

function Bcampo( aCampos, nFor )
return ( Fieldwblock( aCampos[ nFor ], Select() ) )

function Bpicture( aPicture, nFor )
return aPicture[ nFor ]

function Barray( aArray, aCampos, nFor )
   local nIndex

   nIndex := Eval( Bcampo( aCampos, nFor ) )

return aArray[ Val( nIndex ) ]

/*_____________________________________________________________________________*/

function Agetfont( oWnd )
   local aFont    := {}
   local hDC      := Getdc( oWnd:hWnd )
   local nCounter := 0

   if hDC != 0

      while ( Empty( aFont := Getfontnames( hDC ) ) ) .and. ( ++nCounter ) < 5
      end while

      if Empty( aFont )
         Msgalert( I18n( "Error al obtener las fuentes." ) + CRLF + ;
            I18n( "Sólo podrá usar las fuentes predefinidas." ) )
      else
         Asort( aFont,,, {| x, y| Upper( x ) < Upper( y ) } )
      endif

   else

      Msgalert( I18n( "Error al procesar el manejador de la ventana." ) + CRLF + ;
         I18n( "Sólo podrá usar las fuentes predefinidas." ) )

   endif

   Releasedc( oWnd:hWnd, hDC )

return aFont

/*_____________________________________________________________________________*/

function Fillcmb( cAlias, cTag, aCmb, cField, nOrd, nRec, cVar )

   default nOrd := ( cAlias )->( Ordnumber() ), ;
      nRec := ( cAlias )->( Recno() )

   ( cAlias )->( Ordsetfocus( cTag ) )
   ( cAlias )->( Dbgotop() )
   do while ! ( cAlias )->( Eof() )
      Aadd( aCmb, ( cAlias )->&cField )
      ( cAlias )->( Dbskip() )
   end while
   ( cAlias )->( Dbsetorder( nOrd ) )
   ( cAlias )->( Dbgoto( nRec ) )
   cVar := Iif( Len( aCmb ) > 0, aCmb[ 1 ], "" )

return nil

/*_____________________________________________________________________________*/

function Getfieldwidth( cAlias, cField )
   local aDbf := ( cAlias )->( Dbstruct() )
   local i    := 0
   local nLen := Len( aDbf )
   local nPos := 0

   // encuentro la posición del campo a partir del nombre
   for i := 1 to nLen
      if aDbf[ i, 1 ] == cField
         nPos := i
         exit
      endif
   next

   // devuelvo el ancho del campo

return ( cAlias )->( Dbfieldinfo( DBS_LEN, nPos ) )

/*_____________________________________________________________________________*/

function Getdir( oGet )
   local cFile

   cFile := Cgetdir32()

   if ! Empty( cFile )
      oGet:cText := cFile + "\"
   endif

return nil

/*_____________________________________________________________________________*/

function Refreshcont( oCont, cAlias )

   oCont:cTitle :=  Tran( ( cAlias )->( Ordkeyno() ), '@E 999,999' ) + " / " + Tran( ( cAlias )->( Ordkeycount() ), '@E 999,999' )
   oCont:Refresh()

return nil

/*_____________________________________________________________________________*/

function Ascann( aArray, xExpr )
   local nFound := 0
   local i      := 0
   local nLen   := Len( aArray )

   if nLen > 0
      for i := 1 to nLen
         if aArray[ i ] == xExpr
            nFound++
         endif
      next
   endif

return nFound

/*_____________________________________________________________________________*/

function Getfreesystemresources() ; return 0

function Nptrword() ; return 0

/*_____________________________________________________________________________*/
