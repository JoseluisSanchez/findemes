#include "Fivewin.ch"

/*_____________________________________________________________________________*/

FUNCTION Db_Open( cDbf, cAlias )
	local aInvent := {'BI', 'MA', 'TI', 'CA', 'ET', 'UB'}
   local RutaDbf 
	if (cAlias=="EJ".or.cAlias=="IV")
		RutaDbf := oApp():cExePath
	elseif AScan(aInvent,cAlias)!=0
 		RutaDbf := oApp():cInvDbfPath
	else  
		RutaDbf := oApp():cDbfPath
	endif
   IF file( RutaDbf + cDbf + ".dbf" ) .AND. file( RutaDbf + cDbf + ".cdx" )
      USE ( RutaDbf + cDbf + ".dbf" ) ;
         INDEX ( RutaDbf + cDbf + ".cdx" ) ;
         ALIAS ( cAlias ) ;
         NEW
   ELSE
      msgStop( i18n( "No se ha encontrado el fichero "+cDbf ) + CRLF + CRLF + ;
               i18N( "Por favor reindexe los ficheros del programa." ) )
      RETURN .f.
   ENDIF

   IF NetErr()
      msgStop( i18n( "Ha sucedido un error al abrir un fichero." ) + CRLF + ;
               i18n( "Por favor reinicie el programa." ) )
      dbCloseAll()
      RETURN .f.
   ENDIF

RETURN .t.

/*_____________________________________________________________________________*/

FUNCTION Db_OpenNoIndex( cDbf, cAlias )
	local aInvent := {'BI', 'MA', 'TI', 'CA', 'ET', 'UB'}
   local RutaDbf := iif(cAlias=="EJ".or.cAlias=="IV",oApp():cExePath,;
							iif(AScan(aInvent,cAlias)!=0, oApp():cInvDbfPath, oApp():cDbfPath))
   IF file( RutaDbf + cDbf + ".dbf" )
      USE ( RutaDbf + cDbf + ".dbf" ) ;
      ALIAS ( cAlias ) ;
      NEW
   ELSE
      msgStop( i18n( "Uno de los archivos que se intentaba abrir no se ha encontrado." ) + CRLF + CRLF + ;
               i18N( "Por favor reindexe los ficheros del programa." ) )
      RETURN .f.
   ENDIF

   IF NetErr()
      msgStop( i18n( "Ha sucedido un error al abrir un fichero." ) + CRLF + ;
               i18n( "Por favor reinicie el programa." ) )
      dbCloseAll()
      RETURN .f.
   ENDIF

RETURN .t.

/*_____________________________________________________________________________*/

FUNCTION Db_OpenAll()

   IF ! Db_Open("IVA","IV")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("APUNTES","AP")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("CLIENTES","CL")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("GASTOS","GA")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("INGRESOS","IN")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("PROVEED","PR")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("ACTIVIDA","AC")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("EJERCICI","EJ")
      DbCloseAll()
      return .F.
   ENDIF

   IF ! Db_Open("PERIODI","PE")
      DbCloseAll()
      return .F.
   ENDIF

	IF ! Db_Open("CUENTAS","CC")
      DbCloseAll()
      return .F.
   ENDIF

	IF ! Db_Open("TRASPASOS","TR")
      DbCloseAll()
      return .F.
   ENDIF

	IF ! Db_Open("PRESUPU","PU")
      DbCloseAll()
      return .F.
   ENDIF
RETURN .t.
/*_____________________________________________________________________________*/

FUNCTION Db_OpenAllInv()

   IF ! Db_Open("BIENES","BI")
      DbCloseAll()
      return .F.
   ENDIF
	IF ! Db_Open("MARCAS","MA")
      DbCloseAll()
      return .F.
   ENDIF
	IF ! Db_Open("TIENDAS","TI")
      DbCloseAll()
      return .F.
   ENDIF
	IF ! Db_Open("CATEGOR","CA")
      DbCloseAll()
      return .F.
   ENDIF
	IF ! Db_Open("ETIQUETA","ET")
      DbCloseAll()
      return .F.
   ENDIF
	IF ! Db_Open("UBICACI","UB")
      DbCloseAll()
      return .F.
   ENDIF

RETURN .t.
/*_____________________________________________________________________________*/

FUNCTION Db_Delete(cAlias)

   LOCAL nRecord := (cAlias)->(Recno())
   LOCAL nNext

   Select (cAlias)
   (cAlias)->(DbSkip())
   nNext := (cAlias)->(Recno())
   (cAlias)->(DbGoto(nRecord))

   (cAlias)->(DbDelete())
   (cAlias)->(DbPack())
   (cAlias)->(DbGoto(nNext))

   IF (cAlias)->(EOF()) .or. nNext == nRecord
      (cAlias)->(DbGoBottom())
   ENDIF

RETURN NIL
/*_____________________________________________________________________________*/

Function Db_Pack()
   Pack
Return nil

Function DbPack()
   Pack
Return nil
Function Db_Zap()
   Zap
Return nil

/*_____________________________________________________________________________*/

FUNCTION Db_SwapUp( cAlias, oBrw )

   local aRecNew
   local aRecOld  := Db_Scatter( cAlias )
   local nRecNum  := ( cAlias )->( RecNo() )
   //local nOrder := ( cAlias )->( OrdNumber )
   //( cAlias )->(DbSetOrder(0))

   ? (cAlias)->aanombre
   ( cAlias )->( DbSkip( -1 ) )
   ? (cAlias)->aanombre
   IF ( cAlias )->( Bof() )
      Tone(300,1)
      ( cAlias )->( dbGoTo( nRecNum ) )
   ELSE
      aRecNew := Db_Scatter( cAlias )
      ( cAlias )->( DbSkip( 1 ) )
      Db_Gather( aRecNew, cAlias )
      ? (cAlias)->aanombre
      ( cAlias )->( DbSkip( -1 ) )
      Db_Gather( aRecOld, cAlias )
      ? (cAlias)->aanombre
   END IF

   IF oBrw != NIL
      oBrw:Refresh(.t.)
      oBrw:SetFocus(.t.)
   END IF

RETURN NIL

//--------------------------------------------------------------------------//

FUNCTION Db_SwapDown( cAlias, oBrw )

   local aRecNew
   local aRecOld := Db_Scatter( cAlias )
   local nRecNum := ( cAlias )->( RecNo() )

   ( cAlias )->( DbSkip( 1 ) )

   IF ( cAlias )->( Eof() )
      Tone(300,1)
      ( cAlias )->( dbGoTo( nRecNum ) )
   ELSE
      aRecNew := Db_Scatter( cAlias )
      ( cAlias )->( DbSkip( -1 ) )
      Db_Gather( aRecNew, cAlias )
      ( cAlias )->( DbSkip( 1 ) )
      Db_Gather( aRecOld, cAlias )

      IF oBrw != NIL
         oBrw:refresh()
      END IF

   END IF


   IF oBrw != NIL
      oBrw:setFocus()
   END IF

RETURN NIL

//--------------------------------------------------------------------------//

/*
Escribe un registro de disco
*/

FUNCTION DB_Gather( aField, cAlias, lAppend )

      local i

      DEFAULT lAppend := .f.

      // dbRLock( cAlias, lAppend )

      for i = 1 to Len( aField )
         (cAlias)->( FieldPut( i, aField[ i ] ) )
      next

      (cAlias)->( dbCommit() )
      // (cAlias)->( dbRunLock() )

RETURN NIL

//----------------------------------------------------------------------------//

/*
Lee del disco un registro desde un array
*/

FUNCTION DB_Scatter( cAlias )

   local nField := (cAlias)->(FCOUNT())
   local aField := {}
   local i

   // Creating requested field array

   for i = 1 to nField
       AAdd( aField, (cAlias)->(FieldGet( i ) ) )
   next

RETURN aField

//----------------------------------------------------------------------------//
FUNCTION Ut_AbsPath(cRuta)
	if SubStr(cRuta,1,2) == '.\'
		cRuta := oApp():cExePath + SubStr(cRuta,3,len(cRuta)-2)
	endif
return cRuta
