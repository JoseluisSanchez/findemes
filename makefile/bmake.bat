echo off

rem ---------------------------------------------------------------
rem Template bat file for FWH using Borland Make tool
rem Copyright FiveTech 2002
rem Written by Ignacio Ortiz de Zuñiga
rem ---------------------------------------------------------------

:BUILD

   C:\bcc55\bin\make -f%1.mak %2 %3 
   rem C:\bcc55\bin\make -f%1.mak %2 %3 > make.log
   if errorlevel 1 goto BUILD_ERR

:BUILD_OK

   rem if exist %1.exe C:\utilidades\upx\upx %1.exe
   if exist %1.res del *.res
   if exist %1.exe %1.exe
   goto EXIT

:BUILD_ERR

   rem notepad make.log
   goto EXIT

:EXIT
