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
extern int printMax;


// Globals used by commands in the old oma
// Many of these may not be used

TWOBYTE	header[HEADLEN/2] = { 0,0,0,0,0,1,500,500,1,1,0,0,0,1,1 };
TWOBYTE	trailer[TRAILEN/2];
char	comment[COMLEN] = {0};



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
#ifndef FLOAT_
int     maxint = ~(1<<(DATABYTES*8-1));		//	32764		// the max count
#endif
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

DATAWORD    valuesCopy[NVALUES];

int moveOMA2toOMA(int n,char* args){
    unsigned long i=0;
    int r,c,index=0;
    int *imspecs = iBuffer.getspecs();
    DATAWORD* imValues = iBuffer.getvalues();
    for(i=0; i<NVALUES; i++) valuesCopy[i]=imValues[i];
    free(imValues);
    
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
    // args has just the argument, but some old commands may use index=0 for some other purpose
    // so pad args with a leading space
    cmnd[0] = ' ';
    strncpy(cmnd+1, args, CHPERLN-1);
    index = 1;

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
    
    unsigned long i=0;
    int r,c;
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
    
    iBuffer.setvalues(valuesCopy);

    free(imspecs);
    free(datpt);
    datpt = NULL;
    
}

// do-nothings (for now)
void nomemory(){}
void update_status(){}
void setarrow(){}
void maxx(){}


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
    int n;
    

    if(fdatpt == 0) return(0);
    
#ifdef FLOAT_
    for(n=0; n < npts; n++) {
        *(datpt+n+doffset) = *(fdatpt+n);
    }

#else
    
    int i,newsf;
    float fmn,fmx;
    
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
#endif
    
    free(fdatpt);
    fdatpt = 0;
    
    return(1);
}

// *************************************************************************************************************


/* ********** */

int block_g(int n,char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    if (iBuffer.isColor()) {
        err = blockrgb( n, index);
    }else
        err = block( n, index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
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
	
#ifdef FLOAT_
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

/***********************************************************/
/*
 *  Cyl2.c
 *
 *
 *  Created by clduser on 3/5/12.
 *
 */

int cyl2_g(int n,char* args){
    int index = moveOMA2toOMA(n,args);
    int err;

    err = Cyl2( n, index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;
}

int Cyl2(int n,int index)    {                // cylindrical image
    
    DATAWORD *fdatp=0;
    int row,col,depth;
    int i,j,k,DI,size;
    float D,dr,V,V1,V2;
    
    // space for the new image
    size = (header[NCHAN] * header[NTRAK] + MAXDOFFSET) * DATABYTES;
    size = (size+511)/512*512;    // make a bit bigger for file reads
    
    fdatp = (float*) calloc(size,1);
    
    if(fdatp == 0) {
        nomemory();
        return -2;
    }
    
    row = header[NTRAK];
    col = header[NCHAN];
    depth = col;
    
    for    (j=0;j<row;j++) {
        for (i=0;i<col;i++){
            V = 0.;
            
            for (k=0; k<depth; k++) {
                D = sqrt(pow(i,2)+pow(k,2));
                DI = floor(D);
                dr = D-DI;
                if (D<col-1) {
                    V1 = *(datpt+doffset+j*col+DI);
                    V2 = *(datpt+doffset+j*col+DI+1);
                }
                else if (D==col-1) {
                    V1 = *(datpt+doffset+j*col+DI);
                    V2 = 0;
                }
                else if (D>col-1) {
                    V1 = 0;
                    V2 = 0;
                }
                V = V+(V1+(V2-V1)*dr);
            }
            
            V = 2*V-*(datpt+doffset+j*col); //The first column is repeated only once.
            *(fdatp+doffset+j*col+i) = V;
        }
    }
    // copy the 2nd column to the 1st one.
    for (j=0;j<row;j++) {
        *(fdatp+doffset+j*col) = *(fdatp+doffset+j*col+1);
    }
    
    free(datpt);
    datpt = fdatp;
    
    have_max=0;
    maxx();
    
    return(0);
}

/***********************************************************/

/* ************************************************************ */
/* Slightly different abel inversion, Kevin Walsh,June 26, 1996 */
/* 																*/
/* 			     uses analytic evaluation of integral required  */
/*               for abel inversion, which involves a lot of    */
/*               evaluations of ln(x)             	            */
/*           													*/
/*    n is a scale factor for the image       					*/
/*           													*/
/* ************************************************************ */

int kwabel_g(int n, char* args){
    //int index =
    moveOMA2toOMA(n,args);
    int err;
    
    err = kwabel(n);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;

}

int kwabel(int n)			/* 	calculate abel inversion */
{
	int nc,nt,x,j;
	float di;
	DATAWORD idat(int,int),*datp;
	float sum=0, datsum, xsum, x2sum, xdatsum,frac;
	float top,bot,fx,fnc;
	float coldat[1024];    /* dummy array to hold one row of data during calculation */
	float deriv[1024];
	float area1,area2,norm=0,scale;
	
	datp = datpt+doffset;
    
    if (n==0) scale=1.0;
	else scale=(float)n;
    
	/* do reconstruction replacing data */
	for(nt=0; nt<header[NTRAK];nt++) {
		/*********** get area under curve of a single row of intigrated data **********/
		area1 = 0.0;
		area2 = 0.0;
		for(nc=0;nc < header[NCHAN]; nc++){
			area1 += (float)(*(datp + nt*header[NCHAN] + nc));
			coldat[nc] = (float)(*(datp + nt*header[NCHAN] + nc));
		}
		area1 *= 2.0;
		area1 -= coldat[0];
		for(x=0;x < header[NCHAN]; x++){
            /*********** use least sqrs approx. with 3 pts. to calc. derivative ********/
            datsum = 0.0;
            xsum = 0.0;
            x2sum = 0.0;
            xdatsum = 0.0;
            if(x == 0){
                di = idat(nt,x+1) - idat(nt,x);
            }
            else {
                if(x == header[NCHAN]-1){
                    di = idat(nt,x) - idat(nt,x-1);
                }
                else {
                    for(j=0; j < 3; j++) {
                        datsum += idat(nt,x-1+j);
                        xsum += x+j;
                        x2sum += (x+j)*(x+j);
                        xdatsum += idat(nt,x-1+j)*(x+j);
                    }
                    di = (xdatsum - datsum * xsum / 3.0) / ( x2sum - xsum * xsum / 3.0);
                }
            }
            deriv[x]=di;
        }
		/*********** do inversion **********/
		for(nc=1;nc < header[NCHAN]; nc++){
			sum = 0.0;
			for(x=nc;x < header[NCHAN]; x++){
				fx = (float)x;
				fnc = (float)nc;
				top = fx + sqrt(fx*fx-fnc*fnc);
				bot = fx+1.0+sqrt((fx+1.0)*(fx+1.0)-fnc*fnc);
				frac= top/bot;
				sum += (1.0/PI)*deriv[x]*log(frac);
            }
			coldat[nc] = sum;
			area2+=PI*(2.0*(float)nc+1.0)*sum;
		}
        /* At r=0 (nc=0) the integral is undefined - as a solution make f(r=0)=f(r=1) */
        coldat[0]=coldat[1];
        area2+=PI*sum;
        if (area2>0.0) norm=area1/area2;
        /* Scaling done to assure that photon counts are conserved */
        
        for(nc=0;nc < header[NCHAN]; nc++){
            *(datp + nt*header[NCHAN] + nc)	= coldat[nc]*norm*scale; 
		}
	}

	have_max = 0;
    maxx();
    return 0;
}
/* ************************* */

int operator_is_defined=0;
int abel_row,abel_col;
DATAWORD* abel_datp=0;

/* ABEL
 Calculate the abel inversion using
 // Calculate three-point abel inversion operator Di,j
 // The index i,j start from 0.
 // The formula followed Dasch 1992 (Applied Optics) which contains several typos.
 // One correction is done in function OP1 follow Martin's PhD thesis
 */

int abelinv_g(int n, char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    
    err = abelinv(n,index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;

}

int abelinv(int n,int index){
    int row, col, size;
    int i,j,k;
    
    DATAWORD *datp;
    
    // function prototype
    float OP0(int i,int j);
    float OP1(int i,int j);
    float OP_D(int i,int j);
    
    row = header[NTRAK];
    col = header[NCHAN];
    
    // if operator is not defined or not the right size, then calculate a new one for this image size
    if(!(operator_is_defined && abel_row==row && abel_col==col)){
        
        if (abel_datp!=NULL) {
            //printf("Operator has been defined previously. Free it\n");
            free(abel_datp);
        }
        abel_datp = (DATAWORD*)malloc(row*col*sizeof(DATAWORD));
        
        if( abel_datp == 0) {
            nomemory();
            return -1;
        }
        abel_row=row;
        abel_col=col;
        //printf("abel_row is %d", row);
        i=0;
        for (k=0; k<row; k++) {
            for (j=0; j<col; j++) {
                *(abel_datp+i) = OP_D(k,j);
                i++;
            }
        }
        operator_is_defined=1;
    }
    
    size = (header[NCHAN] * header[NTRAK] + MAXDOFFSET) * DATABYTES;
    
    size = (size+511)/512*512;    /* make a bit bigger for file reads */
    //printf("%d\n",row);
    
    datp = (DATAWORD*)calloc(size,1);
    if(datp == 0) {
        nomemory();
        return -1;
    }
    
    datp = datp+doffset;    /* I guess this one make the pointer to skip the first 80 bytes information*/
    
    
    
    for (i=0; i<row; i++) {
        for (k=0; k<col; k++) {
            for (j=0; j<col; j++) {
                *(datp+i*col+k) += *(datpt+doffset+i*col+j)* *(abel_datp+k*col+j);
            }
        }
    }
    
    // copy the 2nd col to the 1st col.
    //for (i=0; i<row; i++) {
    //    *(datp+i*col) = *(datp+i*col+1);
    //}
    
    free(datpt);
    datpt = datp-doffset;    /* Needs the 80 bytes thing for buffer*/
    
    have_max=0;
    maxx();
    
    return(0);
}

// functions for the ABEL command
// The definition of operators
float OP0(int i,int j)
{
    float I0=0;
    // Define operator OP0
    if (j<i || (j==i&&i==0))
        I0 = 0;
    else if (j==i&&i!=0)
        I0 = log((pow(pow((2*j+1),2)-4*pow(i,2),0.5) +2*j+1)/(2*j))/(2*PI);
    else if (j>i)
        I0 = log((pow(pow((2*j+1),2)-4*pow(i,2),0.5)+2*j+1)/(pow((pow((2*j-1),2)-4*pow(i,2)),0.5)+2*j-1))/(2*PI);
    return (I0);
}

float OP1(int i,int j)
{
    // Define operator OP1
    float I1=0;
    if (j<i)
    {I1 = 0;}
    else if (j==i)
    {I1 = pow(pow((2*j+1),2)-4*pow(i,2),0.5)/(2*PI)-2*j*OP0(i,j);}
    else if (j>i)
    {I1 = (pow(pow((2*j+1),2)-4*pow(i,2),0.5)-pow(pow((2*j-1),2)-4*pow(i,2),0.5))/(2*PI)-2*j*OP0(i,j);}
    return (I1);
}

float OP_D(int i,int j)
{
    // Calculate three-point abel inversion operator Di,j
    // The index i,j start from 0.
    // The formula followed Dasch 1992 (Applied Optics) which contains several typos.
    // One correction is done in function OP1 follow Martin's PhD thesis
    
    float ID=0;
    if (j<i-1)
        ID = 0.;
    else if (j==i-1)
        ID = OP0(i,j+1)-OP1(i,j+1);
    else if (j==i)
        ID = OP0(i,j+1)-OP1(i,j+1)+2*OP1(i,j);
    else if (i==0&&j==1)
        ID = OP0(i,j+1)-OP1(i,j+1)+2*OP1(i,j)-2*OP1(i,j-1);
    else if (j>=i+1)
        ID = OP0(i,j+1)-OP1(i,j+1)+2*OP1(i,j)-OP0(i,j-1)-OP1(i,j-1);

    return (ID);
}


/* ************************* */


/*
 ABELPREP clip_value [fill_value]
 Finds the maximum pixel value along horizontal lines in the image. If that
 maximum is < clip_value, the entire horizontal line is set to fill_value.
 Default for fill_value is 0.
 */

int abelprep_g(int n, char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    
    err = abelprep(n,index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;
}

int abelprep(int n, int index){
	float fill_value = 0.0, clip_value = 0.;
	float hmax = 0.;
	int nt,nc=0,i;
	
	for ( i = index; cmnd[i] != EOL; i++) {
		if(cmnd[i] == ' ') {
			nc = sscanf(&cmnd[index],"%f %f",&clip_value,&fill_value);
			break;
		}
	}
	if (nc < 1){
		beep();
		printf("Command format is ABELPREP clip_value [fill_value]\n");
		return -1;
	} else if (nc == 1) {
		fill_value = 0.0;
	}
	
	for(nt=0; nt < header[NTRAK]; nt++){
		hmax = -1e10 ;
		for(nc=0; nc<header[NCHAN]; nc++) {
			if( idat(nt,nc) > hmax)
				hmax = idat(nt,nc);
		}
		if ( hmax < clip_value){
			for(nc=0; nc<header[NCHAN]; nc++)
				*(datpt+doffset+nc+nt*header[NCHAN]) = fill_value;
		}
	}
	have_max = 0;
	maxx();
	return 0;
}


/*
 A different version -- sets values lower than  clip_value to fill_value
 The discontinuities make for some funny looking things
 
 int abelprep(int n, int index){
 float fill_value = 0.0, clip_value = 0.;
 
 int nt,nc=0,i;
 
 for ( i = index; cmnd[i] != EOL; i++) {
 if(cmnd[i] == ' ') {
 nc = sscanf(&cmnd[index],"%f %f",&clip_value,&fill_value);
 break;
 }
 }
 if (nc < 1){
 beep();
 printf("Command format is ABELPREP clip_value [fill_value]\n");
 return -1;
 } else if (nc == 1) {
 fill_value = 0.0;
 }
 
 for(nt=0; nt < header[NTRAK]; nt++){
 for(nc=0; nc<header[NCHAN]; nc++) {
 if( idat(nt,nc) <=  clip_value)
 *(datpt+doffset+nc+nt*header[NCHAN]) = fill_value;
 }
 }
 have_max = 0;
 maxx();
 return 0;
 }
 */

/* ************************* */


/*
 ABELRECT rec_width [rec_y0 rec_y1]
 Sets the rectangle (of width rec_width) according to the centroid of the image.
 If rec_y0 and rec_y1 are omitted, they are taken to be the top and bottom of the image
 */

int abelrect_g(int n, char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    
    err = abelrect(n,index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;
}

int abelrect(int n, int index){
    
	float datval;
	int nt,nc=0,icount=0,y0=0,y1,width = 50;
	y1 = header[NTRAK]-1;
	double xcom=0.,ave=0.;
	
	//extern Point substart,subend;
	extern DATAWORD min;
	
	
	nc = sscanf(&cmnd[index],"%d %d %d",&width,&y0,&y1);
	//printf(" width, y0 y1 %d %d %d\n",width,y0,y1);
	if (nc < 1){
		beep();
		printf("Command format is ABELRECT rec_width [rec_y0 rec_y1]\n");
		return -1;
	}
	printf(" width, y0 y1 narg %d %d %d %d\n",width,y0,y1,nc);
	for(nt=y0; nt <= y1; nt++){
		for(nc=0; nc<header[NCHAN]; nc++) {
			datval = idat(nt,nc);
			ave += datval;					// average
			xcom += nc * (datval-min);			// x center of mass -- subtract min
			icount++;						// number of points
		}
	}
	xcom /= icount;
	ave = ave/(float)icount;
	xcom /= (ave-min);
	
	substart.h = xcom+.5;
	substart.v = y0;
	
	subend.h = substart.h + width;
	subend.v = y1;
	
	return 0;
}

/* ************************* */


/* ************************* */
/*
STRTIM x0 dy scale_factor
    This plots a series of streamlines in the image (similar to a loop containing STREAM commands). x0 is the starting location of the ray that will be propagated mainly in the x direction. dy is increment between rays and can be less than one pixel if a continuous "time elapsed" image is desired. When more than one elapsed time occurs within a given pixel, the minimum value is given. The two components of the velocity field are needed. The y velocity is stored in temporary image 0; the x velocity field is in the current image buffer. On return, the image is -1 except for the stream lines. Values along the stream line correspond to elapsed time as determined by the scale_factor. time = distance/velocity*scale_factor. Distance is in pixels; velocity as per values in velocity files.
*/

int strtim_g(int n, char* args){
    int index = moveOMA2toOMA(n,args);
    int err;
    
    backsize=0;
    backdat=NULL;
    backdat=iTempImages[0].getImageData();
    backsize=(iTempImages[0].width()*iTempImages[0].height()+MAXDOFFSET)*DATABYTES;
    err = strtim(n,index);
    
    moveOMAtoOMA2();
    iBuffer.getmaxx(printMax);
    update_UI();
    return err;
}

int strtim(int n, int index)            // calculate an image made up of elapsed time
                                                // along streamlines
                                                // STRTIM x0 dy scale_factor
                                                // x0 is the starting x point for all rays
                                                // dy is increment between rays
                                                // the two components of the velocity field are needed
                                                // the y velocity is stored with SBACK
                                                // the x velocity field is in the current image buffer
                                                // it is assumed that the major velocity component is in the x direction
{
    int ix,iy,nt,nc,count = 0;
    int narg,size;
    double x,y=0,distance=0,theta,theta_min,theta_max,vx,vy;
    double dx,x0,y0,time=0,factor,v;
        double dy,ymax,loopy;
    float sx,sy,f;
    DATAWORD *datp,idat(int,int),*datp2,*datp3,itime;
        
    //extern DATAWORD *backdat;        // the data pointer for backgrounds
    //extern unsigned int backsize;

    
    size = (header[NCHAN] * header[NTRAK] + MAXDOFFSET) * DATABYTES;
    size = (size+511)/512*512;    // make a bit bigger for file reads

    datp2 = (DATAWORD*)malloc(size);
    if(datp2 == 0) {
        nomemory();
        return -1;
    }
    datp = datp2+doffset;                 // set image to -1
    for(nt=0; nt<header[NTRAK];nt++) {
        for(nc=0;nc < header[NCHAN]; nc++){
            *(datp++) = -1;
        }
    }
    
    datp = datp2+doffset;
    //datp3 = backdat + doffset;
    datp3 = backdat;
    
    narg = sscanf(&cmnd[index],"%f %f %f",&sx,&sy,&f);
    if(narg != 3){
        beep();
        printf("Need 3 args: x0 dy scale_factor\n");
        return -1;
    }
    x = sx;
    dy = sy;
    factor = f;
    printf("%f %f %f\n",x,y,factor);
        if(backdat == 0) {
            beep();
            printf("Must load second image using SBACK first.\n");
            return -1;
        }
        if( (header[NCHAN]*header[NTRAK]+MAXDOFFSET)*DATABYTES != backsize) {
            beep();
            printf("Image Sizes Conflict.\n");
            return -2;
        }
        ymax = header[NTRAK]-1;
    for(loopy = 0.1; loopy< ymax; loopy+= dy){
            // start at specified pixel
            x = sx;
            y = loopy;
            ix = x;
            iy = y;
            distance = 0.0;
            time = 0.0;
            count = 0;
            //printf("%d %d\n",ix,iy);
            // propogate across the entire image
            while(ix < header[NCHAN]-1 && iy > 1 && iy < header[NTRAK]-1&& count++ < header[NCHAN]*3){
                x0 = x;
                y0 = y;
                vx = idat(iy,ix);
                vy = *(datp3 + ix + iy*header[NCHAN]);    /* y velocity */
                v = sqrt(vx*vx+vy*vy);
                theta = atan(vy/vx);
                
                itime = time;
                if(*(datp + ix + iy*header[NCHAN]) == -1 || itime < *(datp + ix + iy*header[NCHAN]) ){  // remember the minimum time
                    *(datp + ix + iy*header[NCHAN]) = itime;    // fill in this pixel
                }
                
                if(x == (float)ix){        // start from LHS of pixel
                        theta_max = atan( (float)(iy+1) - y );
                        theta_min = atan( (float)(iy) - y );
                        if( theta <= theta_max && theta >= theta_min){    // this will make it to the RHS of the pixel
                                ix++;
                                x = ix;
                                y = y + tan(theta);
                        } else if(theta > theta_max) {            // this will go to pixel above
                                x = x + ((float)(iy+1) - y)/tan(theta);
                                iy++;
                                y = iy;
                        } else {                                // this goes to pixel below
                                x = x + ((float)(iy) - y)/tan(theta);
                                iy--;
                                y = iy+1;
                        }
                } else {                                    // start from top or bottom of pixel
                        theta_max = atan( 1.0/(1.0 - x + (float)ix));
                        theta_min = -theta_max;
                        if( theta <= theta_max && theta >= theta_min){    // this will make it to the RHS of the pixel
                                y = y + tan(theta)*(1.0 - x + (float)ix);
                                ix++;
                                x = ix;
                        } else if(theta > 0.0) {                // this will go to pixel above
                                x = x + 1.0/tan(theta);
                                iy++;
                                y = iy;
                        } else {                                // this goes to pixel below
                                x = x - 1.0/tan(theta);
                                iy--;
                                y = iy+1;
                        }
                }
                dx = sqrt( (x-x0)*(x-x0) + (y-y0)*(y-y0) );
                distance += dx;
                time += dx/v*factor;
            }
    }
    
    free(datpt);
    datpt = datp2;
    
    have_max = 0;
        maxx();
        printf(" Distance and Time:\t%f\t%f\n", distance,time);
    return 0;
    
}
/* ************************* */
