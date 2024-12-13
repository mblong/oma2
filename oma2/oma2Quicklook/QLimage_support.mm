#include "image_support.h"


extern char reply[1024];
extern int printMax;

/*
 These are general purpose C functions that may be used anywhere.
 The assumption is they don't use anything in the oma2 classes unless passed as arguments.
 */

/* ***************************** Support Routines **************************** */


int two_to_four(DATAWORD* dpt, int num, TWOBYTE scale)
{
    TWOBYTE* two_byte_ptr;
    int i;
    
    two_byte_ptr = (TWOBYTE*) dpt;
    
    if(scale <= 0) scale = 1;
    for(i=num-1; i>=0; i--){
        *(dpt+i) = *(two_byte_ptr+i);
        *(dpt+i) *= scale;
    }
    return 0;
}

/* ********** */

int get_byte_swap_value(short id)
{
    char* cp;
    cp = (char*) &id;
    if( IS_BIG_ENDIAN ) {	// running on a PowerPC
        if( *(cp) ==  LITTLE_ENDIAN_CODE && *(cp+1) ==  LITTLE_ENDIAN_CODE)
            return 1;	// must have been saved on an intel machine so have to swap bytes
        else
            return 0;	// must be same kind, leave it alone
    } else {			// running on intel
        if( *(cp) ==  LITTLE_ENDIAN_CODE && *(cp+1) ==  LITTLE_ENDIAN_CODE)
            return 0;	// must have been saved on an intel machine so leave it as is
        else
            return 1;	// must be from a powerPC, have to change it
    }
    
}


/*____________________________________________________________________________*/


void swap_bytes_routine(char* co, int num,int nb)
{
    int nr;
    char ch;
    if(nb == 2){
        for(nr=0; nr < num; nr += nb) {
            ch = co[nr+1];
            co[nr+1] = co[nr];
            co[nr] = ch;
        }
    } else if (nb == 4){
        for(nr=0; nr < num; nr += nb) {
            ch = co[nr+3];
            co[nr+3] = co[nr];
            co[nr] = ch;
            ch = co[nr+2];
            co[nr+2] = co[nr+1];
            co[nr+1] = ch;
        }
    } else if (nb == 8){
        for(nr=0; nr < num; nr += nb) {
            ch = co[nr+7];
            co[nr+7] = co[nr];
            co[nr] = ch;
            
            ch = co[nr+6];
            co[nr+6] = co[nr+1];
            co[nr+1] = ch;
            
            ch = co[nr+5];
            co[nr+5] = co[nr+2];
            co[nr+2] = ch;
            
            ch = co[nr+4];
            co[nr+4] = co[nr+3];
            co[nr+3] = ch;
        }
    }
    
}



/*____________________________________________________________________________*/

void trimName(char* lastname)
{
    long length,i,j;
    length = strlen(lastname);
    for(i=length-1; i>0; i--){
        if(lastname[i] == '/')
            break;
    }
    if(i <= 2) return;	// nothing to be done here -- the name is short anyway
    strcpy(lastname, "...");
    for(j=0; j<length-i;j++){
        lastname[j+3] = lastname[j+i+1];
    }
}




unsigned long fsize(char* file)
{
    FILE * f = fopen(file, "r");
    if (f == NULL) {
        return 0;
    }
    fseek(f, 0, SEEK_END);
    unsigned long len = (unsigned long)ftell(f);
    fclose(f);
    return len;
}

/* ____________________________ load settings... ____________________________*/
// actual old length is 1872; new oma length is 4944; new oma2 length is 4232, but could change
#define OLD_SETTINGS_LENGTH 2000


int process_old_header(TWOBYTE* header,char* comment,TWOBYTE* trailer,Image* im){
    int nr,swap_bytes;
    char ch;
    TWOBYTE *scpt,tmp_2byte;
    
    
    /*  68000 aranges text differently */
    for(nr=0; nr < COMLEN; nr += 2) {
        ch = comment[nr+1];
        comment[nr+1] = comment[nr];
        comment[nr] = ch;
    }
    
    swap_bytes = get_byte_swap_value(trailer[IDWRDS]);
    if(swap_bytes) {
        swap_bytes_routine((char*)header,HEADLEN,2);
        swap_bytes_routine((char*)trailer,TRAILEN,2);
    }
    
    if(trailer[IS_COLOR_] == 1)
        im->specs[IS_COLOR] = 1;
    else
        im->specs[IS_COLOR] = 0;
    
    if(trailer[RULER_CODE] == MAGIC_NUMBER) {	// If there was a ruler defined
        im->specs[HAS_RULER] = 1;
        
        scpt = (TWOBYTE*) &(im->values[RULER_SCALE]);
        if(swap_bytes) {
            *(scpt+1) = trailer[OLD_RULER_SCALE];
            *(scpt) = trailer[OLD_RULER_SCALE+1];
            // need to change the order of values in the trailer as well
            tmp_2byte = trailer[OLD_RULER_SCALE];
            trailer[OLD_RULER_SCALE] = trailer[OLD_RULER_SCALE+1];
            trailer[OLD_RULER_SCALE+1] = tmp_2byte;
        } else {
            *(scpt) = trailer[OLD_RULER_SCALE];
            *(scpt+1) = trailer[OLD_RULER_SCALE+1];
        }
        
        strcpy(im->unit_text,(char*) &trailer[RULER_UNITS]);
        if( im->unit_text[0] ){
            //printf("%f Pixels per %s.\n",im->values[RULER_SCALE],im->unit_text);
            
        } else {
            //printf("%f Pixels per Unit.\n",im->values[RULER_SCALE]);
            
        }
    } else {
        im->specs[HAS_RULER] = 0;
    }
    im->specs[ROWS] = header[NTRAK];
    im->specs[COLS] = header[NCHAN];
    im->specs[DX] = header[NDX];
    im->specs[DY] =  header[NDY];
    im->specs[X0] = header[NX0];
    im->specs[Y0] = header[NY0];
    if(im->specs[DX] == 0)im->specs[DX]=1;
    if(im->specs[DY] == 0)im->specs[DY]=1;
    
    return swap_bytes;
}




/* ********** */

int readBinary(char* filename,Image* theImage, int bin_rows, int bin_cols,
               int bin_header, int binary_file_bytes_per_data_point, int swap_bytes_flag, int unsigned_flag){
    int fd;
    //extern int windowNameMemory;
    //char buffer[256];
    //char* pointer;
    
    //
    // copy/paste from getbin_c
    //
    int binary_file_is_float = 0;
    int nbyte,r,c;
    long nr,i;
    unsigned short *usptr;
    short *sptr;
    unsigned char tc;
    float *fptr;
    int *iptr;
    unsigned char* ptr2;
    
    
    fd = open(filename,READBINARY);
    
    if(bin_header > 0) {
        ptr2 = new unsigned char[bin_header];
        if(ptr2 == 0) {
            close(fd);
            return MEM_ERR;
        }
        
        read(fd,ptr2,bin_header);	// skip over the header
        delete[] ptr2;
    }
    Image newImage(bin_rows,bin_cols);
    if(newImage.err()){
        //beep();;
        //printf("Could not allocate %d x %d image\n",bin_rows,bin_cols);
        close(fd);
        return newImage.err();
    }
    
    nbyte = bin_rows * bin_cols * binary_file_bytes_per_data_point;
    
    if( binary_file_bytes_per_data_point == 1) {
        // allocate memory -- assume unsigned
        ptr2 = new unsigned char[nbyte];
        if(ptr2 == 0) {
            close(fd);
            return MEM_ERR;
        }
        // Read in the actual data
        nr = read(fd,ptr2, nbyte);
        //printf("%d Bytes read.\n",nr);
        close(fd);
        
        for (r=0,i=0; r<bin_rows; r++) {
            for (c=0; c<bin_cols; c++) {
                newImage.setpix(r, c, *(ptr2+i++));
            }
        }
        delete[] ptr2;
    } else if( binary_file_bytes_per_data_point == sizeof(short)) {
        // allocate memory
        sptr = (short*)malloc(nbyte);
        if(sptr == 0) {
            close(fd);
            return MEM_ERR;
        }
        // Read in the actual data
        nr = read(fd,sptr, nbyte);
        //printf("%d Bytes read.\n",nr);
        close(fd);
        
        if(swap_bytes_flag){
            // fiddle the byte order
            ptr2 = (unsigned char *)sptr;		// a copy of the data pointer
            for(i=0; i< nr; i+=2){
                tc = *(ptr2);
                *(ptr2) = *(ptr2+1);
                *(++ptr2) = tc;
                ptr2++;
            }
        }
        usptr = (unsigned short*) sptr;		// point to the same data
        for (r=0,i=0; r<bin_rows; r++) {
            for (c=0; c<bin_cols; c++) {
                if(unsigned_flag)
                    newImage.setpix(r, c, *(usptr+i++));
                else
                    newImage.setpix(r, c, *(sptr+i++));
            }
        }
        free(sptr);
    } else if( binary_file_bytes_per_data_point == sizeof(float) && binary_file_is_float) {
        // allocate memory
        fptr = (float*)malloc(nbyte);
        if(fptr == 0) {
            close(fd);
            return MEM_ERR;
        }
        // Read in the actual data
        nr = read(fd,fptr, nbyte);
        //printf("%d Bytes read.\n",nr);
        close(fd);
        for (r=0,i=0; r<bin_rows; r++) {
            for (c=0; c<bin_cols; c++) {
                newImage.setpix(r, c, *(fptr+i++));
            }
        }
        free(fptr);
    }  else if( binary_file_bytes_per_data_point == sizeof(int)){
        // allocate memory
        iptr = (int*)malloc(nbyte);
        if(iptr == 0) {
            close(fd);
            return MEM_ERR;
        }
        // Read in the actual data
        nr = read(fd,iptr, nbyte);
        //printf("%d Bytes read.\n",nr);
        close(fd);
        for (r=0,i=0; r<bin_rows; r++) {
            for (c=0; c<bin_cols; c++) {
                newImage.setpix(r, c, *(iptr+i++));
            }
        }
        free(iptr);
    }
    //iBuffer.free();     // release the old data
    *theImage = newImage;   // this is the new data
    
    theImage->getmaxx(printMax);
    //update_UI();
    
    return NO_ERR;
    
}

/* ********** */
int readCsv(char* filename,Image* theImage){
    FILE *file;
    int n,cols=0,rows=0;
    file = fopen(filename, "rb");
    if (!file)
        return FILE_ERR;
    char buffer[1024];
    // find the number of columns by counting the commas before the first newline
    n = (int)fread(buffer,1,sizeof(buffer),file);
    for(int i=0; i<n; i++){
        if(buffer[i] == ',')cols++;
        if(buffer[i] == '\n')break;
        if(i==n-1){
            n = (int)fread(buffer,1,sizeof(buffer),file);
            i=-1;
        }
    }
    cols++;
    fclose(file);
    
    file = fopen(filename, "r");
    if (!file)
        return FILE_ERR;
    std::vector<float> imageArray;
    int colread=0,numRead=0;
    DATAWORD pixval;
    // read formatted values into a vector
    while((numRead=fscanf(file,"%f,",&pixval)) == 1){
        colread++;
        if(colread==cols){
            colread=0;
            rows++;
        }
        imageArray.push_back(pixval);
    }
    // some checking
    if(colread !=0){
        //beep();;
        //printf("Posible error in CSV file read.\n");
    }
    if(rows*cols < imageArray.size()){
        //beep();;
        //printf("Can't make image from CSV file.\n");
        return MEM_ERR;
    }
    Image newIm(rows,cols);
    memcpy(newIm.data, &imageArray[0], imageArray.size()*sizeof(float));
    // I assume the memory from the vector will be freed when this goes out of scope.
    
    theImage->free();     // release the old data
    *theImage = newIm;   // this is the new data
    theImage->getmaxx(printMax);
    //update_UI();

    return NO_ERR;
}

/* ********** */
int readFits(char* filename,Image* theImage){
    fitsfile *fptr;   /* FITS file pointer, defined in fitsio.h */
    int status = 0,i;   /* CFITSIO status value MUST be initialized to zero! */
    int bitpix, naxis;
    long naxes[3] = {1,1,1}, fpixel[3] = {1,1,1};
    int rows=0,cols=0;

    if (!fits_open_file(&fptr, filename, READONLY, &status)) {
        if (!fits_get_img_param(fptr, 3, &bitpix, &naxis, naxes, &status) ){
            //printf("Axes: %d Dimensions: ",naxis);
            for(i=0; i< naxis-1; i++){
                //printf("%d x ",naxes[i]);
            }
            //printf("%d\n",naxes[i]);
        }
        
        if(naxis == 2){     //monochrome image
            rows=(int)naxes[1];
            cols=(int)naxes[0];
        } else if (naxis == 3 && naxes[2] == 3){        // color image
            rows=(int)naxes[1]*3;
            cols=(int)naxes[0];
        }else {
            //beep();;
            //printf("Unsupported FITS image format.\n");
            return FILE_ERR;
        }
        
        //https://heasarc.gsfc.nasa.gov/docs/software/fitsio/cexamples/listhead.c
        int hdupos,single,nkeys;
        char card[FLEN_CARD];   /* Standard string lengths defined in fitsio.h */
        int comBufPosition=0;
        char commentBuffer[MBUFLEN];
        fits_get_hdu_num(fptr, &hdupos);  /* Get the current HDU position */
        
        /* List only a single header if a specific extension was given */
        if (hdupos != 1 ) single = 1;
        
        for (; !status; hdupos++)  /* Main loop through each extension */
        {
            fits_get_hdrspace(fptr, &nkeys, NULL, &status); /* get # of keywords */
            
            //printf("Header listing for HDU #%d:\n", hdupos);
            
            for (int ii = 1; ii <= nkeys; ii++) { /* Read and print each keywords */
                
                if (fits_read_record(fptr, ii, card, &status))break;
                
                //printf("%s\n", card);
                if(comBufPosition+strlen(card)+2<MBUFLEN){
                    //printf(commentBuffer+comBufPosition,strlen(card)+1,"%s",card);
                    comBufPosition+= strlen(card)+1;
                }
            }

            //printf("END\n\n");  /* terminate listing with END */
            *(commentBuffer+comBufPosition+1)=0;
            
            if (single) break;  /* quit if only listing a single header */
            
            fits_movrel_hdu(fptr, 1, NULL, &status);  /* try to move to next HDU */
        }
        
        if (status == END_OF_FILE)  status = 0; /* Reset after normal error */
        float exp=0,aper=0,gain=0;
        int retval;
        // fitsfile *fptr, int datatype, const char *keyname, void *value,char *comm, int *status);
        // allow different keywords for some values
        if(fits_read_key(fptr,TFLOAT,"EXPTIME",&exp,NULL,&status)){
            fits_read_key(fptr,TFLOAT,"EXPOSURE",&exp,NULL,&status);
        }
        status=0;
        if(fits_read_key(fptr,TFLOAT,"APTDIA",&aper,NULL,&status)){
            fits_read_key(fptr,TFLOAT,"APERTURE",&aper,NULL,&status);
        }
        status=0;
        fits_read_key(fptr,TFLOAT,"GAIN",&gain,NULL,&status);
        status = 0; /* even if there were errors */
        
        Image newIm(rows,cols);
        if(naxes[2]==3) newIm.specs[IS_COLOR]=1;
        switch (bitpix){
            case FLOAT_IMG:
                if (fits_read_pix(fptr, TFLOAT, fpixel, naxes[0]*naxes[1]*naxes[2], NULL,
                                  newIm.data, NULL, &status)){
                    //beep();;
                    //printf("Error reading pixel data.\n");
                    newIm.free();
                    return FILE_ERR;
                }
                break;
            case SHORT_IMG:
                unsigned short* data;
                data =  new unsigned short[naxes[0]*naxes[1]*naxes[2]];
                if (fits_read_pix(fptr, TUSHORT, fpixel, naxes[0]*naxes[1]*naxes[2], NULL,
                                  data, NULL, &status)){
                    //beep();;
                    //printf("Error reading pixel data.\n");
                    delete[] data;
                    newIm.free();
                    return FILE_ERR;
                }
                for( size_t i=0; i< naxes[0]*naxes[1]*naxes[2]; i++) newIm.data[i] = data[i];
                delete[] data;
                break;
            default:
                //beep();;
                //printf("Unsupported FITS image format.\n");
                return FILE_ERR;
        }
        theImage->free();     // release the old data
        *theImage = newIm;   // this is the new data
        if(comBufPosition !=0) theImage->setComment(commentBuffer, comBufPosition+1);
        theImage->setvalue(EXPOSURE,exp);
        theImage->setvalue(APERTURE,aper);
        theImage->setvalue(ISO,gain);
        theImage->getmaxx(printMax);
        
        //update_UI();
        return NO_ERR;

    }
    //beep();;
    //printf("Error opening Fits image.\n");
    return FILE_ERR;
}



typedef unsigned char RGBE[4];
#define R			0
#define G			1
#define B			2
#define E			3

#define  MINELEN	8				// minimum scanline length for encoding
#define  MAXELEN	0x7fff			// maximum scanline length for encoding

static void workOnRGBE(RGBE *scan, int len, float *cols);
static int decrunch(RGBE *scanline, int len, FILE *file);
static int oldDecrunch(RGBE *scanline, int len, FILE *file);
float convertComponent(int expo, int val);


int loadHDR(const char *fileName, HDRLoaderResult *res)
{
    int i;
    char str[200];
    FILE *file;
    
    file = fopen(fileName, "rb");
    if (!file)
        return false;
    
    fread(str, 10, 1, file);
    if (memcmp(str, "#?RADIANCE", 10)) {
        fclose(file);
        return false;
    }
    
    fseek(file, 1, SEEK_CUR);
    
    char cmd[200];
    i = 0;
    char c = 0, oldc;
    while(true) {
        oldc = c;
        c = fgetc(file);
        if (c == 0xa && oldc == 0xa)
            break;
        cmd[i++] = c;
    }
    
    char reso[200];
    i = 0;
    while(true) {
        c = fgetc(file);
        reso[i++] = c;
        if (c == 0xa)
            break;
    }
    
    int w, h;
    if (!sscanf(reso, "-Y %d +X %d", &h, &w)) {
        fclose(file);
        return false;
    }
    
    res->width = w;
    res->height = h;
    
    float *cols = (float*) malloc(w * h * 3*sizeof(float));
    res->cols = cols;
    
    RGBE *scanline = (RGBE*) malloc(w * sizeof(RGBE));
    if (!scanline) {
        fclose(file);
        return false;
    }
    
    // convert image
    for (int y = h - 1; y >= 0; y--) {
        if (decrunch(scanline, w, file) == false)
            break;
        workOnRGBE(scanline, w, cols);
        cols += w * 3;
    }
    
    free(scanline);
    fclose(file);
    
    return true;
}

float convertComponent(int expo, int val)
{
    float v = val / 256.0f;
    float d = (float) pow(2, expo);
    return v * d;
}

void workOnRGBE(RGBE *scan, int len, float *cols)
{
    while (len-- > 0) {
        int expo = scan[0][E] - 128;
        cols[0] = convertComponent(expo, scan[0][R]);
        cols[1] = convertComponent(expo, scan[0][G]);
        cols[2] = convertComponent(expo, scan[0][B]);
        cols += 3;
        scan++;
    }
}

int decrunch(RGBE *scanline, int len, FILE *file)
{
    int  i, j;
    
    if (len < MINELEN || len > MAXELEN)
        return oldDecrunch(scanline, len, file);
    
    i = fgetc(file);
    if (i != 2) {
        fseek(file, -1, SEEK_CUR);
        return oldDecrunch(scanline, len, file);
    }
    
    scanline[0][G] = fgetc(file);
    scanline[0][B] = fgetc(file);
    i = fgetc(file);
    
    if (scanline[0][G] != 2 || scanline[0][B] & 128) {
        scanline[0][R] = 2;
        scanline[0][E] = i;
        return oldDecrunch(scanline + 1, len - 1, file);
    }
    
    // read each component
    for (i = 0; i < 4; i++) {
        for (j = 0; j < len; ) {
            unsigned char code = fgetc(file);
            if (code > 128) { // run
                code &= 127;
                unsigned char val = fgetc(file);
                while (code--)
                    scanline[j++][i] = val;
            }
            else  {	// non-run
                while(code--)
                    scanline[j++][i] = fgetc(file);
            }
        }
    }
    
    return feof(file) ? false : true;
}

int oldDecrunch(RGBE *scanline, int len, FILE *file)
{
    int i;
    int rshift = 0;
    
    while (len > 0) {
        scanline[0][R] = fgetc(file);
        scanline[0][G] = fgetc(file);
        scanline[0][B] = fgetc(file);
        scanline[0][E] = fgetc(file);
        if (feof(file))
            return false;
        
        if (scanline[0][R] == 1 &&
            scanline[0][G] == 1 &&
            scanline[0][B] == 1) {
            for (i = scanline[0][E] << rshift; i > 0; i--) {
                memcpy(&scanline[0][0], &scanline[-1][0], 4);
                scanline++;
                len--;
            }
            rshift += 8;
        }
        else {
            scanline++;
            len--;
            rshift = 0;
        }
    }
    return true;
}
