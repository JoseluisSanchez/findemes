//#ifndef _HEADER_CH
   #define _HEADER_CH

   // Alineacion del texto
   #define HDF_LEFT               0
   #define HDF_RIGHT              1
   #define HDF_CENTER             2
   #define HDF_SORTDOWN         512   // para CommCtrl 6.0
   #define HDF_SORTUP          1024   // para CommCtrl 6.0
   #define HDF_IMAGE           2048   // 0x0800
   #define HDF_BITMAP_ON_RIGHT 4096   // 0x1000
   #define HDF_BITMAP          8192   // 0x2000

   // Estilos
   #define HDS_HORZ                0
   #define HDS_BUTTONS             2
   #define HDS_HOTTRACK            4
   #define HDS_HIDDEN              8
   #define HDS_DRAGDROP           64
   #define HDS_FULLDRAG          128
   #define HDS_FILTERBAR         256  // 0x100
   #define HDS_FLAT              512  // 0x200

   // Mensajes
   #define HDM_FIRST             4608 //  0x1200 Header messages
   #define HDM_INSERTITEM        (HDM_FIRST + 1)

   #ifdef __HARBOUR__
   #define WC_HEADER              "SysHeader32"
   #else
   #define WC_HEADER              "SysHeader"
   #endif

   // Notificaciones
   #define HDN_FIRST               -300 //(0U-300U)       // header
   #define HDN_ITEMCHANGING       (HDN_FIRST-0)
   #define HDN_ITEMCHANGED        (HDN_FIRST-1)
   #define HDN_ITEMCLICK          (HDN_FIRST-2)
   #define HDN_ITEMDBLCLICK       (HDN_FIRST-3)
   #define HDN_DIVIDERDBLCLICK    (HDN_FIRST-5)
   #define HDN_BEGINTRACK         (HDN_FIRST-6)
   #define HDN_ENDTRACK           (HDN_FIRST-7)
   #define HDN_TRACK              (HDN_FIRST-8)

   #define NM_FIRST               0    // (0U-  0U)       // generic to all controls
   #define NM_RELEASEDCAPTURE     (NM_FIRST-16)
//#endif
