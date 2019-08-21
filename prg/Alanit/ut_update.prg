/*
   Actualización de aplicaciones via FTP
   (c) 2008 Biel Maimo bmaimo@gmail.com - bielsys.blogspot.com
   FileTimes. basado sobre fuente publicacdo en foro FiveWin por Manuel Mercado
   Time2Sec De contrib de Harbour HbCt
*/
#include "FiveWin.ch"
STATIC cDirlocal //Directorio local del ejecutable
FUNCTION Main()
   Set Date ITALIAN
   cDirLocal:=cFilePath( GetModuleFileName( GetInstance() ) )
   ChkUpdFtp( '192.168.0.1','/UpdFtp/')
   MsgInfo('Ejecutando UpdFtp')
   //.... Resto de nuestro programa
RETURN NIL

FUNCTION ChkUpdFtp( cIp, cFolder )
LOCAL oInternet,oFtp
   LOCAL nSize1,nSize2,dDate1,dDate2,cTime1,cTmie2
   LOCAL aFiles:={},cPar,cFile
   IF !Empty(cIP) .AND. !Empty(cFolder) .AND. File(cDirLocal+'ActVer.exe')
      oInternet := tInternet():New()
      oFtp      := tFtp():New(cIp,oInternet,'usuario','contraseña')
      IF !Empty( oFtp:hFtp)
         cFile:=GetModuleFileName( GetInstance() )
         aFiles:=oFtp:Directory(cFolder+'*'+SubStr(cFileName( cFile ),2) )
         //---Fichero actual
         aTime := FileTimes( cFile, 1 )
         dDate1:= CToD(Str( aTime[ 3 ], 2 ) + "/" + StrZero( aTime[ 2 ], 2 ) + "/" + StrZero( aTime[ 1 ], 4 ))
         cTime1:= StrZero( aTime[ 4 ], 2 ) + ":" + StrZero( aTime[ 5 ], 2 ) + ":" + StrZero( aTime[ 6 ], 2 )
         nSize1:= FileSize( cFile )
         //---Fichero candiato a ser nuevo---
         dDate2:= aFiles[1,3]
         cTime2:= aFiles[1,4]
         nSize2:= aFiles[1,2]
         IF Len(aFiles)>0
            IF (dDate1<dDate2).OR.;
               ( dDate1==dDate2 .AND. (TimeToSec(cTime1)<TimeToSec(cTime2)))
               IF MsgYesno('Existe una nueva versión disponible, ¿desea descargarla?')
                  IF Actualiza(oFtp,Lower(cFolder+aFiles[1,1]),aFiles[1,1],nSize2)
                     oFtp:END()
                     oInternet:END()
                     WinExec( cDirlocal+'ActVer.exe '+ cFile )
                     PostQuitMessage(0)
                     QUIT
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
      oFtp:END()
      oInternet:END()
   ENDIF
RETURN NIL
//------------------------------------------------------
STATIC FUNCTION Actualiza(oFtp,cSource,cFileName,nSize)
   LOCAL oDlg, oSay, oBtnCancel, oMeter, lEnd:=.F., nAmount, lOk:=.F., lValRet:=.F.
   DEFINE DIALOG oDlg TITLE "Actualizando aplicación" FROM 0,0 TO 10,50
   @ 01,03 SAY oSay  PROMPT "Bytes copiados:" OF oDlg
   @ 02,01 METER oMeter VAR nAMount SIZE 180,20 TOTAL nSize OF oDlg

   @ 03,12 BUTTON oBtnCancel PROMPT "&Cancelar" ACTION ( lEnd := .t., SysRefresh(), oDlg:End() )
   oDlg:bStart := { || lOk:=GetFile(  cSource,nSize,oSay, oMeter,@lEnd, oDlg, oFTP ),;
                       oBtnCancel:SetText( "&Ok" ),oDlg:END()  }
   ACTIVATE DIALOG oDlg CENTERED
   IF !lEnd .AND. lOk
      lValRet:=.T.
   ENDIF
RETURN lValRet
//----------------------------------------------------------------------------------------
STATIC FUNCTION GetFile( cSource,nSize, oSay, oMeter, lEnd, oDlg, oFtp )
   LOCAL oFile, hTarget, lValRet:=.F.
   LOCAL nBufSize,cBuffer,nBytes, nTotal:=0,nFile:=0
   nBufSize:=4096
   cBuffer:=Space(nBufSize)
*   oMeter:nTotal:=nSize
   hTarget := FCreate('tmp.exe')
   oFile := tFtpFile():New( cSource, oFtp )
   oFile:OpenRead()
   SysRefresh()
   WHILE  ( nBytes := Len( cBuffer := oFile:Read( nBufSize ) ) ) > 0 .and. ! lEnd
      FWrite( hTarget, cBuffer, nBytes )
      oSay:SetText( "Bytes copiados: " + ;
                     AllTrim( Str( nTotal += nBytes ) ) )
      oMeter:Set( nTotal )
      SysRefresh()
   END
   FClose( hTarget )
   oFile:End()
RETURN nTotal==nSize
///// FUNCIONES PARA CONVERIR HORA A SEGUNDOS, Y VICEVERSA
//---------------------------------
STATIC FUNCTION  TIMETOSEC( cTime )
local nSec := 0, nLen, i, aLim, aMod, nInd, n
if cTime == NIL
   nSec := seconds()
elseif HB_ISCHAR( cTime )
   nLen := len( cTime )
   if ( nLen + 1 ) % 3 == 0 .and. nLen <= 11
      nInd := 1
      aLim := { 24, 60, 60, 100 }
      aMod := { 3600, 60, 1, 1/100 }
      for i := 1 to nLen step 3
         if isdigit( substr( cTime, i,     1 ) ) .and. ;
            isdigit( substr( cTime, i + 1, 1 ) ) .and. ;
            ( i == nLen - 1 .or. substr( cTime, i + 2, 1 ) == ":" ) .and. ;
            ( n := val( substr( cTime, i, 2 ) ) ) < aLim[ nInd ]
            nSec += n * aMod[ nInd ]
         else
            nSec := 0
            exit
         endif
         ++nInd
      next
   endif
endif
return round( nSec, 2) /* round FL val to be sure that you can compare it */

#pragma BEGINDUMP
#include <Windows.h>
#include <mapiwin.h>
#include <hbApi.h>
                     //nTime 1=Last Update, 2=Last Acces, 3=Creation, defecto last update
HB_FUNC( FILETIMES ) // params cFileName, nTime --> { nYear, nMonth, nDay, nHour, nMin, nSec }
{
   LPSTR cFileName = hb_parc( 1 ) ;
   int nTime       = ( ISNUM( 2 ) ? hb_parni( 2 ) :  1 ) ; // defaults to 1

   FILETIME ftCreate, ftAccess, ftWrite ;
   SYSTEMTIME stTime ;
   BOOL bRet ;
   HANDLE hFile = CreateFile( cFileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0 ) ;

   if( ! hFile )
      return ;

   GetFileTime( (HANDLE) hFile, &ftCreate, &ftAccess, &ftWrite ) ;

   switch( nTime )
   {
      case 1 : // last update
         FileTimeToSystemTime( &ftWrite, &stTime ) ;
         break ;
      case 2 : // last access
         FileTimeToSystemTime( &ftAccess, &stTime ) ;
         break ;
      case 3 : // creation
         FileTimeToSystemTime( &ftCreate, &stTime ) ;
         break ;
      default : // last update
         FileTimeToSystemTime( &ftWrite, &stTime ) ;
         break ;
   }

   SystemTimeToTzSpecificLocalTime( NULL, &stTime, &stTime ) ;
   CloseHandle( hFile ) ;
   hb_reta( 6 ) ;
   hb_storni( stTime.wYear,   -1, 1 ) ;
   hb_storni( stTime.wMonth,  -1, 2 ) ;
   hb_storni( stTime.wDay,    -1, 3 ) ;
   hb_storni( stTime.wHour,   -1, 4 ) ;
   hb_storni( stTime.wMinute, -1, 5 ) ;
   hb_storni( stTime.wSecond, -1, 6 ) ;
}

#define FA_RDONLY           1   /* R */
#define FA_HIDDEN           2   /* H */
#define FA_SYSTEM           4   /* S */
#define FA_LABEL            8   /* V */
#define FA_DIREC           16   /* D */
#define FA_ARCH            32   /* A */
#define FA_NORMAL           0
HB_FUNC(FILESIZE)

   {
   LPCTSTR szFile;
   DWORD dwFlags=FILE_ATTRIBUTE_ARCHIVE;
   HANDLE hFind;
   WIN32_FIND_DATA  hFilesFind;
      int iAttr;
      if (hb_pcount() >=1){
         szFile=hb_parc(1);
         if (ISNUM(2))      {
            iAttr=hb_parnl(2);
         }
         else{
         iAttr=63;
         }
            if( iAttr & FA_RDONLY )
               dwFlags |= FILE_ATTRIBUTE_READONLY;

            if( iAttr & FA_HIDDEN )
               dwFlags |= FILE_ATTRIBUTE_HIDDEN;

            if( iAttr & FA_SYSTEM )
               dwFlags |= FILE_ATTRIBUTE_SYSTEM;
            if( iAttr & FA_NORMAL )
               dwFlags |=    FILE_ATTRIBUTE_NORMAL;

            hFind = FindFirstFile(szFile,&hFilesFind);
                  if (hFind != INVALID_HANDLE_VALUE){
                      if (dwFlags & hFilesFind.dwFileAttributes) {
                         if(hFilesFind.nFileSizeHigh>0)
                              hb_retnl((hFilesFind.nFileSizeHigh*MAXDWORD)+hFilesFind.nFileSizeLow);
                         else
                              hb_retnl(hFilesFind.nFileSizeLow);
                       }
                   else
                           hb_retnl(-1);
                     }

         }
}

#pragma ENDDUMP

/*
   Actualización de aplicaciones
   (c) 2008 Biel Maimo bmaimo@gmail.com - bielsys.blogspot.com
  */
#include "FiveWin.Ch"

FUNCTION main(cFile)
//------------------------------
   LOCAL cFileName
   IF cFile!=NIL
      SysWait(.7)
      FErase(cFile)
      cFileName:=cFileName(cFile)
      FRename('tmp.exe',cFilename)
      WinExec( cFileName )
      PostQuitMessage(0)
      QUIT
   ENDIF
RETURN NIL

FUNCTION RddSys(); RETURN NIL