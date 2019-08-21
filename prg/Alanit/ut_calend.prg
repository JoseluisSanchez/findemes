#include "FiveWin.ch"
#include "calendar.ch"

Function SelecFecha(dFechaPres, oGet)

   local oDlg, oButton1, oButton2, oSayFecha, oCalendar
   local lOk := .f.
   local dFecha
   local aPoint := AdjustWnd(oGet, 97*2, 88*2)

   IF Empty(dFechaPres)
      dFecha := Date()
   ELSE
      dFecha := dFechaPres
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'Ut_Calendar'       ;
      TITLE "Selección de fecha"                   ;
      COLOR GetSysColor(18), GetSysColor(15)
   oDlg:lHelpIcon = .f.
   oDlg:SetFont(oApp():oFont)

   REDEFINE CALENDAR oCalendar VAR dFecha ;
      ID 11 OF oDlg DBLCLICK  ( lOk := .t., oDlg:End()) 

   oCalendar:SetFont(oApp():oFont)
	oCalendar:oCursor := TCursor():New(,'HAND')

   ACTIVATE DIALOG oDlg               ;
      ON PAINT ( oDlg:Move(aPoint[1], aPoint[2],,,.t.), ;
                 oCalendar:SetFocus(.t.) )

   if lOK
      oGet:cText( oCalendar:dDate )
      sysrefresh()
   endif

return NIL

function nDiasMes( dDate )
Local nMes, cYear
Local dDay
Local aDays := {31,28,31,30,31,30,31,31,30,31,30,31}
Local nReturn
Local dateformat := set( _SET_DATEFORMAT )

if empty( dDate )
   return 0
endif
set( _SET_DATEFORMAT, "dd-mm-yyyy" )
nMes := Month( dDate )
cYear := str( year( dDate ),4 )
if nMes == 2
   if day( ctod( "29-02-" + cYear ) ) != 0
      nReturn := 29
   else
      nReturn := 28
   endif
else
   nReturn := aDays[ nMes ]
endif
set( _SET_DATEFORMAT, dateformat )

Return nReturn
