#include "gluedCommands.h"

// code to allow some old oma commands to be easily imported to oma2

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData;


extern Image  iTempImages[];
extern int numberNamedTempImages;
extern Variable namedTempImages[];


// Globals used by commands in the old oma
// Many of these may not be used

TWOBYTE	header[HEADLEN/2] = { 0,0,0,0,0,1,500,500,1,1,0,0,0,1,1 };
TWOBYTE	trailer[TRAILEN/2];
char	comment[COMLEN] = {0};
char	lastname[CHPERLN] = {0};	/* a copy of the last file name specified -- for labeling windows */


char	headcopy[512];		/* copy of all header for file stuff */
int	npts;			/* number of data points */

DATAWORD	min;
DATAWORD	max;		/* for maxx subroutine */
DATAWORD	rmax,gmax,bmax;	// for rgb images

/* Detector Characteristics */
int	dlen = 25000;		/* the max number of channels on the detector */
int	dhi = 75000;		/* the max number of tracks on the detector   */
//int	nbias = 373;	    	/* one pixel bias offset to remove in binning */

char	passflag = 0;		/* flag that, when set, passes unrecognised
                             commands to the controller */

unsigned int     maxint = (1<<(DATABYTES*8-1))-4;		//	32764		// the max count
DATAWORD	cmin = 0;		/* the color display parameters */
DATAWORD	cmax = 1000;
short	pixsiz = 1;		/* block pixel size */
short	newwindowflag = 1;	/* determines whether new window should be opened or just
                             display in the old one */
int	doffset = 80;		/* the data offset. 0 for SIT data; 80 for CCD data. */
short	detector = 1;		/* the detector type 0 for SIT; 1 for CCD */
int	detectorspecified = 1;	/* flag that tells if the detector type has
                             been explicitly specified with the ccd
                             or sit command */
int	openflag = 0;		/* flag that controls whether files are closed after */
/*	a "get" command.  If set, files remain open. */
/*	Use this for getting data from files containing */
/*	several different pictures with a single header */
int	fileisopen = 0;		/*	This also needed for above. Not user set. */

int	have_max = 0;		/* flag that indicates whether or not the minimum
                         and maximum value have been found for the data
                         in the current buffer. 0 -> no;  1 -> yes */

char	block_ave = 0;		/* flag that determines if the results of the BLOCK command
                             are to be averaged. 1 -> average, 0 -> simply sum with no
                             overflow checking */

DATAWORD* datpt = NULL;		/* the data pointer */
DATAWORD *respdat;		/* the data pointer for responses*/
DATAWORD *backdat;		/* the data pointer for backgrounds */
DATAWORD *meandat;		/* the data pointer for mean */

DATAWORD* temp_dat[NUM_TEMP_IMAGES*4] = {0};
TWOBYTE*  temp_header[NUM_TEMP_IMAGES*4] = {0};


float 	*fdatpt;		/* floating point data pointer */
long data_buffer_size;		/* the number of bytes in the data buffer */

unsigned int meansize,backsize,respsize;

/*	DATAWORD  data[DBUFLEN];*/
//DATAWORD  mathbuf[MATHLEN];
char    cmnd[CHPERLN];  		/* the command buffer */

char	saveprefixbuf[PREFIX_CHPERLN];		/* save data file prefix buffer */
char	savesuffixbuf[PREFIX_CHPERLN];		/* save data file suffix buffer */
char	getprefixbuf[PREFIX_CHPERLN];		/* get data file prefix buffer */
char	getsuffixbuf[PREFIX_CHPERLN];		/* get data file suffix buffer */
char	graphicsprefixbuf[PREFIX_CHPERLN];	/* graphics file prefix buffer */
char	graphicssuffixbuf[PREFIX_CHPERLN];	/* graphics file suffix buffer */
char	macroprefixbuf[PREFIX_CHPERLN];	/* macro file prefix buffer */
char	macrosuffixbuf[PREFIX_CHPERLN];	/* macro file suffix buffer */

int have_full_name = 0;				// if this is set, fullname doesn't do anything
// used in non-MacOS cases
int swap_bytes;

short image_is_color = 0;           // set this if image is color
short image_planes = 1;             // the number of image planes

#ifndef ENDIAN
#define ENDIAN 0
#endif

int is_big_endian = ENDIAN;		// this tells the byte ordering of this machine
// big endian is PowerPC et al
// little endian is intel et al


int save_rgb_rectangle = 0;		// flag to determine if rectangle to be saved is part of an rgb image

int start_oma_time;

extern ComDef    commands[];


Point		substart,subend;

unsigned int fd;
int nbyte;
int	open_file_chans;
int	open_file_tracks;

char txt[4096];
float r_scale,g_scale,b_scale;

/* _________________________________________
 
 Routines to move data between oma2 and old oma
 
 enum {ROWS,COLS,X0,Y0,DX,DY,LMAX,LMIN,IS_COLOR,HAVE_MAX,HAS_RULER,
 LRMAX,LRMIN,LGMAX,LGMIN,LBMAX,LBMIN};
 
 // locations within the values array
 enum {MIN,MAX,RMAX,RMIN,GMAX,GMIN,BMAX,BMIN,RULER_SCALE};
 // Define the indices to important locations in the header

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

// Define the indices to important locations in the trailer

#define FREESP	0
#define IDWRDS	1			// use this to indicate byte ordering
#define RULER_CODE 2		// if trailer[RULER_CODE] == MAGIC_NUMBER, assume a ruler
#define MAGIC_NUMBER 12345  //   has been defined.
#define OLD_RULER_SCALE 3		// A floating point number occupying trailer[3] & [4]. Pixels/Unit.
#define RULER_UNITS 5		// The starting location of a text string specifying the
name of the units. Occupies trailer[5] to trailer[12]
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
 _________________________________________ */

int moveOMA2toOMA(int n,char* args){
    int r,c,i=0,index=0;
    int *imspecs = iBuffer.getspecs();
    
    // fill in header/trailer bits
    header[NCHAN] = imspecs[COLS];
    header[NTRAK] = imspecs[ROWS];
    header[NDX] = imspecs[DX];
    header[NDY] = imspecs[DY];
    header[NX0] = imspecs[X0];
    header[NY0] = imspecs[Y0];
    trailer[SFACTR] = 1;
    npts = header[NCHAN] * header[NTRAK];
    trailer[IS_COLOR_] = imspecs[IS_COLOR];
    image_is_color = imspecs[IS_COLOR];
    
    // fill in the command
    strncpy(cmnd, args, CHPERLN);
    
    // ignore spaces or tabs at the beginning of a command
	while( *(args+index) == ' ' || *(args+index) == '\t') {
		index++;
	}
    // skip past the command itself
	while( *(args+index) != ' ' && *(args+index) != '\0' && *(args+index) != ';') {
		index++;
	}
    if( *(args+index) == '\0')
        index = 0;

	
	if (datpt != NULL) {
        free(datpt);
    }
    datpt = (DATAWORD*) malloc((doffset+header[NCHAN]*header[NTRAK])*sizeof(DATAWORD));
    
    for(r=0; r<imspecs[ROWS]; r++){
        for(c=0; c<imspecs[COLS]; c++){
            *(datpt+doffset+i++) = iBuffer.getpix(r,c);
        };
    }
    
    substart.h=UIData.iRect.ul.h ;
    substart.v=UIData.iRect.ul.v ;
    subend.h=UIData.iRect.lr.h ;
    subend.v=UIData.iRect.lr.v ;
    
	have_max = 0;
    free(imspecs);
    return index;
}

void moveOMAtoOMA2(){
    
    int r,c,i=0;
    int* imspecs = iBuffer.getspecs();
    
    if(header[NCHAN]*header[NTRAK] != imspecs[COLS]*imspecs[ROWS]){
        // New -- size -- reallocate data space
        Image newIm(header[NTRAK],header[NCHAN]);
        iBuffer.free();
        iBuffer = newIm;
    }
    
    imspecs[COLS] = header[NCHAN];
    imspecs[ROWS] = header[NTRAK];
    imspecs[DX] = header[NDX];
    imspecs[DY] = header[NDY];
    imspecs[X0] = header[NX0];
    imspecs[Y0] = header[NY0];
    imspecs[IS_COLOR] = trailer[IS_COLOR_];
    
    iBuffer.setspecs(imspecs);
    
    for(r=0; r<imspecs[ROWS]; r++){
        for(c=0; c<imspecs[COLS]; c++){
            iBuffer.setpix(r,c,*(datpt+doffset+i++));
        };
    }
    
    /*
    fullname(saveprefixbuf,LOAD_SAVE_PREFIX);
    fullname(savesuffixbuf,LOAD_SAVE_SUFFIX);
    fullname(getprefixbuf,LOAD_GET_PREFIX);
    fullname(getsuffixbuf,LOAD_GET_SUFFIX);
    */
    
    UIData.iRect.ul.h = substart.h;
    UIData.iRect.ul.v = substart.v;
    UIData.iRect.lr.h = subend.h;
    UIData.iRect.lr.v = subend.v;
    
    free(imspecs);
    free(datpt);
    datpt = NULL;
    
}

// do-nothings (for now)
void nomemory(){}
void update_status(){}
void setarrow(){}
void maxx(){}
void beep(){}

/*___________________________________________________________________*/
/*______________________________Service bits_________________________*/
/*___________________________________________________________________*/


int checkpar()
{
	int error = 0;
	DATAWORD *saveptr;
	extern long data_buffer_size;
	//extern int status_window_inited;
	
	if(header[NDX] <= 0) header[NDX] = 1;
	if(header[NDY] <= 0) header[NDY] = 1;
	data_buffer_size = (header[NCHAN] * header[NTRAK] + MAXDOFFSET) * DATABYTES;
	
	npts = header[NCHAN] * header[NTRAK];	/* 9/21/88 be sure this is updated */
    
	data_buffer_size = (data_buffer_size+511)/512*512;	/* make a bit bigger for file reads */
	
	if(datpt == 0) {
		datpt =(DATAWORD*) malloc(data_buffer_size);
		saveptr = 0;
		/* this should only happen the first time */
	}
	else {
		saveptr = datpt;
		datpt = (DATAWORD*)realloc(datpt,data_buffer_size);	/*  */
	}
	
	if(datpt == 0) {
		nomemory();
		error = 1;
		datpt = saveptr;	/* put back the old value */
		return(error);
	}
	
	
	if ( ((header[NX0] + header[NDX] * header[NCHAN]) > dlen) ||
        ((header[NY0] + header[NDY] * header[NTRAK]) > dhi )) {
		error = 2;
		beep();
		printf("Possible Parameter Mismatch.\n");
	}
    /*	Take this out - if controller is off, have to wait for a GPIB timeout!
     else {
     omaio(RUN,1);	 send the scan definition to the CCD
     }
     */
	//if(status_window_inited) update_status();
    
	return(error);
}

/* ***************** */

DATAWORD idat(int nt,int nc)
{
	extern DATAWORD *datpt;
	extern int	 doffset;
	DATAWORD *pt;
	
	int index;
	
	if (datpt == 0) return(0);
	if(nc < 0) nc = 0;
	if(nt < 0) nt = 0;
	if(nc > header[NCHAN]-1) nc = header[NCHAN]-1;
	if(nt > header[NTRAK]-1) nt = header[NTRAK]-1;
	index = nc + nt*header[NCHAN];
	//if (index >= header[NCHAN]*header[NTRAK]) return(0);	// check for illegal value passed
	pt = datpt + index + doffset;
	return(*pt);
}

float fdat(int nt,int nc)		// get the floating point data value
{
	extern float *fdatpt;
	extern int	 nbyte;
	float *pt;
	int index;
	
	if (fdatpt == 0) return(0);
	index = nc + nt*header[NCHAN];
	if (index >= nbyte) return(0);	// check for illegal value passed
	pt = fdatpt + index;
	return(*pt);
}

int float_image()			// copy the current image into the floating-point buffer
{
	extern float *fdatpt;
	int n;
    
	if(fdatpt != 0) free(fdatpt);
	
	fdatpt = (float*) malloc(npts*sizeof(float));
    
	if(fdatpt == 0) {
		nomemory();
		return(0);
	}
	
	for(n=0; n < npts; n++) {
        *(fdatpt+n) = *(datpt+n+doffset) * trailer[SFACTR];
    }
    return(1);
}

int new_float_image(int nx, int ny)			// initialize a floating-point buffer of a given size
{
	extern float *fdatpt;
	int n;
    
	if(fdatpt != 0) free(fdatpt);
	
	fdatpt = (float*) malloc(nx*ny*sizeof(float));
    
    
	if(fdatpt == 0) {
		nomemory();
		return(0);
	}
	
	for(n=0; n <nx*ny; n++) {
        *(fdatpt+n) = 0.0;
    }
    return(1);
}

int get_float_image()			// copy the current floating image into the image buffer
{
    extern float *fdatpt;
    int n,i,newsf;
    float fmn,fmx;
    
    
    
    
    if(fdatpt == 0) return(0);
    
    fmn = *(fdatpt);
    fmx = *(fdatpt);
    
    for(n=1; n < npts; n++) {
        if( *(fdatpt+n) > fmx) fmx = *(fdatpt+n);
        if( *(fdatpt+n) < fmn) fmn = *(fdatpt+n);
    }
    newsf = fmx/maxint;
    i = fmn/maxint;
    if (newsf < 0 ) newsf = -newsf;
    if (i < 0 ) i = -i;
    if (i > newsf) newsf = i;
    newsf++;
    
    for(n=0; n < npts; n++) {
        *(datpt+n+doffset) = *(fdatpt+n)/newsf;
    }
    trailer[SFACTR] = newsf;
    
    
    free(fdatpt);
    fdatpt = 0;
    
    return(1);
}

/* ***************** */



// *************************************************************************************************************


/* ********** */

int block_c(int n,char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    if (iBuffer.isColor()) {
        err = blockrgb( n, index);
    }else
        err = block( n, index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx();
    update_UI();
    return err;
}

int block(int n,int index)
/* combine the data into n x m blocks */
{
	DATAWORD *datp,*datp2;
	extern DATAWORD *datpt;
	extern int	doffset;
	DATAWORD idat(int,int);
	
#ifdef FLOAT
	DATAWORD sum;
#else
	int sum;
#endif
	
	int dx,dy,i,j,size,nt,nc,count;
	float fsum,*fdatp;
	extern float *fdatpt;
    
	if( index < 0) {  /* if called from routine other than command decoder */
		dx = n;
		dy = -index;
	} else {
		if(n <= 0) n = 2;
        
		dx = dy = n;	/* the blocking amounts */
        
		/* Check to see if there was a second argument */
        
		for ( i = index; cmnd[i] != EOL; i++) {
			if(cmnd[i] == ' ') {
				sscanf(&cmnd[index],"%d %d",&dx,&dy);
				break;
			}
		}
	}
    
	
	size = (header[NCHAN]/dx * header[NTRAK]/dy + MAXDOFFSET) * DATABYTES;
	size = (size+511)/512*512;	/* make a bit bigger for file reads */
	datp2 = datp = (DATAWORD*)malloc(size);
	if(datp == 0) {
		nomemory();
		return 1;
	}
	
	for(nc=0; nc<doffset; nc++)
		*(datp++) = *(datpt+nc);	/* copy the CCD header */
	
	count = dx*dy;
	
	if( block_ave) {
		for(nt=0; nt<header[NTRAK]/dy*dy; nt+=dy) {
			for(nc=0; nc<header[NCHAN]/dx*dx;nc+=dx){
				sum = 0;
				for(i=0; i<dx; i++) {
					for(j=0; j<dy; j++) {
						sum += idat(nt+j,nc+i);
					}
				}
				*(datp++) = sum/count;
			}
		}
	} else {
        // get floating point image
        new_float_image(header[NCHAN]/dx,header[NTRAK]/dy);
        fdatp = fdatpt;
		for(nt=0; nt<header[NTRAK]/dy*dy; nt+=dy) {
            for(nc=0; nc<header[NCHAN]/dx*dx;nc+=dx){
                fsum = 0.0;
                for(i=0; i<dx; i++) {
                    for(j=0; j<dy; j++) {
                        fsum += idat(nt+j,nc+i)*trailer[SFACTR];
                    }
                }
                *(fdatp++) = fsum;
            }
		}
	}
    
	header[NCHAN] /= dx;
	header[NTRAK] /= dy;
	header[NDX] *= dx;
	header[NDY] *= dy;
	npts = header[NCHAN] * header[NTRAK];
	free(datpt);
	datpt = datp2;
	have_max = 0;
    if(  block_ave == 0 ){
        get_float_image();
    }
	update_status();
	setarrow();
	return 0;
}
/* ********** */

int blockrgb(int n,int index)
/* combine rgb data into n x m blocks */
{
	DATAWORD *datp,*datp2,*datp_green,*datp_blue,*pt,*pt_green,*pt_blue;
	extern DATAWORD *datpt;
	extern int	doffset;
	DATAWORD idat(int,int);
	
	DATAWORD sum,sum_green,sum_blue;
	
	int dx,dy,i,j,size,nt,nc,count,nwidth,nheight;
	
	extern float *fdatpt;
    
	if( index < 0) {  /* if called from routine other than command decoder */
		dx = n;
		dy = -index;
	} else {
		if(n <= 0) n = 2;
		dx = dy = n;	/* the blocking amounts */
		/* Check to see if there was a second argument */
		for ( i = index; cmnd[i] != EOL; i++) {
			if(cmnd[i] == ' ') {
				sscanf(&cmnd[index],"%d %d",&dx,&dy);
				break;
			}
		}
	}
	
	nwidth = header[NCHAN]/dx;
	nheight = header[NTRAK]/3/dy * 3;
	size = (nwidth * nheight + MAXDOFFSET) * DATABYTES;
	size = (size+511)/512*512;	/* make a bit bigger for file reads */
	datp2 = datp = (DATAWORD*)malloc(size);
	if(datp == 0) {
		nomemory();
		return 1;
	}
	
	pt = datpt+doffset;
	pt_green = pt + header[NCHAN]*header[NTRAK]/3;
	pt_blue =  pt_green + header[NCHAN]*header[NTRAK]/3;
    
	
	for(nc=0; nc<doffset; nc++)
		*(datp++) = *(datpt+nc);	/* copy the CCD header */
	
	datp_green = datp + nwidth*nheight/3;
	datp_blue =  datp_green + nwidth*nheight/3;
    
	
	count = dx*dy;
	
	for(nt=0; nt < nheight*dy/3; nt+=dy) {
		for(nc=0; nc < nwidth*dx;nc+=dx){
			sum = sum_green = sum_blue = 0;
			for(i=0; i<dx; i++) {
				for(j=0; j<dy; j++) {
					sum += *(pt + nc+i + header[NCHAN] * (nt+j));
					sum_green += *(pt_green + nc+i + header[NCHAN] * (nt+j));
					sum_blue += *(pt_blue + nc+i + header[NCHAN] * (nt+j));
				}
			}
			if( block_ave){
				*(datp++) = sum/count;
				*(datp_green++) = sum_green/count;
				*(datp_blue++) = sum_blue/count;
			} else {
				*(datp++) = sum;
				*(datp_green++) = sum_green;
				*(datp_blue++) = sum_blue;
			}
		}
	}
    
	header[NCHAN] = nwidth;
	header[NTRAK] = nheight;
	header[NDX] *= dx;
	header[NDY] *= dy;
	npts = header[NCHAN] * header[NTRAK];
	free(datpt);
	datpt = datp2;
	have_max = 0;
	maxx();
	update_status();
	setarrow();
	return 0;
}

