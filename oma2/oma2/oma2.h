#ifndef _OMA2_

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

#define CHPERLN 4096      	/* maximum number of characters per line */
#define PREFIX_CHPERLN 256  /* maximum number of characters in the prefix */
#define HEADLEN 30       	/* number of bytes in header */
#define TRAILEN 62       	/* number of bytes in trailer */
#define COMLEN 512-HEADLEN-TRAILEN  /* number of bytes in comment buffer */

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
       LOAD_SAVE_PREFIX,LOAD_GET_PREFIX,LOAD_SAVE_SUFFIX,LOAD_GET_SUFFIX};




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
    char        version[32];
    
    // Prefix/suffix buffers
    
    char	saveprefixbuf[PREFIX_CHPERLN];		/* save data file prefix buffer */
    char	savesuffixbuf[PREFIX_CHPERLN];		/* save data file suffix buffer */
    char	getprefixbuf[PREFIX_CHPERLN];		/* get data file prefix buffer */
    char	getsuffixbuf[PREFIX_CHPERLN];		/* get data file suffix buffer */
    char	graphicsprefixbuf[PREFIX_CHPERLN];	/* graphics file prefix buffer */
    char	graphicssuffixbuf[PREFIX_CHPERLN];	/* graphics file suffix buffer */
    char	macroprefixbuf[PREFIX_CHPERLN];     /* macro file prefix buffer */
    char	macrosuffixbuf[PREFIX_CHPERLN];     /* macro file suffix buffer */

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
                                    // Consider moving this to the rectan command as static


    DATAWORD    cmin;
	DATAWORD    cmax;
    DATAWORD    min;
    DATAWORD    max;
    
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

#define _OMA2_
#endif

