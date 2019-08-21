#include "FiveWin.ch"
#include "Report.ch"
STATIC aTipo   := { "Capítulo 2", "Nómina", "Prestación", "Proveedor" }

CLASS TInforme
   DATA aCampos, aTitulos, aWidth, aShow, aPicture, aTotal  AS ARRAY
   DATA hBmp
   DATA cReport, cRptFont           //AS STRING
   DATA nRadio                      AS NUMERIC
   DATA cTitulo1, cTitulo2, cTitulo3, cAlias  //AS STRING
   DATA cDlgTitle

   DATA aoFont, aoSizes, aoEstilo, acSizes, acEstilo, acFont, aSizes, aEstilo, aFont AS ARRAY
   DATA nDevice                     AS NUMERIC
   DATA oDlg, oFld, oRadio, oLbx, oGet, oSay, oCheck, oGet1, oGet2, oGet3  AS OBJECT
   DATA oBtnUp, oBtnDown, oBtnShow, oBtnHide, oFont1, oFont2, oFont3 AS OBJECT
   DATA oReport AS OBJECT
   DATA lSummary
	DATA cPdfFile

   METHOD New(aCampos, aTitulos, aWidth, aShow, aPicture, aTotal)    CONSTRUCTOR
   METHOD Dialog()
   METHOD Folders()
   METHOD Activate()
   METHOD Report()
   METHOD ReportInit()
   METHOD ReportEnd()
   METHOD End()
ENDCLASS

METHOD New(aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, cAlias) CLASS TInforme
   LOCAL i, cToken

   ::aCampos   := aCampos
   ::aTitulos  := aTitulos
   ::aWidth    := aWidth
   ::aShow     := aShow
   ::aPicture  := aPicture
   ::aTotal    := aTotal
   ::cAlias    := cAlias

   ::cReport   := GetPvProfString("Report", ::cAlias+"Report","",oApp():cIniFile)
   ::cRptFont  := GetPvProfString("Report", ::cAlias+"RptFont","",oApp():cIniFile)
   ::nRadio    := VAL(GetPvProfString("Report", ::cAlias+"Radio",1,oApp():cIniFile))
   ::cTitulo1  := GetPvProfString("Report", ::cAlias+"Titulo1",space(50),oApp():cIniFile)
   ::cTitulo2  := GetPvProfString("Report", ::cAlias+"Titulo2",space(50),oApp():cIniFile)
	::cTitulo3	:= NIL
	::cPdfFile  := GetPvProfString("Report", ::cAlias+"PdfFile","listado.pdf",oApp():cIniFile)
	::cPdfFile  := ::cPdfFile+Space(50-Len(::cPdfFile))

   ::hBmp      := LoadBitmap( 0, 32760 )

   ::aoFont    := { , , }
   ::aoSizes   := { , , }
   ::aoEstilo  := { , , }
   ::acSizes   := { "10", "10", "10" }
   ::acEstilo  := { "Normal", "Normal", "Normal" }
   ::acFont    := { "Courier New", "Courier New", "Courier New" }
   ::aSizes    := { "08", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "36", "48", "72" }
   ::aEstilo   := { i18n("Cursiva"), i18n("Negrita"), i18n("Negrita Cursiva"),  i18n("Normal") }
   ::nDevice   := 0

   ::cTitulo1  := Rtrim(::cTitulo1)+Space(50-LEN(::cTitulo1))
   ::cTitulo2  := Rtrim(::cTitulo2)+Space(50-LEN(::cTitulo2))
   ::lSummary  := .f.
   do case
      case ::cAlias == "EJ"
         ::cDlgTitle := "Informes de ejercicios"
      case ::cAlias == "APIN"
         ::cDlgTitle := "Informes de apuntes de ingresos"
      case ::cAlias == "APGA"
         ::cDlgTitle := "Informes de apuntes de gastos"
      case ::cAlias == "APAP"
         ::cDlgTitle := "Informes de apuntes"
		case ::cAlias == "PUPU"
         ::cDlgTitle := "Informes de presupuestos"
      case ::cAlias == "IN"
         ::cDlgTitle := "Informes de tipos de ingresos"
      case ::cAlias == "AC"
         ::cDlgTitle := "Informes de actividades"
      case ::cAlias == "GA"
         ::cDlgTitle := "Informes de tipos de gastos"
      case ::cAlias == "PR"
         ::cDlgTitle := "Informes de perceptores"
      case ::cAlias == "CL"
         ::cDlgTitle := "Informes de pagadores"
      case ::cAlias == "PEAP"
         ::cDlgTitle := "Informes de previsión de ingresos y gastos"
		case ::cAlias == "TI"
			::cDlgTitle := "Informe de tiendas"
		case ::cAlias == "MA"
			::cDlgTitle := "Informe de marcas"
		case ::cAlias == "MA"
			::cDlgTitle := "Informe de ubicaciones"
		case ::cAlias == "ET"
			::cDlgTitle := "Informe de etiquetas"
		case ::cAlias == "CA"
			::cDlgTitle := "Informe de categorías"
		case ::cAlias == "BI"
			::cDlgTitle := "Informe de bienes"
   endcase
   IF ! empty(::cReport)
      FOR i := 1 TO Len(aCampos)
         cToken         := StrToken(::cReport,i,";")
         ::aCampos[i]   := StrToken(cToken,1,":")
         ::aTitulos[i]  := StrToken(cToken,2,":")
         ::aWidth[i]    := VAL(StrToken(cToken,3,":"))
         ::aShow[i]     := AllTrim(StrToken( cToken, 4, ":" ) ) == "S"
         ::aPicture[i]  := StrToken(cToken,5,":")
         ::aTotal[i]    := AllTrim(StrToken( cToken, 6, ":" ) ) == "S"
      NEXT
   ENDIF
   IF ! empty(:: cRptFont)
      FOR i:=1 TO 3
         cToken         := StrToken(::cRptFont,i,";")
         ::acFont[i]    := StrToken(cToken,1,":")
         ::acSizes[i]   := StrToken(cToken,2,":")
         ::acEstilo[i]  := StrToken(cToken,3,":")
      NEXT
   ENDIF
   ::aFont := aGetFont( oApp():oWndMain )
RETURN Self

METHOD Dialog() CLASS TInforme
	local cDlgName
	if ::cAlias == "APIN" .OR. ::cAlias == "APGA" .OR. ::cAlias == "BI"
		cDlgName := "INFORMEXL"
	else
		cDlgName := "INFORME"
	endif

   DEFINE DIALOG ::oDlg RESOURCE cDlgName ;
      TITLE ::cDlgTitle
	::oDlg:SetFont(oApp():oFont)

   REDEFINE FOLDER ::oFld ;
      ID 100 OF ::oDlg    ;
      ITEMS " &Tipo de informe ", " &Selección de campos ", " &Encabezado y tipografía ", " PDF ";
      DIALOGS "INFORME1"+::cAlias, "INFORME2", "INFORME3", "INFORME4" ;
      OPTION 1

RETURN NIL

METHOD Folders() CLASS TInforme
	local i
	local aArray := {}
	local oCol

	::oLbx := TXBrowse():New( ::oFld:aDialogs[2] )

	For i := 1 to len(::aTitulos)
		Aadd( aArray, {::aShow[i],::aTitulos[i],::aWidth[i]} )
	Next

	::oLbx:SetArray(aArray)
	Ut_BrwRowConfig( ::oLbx )
   ::oLbx:nDataType 	:= 1 // array
	::oLbx:bChange		:= { || (::oGet:Refresh(),::oCheck:Refresh(),::oFld:aDialogs[2]:AEvalWhen() ) }


   ::oLbx:aCols[1]:cHeader  := i18n("Mostrar")
   ::oLbx:aCols[1]:nWidth   := 44
  	::oLbx:aCols[1]:AddResource("16_CHECK")
   ::oLbx:aCols[1]:AddResource(" ")
   ::oLbx:aCols[1]:bBmpData := { || if(aArray[::oLbx:nArrayAt,1]==.t.,1,2)}
 	::olbx:aCols[1]:bStrData := {|| NIL }

   ::oLbx:aCols[2]:cHeader  := i18n("Columna")
   ::oLbx:aCols[2]:nWidth   := 134

   ::oLbx:aCols[3]:cHeader  := i18n("Ancho")
   ::oLbx:aCols[3]:nWidth   := 70

   FOR i := 1 TO LEN(::oLbx:aCols)
      oCol := ::oLbx:aCols[ i ]
		oCol:bLDClickData  := { || IIF(::aShow[ ::oLbx:nArrayAt ],::oBtnHide:Click(),::oBtnShow:Click()) }
      oCol:bClrSelFocus  := { || { CLR_BLACK, nRGB(202,224,252) } }
      // ::oCol:bPaintText 	:= { |::oCol, hDC, cData, aRect | Ut_PaintColArray( ::oCol, hDC, cData, aRect ) }
   NEXT
	::oLbx:CreateFromResource( 200 )

   REDEFINE Say ::oSay ID 210 OF ::oFld:aDialogs[2]

   REDEFINE GET ::oGet VAR ::aWidth[ ::oLbx:nArrayAt ] ;
      ID       211   ;
      SPINNER        ;
      MIN      1     ;
      MAX      99    ;
      PICTURE  "99"  ;
      VALID    ::aWidth[ ::oLbx:nArrayAt ] > 0 ;
      OF       ::oFld:aDialogs[2]
	::oGet:bChange    := {|| (::oLbx:aArrayData[::oLbx:nArrayAt,3] := ::aWidth[::oLbx:nArrayAt], ::oLbx:Refresh()) }
	::oGet:bLostFocus := {|| (::oLbx:aArrayData[::oLbx:nArrayAt,3] := ::aWidth[::oLbx:nArrayAt], ::oLbx:Refresh()) }

   REDEFINE CHECKBOX ::oCheck VAR ::aTotal[ ::oLbx:nArrayAt ] ;
      ID 212 OF ::oFld:aDialogs[2] UPDATE          ;
      WHEN ::aPicture[ ::oLbx:nArrayAt ] != "NO"

   REDEFINE BUTTON ::oBtnUp       ;
      ID       201                ;
      OF       ::oFld:aDialogs[2] ;
      WHEN ::oLbx:nArrayAt > 1    ;
      ACTION IIF( ::oLbx:nArrayAt > 1,;
                ( SwapUpArray( ::aShow   , ::oLbx:nArrayAt ) ,;
                  SwapUpArray( ::aTitulos, ::oLbx:nArrayAt ) ,;
                  SwapUpArray( ::aCampos , ::oLbx:nArrayAt ) ,;
                  SwapUpArray( ::aWidth  , ::oLbx:nArrayAt ) ,;
                  SwapUpArray( ::aPicture, ::oLbx:nArrayAt ) ,;
                  SwapUpArray( ::oLbx:aArrayData, ::oLbx:nArrayAt ) ,;
						::oLbx:nArrayAt -- ,;
                  ::oLbx:Refresh()  ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON ::oBtnDown   ;
      ID    202                 ;
      OF    ::oFld:aDialogs[2]  ;
      WHEN ::oLbx:nArrayAt < Len(::aTitulos) ;
      ACTION IIF( ::oLbx:nArrayAt < Len(::aTitulos),  ;
                ( SwapDwArray( ::aShow   , ::oLbx:nArrayAt ) ,;
                  SwapDwArray( ::aTitulos, ::oLbx:nArrayAt ) ,;
                  SwapDwArray( ::aCampos , ::oLbx:nArrayAt ) ,;
                  SwapDwArray( ::aWidth  , ::oLbx:nArrayAt ) ,;
                  SwapDwArray( ::aPicture, ::oLbx:nArrayAt ) ,;
						SwapDwArray( ::oLbx:aArrayData, ::oLbx:nArrayAt ) ,;
                  ::oLbx:nArrayAt ++ ,;
                  ::oLbx:Refresh()  ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON ::oBtnShow   ;
      ID    203                 ;
      OF    ::oFld:aDialogs[2]  ;
      WHEN ( ! ::aShow[ ::oLbx:nArrayAt ] ) ;
      ACTION ( ::aShow[ ::oLbx:nArrayAt ] := .t., ;
					::oLbx:aArrayData[::oLbx:nArrayAt,1] := .t., ::oLbx:Refresh(),;
					::oLbx:SetFocus(), ::oLbx:Refresh() )

   REDEFINE BUTTON ::oBtnHide   ;
      ID     204                ;
      OF     ::oFld:aDialogs[2] ;
      WHEN ( ::aShow[ ::oLbx:nArrayAt ] .AND. aScanN( ::aShow, .t. ) > 1 ) ;
      ACTION ( ::aShow[ ::oLbx:nArrayAt ] := .f.,;
 					::oLbx:aArrayData[::oLbx:nArrayAt,1] := .f., ::oLbx:Refresh(),;
					::oLbx:SetFocus(), ::oLbx:Refresh() )

   REDEFINE SAY ID 100 OF ::oFld:aDialogs[3]
   REDEFINE SAY ID 101 OF ::oFld:aDialogs[3]
   REDEFINE SAY ID 102 OF ::oFld:aDialogs[3]
   REDEFINE GET ::oGet1 VAR ::cTitulo1 ;
      ID 200 OF ::oFld:aDialogs[3] UPDATE
   REDEFINE GET ::oGet2 VAR ::cTitulo2 ;
      ID 201 OF ::oFld:aDialogs[3] UPDATE

   REDEFINE SAY ID 211 OF ::oFld:aDialogs[3]
   REDEFINE SAY ID 212 OF ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoFont[1] VAR ::acFont[1] ;
      ID       213 ;
      ITEMS    ::aFont ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoSizes[1] VAR ::acSizes[1] ;
      ID       214 ;
      ITEMS    ::aSizes ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoEstilo[1] VAR ::acEstilo[1] ;
      ID       215 ;
      ITEMS    ::aEstilo ;
      OF       ::oFld:aDialogs[3]

   REDEFINE SAY ID 216 OF ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoFont[2] VAR ::acFont[2] ;
      ID       217 ;
      ITEMS    ::aFont ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoSizes[2] VAR ::acSizes[2] ;
      ID       218 ;
      ITEMS    ::aSizes ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoEstilo[2] VAR ::acEstilo[2] ;
      ID       219 ;
      ITEMS    ::aEstilo ;
      OF       ::oFld:aDialogs[3]

   REDEFINE SAY ID 220 OF ::oFld:aDialogs[3]
   REDEFINE COMBOBOX ::aoFont[3] VAR ::acFont[3] ;
      ID       221 ;
      ITEMS    ::aFont ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoSizes[3] VAR ::acSizes[3] ;
      ID       222 ;
      ITEMS    ::aSizes ;
      OF       ::oFld:aDialogs[3]

   REDEFINE COMBOBOX ::aoEstilo[3] VAR ::acEstilo[3] ;
      ID       223 ;
      ITEMS    ::aEstilo ;
      OF       ::oFld:aDialogs[3]

	// 4º folder: PDF
	REDEFINE SAY ID 100 OF ::oFld:aDialogs[4]
	REDEFINE SAY ID 101 OF ::oFld:aDialogs[4]

	REDEFINE GET ::oGet3 VAR ::cPdfFile  ;
		ID 200 OF ::oFld:aDialogs[4]    ;
		VALID PdfFileValid(::cPdfFile, ::oGet3)

	REDEFINE SAY ID 211 OF ::oFld:aDialogs[4]
	REDEFINE SAY ID 212 OF ::oFld:aDialogs[4] ;
	PROMPT iif(oApp():oRebar:nOption==1,oApp():cPdfPath,oApp():cInvPdfPath)

   REDEFINE BUTTON ;
      ID       101 ;
      OF       ::oDlg ;
      ACTION   ( ::nDevice := 1, ::oDlg:end( IDOK ) )

   REDEFINE BUTTON ;
      ID       102 ;
      OF       ::oDlg ;
      ACTION   ( ::nDevice := 2, ::oDlg:end( IDOK ) )

   REDEFINE BUTTON ;
      ID       103 ;
      OF       ::oDlg ;
      ACTION   ::oDlg:end( IDCANCEL )

RETURN Nil

METHOD Activate() CLASS TInforme
   local o := self
   ACTIVATE DIALOG ::oDlg ;
      ON INIT DlgCenter(o:oDlg,oApp():oWndMain)

RETURN ( ::oDlg:nResult == IDOK )

METHOD Report(lResumen) CLASS TInforme
   LOCAL i
   DEFAULT lResumen := .f.

	::lSummary := lResumen

   ::oFont1 := TFont():New( Rtrim( ::acFont[ 1 ] ), 0, Val( ::acSizes[ 1 ] ),,( i18n("Negrita") $ ::acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 1 ] ),,,,,,, )
   ::oFont2 := TFont():New( Rtrim( ::acFont[ 2 ] ), 0, Val( ::acSizes[ 2 ] ),,( i18n("Negrita") $ ::acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 2 ] ),,,,,,, )
   ::oFont3 := TFont():New( Rtrim( ::acFont[ 3 ] ), 0, Val( ::acSizes[ 3 ] ),,( i18n("Negrita") $ ::acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 3 ] ),,,,,,, )

   ::cTitulo1 := Rtrim(::cTitulo1)
   ::cTitulo2 := Rtrim(::cTitulo2)

   IF ::nDevice == 1
   	IF ! ::lSummary
      	REPORT ::oReport ;
		   TITLE  " ",::cTitulo1,::cTitulo2,iif(::cTitulo3!=NIL,::cTitulo3," ") CENTERED;
      	FONT   ::oFont3, ::oFont2, ::oFont1 ;
      	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
      	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      	CAPTION oApp():cAppName+oApp():cVersion PREVIEW
      ELSE
      	REPORT ::oReport ;
		   TITLE  " ",::cTitulo1,::cTitulo2,iif(::cTitulo3!=NIL,::cTitulo3," ") CENTERED;
      	FONT   ::oFont3, ::oFont2, ::oFont1 ;
      	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
      	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      	CAPTION oApp():cAppName+oApp():cVersion PREVIEW SUMMARY
      ENDIF
   ELSEIF ::nDevice == 2
   	IF ! ::lSummary
      	REPORT ::oReport ;
		   TITLE  " ",::cTitulo1,::cTitulo2,iif(::cTitulo3!=NIL,::cTitulo3," ") CENTERED;
      	FONT   ::oFont3, ::oFont2, ::oFont1 ;
      	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
      	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      	CAPTION oApp():cAppName+oApp():cVersion // PREVIEW
      ELSE
      	REPORT ::oReport ;
		   TITLE  " ",::cTitulo1,::cTitulo2,iif(::cTitulo3!=NIL,::cTitulo3," ") CENTERED;
      	FONT   ::oFont3, ::oFont2, ::oFont1 ;
      	HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
      	FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      	CAPTION oApp():cAppName+oApp():cVersion SUMMARY // PREVIEW SUMMARY
      ENDIF
   ENDIF

   FOR i := 1 TO Len(::aTitulos)
      IF ::aShow[i]
         if ::aPicture[i] == "NO"
            RptAddColumn( {bTitulo(::aTitulos,i)},,{bCampo(::aCampos,i)},::aWidth[i],{},{||1},.F.,,,.F.,.F.,)
         elseif ::aPicture[i] == "AP01"
   			COLUMN TITLE "Imp. Neto" DATA IIF(AP->ApTipo=="I",AP->ApImpNeto,(-1)*AP->ApImpNeto) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
         elseif ::aPicture[i] == "AP02"
   			COLUMN TITLE "Imp. Total" DATA IIF(AP->ApTipo=="I",AP->ApImpTotal,(-1)*AP->ApImpTotal) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
			elseif ::aPicture[i] == "APG1"
				COLUMN TITLE "Iva Sop." DATA Ap->ApImpNeto*AP->ApIvaSop/100 SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
			elseif ::aPicture[i] == "API1"
				COLUMN TITLE "Iva Rep." DATA Ap->ApImpNeto*AP->ApIvaRep/100 SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
			elseif ::aPicture[i] == "PE01"
				COLUMN TITLE "Imp. Neto" DATA IIF(PE->PeTipo=="I",PE->PeImpNeto,(-1)*PE->PeImpNeto) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99"
			elseif ::aPicture[i] == "PE02"
				COLUMN TITLE "Imp. Total" DATA IIF(PE->PeTipo=="I",PE->PeImpTotal,(-1)*PE->PeImpTotal) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99"
         elseif ::aPicture[i] == "PU01"
   			COLUMN TITLE "Imp. Neto" DATA IIF(PU->PuTipo=="I",PU->PuImpNeto,(-1)*PU->PuImpNeto) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
         elseif ::aPicture[i] == "PU02"
   			COLUMN TITLE "Imp. Total" DATA IIF(PU->PuTipo=="I",PU->PuImpTotal,(-1)*PU->PuImpTotal) SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
			elseif ::aPicture[i] == "PUG1"
				COLUMN TITLE "Iva Sop." DATA PU->PuImpNeto*PU->PuIvaSop/100 SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
			elseif ::aPicture[i] == "PUI1"
				COLUMN TITLE "Iva Rep." DATA PU->PuImpNeto*PU->PuIvaRep/100 SIZE ::aWidth[i] FONT 1 PICTURE "@E 9,999,999.99" TOTAL
         else
            RptAddColumn( {bTitulo(::aTitulos,i)},,{bCampo(::aCampos,i)},::aWidth[i],{bPicture(::aPicture,i)},{||1},::aTotal[i],,,.F.,.F.,)
         endif
      ENDIF
   NEXT
   // defino los grupos para los informes
   do case
   	case ::cAlias == "APIN"
   		if ::nRadio == 2
		   	GROUP ON AP->ApCatIngr ;
        		   FOOTER " » Total tipo de ingreso » "+::oReport:aGroups[1]:cValue ; // +"("+ltrim(str(::oReport:aGroups[1]:nCounter))+")" ;
         		FONT 1
         endif
   		if ::nRadio == 4
		   	GROUP ON AP->ApCliente ;
        		   FOOTER " » Total pagador » "+::oReport:aGroups[1]:cValue ; // +"("+ltrim(str(::oReport:aGroups[1]:nCounter))+")" ;
         		FONT 1
         endif
   	case ::cAlias == "APGA"
   		if ::nRadio == 2
		   	GROUP ON AP->ApCatGast ;
        		   FOOTER " » Total tipo de gasto » "+::oReport:aGroups[1]:cValue ; // +"("+ltrim(str(::oReport:aGroups[1]:nCounter))+")" ;
         		FONT 1
         endif
   		if ::nRadio == 4
		   	GROUP ON AP->ApProveed ;
        		   FOOTER " » Total perceptor » "+::oReport:aGroups[1]:cValue ; // +"("+ltrim(str(::oReport:aGroups[1]:nCounter))+")" ;
         		FONT 1
         endif
   end case
	::oReport:Cargo := ::cPdfFile
   END REPORT

   IF ::oReport:lCreated
      ::oReport:nTitleUpLine     := RPT_SINGLELINE
      ::oReport:nTitleDnLine     := RPT_SINGLELINE
      ::oReport:oTitle:aFont[2]  := {|| 3 }
      ::oReport:oTitle:aFont[3]  := {|| 2 }
      ::oReport:nTopMargin       := 0.1
      ::oReport:nDnMargin        := 0.1
      ::oReport:nLeftMargin      := 0.1
      ::oReport:nRightMargin     := 0.1
      ::oReport:oDevice:lPrvModal:= .t.
   ENDIF
RETURN NIL

METHOD End(lSaveTitle) CLASS TInforme
   LOCAL i

   RELEASE FONT ::oFont1
   RELEASE FONT ::oFont2
   RELEASE FONT ::oFont3

   ::cReport   := ""
   FOR i:=1 TO Len(::aCampos)
      ::cReport := ::cReport + ::aCampos[i]+":"
      ::cReport := ::cReport + ::aTitulos[i]+":"
      ::cReport := ::cReport + STR(::aWidth[i],2)+":"
      ::cReport := ::cReport + IIF(::aShow[i],"S","N")+":"
      ::cReport := ::cReport + ::aPicture[i]+":"
      ::cReport := ::cReport + IIF(::aTotal[i],"S","N")+";"
   NEXT

   ::cRptFont  := ""
   FOR i:=1 TO 3
      ::cRptFont := ::cRptFont + ::acFont[i]+":"
      ::cRptFont := ::cRptFont + ::acSizes[i]+":"
      ::cRptFont := ::cRptFont + ::acEstilo[i]+";"
   NEXT

   WritePProString("Report",::cAlias+"Report",::cReport,oApp():cIniFile)
   WritePProString("Report",::cAlias+"RptFont",::cRptFont,oApp():cIniFile)
   WritePProString("Report",::cAlias+"Radio",Ltrim(Str(::nRadio)),oApp():cIniFile)
   if lSaveTitle
      WritePProString("Report",::cAlias+"Titulo1",::cTitulo1,oApp():cIniFile)
      WritePProString("Report",::cAlias+"Titulo2",::cTitulo2,oApp():cIniFile)
   endif
	WritePProString("Report",::cAlias+"PdfFile",::cPdfFile,oApp():cIniFile)
RETURN NIL

METHOD ReportInit() CLASS TInforme
	/*
   LOCAL i
   ::oFont1 := TFont():New( Rtrim( ::acFont[ 1 ] ), 0, Val( ::acSizes[ 1 ] ),,( i18n("Negrita") $ ::acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 1 ] ),,,,,,, )
   ::oFont2 := TFont():New( Rtrim( ::acFont[ 2 ] ), 0, Val( ::acSizes[ 2 ] ),,( i18n("Negrita") $ ::acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 2 ] ),,,,,,, )
   ::oFont3 := TFont():New( Rtrim( ::acFont[ 3 ] ), 0, Val( ::acSizes[ 3 ] ),,( i18n("Negrita") $ ::acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ ::acEstilo[ 3 ] ),,,,,,, )

   ::cTitulo1 := Rtrim(::cTitulo1)
   ::cTitulo2 := Rtrim(::cTitulo2)

   IF ::nDevice == 1
      REPORT ::oReport ;
      TITLE  " "," ",::cTitulo1,::cTitulo2," " CENTERED;
      FONT   ::oFont3, ::oFont2, ::oFont1 ;
      HEADER ' ', oApp():cAppName+oApp():cVersion;
      FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      CAPTION oApp():cAppName+oApp():cVersion PREVIEW
   ELSEIF ::nDevice == 2
      REPORT ::oReport ;
      TITLE  " "," ",::cTitulo1,::cTitulo2," " CENTERED;
      FONT   ::oFont3, ::oFont2, ::oFont1 ;
      HEADER ' ', oApp():cAppName+oApp():cAppName+oApp():cVersion;
      FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(::oReport:nPage,3) ;
      CAPTION oApp():cAppName+oApp():cVersion //PREVIEW
   ENDIF
   */
RETURN NIL


METHOD ReportEnd() CLASS TInforme
   END REPORT
   IF ::oReport:lCreated
      ::oReport:nTitleUpLine     := RPT_SINGLELINE
      ::oReport:nTitleDnLine     := RPT_SINGLELINE
      ::oReport:oTitle:aFont[2]  := {|| 3 }
      ::oReport:oTitle:aFont[3]  := {|| 2 }
      ::oReport:nTopMargin       := 0.1
      ::oReport:nDnMargin        := 0.1
      ::oReport:nLeftMargin      := 0.1
      ::oReport:nRightMargin     := 0.1
      ::oReport:oDevice:lPrvModal:= .t.
   ENDIF
RETURN NIL

Function PdfFileValid(cPdfFile, oGet)
	if Lower(Right(RTrim(cPdfFile),4))!=".pdf"
		cPdfFile := RTrim(cPdfFile) + ".pdf"
	endif
	oGet:cText( cPdfFile )
return .t.
