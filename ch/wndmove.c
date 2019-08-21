#include <WinTen.h>
#include <Windows.h>
#include <ClipApi.h>

HANDLE CursorWait( void );
HANDLE CursorArrow( void );

static far char NotEnough[] = "Not enough memory";
static far char Error[]     = "Error";

//----------------------------------------------------------------------------//

CLIPPER MOVEWINDOW( PARAMS )
{
   HWND hWnd   = ( HWND ) _parnl( 1 );
   int wRow    = _parnl( 2 );
   int wCol    = _parnl( 3 );
   int wWidth  = _parnl( 4 );
   int wHeight = _parnl( 5 );
   RECT rct;

   if( ! _parnl( 4 ) )
   {
      GetWindowRect( hWnd, &rct );
      wWidth  = rct.right - rct.left;
      wHeight = rct.bottom - rct.top;
   }

   if( IsWindow( hWnd ) )
      _retl( MoveWindow( hWnd, wCol, wRow, wWidth, wHeight, _parl( 6 ) ) );
   else
      _retl( FALSE );
}

//----------------------------------------------------------------------------//

CLIPPER WNDCOPY( PARAMS )  //  hWnd        Copies any Window to the Clipboard!
{
   HWND hWnd = ( HWND ) _parnl( 1 );
   BOOL bAll = _parl( 2 );
   HDC  hDC  = GetDC( hWnd );
   WORD wX, wY;
   HDC  hMemDC;
   RECT rct;
   HBITMAP hBitmap, hOldBmp;
   BOOL bColor = _parl( 3 );

   CursorWait();

   if( bAll )
      GetWindowRect( hWnd, &rct );
   else
      GetClientRect( hWnd, &rct );

   wX = rct.right - rct.left + 1;
   wY = rct.bottom - rct.top + 1;

   if( GlobalCompact( 0 ) < ( wX * wY ) / 8 )
      MessageBox( 0, NotEnough, Error, 0 );
   else
   {
      hMemDC  = CreateCompatibleDC( hDC );

      if( bColor )
         hBitmap = CreateCompatibleBitmap( hDC, wX, wY );
      else
         hBitmap = CreateCompatibleBitmap( hMemDC, wX, wY );

      hOldBmp = ( HBITMAP ) SelectObject( hMemDC, hBitmap );

      BitBlt( hMemDC, 0, 0, wX, wY, hDC, 0, 0, SRCCOPY );

      OpenClipboard( hWnd );
      EmptyClipboard();
      SetClipboardData( CF_BITMAP, hBitmap );
      CloseClipboard();

      SelectObject( hMemDC, hOldBmp );
      DeleteDC( hMemDC );
   }
   ReleaseDC( hWnd, hDC );
   CursorArrow();
}

//----------------------------------------------------------------------------//

#ifdef __HARBOUR__
   CLIPPER BRINGWINDOWTOTOP( PARAMS ) // ( hWnd )  --> lSuccess
#else
   CLIPPER BRINGWINDO( PARAMS ) // WTOTOP( hWnd )  --> lSuccess
#endif
{
   _retl( BringWindowToTop( ( HWND ) _parnl( 1 ) ) );
}

//----------------------------------------------------------------------------//

CLIPPER SETMINMAX( PARAMS ) // ( pMinMaxInfo, aMinMaxInfo ) --> 0
{
   MINMAXINFO * pMinMaxInfo = ( MINMAXINFO * ) _parnl( 1 );

   #ifdef __FLAT__
      #ifndef __HARBOUR__
         #define _parnl( x, y ) PARNL( x, params, y )
      #endif
   #endif

   pMinMaxInfo->ptMaxSize.x      = _parnl( 2, 1 );
   pMinMaxInfo->ptMaxSize.y      = _parnl( 2, 2 );
   pMinMaxInfo->ptMaxPosition.x  = _parnl( 2, 3 );
   pMinMaxInfo->ptMaxPosition.y  = _parnl( 2, 4 );
   pMinMaxInfo->ptMinTrackSize.x = _parnl( 2, 5 );
   pMinMaxInfo->ptMinTrackSize.y = _parnl( 2, 6 );
   pMinMaxInfo->ptMaxTrackSize.x = _parnl( 2, 7 );
   pMinMaxInfo->ptMaxTrackSize.y = _parnl( 2, 8 );

   #ifdef __FLAT__
      #ifndef __HARBOUR__
         #define _parnl( x ) PARNL( x, params )
      #endif
   #endif

   _retni( 0 );
}

//----------------------------------------------------------------------------//

CLIPPER WNDSETSIZE( PARAMS ) // ( hWnd, nWidth, nHeight, lRepaint ) --> lOk
{
   HWND hWnd    = ( HWND ) _parnl( 1 );
   WORD wWidth  = _parni( 2 );
   WORD wHeight = _parni( 3 );
   RECT rct, rctParent;
   POINT pt;

   GetWindowRect( hWnd, &rct );

   if( ! wWidth )
      wWidth = rct.right - rct.left;

   if( ! wHeight )
      wHeight = rct.bottom - rct.top;

   if( GetWindowLong( hWnd, GWL_STYLE ) && WS_CHILD )
   {
      pt.x = rct.left;
      pt.y = rct.top;
      ScreenToClient( GetParent( hWnd ), &pt );
      rct.left = pt.x;
      rct.top  = pt.y;
   }

   _retl( MoveWindow( hWnd, rct.left, rct.top, wWidth, wHeight, _parl( 4 ) ) );
}

//----------------------------------------------------------------------------//

CLIPPER WNDWIDTH( PARAMS )  // ( hWnd [, nNewWidth ] ) --> nWidth
{
   RECT rct;
   HWND hWnd = ( HWND ) _parnl( 1 );
   POINT pt;
   WORD wWidth, wHeight;

   GetWindowRect( hWnd, &rct );
   wWidth  = rct.right - rct.left;
   wHeight = rct.bottom - rct.top;

   if( GetWindowLong( hWnd, GWL_STYLE ) && WS_CHILD )
   {
      pt.x = rct.left;
      pt.y = rct.top;
      ScreenToClient( GetParent( hWnd ), &pt );
      rct.left = pt.x;
      rct.top  = pt.y;
   }

   if( PCOUNT() > 1 )
      MoveWindow( hWnd, rct.left, rct.top, _parni( 2 ),
                  wHeight, TRUE );
   else
      _retni( wWidth );
}

//----------------------------------------------------------------------------//

CLIPPER WNDHEIGHT( PARAMS )  // ( hWnd [, nNewHeight ] ) --> nHeight
{
   RECT rct;
   HWND hWnd = ( HWND ) _parnl( 1 );
   POINT pt;
   WORD wWidth, wHeight;
   BOOL bSet = ( PCOUNT() > 1 );
   WORD wNewHeight = _parni( 2 );

   GetWindowRect( hWnd, &rct );
   wWidth  = rct.right - rct.left;
   wHeight = IF( bSet, wNewHeight, rct.bottom - rct.top );

   if( GetWindowLong( hWnd, GWL_STYLE ) && WS_CHILD )
   {
      pt.x = rct.left;
      pt.y = rct.top;
      ScreenToClient( GetParent( hWnd ), &pt );
      rct.left = pt.x;
      rct.top  = pt.y;
   }

   if( PCOUNT() > 1 )
      MoveWindow( hWnd, rct.left, rct.top, wWidth,
                  wHeight, TRUE );
   else
      _retni( wHeight );
}

//----------------------------------------------------------------------------//

CLIPPER WNDTOP( PARAMS )  // ( hWnd [, nNewTop ] ) --> nNewTop
{
   RECT rct;
   HWND hWnd = ( HWND ) _parnl( 1 );
   POINT pt;
   WORD wWidth, wHeight;
   BOOL bSet = ( PCOUNT() > 1 );
   WORD wNewTop = _parni( 2 );

   if( ! hWnd )
      return;

   GetWindowRect( hWnd, &rct );
   wWidth  = rct.right - rct.left;
   wHeight = rct.bottom - rct.top;

   if( GetWindowLong( hWnd, GWL_STYLE ) && WS_CHILD )
   {
      pt.x = rct.left;
      pt.y = IF( bSet, wNewTop, rct.top );
      ScreenToClient( GetParent( hWnd ), &pt );
      rct.left = pt.x;
      rct.top  = pt.y;
   }

   if( bSet )
      MoveWindow( hWnd, rct.left, wNewTop, wWidth,
                  wHeight, TRUE );
   else
      _retni( rct.top );
}

//----------------------------------------------------------------------------//

CLIPPER WNDBOTTOM( PARAMS )  // ( hWnd [, nNewBottom ] ) --> nNewBottom
{
   RECT rct;
   HWND hWnd = ( HWND ) _parnl( 1 );
   WORD wWidth, wHeight;
   BOOL bSet = ( PCOUNT() > 1 );

   if( ! hWnd )
      return;

   GetWindowRect( hWnd, &rct );

   if( bSet )
   {
      wWidth  = rct.right - rct.left;
      wHeight = _parni( 2 ) - rct.top;
      MoveWindow( hWnd, rct.left, rct.top, wWidth,
                  wHeight, TRUE );
   }
   else
      _retni( rct.bottom );
}

//----------------------------------------------------------------------------//

CLIPPER WNDLEFT( PARAMS )  // ( hWnd [, nNewLeft ] ) --> nNewLeft
{
   RECT rct;
   HWND hWnd = ( HWND ) _parnl( 1 );
   POINT pt;
   WORD wWidth, wHeight;
   BOOL bSet = ( PCOUNT() > 1 );
   WORD wNewLeft = _parni( 2 );

   if( ! hWnd )
      return;

   GetWindowRect( hWnd, &rct );
   wWidth   = rct.right - rct.left;
   wHeight  = rct.bottom - rct.top;

   if( GetWindowLong( hWnd, GWL_STYLE ) && WS_CHILD )
   {
      pt.x = IF( bSet, wNewLeft, rct.left );
      pt.y = rct.top;
      ScreenToClient( GetParent( hWnd ), &pt );
      rct.left = pt.x;
      rct.top  = pt.y;
   }

   if( bSet )
      MoveWindow( hWnd, wNewLeft, rct.top, wWidth,
                  wHeight, TRUE );
   else
      _retni( rct.left );
}

//----------------------------------------------------------------------------//

CLIPPER WNDADJTOP( PARAMS ) // ( hWnd )
{
   HWND hControl = ( HWND ) _parnl( 1 );
   HWND hParent  = GetParent( hControl );
   RECT rctParent, rctControl;
   WORD wHeight;

   GetWindowRect( hControl, &rctControl );
   GetClientRect( hParent, &rctParent );
   wHeight = rctControl.bottom - rctControl.top;

   MoveWindow( hControl, -1, -1,
           rctParent.right - rctParent.left + 2, wHeight, TRUE );
}

//----------------------------------------------------------------------------//

#ifdef __HARBOUR__
   CLIPPER WNDADJBOTTOM( PARAMS ) // ( hWnd )
#else
   CLIPPER WNDADJBOTT( PARAMS ) // OM( hWnd )
#endif
{
   HWND hControl = ( HWND ) _parnl( 1 );
   HWND hParent  = GetParent( hControl );
   RECT rctParent, rctControl;
   WORD wHeight;

   GetWindowRect( hControl, &rctControl );
   GetClientRect( hParent, &rctParent );
   wHeight = rctControl.bottom - rctControl.top;

   MoveWindow( hControl, -1, rctParent.bottom - wHeight + 1 -
               ( GetParent( GetParent( hControl ) ) != 0 ),
               rctParent.right - rctParent.left + 2, wHeight, TRUE );
}

//----------------------------------------------------------------------------//

#ifdef __HARBOUR__
   CLIPPER WNDADJCLIENT( PARAMS ) // ( hWnd, hTop, hBottom, hLeft, hRight, bMdiClient, nBevel )
#else
   CLIPPER WNDADJCLIE( PARAMS ) // NT( hWnd, hTop, hBottom, hLeft, hRight, bMdiClient, nBevel )
#endif
{
   HWND hControl   = ( HWND ) _parnl( 1 );
   HWND hTop       = ( HWND ) _parnl( 2 );
   HWND hBottom    = ( HWND ) _parnl( 3 );
   HWND hLeft      = ( HWND ) _parnl( 4 );
   HWND hRight     = ( HWND ) _parnl( 5 );
   BOOL bMdiClient = _parl( 6 );
   LONG lBevel     = _parnl( 7 );
   RECT rct;
   LONG wTopHeight = 0, wBottomHeight = 0;
   LONG wLeftWidth = 0, wRightWidth = 0;
   BOOL bChildChild = ( GetParent( GetParent( hControl ) ) != 0 );

   if( hTop )
   {
      GetWindowRect( hTop, &rct );
      wTopHeight = rct.bottom - rct.top;
   }

   if( hBottom )
   {
      GetWindowRect( hBottom, &rct );
      wBottomHeight = rct.bottom - rct.top;
   }

   if( hLeft )
   {
      GetWindowRect( hLeft, &rct );
      wLeftWidth = rct.right - rct.left - 1;
   }

   if( hRight )
   {
      GetWindowRect( hRight, &rct );
      wRightWidth = rct.right - rct.left;
   }

   GetClientRect( GetParent( hControl ), &rct );

   if ( lBevel > 0 )
   {
      wLeftWidth    += lBevel;
      wTopHeight    += lBevel;
      wBottomHeight += lBevel;
      wRightWidth   += lBevel;
      MoveWindow( hControl, wLeftWidth, wTopHeight,
                 rct.right - rct.left - wLeftWidth - wRightWidth,
                 rct.bottom - rct.top - wTopHeight  - wBottomHeight , TRUE );
      return;
   }

   if( ! bChildChild )
      MoveWindow( hControl, wLeftWidth - 1,
                 wTopHeight - IF( wTopHeight != 0, 2 - bMdiClient, 1 ),
                 rct.right - rct.left - wLeftWidth - wRightWidth + 2,
                 rct.bottom - rct.top - wTopHeight +
                 ( wTopHeight != 0 ) - wBottomHeight + 3 +
                 IF( ! wTopHeight && ! bMdiClient, 1, 0 ) -
                 IF( bMdiClient, 2, 1 ),
                 TRUE );
   else
      MoveWindow( hControl, wLeftWidth, wTopHeight -
                 IF( wTopHeight != 0, 2, 0 ),
                 rct.right - rct.left - wLeftWidth - wRightWidth,
                 rct.bottom - rct.top - wTopHeight + ( wTopHeight != 0 ) -
                 wBottomHeight + 1, TRUE );
}

//----------------------------------------------------------------------------//

CLIPPER WNDADJLEFT( PARAMS ) // ( hWnd, hTop, hBottom )
{
   HWND hControl = ( HWND ) _parnl( 1 );
   HWND hWnd;
   RECT rct, rctCtrl;
   WORD wTopHeight = 0, wBottomHeight = 0;

   if( hWnd = ( HWND ) _parnl( 2 ) )
   {
      GetWindowRect( hWnd, &rct );
      wTopHeight = rct.bottom - rct.top;
   }

   if( hWnd = ( HWND ) _parnl( 3 ) )
   {
      GetWindowRect( hWnd, &rct );
      wBottomHeight = rct.bottom - rct.top;
   }

   GetClientRect( GetParent( hControl ), &rct );
   GetWindowRect( hControl, &rctCtrl );

   MoveWindow( hControl, 0, wTopHeight - ( GetParent( GetParent( hControl ) ) != 0 ),
               rctCtrl.right - rctCtrl.left,
               rct.bottom - rct.top + 1 +
               ( ! GetParent( GetParent( hControl ) ) )
               - wTopHeight - wBottomHeight,
               TRUE );
}

//----------------------------------------------------------------------------//

#ifdef __HARBOUR__
   CLIPPER WNDADJRIGHT( PARAMS ) // ( hWnd, hTop, hBottom )
#else
   CLIPPER WNDADJRIGH( PARAMS ) // T( hWnd, hTop, hBottom )
#endif
{
   HWND hControl = ( HWND ) _parnl( 1 );
   HWND hWnd;
   RECT rct, rctCtrl;
   WORD wTopHeight = 0, wBottomHeight = 0;

   if( hWnd = ( HWND ) _parnl( 2 ) )
   {
      GetWindowRect( hWnd, &rct );
      wTopHeight = rct.bottom - rct.top;
   }

   if( hWnd = ( HWND ) _parnl( 3 ) )
   {
      GetWindowRect( hWnd, &rct );
      wBottomHeight = rct.bottom - rct.top;
   }

   GetClientRect( GetParent( hControl ), &rct );
   GetWindowRect( hControl, &rctCtrl );

   MoveWindow( hControl, rct.right - ( rctCtrl.right - rctCtrl.left ),
               wTopHeight - ( GetParent( GetParent( hControl ) ) != 0 ),
               rctCtrl.right - rctCtrl.left,
               rct.bottom - rct.top + 1 +
               ( ! GetParent( GetParent( hControl ) ) )
               - wTopHeight - wBottomHeight,
               TRUE );
}

//----------------------------------------------------------------------------//
