#ifndef _OMA2_h

//#include <iostream>
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <Strings.h>
#include <StdLib.h>
#include <math.h>


/******************** Definitions ********************/

#define IS_BIG_ENDIAN 0

#define EOL 0

#define FLOAT 1
#define DATAWORD float
#define TWOBYTE short
#define DATABYTES 4

#define CHPERLN 4096            // maximum number of characters per line 
#define PREFIX_CHPERLN 128      // maximum number of characters in the prefix 
#define NEW_PREFIX_CHPERLN 256  // maximum number of characters in the new prefix 
#define HEADLEN 30              // number of bytes in header 
#define TRAILEN 62              // number of bytes in trailer 
#define COMLEN 512-HEADLEN-TRAILEN  // number of bytes in comment buffer 

/* Define the indices to important locations in the header */

#define NMAX    1
#define LMAX_    2
#define NMIN    3
#define LMIN_    4
#define NFRAM   5
#define NPTS    6
#define NCHAN   7
#define NTRAK   8
#define NTIME   9
#define NPREP   10
#define NX0     11
#define NY0     12
#define NDX     13
#define NDY     14

/* Define the indices to important locations in the trailer */

#define FREESP	0
#define IDWRDS	1			// use this to indicate byte ordering
#define RULER_CODE 2		/* if trailer[RULER_CODE] == MAGIC_NUMBER, assume a ruler */
#define MAGIC_NUMBER 12345  /*   has been defined. */
#define RULER_SCALE 3		/* A floating point number occupying trailer[3] & [4]. Pixels/Unit. */
#define RULER_UNITS 5		/* The starting location of a text string specifying the 
name of the units. Occupies trailer[5] to trailer[12] */
#define RUNNUM	13
#define	TOMA2	14
#define	IS_COLOR_	15
#define SFACTR	17
#define NDATE	18
#define DMODE	21
#define NDATW	22
#define SAMT	23
#define SUBFC	24
#define NREAD	25
#define LSYFG	26
#define COLFG	27
#define NDISF	28
#define NDELY	29
#define ACSTAT	30

// use these constants in both bytes of trailer[IDWRDS] to specify the byte ordering of files
// big endian is PowerPC et al
// little endian is intel et al

#define LITTLE_ENDIAN_CODE 127
#define BIG_ENDIAN_CODE 0

#define PI 3.14159265358979323846

#define MAXMSG " Maximum %g at Row %d and Column %d.\n"
#define MINMSG " Minimum %g at Row %d and Column %d.\n"
#define DATAMSG " %g\n"
#define DATAFMT "%g"


/* Prefix and Suffix Types */
enum  {SAVE_DATA,GET_DATA,MACROS_DATA,GRAPHICS_DATA,SETTINGS_DATA,TIFF_DATA,TIF_DATA,CSV_DATA,FTS_DATA,
       RAW_DATA,PDF_DATA,SAVE_DATA_NO_SUFFIX,
       LOAD_SAVE_PREFIX,LOAD_GET_PREFIX,LOAD_SAVE_SUFFIX,LOAD_GET_SUFFIX,
       LOAD_MACRO_PREFIX,LOAD_SETTINGS_PREFIX,LOAD_MACRO_SUFFIX,LOAD_SETTINGS_SUFFIX};

#define DO_MACH_O

#ifdef DO_MACH_O
    #ifndef SETTINGSFILE
        #define SETTINGSFILE "oma2.app/Contents/Resources/OMA Settings"
        #define PALETTEFILE	"oma2.app/Contents/Resources/OMA palette.pa1"
        #define PALETTEFILE2 "oma2.app/Contents/Resources/OMA palette2.pa1"
        #define PALETTEFILE3 "oma2.app/Contents/Resources/OMA palette3.pa1"

        #define HELPFILE "oma2.app/Contents/Resources/oma help.txt"
        #define HELPURL "oma2.app/Contents/Resources/oma_help/OMA_First_Steps.html"
    #endif
#else
    #define SETTINGSFILE "OMA Settings"
    #define PALETTEFILE	"OMA Palette"
    #define PALETTEFILE2 "OMA Palette2"
    #define PALETTEFILE3 "OMA Palette3"
#endif

// 8 defined color palettes
#define NUMPAL 8
enum  {DEFAULTMAP,BGRBOW,GRAYMAP,REDMAP,GREENMAP,BLUEMAP,FROMAFILE2,FROMAFILE3};


#define SETTINGS_VERSION_1  "OMA2 Settings Version 1.0"


/******************** Structures ********************/


typedef struct {
	int* specs;
} ImSpecs;

typedef struct {
	int h;
    int v;
} point;

typedef struct {
	point ul;       // upper left
    point lr;       // lower right
} rect;

typedef struct {
    char        version[HEADLEN];
    
    // Prefix/suffix buffers
    
    char	saveprefixbuf[NEW_PREFIX_CHPERLN];		/* save data file prefix buffer */
    char	savesuffixbuf[NEW_PREFIX_CHPERLN];		/* save data file suffix buffer */
    char	getprefixbuf[NEW_PREFIX_CHPERLN];		/* get data file prefix buffer */
    char	getsuffixbuf[NEW_PREFIX_CHPERLN];		/* get data file suffix buffer */
    char	graphicsprefixbuf[NEW_PREFIX_CHPERLN];	/* graphics file prefix buffer */
    char	graphicssuffixbuf[NEW_PREFIX_CHPERLN];	/* graphics file suffix buffer */
    char	macroprefixbuf[NEW_PREFIX_CHPERLN];     /* macro file prefix buffer */
    char	macrosuffixbuf[NEW_PREFIX_CHPERLN];     /* macro file suffix buffer */

    // Status Window Related 
    
    int         pixsiz;					
    int         newwindowflag;
    int         cminmaxinc;
    int         autoscale;
	int         autoupdate;
    int         toolselected;
    int         iscolor;
    int         rows;
    int         cols;
    int         dx;
    int         dy;
    int         x0;
    int         y0;
    
    rect        iRect;              // the image sub-rectagle (for cropping for example), 
                                    //   defined in terms of upper left pt. to lower right pt.
                                    

    DATAWORD    cmin;
	DATAWORD    cmax;
    DATAWORD    min;
    DATAWORD    max;
    
    int         thepalette;
    
    float r_scale;
    float g_scale;
    float b_scale;
    
    
    
    /*
	settings[4] = detector;
	settings[8] = showselection;
	settings[9] = docalcs;
	
	settings[11] = dlen;
	settings[12] = dhi;
	settings[13] = c_font;
	settings[14] = s_font;
	settings[15] = showruler;
    */

    
    
}oma2UIData;

#define _OMA2_h
#endif

