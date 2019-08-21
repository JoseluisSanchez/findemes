#define COLOR_HIGHLIGHT      13
#define COLOR_HIGHLIGHTTEXT  14
#define DEFAULT_GUI_FONT     17
#define DT_WORDBREAK         16 //     0x00000010
#define DT_CALCRECT        1024 //     0x00000400
#define DT_END_ELLIPSIS   32768 //     0x00008000
#define SRCCOPY 13369376
#define WM_ERASEBKGND 20 //0x0014

/* 3D border styles */
#define BDR_RAISEDOUTER 1
#define BDR_SUNKENOUTER 2
#define BDR_RAISEDINNER 4
#define BDR_SUNKENINNER 8

#define BDR_OUTER       nOr(BDR_RAISEDOUTER , BDR_SUNKENOUTER)
#define BDR_INNER       nOr(BDR_RAISEDINNER , BDR_SUNKENINNER)
#define BDR_RAISED      nOr(BDR_RAISEDOUTER , BDR_RAISEDINNER)
#define BDR_SUNKEN      nOr(BDR_SUNKENOUTER , BDR_SUNKENINNER)


#define EDGE_RAISED     nOr(BDR_RAISEDOUTER , BDR_RAISEDINNER)
#define EDGE_SUNKEN     nOr(BDR_SUNKENOUTER , BDR_SUNKENINNER)
#define EDGE_ETCHED     nOr(BDR_SUNKENOUTER , BDR_RAISEDINNER)
#define EDGE_BUMP       nOr(BDR_RAISEDOUTER , BDR_SUNKENINNER)

/* Border flags */
#define BF_LEFT         1
#define BF_TOP          2
#define BF_RIGHT        4
#define BF_BOTTOM       8

#define BF_TOPLEFT      nOr(BF_TOP,  BF_LEFT)
#define BF_TOPRIGHT     nOr(BF_TOP , BF_RIGHT)
#define BF_BOTTOMLEFT   nOr(BF_BOTTOM , BF_LEFT)
#define BF_BOTTOMRIGHT  nOr(BF_BOTTOM , BF_RIGHT)
#define BF_RECT         nOr(BF_LEFT , BF_TOP , BF_RIGHT , BF_BOTTOM)

#define BF_DIAGONAL     16



// For diagonal lines, the BF_RECT flags specify the end point of the
// vector bounded by the rectangle parameter.
#define BF_DIAGONAL_ENDTOPRIGHT     nOr(BF_DIAGONAL , BF_TOP , BF_RIGHT)
#define BF_DIAGONAL_ENDTOPLEFT      nOr(BF_DIAGONAL , BF_TOP , BF_LEFT)
#define BF_DIAGONAL_ENDBOTTOMLEFT   nOr(BF_DIAGONAL , BF_BOTTOM , BF_LEFT)
#define BF_DIAGONAL_ENDBOTTOMRIGHT  nOr(BF_DIAGONAL , BF_BOTTOM , BF_RIGHT)


#define BF_MIDDLE       2048      // 0x0800  /* Fill in the middle */
#define BF_SOFT         4096      // 0x1000  /* For softer buttons */
#define BF_ADJUST       8192      // 0x2000  /* Calculate the space left over */
#define BF_FLAT        16384      // 0x4000  /* For flat rather than 3D borders */
#define BF_MONO        32768      // 0x8000  /* For monochrome borders */


#define SINSELECCION   0
#define SUBRAYADO      1
#define INSET          2
#define SOLID          3
#define XBOX           4
#define SOLIDUNDERLINE 5
#define BUMP           6
#define ETCHED         7
#define RAISED         8

#define NONE         0
#define DOTS         1
#define LFILLED      2
#define RFILLED      3
#define FILLED       4
#define LFOLDER      5
#define RFOLDER      6

