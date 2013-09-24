#pragma warning( disable: "No Previous Prototype" )
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


int CLASS fc (int row, int col);
char *my_memmem (char *haystack, size_t haystacklen,
                 char *needle, size_t needlelen);
void CLASS merror (void *ptr, char *where);
void CLASS derror();
ushort CLASS sget2 (uchar *s);
ushort CLASS get2();
unsigned CLASS sget4 (uchar *s);
unsigned CLASS get4();
unsigned CLASS getint (int type);
float CLASS int_to_float (int i);
double CLASS getreal (int type);
void CLASS read_shorts (ushort *pixel, int count);
void CLASS canon_black (double dark[2]);
void CLASS canon_600_fixed_wb (int temp);
int CLASS canon_600_color (int ratio[2], int mar);
void CLASS canon_600_auto_wb();
void CLASS canon_600_coeff();
void CLASS canon_600_load_raw();
void CLASS remove_zeroes();
int CLASS canon_s2is();
void CLASS canon_a5_load_raw();
unsigned CLASS getbits (int nbits);
void CLASS init_decoder();
uchar * CLASS make_decoder (const uchar *source, int level);
void CLASS crw_init_tables (unsigned table);
int CLASS canon_has_lowbits();
void CLASS canon_compressed_load_raw();
int CLASS ljpeg_start (struct jhead *jh, int info_only);
int CLASS ljpeg_diff (struct decode *dindex);
ushort * CLASS ljpeg_row (int jrow, struct jhead *jh);
void CLASS lossless_jpeg_load_raw();
void CLASS canon_sraw_load_raw();
void CLASS adobe_copy_pixel (int row, int col, ushort **rp);
void CLASS adobe_dng_load_raw_lj();
void CLASS adobe_dng_load_raw_nc();
void CLASS pentax_k10_load_raw();
void CLASS nikon_compressed_load_raw();
int CLASS nikon_is_compressed();
int CLASS nikon_e995();
int CLASS nikon_e2100();
void CLASS nikon_3700();
int CLASS minolta_z2();
void CLASS nikon_e900_load_raw();
void CLASS fuji_load_raw();
void CLASS jpeg_thumb (FILE *tfp);
void CLASS ppm_thumb (FILE *tfp);
void CLASS layer_thumb (FILE *tfp);
void CLASS rollei_thumb (FILE *tfp);
void CLASS rollei_load_raw();
int CLASS bayer (unsigned row, unsigned col);
void CLASS phase_one_flat_field (int is_float, int nc);
void CLASS phase_one_correct();
void CLASS phase_one_load_raw();
unsigned CLASS ph1_bits (int nbits);
void CLASS phase_one_load_raw_c();
void CLASS hasselblad_load_raw();
void CLASS leaf_hdr_load_raw();
void CLASS sinar_4shot_load_raw();
void CLASS imacon_full_load_raw();
void CLASS packed_12_load_raw();
void CLASS nokia_load_raw();
unsigned CLASS pana_bits (int nbits);
void CLASS panasonic_load_raw();
void CLASS olympus_e300_load_raw();
void CLASS olympus_e410_load_raw();
void CLASS minolta_rd175_load_raw();
void CLASS casio_qv5700_load_raw();
void CLASS quicktake_100_load_raw();
const int * CLASS make_decoder_int (const int *source, int level);
int CLASS radc_token (int tree);
void CLASS kodak_radc_load_raw();
void CLASS kodak_jpeg_load_raw();
void CLASS kodak_jpeg_load_raw();
void CLASS kodak_dc120_load_raw();
void CLASS eight_bit_load_raw();
void CLASS kodak_yrgb_load_raw();
void CLASS kodak_262_load_raw();
int CLASS kodak_65000_decode (short *out, int bsize);
void CLASS kodak_65000_load_raw();
void CLASS kodak_ycbcr_load_raw();
void CLASS kodak_rgb_load_raw();
void CLASS kodak_thumb_load_raw();
void CLASS sony_decrypt (unsigned *data, int len, int start, int key);
void CLASS sony_load_raw();
void CLASS sony_arw_load_raw();
void CLASS sony_arw2_load_raw();
void CLASS smal_decode_segment (unsigned seg[2][2], int holes);
void CLASS smal_v6_load_raw();
int CLASS median4 (int *p);
void CLASS fill_holes (int holes);
void CLASS smal_v9_load_raw();
void CLASS foveon_decoder (unsigned size, unsigned code);
void CLASS foveon_thumb (FILE *tfp);
void CLASS foveon_load_camf();
void CLASS foveon_load_raw();
const char * CLASS foveon_camf_param (const char *block, const char *param);
void * CLASS foveon_camf_matrix (unsigned dim[3], const char *name);
int CLASS foveon_fixed (void *ptr, int size, const char *name);
float CLASS foveon_avg (short *pix, int range[2], float cfilt);
short * CLASS foveon_make_curve (double max, double mul, double filt);
void CLASS foveon_make_curves
(short **curvep, float dq[3], float div[3], float filt);
int CLASS foveon_apply_curve (short *curve, int i);
void CLASS foveon_interpolate();
void CLASS bad_pixels (char *fname);
void CLASS subtract (char *fname);
void CLASS pseudoinverse (double (*in)[3], double (*out)[3], int size);
void CLASS cam_xyz_coeff (double cam_xyz[4][3]);
void CLASS colorcheck();
void CLASS hat_transform (float *temp, float *base, int st, int size, int sc);
void CLASS wavelet_denoise();



void CLASS oma_write_ppm_tiff (int thecolor);


