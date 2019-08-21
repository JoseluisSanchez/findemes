#include <Windows.h>
#include "Extend.api"

#define OPTION_NONE         0
#define OPTION_OPEN_PDF		1
#define OPTION_RESET		2

UINT WINAPI I2PDF_AddImage( char * );
UINT WINAPI I2PDF_SetDPI( UINT );
UINT WINAPI I2PDF_MakePDF( char *, int, char *, UINT );
UINT WINAPI I2PDF_License( char * );

static HMODULE hModule = NULL;

/*
DLL32 Function I2PDF_AddImage(image as LPSTR);
AS LONG PASCAL FROM "I2PDF_AddImage" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_SetProducer(producer as LPSTR);
AS LONG PASCAL FROM "I2PDF_SetProducer" LIB "IMAGE2PDF.DLL"


DLL32 Function I2PDF_GetDLLVersion();
AS LONG PASCAL FROM "I2PDF_GetDLLVersion" LIB "IMAGE2PDF.DLL"


DLL32 Function I2PDF_License(code As LPSTR);
AS LPSTR PASCAL FROM "I2PDF_License" LIB "IMAGE2PDF.DLL"


DLL32 Function I2PDF_MetaImageMaxMP(maxmp as LONG);
AS LONG PASCAL FROM "I2PDF_MetaImageMaxMP" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_DeleteImagesOnConvert();
AS VOID PASCAL FROM "I2PDF_DeleteImagesOnConvert" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_SetDPI(dpi as LONG);
AS LONG PASCAL FROM "I2PDF_SetDPI" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_MakePDF(output As LPSTR, options as LONG, @cBuffer As LPSTR, ;
   maxErrorTextSize As LONG);
AS LONG PASCAL FROM "I2PDF_MakePDF" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_SetPermissionPrint();
AS VOID PASCAL FROM "I2PDF_SetPermissionPrint" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_MetaImageMaxMP_Int(maxmp as LONG);
AS LONG PASCAL FROM "I2PDF_MetaImageMaxMP_Int" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_UseEMFDeviceSize();
AS VOID PASCAL FROM "I2PDF_UseEMFDeviceSize" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_MetaToNativePDF();
AS VOID PASCAL FROM "I2PDF_MetaToNativePDF" LIB "IMAGE2PDF.DLL"

DLL32 Function I2PDF_Log(logFilename As LPSTR, logLevel as LONG);
AS LONG PASCAL FROM "I2PDF_Log" LIB "IMAGE2PDF.DLL"
*/

//---------------------------------------------------------------------------//

UINT ShowError(char *which, UINT iErr)
{
	char message[200];

	wsprintf(message, "%s returned error %d", which, iErr);

	MessageBox(NULL, message, "Error Returned From Image2PDF DLL", MB_OK | MB_ICONERROR);

	return iErr;
}

//---------------------------------------------------------------------------//

CLIPPER I2PDF_ADDIMAGE_C3( void )
{

    LONG hResult;
    UINT iErr;

    LPSTR lpImage   = _parc( 1 );

    if( hModule == NULL )
        hModule = LoadLibrary( "IMAGE2PDF.DLL" );

    iErr            = I2PDF_AddImage( lpImage );

    if( hModule != NULL )
    {
        FreeLibrary( hModule );
        hModule = NULL;
    }

    _retnl( iErr );

}

//---------------------------------------------------------------------------//

CLIPPER I2PDF_SETDPI_C3( void )
{

    LONG hResult;
    UINT iErr;

    LONG lDpi       = _parnl( 1 );

    if( hModule == NULL )
        hModule = LoadLibrary( "IMAGE2PDF.DLL" );

    iErr            = I2PDF_SetDPI( lDpi );

    if( hModule != NULL )
    {
        FreeLibrary( hModule );
        hModule = NULL;
    }

    _retnl( iErr );

}

//---------------------------------------------------------------------------//

CLIPPER I2PDF_MAKEPDF_C3( void )
{

    LONG hResult;
    UINT iErr;

    char errorText[1024];

    LPSTR lpOutput  = _parc( 1 );

    if( hModule == NULL )
        hModule = LoadLibrary( "IMAGE2PDF.DLL" );

    iErr            = I2PDF_MakePDF( lpOutput, OPTION_OPEN_PDF, errorText, sizeof( errorText ) );

    if (iErr)
	{
		if (iErr == 3)
			ShowError(errorText, iErr);
		else
			ShowError("I2PDF_MakePDF", iErr);
	}

    if( hModule != NULL )
    {
        FreeLibrary( hModule );
        hModule = NULL;
    }

    _retnl( iErr );

}

//---------------------------------------------------------------------------//

CLIPPER I2PDF_LICENSE_C3( void )
{

    UINT iErr;

    char errorText[1024];

    if( hModule == NULL )
        hModule = LoadLibrary( "IMAGE2PDF.DLL" );

    iErr            = I2PDF_License( "IPD-TBFZ-1OTB4-5B0T8K-28VD0WC" );

    if (iErr)
	{
		if (iErr == 3)
			ShowError(errorText, iErr);
		else
            ShowError("I2PDF_License", iErr);
	}

    if( hModule != NULL )
    {
        FreeLibrary( hModule );
        hModule = NULL;
    }

    _retnl( iErr );

}