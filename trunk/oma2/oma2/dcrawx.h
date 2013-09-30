#pragma clang diagnostic ignored "-Wall"
#pragma clang diagnostic ignored "-Wconversion"
#pragma clang diagnostic ignored "-Wmissing-prototypes"
#pragma clang diagnostic ignored "-Wwrite-strings"


#define VERSION "8.89"

#define _GNU_SOURCE
#define _USE_MATH_DEFINES
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <float.h>
#include <limits.h>
#include <math.h>
#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
/*
 NO_JPEG disables decoding of compressed Kodak DC120 files.
 NO_LCMS disables the "-p" option.
 */

// -- oma
#include "oma2.h"
#include "gluedCommands.h"
#define NO_JPEG 1
#define NO_LCMS 1


#define histogram dcraw_histogram

//int printf();
// Note: replace as follows:
//fprintf (stderr,' 'printf('
//
// -- oma

#ifndef NO_JPEG
#include <jpeglib.h>
#endif
#ifndef NO_LCMS
#include <lcms.h>
#endif
#ifdef LOCALEDIR
#include <libintl.h>
#define _(String) gettext(String)
#else
#define _(String) (String)
#endif
#ifdef DJGPP
#define fseeko fseek
#define ftello ftell
#else
#define fgetc getc_unlocked
#endif
#ifdef __CYGWIN__
#include <io.h>
#endif
#ifdef WIN32
#include <sys/utime.h>
#include <winsock2.h>
#pragma comment(lib, "ws2_32.lib")
#define snprintf _snprintf
#define strcasecmp stricmp
#define strncasecmp strnicmp
typedef __int64 INT64;
typedef unsigned __int64 UINT64;
#else
#include <unistd.h>
#include <utime.h>
#include <netinet/in.h>
typedef long long INT64;
typedef unsigned long long UINT64;
#endif

#ifdef LJPEG_DECODE
#error Please compile dcraw.c by itself.
#error Do not link it with ljpeg_decode.
#endif

#ifndef LONG_BIT
#define LONG_BIT (8 * sizeof (long))
#endif

#define ushort UshORt
typedef unsigned char uchar;
typedef unsigned short ushort;

#define CLASS

#define FORC(cnt) for (c=0; c < cnt; c++)
#define FORC3 FORC(3)
#define FORC4 FORC(4)
#define FORCC FORC(colors)

#define SQR(x) ((x)*(x))
//#define ABS(x) (((int)(x) ^ ((int)(x) >> 31)) - ((int)(x) >> 31))
//#define MIN(a,b) ((a) < (b) ? (a) : (b))
//#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define LIM(x,min,max) MAX(min,MIN(x,max))
#define ULIM(x,y,z) ((y) < (z) ? LIM(x,y,z) : LIM(x,z,y))
#define CLIP(x) LIM(x,0,65535)
#define SWAP(a,b) { a ^= b; a ^= (b ^= a); }

