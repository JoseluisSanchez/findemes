#ifndef _FWHARB_H
#define _FWHARB_H

#ifndef HB_OS_WIN_32_USED
   #define HB_OS_WIN_32_USED
#endif

#include <extend.h>

#define ISLOGICAL    ISLOG
#define PCLIPVAR     PHB_ITEM
#define LPCLIPSYMBOL PHB_DYNS
#define PCLIPSYMBOL  PHB_DYNS

#define __hInstance hb_hInstance

void _bcopy( char * pDest, char * pOrigin, LONG lSize );
void _bset( char * pDest, LONG lValue, LONG lLen );
void _strcpy( char * pDest, char * pOrigin );

#undef PCOUNT
#define PCOUNT()  hb_pcount()

#define _param          hb_param
#define _parc           hb_parc
#define _parclen        hb_parclen
#define _parcsiz        hb_parcsiz
#define _pards          hb_pards
#define _parinfa        hb_parinfa
#define _parinfo        hb_parinfo
#define _parl           hb_parl
#define _parnd          hb_parnd
#define _parni          hb_parni
#define _parnl          hb_parnl
#define _parptr         hb_parptr

#define _ret            hb_ret
#define _reta           hb_reta
#define _retc           hb_retc
#define _retclen        hb_retclen
#define _retd           hb_retd
#define _retdl          hb_retdl
#define _retds          hb_retds
#define _retl           hb_retl
#define _retnd          hb_retnd
#define _retni          hb_retni
#define _retnl          hb_retnl

#define _storc          hb_storc
#define _storclen       hb_storclen
#define _stords         hb_stords
#define _storl          hb_storl
#define _stornd         hb_stornd
#define _storni         hb_storni
#define _stornl         hb_stornl

#define _xgrab          hb_xgrab
#define _xrealloc       hb_xrealloc
#define _xfree          hb_xfree

#define _pcount         hb_pcount

#define _tcreat         hb_fsCreate
#define _tunlink        hb_fsDelete
#define _topen          hb_fsOpen
#define _tclose         hb_fsClose
#define _tread          hb_fsRead
#define _twrite         hb_fsWrite
#define _tlseek         hb_fsSeek
#define _trename        hb_fsRename
#define _tlock          hb_fsLock
#define _tcommit        hb_fsCommit

#endif