#include "oma2.h"
#include "image.h"
#include "jpeglib.h"


int read_jpeg(char* filename,int thecolor,Image* im)
{

	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	FILE * infile;
	
	JSAMPROW row = 0;
	
	int i,nbyte;
	
	//extern int have_max;
	//extern DATAWORD *datpt;
	//extern TWOBYTE 	header[],trailer[];
	//extern int 		doffset;
	//extern int		npts;		/* number of data points */
	//extern short	detector;
	//extern int		nbyte,dhi,dlen;
	//extern char     		comment[];
    //extern short image_is_color;
	DATAWORD *pt,*pt_green,*pt_blue;
    
	
/*
http://www.php-websource.com/php500/source-gd_jpeg.htm

volatile JSAMPROW row = 0;
volatile gdImagePtr im = 0;
JSAMPROW rowptr[1];
unsigned int i, j;
int retval;
JDIMENSION nrows;
int channels = 3;
int inverted = 0;
memset(row, 0, cinfo.output_width * channels * sizeof(JSAMPLE));
rowptr[0] = row;

if (cinfo.out_color_space == JCS_CMYK) {
for (i = 0; i < cinfo.output_height; i++) {
register JSAMPROW currow = row;
register int *tpix = im->tpixels[i];
nrows = jpeg_read_scanlines (&cinfo, rowptr, 1);
*/

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);
	
	// the source of the data
	if ((infile = fopen(filename, "r")) == NULL) {
        beep();
	    printf( "Can't open %s\n", filename);
	   return(FILE_ERR);
	}
    
    // Be sure this is not 0 bytes long or the program will exit
    char c;
    i = fscanf(infile, "%c",&c);
    if (i !=1 ){
        printf( "%s is empty.\n", filename);
        fclose(infile);
        return NO_ERR;   // don't flag this as an error for now
    }
    rewind(infile);
    
	jpeg_stdio_src(&cinfo, infile);

	// obtain image info
	i = jpeg_read_header(&cinfo, TRUE);
    if (i == 0) {
        printf( "Header Problem in %s.\n", filename);
        return(FILE_ERR);
    }
	
	jpeg_calc_output_dimensions(&cinfo);
	
	// allocate memory
	row = (JSAMPROW)calloc(cinfo.output_width * cinfo.output_components,sizeof(JSAMPLE));
	
    // add the original file name as a comment
    /*
	for(i=0;i<COMLEN;i++) comment[i] = 0;
	sprintf(comment,"Original file: %s",filename);
    */
    int* specs = im->getspecs();
	
	specs[COLS] = cinfo.output_width;
	if(thecolor == -1){
		specs[ROWS] = cinfo.output_height*cinfo.output_components;
        specs[IS_COLOR] = 1;
	} else {
		specs[ROWS] = cinfo.output_height;
        specs[IS_COLOR] = 0;
    }
	specs[DX] = specs[DY] = 1;
	specs[X0] = specs[Y0] = 0;
	nbyte = (specs[NCHAN]*specs[NTRAK]) * DATABYTES;
	
	if (cinfo.output_components == 1) thecolor = 0;
	// this could be big!
	//dlen = 5000;
	//dhi = 15000;
    
    /*
	
	if(nbyte <= 0 || checkpar()==1) {
			beep();
			printf(" Cannot Read %d Bytes!\n",nbyte);
			printf(" %d Channels & %d Tracks Reset to 1.\n",header[NCHAN],header[NTRAK]);
			header[NCHAN] = header[NTRAK] = npts = 1;
			//close(fd);
			return -1;
	}
     */
    im->setspecs(specs);
    free(specs);
    if (im->error != NO_ERR) {
        fclose(infile);
        free(row);
        return im->error;
    }
	
	pt = im->data;
	pt_green = pt + cinfo.output_height*cinfo.output_width;
	pt_blue =  pt_green + cinfo.output_height*cinfo.output_width;
	jpeg_start_decompress(&cinfo);

	/*
	printf("width: %d\nheight: %d\nout color components: %d\ncolor components:%d\n",
			cinfo.output_width,cinfo.output_height,cinfo.out_color_components,cinfo.output_components,
			cinfo.actual_number_of_colors);
	*/
	printf("%d x %d image\n%d color components\n",
			cinfo.output_width,cinfo.output_height,cinfo.output_components);

	while (cinfo.output_scanline < cinfo.output_height){
		jpeg_read_scanlines(&cinfo, &row, 1);
		if(thecolor != -1){
			for(i=0; i< cinfo.output_width;i++){
				*pt++ = *(row+cinfo.output_components*i+thecolor);
			}
		}else {
			for(i=0; i< cinfo.output_width;i++){
				*pt++ = *(row+cinfo.output_components*i);
				*pt_green++ = *(row+cinfo.output_components*i+1);
				*pt_blue++ = *(row+cinfo.output_components*i+2);
			}
		
		}
	}
    
	jpeg_finish_decompress(&cinfo);
    
    fclose(infile);
    
	free(row);
	//have_max = 0;
	//maxx();
	//update_status();
	return NO_ERR;

}
