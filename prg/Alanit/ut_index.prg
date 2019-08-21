#include "FiveWin.ch"
/*_____________________________________________________________________________*/

function Ut_Actualizar( lMsg )

   local oDlg, oBmp
   local aSay  := array( 02 )
   local lOk

   if oApp():oDlg != nil
      if oApp():nEdit > 0
         msgStop( i18n("No puede realizar esta operación hasta que no cierre las ventanas abiertas sobre el mantenimiento que está manejando.") )
         retu nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   lOk := .F.

   DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "UT_ACTUALIZAR"
   oDlg:SetFont(oApp():oFont)

   REDEFINE BITMAP oBmp ID 111 OF oDlg RESOURCE "BB_INDEX" TRANSPARENT

   REDEFINE SAY aSay[01] ID  99 OF oDlg PROMPT i18n( "Actualizando ficheros..." )
   REDEFINE SAY aSay[02] ID 100 OF oDlg PROMPT ""

   oDlg:bStart := {|| SysRefresh(), Ut_CrearDbf( oDlg, aSay[02], lMsg ) }

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function Ut_CrearDbf( oDlgT, oSay, lMsg )
	local aData := {}
   CursorWait()

	// ejercicios
   oSay:SetText('Fichero de EJERCICIOS')
   DbCreate(oApp():cExePath+'ej', { ;
      {"EJANYO"      , "C",   4,   0} ,; //Año de la actividad
      {"EJDBF"       , "C",  80,   0} ,; //Ruta a archivos DBF
      {"EJZIP"       , "C",  80,   0} ,; //Ruta a archivos ZIP
      {"EJXML"       , "C",  80,   0} ,; //Ruta a archivos XML
		{"EJXLS"       , "C",  80,   0} ,; //Ruta a archivos XLS
      {"EJPDF"       , "C",  80,   0} }) //Ruta a archivos PDF
   close all
   use &(oApp():cExePath+'ej') new
   select ej
   if File(oApp():cExePath+'EJERCICI.DBF')
      delete file &(oApp():cExePath+'ejercici.cdx')
      append from &(oApp():cExePath+'ejercici')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cExePath+'ejercici.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cExePath+'ej.dbf') to &(oApp():cExePath+'ejercici.dbf')

	// iva de ejercicios
   oSay:SetText('Fichero de EJERCICIOS')
   DbCreate(oApp():cExePath+'iv', { ;
   	{"IVCLASE"     , "C",   1,   0} ,; // I IVA E Recargo Equivalencia
      {"IVANYO"      , "C",   4,   0} ,; //Año de la actividad
      {"IVTIPO"      , "N",   5,   2} ,; //IVA
      {"IVVIGENTE"   , "L",   1,   0} }) //Vigencia del tipo de IVA
   close all
   use &(oApp():cExePath+'iv') new
   select iv
   if File(oApp():cExePath+'IVA.DBF')
      delete file &(oApp():cExePath+'iva.cdx')
      append from &(oApp():cExePath+'iva')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cExePath+'iva.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cExePath+'iv.dbf') to &(oApp():cExePath+'iva.dbf')

	// actividades
   oSay:SetText('Fichero de ACTIVIDADES')
   DbCreate(oApp():cDbfPath+'ac', { ;
                        {"ACANYO"      , "C",   4,   0} ,; //Año de la actividad
                        {"ACNUMERO"    , "C",   2,   0} ,; //Número de actividad en el año
                        {"ACACTIVIDA"  , "C",  60,   0} ,; //Descripción de la actividad
								{"ACPREDETER"  , "L",   1,   0} ,; //Actividad predeterminada de IVA
								{"ACIVA"       , "L",   1,   0} ,; //Actividad con gestión de IVA
                        {"ACREQUIV"    , "L",   1,   0} }) //Actividad con gestión de RE
   close all
   use &(oApp():cDbfPath+'ac') new
   select ac
   if File(oApp():cDbfPath+'ACTIVIDA.DBF')
      delete file &(oApp():cDbfPath+'activida.cdx')
      append from &(oApp():cDbfPath+'activida')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'activida.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'ac.dbf') to &(oApp():cDbfPath+'activida.dbf')

   // apuntes
   oSay:SetText('Fichero de APUNTES')
   DbCreate(oApp():cDbfPath+'ap', {{"APNUMERO"    , "C",  10,   0} ,; //Número de apunte
                        {"APFECHA"     , "D",   8,   0} ,; //Fecha
                        {"APCONCEPTO"  , "C",  90,   0} ,; //Concepto
                        {"APTIPO"      , "C",   1,   0} ,; // I/G
                        {"APACTIVIDA"  , "C",  60,   0} ,; // Actividad
                        {"APIMPNETO"   , "N",   9,   2} ,; //Importe neto
                        {"APOBSERV"    , "C", 250,   0} ,; //Observaciones
                        {"APCLIENTE"   , "C",  40,   0} ,; //(I)Cliente
                        {"APCATINGR"   , "C",  40,   0} ,; //(I)Categoría Ingreso
                        {"APMIFACTUR"  , "C",  10,   0} ,; //(I)Mi factura
                        {"APRECING"    , "N",   5,   2} ,; //(I)Recargo equivalencia ingreso
                        {"APIVAREP"    , "N",   5,   2} ,; //(I)Iva repercutido %
                        {"APGASTOSFI"  , "N",   9,   2} ,; //Gastos financieros o comisiones
                        {"APPROVEED"   , "C",  40,   0} ,; //(G)Proveedor
                        {"APCATGAST"   , "C",  40,   0} ,; //(G)Categoría Gasto
								{"APCUENTA"    , "C",  20,   0} ,; //(A)Cuenta
                        {"APSUFACTUR"  , "C",  10,   0} ,; //(G)Su factura
                        {"APIVASOP"    , "N",   5,   2} ,; //(G)Iva soportado %
                        {"APRECGAS"    , "N",   5,   2} ,; //(I)Recargo equivalencia gasto
                        {"APIMPTOTAL"  , "N",   9,   2}} ) //Total del apunte

   DbCloseAll()
   use &(oApp():cDbfPath+'ap') new
   select ap
   if File(oApp():cDbfPath+'APUNTES.DBF')
      delete file &(oApp():cDbfPath+'apuntes.cdx')
		Db_OpenNoIndex("APUNTES", "APUNTES")
		APUNTES->(DbGoTop())
		while ! APUNTES->(EoF())
			aData := Db_Scatter("APUNTES")
			AP->(DbAppend())
			DB_Gather( aData, "AP", .t. )
			APUNTES->(DbSkip())
		enddo
      //append from &(oApp():cDbfPath+'apuntes')
      //DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'apuntes.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'ap.dbf') to &(oApp():cDbfPath+'apuntes.dbf')

   // apuntes periodicos
   oSay:SetText('Fichero de APUNTES PERIODICOS')
   DbCreate(oApp():cDbfPath+'pe', {{"PECONCEPTO"  , "C",  90,   0} ,; //Concepto
      {"PETIPO"      , "C",   1,   0} ,; // I/G
      {"PEACTIVIDA"  , "C",  60,   0} ,; // Actividad
      {"PEIMPNETO"   , "N",   9,   2} ,; //Importe neto
      {"PEOBSERV"    , "C", 250,   0} ,; //Observaciones
      {"PECLIENTE"   , "C",  40,   0} ,; //(I)Cliente
      {"PECATINGR"   , "C",  40,   0} ,; //(I)Categoría Ingreso
      {"PERECING"    , "N",   5,   2} ,; //(I)Recargo equivalencia ingreso
      {"PEIVAREP"    , "N",   5,   2} ,; //(I)Iva repercutido %
      {"PEGASTOSFI"  , "N",   9,   2} ,; //(I)Gastos financieros o comisiones
      {"PEPROVEED"   , "C",  40,   0} ,; //(G)Proveedor
      {"PECATGAST"   , "C",  40,   0} ,; //(G)Categoría Gasto
		{"PECUENTA"    , "C",  20,   0} ,; //Cuenta
      {"PEIVASOP"    , "N",   5,   2} ,; //(G)Iva soportado %
      {"PERECGAS"    , "N",   5,   2} ,; //(I)Recargo equivalencia gasto
      {"PEIMPTOTAL"  , "N",   9,   2} ,;
      {"PEPERIODIC"  , "N",   1,   0} ,; // anual, semestral, trimestal, bimestral, mensual
      {"PEMESES"     , "C",  12,   0} ,; // meses
      {"PEFULTIMO"   , "D",   8,   0} ,; // fecha ultimo apunte
      {"PEFPROXIMO"  , "D",   8,   0} }) // fecha proximo apunte

   DbCloseAll()
   use &(oApp():cDbfPath+'pe') new
   select pe
   if File(oApp():cDbfPath+'PERIODI.DBF')
      delete file &(oApp():cDbfPath+'periodi.cdx')
		Db_OpenNoIndex("PERIODI", "PERIODI")
		PERIODI->(DbGoTop())
		while ! PERIODI->(EoF())
			aData := Db_Scatter("PERIODI")
			PE->(DbAppend())
			DB_Gather( aData, "PE", .t. )
			PERIODI->(DbSkip())
		enddo
      //append from &(oApp():cDbfPath+'apuntes')
      //DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'periodi.dbf')
   endif
   if File(oApp():cDbfPath+'PERIODI.DBF')
      delete file &(oApp():cDbfPath+'periodi.cdx')
      append from &(oApp():cDbfPath+'periodi')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'periodi.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'pe.dbf') to &(oApp():cDbfPath+'periodi.dbf')

   // presupuestos
   oSay:SetText('Fichero de PRESUPUESTOS')
   DbCreate(oApp():cDbfPath+'pu', {;
                        {"PUFECHA"     , "D",   8,   0} ,; //Fecha
                        {"PUCONCEPTO"  , "C",  90,   0} ,; //Concepto
                        {"PUTIPO"      , "C",   1,   0} ,; // I/G
                        {"PUACTIVIDA"  , "C",  60,   0} ,; // Actividad
                        {"PUIMPNETO"   , "N",   9,   2} ,; //Importe neto
                        {"PUOBSERV"    , "C", 250,   0} ,; //Observaciones
                        {"PUCLIENTE"   , "C",  40,   0} ,; //(I)Cliente
                        {"PUCATINGR"   , "C",  40,   0} ,; //(I)Categoría Ingreso
                        {"PURECING"    , "N",   5,   2} ,; //(I)Recargo equivalencia ingreso
                        {"PUIVAREP"    , "N",   5,   2} ,; //(I)Iva repercutido %
                        {"PUGASTOSFI"  , "N",   9,   2} ,; //Gastos financieros o comisiones
                        {"PUPROVEED"   , "C",  40,   0} ,; //(G)Proveedor
                        {"PUCATGAST"   , "C",  40,   0} ,; //(G)Categoría Gasto
                        {"PUIVASOP"    , "N",   5,   2} ,; //(G)Iva soportado %
                        {"PURECGAS"    , "N",   5,   2} ,; //(I)Recargo equivalencia gasto
                        {"PUIMPTOTAL"  , "N",   9,   2}} ) //Total del apunte

   DbCloseAll()
   use &(oApp():cDbfPath+'pu') new
   select pu
   if File(oApp():cDbfPath+'PRESUPU.DBF')
      delete file &(oApp():cDbfPath+'presupu.cdx')
		Db_OpenNoIndex("PRESUPU", "PRESUPU")
		PRESUPU->(DbGoTop())
		while ! PRESUPU->(EoF())
			aData := Db_Scatter("PRESUPU")
			PU->(DbAppend())
			DB_Gather( aData, "PU", .t. )
			PRESUPU->(DbSkip())
		enddo
      DbCloseAll()
      delete file &(oApp():cDbfPath+'presupu.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'pu.dbf') to &(oApp():cDbfPath+'presupu.dbf')

   // perceptores
   oSay:SetText('Fichero de PERCEPTORES')
   DbCreate(oApp():cDbfPath+'pr', {{"PRNOMBRE"    , "C",  40,   0} ,;
                        {"PRCIF"       , "C",  15,   0} ,;
                        {"PRCATEGOR"   , "C",  40,   0} ,;
                        {"PRNOTAS"     , "C", 255,   0} ,;
                        {"PRDIRECC"    , "C",  50,   0} ,;
                        {"PRLOCALI"    , "C",  50,   0} ,;
                        {"PRPAIS"      , "C",  30,   0} ,;
                        {"PRTELEFONO"  , "C",  15,   0} ,;
                        {"PRMOVIL"     , "C",  15,   0} ,;
                        {"PRFAX"       , "C",  15,   0} ,;
                        {"PRCONTACTO"  , "C",  40,   0} ,;
                        {"PREMAIL"     , "C",  50,   0} ,;
                        {"PRURL"       , "C",  50,   0} ,;
								{"PRAPUNTES"   , "N",   6,   0} ,;
								{"PRAPSUMA" 	, "N",   9,   2} ,;
								{"PRPUSUMA" 	, "N",   9,   2} ,;
								{"PRPRESUPU"   , "N",   6,   0} })

   use &(oApp():cDbfPath+'pr') new
   select pr
   if File(oApp():cDbfPath+'PROVEED.DBF')
      delete file &(oApp():cDbfPath+'proveed.cdx')
      append from &(oApp():cDbfPath+'proveed')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'proveed.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'pr.dbf') to &(oApp():cDbfPath+'proveed.dbf')

   // cat. gastos
   oSay:SetText('Fichero de GASTOS')
   DbCreate(oApp():cDbfPath+'ga', {{"GACATEGOR"   , "C",  40,   0} ,;
											  {"GAAPUNTES"   , "N",   6,   0} ,;
											  {"GAAPSUMA" 	  , "N",   9,   2} ,;
											  {"GAPUSUMA" 	  , "N",   9,   2} ,;
											  {"GAPRESUPU"   , "N",   6,   0} ,;
											  {"GACOLOR"     , "N",  10,   0} })


   use &(oApp():cDbfPath+'ga') new
   select ga
   if File(oApp():cDbfPath+'GASTOS.DBF')
      delete file &(oApp():cDbfPath+'gastos.cdx')
      append from &(oApp():cDbfPath+'gastos')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'gastos.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'ga.dbf') to &(oApp():cDbfPath+'gastos.dbf')

   // pagadores
   oSay:SetText('Fichero de PAGADORES')
   DbCreate(oApp():cDbfPath+'cl', {{"CLNOMBRE"    , "C",  40,   0} ,;
                        {"CLCIF"       , "C",  15,   0} ,;
                        {"CLCATEGOR"   , "C",  40,   0} ,;
                        {"CLNOTAS"     , "C", 255,   0} ,;
                        {"CLDIRECC"    , "C",  50,   0} ,;
                        {"CLLOCALI"    , "C",  50,   0} ,;
                        {"CLPAIS"      , "C",  30,   0} ,;
                        {"CLTELEFONO"  , "C",  15,   0} ,;
                        {"CLMOVIL"     , "C",  15,   0} ,;
                        {"CLFAX"       , "C",  15,   0} ,;
                        {"CLCONTACTO"  , "C",  40,   0} ,;
                        {"CLEMAIL"     , "C",  50,   0} ,;
								{"CLURL"       , "C",  50,   0} ,;
								{"CLAPUNTES"   , "N",   6,   0} ,;
								{"CLAPSUMA" 	, "N",   9,   2} ,;
								{"CLPUSUMA" 	, "N",   9,   2} ,;
								{"CLPRESUPU"   , "N",   6,   0} })

   use &(oApp():cDbfPath+'cl') new
   select cl
   if File(oApp():cDbfPath+'CLIENTES.DBF')
      delete file &(oApp():cDbfPath+'clientes.cdx')
      append from &(oApp():cDbfPath+'clientes')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'clientes.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'cl.dbf') to &(oApp():cDbfPath+'clientes.dbf')

   // cat. ingresos
   oSay:SetText('Fichero de INGRESOS')
   DbCreate(oApp():cDbfPath+'in', {{"INCATEGOR"   , "C",  40,   0} ,;
											  {"INAPUNTES" , "N",   6,   0} ,;
											  {"INAPSUMA" 	, "N",   9,   2} ,;
											  {"INPUSUMA" 	, "N",   9,   2} ,;
											  {"INPRESUPU" , "N",   6,   0} ,;
											  {"INCOLOR"   , "N",  10,   0} })

   use &(oApp():cDbfPath+'in') new
   select in
   if File(oApp():cDbfPath+'INGRESOS.DBF')
      delete file &(oApp():cDbfPath+'ingresos.cdx')
      append from &(oApp():cDbfPath+'ingresos')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'ingresos.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'in.dbf') to &(oApp():cDbfPath+'ingresos.dbf')

	// cuentas corrientes
   oSay:SetText('Fichero de CUENTAS CORRIENTES')
   DbCreate(oApp():cDbfPath+'cc', {{"CCCUENTA"    , "C",  20,   0} ,;
											  {"CCBANCO"     , "C",  20,   0} ,;
											  {"CCNCUENTA"   , "C",  23,   0} ,;
											  {"CCTIPO"      , "N",   1,   0} ,; // 1 corriente 2 crédito
											  {"CCFAPERTU"   , "D",   8,   0} ,;
											  {"CCSALDOIN"   , "N",  11,   2} ,;
											  {"CCFULTIMO"   , "D",   8,   0} ,;
											  {"CCSALDOAC"   , "N",  11,   2} })

   use &(oApp():cDbfPath+'cc') new
   select cc
   if File(oApp():cDbfPath+'CUENTAS.DBF')
      delete file &(oApp():cDbfPath+'cuentas.cdx')
      append from &(oApp():cDbfPath+'cuentas')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'cuentas.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'cc.dbf') to &(oApp():cDbfPath+'cuentas.dbf')

   oSay:SetText('Fichero de TRASPASOS ENTRE CUENTAS CORRIENTES')
   DbCreate(oApp():cDbfPath+'tr', {{"TRCC1"       , "C",  20,   0} ,;
											  {"TRCC2"       , "C",  20,   0} ,;
											  {"TRFECHA"     , "D",   8,   0} ,;
											  {"TRIMPORTE"   , "N",  11,   2} ,;
											  {"TRCOMISI1"   , "N",  11,   2} ,;
											  {"TRCOMISI2"   , "N",  11,   2}  })

   use &(oApp():cDbfPath+'tr') new
   select tr
   if File(oApp():cDbfPath+'TRASPASOS.DBF')
      delete file &(oApp():cDbfPath+'traspasos.cdx')
      append from &(oApp():cDbfPath+'traspasos')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cDbfPath+'traspasos.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cDbfPath+'tr.dbf') to &(oApp():cDbfPath+'traspasos.dbf')
   if lMsg
      msgInfo( i18n( "Los datos se actualizaron correctamente." ) )
   endif

	// inventario doméstico
   oSay:SetText('Fichero de Inventario')
   DbCreate(oApp():cInvDbfPath+'bi', {{"BIDENOMI"    , "C",  50,   0} ,;
											  {"BIMARCA"     , "C",  40,   0} ,;
											  {"BICATEGOR"   , "C",  40,   0} ,;
									  		  {"BIMODELO"    , "C",  40,   0} ,;
											  {"BINSERIE"    , "C",  20,   0} ,;
											  {"BIUNIDADES"  , "N",   6,   0} ,;
											  {"BIUBICACI"   , "C",  40,   0} ,;
											  {"BIFCOMPRA"   , "D",   8,   0} ,;
									  	     {"BIFFGARANT"  , "D",   8,   0} ,;
									  		  {"BIPRECIO"    , "N",  11,   2} ,;
							  		  		  {"BIAPUNTE"    , "L",   1,   0} ,;
											  {"BITIENDA"    , "C",  40,   0} ,;
											  {"BITAGS"      , "C", 200,   0} ,;
											  {"BIOBSERV"    , "M",  10,   0} ,;
											  {"BIIMAGEN"    , "C", 120,   0} })

   use &(oApp():cInvDbfPath+'bi') new
   select bi
   if File(oApp():cInvDbfPath+'bienes.dbf')
      delete file &(oApp():cInvDbfPath+'bienes.cdx')
      append from &(oApp():cInvDbfPath+'bienes')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cInvDbfPath+'bienes.dbf')
		delete file &(oApp():cInvDbfPath+'bienes.fpt')
   endif
   DbCloseAll()
   rename &(oApp():cInvDbfPath+'bi.dbf') to &(oApp():cInvDbfPath+'bienes.dbf')
	rename &(oApp():cInvDbfPath+'bi.fpt') to &(oApp():cInvDbfPath+'bienes.fpt')

   // marcas
   oSay:SetText('Fichero de Marcas')
   DbCreate(oApp():cInvDbfPath+'ma', {{"MANOMBRE"    , "C",  40,   0} ,;
								{"MAINVEN"     , "N",   3,   0} ,;
                        {"MACIF"       , "C",  15,   0} ,;
                        {"MANOTAS"     , "C", 255,   0} ,;
                        {"MADIRECC"    , "C",  50,   0} ,;
                        {"MALOCALI"    , "C",  50,   0} ,;
                        {"MAPAIS"      , "C",  30,   0} ,;
                        {"MATELEFONO"  , "C",  50,   0} ,;
                        {"MACONTACTO"  , "C",  40,   0} ,;
                        {"MAEMAIL"     , "C",  50,   0} ,;
                        {"MAURL"       , "C",  50,   0}  })
   use &(oApp():cInvDbfPath+'ma') new
   select ma
   if File(oApp():cInvDbfPath+'MARCAS.DBF')
      delete file &(oApp():cInvDbfPath+'marcas.cdx')
      append from &(oApp():cInvDbfPath+'marcas')
      DbCommitAll()
      DbCloseAll()
      delete file &(oApp():cInvDbfPath+'marcas.dbf')
   endif
   DbCloseAll()
   rename &(oApp():cInvDbfPath+'ma.dbf') to &(oApp():cInvDbfPath+'marcas.dbf')

	// tiendas
	oSay:SetText('Fichero de Tiendas')
	DbCreate(oApp():cInvDbfPath+'ti', {{"TINOMBRE"    , "C",  40,   0} ,;
								{"TIINVEN"     , "N",   3,   0} ,;
								{"TICIF"       , "C",  15,   0} ,;
								{"TINOTAS"     , "C", 255,   0} ,;
								{"TIDIRECC"    , "C",  50,   0} ,;
								{"TILOCALI"    , "C",  50,   0} ,;
								{"TIPAIS"      , "C",  30,   0} ,;
								{"TITELEFONO"  , "C",  50,   0} ,;
								{"TICONTACTO"  , "C",  40,   0} ,;
								{"TIEMAIL"     , "C",  50,   0} ,;
								{"TIURL"       , "C",  50,   0}  })
	use &(oApp():cInvDbfPath+'ti') new
	select ti
	if File(oApp():cInvDbfPath+'TIENDAS.DBF')
		delete file &(oApp():cInvDbfPath+'tiendas.cdx')
		append from &(oApp():cInvDbfPath+'tiendas')
		DbCommitAll()
		DbCloseAll()
		delete file &(oApp():cInvDbfPath+'tiendas.dbf')
	endif
	DbCloseAll()
	rename &(oApp():cInvDbfPath+'ti.dbf') to &(oApp():cInvDbfPath+'tiendas.dbf')

	// categorias
	oSay:SetText('Fichero de Categorias')
	DbCreate(oApp():cInvDbfPath+'ca', {{"CANOMBRE"    , "C",  40,   0},;
 								{"CAINVEN"     , "N",   3,   0}})
	use &(oApp():cInvDbfPath+'ca') new
	select ca
	if File(oApp():cInvDbfPath+'CATEGOR.DBF')
		delete file &(oApp():cInvDbfPath+'categor.cdx')
		append from &(oApp():cInvDbfPath+'categor')
		DbCommitAll()
		DbCloseAll()
		delete file &(oApp():cInvDbfPath+'categor.dbf')
	endif
	DbCloseAll()
	rename &(oApp():cInvDbfPath+'ca.dbf') to &(oApp():cInvDbfPath+'categor.dbf')

	// etiquetas
	oSay:SetText('Fichero de Etiquetas')
	DbCreate(oApp():cInvDbfPath+'et', {{"ETNOMBRE"    , "C",  40,   0},;
 								{"ETINVEN"     , "N",   3,   0}})
	use &(oApp():cInvDbfPath+'et') new
	select et
	if File(oApp():cInvDbfPath+'ETIQUETA.DBF')
		delete file &(oApp():cInvDbfPath+'etiqueta.cdx')
		append from &(oApp():cInvDbfPath+'etiqueta')
		DbCommitAll()
		DbCloseAll()
		delete file &(oApp():cInvDbfPath+'etiqueta.dbf')
	endif
	DbCloseAll()
	rename &(oApp():cInvDbfPath+'et.dbf') to &(oApp():cInvDbfPath+'etiqueta.dbf')

	// ubicaciones
	oSay:SetText('Fichero de Ubicaciones')
	DbCreate(oApp():cInvDbfPath+'ub', {{"UBNOMBRE"    , "C",  40,   0},;
 								{"UBINVEN"     , "N",   3,   0}})
	use &(oApp():cInvDbfPath+'ub') new
	select ub
	if File(oApp():cInvDbfPath+'UBICACI.DBF')
		delete file &(oApp():cInvDbfPath+'ubicaci.cdx')
		append from &(oApp():cInvDbfPath+'ubicaci')
		DbCommitAll()
		DbCloseAll()
		delete file &(oApp():cInvDbfPath+'ubicaci.dbf')
	endif
	DbCloseAll()
	rename &(oApp():cInvDbfPath+'ub.dbf') to &(oApp():cInvDbfPath+'ubicaci.dbf')

	// finalizo
   oDlgT:End()
   CursorArrow()

return nil

/*_____________________________________________________________________________*/

function Ut_Indexar( lMsg )
   local oDlgProgress, oSay01, oSay02, oBmp, oProgress
   local nVar   := 0

   if oApp():oDlg != nil
      if oApp():nEdit > 0
         return nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_'+oApp():cLanguage OF oApp():oWndMain 
	oDlgProgress:SetFont(oApp():oFont)

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_INDEX' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT "Generando índices de la aplicación" ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT space(30) ID 10  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )

   oDlgProgress:bStart := { || SysRefresh(), Ut_CrearCdx(oSay02, oProgress, .t.), oDlgProgress:End() }

   ACTIVATE DIALOG oDlgProgress ;
      ON INIT DlgCenter(oDlgProgress,oApp():oWndMain)

return nil
//-----------------------------------------------------------------------//

function Ut_CrearCDX( oSay, oMeter, lMsg )

   local nPaso  := 1
   local nMeter := 0
   local cTipo, aTags, i

	field ejAnyo, ivclase, ivanyo, ivtipo, acAnyo, AcNumero, AcActivida
   field ApActivida, ApFecha, ApConcepto, ApCuenta, ApCatIngr, ApCliente, ApCatGast, ApProveed, ApTipo, ApNumero, ApIvaSop, ApIvaRep
   field PeActivida, PeFUltimo, PeFProximo, PeConcepto, PeCuenta, PeCatIngr, PeCliente, PeCatGast, PeProveed, PeTipo
   field PuActivida, PuFecha, PuConcepto, PuCuenta, PuCatIngr, PuCliente, PuCatGast, PuProveed, PuTipo
   field PrNombre, PrCif, PrContacto
   field ClNombre, ClCif, ClContacto
   field InCategor, GaCategor
 	field	CcCuenta, CcFUltimo
	field TrCC1, TrCC2, TrFecha
	field BiDenomi, BiMarca, BiCategor, BiUbicaci, BiFCompra, BiFFgarant
	field MaNombre, MaCif, MaContacto
	field TiNombre, TiCif, TiContacto
	field CaNombre, EtNombre, UbNombre
   CursorWait()

   // ejercicios
   DbCloseAll()
   if File(oApp():cExePath + 'EJERCICI.CDX')
      DELETE FILE ( oApp():cExePath + 'ejercici.cdx' )
   endif

   Db_OpenNoIndex("ejercici","EJ" )
   oSay:SetText( i18n( "Fichero de Ejercicios" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON EjAnyo TAG ej01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

	// iva
   DbCloseAll()
   if File(oApp():cExePath + 'IVA.CDX')
      DELETE FILE ( oApp():cExePath + 'iva.cdx' )
   endif

   Db_OpenNoIndex("IVA","IV" )
   oSay:SetText( i18n( "Fichero de IVA" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON ivclase+ivAnyo+str(ivtipo) TAG iv01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

   // actividades
   DbCloseAll()
   if File(oApp():cDbfPath + 'ACTIVIDA.CDX')
      DELETE FILE ( oApp():cDbfPath + 'activida.cdx' )
   endif

   Db_OpenNoIndex("activida", )
   oSay:SetText( i18n( "Fichero de Actividades" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON AcAnyo+AcNumero TAG ac01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON Upper(AcActivida) TAG ac02  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

   // apuntes
   dbCloseAll()
   if file(oApp():cDbfPath + 'APUNTES.CDX')
      DELETE FILE ( oApp():cDbfPath + 'apuntes.cdx' )
   endif

	Db_OpenNoIndex('apuntes', )
   oSay:SetText( i18n( "Fichero de Apuntes" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON upper(ApActivida)+DtoS(ApFecha) TAG ap01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DtoS(ApFecha) TAG ap02  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApConcepto)+DtoS(ApFecha) TAG ap03  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApCuenta)+DtoS(ApFecha) TAG ap04  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApCatIngr)+DtoS(ApFecha) TAG ap05  ;
      FOR ! DELETED() .AND. ApTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApCliente)+DtoS(ApFecha) TAG ap06  ;
      FOR ! DELETED() .AND. ApTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApCatGast)+DtoS(ApFecha) TAG ap07  ;
      FOR ! DELETED() .AND. ApTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApProveed)+DtoS(ApFecha) TAG ap08  ;
      FOR ! DELETED() .AND. ApTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(ApNumero) TAG ap09  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
	INDEX ON Str(ApIVASop)+Dtos(ApFecha) TAG ap10  ;
      FOR ! DELETED() .AND. ApTipo == "G" EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
	INDEX ON Str(ApIVARep)+Dtos(ApFecha) TAG ap11  ;
      FOR ! DELETED() .AND. ApTipo == "I" EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

   // apuntes periodicos
   dbCloseAll()
   if file(oApp():cDbfPath + 'PERIODI.CDX')
      DELETE FILE ( oApp():cDbfPath + 'periodi.cdx' )
   endif

	Db_OpenNoIndex('periodi', )
   oSay:SetText( i18n( "Fichero de Apuntes Periódicos" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON upper(PeActivida) TAG pe01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DtoS(PeFUltimo) TAG pe02  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DtoS(PeFProximo) TAG pe03  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PeConcepto) TAG pe04  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
	INDEX ON upper(PeCuenta) TAG pe05  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PeCatIngr) TAG pe06  ;
      FOR ! DELETED() .AND. PeTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PeCliente) TAG pe07  ;
      FOR ! DELETED() .AND. PeTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PeCatGast) TAG pe08  ;
      FOR ! DELETED() .AND. PeTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PeProveed) TAG pe09  ;
      FOR ! DELETED() .AND. PeTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

	// presupuestos
   dbCloseAll()
   if file(oApp():cDbfPath + 'PRESUPU.CDX')
      DELETE FILE ( oApp():cDbfPath + 'presupu.cdx' )
   endif

	Db_OpenNoIndex('presupu', )
   oSay:SetText( i18n( "Fichero de Presupuestos" ) )
   oMeter:SetRange( 0, LastRec()/nPaso/nPaso )
   PACK
   INDEX ON upper(PuActivida)+DtoS(PuFecha) TAG pu01  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DtoS(PuFecha) TAG pu02  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PuConcepto)+DtoS(PuFecha) TAG pu03  ;
      FOR ! DELETED() EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PuCatIngr)+DtoS(PuFecha) TAG ap05  ;
      FOR ! DELETED() .AND. PuTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PuCliente)+DtoS(PuFecha) TAG ap06  ;
      FOR ! DELETED() .AND. PuTipo == "I"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PuCatGast)+DtoS(PuFecha) TAG ap07  ;
      FOR ! DELETED() .AND. PuTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON upper(PuProveed)+DtoS(PuFecha) TAG ap08  ;
      FOR ! DELETED() .AND. PuTipo == "G"  EVAL ( oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )

   // ingresos
   DbCloseAll()
   if file(oApp():cDbfPath + 'INGRESOS.CDX')
      DELETE FILE ( oApp():cDbfPath + 'ingresos.cdx' )
   endif
   Db_OpenNoIndex('ingresos', )
   oSay:SetText( i18n( "Ingresos" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(InCategor) TAG ingresos FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   dbCloseAll()

   // gastos
   DbCloseAll()
   if file(oApp():cDbfPath + 'GASTOS.CDX')
      DELETE FILE ( oApp():cDbfPath + 'gastos.cdx' )
   endif
   Db_OpenNoIndex('gastos', )
   oSay:SetText( i18n( "Gastos" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(GaCategor) TAG gastos FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   dbCloseAll()

   // proveedores
   DbCloseAll()
   if file(oApp():cDbfPath + 'PROVEED.CDX')
      DELETE FILE ( oApp():cDbfPath + 'proveed.cdx' )
   endif
   Db_OpenNoIndex('proveed', )
   oSay:SetText( i18n( "Proveedores" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(PrNombre) TAG pr01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(PrCIF) TAG pr02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(PrContacto) TAG pr03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso


   // clientes
   DbCloseAll()
   if file(oApp():cDbfPath + 'CLIENTES.CDX')
      DELETE FILE ( oApp():cDbfPath + 'clientes.cdx' )
   endif
   Db_OpenNoIndex('clientes', )
   oSay:SetText( i18n( "Clientes" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(ClNombre) TAG cl01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(ClCIF) TAG cl02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(ClContacto) TAG cl03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

   // cuentas
   DbCloseAll()
   if file(oApp():cDbfPath + 'CUENTAS.CDX')
      DELETE FILE ( oApp():cDbfPath + 'cuentas.cdx' )
   endif
   Db_OpenNoIndex('cuentas', )
   oSay:SetText( i18n( "Cuentas" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(CcCuenta) TAG cc01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DTOS(CcFUltimo) TAG cc02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

   // cuentas
   DbCloseAll()
   if file(oApp():cDbfPath + 'TRASPASOS.CDX')
      DELETE FILE ( oApp():cDbfPath + 'traspasos.cdx' )
   endif
   Db_OpenNoIndex('traspasos', )
   oSay:SetText( i18n( "Traspasos" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(TrCC1) TAG tr01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(TrCC2) TAG tr02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DTOS(TrFecha) TAG tr03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

   // bienes
   DbCloseAll()
   if file(oApp():cInvDbfPath + 'BIENES.CDX')
      DELETE FILE ( oApp():cInvDbfPath + 'bienes.cdx' )
   endif
   Db_OpenNoIndex('bienes', 'BI'  )
   oSay:SetText( i18n( "Bienes" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(BiDenomi) TAG bi01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(BiMarca) TAG bi02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(BiCategor) TAG bi03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(BiUbicaci) TAG bi04 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON DtoS(BiFCompra) TAG bi05 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
	UtResetMeter( oMeter, @nMeter )
	INDEX ON DtoS(BiFFgarant) TAG bi06 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

   // marcas
   DbCloseAll()
   if file(oApp():cInvDbfPath + 'MARCAS.CDX')
      DELETE FILE ( oApp():cInvDbfPath + 'marcas.cdx' )
   endif
   Db_OpenNoIndex('marcas', 'MA'  )
   oSay:SetText( i18n( "Marcas" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(MaNombre) TAG ma01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(MaCIF) TAG ma02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(MaContacto) TAG ma03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

   // marcas
   DbCloseAll()
   if file(oApp():cInvDbfPath + 'TIENDAS.CDX')
      DELETE FILE ( oApp():cInvDbfPath + 'tiendas.cdx' )
   endif
   Db_OpenNoIndex('tiendas', 'TI'  )
   oSay:SetText( i18n( "Tiendas" ) )
   oMeter:setRange( 0, LastRec()/nPaso/nPaso )
   PACK
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(TiNombre) TAG ti01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(TiCIF)    TAG ti02 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso
   UtResetMeter( oMeter, @nMeter )
   INDEX ON UPPER(TiContacto) TAG ti03 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

	// categorias
	DbCloseAll()
	if file(oApp():cInvDbfPath + 'CATEGOR.CDX')
		DELETE FILE ( oApp():cInvDbfPath + 'categor.cdx' )
	endif
	Db_OpenNoIndex('categor', 'CA'  )
	oSay:SetText( i18n( "Categorias" ) )
	oMeter:setRange( 0, LastRec()/nPaso/nPaso )
	PACK
	UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(CaNombre) TAG ca01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

	// etiquetas
	DbCloseAll()
	if file(oApp():cInvDbfPath + 'ETIQUETA.CDX')
		DELETE FILE ( oApp():cInvDbfPath + 'etiqueta.cdx' )
	endif
	Db_OpenNoIndex('etiqueta', 'ET'  )
	oSay:SetText( i18n( "etiqueta" ) )
	oMeter:setRange( 0, LastRec()/nPaso/nPaso )
	PACK
	UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(EtNombre) TAG et01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

	// ubicaciones
	DbCloseAll()
	if file(oApp():cInvDbfPath + 'UBICACI.CDX')
		DELETE FILE ( oApp():cInvDbfPath + 'ubicaci.cdx' )
	endif
	Db_OpenNoIndex('ubicaci', 'UB'  )
	oSay:SetText( i18n( "ubicaciones" ) )
	oMeter:setRange( 0, LastRec()/nPaso/nPaso )
	PACK
	UtResetMeter( oMeter, @nMeter )
	INDEX ON UPPER(UbNombre) TAG ub01 FOR ! deleted() EVAL (oMeter:setPos(nMeter++), Sysrefresh()) EVERY nPaso

	// ___ actualizo los bienes en las tablas de inventario
	DbCloseAll()
	if ! Db_OpenAllInv()
		retu nil
	endif

	select MA
	replace all MA->MaInven with 0
	select CA
	replace all CA->CaInven with 0
	select UB
	replace all UB->UbInven with 0
	select TI
	replace all TI->TiInven with 0
	select ET
	replace all ET->EtInven with 0

	select BI
	BI->(DbGoTop())
	while ! BI->(eof())
		// ___ actualizo el número de bienes en la marca
	   select MA
		MA->(dbgotop())
		if ! empty(BI->BiMarca)
	   	if MA->(dbSeek(Upper(BI->BiMarca)))
	   		replace MA->MaInven with MA->MaInven + 1
			else
				MA->(DbAppend())
				replace MA->MaNombre with BI->BiMarca
				replace MA->MaInven  with 1
			endif
		endif
	   // ___ actualizo el número de bienes en la categoría
	   select CA
		CA->(dbgotop())
		if ! empty(BI->BiCategor)
	   	if CA->(dbSeek(Upper(BI->BiCategor)))
	   		replace CA->CaInven with CA->CaInven + 1
			else
				CA->(DbAppend())
				replace CA->CaNombre with BI->BiCategor
				replace CA->CaInven  with 1
			endif
		endif
		// ___ actualizo el número de bienes en la ubicación
	   select UB
		UB->(dbgotop())
		if ! empty(BI->BiUbicaci)
	   	if UB->(dbSeek(Upper(BI->BiUbicaci)))
	   		replace UB->UbInven with UB->UbInven + 1
			else
				UB->(DbAppend())
				replace UB->UbNombre with BI->BiUbicaci
				replace UB->UbInven  with 1
			endif
		endif
		// ___ actualizo el número de bienes en la tienda
	   select TI
		TI->(dbgotop())
		if ! empty(BI->BiTienda)
	   	if TI->(dbSeek(Upper(BI->BiTienda)))
	   		replace TI->TiInven with TI->TiInven + 1
			else
				TI->(DbAppend())
				replace TI->TiNombre with BI->BiTienda
				replace TI->TiInven  with 1
			endif
		endif
		// ___ actualizo el número de bienes en etiquetas __________//
		aTags := iif(At(';',BI->BiTags)!=0, hb_ATokens( BI->BiTags, ";"), {})
		if Len(aTags) > 1
			ASize( aTags, Len(aTags)-1)
			for i:=1 to Len(aTags)
				ET->(dbGoTop())
				if ET->( dbSeek( Upper(alltrim(aTags[i] )) ) )
					replace ET->EtInven with ET->EtInven + 1
				else
					ET->( dbAppend() )
					replace ET->EtNombre with aTags[i]
					replace ET->EtInven  with 1
				endif
			next
		endif
		BI->(DbSkip())
	enddo
   dbCloseAll()

	// actualizo datos de apuntes y presupuestos
	if ! Db_OpenAll()
		retu nil
	endif
	select IN 
	replace IN->InApuntes with 0 all
	replace IN->InPresupu with 0 all
	replace IN->InApSuma  with 0 all
	replace IN->InPuSuma  with 0 all
	select CL 
	replace CL->ClApuntes with 0 all
	replace CL->ClPresupu with 0 all
	replace CL->ClApSuma  with 0 all
	replace CL->ClPuSuma  with 0 all
	select GA
	replace GA->GaApuntes with 0 all
	replace GA->GaPresupu with 0 all
	replace GA->GaApSuma  with 0 all
	replace GA->GaPuSuma  with 0 all
	select PR 
	replace PR->PrApuntes with 0 all
	replace PR->PrPresupu with 0 all
	replace PR->PrApSuma  with 0 all
	replace Pr->PrPuSuma  with 0 all
 	DbCommitAll()

	oMeter:setRange( 0, AP->(LastRec()) )
	UtResetMeter( oMeter, @nMeter )
	select AP
	AP->(OrdSetFocus(1))
	AP->(DbGoTop())
	while ! AP->(eof())
		oSay:SetText( "Revisando apunte "+AP->ApNumero )
		// ___ actualizo el número de apuntes en ingresos
		if ! empty(AP->ApCatIngr)
	   	select IN
  			IN->(dbgotop())
			if IN->(dbSeek(Upper(AP->ApCatIngr)))
	   		replace IN->InApuntes with IN->InApuntes + 1
				replace IN->InApSuma	 with IN->InApSuma + AP->ApImpTotal
			else
				IN->(DbAppend())
				replace IN->InCategor with AP->ApCatIngr
				replace IN->InApuntes with 1
				replace IN->InApSuma	 with AP->ApImpTotal
				? 'Añadida la categoría de ingresos '+ IN->InCategor
			endif
		endif
		if ! empty(AP->ApCliente)
	   	select CL
  			CL->(dbgotop())
			if CL->(dbSeek(Upper(AP->ApCliente)))
	   		replace CL->ClApuntes with CL->ClApuntes + 1
				replace CL->ClApSuma	 with CL->ClApSuma + AP->ApImpTotal
			else
				CL->(DbAppend())
				replace CL->ClNombre with AP->ApCliente
				replace CL->ClApuntes with 1
				replace CL->ClApSuma	 with AP->ApImpTotal
				? 'Añadido el perceptor '+ CL->ClNombre
			endif
		endif
		if ! empty(AP->ApCatGast)
	   	select GA
  			GA->(dbgotop())
			if GA->(dbSeek(Upper(AP->ApCatGast)))
	   		replace GA->GaApuntes with GA->GaApuntes + 1
				replace GA->GaApSuma	 with GA->GaApSuma + AP->ApImpTotal
			else
				GA->(DbAppend())
				replace GA->GaCategor with AP->ApCatGast
				replace GA->GaApuntes with 1
				replace GA->GaApSuma	 with AP->ApImpTotal
				? 'Añadida la categoría de gastos '+ GA->GaCategor
			endif
		endif
		if ! empty(AP->ApProveed)
	   	select PR
  			PR->(dbgotop())
			if PR->(dbSeek(Upper(AP->ApProveed)))
	   		replace PR->PrApuntes with PR->PrApuntes + 1
				replace PR->PrApSuma	 with PR->PrApSuma + AP->ApImpTotal
			else
				PR->(DbAppend())
				replace PR->PrNombre with AP->ApProveed
				replace PR->PrApuntes with 1
				replace PR->PrApSuma	 with AP->ApImpTotal
				? 'Añadido el pagador '+ CL->ClNombre
			endif
		endif
		/*
		IF ! Empty(AP->ApUbicaci)
			SELECT UB
			UB->(dbgotop())
			IF UB->(dbSeek(Upper(AP->ApUbicaci)))
				REPLACE UB->UbInven WITH UB->UbInven + 1
			ELSE
				UB->(DbAppend())
				REPLACE UB->UbNombre WITH AP->ApUbicaci
				REPLACE UB->UbTipo WITH 'A'
				REPLACE UB->UbInven WITH 1
				? 'Añadida la ubicación '+ AP->ApUbicaci
			ENDIF
		ENDIF
		*/
		DbCommitAll()
		AP->(DbSkip())
		oMeter:setPos(nMeter++)
 		Sysrefresh()
	enddo
	oMeter:setRange( 0, PU->(LastRec()) )
	UtResetMeter( oMeter, @nMeter )
	select PU
	PU->(OrdSetFocus(1))
	PU->(DbGoTop())
	while ! PU->(eof())
		// oSay:SetText( "Revisando presupuesto "+PU->PuNumero )
		// ___ actualizo el número de Presupu en ingresos
		if ! empty(PU->PuCatIngr)
	   	select IN
  			IN->(dbgotop())
			if IN->(dbSeek(Upper(PU->PuCatIngr)))
	   		replace IN->InPresupu with IN->InPresupu + 1
				replace IN->InPuSuma	 with IN->InPuSuma + PU->PuImpTotal
			else
				IN->(DbAppend())
				replace IN->InCategor with PU->PuCatIngr
				replace IN->InPresupu with 1
				replace IN->InPuSuma	 with PU->PuImpTotal
				? 'Añadida la categoría de ingresos '+ IN->InCategor
			endif
		endif
		if ! empty(PU->PuCliente)
	   	select CL
  			CL->(dbgotop())
			if CL->(dbSeek(Upper(PU->PuCliente)))
	   		replace CL->ClPresupu with CL->ClPresupu + 1
				replace CL->ClPuSuma	 with CL->ClPuSuma + PU->PuImpTotal
			else
				CL->(DbAppend())
				replace CL->ClNombre with PU->PuCliente
				replace CL->ClPresupu with 1
				replace CL->ClPuSuma	 with PU->PuImpTotal
				? 'Añadido el perceptor '+ CL->ClNombre
			endif
		endif
		if ! empty(PU->PuCatGast)
	   	select GA
  			GA->(dbgotop())
			if GA->(dbSeek(Upper(PU->PuCatGast)))
	   		replace GA->GaPresupu with GA->GaPresupu + 1
				replace GA->GaPuSuma	 with GA->GaPuSuma + PU->PuImpTotal
			else
				GA->(DbAppend())
				replace GA->GaCategor with PU->PuCatGast
				replace GA->GaPresupu with 1
				replace GA->GaPuSuma	 with PU->PuImpTotal
				? 'Añadida la categoría de gastos '+ GA->GaCategor
			endif
		endif
		if ! empty(PU->PuProveed)
	   	select PR
  			PR->(dbgotop())
			if PR->(dbSeek(Upper(PU->PuProveed)))
	   		replace PR->PrPresupu with PR->PrPresupu + 1
				replace PR->PrPuSuma	 with PR->PrPuSuma + PU->PuImpTotal
			else
				PR->(DbAppend())
				replace PR->PrNombre with PU->PuProveed
				replace PR->PrPresupu with 1
				replace PR->prPuSuma	 with PU->PuImpTotal
				? 'Añadido el pagador '+ CL->ClNombre
			endif
		endif
		/*
		IF ! Empty(PU->PuUbicaci)
			SELECT UB
			UB->(dbgotop())
			IF UB->(dbSeek(Upper(PU->PuUbicaci)))
				REPLACE UB->UbPresupu WITH UB->UbPresupu + 1
			ELSE
				UB->(DbAppend())
				REPLACE UB->UbNombre WITH PU->PuUbicaci
				REPLACE UB->UbTipo WITH 'A'
				REPLACE UB->UbPresupu WITH 1
				? 'Añadida la ubicación '+ DO->DoUbicaci
			ENDIF
		ENDIF
		*/
		DbCommitAll()
		PU->(DbSkip())
		oMeter:setPos(nMeter++)
 		Sysrefresh()
	enddo
	DbCloseAll()
   CursorArrow()

   if lMsg
      msgInfo( i18n( "La regeneración de índices se realizó correctamente." ) )
   endif

return nil

/*_____________________________________________________________________________*/

function UtResetMeter( oMeter, nMeter )

   nMeter := 0
   oMeter:setPos(nMeter)
   sysrefresh()

return nil

//_____________________________________________________________________________//


