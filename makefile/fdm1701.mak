#FWH Borland make, (c) FiveTech Software 2005-2011

HBDIR=c:\fivetech\hb32_bcc7
BCDIR=c:\bcc\bcc7
FWDIR=c:\fivetech\fwh1701

#change these paths as needed
.path.OBJ = .\obj
.path.PRG = .\prg
.path.CH  = $(FWDIR)\include;$(HBDIR)\include
.path.C   = .\
.path.rc  = .\res

#important: Use Uppercase for filenames extensions!

PRG =           	\
   MAIN.PRG       \
   C5IMGLIS.PRG   \
   C5VITEM.PRG		\
   C5VMENU.PRG		\
	ERRSYSW.PRG  	\
   PACTIVIDA.PRG  \
   PAPUNTE.PRG    \
   PCLIENTE.PRG   \
   PCUENTA.PRG    \
   PEJERCICIO.PRG \
   PGASTO.PRG     \
   PGRAFICO.PRG   \
	PIBIENES.PRG   \
	PICATEGOR.PRG  \
	PIETIQUETA.PRG \
	PIMARCA.PRG 	\
   PINGRESO.PRG   \
	PITIENDAS.PRG	\
	PIUBICACI.PRG  \
   PPERIODI.PRG   \
	PPRESUPU.PRG	\
   PPROVEED.PRG   \
	PTRASPASO.PRG  \
   RPREVIEW.PRG  \
   TABS.PRG       \
   TAGEVER2.PRG	\
   TFSDI.PRG      \
	TGETCALC.PRG   \
   TINFORME.PRG   \
   TIPS.PRG       \
	TRIBBON.PRG		\
   TSAYREF.PRG    \
   TZOOMIMAGE.PRG \
   UT_BRW.PRG     \
   UT_CALEND.PRG  \
   UT_COMMON.PRG  \
   UT_DBF.PRG     \
   UT_INDEX.PRG   \
   UT_MSG.PRG     \
	UT_OVERRIDE.PRG\
   UT_XML.PRG     \
   ZIPBACKUP.PRG  \

OBJ = $(PRG:.PRG=.OBJ)
OBJS = $(OBJ:.\=.\obj)
PROJECT    : FINDEMES.EXE

FINDEMES.EXE : $(PRG:.PRG=.OBJ) $(C:.C=.OBJ) FINDEMES.RES

  $(BCDIR)\bin\ilink32 -Gn -aa -Tpe -s @makefile\fdm1701.bc

.PRG.OBJ:
  $(HBDIR)\bin\harbour $< /N /W1 /ES2 /Oobj\ /I$(FWDIR)\include;$(HBDIR)\include;.\ch 
  $(BCDIR)\bin\bcc32 -c -tWM -I$(HBDIR)\include -oobj\$& obj\$&.c

.C.OBJ:
  echo -c -tWM -D__HARBOUR__ > tmp
  echo -I$(HBDIR)\include;$(FWDIR)\include >> tmp
  $(BCDIR)\bin\bcc32 -oobj\$& @tmp $&.c
  del tmp
