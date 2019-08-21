/*
##############################################################################
# TXBrowse & TXBrwColumn header file                                         #
# Copyright OZ Sofware 2002                                                  #
# Written by Ignacio Ortiz de Zuñiga                                         #
##############################################################################
*/

#define AL_LEFT               0
#define AL_RIGHT              1
#define AL_CENTER             2

#define LINESTYLE_NOLINES     0
#define LINESTYLE_BLACK       1
#define LINESTYLE_DARKGRAY    2
#define LINESTYLE_FORECOLOR   3
#define LINESTYLE_LIGHTGRAY   4
#define LINESTYLE_INSET       5
#define LINESTYLE_RAISED      6

#define MARQSTYLE_NOMARQUEE   0
#define MARQSTYLE_DOTEDCELL   1
#define MARQSTYLE_SOLIDCELL   2
#define MARQSTYLE_HIGHLCELL   3
#define MARQSTYLE_HIGHLROWRC  4
#define MARQSTYLE_HIGHLROW    5
#define MARQSTYLE_HIGHLROWMS  6

#define EDIT_NONE             0
#define EDIT_GET              1
#define EDIT_LISTBOX          2
#define EDIT_BUTTON           3
#define EDIT_GET_LISTBOX      4
#define EDIT_GET_BUTTON       5

#ifndef __HARBOUR__
   #xtranslate :CreateFromCode      => :CteFromCode
   #xtranslate :CreateFromResource  => :CteFromResource
   #xtranslate :GetDisplayColsWidth => :GetDispColsWidth
   #xtranslate :HeaderLButtonDown   => :HLButtonDown
   #xtranslate :HeaderLButtonUp     => :HLButtonUp
   #xtranslate :FooterLButtonDown   => :FLButtonDown
   #xtranslate :FooterLButtonUp     => :FLButtonUp
   #xtranslate :lAllowColSwapping   => :lAllColSwapping
   #xtranslate :lAllowColHiding     => :lAllColHiding
   #xtranslate :aEditListTxt        => :aEdListTxt
   #xtranslate :aEditListBound      => :aEdListBound
#endif
