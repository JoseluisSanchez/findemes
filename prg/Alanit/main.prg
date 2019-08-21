#include "FiveWin.ch"
#include "SayRef.ch"
#include "Ribbon.ch"

request dbfcdx
request dbffpt

request hb_lang_es
request hb_codepage_eswin

memvar oApp
/*_____________________________________________________________________________*/
function Main()

   RddSetDefault( "DBFCDX" )
   HB_LANGSELECT( "ES" )
   HB_SETCODEPAGE( "ESWIN" )
   SetHandleCount( 100 )
	SetResDebug(.t.)

   SET DATE FORMAT "dd-mm-yyyy"
   SET DELETED     ON
   SET CENTURY     ON
   SET EPOCH TO    year( date() ) - 20
   SET MULTIPLE    OFF

	ut_override()
	
   WITH OBJECT oApp := TApplication():New()
      :Activate()
   END
	CheckRes()
return nil
/*_____________________________________________________________________________*/

class tApplication
   data cAppName
   data cVersion
   data cBuild
	data cEdicion

   data cUser
   data cCopyright
   data cUrl
   data cUrlDonativo
   data cEmail
   data cMsgBar

   data cIniFile
   data cTipFile
   data cEjercicio
   data cActividad
   data cDescripci
   data cExePath
	data cInvPath
	data cInvDbfPath
	data cInvZipPath
	data cInvXMLPath
	data cInvPdfPath
	data cInvXlsPath
	data cInvImgPath
   data cDbfPath
   data cZipPath
   data cXMLPath
   data cPdfPath
	data cXlsPath
   data cUpdPath
   data lDirect
	data lChkPeriod
	data lExcel
   data lCodAut
	data lRibbon
	data nRibbon

   data oWndMain
   data oImgList, oRebar, oToolbar
	data nBarHeight
   data oFont
   data oBar
   data oExit
   data oIcon
   data oMsgItem1
   data oMsgItem2
   data oMsgItem3
   data oDlg
   data oGrid
   data oGraph
   data oTab
   data oSplit
   data nEdit
   data cClrIng
   data cClrGas
	data cClrCc
	data nClrHL
	data nClrBar
	DATA nClrFilter
	data TheFull
	data nSeconds

   data cLanguage

   method New() CONSTRUCTOR

   method Activate()

   method BuildMenu()
   method BuildBtnBar()
	method BuildRibbon()

   method Close()

   method End() INLINE ( SetWinCoors( ::oWndMain, ::cIniFile ), ::oImgList:End(), ::oWndMain:End() )

   method InitCheck()
   method CheckFiles()
   method CheckUpdates()
   method ExitFromX()
   method ExitFromBtn()
   method ExitFromSource()
   method Config( oParent )

endclass
/*_____________________________________________________________________________*/

method New() CLASS tApplication

   local cAAAA := ""
   local cBBBB := ""
   local cCCCC := ""
   local cDDDD := ""
   local cEEEE := ""
   local cFFFF := ""
   local cGGGG1:= ""
	local cGGGG2:= ""
   local cHHHH := ""
   local cCfg  := ""
   local cUser := ""
   local oStatusBar

   ::cAppName  := i18n("findemes")
   ::cVersion  := " 3.73.a " // "2.02"
   ::cBuild    := "build 21.08.2019"
   ::cCopyright  := "© José Luis Sánchez Navarro 2019"
   ::cUrl        := "http://www.alanit.com"
   ::cEmail      := "correo@alanit.com"
   ::cMsgBar     := ::cCopyright + " * alanit software - 2019 "

   ::cIniFile    := cFilePath( GetModuleFileName( GetInstance() ) ) + "findemes.ini"
   ::cTipFile    := cFilePath( GetModuleFileName( GetInstance() ) ) + "tips.ini"
   ::cExePath    := cFilePath( GetModuleFileName( GetInstance() ) )
   ::cEjercicio  := GetIni( ::cIniFile, "Config", "Ejercicio", "2013")
	::cActividad  := GetIni( ::cIniFile, "Config", "Actividad", space(60))
   ::cDbfPath    := GetIni( ::cIniFile, "Config", "Dbf", cFilePath(GetModuleFileName(GetInstance()))+::cEjercicio+"\dbf\")
   ::cZipPath    := GetIni( ::cIniFile, "Config", "Zip", cFilePath(GetModuleFileName(GetInstance()))+::cEjercicio+"\zip\")
   ::cXMLPath    := GetIni( ::cIniFile, "Config", "Xml", cFilePath(GetModuleFileName(GetInstance()))+::cEjercicio+"\xml\")
   ::cPdfPath    := GetIni( ::cIniFile, "Config", "Pdf", cFilePath(GetModuleFileName(GetInstance()))+::cEjercicio+"\pdf\")
	::cXlsPath    := GetIni( ::cIniFile, "Config", "Xls", cFilePath(GetModuleFileName(GetInstance()))+::cEjercicio+"\xls\")
   ::lDirect     := GetIni( ::cIniFile, "Config", "Direct", .f. )
	::lChkPeriod  := GetIni( ::cIniFile, "Config", "ChkPeriod", .f. )
	::lExcel      := GetIni( ::cIniFile, "Config", "Excel", .f. )
   ::lCodAut     := GetIni( ::cIniFile, "Config", "CodAut", .t. )
   ::cClrIng     := GetIni( ::cIniFile, "Config", "ClrIng", CLR_BLUE )
   ::cClrGas     := GetIni( ::cIniFile, "Config", "ClrGas", CLR_RED )
	::cClrCc      := GetIni( ::cIniFile, "Config", "ClrCC", CLR_GRAY )
	::cInvPath    := GetIni( ::cIniFile, "Config", "Inv"   , cFilePath(GetModuleFileName(GetInstance()))+"invent\")
   ::cInvDbfPath := GetIni( ::cIniFile, "Config", "InvDbf", cFilePath(GetModuleFileName(GetInstance()))+"invent\dbf\")
   ::cInvZipPath := GetIni( ::cIniFile, "Config", "invZip", cFilePath(GetModuleFileName(GetInstance()))+"invent\zip\")
   ::cInvXMLPath := GetIni( ::cIniFile, "Config", "InvXml", cFilePath(GetModuleFileName(GetInstance()))+"invent\xml\")
   ::cInvPdfPath := GetIni( ::cIniFile, "Config", "InvPdf", cFilePath(GetModuleFileName(GetInstance()))+"invent\pdf\")
	::cInvXlsPath := GetIni( ::cIniFile, "Config", "InvXls", cFilePath(GetModuleFileName(GetInstance()))+"invent\xls\")
	::cInvImgPath := GetIni( ::cIniFile, "Config", "InvImg", cFilePath(GetModuleFileName(GetInstance()))+"invent\fotos\")
   ::cLanguage   := "ES"
	::nClrHL		  := RGB(204,232,255)
	::nClrbar	  := RGB(165,186,204) 
	::nClrFilter  := ::cClrGas //RGB(181,0,0)

   ::oDlg        := nil
   ::nEdit       := 0
	::lRibbon     := .t.
	::nRibbon	  := Val(GetIni( ::cIniFile, "Config", "Ribbon", "1" ))
	::nSeconds	  := Seconds()

	::cUser := space(15)
	::thefull := .f.
	::cEdicion := " Edición gratuita"
	::oFont = TFont():New( GetDefaultFontName(), 0, GetDefaultFontHeight(),, )

   DEFINE ICON ::oIcon RESOURCE "FINDEMES"

   DEFINE WINDOW ::oWndMain   ;
      TITLE ::cAppName + ::cVersion + ::cEdicion + " » Ejercicio " + ::cEjercicio; //      MENU ::BuildMenu()      ;
      COLOR CLR_BLACK, GetSysColor(15) - Rgb(20,20,20 ) ;
      ICON ::oIcon

	::oWndMain:SetFont(::oFont)
   SET MESSAGE OF ::oWndMain TO ::cMsgBar CENTER NOINSET
	::oWndMain:oMsgbar:oFont := ::oFont

   DEFINE MSGITEM ::oMsgItem2;
      OF ::oWndMain:oMsgBar;
      PROMPT iif(::cUser!=SPACE(15),::cUser,"acerca de findemes");
      SIZE len(::cUser)*11;
      BITMAPS "MSG_LOTUS", "MSG_LOTUS";
      TOOLTIP " " + i18n("Acerca de...") + " "
	if ::thefull
		::oMsgItem2:bAction := { || AppAcercade(.f.) }
	else
		::oMsgItem2:bAction := { || Registrame(.t.) }
	endif

   DEFINE MSGITEM ::oMsgItem3 OF ::oWndMain:oMsgBar ;
      SIZE 162 FONT ::oFont;
      PROMPT "www.alanit.com" ;
      COLOR RGB(3,95,156), GetSysColor(15)    ;
		BITMAPS "MSG_ALANIT", "MSG_ALANIT";
      TOOLTIP i18n("visitar la web de alanit");
      ACTION WinExec('start '+'.\alanit.url', 0)

	::oWndMain:oMsgBar:DateOn()

   if ::lRibbon
		::BuildRibbon()
	else
		::BuildBtnBar()
	endif

	if ::cUser == space(15)
		::cUser := "Edición no registrada"
	endif

return Self
/*_____________________________________________________________________________*/

method Activate() class TApplication
   GetWinCoors( ::oWndMain, ::cInifile )
   ::oWndMain:bResized := {|| ResizeWndMain() }
   ::oWndMain:bInit := { || ::InitCheck(), ::CheckFiles(), TipOfDay( ::cTipFile, .t. ), AppAcercade(.t.), IIF(::lDirect,Apuntes(),) }
   ACTIVATE WINDOW ::oWndMain ;
      VALID ::ExitFromX()
   ::oFont:End()
return nil

/*_____________________________________________________________________________*/

method BuildMenu() CLASS TApplication
   local oMenu
   MENU oMenu
      MENUITEM "&Archivo"
         MENU
            MENUITEM i18n( "Especificar impresora" ) ;
               ACTION PrinterSetup() ;
               MESSAGE i18n( " Establecer la Configuración de su impresora. " )
            SEPARATOR
            MENUITEM i18n( "Salir" ) ;
               ACTION ::ExitFromBtn() ;
               MESSAGE i18n( " Terminar la ejecución del programa. " )
         ENDMENU
		MENUITEM "&Contabilidad"
         MENU
				MENUITEM "Ejercicios" ACTION Ejercicio() ;
					MESSAGE "Mantenimiento del fichero de ejercicios."
         	MENUITEM "Actividades" ACTION Actividad() ;
								MESSAGE "Mantenimiento del fichero de actividades."
   			SEPARATOR
				MENUITEM "Apuntes" ACTION Apuntes() ;
               MESSAGE "Mantenimiento del fichero de apuntes. "
				MENUITEM "Apuntes periódicos" ACTION Periodicos() ;
               MESSAGE "Mantenimiento del fichero de apuntes periódicos. "
				MENUITEM "Gráficos" ACTION Graficos() ;
               MESSAGE "Gráficos sobre apuntes. "
      		SEPARATOR
				MENUITEM "Tipos de ingresos" ACTION Ingresos() ;
               MESSAGE "Mantenimiento del fichero de tipos de ingresos."
				MENUITEM "Pagadores" ACTION Clientes() ;
					MESSAGE "Mantenimiento del fichero de pagadores. "
				SEPARATOR
				MENUITEM "Tipos de gastos" ACTION Gastos() ;
					MESSAGE "Mantenimiento del fichero de tipos de gastos."
				MENUITEM "Perceptores" ACTION Proveedores() ;
					MESSAGE "Mantenimiento del fichero de proveedores. "
				SEPARATOR
				MENUITEM "Cuentas corrientes" ACTION Cuentas() ;
					MESSAGE "Mantenimiento del fichero de cuentas."
				SEPARATOR
				MENUITEM "Traspasos entre cuentas corrientes" ACTION Traspasos() ;
					MESSAGE "Mantenimiento del fichero de traspasos entre cuentas."
         ENDMENU
		MENUITEM "&Inventario"
         MENU
				MENUITEM "Bienes" ACTION Bienes() ;
					MESSAGE "Mantenimiento del fichero de bienes."
         	MENUITEM "Categorías" ACTION Categorias() ;
					MESSAGE "Mantenimiento del fichero de categorías."
				MENUITEM "Etiquetas" ACTION Etiquetas() ;
               MESSAGE "Mantenimiento del fichero de etiquetas. "
				MENUITEM "Ubicaciones" ACTION Ubicaciones() ;
               MESSAGE "Mantenimiento del fichero de ubicaciones. "
      		SEPARATOR
				MENUITEM "Marcas" ACTION Marcas() ;
               MESSAGE "Mantenimiento del fichero de marcas."
				MENUITEM "Tiendas" ACTION Tiendas() ;
					MESSAGE "Mantenimiento del fichero de tiendas. "
         ENDMENU
      MENUITEM "&Utilidades"
      MENU
         MENUITEM "Reindexar ficheros de datos"  ACTION (Ut_Actualizar(.f.),Ut_Indexar(.t.)) ;
            MESSAGE "Regenerar los indices de la aplicación."
         MENUITEM "Configurar la aplicación"  ACTION ::Config( ::oWndMain ) ;
            MESSAGE "Configurar la aplicación."
         SEPARATOR
         MENUITEM "Hacer copia de seguridad"  ACTION ZipBackup() ;
            MESSAGE " "
         MENUITEM "Restaurar copia de seguridad"  ACTION ZipRestore() ;
            MESSAGE " "
         SEPARATOR
         MENUITEM "Generar XML"  ACTION GenXML() ;
            MESSAGE " "
      ENDMENU
      MENUITEM i18n( "A&yuda" )
      MENU
         MENUITEM i18n( "Ayuda del programa" ) ;
            ACTION IIF(!IsWinNt(),;
               winExec("start "+rtrim(TakeOffExt(GetModuleFileName(GetInstance()))+".chm")),;
               ShellExecute(GetActiveWindow(),'Open',TakeOffExt(GetModuleFileName(GetInstance()))+".chm",,,4));
            MESSAGE i18n( " Obtener ayuda de la aplicación." )
         // MENUITEM i18n("Truco del día")  ACTION TipOfDay('.\tips.ini', .f.) ;
         //    MESSAGE i18n(" Mostrar el truco del día.") DISABLED
         SEPARATOR
         MENUITEM i18n("Visitar la web de alanit")  ACTION GoWeb("http://www.alanit.com") ;
            MESSAGE "Visitar la web de alanit en internet."
         MENUITEM i18n("Contactar por e-mail con el autor del programa")   ;
            ACTION IIF(!IsWinNt(),;
               winexec('start mailto:correo.alanit@gmail.com?subject=Consulta sobre Findemes',0),;
               Winexec('rundll32.exe url.dll,FileProtocolHandler mailto:correo.alanit@gmail.com?subject=Consulta sobre Findemes' )) ;
            MESSAGE i18n("Enviar un e-mail al autor del programa.")
         SEPARATOR
         MENUITEM i18n("Acerca de findemes")  ACTION AppAcercade( .f. ) ;
            MESSAGE i18n(" Información sobre la aplicación.")
      ENDMENU
   ENDMENU
   */
return oMenu

/*_____________________________________________________________________________*/

method BuildBtnBar() CLASS TApplication

   ::oImgList := TImageList():New( 36, 36 ) // width and height of bitmaps
   ::oImgList:AddMasked( TBitmap():Define( "BB_EJERCICIO" ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_ACTIVIDAD" ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_APUNTE"    ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_PERIODICO" ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_GRAFICO"   ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_PRESUPU"   ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_CATINGRESO",, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_CLIENTE"   ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_CATGASTO"  ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_PROVEED"   ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_CUENTA"    ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_TRASPASOS" ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_INDEX"     ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_AYUDA"     ,, ::oWndMain ), nRGB( 220, 220, 220 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_SALIR"     ,, ::oWndMain ), nRGB( 220, 220, 220 ) )

   ::oReBar := TReBar():New( ::oWndMain )
   ::oToolBar := TToolBar():New( ::oReBar, 38, 40, ::oImgList, .t. )
   ::oReBar:InsertBand( ::oToolBar )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Ejercicio() ;
      TOOLTIP i18n("ejercicios");
      MESSAGE i18n( "Gestión del fichero de ejercicios." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Actividad() ;
      TOOLTIP i18n("actividades");
      MESSAGE i18n( "Gestión del fichero de actividades." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Apuntes() ;
      TOOLTIP i18n( "apuntes" ) ;
      MESSAGE i18n( "Gestión del fichero de apuntes." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Periodicos() ;
      TOOLTIP i18n( "apuntes periodicos" ) ;
      MESSAGE i18n( "Gestión del fichero de apuntes periódicos." )


   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Graficos() ;
      TOOLTIP i18n( "graficos" ) ;
      MESSAGE i18n( "Visualización gráfica del fichero de apuntes." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Presupuestos() ;
      TOOLTIP i18n( "presupuestos" ) ;
      MESSAGE i18n( "Gestión del fichero de presupuestos." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Ingresos() ;
      TOOLTIP i18n( "tipos de ingresos" ) ;
      MESSAGE i18n( "Gestión del fichero de tipos de ingresos." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Clientes() ;
      TOOLTIP i18n( "pagadores / clientes" ) ;
      MESSAGE i18n( "Gestión del fichero de pagadores / clientes." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Gastos() ;
      TOOLTIP i18n( "tipos de gastos" ) ;
      MESSAGE i18n( "Gestión del fichero de tipos de gastos." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Proveedores() ;
      TOOLTIP i18n( "perceptores / proveedores" ) ;
      MESSAGE i18n( "Gestión del fichero de perceptores / proveedores." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Cuentas() ;
      TOOLTIP i18n( "cuentas corrientes" ) ;
      MESSAGE i18n( "Gestión del fichero de cuentas corrientes." )

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION Traspasos() ;
      TOOLTIP i18n( "traspasos entre cuentas corrientes" ) ;
      MESSAGE i18n( "Gestión del fichero de traspasos entre cuentas corrientes." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION ( Ut_Actualizar(.f.), Ut_Indexar(.t.) ) ;
      TOOLTIP i18n( "Reindexar ficheros del programa" ) ;
      MESSAGE i18n( "Reindexar ficheros del programa." ) ;

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION IIF(!IsWinNt(),;
         winExec("start "+rtrim(TakeOffExt(GetModuleFileName(GetInstance()))+".chm")),;
         ShellExecute(GetActiveWindow(),'Open',TakeOffExt(GetModuleFileName(GetInstance()))+".chm",,,4));
      TOOLTIP i18n( "Ayuda de la aplicacion" ) ;
      MESSAGE i18n( "Obtener ayuda del uso de la aplicación." )

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar  ;
      ACTION ::ExitFromBtn() ;
      TOOLTIP i18n( "Salir del programa" ) ;
      MESSAGE i18n( "Finalizar el uso del programa." )

return Self
/*_____________________________________________________________________________*/

method BuildRibbon() class TApplication

   local aRbPrompts :=  {"Contabilidad", "Inventario", "Utilidades"}
   local oGrC1, oGrC2, oGrC3, oGrC4
	local oGrI1, oGrI2
	local oGrU1
	local obtnC11
   // local nOption := Val(GetPvProfString("Config", "Ribbon","2", ::cIniFile))

   ::oRebar := TRibbonBar():New(::oWndMain, aRbPrompts,,,,105,22,CLR_WHITE,RGB(165,186,204),,,,,,,,.T.,)
   ::nBarHeight := ::oRebar:nHeight
   ::oReBar:bLDblClick = { || (iif( ::oReBar:nHeight > 24, ::oReBar:nHeight := 24, ::oReBar:nHeight := 105 ),;
      ::nBarHeight := ::oRebar:nHeight, Resizewndmain() ) }

   ADD GROUP oGrC1 RIBBON ::oRebar to OPTION 1 WIDTH 142

   @ 04,05 ADD BUTTON obtnC11 prompt "Ejercicios" BITMAP "BB_EJERCICIO";
      GROUP oGrC1 SIZE 60,65 top ROUND ACTION Ejercicio() TOOLTIP "Gestión de ejercicios" ;
	
   @ 04,65 ADD BUTTON prompt "Actividades" BITMAP "BB_ACTIVIDAD";
      GROUP oGrC1 SIZE 70,65 top ROUND RSIZE 2 ACTION Actividad() TOOLTIP "Gestión de actividades"

	ADD GROUP oGrC2 RIBBON ::oRebar to OPTION 1 WIDTH 280

	@ 04,05 ADD BUTTON prompt "Apuntes" BITMAP "BB_APUNTE";
	   GROUP oGrC2 SIZE 60,65 top ROUND ACTION Apuntes() TOOLTIP "Gestión de apuntes"

	@ 04,65 ADD BUTTON prompt "Ap. Periódicos" BITMAP "BB_PERIODICO";
	   GROUP oGrC2 SIZE 80,65 top ROUND ACTION Periodicos() TOOLTIP "Gestión de apuntes periódicos"

	@ 04,145 ADD BUTTON prompt "Gráficos" BITMAP "BB_GRAFICO";
	   GROUP oGrC2 SIZE 60,65 top ROUND ACTION Graficos() TOOLTIP "Gráficos de apuntes"

	@ 04,205 ADD BUTTON prompt "Presupuestos" BITMAP "BB_PRESUPU";
	   GROUP oGrC2 SIZE 70,65 top ROUND ACTION Presupuestos() TOOLTIP "Gestión de presupuestos"

	ADD GROUP oGrC3 RIBBON ::oRebar to OPTION 1 WIDTH 280

	@ 04,05 ADD BUTTON prompt "T. Ingresos" BITMAP "BB_CATINGRESO";
	   GROUP oGrC3 SIZE 70,65 top ROUND ACTION Ingresos() TOOLTIP "Gestión de tipos de ingresos"

	@ 04,75 ADD BUTTON prompt "Pagadores" BITMAP "BB_CLIENTE";
	   GROUP oGrC3 SIZE 70,65 top ROUND ACTION Clientes() TOOLTIP "Gestión de pagadores / clientes"

	@ 04,145 ADD BUTTON prompt "T. Gastos" BITMAP "BB_CATGASTO";
	   GROUP oGrC3 SIZE 60,65 top ROUND ACTION Gastos() TOOLTIP "Gráficos de apuntes"

	@ 04,205 ADD BUTTON prompt "Perceptores" BITMAP "BB_PROVEED";
	   GROUP oGrC3 SIZE 70,65 top ROUND ACTION Proveedores() TOOLTIP "Gestión de perceptores / proveedores"

	ADD GROUP oGrC4 RIBBON ::oRebar to OPTION 1 WIDTH 140

	@ 04,05 ADD BUTTON prompt "Cuentas" BITMAP "BB_CUENTA";
	   GROUP oGrC4 SIZE 60,65 top ROUND ACTION Cuentas() TOOLTIP "Gestión de cuentas corrientes"

	@ 04,65 ADD BUTTON prompt "Traspasos" BITMAP "BB_TRASPASOS";
	   GROUP oGrC4 SIZE 70,65 top ROUND ACTION Traspasos() TOOLTIP "Gestión de traspasos entre cuentas"

	ADD GROUP oGrI1 RIBBON ::oRebar to OPTION 2 WIDTH 288

   @ 04,05 ADD BUTTON prompt "Inventario" BITMAP "BB_INVENT";
      GROUP oGrI1 SIZE 60,65 top ROUND ACTION Bienes() TOOLTIP "Gestión de bienes"

   @ 04,65 ADD BUTTON prompt "Categorías" BITMAP "BB_CATEGOR";
      GROUP oGrI1 SIZE 70,65 top ROUND ACTION Categorias() TOOLTIP "Gestión de categorias"

	@ 04,135 ADD BUTTON prompt "Etiquetas" BITMAP "BB_TAG";
      GROUP oGrI1 SIZE 70,65 top ROUND ACTION Etiquetas() TOOLTIP "Gestión de categorias"

	@ 04,205 ADD BUTTON prompt "Ubicaciones" BITMAP "BB_UBICACI";
      GROUP oGrI1 SIZE 75,65 top ROUND ACTION Ubicaciones() TOOLTIP "Gestión de categorias"

	ADD GROUP oGrI2 RIBBON ::oRebar to OPTION 2 WIDTH 142

   @ 04,05 ADD BUTTON prompt "Marcas"     BITMAP "BB_MARCAS";
      GROUP oGrI2 SIZE 60,65 top ROUND ACTION Marcas() TOOLTIP "Gestión de marcas"

   @ 04,70 ADD BUTTON prompt "Tiendas" BITMAP "BB_TIENDAS";
      GROUP oGrI2 SIZE 60,65 top ROUND ACTION Tiendas() TOOLTIP "Gestión de centros de compras"

	//@ 04,65 ADD BUTTON prompt "Traspasos" BITMAP "BB_TRASPASOS";
	//   GROUP oGrC4 SIZE 70,65 top ROUND ACTION Traspasos() TOOLTIP "Gestión de traspasos entre cuentas"
	ADD GROUP oGrU1 RIBBON ::oRebar to OPTION 3 WIDTH 160

   @ 04,05 ADD BUTTON prompt "Configuración" BITMAP "BB_U_CONFIG";
      GROUP oGrU1 SIZE 80,65 top ROUND ACTION oApp():Config( oApp():oWndMain ) TOOLTIP "Configuración del programa"

	@ 04,85 ADD BUTTON prompt "Reindexar" BITMAP "BB_INDEX";
			GROUP oGrU1 SIZE 70,65 top ROUND ACTION ( Ut_Actualizar(.f.), Ut_Indexar(.t.) ) TOOLTIP "Reindexar ficheros del programa"

	ADD GROUP oGrU1 RIBBON ::oRebar to OPTION 3 WIDTH 145

   @ 04,5 ADD BUTTON prompt "Web" BITMAP "BB_ALANIT";
      GROUP oGrU1 SIZE 60,65 top ROUND ACTION GoWeb('http://www.alanit.com') ;
      TOOLTIP "Visitar la web de alanit.com"

   @ 04,65 ADD BUTTON prompt "Acerca de" BITMAP "BB_ACERCADE";
      GROUP oGrU1 SIZE 70,65 top ROUND ACTION AppAcercade(.F.) ;
      TOOLTIP "Acerca de Findemes"


	::oRebar:SetOption(::nRibbon)

return Self
/*_____________________________________________________________________________*/

method Close() CLASS TApplication
   // ResAllFree()
return nil
/*_____________________________________________________________________________*/

method InitCheck() CLASS tApplication
   ::cDbfPath   := Ut_AbsPath(::cDbfPath)
   ::cZipPath   := Ut_AbsPath(::cZipPath)
   ::cXmlPath   := Ut_AbsPath(::cXmlPath)
   ::cPdfPath   := Ut_AbsPath(::cPdfPath)
   ::cXlsPath   := Ut_AbsPath(::cXlsPath)

   if !lIsDir( lower( ::cDbfPath ) )
      lMkDir( lower( ::cDbfPath ) )
   endif

   if !lIsDir( lower( ::cZipPath ) )
      lMkDir( lower( ::cZipPath ) )
   endif

   if !lIsDir( lower( ::cXmlPath ) )
      lMkDir( lower( ::cXmlPath ) )
   endif

   if !lIsDir( lower( ::cPdfPath ) )
      lMkDir( lower( ::cPdfPath ) )
   endif

   if !lIsDir( lower( ::cXlsPath ) )
      lMkDir( lower( ::cXlsPath ) )
   endif

   // 2º intento, => no ha podido crear la carpeta => no existe la ruta
   if !lIsDir( lower( ::cDbfPath ) )
      msgAlert( i18n("No se han podido encontrar los datos de la aplicación en la ruta indicada en la configuración del programa." + CRLF + ;
                     "Por favor indique la ubicación correcta en la gestión de ejercicios.") )
      // ::Config( ::oWndMain )
		Ejercicio()
   endif

	// inventario
	::cInvPath      := Ut_AbsPath(::cInvPath)
	::cInvDbfPath   := Ut_AbsPath(::cInvDbfPath)
	::cInvZipPath   := Ut_AbsPath(::cInvZipPath)
	::cInvXmlPath   := Ut_AbsPath(::cInvXmlPath)
	::cInvPdfPath   := Ut_AbsPath(::cInvPdfPath)
	::cInvXlsPath   := Ut_AbsPath(::cInvXlsPath)
	::cInvImgPath   := Ut_AbsPath(::cInvImgPath)

	if !lIsDir( lower( ::cInvPath ) )
		lMkDir( lower( ::cInvPath ) )
	endif

	if !lIsDir( lower( ::cInvDbfPath ) )
		lMkDir( lower( ::cInvDbfPath ) )
	endif

	if !lIsDir( lower( ::cInvZipPath ) )
		lMkDir( lower( ::cInvZipPath ) )
	endif

	if !lIsDir( lower( ::cInvXmlPath ) )
		lMkDir( lower( ::cInvXmlPath ) )
	endif

	if !lIsDir( lower( ::cInvPdfPath ) )
		lMkDir( lower( ::cInvPdfPath ) )
	endif

	if !lIsDir( lower( ::cInvXlsPath ) )
		lMkDir( lower( ::cInvXlsPath ) )
	endif

	if !lIsDir( lower( ::cInvImgPath ) )
		lMkDir( lower( ::cInvImgPath ) )
	endif

	// 2º intento, => no ha podido crear la carpeta => no existe la ruta
	if !lIsDir( lower( ::cInvDbfPath ) )
		msgAlert( i18n("No se han podido encontrar los datos de inventario en la ruta indicada en la configuración del programa." + CRLF + ;
							"Por favor indique la ubicación correcta en la configuración del programa.") )
		// ::Config( ::oWndMain )
		Ejercicio()
	endif

return Self
/*_____________________________________________________________________________*/

method CheckFiles() CLASS tApplication
   local i      := 0
   local nLen   := 0
   local aFiles := { "apuntes.dbf"  , "apuntes.cdx"   ,;
                     "periodi.dbf"  , "periodi.cdx"   ,;
                     "clientes.dbf" , "clientes.cdx"  ,;
                     "activida.dbf" , "activida.cdx"  ,;
                     "gastos.dbf"   , "gastos.cdx"    ,;
                     "ingresos.dbf" , "ingresos.cdx"  ,;
                     "proveed.dbf"  , "proveed.cdx"   }
	local aFilesInv := { "bienes.dbf"   , "bienes.cdx"    ,"bienes.fpt"    ,;
								"categor.dbf"  , "categor.cdx"   ,;
								"etiqueta.dbf" , "etiqueta.cdx"  ,;
								"marcas.dbf"   , "marcas.cdx"    ,;
								"tiendas.dbf"  , "tiendas.cdx"   ,;
								"ubicaci.dbf"  , "ubicaci.cdx"   }
	local cOldversion := alltrim((GetPvProfString("Config", "Version","", oApp():cIniFile)))

   nLen := len( aFiles )
   for i := 1 TO nLen
      if !file( ::cDbfPath + aFiles[i] )
        	Ut_Actualizar(.f.)
         Ut_Indexar(.f.)
         EXIT
      endif
   next
	nLen := len( aFilesInv )
   for i := 1 TO nLen
      if !file( ::cInvDbfPath + aFilesInv[i] )
        	Ut_Actualizar(.f.)
         Ut_Indexar(.f.)
         EXIT
      endif
   next
   if ! file( ::cExePath + "ejercici.dbf" ) .or. ! file( ::cExePath + "ejercici.cdx" )
      Ut_Actualizar(.f.)
      Ut_Indexar(.f.)
   endif
	// compruebo la versión
	if cOldversion != alltrim(::cVersion)
		msgAlert("Se ha detectado un cambio de versión. A continuación se adaptarán los ficheros de datos para la nueva versión.")
      Ut_Actualizar(.f.)
      Ut_Indexar(.f.)
		DelIniSection( "Browse", ::cIniFile )
		DelIniSection( "Report", ::cIniFile )
	endif
	WritePProString("Config","Version",Ltrim(::cVersion),oApp():cIniFile)
   if ! Db_OpenAll() .or. ! Db_OpenAllInv()
      retu NIL
   else
      DbCloseAll()
   endif
return Self
/*_____________________________________________________________________________*/

method CheckUpdates() CLASS tApplication
   /*
   local oUrl, oClient
   local cIni2 := "d:\alanit\fdm2.ini"

   oUrl := tURL():New("http://10.103.70.53/fdmupd.ini" )
   oClient := tIPClient():New( oUrl )

   if oClient:Open( oUrl )
      oClient:ReadToFile( cIni2 )
      oClient:Close()
   endif
   */
return nil
/*_____________________________________________________________________________*/

method ExitFromBtn() CLASS tApplication
   // ::oImgList:End()
   ::oWndMain:End()
return nil
/*_____________________________________________________________________________*/

method ExitFromX() CLASS tApplication

   if oApp:oDlg != nil
      if oApp:nEdit > 0
         msgStop( i18n("No puede salir del programa hasta que no cierre las ventanas abiertas sobre el mantenimiento que está manejando.") )
         retu .f.
      end
   end
   if msgYesNo( i18n("¿Desea finalizar el programa?") )
      if oApp:oDlg != nil
         oApp:oDlg:End()
      endif
      SetWinCoors( ::oWndMain, ::cIniFile )
      retu .t.
   end
return .F.
/*_____________________________________________________________________________*/

method ExitFromSource() CLASS tApplication
   ::oWndMain:bValid := { || SetWinCoors( ::oWndMain, ::cIniFile ), .t. }
   ::oImgList:End()
   ::oWndMain:End()
return nil
//_____________________________________________________________________________//

method Config( oParent ) CLASS TApplication
   local oDlg, oFld
   local aGet[16]
   local oSay[12]

   if ::oDlg != nil
      if ::nEdit > 0
         retu nil
      else
         ::oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlg RESOURCE 'APP_CONFIG' OF oParent ;
      TITLE ::cAppName+' '+::cVersion + " - Configuración de la aplicación"
   oDlg:SetFont(oApp():oFont)

   REDEFINE FOLDER oFld ;
      ID 110 OF oDlg    ;
      ITEMS " &Inicio ", " &Colores ", " I&nventario "; // , ' &Valores por defecto ';
      DIALOGS "APP_CONFIGB", "APP_CONFIGC", "APP_CONFIGD" ;
      OPTION 1

   REDEFINE CHECKBOX aGet[1] VAR ::lDirect ID 201 OF oFld:aDialogs[1]
   REDEFINE CHECKBOX aGet[2] VAR ::lChkPeriod ID 202 OF oFld:aDialogs[1]
	REDEFINE CHECKBOX aGet[8] VAR ::lExcel ID 203 OF oFld:aDialogs[1]

   REDEFINE SAY oSay[1] ID 100 OF oFld:aDialogs[2]

   REDEFINE SAY oSay[2] ID 201 OF oFld:aDialogs[2]
   oSay[2]:SetColor(::cClrIng)

   REDEFINE BUTTON aGet[3] ID 101 OF oFld:aDialogs[2] ;
      ACTION ( ::cClrIng := ChooseColor(::cClrIng),;
 					oSay[2]:SetColor(::cClrIng,::cClrIng),;
               oSay[2]:Refresh() )

   REDEFINE SAY oSay[3] ID 102 OF oFld:aDialogs[2]

   REDEFINE SAY oSay[4] ID 202 OF oFld:aDialogs[2]
   oSay[4]:SetColor(::cClrGas)

   REDEFINE BUTTON aGet[4] ID 103 OF oFld:aDialogs[2] ;
      ACTION ( ::cClrGas := ChooseColor(::cClrGas),;
 					oSay[5]:SetColor(::cClrGas,::cClrGas),;
               oSay[5]:Refresh() )

	REDEFINE SAY oSay[5] ID 104 OF oFld:aDialogs[2]

   REDEFINE SAY oSay[6] ID 203 OF oFld:aDialogs[2]
  	oSay[6]:SetColor(::cClrCC)

   REDEFINE BUTTON aGet[5] ID 105 OF oFld:aDialogs[2] ;
      ACTION ( ::cClrCC := ChooseColor(::cClrCC),;
 					oSay[6]:SetColor(::cClrCC,::cClrCC),;
               oSay[6]:Refresh() )

	REDEFINE SAY oSay[7] ID 100 OF oFld:aDialogs[3]
	REDEFINE GET aGet[6] VAR ::cInvDbfPath    ;
		ID 101 OF oFld:aDialogs[3] UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[7]	 ;
		ID 111 OF oFld:aDialogs[3] UPDATE ;
		ACTION GetDir(aGet[6])
   aGet[7]:cTooltip := "seleccionar carpeta de datos"

	REDEFINE SAY oSay[8] ID 102 OF oFld:aDialogs[3]
	REDEFINE GET aGet[9] VAR ::cInvZipPath    ;
		ID 103 OF oFld:aDialogs[3] UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[10]	 ;
		ID 113 OF oFld:aDialogs[3] UPDATE ;
		ACTION GetDir(aGet[9])
   aGet[10]:cTooltip := "seleccionar carpeta de ZIP"

	REDEFINE SAY oSay[9] ID 104 OF oFld:aDialogs[3]
	REDEFINE GET aGet[11] VAR ::cInvPdfPath    ;
		ID 105 OF oFld:aDialogs[3] UPDATE PICTURE '@!'
	REDEFINE BUTTON aGet[12]	 ;
		ID 115 OF oFld:aDialogs[3] UPDATE ;
		ACTION GetDir(aGet[11])
	aGet[12]:cTooltip := "seleccionar carpeta de PDF"

	REDEFINE SAY oSay[10] ID 106 OF oFld:aDialogs[3]
	REDEFINE GET aGet[13] VAR ::cInvXlsPath    ;
		ID 107 OF oFld:aDialogs[3] UPDATE PICTURE '@!'
	REDEFINE BUTTON aGet[14]	 ;
		ID 117 OF oFld:aDialogs[3] UPDATE ;
		ACTION GetDir(aGet[13])
	aGet[14]:cTooltip := "seleccionar carpeta de XLS"

	REDEFINE SAY oSay[11] ID 108 OF oFld:aDialogs[3]
	REDEFINE GET aGet[15] VAR ::cInvImgPath    ;
		ID 109 OF oFld:aDialogs[3] UPDATE PICTURE '@!'
	REDEFINE BUTTON aGet[16]	 ;
		ID 119 OF oFld:aDialogs[3] UPDATE ;
		ACTION GetDir(aGet[15])
	aGet[16]:cTooltip := "seleccionar carpeta de imágenes"

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
	//data cInvDbfPath
	//data cInvZipPath
	//data cInvXMLPath
	//data cInvPdfPath
	//data cInvXlsPath
   if oDlg:nresult == IDOK
      SetIni(::cIniFile, "Config", "ClrIng", ::cClrIng )
      SetIni(::cIniFile, "Config", "ClrGas", ::cClrGas )
		SetIni(::cIniFile, "Config", "ClrCC" , ::cClrCC )
      SetIni(::cIniFile, "Config", "Direct", ::lDirect )
      SetIni(::cIniFile, "Config", "ChkPeriod", ::lChkPeriod )
		SetIni(::cIniFile, "Config", "Excel", ::lExcel )
		// inventario
		SetIni(::cIniFile, "Config", "InvDbf", ::cInvDbfPath )
		SetIni(::cIniFile, "Config", "InvZip", ::cInvZipPath )
		SetIni(::cIniFile, "Config", "InvPdf", ::cInvPdfPath )
		SetIni(::cIniFile, "Config", "InvXls", ::cInvXlsPath )
		SetIni(::cIniFile, "Config", "InvImg", ::cInvImgPath )
   endif
return ( Self )

/*___ OZScript ________________________________________________________________*/
#define ST_NORMAL        0
#define ST_ICONIZED      1
#define ST_ZOOMED        2

function GetWinCoors(oWnd,cIniFile)

   local oIni
   local nRow, nCol, nWidth, nHeight, nState

   nRow    := oWnd:nTop
   nCol    := oWnd:nLeft
   nWidth  := oWnd:nRight-oWnd:nLeft
   nHeight := oWnd:nBottom-oWnd:nTop

   if IsIconic( oWnd:hWnd )
      nState := ST_ICONIZED
   elseif IsZoomed(oWnd:hWnd)
      nState := ST_ZOOMED
   else
      nState := ST_NORMAL
   endif

   INI oIni FILE cIniFile

   GET nRow SECTION "config" ;
      ENTRY "nTop" DEFAULT -4 OF oIni

   GET nCol SECTION "config" ;
      ENTRY "nLeft" DEFAULT -4 OF oIni

   GET nWidth SECTION "config" ;
      ENTRY "nRight" DEFAULT 1032 OF oIni

   GET nHeight SECTION "config" ;
      ENTRY "nBottom" DEFAULT 752 OF oIni

   GET nState SECTION "config" ;
      ENTRY "Mode" DEFAULT nState OF oIni

   ENDINI

   IF nRow == 0 .AND. nCol == 0
      WndCenter(oWnd:hWnd)
   ELSE
      oWnd:Move(nRow, nCol, nWidth, nHeight)
   endif

   IF nState == ST_ICONIZED
      oWnd:Minimize()
   ELSEIF nState == ST_ZOOMED
      oWnd:Maximize()
   endif
   UpdateWindow( oWnd:hWnd )
   oWnd:CoorsUpdate()
   SysRefresh()
return nil
//----------------------------------------------------------------------------//

function SetWinCoors(oWnd, cIniFile)

   local oIni
   local nRow, nCol, nWidth, nHeight, nState

   oWnd:CoorsUpdate()

   nRow    := oWnd:nTop
   nCol    := oWnd:nLeft
   nWidth  := oWnd:nRight-oWnd:nLeft
   nHeight := oWnd:nBottom-oWnd:nTop

   IF IsIconic( oWnd:hWnd )
      nState := ST_ICONIZED
   ELSEIF IsZoomed(oWnd:hWnd)
      nState := ST_ZOOMED
   ELSE
      nState := ST_NORMAL
   endif

   INI oIni FILE cIniFile

   SET SECTION "config" ;
      ENTRY "nTop" TO nRow OF oIni

   SET SECTION "config" ;
      ENTRY "nLeft" TO nCol OF oIni

   SET SECTION "config" ;
      ENTRY "nRight" TO nWidth OF oIni

   SET SECTION "config" ;
      ENTRY "nBottom" TO nHeight OF oIni

   SET SECTION "config" ;
      ENTRY "Mode" TO nState OF oIni

	// guardo la posición de la ribbon
   if oApp():lRibbon
      set SECTION "config" ;
         ENTRY "Ribbon" to oApp():oRebar:nOption OF oIni
   endif

   ENDINI
return .t.

function TakeOffExt(cFile)

   local nAt := At(".", cFile)

   if nAt > 0
      cFile := Left(cFile, nAt-1)
   endif

return cFile

/*_____________________________________________________________________________*/

function oApp()
return oApp
/*_____________________________________________________________________________*/

function AppAcercade( lForced )
   local oDlg
   local oBmp
   local oSay
   local oTel
   local oURL1
   local oURL2
   local cCfg, cAAAA, cBBBB, cCCCC, CDDDD
   local lOtravez   := GetIni( , "Config", "Again", "SI" ) == "SI"

	if lForced .and. lOtravez == .f.
      retu nil
   endif

	DEFINE DIALOG oDlg;
	   TITLE i18n("acerca de...");
	   FROM  0, 0 TO 242, 330 PIXEL;
	   COLOR CLR_BLACK, CLR_WHITE
	oDlg:SetFont(oApp():oFont)

   @ 04,26 BITMAP oBmp RESOURCE 'acercade' ;
      SIZE 110, 30 OF oDlg PIXEL NOBORDER

	@ 32,13 SAY oSay;
	   PROMPT i18n("versión")+" "+oApp:cVersion+" "+oApp:cBuild;
	   SIZE 140,15 PIXEL;
	   OF oDlg;
	   COLOR CLR_GRAY, CLR_WHITE;
	   CENTERED

	@ 40,13 SAY oTel;
	   PROMPT oApp:cCopyright;
	   SIZE 140,9 PIXEL;
	   OF oDlg;
	   COLOR CLR_GRAY, CLR_WHITE;
	   CENTERED

	hb_UnZipFile( oApp():cExePath+"user.nit",NIL,.f.,"deomnirescibilietquibusdamaliis",oAPP():cExePath,"user.lic" )
	cCfg  := cFilePath( GetModuleFileName( GetInstance() ) ) + "user.lic"
	cAAAA := GetPvProfString( "Usuario", "AAAA", "", cCfg )
	cBBBB := GetPvProfString( "Usuario", "BBBB", "", cCfg )
	cCCCC := GetPvProfString( "Usuario", "CCCC", "", cCfg )
	cDDDD := GetPvProfString( "Usuario", "DDDD", "", cCfg )
	delete file (oApp():cExePath+"user.lic")

	// @ 52, 10 TO 100, 156 PIXEL OF oDlg

	@ 52 ,20 SAY oSay;
	   PROMPT " "+i18n("Programa registrado por:")+" ";
	   SIZE 80,9 PIXEL;
	   OF oDlg;
	   COLOR CLR_GRAY, CLR_WHITE

	@ 65,13 SAY oSay     ;
	   PROMPT cBBBB      ;
	   SIZE 140,9 PIXEL  ;
	   OF oDlg;
	   COLOR GetSysColor(2), CLR_WHITE;
	   CENTERED

	@ 75,13 SAY oSay     ;
	   PROMPT cCCCC      ;
	   SIZE 140,9 PIXEL  ;
	   OF oDlg ;
	   COLOR GetSysColor(2), CLR_WHITE;
	   CENTERED

	@ 85,13 SAY oSay     ;
	   PROMPT cDDDD      ;
	   SIZE 140,9 PIXEL  ;
	   OF oDlg;
	   COLOR GetSysColor(2), CLR_WHITE;
	   CENTERED

	@ 106,13 CHECKBOX lOtravez;
	   PROMPT i18n("Mostrar la próxima vez que arranque el programa");
	   SIZE 130, 9 PIXEL;
	   OF oDlg;
	   COLOR GetSysColor(2), CLR_WHITE

	ACTIVATE DIALOG oDlg ;
	   ON INIT ( DlgCenter( oDlg, oApp:oWndMain ) );
	   ON CLICK oDlg:End()

	SetIni( , "Config", "Again", iif( lOtravez, "SI", "NO" ) )

return nil

function Donacion()
   local oDlg
   local oBmp01
   local oBmp02
   local oSay
   local oTel
   local lDonativo := .f.
   local oFontBold := TFont():New( GetDefaultFontName(), 0, GetDefaultFontHeight(),,.t. )

   DEFINE DIALOG oDlg;
      TITLE i18n("Donación");
      FROM  0, 0 TO 290, 324 PIXEL;
      COLOR CLR_BLACK, CLR_WHITE
	oDlg:SetFont(oApp():oFont)

   @ 00,28 BITMAP oBmp01 OF oDlg;
      RESOURCE 'acercade2';
      SIZE 34, 54 PIXEL;
      NOBORDER

   @ 10,50 BITMAP oBmp02 OF oDlg;
      RESOURCE 'acercade1';
      SIZE 80, 20 PIXEL;
      NOBORDER

   @ 32,10 SAY oSay;
      PROMPT i18n("versión")+" "+oApp:cVersion+" "+oApp:cBuild;
      SIZE 140,15 PIXEL;
      OF oDlg;
      COLOR CLR_GRAY, CLR_WHITE;
      CENTERED

   @ 40,10 SAY oTel;
      PROMPT oApp():cCopyright ;
      SIZE 140,9 PIXEL;
      OF oDlg;
      COLOR CLR_GRAY, CLR_WHITE;
      CENTERED

   @ 50, 10 SAY oSay;
      PROMPT i18n("¡ Gracias por utilizar Findemes !");
      SIZE 140, 9 PIXEL;
      OF oDlg;
      COLOR CLR_BLACK, CLR_WHITE;
      CENTERED FONT oFontBold

   @ 60, 12 SAY oSay;
      PROMPT i18n("He pasado muchas noches creando este programa. Si es útil para ti " + ;
                  "puedes contribuir a su desarrollo realizando un donativo. Eso me animará a seguir mejorándolo."+CRLF+CRLF+;
						"Al realizar el donativo recibirás una clave de donante que desactivará este mensaje y pondrá tu nombre en todos los listados del programa.");
      SIZE 140, 56 PIXEL;
      OF oDlg;
      COLOR CLR_BLACK, CLR_WHITE

   @ 124, 75 BUTTON i18n("Donativo") OF oDlg;
      SIZE 36,12 PIXEL;
      ACTION ( lDonativo := .t., oDlg:End() )

   @ 124, 115 BUTTON i18n("Ahora no") OF oDlg;
      SIZE 36,12 PIXEL;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp:oWndMain ) )

   oFontBold:End()

return nil

//___ manejo de fuentes © Paco García 2006 ____________________________________//
#pragma BEGINDUMP
#include "Windows.h"
#include "hbapi.h"

HB_FUNC( GETDEFAULTFONTNAME )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retc( lf.lfFaceName );
}

HB_FUNC( GETDEFAULTFONTHEIGHT )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfHeight );
}

HB_FUNC( GETDEFAULTFONTWIDTH )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfWidth );
}

HB_FUNC( GETDEFAULTFONTITALIC )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfItalic );
}

HB_FUNC( GETDEFAULTFONTUNDERLINE )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfUnderline );
}

HB_FUNC( GETDEFAULTFONTBOLD )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) ( lf.lfWeight == 700 ) );
}

HB_FUNC( GETDEFAULTFONTSTRIKEOUT )
{
      LOGFONT lf;
      GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      hb_retl( (BOOL) lf.lfStrikeOut );
}

#pragma ENDDUMP

function ResizeWndMain()
	local aClient

	if oApp():oDlg != nil
      aClient := Getclientrect ( oApp():oWndMain:hWnd )
      oApp():oDlg:Move(oApp():nBarHeight - 2 , 0,,,.t.)
      oApp():oDlg:Setsize( aClient[ 4 ], aClient[ 3 ] - oApp():nBarHeight + 2 - oApp():oWndMain:oMsgBar:nHeight )
      oApp():oDlg:Refresh()
      oApp():oSplit:Setsize( oApp():oSplit:nWidth, oApp():oDlg:nHeight )
      oApp():oSplit:Refresh()
      if oApp():oGrid != nil
         oApp():oGrid:Setsize( aClient[ 4 ] -oApp():oGrid:nLeft, oApp():oDlg:nHeight -26 )
         oApp():oGrid:Refresh()
         oApp():oTab:nTop := oApp():oDlg:nHeight -26
         oApp():oTab:Refresh()
      elseif oApp():oGraph != nil
         oApp():oGraph:Setsize( aClient[ 4 ] -oApp():oGraph:nLeft, oApp():oDlg:nHeight )
         oApp():oGraph:Refresh()
      endif
      oApp():oWndMain:oMsgBar:Refresh()
   endif
	IF ! oApp():thefull
		Registrame()
	ENDIF

return nil
//-----------------------------------------------------------------------//
function AutoUpdate1()
   /*
   local oUrl, oFtp
   local cIni2 := "d:\alanit\fdm2.ini"

   oUrl := tURL():New("http://10.103.70.53/fdmupd.ini" )
   oFtp := tIPClient():New( oUrl,, .T. )
   oFTP:nConnTimeout := 20000
   oFTP:bUsePasv     := .T.

   if oFtp:Open( oUrl )
      if oFtp:DownloadFile( "fdm2.ini" )
         ? "OK"
      else
         ? "NO"
      endif
      oFtp:Close()
   endif
   */
return nil

/*------------------------------------------------------------------------------*/

function AutoUpdate2()
   local oInternet, oFtp, cFtpSite:="10.103.70.53"

   MsgRun( "Conectando al FTP...", "Espere un momento...",;
      { || oInternet := TInternet():New(),;
      If( Empty( oInternet:hSession ),;
      MsgAlert( "Internet session not available!" ),),;
      oFTP := TFTP():New( cFTPSite, oInternet,"","" ) } )

   if Empty( oFTP:hFTP )
      MsgStop( "No se puede conectar con el sitio FTP." )
      retu nil
   else
      FtpGetFiles({"fdm.ini"},{cFilePath( GetModuleFileName( GetInstance() )) +"fdm99.ini"},oFtp)
   endif
   oInternet:End()
   MsgInfo("FTP terminado.")
return nil
/*------------------------------------------------------------------------------*/

function FtpGetFiles( aSource, aTarget, oFTP, oSay )
   local nBufSize:=4096
   local n
   local hTarget
   local cBuffer := Space( nBufSize )
   local nBytes, nFile := 0, nTotal := 0
   local nTotSize := 0
   local oFile, aFiles, aSizes := {}

   for n = 1 to Len( aSource )
      aFiles = oFTP:Directory( aSource[ n ] )
      if Len( aFiles ) > 0
         AAdd( aSizes, aFiles[ 1 ][ 2 ] ) // first file, size
         nTotSize += ATail( aSizes )
         else
         AAdd( aSizes, 0 )
      endif
      SysRefresh()
   next

   nFile := 0
   for n = 1 to Len( aSource )
      hTarget = FCreate( aTarget[ n ] )
      oFile = TFtpFile():New( aSource[ n ], oFTP )
      oFile:OpenRead()
      SysRefresh()
      while ( nBytes := Len( cBuffer := oFile:Read( nBufSize ) ) ) > 0
         FWrite( hTarget, cBuffer, nBytes )
         if oSay<>NIL
            oSay:SetText ("- Recibiendo :"+Str(nFile+=nBytes)+" de "+Str(nTotSize))
         endif
         SysRefresh()
      enddo
      FClose( hTarget )
      oFile:End()
next

return nil


*
 * función .: Registrarme()
 * prec ....: True
 * post ....: Muestra la prohibición de usar una funcionalidad de pago.
*/

function Registrame(lDirect) // CLASS TApplication
   local oDlg, oBmp01, oBmp02, oTmr, oSay, oTel, oURL1, oURL2, cCfg
   local lNext := .t.
	local nPaso := 11 // (-1)*GetDefaultFontHeight()-1

	IF Seconds() - oApp():nSeconds < 120 .AND. lDirect == NIL
      // ? Seconds() - oApp():nSeconds
      RETU NIL
   ELSE
      oApp():nSeconds := Seconds()
   ENDIF


   define dialog oDlg title 'edición gratuita del programa' ; // OF oParent ;
      FROM  0, 0 TO 35*nPaso, 390 PIXEL  ;
      COLOR CLR_BLACK, CLR_WHITE
	oDlg:SetFont(oApp():oFont)

   @ 04,36 BITMAP oBmp01 RESOURCE 'acercade' ;
      SIZE 110, 30 OF oDlg PIXEL NOBORDER // TRANSPAREN

   //@ 10,80 BITMAP oBmp02 RESOURCE 'acercade1' ;
   //   SIZE 94, 26 OF oDlg PIXEL NOBORDER // TRANSPAREN

   @ 40,10 SAY oSay PROMPT "version "+oApp():cVersion+" "+oApp():cBuild +" "+oApp():cEdicion ;
      SIZE 174,15 CENTERED PIXEL OF oDlg ;
      COLOR CLR_GRAY, CLR_WHITE

   @ 40+nPaso-2,10 SAY oTel PROMPT ' © José Luis Sánchez Navarro 2018 ' ;
      SIZE 174,9 PIXEL CENTERED OF oDlg ;
      COLOR CLR_GRAY, CLR_WHITE

   @ 40+2*nPaso,10 SAY oSay PROMPT 'Está utilizando la edición gratuita del programa. Esta edición es completamente funcional por tiempo ilimitado, pero existe una edición registrada que incorpora las siguientes funcionalidades:';
      SIZE 174,76 PIXEL OF oDlg ;
      CENTERED COLOR CLR_BLACK, CLR_WHITE

	@ 40 + 5 * nPaso, 10 SAY oSay PROMPT "* No aparece este recordatorio de registrar el programa" ;
      SIZE 174, 10 PIXEL CENTERED OF oDlg COLOR RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under
   @ 40 + 6 * nPaso, 10 SAY oSay PROMPT "* Nombre del usuario en todos los listados" ;
      SIZE 174, 10 PIXEL CENTERED OF oDlg  COLOR RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under
   @ 40 + 7 * nPaso, 10 SAY oSay PROMPT "* Soporte técnico preferente" ;
      SIZE 174, 18 PIXEL CENTERED OF oDlg COLOR  RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under

   @ 40+9*nPaso,10 SAY oSay PROMPT 'Si desea comprar la edición registrada del programa por sólo 20 € pulse sobre el siguiente enlace:';
      SIZE 174,46 PIXEL CENTERED OF oDlg ;
      COLOR CLR_BLACK, CLR_WHITE

   @ 40+11*nPaso,10 SAYREF oURL2 PROMPT "http://www.alanit.com/comprar" ;
      SIZE 174,14 PIXEL CENTERED OF oDlg     ;
      HREF "http://www.alanit.com/comprar"   ;
      COLOR RGB(3,95,156), CLR_WHITE

   oUrl2:cTooltip  := 'registrar el programa por sólo 20 €'
	oUrl2:SetFont( oApp():oFont )

	activate dialog oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain ) ;
      ON PAINT ( SysWait( 9 ), oDlg:End() )

return nil

