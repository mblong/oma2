#include "commands_1.h"

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData;

extern Image  iTempImages[];
extern Image   accumulator;   // the accumulator
extern Image   hdrAccumulator;   // the HDR accumulator
extern Image   hdrCounter;       // the HDR counter
extern DATAWORD hdrCutoffMax;       // the HDR saturation value
extern DATAWORD hdrCutoffMin;       // the HDR min value for inclusion in the image
extern float   hdrMaxScale;        // this is the biggest scale factor -- use to determine largest value in an hdr image
extern int      hdrFrames;     // HDR frame counter
extern int numberNamedTempImages;
extern Variable namedTempImages[];

/* ********** */
/// Add a constant
///
int plus_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
        val = n;
    (iBuffer+val);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    //cout << "test message\n";
    return NO_ERR;
}

/* ********** */

/// Do nothing
///
int null_c(int n,char* args){
    return NO_ERR;
}

/* ********** */
/// Subtract a constant.
///
int minus_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
        val = n;
    (iBuffer-val);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */
/// Divide by a constant.
///
int divide_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
        val = n;
    (iBuffer/val);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */
/// Multiply by a constant.
///

int multiply_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
        val = n;
    (iBuffer*val);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */
/// Multiply RGB by a specified constants.
///

int mulRGB_c(int n,char* args){
    
    float x,y,z;
    
    if( sscanf(args,"%f %f %f",&x,&y,&z) != 3){
        beep();
        printf("3 Arguments needed\n");
        return CMND_ERR;
    }
    iBuffer.rgbMult(x,y,z);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ********** */
/// divide RGB by a specified constants.
///

int divRGB_c(int n,char* args){
    
    float x,y,z;
    
    if( sscanf(args,"%f %f %f",&x,&y,&z) != 3){
        beep();
        printf("3 Arguments needed\n");
        return CMND_ERR;
    }
    iBuffer.rgbDiv(x,y,z);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ********** */
/// subtract RGB by a specified constants.
///

int subRGB_c(int n,char* args){
    
    float x,y,z;
    
    if( sscanf(args,"%f %f %f",&x,&y,&z) != 3){
        beep();
        printf("3 Arguments needed\n");
        return CMND_ERR;
    }
    iBuffer.rgbSub(x,y,z);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ********** */
/// add RGB by a specified constants.
///

int addRGB_c(int n,char* args){
    
    float x,y,z;
    
    if( sscanf(args,"%f %f %f",&x,&y,&z) != 3){
        beep();
        printf("3 Arguments needed\n");
        return CMND_ERR;
    }
    iBuffer.rgbAdd(x,y,z);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */
/// raise RGB to power by specified constants.
///

int powRGB_c(int n,char* args){
    
    float x,y,z;
    
    if( sscanf(args,"%f %f %f",&x,&y,&z) != 3){
        beep();
        printf("3 Arguments needed\n");
        return CMND_ERR;
    }
    iBuffer.rgbPow(x,y,z);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int power_c(int n,char* args)				// raise the data to a power
{
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
        val = n;
    iBuffer.power(val);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int savefile_c(int n,char* args)
{
    if(*args == 0){	// no file name was specified
        beep();
        printf(" No filename specified.\n");
        return FILE_ERR;
    } else { // otherwise, add the prefix and suffix and use the name specified
        iBuffer.saveFile(args,SHORT_NAME);
        return iBuffer.err();
    }
}

/* ********** */

/*
SAVEINT filename [typeOfInteger]
 Save the data to an oma2 file where the values are converted to integers. Default is typeOfInteger=16 (unsigned 16-bit integers) Other options for typeOfInteger are -16 (signed short), 8 (unsigned char), or -8 (signed char). Out of bounds values for a given type are set to the type's minimum and maximum.
 */

int saveInt_c(int n,char* args)
{
    char filename[CHPERLN];
    int typeOfInt=16;
    int narg = sscanf(args,"%s %d", filename, &typeOfInt);


    if(narg < 1){    // no file name was specified
        beep();
        printf(" No filename specified.\n");
        return FILE_ERR;
    } else { // otherwise, add the prefix and suffix and use the name specified
        switch (typeOfInt){
            case 16:
                iBuffer.saveFile(filename,SHORT_NAME,UNSIGNED16);
                return iBuffer.err();
            case -16:
                iBuffer.saveFile(filename,SHORT_NAME,SIGNED16);
                return iBuffer.err();
            case 8:
                iBuffer.saveFile(filename,SHORT_NAME,UNSIGNED8);
                return iBuffer.err();
            case -8:
                iBuffer.saveFile(filename,SHORT_NAME,SIGNED8);
                return iBuffer.err();
            default:
                beep();
                printf("Specified integer type must be -8, 8, -16 or 16.\n");
                return FILE_ERR;
        }
    }
}

/* ********** */

int fwdatm_c(int n,char* args)
{
    int	i,nt,nc;
    FILE *fp;
    char fname[CHPERLN],delimiter=0;
    
    n = sscanf(args,"%s %c",fname,&delimiter);
    if(n==0){
        beep();
        printf("Need a file name.\n");
        return CMND_ERR;
    }
    if(delimiter == ','){
        fp = fopen(fullname(fname,CSV_DATA),"w");
    } else {
        fp = fopen(fullname(fname,SAVE_DATA),"w");
    }
    if( fp != NULL) {
        i=0;
        int* specs = iBuffer.getspecs();
        for(nt=0; nt<specs[ROWS]; nt++){
            for(nc=0; nc<specs[COLS]; nc++){
                if(n==2){
                    if(nc == specs[COLS]-1)
                        fprintf(fp,"%g\n",iBuffer.getpix(nt,nc));
                    else
                        fprintf(fp,"%g%c",iBuffer.getpix(nt,nc),delimiter);
                } else {
                    if(nc == specs[COLS]-1)
                        fprintf(fp,"%g\n",iBuffer.getpix(nt,nc));
                    else
                        fprintf(fp,"%g\t",iBuffer.getpix(nt,nc));
                }
            }
        }
        fclose(fp);
        delete[] specs;
    }
    else {
        beep();
        printf("Could not open file: %s\n",args);
        return FILE_ERR;
    }
    return NO_ERR;
}
/* ********** */

int pixValue_c(int n,char* args)
{
    int	r=0, c=0, frameSize = iBuffer.width()*iBuffer.height();
    extern Variable user_variables[];
    
    sscanf(args,"%d %d",&r,&c);
    printf("Pixel at row %d and column %d is: ",r,c);
    if (iBuffer.isColor()) {
        printf("%g R, %g G, %g B\n",iBuffer.getpix(r,c),iBuffer.getpix(r+frameSize,c),iBuffer.getpix(r+frameSize*2,c));
        user_variables[0].fvalue = iBuffer.getpix(r,c);
        user_variables[0].is_float = 1;
        user_variables[1].fvalue = iBuffer.getpix(r+frameSize,c);
        user_variables[1].is_float = 1;
        user_variables[2].fvalue = iBuffer.getpix(r+frameSize*2,c);
        user_variables[2].is_float = 1;
    } else {
        printf("%g\n",iBuffer.getpix(r,c));
        user_variables[0].fvalue = iBuffer.getpix(r,c);
        user_variables[0].is_float = 1;
    }
    return NO_ERR;
}

/* ********** */

int getfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not load %s\n",args);
        return new_im.err();
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    int extraSize = iBuffer.getExtraSize();
    if (extraSize) {
        printf("Image has %d extra floating point values.\n",extraSize);
    }
    int* specs = iBuffer.getspecs();
    if (specs[NFRAMES]) {
        printf("Showing image 1 of %d.\n",specs[NFRAMES]+1);
    }
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

/*
 GETBINARYFILE <filename> rows columns headerBytes bytesPerDataPoint swapBytesFlag [unsignedFlag]
 Read in a binary file with the specified parameters. If bytesPerDataPoint is -sizeof(float), the binary data are treated as float. Other reasonable values would be 1, 2, or 4. Specified parameters do not change those set with the BINARGUMENTS command.
 */

int getbin_c(int n,char* args)
{
    extern char txt[];		     // the file name will be stored here temporarily
    
    int bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point, swap_bytes_flag, unsigned_flag=0;
    int binary_file_is_float = 0;
    
    int narg = sscanf(args,"%s %d %d %d %d %d %d",txt,
                      &bin_rows, &bin_cols, &bin_header, &binary_file_bytes_per_data_point,
                      &swap_bytes_flag, &unsigned_flag);
    if( narg < 6){
        beep();
        printf("Usage: GETBIN <filename> rows columns headerBytes bytesPerDataPoint swapBytesFlag [unsignedFlag]\n");
        return CMND_ERR;
    }
    if(binary_file_bytes_per_data_point == -sizeof(float)) {
        binary_file_bytes_per_data_point = sizeof(float);
        binary_file_is_float = 1;
    }
    Image newImage;
    int error = readBinary(fullname(txt,GET_DATA),&newImage,bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point, swap_bytes_flag, unsigned_flag);
    if(error)return error;
    iBuffer.free();     // release the old data
    iBuffer = newImage;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

/*
 BINARGUMENTS rows columns headerBytes bytesPerDataPoint swapBytesFlag [unsignedFlag]
 Specify parameters for reading in binary files. If bytesPerDataPoint is -sizeof(float), the binary data are treated as float. Other reasonable values would be 1, 2, or 4. The extension for binary files is specified using the BINEXTENSION command. Once these are specified, binary files can be read in using the GET command, or by dropping them onto the status window.
 */

int binarguments_c(int n,char* args)
{
    
    extern int bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point, swap_bytes_flag, unsigned_flag;
    extern char binaryExtension[];
    
    if( args[0] != 0){
        sscanf(args,"%d %d %d %d %d %d",
               &bin_rows, &bin_cols, &bin_header, &binary_file_bytes_per_data_point,
               &swap_bytes_flag, &unsigned_flag);
    }
    printf("Settings for reading binary files with extension %s are:\n%d rows\n%d comumns\n%d header bytes\n%d bytes per point\n",
           binaryExtension,bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point);
    printf("%d swap bytes flag\n%d unsigned flag\n",swap_bytes_flag, unsigned_flag);
    
    return NO_ERR;
}

/* ********** */

/*
 BINEXTENSION fileExtension
 Specify the extension for binary files. Together with the BINARGUMENTS command, this allows binary files to be read with GET or dropped onto the status window.
 */

int binextension_c(int n,char* args)
{
    
    extern int bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point, swap_bytes_flag, unsigned_flag;
    extern char binaryExtension[];
    extern FileDecoderExtensions fileDecoderExtensions[];
    
    if(args[0] == '.'){
        beep();
        printf("Please omit the leading '.'\n");
        return CMND_ERR;
    }
    
    for(int i=0; i<strlen(args); i++){
         args[i] = toupper(args[i]);
     }
    
    if( args[0] != 0){
        sscanf(args,"%s",binaryExtension);
    }
    
    int extLength = (int)strlen(args);

    
    strncpy(&fileDecoderExtensions[RAW_FILE_EXT_INDEX].ext[1],args,extLength);
    
    printf("Settings for reading binary files with extension %s are:\n%d rows\n%d comumns\n%d header bytes\n%d bytes per point\n",
           binaryExtension,bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point);
    printf("%d swap bytes flag\n%d unsigned flag\n",swap_bytes_flag, unsigned_flag);
    
    return NO_ERR;
}

/* ********** */

int addfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer+new_im);
        iBuffer.getmaxx(PRINT_RESULT);
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

/* ********** */

int mulfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer*new_im);
        iBuffer.getmaxx(PRINT_RESULT);
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    beep();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

/* ********** */

int subfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer-new_im);
        iBuffer.getmaxx(PRINT_RESULT);
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    beep();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

/* ********** */

int divfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer/new_im);
        iBuffer.getmaxx(PRINT_RESULT);
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    beep();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

/* ********** */

int compositefile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    iBuffer.composite(new_im);
    if(iBuffer.err()){
        new_im.free();
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    new_im.free();
    update_UI();
    return NO_ERR;
}

/* ********** */

int croprectangle_c(int n,char* args){
    rect crop_rect = UIData.iRect;
    iBuffer.crop(crop_rect);
    int err = iBuffer.err();
    if(err == SIZE_ERR){
        beep();
        printf("Rectangle size error.\n");
        iBuffer.errclear();
        return err;
    }else if (err){
        iBuffer.errclear();
        return err;
    }
    
    int x0 = crop_rect.ul.h;
    int y0 = crop_rect.ul.v;
    int sizx = crop_rect.lr.h - crop_rect.ul.h +1;
    int sizy = crop_rect.lr.v - crop_rect.ul.v +1;
    printf("%d x %d Image.\n",sizx,sizy);
    printf("Current image starts at: %d\t%d\n",x0,y0);
    
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ***************** */

/* Put a "frame" around the current image -- making it a new size
 
 FRAME NewWidth NewHeight [Value] [X0] [Y0]
 
 default Value is 0
 default of x0 and y0 center the old image in the frame
 
 */

int frame_c(int n, char* args)
{
    int sizx,sizy,j,i,fraction=0;
    float x0,y0;
    
    DATAWORD value = 0;
    i = sscanf(args,"%d %d %f %f %f",&sizx,&sizy,&value,&x0,&y0);
    if( i < 2) {
        beep();
        printf("Arguments are: NewWidth NewHeight [Value] [X0] [Y0]\n");
        return(CMND_ERR);
    }
    
    int* specs = iBuffer.getspecs();
    int oldWidth = specs[COLS];
    int oldHeight = specs[ROWS];
    int nColors = 1+iBuffer.isColor()*2;
    int height = oldHeight/nColors;

    switch(i) {
        case 2:
        case 3:
            x0 = -(sizx - (float)oldWidth)/2.;
        case 4:
            y0 = -(sizy - (float)height)/2.;
    }

    Image im;
    // error check?
    im.copyABD(iBuffer);
    specs[ROWS] = sizy*nColors;
    specs[COLS] = sizx;
    im.setspecs(specs); // this will allocate the memory
    
    i = x0;
    j = y0;
    if( x0-i != 0.0 || y0-j != 0.0)fraction=1;
    
    printf("%d x %d Image.\n",sizx,sizy);
    if(fraction)
        printf("Interpolation from current image starts at: %.2f\t%.2f\n",x0,y0);
    else
        printf("Current image starts at: %.0f\t%.0f\n",x0,y0);
    printf("Frame Value: %g\n",value);
    
    for(int c=0; c<nColors; c++){
        for(i=0; i<sizy; i++){
            for(j=0; j<sizx; j++) {
                if(i+y0<0 || i+y0 >=oldHeight ||
                   j+x0<0 || j+x0 >=oldWidth) {
                    im.setpix(i+c*sizy,j,value);
                }else {
                    if(fraction)
                        im.setpix(i+c*sizy,j,iBuffer.getpix(i+y0+c*height,j+x0));
                    else
                        im.setpix(i+c*sizy,j,iBuffer.getpix((int)i+y0+c*height,(int)j+x0));
                }
            }
        }
    }
    free(specs);  // release specs copy
    iBuffer.free();     // release the old data
    iBuffer = im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return 0;
    
}

/* ***************** */

/*
 
 FRAMECNTR CenterX HalfWidth [Y0] [Y1] [Value]
 
 Put a "frame" around the current image centered on column CenterX. The new image width will be 2*HalfWidth+1. Y0 and Y1 specify where the top and bottom of the new image start. Their default values are 0 and originalImageHeight-1. If the new image is larger than the original image, data values are set to Value (default is 0).
 
 */

int framecntr_c(int n, char* args)
{
    int i,halfWidth,centerX;
    int y0=0, y1=iBuffer.height()-1;
    DATAWORD value = 0;
    i = sscanf(args,"%d %d %d %d %f",&centerX,&halfWidth,&y0,&y1,&value);
    if( i < 2) {
        beep();
        printf("Arguments are: CenterX HalfWidth [Y0] [Y1] [Value]\n");
        return(CMND_ERR);
    }
    
    char cmnd[128];
    sprintf(cmnd,"%d %d %f %d %d",2*halfWidth+1,y1-y0,value,centerX-halfWidth,y0);

    return frame_c(0,cmnd);
}

/* ********** */

int resize_c(int n,char* args){
    int newRows,newCols;
    int narg = sscanf(args,"%d %d",&newRows,&newCols);
    if (narg == 1) {
        newCols = newRows;
    }
    if (newRows < 10) newRows = 10;
    if (newCols < 10) newCols = 10;
    
    iBuffer.resize(newRows, newCols);
    if(iBuffer.err()){
        beep();
        printf("Could not resize.\n");
        iBuffer.errclear();
        return iBuffer.err();
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rectan_c(int n, char* args)
{
    int narg;
    point start,end;
    rect new_rect;
    extern Variable user_variables[];
    // For this need 4 arguments
    narg = sscanf(args,"%d %d %d %d",&new_rect.ul.h,&new_rect.ul.v,&new_rect.lr.h,&new_rect.lr.v);
    
    if(*args == 0){
        
        printf("Current Rectangle is %d %d %d %d.\n",
               UIData.iRect.ul.h,UIData.iRect.ul.v,UIData.iRect.lr.h,UIData.iRect.lr.v);
        
        user_variables[0].ivalue = UIData.iRect.ul.h;
        user_variables[0].is_float = 0;
        user_variables[1].ivalue = UIData.iRect.ul.v;
        user_variables[1].is_float = 0;
        user_variables[2].ivalue = UIData.iRect.lr.h;
        user_variables[2].is_float = 0;
        user_variables[3].ivalue = UIData.iRect.lr.v;
        user_variables[3].is_float = 0;
        update_UI();
        return NO_ERR;
    }
    
    if(narg != 4) {
        beep();
        printf("Need 4 Arguments.\n");
        return -1;
    }
    UIData.iRect = new_rect;
    start = UIData.iRect.ul;
    end = UIData.iRect.lr;
    // remove restriction on the way a rectangle is defined
    // previously, the assumption was that all rectangles were defined from the upper left to lower right
    if(end.h < start.h){
        UIData.iRect.lr.h = start.h;
        UIData.iRect.ul.h = end.h;
    }
    if(end.v < start.v){
        UIData.iRect.lr.v = start.v;
        UIData.iRect.ul.v = end.v;
    }
    
    printf("Current Rectangle is %d %d %d %d.\n",
           UIData.iRect.ul.h,UIData.iRect.ul.v,UIData.iRect.lr.h,UIData.iRect.lr.v);
    
    user_variables[0].ivalue = UIData.iRect.ul.h;
    user_variables[0].is_float = 0;
    user_variables[1].ivalue = UIData.iRect.ul.v;
    user_variables[1].is_float = 0;
    user_variables[2].ivalue = UIData.iRect.lr.h;
    user_variables[2].is_float = 0;
    user_variables[3].ivalue = UIData.iRect.lr.v;
    user_variables[3].is_float = 0;
    
    update_UI();
    return NO_ERR;
}

/* ********** */

int list_c(int n, char* args){
    
    int lc,i;
    
    lc = 1;
    i = 0;
    char* comment = iBuffer.getComment();
    int* specs = iBuffer.getspecs();
    DATAWORD* values = iBuffer.getvalues();
    if(comment){
        while (comment[i]) {
            printf( "Line #%d: ",lc++);
            printf( "%s\n",&comment[i]);
            while (comment[i]) {
                i++;
            }
            i++;
        }
        free(comment);
    }
    printf("\n");
    printf(" %7d  Data Points\n",specs[ROWS]*specs[COLS]);
    printf(" %7d  Columns (Channels)\n",specs[COLS]);
    printf(" %7d  Rows (Tracks)\n",specs[ROWS]);
    printf(" %7d  X0\n",specs[X0]);
    printf(" %7d  Y0\n",specs[Y0]);
    printf(" %7d  Delta X\n",specs[DX]);
    printf(" %7d  Delta Y\n",specs[DY]);
    printf(" %g  Exposure \n",values[EXPOSURE]);
    /*
     #ifdef FLOAT
     printf(" %g  Color Minimum\n %g  Color Maximum\n",cmin,cmax);
     #else
     printf(" %7d  Color Minimum\n %7d  Color Maximum\n",cmin,cmax);
     #endif
     */
    /*	printf(" File Prefix: '%s'\n",prefixbuf); */
    /*	printf(" File Suffix: '%s'\n",suffixbuf); */
    /*	printf("\nDisplay Type  : dt  = %d\n",disp_dflag);
     pprintf("Max height of any pixel in a row : dhi = %d\n",disp_height);
     pprintf("3D grid resolution : ddx = %d ddy = %d ddz = %d\n",
     disp_dx,disp_dy,disp_dz);
     pprintf("Display origin: orgx= %d orgy = %d\n",disp_x0,disp_y0);
     
     if (passflag)
     pprintf("\nUnknown Commands Passed to Camera Controller.\n");
     else
     pprintf("\nUnknown Commands Flagged.\n");  */
    free(specs);
    free(values);
    return NO_ERR;
    
    
    
}

/* ********** */

int invert_c(int n,char* args){
    iBuffer.invert();
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int mirror_c(int n,char* args){
    iBuffer.mirror();
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rgb2red_c(int n,char* args){
    iBuffer.rgb2color(0);
    if(iBuffer.err()){
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rgb2green_c(int n,char* args){
    iBuffer.rgb2color(1);
    if(iBuffer.err()){
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rgb2blue_c(int n,char* args){
    iBuffer.rgb2color(2);
    if(iBuffer.err()){
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rgb2grey_c(int n,char* args){
    Image imGreen,imBlue;
    imGreen << iBuffer;
    imBlue << iBuffer;
    iBuffer.rgb2color(0);
    imGreen.rgb2color(1);
    imBlue.rgb2color(2);
    iBuffer + imGreen;
    iBuffer + imBlue;
    if(iBuffer.err()){
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

/*
 RGB2COLOR colorNumber
 Get the red, green, or blue channel of the current color image for colorNumber = 1, 2, or 3.
 */

int rgb2color_c(int n,char* args){
    if(n < 1 || n > 3){
        beep();
        printf("Color numbers must be 1=red, 2=green, or 3=blue.\n");
        return CMND_ERR;
    }
    iBuffer.rgb2color(n-1);
    if(iBuffer.err()){
        int err = iBuffer.err();
        beep();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}


/* ********** */

int colorflag_c(int n, char* args){
    int flag;
    int* specs= iBuffer.getspecs();
    
    if (*args) {
        sscanf(args, "%d",&flag);
        if (flag)
            specs[IS_COLOR]= 1;
        else
            specs[IS_COLOR]= 0;
        iBuffer.setspecs(specs);
    }
    printf("Image Color Flag is %d\n", specs[IS_COLOR]);
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

int rotate_c(int n,char* args){
    float angle;
    int* specs= iBuffer.getspecs();
    sscanf(args,"%f",&angle);
    if(*args == 0) angle = 90.;
    if (!specs[IS_COLOR]) {
        iBuffer.rotate(angle);
        if(iBuffer.err()){
            int err = iBuffer.err();
            beep();
            printf("Error: %d.\n",err);
            iBuffer.errclear();
            free(specs);
            return err;
        }
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else{
        Image color[3];
        int c;
        for(c=0; c<3; c++){
            color[c]<< iBuffer;
            color[c].rgb2color(c);
            color[c].rotate(angle);
        }
        iBuffer.free();
        iBuffer=color[0];
        for(c=1; c<3; c++){
            iBuffer.composite(color[c]);
            color[c].free();
        }
        free(specs);                 // free the old specs array
        specs = iBuffer.getspecs();  // get the new specs
        specs[IS_COLOR] = 1;        // reset the color flag
        iBuffer.setspecs(specs);
        free(specs);
        if(iBuffer.err()){
            int err = iBuffer.err();
            beep();
            printf("Error: %d.\n",err);
            iBuffer.errclear();
            return err;
        }
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    }
}

/* ********** */

int smooth_c(int n,char* args){
    int dx,dy,i,j,nt,nc,count,dxs,dys;
    float sum;
    int* bufferspecs;
    
    // get args
    int narg = sscanf(args,"%d %d",&dx,&dy);
    if(narg == 0){
        dx = dy = 2;    // default 2x2 smooth
    } else if (narg==1){
        dy = dx;        // one argument, smooth same in x and y
    }
    
    bufferspecs = iBuffer.getspecs();
    Image smoothed(bufferspecs[ROWS],bufferspecs[COLS]);
    smoothed.copyABD(iBuffer);
    
    
    if(smoothed.err()){
        free(bufferspecs);
        return smoothed.err();
    }
    
    dxs = -dx/2;
    dys = -dy/2;
    if( dx & 0x1)
        dx = dx/2+1;
    else
        dx /= 2;
    if( dy & 0x1)
        dy = dy/2+1;
    else
        dy /= 2;
    
    for(nt=0; nt<bufferspecs[ROWS]; nt++) {
        for(nc=0; nc<bufferspecs[COLS];nc++){
            sum = 0;
            count = 0;
            for(i=dxs; i<dx; i++) {
                for(j=dys; j<dy; j++) {
                    if( (nt+j) < bufferspecs[ROWS] &&
                       (nc+i) < bufferspecs[COLS] &&
                       (nt+j) >= 0 && (nc+i) >= 0) {
                        count++;
                        sum += iBuffer.getpix(nt+j,nc+i);
                    }
                }
            }
            smoothed.setpix(nt, nc, sum/count);
        }
    }
    free(bufferspecs);  // release specs copy
    iBuffer.free();     // release the old data
    iBuffer = smoothed;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int gsmooth_c(int n, char* args)
//  Gaussian Smoothing of the Data
// GSMOOT NX [NY]
// 1/e2 weight at  = (NX-1)/2 pixels from center
{
    
    int dx,dy,dxs,dys,i,j,m,nt,nc;
    float sigx,sigy,*mask,norm,sum;
    
    mask = 0;
    
    if(n <= 0) n = 3;
    
    dx = dy = n;	// the smoothing amounts
    
    // get args
    int narg = sscanf(args,"%d %d",&dx,&dy);
    if(narg == 0){
        dx = dy = 3;    // default 3 x 3
    } else if (narg==1){
        dy = dx;        // one argument, smooth same in x and y
    }
    
    if (dx/2 == dx/2.0) {
        beep();
        printf("The X size of the region must be odd.\n");
        
        return CMND_ERR;
    }
    if (dy/2 == dy/2.0) {
        printf("The Y size of the region must be odd.\n");
        beep();
        return CMND_ERR;
    }
    
    norm = 0;
    dx = (dx-1)/2;
    dxs = -dx;
    sigx = dx/2;
    
    dy = (dy-1)/2;
    dys = -dy;
    sigy = dy/2;
    printf("Sigx=%5.2f, Sigy=%5.2f, ",sigx,sigy);
    printf("pixels=%d x %d\n",dx*2+1,dy*2+1);
    
    if ( sigy == 0 ) sigy = 1;
    if ( sigx == 0 ) sigx = 1;
    
    if(dx == 0 && dy == 0) return NO_ERR;	// The 1 x 1 smoothing case
    
    int* specs = iBuffer.getspecs();
    Image smoothed(specs[ROWS],specs[COLS]);
    
    if(smoothed.err()){
        return smoothed.err();
    }
    smoothed.copyABD(iBuffer);
    
    /* Set loop limit so only have to do "<", not "<=" */
    dx=dx+1;
    dy=dy+1;
    
    mask = (float*) malloc((dx-dxs) * (dy-dys) * sizeof(float));
    norm = 0;
    for(i=dxs; i<dx; i++) {
        for(j=dys; j<dy; j++) {
            m=(j - dys)*(dx - dxs) + (i - dxs);
            mask[m]=exp(-(i*i/(sigx*sigx)+j*j/(sigy*sigy))/2);
            norm += mask[m];
        }
    }
    
    for(nt=0; nt<specs[ROWS]; nt++) {
        for(nc=0; nc<specs[COLS];nc++){
            sum = 0;
            for(i=dxs; i<dx; i++) {
                for(j=dys; j<dy; j++) {
                    m = (j - dys)*(dx - dxs) + (i - dxs);
                    sum += iBuffer.getpix(nt+j,nc+i)*mask[m];
                }
            }
            smoothed.setpix(nt,nc,sum/norm);
        }
    }
    if(mask!=0) {free(mask); mask = 0;}
    free(specs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = smoothed;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

//***************************************************************//
//**    TSMOOTH - Smooth radius based on x_dim = Temp[0], y_dim = Temp[1]   *//
//***************************************************************//
int tsmooth_c(int n, char* args)
{
    Image Im_Result;
    Image Im_dimX;
    Image Im_dimY;
    
    int nc, nt;
    int i,j,count;
    float sum;
    int dx, dy, dxs, dys;
    char arg[2]="0";
    
    // Allocate space for the result Image
    
    int* specs = iBuffer.getspecs();
    Image smoothed(specs[ROWS],specs[COLS]);
    
    if(smoothed.err()){
        return smoothed.err();
    }
    smoothed.copyABD(iBuffer);
    
    if (temp_image_index(arg, 0) != 0) {
        beep();
        printf("Temp[0] is not defined.\n");
        return CMND_ERR;
    }
    arg[0] = '1';
    if (temp_image_index(arg, 0) != 1) {
        beep();
        printf("Temp[1] is not defined.\n");
        return CMND_ERR;
    }
    
    // Check everything for appropraite sizes
    if ((iBuffer != iTempImages[0])||(iBuffer != iTempImages[1])) {
        beep();
        printf("Please make sure that the Temporary buffers T[0] and T[1] are the same size as the image.\n");
        return CMND_ERR;
    }
    
    // Loop through Original image and do appropriate smoothing
    for(nt=0; nt<specs[ROWS]; nt++) {
        for(nc=0; nc<specs[COLS];nc++){
            // set counters to zero for new pixel
            sum = 0;
            count = 0;
            
            // Work out local smoothing size by reading from Temp buffers
            dx = floor(iTempImages[0].getpix(nt,nc));
            dy = floor(iTempImages[1].getpix(nt,nc));
            dxs = -dx/2;
            dys = -dy/2;
            if( dx & 0x1)   dx = dx/2+1;
            else		dx /= 2;
            if( dy & 0x1)	dy = dy/2+1;
            else		dy /= 2;
            
            // Calculate local average (unweighted rectangular smoothing)
            for(i=dxs; i<dx; i++) {
                for(j=dys; j<dy; j++) {
                    count++;
                    sum += iBuffer.getpix(nt+j,nc+i);
                }
            }
            smoothed.setpix(nt,nc, (DATAWORD) sum/count);
        }
    }
    // Free up memory and GO
    free(specs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = smoothed;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int diffy_c(int n,char* args )				/* differentiate the data in the y direction  -- central difference */
{
    int* bufferspecs = iBuffer.getspecs();
    Image newIm(bufferspecs[ROWS],bufferspecs[COLS]);
    int nc,nt;
    
    if(newIm.err()){
        return newIm.err();
    }
    newIm.copyABD(iBuffer);
    
    for(nc=0;nc < bufferspecs[COLS]; nc++){
        newIm.setpix(0, nc,iBuffer.getpix(0,nc) - iBuffer.getpix(1,nc));
    }
    
    
    for(nt=1; nt<bufferspecs[ROWS]-1;nt++) {
        for(nc=0;nc < bufferspecs[COLS]; nc++){
            newIm.setpix(nt, nc,(iBuffer.getpix(nt-1,nc) - iBuffer.getpix(nt+1,nc))/2.);
        }
    }
    
    for(nc=0;nc < bufferspecs[COLS]; nc++){
        //*(datp2++) = iBuffer.getpix(bufferspecs[ROWS]-2,nc) - idat(bufferspecs[ROWS]-1,nc);
        newIm.setpix(bufferspecs[ROWS]-1, nc,iBuffer.getpix(bufferspecs[ROWS]-2,nc) - iBuffer.getpix(bufferspecs[ROWS]-1,nc));
    }
    free(bufferspecs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int diffx_c(int n,char* args)				/* differentiate the data in the x direction  -- central difference */
{
    int* bufferspecs = iBuffer.getspecs();
    Image newIm(bufferspecs[ROWS],bufferspecs[COLS]);
    int nc,nt;
    
    if(newIm.err()){
        return newIm.err();
    }
    newIm.copyABD(iBuffer);
    
    for(nt=0; nt<bufferspecs[ROWS];nt++) {
        newIm.setpix(nt, 0,iBuffer.getpix(nt,1) - iBuffer.getpix(nt,0));
        for(nc=1;nc < bufferspecs[COLS]-1; nc++){
            newIm.setpix(nt, nc,(iBuffer.getpix(nt,nc+1) - iBuffer.getpix(nt,nc-1))/2.);
        }
        //*(datp2++) = idat(nt, bufferspecs[COLS]-1) - idat(nt, bufferspecs[COLS]-2);
        newIm.setpix(nt, bufferspecs[COLS]-1,iBuffer.getpix(nt, bufferspecs[COLS]-1) - iBuffer.getpix(nt, bufferspecs[COLS]-2));
    }
    free(bufferspecs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int gradient_c(int n,char* args)				/* get the 2D (x & y) gradient magnitude */
/* GRAD command -- uses points on either side of the
 current point for gradient */
{
    int* specs = iBuffer.getspecs();
    Image newIm(specs[ROWS],specs[COLS]);
    int nc,nt;
    float dx,dy;
    
    if(newIm.err()){
        return newIm.err();
    }
    newIm.copyABD(iBuffer);
    
    for(nc=0;nc < specs[COLS]; nc++){
        //*(datp2++) = 0;
        newIm.setpix(0,nc,0);
    }
    
    for(nt=1; nt<specs[ROWS]-1;nt++) {
        //*(datp2++) = 0;
        newIm.setpix(nt,0,0);
        for(nc=1;nc < specs[COLS]-1; nc++){
            dx = (iBuffer.getpix(nt,nc+1) - iBuffer.getpix(nt,nc-1))/2.0;
            dy = (iBuffer.getpix(nt+1,nc) - iBuffer.getpix(nt-1,nc))/2.0;
            newIm.setpix(nt,nc,sqrt(dx*dx +dy*dy));
        }
        //*(datp2++) = 0;
        newIm.setpix(nt,0,0);
    }
    for(nc=0;nc < specs[COLS]; nc++){
        //*(datp2++) = 0;
        newIm.setpix(specs[ROWS]-1,nc,0);
    }
    free(specs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int size_c(int n,char* args){
    int width, height;
    if(*args){
        int narg = sscanf(args,"%d %d",&height,&width);     // rows and columns
        if (narg == 2){
            Image new_im(height,width);
            if(new_im.err()){
                beep();
                printf("Could not create image.\n",args);
                return new_im.err();
            }
            iBuffer.free();     // release the old data
            iBuffer = new_im;   // this is the new data
            iBuffer.getmaxx(PRINT_RESULT);
            update_UI();
            return NO_ERR;
        }
    }
    int* specs = iBuffer.getspecs();
    printf("Current Image is %d by %d\n",specs[COLS],specs[ROWS]);
    free(specs);
    return NO_ERR;
    
}

/* ********** */

int rows_c(int n,char* args){
    int* specs = iBuffer.getspecs();
    if(n > 0){
        Image new_im(n,specs[COLS]);
        if(new_im.err()){
            beep();
            printf("Could not create image.\n");
            return new_im.err();
        }
        iBuffer.free();     // release the old data
        iBuffer = new_im;   // this is the new data
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        free(specs);
        return NO_ERR;
    }
    printf("Current Image is %d by %d\n",specs[COLS],specs[ROWS]);
    free(specs);
    return NO_ERR;
}

/* ********** */

int columns_c(int n,char* args){
    int* specs = iBuffer.getspecs();
    if(n > 0){
        Image new_im(specs[ROWS],n);
        if(new_im.err()){
            beep();
            printf("Could not create image.\n");
            return new_im.err();
        }
        iBuffer.free();     // release the old data
        iBuffer = new_im;   // this is the new data
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        free(specs);
        return NO_ERR;
    }
    printf("Current Image is %d by %d\n",specs[COLS],specs[ROWS]);
    free(specs);
    return NO_ERR;
}

/* ********** */


int setcminmax_c(int n,char* args)		/* get color min and max */
{
    DATAWORD mn = 1, mx;
    
    if(*args){
        int narg = sscanf(args,"%f %f",&mn,&mx);
        if (narg == 2){
            UIData.cmin = mn;
            UIData.cmax = mx;
            UIData.autoscale = 0;
        } else
            UIData.autoscale = 1;
    } else
        UIData.autoscale = 1;
    update_UI();
    return 0;
}

int palette_c(int n,char* args){
    if(n>= 0 && n<NUMPAL){
        UIData.thepalette = n;
    }else {
        UIData.thepalette = DEFAULTMAP;
    }
    update_UI();
    return 0;
}

/* ********** */

int killBox_c(int n, char* args)
{
    point substart,subend;
    int i,j;
    int* bufferspecs = iBuffer.getspecs();
    DATAWORD filval = 0.;
    
    sscanf(args,"%f",&filval);
    
    substart = UIData.iRect.ul;
    subend = UIData.iRect.lr;
    
    if (subend.h > bufferspecs[COLS]-1 ||
        subend.v > bufferspecs[ROWS]-1 ||
        substart.h < 0 ||
        substart.v < 0){
        free(bufferspecs);
        beep();
        printf("Rectangle not contained in current image.\n");
        return SIZE_ERR;
    }
    
    for(i=substart.v; i<= subend.v; i++) {
        for(j=substart.h; j<= subend.h; j++) {
            iBuffer.setpix(i, j, filval);
        }
    }
    free(bufferspecs);
    
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int positive_c(int n, char* args)
{
    iBuffer.floor(0.);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int absolute_c(int n, char* args)
{
    iBuffer.abs();
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ********** */

int clip_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    
    iBuffer.clip(clipval);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}

/* ********** */

int clipbottom_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    
    iBuffer.floor(clipval);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}

/* ********** */

int clipfraction_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    DATAWORD* values = iBuffer.getvalues();
    
    iBuffer.clip(clipval*values[MAX]);
    
    free(values);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}

/* ********** */

int clipfbottom_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    DATAWORD* values = iBuffer.getvalues();
    
    iBuffer.floor(clipval*values[MAX]);
    
    free(values);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}
/* ********** */

/* BOUNDBOX targetValue [setRectFlag]
    Returns the bounds of a rectangle that encloses any part of the image that has a value >= targetValue. If setRectFlag is nonzero, the current rectangle will be set by the results. command_return 1-4 are set to the bounds.
 */

int boundbox_c(int n, char* args)
{
    point substart={iBuffer.width(),iBuffer.height()},subend={0,0};
    DATAWORD clipval = n;
    int setRect=0;
    extern Variable user_variables[];
    
    sscanf(args,"%f %d",&clipval,&setRect);
    
    
    for(int r=0; r<iBuffer.height();r++) {
        for(int c=0; c<iBuffer.width(); c++) {
            if( iBuffer.getpix(r,c) >= clipval){
                if(c < substart.h ) substart.h = c;
                if(c > subend.h ) subend.h = c;
                if(r < substart.v ) substart.v = r;
                if(r > subend.v ) subend.v = r;
            };
        }
    }

    printf("Bounding rectangle is %d %d %d %d\n",substart.h,substart.v,subend.h,subend.v);
    user_variables[0].ivalue = substart.h;
    user_variables[0].is_float = 0;
    user_variables[1].ivalue = substart.v;
    user_variables[1].is_float = 0;
    user_variables[2].ivalue = subend.h;
    user_variables[2].is_float = 0;
    user_variables[3].ivalue = subend.v;
    user_variables[3].is_float = 0;

    if (setRect){
        UIData.iRect.ul=substart;
        UIData.iRect.lr=subend;
    }
    return NO_ERR;
}

/* ********** */

int calc_cmd_c(int n, char* args)
{
    point substart,subend;
    int* bufferspecs = iBuffer.getspecs();
    
    substart = UIData.iRect.ul;
    subend = UIData.iRect.lr;
    
    if (subend.h > bufferspecs[COLS]-1 ||
        subend.v > iBuffer.height()-1 ||
        substart.h < 0 ||
        substart.v < 0){
        free(bufferspecs);
        beep();
        printf("Rectangle not contained in current image.\n");
        return SIZE_ERR;
    }
    
    calc(substart,subend);
    free(bufferspecs);
    
    return NO_ERR;
}

/* ********** */

int calcall_c(int n, char* args)
{
    point substart,subend;
    int* bufferspecs = iBuffer.getspecs();
    
    substart.h = substart.v = 0;
    subend.h = bufferspecs[COLS]-1;
    subend.v = bufferspecs[ROWS]-1;
    
    calc(substart,subend);
    free(bufferspecs);
    return 0;
}

int calc(point start,point end){
    
    double xcom,ycom,ave,rms;		// centroid coordinates,average, and rms
    int icount,nt,nc;
    DATAWORD datval;
    DATAWORD* buffervalues = iBuffer.getvalues();
    int* bufferspecs = iBuffer.getspecs();
    char* unit_text = iBuffer.getunit_text();
    extern Variable user_variables[];
    
    for(int c=0; c<= bufferspecs[IS_COLOR]*2; c++){
        icount = 0;
        xcom = ycom = ave = rms = 0.0;
        
        //printf("%d %d %d %d \n", start->v,start->h,end->v,end->h);
        for(nt=start.v; nt<=end.v; nt++) {
            for(nc=start.h; nc<=end.h; nc++) {
                datval = iBuffer.getpix(nt+c*iBuffer.height(),nc);
                ave += datval;					// average
                xcom += nc * (datval-buffervalues[MIN]);			// x center of mass -- subtract min
                ycom += nt * (datval-buffervalues[MIN]);			// y center of mass -- subtract min
                rms += datval*datval;			// rms
                icount++;						// number of points
            }
        }
        xcom /= icount;
        ycom /= icount;
        ave = ave/(float)icount;
        xcom /= (ave-buffervalues[MIN]);
        ycom /= (ave-buffervalues[MIN]);
        
        rms = rms/icount - ave*ave;
        rms = sqrt(rms);
        if( bufferspecs[HAS_RULER] ) {
            xcom /= buffervalues[RULER_SCALE];
            ycom /= buffervalues[RULER_SCALE];
        }
        if(bufferspecs[IS_COLOR]){
            switch (c) {
                case 0:
                    printf("R ");
                    break;
                case 1:
                    printf("G ");
                    break;
                case 2:
                    printf("B ");
                    break;
                default:
                    break;
            }
        }
        pprintf("Ave:\t%g\t rms:\t%g\t # Pts:\t%d\t x:\t%g\t y:\t%g",ave,rms,icount,xcom,ycom);
        
        if( bufferspecs[HAS_RULER]!= 0  && unit_text[0]!=0 ){
            pprintf("\t%s \n",unit_text);
        } else {
            pprintf(" \n");
        }
        switch (c) {
            case 0:
                // return values available as variables monochrome or red
                user_variables[0].fvalue = ave;
                user_variables[0].is_float = 1;
                user_variables[1].fvalue = rms;
                user_variables[1].is_float = 1;
                user_variables[2].fvalue = xcom;
                user_variables[2].is_float = 1;
                user_variables[3].fvalue = ycom;
                user_variables[3].is_float = 1;
                break;
            case 1:
                // return values available as variables green
                user_variables[4].fvalue = ave;
                user_variables[4].is_float = 1;
                user_variables[5].fvalue = rms;
                user_variables[5].is_float = 1;
                user_variables[6].fvalue = xcom;
                user_variables[6].is_float = 1;
                user_variables[7].fvalue = ycom;
                user_variables[7].is_float = 1;
                break;
            case 2:
                // return values available as variables blue
                user_variables[8].fvalue = ave;
                user_variables[8].is_float = 1;
                user_variables[9].fvalue = rms;
                user_variables[9].is_float = 1;
                break;
                
            default:
                break;
        }
        
    }
    free( buffervalues);
    free( bufferspecs);
    free( unit_text);
    update_UI();
    return 0;
    
}

/* ********** */

// return the index of a temporary image
// or return -1 if there was a problem
int temp_image_index (char* args,int define)
{
    int i,j;
    char name[CHPERLN];
    
    sscanf(args,"%s",name); // only get the first string, not anything after a whitespace
    
    // numbered temporary image?
    if(name[0] >= '0' && name[0] <= '9'){   // this is the 0-9 naming case
        // just to be sure, be sure this isn't a number > 9
        sscanf(name, "%d",&i);
        if( i > 9){
            beep();
            printf("Numbered temporary images must be between 0-9\n");
            return -1;
        } else
            return name[0] - '0';
    }
    // valid named temporary?
    if (name[0] >= 'a' && name[0] <='z') {
        // this is a named temporary image
        // check to see if it already exists
        for(i=0; i< numberNamedTempImages; i++){
            for(j=0; j< strlen(name); j++){
                if( *(name+j) != namedTempImages[i].vname[j])
                    break;
            }
            if( j == strlen(name) && j == strlen(namedTempImages[i].vname)){
                // this is already defined
                return NUMBERED_TEMP_IMAGES+i;
            }
        }
        if( i == numberNamedTempImages && define == 1){	// add a new named temp image to the list
            if(numberNamedTempImages >= NUM_TEMP_IMAGES-NUMBERED_TEMP_IMAGES){
                // TOO MANY named temps
                return -1;
            }
            for(j=0; j<= strlen(name); j++)
                namedTempImages[numberNamedTempImages].vname[j] = *(name+j);
            numberNamedTempImages++;
            return NUMBERED_TEMP_IMAGES+numberNamedTempImages-1;
        }
        beep();
        printf("Temporary image %s not defined.\n",name);
        return(-1);
    }
    beep();
    printf("%s is not a valid image name.\n",name);
    return -1;
}


/*
 STEMP name
 Save current image as temporary image with specified name. The name can be 0-9 or
 a text string beginning with a lower case letter. This can be retrieved with GTEMP.
 */
int stemp_c(int n, char* args)
{
    n = temp_image_index(args,1);
    if(n >=0){
        iTempImages[n] << iBuffer;
        update_UI();
        return NO_ERR;
    } else {
        return MEM_ERR;
    }
}
/* ********** */

int gtemp_c(int n, char* args)
{
    n = temp_image_index(args,0);
    if(n >=0){
        
        if( iTempImages[n].isEmpty()){
            beep();
            printf("Temporary image is not defined.\n");
            return MEM_ERR;
        }
        iBuffer << iTempImages[n];
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

/* ********** */
/*
 FTEMPIMAGE [tempImage]
 Free memory associated with temporary image tempImage. If no argument is specified, all temporary images are freed.
 tempImage must be in the range 0-9, or correspond to a named image.
 */
int ftemp_c(int n, char* args)
{
    if(args[0]){
        n = temp_image_index(args,0);
        if(n >=0){
            iTempImages[n].free();
            if (n >= NUMBERED_TEMP_IMAGES) { // this one was named
                namedTempImages[n-NUMBERED_TEMP_IMAGES].vname[0] = 0;    // get rid of this name
                numberNamedTempImages--;
                for(int i=n-NUMBERED_TEMP_IMAGES; i < numberNamedTempImages; i++){
                    namedTempImages[i] = namedTempImages[i+1];
                    iTempImages[i+NUMBERED_TEMP_IMAGES] = iTempImages[i+NUMBERED_TEMP_IMAGES+1];
                }
            }
            update_UI();
            return NO_ERR;
        }
        return MEM_ERR;
    } else {
        // clear all images
        for(int i=0; i<numberNamedTempImages+NUMBERED_TEMP_IMAGES; i++){
            iTempImages[i].free();
        }
        numberNamedTempImages = 0;
        update_UI();
        return NO_ERR;
        
    }
}

/* ********** */
/*
 LTEMP
 list defined temporary images.
 */
int ltemp_c(int n, char* args)
{
    int i,ncolors;
    for (n=0; n<NUMBERED_TEMP_IMAGES; n++) {
        if(!iTempImages[n].isEmpty()){
            if(iTempImages[n].isColor())
                ncolors=3;
            else
                ncolors=1;
            printf("Temp Image %d: %d x %d x %d\n",n,
                   iTempImages[n].width(),iTempImages[n].height(),ncolors);
        }
    }
    for (i = 0; i<numberNamedTempImages; i++) {
        n = i+NUMBERED_TEMP_IMAGES;
        if(iTempImages[n].isColor())
            ncolors=3;
        else
            ncolors=1;
        printf("Temp Image %s: %d x %d x %d\n",namedTempImages[i].vname,
               iTempImages[n].width(),iTempImages[n].height(),ncolors);
    }
    
    return 0;
}
/* ********** */

int addtmp_c(int n, char* args)
{
    n = temp_image_index(args,0);
    if(n >=0){
        if (iBuffer != iTempImages[n]) {
            beep();
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer + iTempImages[n];
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}
/* ********** */

int subtmp_c(int n, char* args)
{	
    n = temp_image_index(args,0);
    if(n >=0){
        if (iBuffer != iTempImages[n]) {
            beep();
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer - iTempImages[n];
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

/* ********** */

int multmp_c(int n, char* args)
{
    n = temp_image_index(args,0);
    if(n >=0){
        if (iBuffer != iTempImages[n]) {
            beep();
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer * iTempImages[n];
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

/* ********** */

int divtmp_c(int n, char* args)
{
    n = temp_image_index(args,0);
    if(n >=0){
        if (iBuffer != iTempImages[n]) {
            beep();
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer / iTempImages[n];
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}


/* ********** */

int comtmp_c(int n, char* args)
{
    n = temp_image_index(args,0);
    if(n >=0){
        if (iBuffer.width() != iTempImages[n].width()) {
            beep();
            printf("Images are not the same width.\n");
            return SIZE_ERR;
        }
        iBuffer.composite(iTempImages[n]);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

/* ********** */

int sinGrid_c(int n, char* args)				/* draw grid from sin function */
{
    int nc,nt;
    float radius,dist,x,y;
    
    if( sscanf(args,"%f",&radius) != 1)
        radius = n;
    if (radius < 10.) {
        radius = 10.;
    }
    int* theSpecs = iBuffer.getspecs();
    
    printf("radius = %f\n",radius);
    //if (radius <= 0 || radius > header[NCHAN] || radius > header[NTRAK]) radius = 20.0;
    
    for(nt=0; nt<theSpecs[ROWS];nt++) {
        for(nc=0;nc < theSpecs[COLS]; nc++){
            x = radius - fmod(nc,radius*2);
            y = radius - fmod(nt,radius*2);
            dist = sqrt(y*y + x*x);
            iBuffer.setpix(nt, nc, cos(dist/(.67*radius)*PI/2));
        }
    }
    free(theSpecs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

/* ********** */

int dcrawarg_c(int n, char* args){
    
    int next = 0, i;
    static int first = 1;
    extern char txt[];
    extern int argc;
    extern char *argv[];
    extern char dcraw_arg[];
    
    
    if(*args == 0){
        i = argc;
        argc = 1;
        dcrawGlue(txt,-1,NULL);
        argc = i;
        printf("\nCurrent settings are: ");
        for(i=0; i<argc; i++){
            printf("%s ",argv[i]);
        }
        printf("\n");
        return NO_ERR;
    }
    
    argc = 0;
    strcpy(dcraw_arg, args);
    argv[argc++] = &dcraw_arg[next];
    for(i=0; i<strlen(args); i++){
        if(args[i] == ' '){
            dcraw_arg[i] = 0;
            next = i+1;
            argv[argc++] = &dcraw_arg[next];
        }
    }
    
    if(!first){
        printf("%d arguments:\n",argc);
        printf("DCRAW arguments are: %s\n",args);
        
    }
    
    
    return NO_ERR;
}

/* ********** */

int newWindow_c(int n,char* args){
    //extern int newWindowFlag;
    if(n)
        UIData.newwindowflag = 1;
    else
        UIData.newwindowflag =0;
    return NO_ERR;
    
}
/* ********** */

/*
 GETFILENAMES NameFile
 Open NameFile (uses GET DATA FILES prefix and ".txt" as suffix), which contains the names of files. The NEXTFILE command is used to open the next file. NameFile is left open until all files have been accessed. Namefile can be generated with a SHELL command. See also NEXTTFILE command.
 */

int getFileNames_c(int n,char* args)			// open a file containing file names
{
    extern FILE* nameFilePtr;
    
    if( nameFilePtr != NULL) fclose(nameFilePtr);
    
    nameFilePtr = fopen(fullname(args,GET_FILENAMES),"r");
    if( nameFilePtr != NULL) {
        return NO_ERR;
    }
    else {
        beep();
        printf("Could not open %s\n",args);
        return FILE_ERR;
    }
}
/* ********** */

/*
GETFOLDERNAMES FolderFile
 Open FolderFile (uses GET DATA FILES prefix and ".txt" as suffix), which contains the names of folders. The NEXTFOLDER command is used to read the next folder name. FolderFile is left open until all folders have been accessed. FolderFile can be generated with a SHELL command. See also NEXTFOLDER command.
 */

int getFolderNames_c(int n,char* args)            // open a file containing file names
{
    extern FILE* folderFilePtr;
    
    if( folderFilePtr != NULL) fclose(folderFilePtr);
    
    folderFilePtr = fopen(fullname(args,GET_FILENAMES),"r");
    if( folderFilePtr != NULL) {
        return NO_ERR;
    }
    else {
        beep();
        printf("Could not open %s\n",args);
        return FILE_ERR;
    }
}
/* ********** */

/*
 NEXTFILE [prefix]
 Open the next file specified in the NameFile that was opened with the GetFileNames command.
 If a prefix is specified, that is added to the name before trying to open the file.
 command_return_1 is the the filename without any prefix and without the extension (last 4 characters)
 */
int nextFile_c(int n,char* args){
    char 	txt[256];          // read the filename in here initially
    char 	fulltxt[512];
    extern Variable user_variables[];
    extern FILE* nameFilePtr;
    
    if( nameFilePtr == NULL){
        beep();
        printf("No Names file is open. Use the GetFileNames command first.\n");
        return FILE_ERR;
    }
    if(fscanf(nameFilePtr, "%s",txt) == EOF){
        beep();
        printf("All files have been read.\n");
        fclose(nameFilePtr);
        nameFilePtr = NULL;
        return FILE_ERR;
    }
    
    // return the file name without the extension as the first  return value
    
    user_variables[0].fvalue = user_variables[0].ivalue = 0;
    user_variables[0].is_float = -1;
    int length = (int)strlen(txt);
    while(txt[length] != '.' && length > 0) length--;
    strncpy( user_variables[0].estring,txt,length);
    user_variables[0].estring[length] = 0;   // need to end this explicitly
    
    printf("%s\n",user_variables[0].estring);
    
    if(*args)
        strcpy(fulltxt, args);
    else
        fulltxt[0]=0;
    n = (int)strlen(fulltxt);
    
    strcpy(&fulltxt[n], txt);
    printf("%s\n",fulltxt);
    
    Image new_im(fulltxt,LONG_NAME);
    if(new_im.err()){
        beep();
        printf("Could not load %s\n",fulltxt);
        return new_im.err();
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}
/* ********** */

/*
 NEXTFolder
 Read the next entry in the FolderNames file that was opened with the GETFOLDERNAMES command. command_return_1 has the local folder name. Typically this would be saved to a variable (e.g., named "folder") for use in subsequent NEXTFILE commands.
 */
int nextFolder_c(int n,char* args){
    char 	fulltxt[512];
    extern FILE* folderFilePtr;
    extern Variable user_variables[];
    
    if( folderFilePtr == NULL){
        beep();
        printf("No Folder file is open. Use the GetFolderNames command first.\n");
        return FILE_ERR;
    }
    if(fscanf(folderFilePtr, "%s",fulltxt) == EOF){
        beep();
        printf("All paths have been read.\n");
        fclose(folderFilePtr);
        folderFilePtr = NULL;
        return FILE_ERR;
    }
    
    // return the path name  as the first  return value
    
    user_variables[0].fvalue = user_variables[0].ivalue = 0;
    user_variables[0].is_float = -1;
    int length = (int)strlen(fulltxt);
    strncpy( user_variables[0].estring,fulltxt,length);
    user_variables[0].estring[length] = 0;   // need to end this explicitly
    
    printf("New path is %s\n",user_variables[0].estring);

    
    //strncpy(UIData.getprefixbuf, fulltxt,512);
    
    return NO_ERR;
    
}

/* ********** */

int stringmacro_c(int n,char* args)
{
    extern char macstring[];
    
    if (*args == 0) {
        printf("%s\n",macstring);
    } else {
        strncpy(macstring,args,COMLEN);
    }
    return 0;
}

/* ********** */

int delay_c(int n,char* args)
{
    // n is in ticks (1/60 seconds)
    
    clock_t start;
    start = clock();
    while ( (clock()- start)*60/CLOCKS_PER_SEC < n);
    return 0;
}

/* ********** */
/*
 SHELL shell_command
 send a command to a shell
 */
int sysCommand_c(int n,char* args)
{
    FILE*	sf;
    char     txt[256];
    unsigned long i,j;
    //system(&cmnd[index]);
    sf = popen(args,"r");
    i = fread(txt,1,255,sf);
    while( i> 0){
        for(j=0; j< i; j++){
            printf("%c",txt[j]);
        }
        i = fread(txt,1,255,sf);
    }
    
    pclose(sf);
    return(0);
    
}

/* ********** */

int gmacro_c(int n,char* args)
{
    extern char	macbuf[];
    
    int fd,nread,i;
    
    if(*args == 0)
        fd = open(args,READMODE);
    else
        fd = open(fullname(args,MACROS_DATA),READMODE);
    
    if(fd == -1) {
        beep();
        printf("Macro File '%s' Not Found.\n",args);
        return FILE_ERR;
    }
    for(i=0; i<MBUFLEN; i++) *(macbuf+i) = 0;	// clear the buffer
    nread = (int)read(fd,macbuf,MBUFLEN);		/* read the largest buffer  */
    printf("%d Bytes Read.\n",nread);
    
    
    /* the format of macro files has changed -- now they are formatted text files */
    /* previously, they were constant length files containing C strings */
    /* this code should read both formats */
    
    for(i=0; i<nread ; i++) {
        if( *(macbuf+i) == 0x0D || *(macbuf+i) == 0x0A)
            *(macbuf+i) = 0x00;	/* change CR or LF to null */
    }
    *(macbuf+nread) = 0;				/* one extra to signify end of buffer */
    *(macbuf+nread+1) = 0;
    
    close(fd);
    clear_buffer_to_end(macbuf);		/* insert trailing zeros after the macro */
    return NO_ERR;
}
/* ********** */

int echo_c(int n,char* args)
{
    if (*args != 0) {
        pprintf("%s\n",args);
    }
    return NO_ERR;
}


/* ********** */

//********************************************************
//*** FECHO, FOPEN , FCLOSE
//***         P. Kalt (2005)
//********************************************************
FILE 	*fptr_local;
char    *fptr_name;

int fopen_c (int n,char* args)
{
    
    fptr_name = fullname(args,CSV_DATA);
    fptr_local = fopen(fptr_name,"w");
    if( fptr_local != NULL) {
        //settext(args);      /* text file type */
        //fileflush(args]);	/* for updating directory */
        return NO_ERR;
    } else {
        beep();
        printf("Error: Could not open file: %s\n",fptr_name);
        return FILE_ERR;
    }
}

int fclose_c (int n,char* args)
{
    if( fptr_local != NULL) {
        fclose(fptr_local);
    } else {
        beep();
        printf("Error: No file open. File pointer is NULL\n");
        return OMA_FILE;
    }
    
    return NO_ERR;
}

int fecho_c (int n,char* args)
{
    if (*args != 0) {
        if( fptr_local != NULL) {
            if(strncmp(&args[strlen(args)-3],"...",3) == 0){
                args[strlen(args)-3]=0;
                fprintf(fptr_local, "%s",args);
            }else {
                fprintf(fptr_local, "%s\n",args);
            }
        } else {
            beep();
            printf("Error: No file open. File pointer is NULL\n");
            return OMA_FILE;
        }
    }
    return NO_ERR;
}

int saveJpg_c(int n, char* args){
    
    char txt[CHPERLN];
    int saveJpeg(char*);
    if(*args == 0){
        beep();
        printf("Error: Must specify file name.\n");
        return OMA_FILE;
    }
    sscanf(args,"%s",txt);
    fullname(txt,SAVE_DATA_NO_SUFFIX);  // you should add the jpg suffix yourself
    printf("Writing JPG to file: %s\n",txt);
    return saveJpeg(txt);
    
    
}
int savePdf_c(int n, char* args){
    
    char txt[CHPERLN];
    int savePdf(char*);
    if(*args == 0){
        beep();
        printf("Error: Must specify file name.\n");
        return OMA_FILE;
    }
    sscanf(args,"%s",txt);
    fullname(txt,SAVE_DATA_NO_SUFFIX);  // you should add the pdf suffix yourself
    printf("Writing PDF to file: %s\n",txt);
    return savePdf(txt);
    
    
}

//***************************************************
//*** SATIFF - Convert image to 8bit and save as a
//***          Greyscale TIFF file (uses LibTIFF)
//***          P. Kalt (2003) after J.Fielding
//***************************************************
int satiff_c(int n, char* args)
{
#ifdef MacOSX_UI
    uint32 rowsperstrip = (uint32) -1;
    double resolution = -1;
    unsigned char *buf = NULL,*buf2;
    uint32 row, col;
    tsize_t linebytes;
    uint16 spp;
    TIFF *out;
    uint32 w, h;
    
    char txt[CHPERLN];
    
    int* specs = iBuffer.getspecs();
    
    w = specs[COLS];
    h = specs[ROWS];
    spp = 1; // grayscale
    if(specs[IS_COLOR]){
        spp=3;
        h /= 3;
    }
    
    sscanf(args,"%s",txt);
    
    fullname(txt,TIF_DATA);  //if TIFF_DATA is not on your system use GET_DATA
    printf("Writing TIFF to file: %s\n",txt);
    
    out = TIFFOpen(txt, "w");
    if (out == NULL)
        return (-4);
    TIFFSetField(out, TIFFTAG_IMAGEWIDTH,  w);
    TIFFSetField(out, TIFFTAG_IMAGELENGTH, h);
    TIFFSetField(out, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    TIFFSetField(out, TIFFTAG_SAMPLESPERPIXEL, spp);
    TIFFSetField(out, TIFFTAG_BITSPERSAMPLE, 8);
    TIFFSetField(out, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    if(specs[IS_COLOR])
        TIFFSetField(out, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_RGB);
    else
        TIFFSetField(out, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK);
    
    TIFFSetField(out, TIFFTAG_COMPRESSION, COMPRESSION_NONE);
    
    linebytes = spp * w;
    buf = (unsigned char *)_TIFFmalloc(TIFFScanlineSize(out));
    TIFFSetField(out, TIFFTAG_ROWSPERSTRIP,
                 TIFFDefaultStripSize(out, rowsperstrip));
    if (resolution > 0) {
        TIFFSetField(out, TIFFTAG_XRESOLUTION, resolution);
        TIFFSetField(out, TIFFTAG_YRESOLUTION, resolution);
        TIFFSetField(out, TIFFTAG_RESOLUTIONUNIT, RESUNIT_INCH);
    }
    
    bit8_c(0,NULL); // Convert to 8bit greyscale
    
    if (specs[IS_COLOR]) {
        for (row = 0; row < h; row++) {
            buf2 = buf;
            for (col = 0; col < w; col++){
                *buf2++ = (unsigned char) iBuffer.getpix((int)row, (int)col);
                *buf2++ = (unsigned char) iBuffer.getpix((int)(row+1)*h, (int)col);
                *buf2++ = (unsigned char) iBuffer.getpix((int)(row+2)*h, (int)col);
            }
            if (TIFFWriteScanline(out, buf, row, 0) < 0) break;
        }
    } else{
        for (row = 0; row < h; row++) {
            for (col = 0; col < w; col++)
                *(buf+col) = (unsigned char) iBuffer.getpix((int)row, (int)col);
            if (TIFFWriteScanline(out, buf, row, 0) < 0) break;
        }
    }
    (void) TIFFClose(out);
    if (buf)
        _TIFFfree(buf);
    free(specs);
    return NO_ERR;
#endif
#ifndef MacOSX_UI
    return saveTiff(args);
#endif
    
}

//***************************************************
//*** SATIFFSCALED - Convert image to 16bit and save as a
//***          Color or Greyscale TIFF file (uses LibTIFF)
//***         Uses  min and max for scaling
//***************************************************

int satiffscaled_c(int n, char* args)
{
#ifdef MacOSX_UI
    uint32 rowsperstrip = (uint32) -1;
    double resolution = -1;
    unsigned short *buf = NULL,*buf2;
    uint32 row, col;
    tsize_t linebytes;
    uint16 spp;
    TIFF *out;
    uint32 w, h;
    char txt[CHPERLN];
    
    float mymin,mymax;
    int narg = 0;
    
    int* specs = iBuffer.getspecs();
    
    w = specs[COLS];
    h = specs[ROWS];
    spp = 1; // grayscale
    if(specs[IS_COLOR]){
        spp=3;
        h /= 3;
    }
    
    narg = sscanf(args,"%f %f %s",&mymin,&mymax,txt);
    
    if(narg != 3) {
        beep();
        printf("Need 3 arguments: min max filename\n");
        return CMND_ERR;
    }
    if(mymax <= mymin ){
        beep();
        printf("Need Max > Min\n");
        return ARG_ERR;
    }
    
    fullname(txt,TIF_DATA);  //if TIFF_DATA is not on your system use GET_DATA
    printf("Writing TIFF to file: %s\n",txt);
    
    out = TIFFOpen(txt, "w");
    if (out == NULL)
        return (-4);
    TIFFSetField(out, TIFFTAG_IMAGEWIDTH,  w);
    TIFFSetField(out, TIFFTAG_IMAGELENGTH, h);
    TIFFSetField(out, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    TIFFSetField(out, TIFFTAG_SAMPLESPERPIXEL, spp);
    TIFFSetField(out, TIFFTAG_BITSPERSAMPLE, 16);
    TIFFSetField(out, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
    if(specs[IS_COLOR])
        TIFFSetField(out, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_RGB);
    else
        TIFFSetField(out, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK);
    
    TIFFSetField(out, TIFFTAG_COMPRESSION, COMPRESSION_NONE);
    
    linebytes = spp * w;
    buf = (unsigned short *)_TIFFmalloc(TIFFScanlineSize(out));
    TIFFSetField(out, TIFFTAG_ROWSPERSTRIP,
                 TIFFDefaultStripSize(out, rowsperstrip));
    if (resolution > 0) {
        TIFFSetField(out, TIFFTAG_XRESOLUTION, resolution);
        TIFFSetField(out, TIFFTAG_YRESOLUTION, resolution);
        TIFFSetField(out, TIFFTAG_RESOLUTIONUNIT, RESUNIT_INCH);
    }
    
    bit16_c(n,args); // Convert to 16 bit greyscale
    
    if (specs[IS_COLOR]) {
        for (row = 0; row < h; row++) {
            buf2 = buf;
            for (col = 0; col < w; col++){
                *buf2++ = (unsigned short) iBuffer.getpix((int)row, (int)col);
                *buf2++ = (unsigned short) iBuffer.getpix((int)row+h, (int)col);
                *buf2++ = (unsigned short) iBuffer.getpix((int)row+2*h, (int)col);
            }
            if (TIFFWriteScanline(out, buf, row, 0) < 0) break;
        }
    } else{
        for (row = 0; row < h; row++) {
            for (col = 0; col < w; col++)
                *(buf+col) = (unsigned short) iBuffer.getpix((int)row, (int)col);
            if (TIFFWriteScanline(out, buf, row, 0) < 0) break;
        }
    }
    (void) TIFFClose(out);
    if (buf)
        _TIFFfree(buf);
    free(specs);
    return NO_ERR;
#endif
#ifndef MacOSX_UI
    beep();
    printf("Not implemented in QtOMA.\n");
    return CMND_ERR;
#endif
    
}


//***************************************************
//*** 8BIT - reduce bit depth to 8 bits per pixel
//***************************************************
int bit8_c(int n, char* args)
{
    DATAWORD mymax,mymin;
    
    DATAWORD range;
    float fpval;
    int narg = 0;
    int* specs = iBuffer.getspecs();
    
    //datp = datpt+doffset;
    if(args != NULL){
        narg = sscanf(args,"%f %f",&mymin,&mymax);
    }
    if (narg != 2) narg = 0;
    
    if( narg == 0 ) {
        DATAWORD* values = iBuffer.getvalues();
        range = values[MAX] - values[MIN];
        for(int i=0; i<specs[ROWS]; i++){
            for(int j = 0; j<specs[COLS]; j++){
                fpval = (iBuffer.getpix(i,j)-values[MIN]) * 255.0/range;
                iBuffer.setpix(i,j,fpval);
            }
        }
        free(values);
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else {
        range = mymax - mymin;
        for(int i=0; i<specs[ROWS]; i++){
            for(int j = 0; j<specs[COLS]; j++){
                fpval = (iBuffer.getpix(i,j)-mymin) * 255.0/range;
                if (fpval > 255.) fpval = 255;
                if(fpval < 0.) fpval = 0;
                
                iBuffer.setpix(i,j,fpval);
            }
        }
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
        
    }
}

//***************************************************
//*** 16BIT - reduce bit depth to 16 bits per pixel
//***************************************************

int bit16_c(int n, char* args)
{
    DATAWORD mymax,mymin;
    
    DATAWORD range;
    float fpval;
    int narg = 0;
    int* specs = iBuffer.getspecs();
    
    //datp = datpt+doffset;
    if(args != NULL){
        narg = sscanf(args,"%f %f",&mymin,&mymax);
    }
    if (narg != 2) narg = 0;
    
    
    if( narg == 0 ) {
        DATAWORD* values = iBuffer.getvalues();
        range = values[MAX] - values[MIN];
        for(int i=0; i<specs[ROWS]; i++){
            for(int j = 0; j<specs[COLS]; j++){
                fpval = (iBuffer.getpix(i,j)-values[MIN]) * 65535.0/range;
                iBuffer.setpix(i,j,fpval);
            }
        }
        free(values);
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    } else {
        range = mymax - mymin;
        for(int i=0; i<specs[ROWS]; i++){
            for(int j = 0; j<specs[COLS]; j++){
                fpval = (iBuffer.getpix(i,j)-mymin) * 65535.0/range;
                if (fpval > 65535.) fpval = 65535;
                if(fpval < 0.) fpval = 0;
                iBuffer.setpix(i,j,fpval);
            }
        }
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    }
}

/* ********** */

/*
 
 GAUSSIAN EdgeValue [x0 y0]
 Generate a Gaussian distribution centered at x0, y0. If x0, and y0, are not specified, the distribution is centered.
 The maximum is 1. For a centered distribution, EdgeValue specifies the value of the distribution at the center edge.
 */

int gaussian_c(int n,char* args){
    int nc,nt;
    float value,x,y,c2,r2,w,h;
    int narg = sscanf(args,"%f %f %f",&value,&x,&y);
    
    int* theSpecs = iBuffer.getspecs();
    w = theSpecs[COLS]/2;
    h = theSpecs[ROWS]/2;
    switch (narg) {
        case 0:
        case -1:
            value = .5;
            x = w;
            y = h;
            break;
        case 1:
            x = w;
            y = h;
            break;
        case 2:
            y = h;
            break;
            
        default:
            break;
    }
    if(w<h)
        c2 = - h*h/log(value);
    else
        c2 = - w*w/log(value);
    
    for(nt=1; nt<=theSpecs[ROWS];nt++) {
        for(nc=1;nc <= theSpecs[COLS]; nc++){
            r2 = (nc-x)*(nc-x)+(nt-y)*(nt-y);
            iBuffer.setpix(nt-1, nc-1, expf(-r2/c2));
        }
    }
    free(theSpecs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

/*
 
 GREY2RGB [scaleRed scaleGreen scaleBlue]
 Turns a single plane image into a three plane RGB image. The optional weighting factors are applied to each color plane.
 */

int grey2rgb_c(int n,char* args){
    
    float sR = 1.,sG=1.,sB=1.;
    sscanf(args,"%f %f %f",&sR,&sG,&sB);
    Image im;
    im << iBuffer;
    if(sR != 1.) im * sR;
    if(sG != 1.) iBuffer * sG;
    im.composite(iBuffer);
    if(sB != 1.) iBuffer * (sB/sG);
    im.composite(iBuffer);
    int* theSpecs = im.getspecs();
    theSpecs[IS_COLOR] = 1;
    im.setspecs(theSpecs);
    free(theSpecs);
    
    iBuffer.free();     // release the old data
    iBuffer = im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */
/*
 FINDBAD Counts [TargetValue] [Passes]
 
 Searches the current image buffer for pixels whose value is more than "Counts" above that of it's
 nearest eight neighbors. Those pixels are tagged as hot pixels. If the optional TargetValue is specified,
 a different algorithm is used that will get values from 1 to 8 neighboring pixels that are within the specified
 number of counts of the target value. A reasonable Target Value would be the average A/D offset, e.g., from a dark frame.
 As currently implemented, the alternate algorithm is not appropriate for raw images from a color camera.
 
 */

int hot_pix[NUMHOT];	// store info on hot pixels
int neighbors[NUMHOT][8] = {{0}};
int num_hot = 0;
int ccd_width = 0;
int ccd_height = 0;

int findbad_c(int n, char* args){
    int i,j,target=0,passes = 1;
    DATAWORD ave_val;
    num_hot = 0;
    int* specs = iBuffer.getspecs();
    ccd_width = specs[COLS];
    ccd_height = specs[ROWS];
    int narg = sscanf(args,"%d %d %d",&n,&target,&passes);
    if( n == 0) n = 200;		// a reasonable default value
    if(narg == 1){
        for(i=0; i< specs[ROWS]; i++){
            for(j = 0; j< specs[COLS]; j++) {
                ave_val = ( iBuffer.getpix(i-1,j-1) + iBuffer.getpix(i-1,j) + iBuffer.getpix(i-1,j+1) +
                           iBuffer.getpix(i,j-1)                            + iBuffer.getpix(i,j+1) +
                           iBuffer.getpix(i+1,j-1)  + iBuffer.getpix(i+1,j) + iBuffer.getpix(i+1,j+1) ) / 8;
                if( iBuffer.getpix(i,j) - ave_val > n ){
                    if(num_hot < NUMHOT){
                        hot_pix[num_hot++] = i*specs[COLS] + j;
                        if(num_hot <= 10) printf(" %d\t%d\n",j,i);
                    }
                }
            }
        }
        printf("%d hot pixels found\n",num_hot);
        if(num_hot > 10) printf("First 10 printed\n");
        if(specs[X0] != 0 || specs[Y0] != 0){
            beep();
            printf("Warning! FINDBAD is designed to operate on a full frame.\n");
        }
        free(specs);
        return NO_ERR;
    }
    // Alternate algorithm, with target value specified, this will call clearbad routine
    for (int p=0; p<passes;p++) {
        for(i=0; i< specs[ROWS]; i++){
            for(j = 0; j< specs[COLS]; j++) {
                int usefulNeighbors = 0;
                if( fabs(iBuffer.getpix(i,j) - target) >= n ){ // we have a hot one
                    hot_pix[num_hot] = i*specs[COLS] + j;
                    if (fabs(iBuffer.getpix(i-1,j-1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 1;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i-1,j) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 2;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i-1,j+1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 3;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i,j-1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 4;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i,j+1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 5;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i+1,j-1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 6;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i+1,j) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 7;
                        usefulNeighbors++;
                    }
                    if (fabs(iBuffer.getpix(i+1,j+1) - target) < n) {
                        neighbors[num_hot][usefulNeighbors] = 8;
                        usefulNeighbors++;
                    }
                    if(num_hot <= 10) printf(" %d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t\n",j,i,neighbors[num_hot][0],neighbors[num_hot][1],neighbors[num_hot][2],neighbors[num_hot][3],neighbors[num_hot][4],neighbors[num_hot][5],neighbors[num_hot][6],neighbors[num_hot][7]);
                    num_hot++;
                    if (usefulNeighbors == 0) {
                        neighbors[num_hot][usefulNeighbors] = 0;  // nothing to be done for this one
                    }
                }
            }
            
        }
        if(ccd_height > 0) ccd_height = -ccd_height;
        
        printf("%d hot pixels found on pass %d\n",num_hot,p+1);
        clearbad_c(0,(char*)"");
    }
    
    free(specs);
    return NO_ERR;
    
    
}
/*
 READBAD filename
 Read in bad pixel data from a text file.
 */

int readbad_c(int n, char* args)			/* read bad pixel data */
{
    int	i,j,k;
    FILE *fp;
    
    fp = fopen(fullname(args,GET_DATA),"r");
    if( fp != NULL) {
        
        fscanf(fp,"%d",&num_hot);
        fscanf(fp,"%d %d",&ccd_width, &ccd_height);
        if (ccd_height > 0) {
            for(k = 0; k < num_hot; k++){
                fscanf(fp,"%d %d",&j,&i);
                hot_pix[k] = i*ccd_width + j;
            }
        } else {
            for(k = 0; k < num_hot; k++){
                fscanf(fp,"%d %d",&j,&i);
                hot_pix[k] = i*ccd_width + j;
                for (int l = 0; l < 8; l++) fscanf(fp,"%d",&neighbors[k][l]);
            }
        }
    } else {
        beep();
        printf("Could not open file %s\n",args);
        return FILE_ERR;
    }
    fclose(fp);
    return NO_ERR;
}

/*
 WRITEBAD filename
 Write bad pixel data to a text file.
 */

int writebad_c(int n, char* args)			/* read bad pixel data */
{
    int	k;
    FILE *fp;
    
    if(num_hot == 0){
        beep();
        printf("No bad pixels found. Use FINDBAD Counts\n");
        return CMND_ERR;
    }
    
    fp = fopen(fullname(args,SAVE_DATA),"w");
    if( fp != NULL) {
        
        fprintf(fp,"%d\n",num_hot);
        fprintf(fp,"%d\t%d\n",ccd_width, ccd_height);
        if (ccd_height > 0) {   // take 8 neighbors
            for(k = 0; k < num_hot; k++){
                fprintf(fp,"%d\t%d\n",hot_pix[k]%ccd_width,hot_pix[k]/ccd_width);
            }
        } else { // height < 0 means this has the more complete set of pixels to average for bad pixels
            for(k = 0; k < num_hot; k++){
                fprintf(fp,"%d\t%d",hot_pix[k]%ccd_width,hot_pix[k]/ccd_width);
                for (int l = 0; l < 8; l++) fprintf(fp,"\t%d",neighbors[k][l]);
                fprintf(fp,"\n");
            }
        }
    } else {
        beep();
        printf("Could not open file %s\n",args);
        return FILE_ERR;
    }
    fclose(fp);
    return NO_ERR;
}

/*
 CLEARBAD
 
 Sets pixels tagged as bad to the value of their 8 nearest neighbors. This will not work well if
 there are contiguous bad pixels. For that, consider using the FILBOX or FILMSK commands.
 
 readbad /volumes/in/impx-s/sbig/sbig_bad_pix
 
 */

int clearbad_c(int n, char* args)
{
    int i,j,k;
    DATAWORD new_val;
    
    int* specs = iBuffer.getspecs();
    
    if(ccd_height > 0){
        for(k=0; k<num_hot; k++){
            i = hot_pix[k]/ccd_width;
            j = hot_pix[k] - i*ccd_width - specs[X0];
            i -= specs[Y0];
            //printf(" %d %d\n",j,i);
            if(i < specs[ROWS] && j < specs[COLS] && i >= 0 && j >= 0) {
                new_val = ( iBuffer.getpix(i-1,j-1) + iBuffer.getpix(i-1,j) + iBuffer.getpix(i-1,j+1) +
                           iBuffer.getpix(i,j-1)                            + iBuffer.getpix(i,j+1) +
                           iBuffer.getpix(i+1,j-1)  + iBuffer.getpix(i+1,j) + iBuffer.getpix(i+1,j+1) ) / 8;
                iBuffer.setpix(i,j, new_val);
            }
        }
        free(specs);
        iBuffer.getmaxx(PRINT_RESULT);
        update_UI();
        return NO_ERR;
    }
    for(k=0; k<num_hot; k++){
        i = hot_pix[k]/ccd_width;
        j = hot_pix[k] - i*ccd_width - specs[X0];
        i -= specs[Y0];
        //printf(" %d %d\n",j,i);
        if(i < specs[ROWS] && j < specs[COLS] && i >= 0 && j >= 0) {
            int usefulNeighbors = 0;
            new_val = 0.;
            while (neighbors[k][usefulNeighbors] != 0 && usefulNeighbors < 8) {
                
                switch (neighbors[k][usefulNeighbors]) {
                    case 1:
                        new_val += iBuffer.getpix(i-1,j-1);
                        usefulNeighbors++;
                        break;
                    case 2:
                        new_val += iBuffer.getpix(i-1,j);
                        usefulNeighbors++;
                        break;
                    case 3:
                        new_val += iBuffer.getpix(i-1,j+1);
                        usefulNeighbors++;
                        break;
                    case 4:
                        new_val += iBuffer.getpix(i,j-1);
                        usefulNeighbors++;
                        break;
                    case 5:
                        new_val += iBuffer.getpix(i,j+1);
                        usefulNeighbors++;
                        break;
                    case 6:
                        new_val += iBuffer.getpix(i+1,j-1);
                        usefulNeighbors++;
                        break;
                    case 7:
                        new_val += iBuffer.getpix(i+1,j);
                        usefulNeighbors++;
                        break;
                    case 8:
                        new_val += iBuffer.getpix(i+1,j+1);
                        usefulNeighbors++;
                        break;
                        
                    default:
                        break;
                }
            }
            
            if(usefulNeighbors){
                new_val /= usefulNeighbors;
                iBuffer.setpix(i,j, new_val);
            }
            
        }
        
        
    }
    free(specs);
    if (strncmp(args, "NoPrint", 7)== 0) {
        iBuffer.getmaxx(NO_PRINT);
    } else {
        iBuffer.getmaxx(PRINT_RESULT);
    }
    
    update_UI();
    return NO_ERR;
}

/* ********** */
int cclearbad_c(int n, char* args){
    int row,col,k;
    DATAWORD new_val;
    int* specs = iBuffer.getspecs();
    
    for(k=0; k<num_hot; k++){
        row = hot_pix[k]/ccd_width;
        col = hot_pix[k] - row*ccd_width - specs[X0];
        row -= specs[Y0];
        //printf(" %d %d\n",j,i);
        if(row < iBuffer.height() && col < iBuffer.width() && row >= 0 && col >= 0) {
            new_val = ( iBuffer.getpix(row-2,col-2) + iBuffer.getpix(row-2,col) + iBuffer.getpix(row-2,col+2) +
                       iBuffer.getpix(row,col-2)                            + iBuffer.getpix(row,col+2) +
                       iBuffer.getpix(row+2,col-2)  + iBuffer.getpix(row+2,col) + iBuffer.getpix(row+2,col+2) ) / 8;
            iBuffer.setpix(row,col, new_val);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}

void colorClearBad(Image* image){
    int row,col,k;
    DATAWORD new_val;
    int* specs = image->getspecs();
    
    for(k=0; k<num_hot; k++){
        row = hot_pix[k]/ccd_width;
        col = hot_pix[k] - row*ccd_width - specs[X0];
        row -= specs[Y0];
        //printf(" %d %d\n",j,i);
        if(row < image->height() && col < image->width() && row >= 0 && col >= 0) {
            new_val = ( image->getpix(row-2,col-2) + image->getpix(row-2,col) + image->getpix(row-2,col+2) +
                       image->getpix(row,col-2)                            + image->getpix(row,col+2) +
                       image->getpix(row+2,col-2)  + image->getpix(row+2,col) + image->getpix(row+2,col+2) ) / 8;
            image->setpix(row,col, new_val);
        }
    }
    free(specs);
}

/* ********** */
/*
 GETFUNCTION n filename
 Read in a tabulated function to be used by tabfun routine
 n is function number to be defined
 filename is file containing y=f(x) data pairs, preceeded by number of table entries
 Assumptions for tabulated functions:
 File format:
 first number is integer with the number of pairs to follow
 pairs are float with x followed by f(x) on the same line
 x values are ordered smallest to largest
 y = f(x) is single valued
 */

float* xptr[10] = {0,0,0,0,0,0,0,0,0,0};		// have a maximum of 10 functions
float* yptr[10] = {0,0,0,0,0,0,0,0,0,0};
int funsize[10] = {0*10};		// the number of elements in each function

int getfun_c(int n,char* args)
{
    int	i=0,j;
    int ferror = 0;
    FILE *fp;
    
    if( n<0 || n>9){
        beep();
        printf("Functions must be numbered 0-9.\n");
        return CMND_ERR;
    }
    
    while(args[i] != ' ' && args[i] != EOL) i++;
    
    fp = fopen(fullname(&args[++i],GET_DATA),"r");
    if( fp != NULL) {
        
        fscanf(fp,"%d",&i);		// the number of data pairs in the function
        
        if(xptr[n] !=0) free(xptr[n]);
        if(yptr[n] !=0) free(yptr[n]);
        
        xptr[n] = (float*) malloc(i*sizeof(float));
        yptr[n] = (float*) malloc(i*sizeof(float));
        funsize[n] = i;
        if(yptr[n] == 0 || xptr[n]==0) {
            beep();
            printf(" Not enough memory.\n");
            return MEM_ERR;
        }
        
        printf("Will read %d x-y pairs.\n",i);
        
        
        for (j=0; j < i; j++) {
            if( fscanf(fp,"%f %f",(xptr[n]+j),(yptr[n]+j)) != 2) ferror = 1;
        }
        
        fclose(fp);
        if(ferror == 1){
            beep();
            printf("Data Error.\n");
            if(xptr[n] !=0) free(xptr[n]);
            if(yptr[n] !=0) free(yptr[n]);
            return FILE_ERR;
        }
        if(*xptr[n] >= *(xptr[n]+1) ){
            beep();
            printf("Incorrect Data Ordering.\n");
            if(xptr[n] !=0) free(xptr[n]);
            if(yptr[n] !=0) free(yptr[n]);
            return FILE_ERR;
        }
        
        printf("x range is from %g to %g.\n",*(xptr[n]),*(xptr[n]+funsize[n]-1));
        printf("y range is from %g to %g.\n",*(yptr[n]),*(yptr[n]+funsize[n]-1));
        
    }
    else {
        beep();
        printf("Could not open file: %s\n",args);
        return FILE_ERR;
    }
    return NO_ERR;
}

float tabfun(int n, float x)	// n is the function number, x is the desired x value
{
    /* Assumptions for tabulated functions:
     File format:
     first number is integer with the number of pairs to follow
     pairs are float with x followed by f(x) on the same line
     x values are ordered smallest to largest
     y = f(x) is single valued
     */
    
    int i=0;
    float x0,x1,y0,y1,y;
    
    if( x <= *(xptr[n]) )
        return ( *(yptr[n]) );	// less than min x, returns f(min x)
    if( x >= *(xptr[n]+funsize[n]-1) )
        return ( *(yptr[n]+funsize[n]-1) ); // > max x, returns f(max x)
    
    while(  x >= *(xptr[n]+i) )
        i++;
    
    i--;
    x0 = *(xptr[n]+i);
    x1 = *(xptr[n]+i+1);
    y0 = *(yptr[n]+i);
    y1 = *(yptr[n]+i+1);
    y = y0 + (y1-y0)/(x1-x0)*(x-x0);
    //y = y0;								// What?
    return(y);
    
}

/* ********** */
/*
 LOOKUP
 
 Redefine the current image using the lookup table specified by a tabulated function
 Use GETFUN n filename before using this command
 Ignore scale factors for now
 */
int lookup_c(int n,char* args)
{
    if(xptr[n] == 0) {
        beep();
        printf("Function %d is not currently defined.\n",n);
        return CMND_ERR;
    }
    int nc,nt;
    int* specs = iBuffer.getspecs();
    
    for(nt=0; nt<specs[ROWS];nt++) {
        for(nc=0;nc < specs[COLS]; nc++){
            iBuffer.setpix(nt,nc,tabfun(n,iBuffer.getpix(nt,nc)));
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}


/* ********** */


/* --------------------------- */
int ramp_c(int n,char* args)				/* fill current image with a ramp from 0 to the number of number of channels */
{
    int nc,nt;
    int* specs = iBuffer.getspecs();
    //printf("rsize = %f\n",rsize);
    for(nt=0; nt<specs[ROWS];nt++) {
        for(nc=0;nc < specs[COLS]; nc++){
            iBuffer.setpix(nt,nc,nc);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

//***************************************************************//
//**    ROUNDUP - Round the DATAWORD values UP to the nearest integer value   *//
//***************************************************************//
int roundUp_c (int n, char* args)
{
    int nc,nt;
    int* specs = iBuffer.getspecs();
    
    for(nt=0; nt<specs[ROWS]; nt++) {
        for (nc =0; nc<specs[COLS]; nc++){
            iBuffer.setpix(nt, nc, ceilf(iBuffer.getpix(nt, nc)));
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

//***************************************************************//
//**    ROUNDOFF - Round the DATAWORD values Down to the nearest integer value   *//
//***************************************************************//
int roundoff_c(int n, char* args)
{
    int nc,nt;
    int* specs = iBuffer.getspecs();
    
    for(nt=0; nt<specs[ROWS]; nt++) {
        for (nc =0; nc<specs[COLS]; nc++){
            iBuffer.setpix(nt, nc, floorf(iBuffer.getpix(nt, nc)));
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* --------------------------- */

/*
 ACCUMULATE
 Allocates and clears memory for an image accumulator buffer that can be used to sum
 individual images. The size of the accumulator is determined by the image size parameters
 when the accumulate command is first given.
 */

int accumulate_c(int n,char* args)
{
    accumulator.free();
    int* specs = iBuffer.getspecs();
    accumulator = Image(specs[ROWS],specs[COLS]);
    free(specs);
    if(accumulator.err()){
        return accumulator.err();
    }
    accumulator.copyABD(iBuffer);
    accumulator.zero();
    //free(specs);
    return NO_ERR;
}


/*
 ACDELETE
 Frees the memory associated with the accumulator.
 */

int acdelete_c(int n,char* args)
{
    if (!accumulator.isEmpty()) {
        accumulator.free();
    }
    return NO_ERR;
}


/*
 ACADD
 Adds the current image data buffer to the accumulator buffer.
 */

int acadd_c(int n,char* args)
{
    if (accumulator.isEmpty()) {
        beep();
        printf("Accumulator has not been initialized.\n");
        return CMND_ERR;
    }
    
    if(accumulator != iBuffer){
        beep();
        printf("Accumulator is not the correct size for the current image.\n");
        return SIZE_ERR;
    }
    accumulator + iBuffer;
    return NO_ERR;
}

/*
 ACGET
 Moves the data from the accumulator buffer into the current image data area. The
 previous contents of the image data buffer are destroyed.
 */

int acget_c(int n,char* args){
    if (accumulator.isEmpty()) {
        beep();
        printf("Accumulator has not been initialized.\n");
        return CMND_ERR;
    }
    iBuffer.free();
    iBuffer << accumulator;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return iBuffer.err();
}

/* ********** */
/* --------------------------- */

/*
 HDRACCUMULATE cutoffMax [cutoffMin]
 Allocates and clears memory for an HDR accumulator that can be used to generate HDR
 images from a series of different exposures. The cuttoffMax value should be less than
 the saturation value for the detector. Values less than cutoffMin are not included; the default
 for cutoffMin is 0. The size of the accumulator is determined
 by the image size parameters when the accumulate command is first given. Be sure
 the exposure value for the image is set (e.g., imported from a raw file or set using
 the EXPOSURE command).
 */

int hdrAccumulate_c(int n,char* args)
{
    hdrCutoffMax = n;
    hdrCutoffMin = 0;
    sscanf(args,"%f %f",&hdrCutoffMax,&hdrCutoffMin);
    hdrFrames = 0;
    hdrMaxScale = 1.;
    hdrAccumulator.free();
    hdrCounter.free();
    int* specs = iBuffer.getspecs();
    hdrAccumulator = Image(specs[ROWS],specs[COLS]);
    if(hdrAccumulator.err()){
        free(specs);
        return hdrAccumulator.err();
    }
    hdrAccumulator.copyABD(iBuffer);
    hdrAccumulator.zero();
    
    hdrCounter = Image(specs[ROWS],specs[COLS]);
    if(hdrCounter.err()){
        free(specs);
        return hdrCounter.err();
    }
    hdrCounter.zero();
    free(specs);
    return NO_ERR;
}


/*
 ACDELETE
 Frees the memory associated with the accumulator.
 */

int hdrAcdelete_c(int n,char* args)
{
    if (!hdrAccumulator.isEmpty()) {
        hdrAccumulator.free();
        hdrCounter.free();
    }
    hdrFrames = 0;
    return NO_ERR;
}


/*
 ACADD
 Adds the current image data buffer to the accumulator buffer.
 */

int hdrAcadd_c(int n,char* args)
{
    if (hdrAccumulator.isEmpty()) {
        beep();
        printf("HDR Accumulator has not been initialized.\n");
        return CMND_ERR;
    }
    
    if(hdrAccumulator != iBuffer){
        beep();
        printf("HDR Accumulator is not the corret size for the current image.\n");
        return SIZE_ERR;
    }
    static float firstExposure = 1;
    int* specs = iBuffer.getspecs();
    DATAWORD* values = iBuffer.getvalues();
    if(hdrFrames == 0){
        firstExposure = values[EXPOSURE];
    }
    float normalize = values[EXPOSURE]/firstExposure;
    printf("%f\n",normalize);
    if (1./normalize > hdrMaxScale) {
        hdrMaxScale = 1./normalize;
    }
    hdrFrames++;
    for( int row=0; row < specs[ROWS]; row++){
        for( int col=0; col < specs[COLS]; col++){
            DATAWORD val = iBuffer.getpix(row,col);
            if (val < hdrCutoffMax && val >= hdrCutoffMin) {
                hdrAccumulator.setpix(row, col, hdrAccumulator.getpix(row,col)+val/normalize);
                hdrCounter.setpix(row, col, hdrCounter.getpix(row,col)+1);
            }
        }
    }
    free(specs);
    free(values);
    return NO_ERR;
}

/*
 ACGET
 Moves the data from the accumulator buffer into the current image data area. The
 previous contents of the image data buffer are destroyed.
 */

int hdrAcget_c(int n,char* args){
    if (hdrAccumulator.isEmpty()) {
        beep();
        printf("HDR Accumulator has not been initialized.\n");
        return CMND_ERR;
    }
    iBuffer.free();
    int* specs = hdrAccumulator.getspecs();
    iBuffer = Image(specs[ROWS],specs[COLS]);
    iBuffer.copyABD(hdrAccumulator);
    
    for( int row=0; row < specs[ROWS]; row++){
        for( int col=0; col < specs[COLS]; col++){
            if(hdrCounter.getpix(row,col) > 0)  // check in case there are no images contributing at this pixel
                iBuffer.setpix(row, col, hdrAccumulator.getpix(row,col)/hdrCounter.getpix(row,col));
            else
                // if counter is zero, assume we're saturated
                iBuffer.setpix(row, col,hdrCutoffMax*hdrMaxScale);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return iBuffer.err();
}

int hdrNumget_c(int n,char* args){
    if (hdrCounter.isEmpty()) {
        beep();
        printf("HDR Accumulator has not been initialized.\n");
        return CMND_ERR;
    }
    iBuffer.free();
    iBuffer << hdrCounter;
    
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return iBuffer.err();
}

int exposure_c(int n,char* args){
    extern Variable user_variables[];
    DATAWORD* values = iBuffer.getvalues();
    float exp;
    if(sscanf(args,"%f",&exp) == 1){
        values[EXPOSURE] = exp;
        iBuffer.setvalues(values);
    } else {
        printf("Exposure: %f\n",values[EXPOSURE]);
    }
    
    user_variables[0].fvalue = values[EXPOSURE];
    user_variables[0].is_float = 1;
    free(values);
    update_UI();
    return NO_ERR;
}
/* ********** */

/*
 INTEGRATE direction_flag selection_box do_average
 
 direction_flag = 1 	The result is an array in x; sum in the y direction (sum rows)
 direction_flag = 0 	The result is an array in y; sum in the x direction (sum columns)
 
 selection_box = 1	A selection box specifies how many channels or tracks to sum
 selection_box = 0	Sum all channels or tracks -- direction specified by direction_flag
 
 do_average = 1		Average along the integrate direction (divide by box size in integration direction)
 do_average = 0		just sum, don't average
 
 */

int integrateFill(int n,char* args, int integratefill ){
    float	sum;
    int			pxstart,pxend,pystart,pyend;
    int 		i,j,xdirection,sbox=0,do_average=0;
    float *acpoint;
    unsigned int  acsize = 0;
    
    point substart,subend;
    int* specs = iBuffer.getspecs();
    int imageHeight = iBuffer.height();
    
    substart = UIData.iRect.ul;
    subend = UIData.iRect.lr;
    
    xdirection = n;
    Image newImage;
    
    sscanf(args,"%d %d %d",&xdirection,&sbox,&do_average);
    
    if(xdirection) {
        
        if( sbox && ( substart.h == subend.h) ) {
            beep();
            printf("Rectangle has 0 width; integrate entire image\n");
            sbox = false;
        }
        if(sbox) {
            pxstart = substart.h;
            pxend = subend.h+1;
            pystart = substart.v;
            pyend = subend.v+1;
            
            if( pxstart < 0 )
                pxstart = 0;
            if( pxend > specs[COLS])
                pxend = specs[COLS];
            if( pystart < 0 )
                pystart = 0;
            if( pyend > imageHeight)
                pyend = imageHeight;
            
        }
        else {
            pxstart = 0;
            pxend = specs[COLS];
            pystart = 0;
            pyend = imageHeight;
        }
        
        acsize = specs[COLS]*sizeof(DATAWORD);
        acpoint = (float*) malloc(acsize);
        if(acpoint == 0) {
            nomemory();
            return MEM_ERR;
        }
        
        for(j=pxstart; j < pxend; j++) {
            sum = 0;
            for(i=pystart; i < pyend; i++) {
                sum += iBuffer.getpix(i,j) ;
            }
            *(acpoint + j) = sum;
        }
        
        specs[COLS] = abs(pxend - pxstart);
        
        if(!integratefill) {
            if(specs[IS_COLOR]){
                specs[ROWS] = 3;
            } else {
                specs[ROWS] = 1;
            }
        }

        newImage.setspecs(specs);
        
        for (i=0; i<newImage.height(); i++) {
            for(j=0; j < specs[COLS]; j++) {
                if(do_average)
                    newImage.setpix(i,j, *(acpoint+j+pxstart)/(pyend-pystart));
                else
                    newImage.setpix(i,j, *(acpoint+j+pxstart));
            }
        }
        if(specs[IS_COLOR]){
            // we've done the red already, do the green and blue (colors 2 and 3)
            for(int c=1; c<3; c++){
                for(j=pxstart; j < pxend; j++) {
                    sum = 0;
                    for(i=pystart; i < pyend; i++) {
                        sum += iBuffer.getpix(i+c*imageHeight,j) ;
                    }
                     *(acpoint + j) = sum;
                }
                for (i=0; i<newImage.height(); i++) {
                    for(j=0; j < specs[COLS]; j++) {
                        if(do_average)
                            newImage.setpix(i+c*newImage.height(),j, *(acpoint+j+pxstart)/(pyend-pystart));
                        else
                            newImage.setpix(i+c*newImage.height(),j, *(acpoint+j+pxstart));
                    }
                }
            }
        }

    }
    else {
        if( sbox && (substart.v == subend.v) ) {
            beep();
            sbox = false;
        }
        if(sbox) {
            pxstart = substart.v;
            pxend = subend.v+1;
            pystart = substart.h;
            pyend = subend.h+1;
            
            if( pxstart < 0 )
                pxstart = 0;
            if( pxend > imageHeight)
                pxend = imageHeight;
            if( pystart < 0 )
                pystart = 0;
            if( pyend > specs[COLS])
                pyend = specs[COLS];
            
        }
        else {
            pxstart = 0;
            pxend = imageHeight;
            pystart = 0;
            pyend = specs[COLS];
        }
        
        acsize = imageHeight*sizeof(DATAWORD);
        acpoint = (float*) malloc(acsize);
        if(acpoint == 0) {
            nomemory();
            return -1;
        }
        
        for(j=pxstart; j < pxend; j++) {
            sum = 0;
            for(i=pystart; i < pyend; i++) {
                sum += iBuffer.getpix(j,i);
            }
            *(acpoint + j) = sum;
        }
        
        specs[ROWS] = abs(pxend - pxstart);
        if(specs[IS_COLOR]) specs[ROWS] *= 3;
        
        if(!integratefill) {
            specs[COLS] = 1;
        }

        newImage.setspecs(specs);

        for (i=0; i<newImage.height(); i++) {
            for(j=0; j < specs[COLS]; j++) {
                if(do_average)
                    newImage.setpix(i,j, *(acpoint+i+pxstart)/(pyend-pystart));
                else
                    newImage.setpix(i,j, *(acpoint+i+pxstart));
            }
        }
        if(specs[IS_COLOR]){
            // we've done the red already, do the green and blue (colors 2 and 3)
            for(int c=1; c<3; c++){
                for(j=pxstart; j < pxend; j++) {
                    sum = 0;
                    for(i=pystart; i < pyend; i++) {
                        sum += iBuffer.getpix(j+c*imageHeight,i);
                    }
                    *(acpoint + j) = sum;
                }
                for (i=0; i<newImage.height(); i++) {
                    for(j=0; j < specs[COLS]; j++) {
                        if(do_average)
                            newImage.setpix(i+c*newImage.height(),j, *(acpoint+i+pxstart)/(pyend-pystart));
                        else
                            newImage.setpix(i+c*newImage.height(),j, *(acpoint+i+pxstart));
                    }
                }
            }
        }
    }
    iBuffer.free();
    iBuffer = newImage;
    free(acpoint);
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return iBuffer.err();
}

/* ********** */

int integrate_c(int n,char* args){
    return integrateFill(n,args, false );
}

/* ********** */

int intfill_c(int n,char* args){
    return integrateFill(n,args, true );
}

/* ********** */

int ln_c(int n,char* args){
    for(int nt=0; nt<iBuffer.rows(); nt++) {
        for (int nc =0; nc<iBuffer.cols(); nc++){
            iBuffer.setpix(nt, nc, logf(iBuffer.getpix(nt, nc)));
        }
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int 	bigfile_fd;
int 	bigfile_open = 0;
char 	bigfile_name[CHPERLN] = {0};
int     bigfileFrames = 0;

int createfile_c(int n,char* args)
{
    //strcpy(lastname,args);		// save a copy of the short name for labeling graphics windows
    //bigfile_fd = creat(fullname(args,SAVE_DATA),PMODE);
    bigfile_fd = open(fullname(args,SAVE_DATA),WMODE);
    strcpy(bigfile_name,args);
    iBuffer.saveFile((char*)&bigfile_fd,LEAVE_OPEN);
    bigfileFrames++;
    bigfile_open = 1;
    return iBuffer.err();
}
/* ********** */

int concatfile_c(int n,char* args)
{
    if( bigfile_open == 0) {
        beep();
        printf("Use CREATE to Specify a File First.\n");
        return FILE_ERR;
    }
    iBuffer.saveFile((char*)&bigfile_fd,IS_OPEN);
    bigfileFrames++;
    return iBuffer.err();
}

/* ********** */

int closefile_c(int n,char* args)
{
    if(bigfile_open == 0){
        beep();
        printf("There is no open file from the CREATEFILE command.\n");
        return FILE_ERR;
    }
    
    close(bigfile_fd);
    FILE* big;
    big = fopen(bigfile_name, "r+");
    if (big) {                      // set the number of frames
        char txt[HEADLEN];
        int nspecs = NSPECS;
        int nvalues = NVALUES;
        int nrulerchar = NRULERCHAR;
        
        int* specs = iBuffer.getspecs();
        specs[ NFRAMES] = --bigfileFrames;
        
        strcpy(txt, OMA2_BINARY_DATA_STRING);
        fwrite(txt, sizeof(char), HEADLEN, big);
        fwrite(&nspecs,sizeof(int),1,big);
        fwrite(&nvalues,sizeof(int),1,big);
        fwrite(&nrulerchar,sizeof(int),1,big);
        fwrite(specs,sizeof(int),nspecs,big);
        fclose(big);
        free(specs);
    }
    bigfile_open = 0;
    bigfileFrames = 0;
    //setdata(bigfile_name);
    //fileflush(bigfile_name);	/* for updating directory */
    printf("File %s Closed.\n",bigfile_name);
    return NO_ERR;
    
}

/* ********** */

int	fileIsOpen = 0;
int openFileFd = -1;
int remainingFrames = 0;


int openfile_c(int n,char* args){
    extern Variable user_variables[];
    char txt[CHPERLN];
    strncpy(txt, args, CHPERLN);
    unsigned long filesize = fsize(fullname(txt, GET_DATA));
    Image new_im(args,LEAVE_OPEN);
    if(new_im.err()){
        beep();
        printf("Could not load %s\n",args);
        return new_im.err();
    }
    fileIsOpen = 1;
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    int* specs = iBuffer.getspecs();
    if (filesize < specs[ROWS]*specs[COLS]*sizeof(DATAWORD)*specs[NFRAMES]) { // number of frames must not have been set
        specs[NFRAMES] = (int)(filesize-sizeof(Image))/(specs[ROWS]*specs[COLS]*sizeof(DATAWORD))-1;    // this is a reasonable guess
        iBuffer.setspecs(specs);
    }
    printf("%d Frames.\n",specs[NFRAMES]+1);
    remainingFrames = specs[NFRAMES];
    user_variables[0].ivalue = user_variables[0].fvalue = specs[NFRAMES]+1;
    user_variables[0].is_float = 0;
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

int getNext_c(int n,char* args)
{
    if (!fileIsOpen) {
        beep();
        printf("No file has been opened. Use the OPENFILE command.\n");
        return FILE_ERR;
        
    }
    Image new_im((char*)&openFileFd,IS_OPEN);
    if(new_im.err()){
        beep();
        printf("Could not load another image.\n");
        fileIsOpen = 0;
        close(openFileFd);
        openFileFd= -1;
        new_im.free();
        return new_im.err();
    }
    // some potential problems here if sizes aren't right
    // probably need more checking
    new_im.copyABD(iBuffer);
    remainingFrames--;
    if (remainingFrames == 0) {
        fileIsOpen = 0;
        close(openFileFd);
        printf("Last image -- file is now closed.\n");
        openFileFd= -1;
        
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    if (strncmp(args, "NoPrint", 7)== 0) {
        iBuffer.getmaxx(NO_PRINT);
    } else {
        iBuffer.getmaxx(PRINT_RESULT);
    }
    
    update_UI();
    return NO_ERR;
}

/* ********** */

int dx_c(int n,char* args)
{
    if(n < 1) n = 1;
    int* specs = iBuffer.getspecs();
    specs[DX] = n;
    iBuffer.setspecs(specs);
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

int dy_c(int n,char* args)
{
    if(n < 1) n = 1;
    int* specs = iBuffer.getspecs();
    specs[DY] = n;
    iBuffer.setspecs(specs);
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

int x0_c(int n,char* args)
{
    if(n < 0) n = 0;
    int* specs = iBuffer.getspecs();
    specs[X0] = n;
    iBuffer.setspecs(specs);
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */
int y0_c(int n,char* args)
{
    if(n < 0) n = 0;
    int* specs = iBuffer.getspecs();
    specs[Y0] = n;
    iBuffer.setspecs(specs);
    free(specs);
    update_UI();
    return NO_ERR;
}

/* ********** */

int pixSize_c(int n,char* args){
    extern float windowScaleFactor;
    if(*args == 0){
        printf("Pixel scaling is %.2f\n",windowScaleFactor);
        return NO_ERR;
    }
    int narg = (sscanf(args,"%f",&windowScaleFactor));
    if(narg != 1 )windowScaleFactor = 1.;
    if (windowScaleFactor == 0.) {
        windowScaleFactor = 1.;
    }
    if (windowScaleFactor < 0.) {
        windowScaleFactor = -1./windowScaleFactor;
    }
    return NO_ERR;
}

/* ********** */

int ruler_c(int n, char* args)
{
    
    int i=0;
    float pix,unit,rulerScale;
    
    
    int* specs = iBuffer.getspecs();
    
    if (*args == 0) {
        if( specs[HAS_RULER]) {
            char* unit_text = iBuffer.getunit_text();
            float* values = iBuffer.getvalues();
            if( unit_text[0] )
                printf("%f Pixels per %s.\n",values[RULER_SCALE],unit_text);
            else
                printf("%f Pixels per Unit.\n",values[RULER_SCALE]);
            free(values);
            free(unit_text);
        } else {
            printf("No Ruler Defined.\n");
        }
        free(specs);
        return NO_ERR;
    }
    
    if( sscanf(args,"%f %f",&pix,&unit) != 2) {
        beep();
        printf("Two Arguments Needed.\n");
        specs[HAS_RULER] = 0;
        iBuffer.setspecs(specs);
        free(specs);
        return CMND_ERR;
    }
    rulerScale = pix/unit;
    
    char unit_text[NRULERCHAR];
    unit_text[0] = 0;
    
    //if( sscanf(args,"%f %f %s",&pix,&unit,unit_text) == 3)
    int index = 0;
    /* Now see if a unit was specified */
    while (args[index] != EOL && args[index] != ';') {
        if(args[index] == ' ') {
            i++;
            if(i==2) {		/* if this is the second space, assume we have a comment */
                index++;
                for(n=0; (n<NRULERCHAR-1) && (args[index] != EOL) && (args[index] != ';') ; n++) {
                    unit_text[n] = args[index];
                    index++;
                }
                unit_text[n] = EOL;
                break;
            }
        }
        index++;
    }
    iBuffer.setRuler(rulerScale,unit_text);
    
    if( unit_text[0] )
        printf("%f Pixels per %s.\n",rulerScale,unit_text);
    else
        printf("%f Pixels per Unit.\n",rulerScale);
    free(specs);
    return NO_ERR;
    
}

/* ********** */

/*
 DOC2RGB c1 c2 c3 c4
 Treat the image in the current image buffer as a raw document
 (output from the dcraw routine with options -d or -D selected)
 and convert it to an RGB image. This is assumed to have a 2 x 2 color matrix
 of R G B values in a Bayer pattern.
 c1 - c4 have values 0, 1 or 2, corresponding to red, green, and blue. For example if Bayer Matrix is
 G B
 R G
 c1 - c4 should be 1 2 0 1
 Appropriate values depend on the specific camera. (See the output from the GETRGB command.)
 */

int doc2rgb_c(int n, char* args){
    
    int bayer[2][2] = {{ 0 }};
    
    int narg = sscanf(args,"%d %d %d %d",&bayer[0][0],&bayer[0][1],&bayer[1][0],&bayer[1][1]);
    if(narg != 4){
        beep();
        printf("4 arguments needed. E.g., 1 2 0 1 for GBRG\n");
        return CMND_ERR;
    }
    int* specs = iBuffer.getspecs();
    
    int newrow = specs[ROWS]/2;
    int newcol = specs[COLS]/2;
    int row,col;
    
    Image red(newrow,newcol),green(newrow,newcol),blue(newrow,newcol);
    
    for (row=0; row < newrow*2; row++) {
        //if( row&1)
        //pt_green -= nchan;
        for (col=0; col < newcol*2; col++){
            switch (bayer[row&1][col&1]){
                case 0:		// red
                    red.setpix(row/2,col/2,iBuffer.getpix(row,col));   //*datp++;
                    break;
                case 1:		// green
                    if(row&1){
                        green.setpix(row/2,col/2,(green.getpix(row/2,col/2)+iBuffer.getpix(row,col))/2.);
                    } else {
                        green.setpix(row/2,col/2,iBuffer.getpix(row,col));// =  *datp++;
                    }
                    break;
                case 2:		// blue
                    blue.setpix(row/2,col/2,iBuffer.getpix(row,col));// *pt_blue++ =  *datp++;
                    break;
            }
        }
        //if(header[NCHAN]&1) datp++;	// there may be an odd number of columns
    }
    
    red.composite(green);
    red.composite(blue);
    green.free();
    blue.free();
    iBuffer.free();     // release the old data
    iBuffer = red;   // this is the new data
    specs[IS_COLOR] = 1;
    specs[ROWS] = newrow*3;
    specs[COLS] = newcol;
    iBuffer.setspecs(specs);
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ********** */

/*
 DOC2COLOR c1 c2 c3 c4 c5
 Treat the image in the current image buffer as a raw document
 (e.g., output from the dcraw routine with options -d or -D selected)
 and convert it to an R, G, or B image. This is assumed to have a 2 x 2 color matrix
 of R G B values in a Bayer pattern.
 c1 - c4 have values 0, 1 or 2, corresponding to red, green, and blue. For example if Bayer Matrix is
 G B
 R G
 c1 - c4 should be 1 2 0 1
 c5 is 0, 1, or 2 for conversion to red, green, or blue
 Pixels associated with non-selected colors have a value of 0. Doing a BLOCK 2 2 command after this command will remove the zeros.
 Blocking 2 by 2 on the green channel will sum the two green pixels.
 
 Appropriate values depend on the specific camera. (See the output from the GETRGB command.)
 */

int doc2color_c(int n, char* args){
    
    int bayer[2][2] = {{ 0 }};
    int color;
    
    int narg = sscanf(args,"%d %d %d %d %d",&bayer[0][0],&bayer[0][1],&bayer[1][0],&bayer[1][1],&color);
    if(narg != 5){
        beep();
        printf("5 arguments needed. E.g., 1 2 0 1 1 for GBRG pattern, zero all but G\n");
        return CMND_ERR;
    }
    
    int row,col;
    
    Image newim(iBuffer.height(),iBuffer.width());    // allocates space for new image
    newim.copyABD(iBuffer);     // same size
    
    for (row=0; row < iBuffer.height(); row++) {
        for (col=0; col < iBuffer.width(); col++){
            switch (bayer[row&1][col&1]){
                case 0:		// red
                    if(color == 0)
                        newim.setpix(row,col,iBuffer.getpix(row,col));
                    else
                        newim.setpix(row,col,0);
                    break;
                case 1:		// green
                    if(color == 1)
                        newim.setpix(row,col,iBuffer.getpix(row,col));
                    else
                        newim.setpix(row,col,0);
                    break;
                case 2:		// blue
                    if(color == 2)
                        newim.setpix(row,col,iBuffer.getpix(row,col));
                    else
                        newim.setpix(row,col,0);
                    break;
            }
        }
        //if(header[NCHAN]&1) datp++;	// there may be an odd number of columns
    }
    
    iBuffer.free();     // release the old data
    iBuffer = newim;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ********** */

int	normal_prefix = 1;

int uprefix_c(int n,char* args)		/* force the use of a particular prefix andsuffix */
{
    
    switch( *args ) {
        case 'G':
        case 'g':
            printf("Using 'Get File' Prefixes.\n");
            normal_prefix = 0;
            break;
        case 'S':
        case 's':
            printf("Using 'Save File' Prefixes.\n");
            normal_prefix = -1;
            break;
        default:
            printf("Using Default Prefixes.\n");
            normal_prefix = 1;
            break;
    }
    return 0;
    
}

/* ********** */

/*
 SEQ2HDR filename cutoff
 Convert a sequence of images with different exposures to an HDR image. The file contains all images and must have information on exposures stored in the EXTRA data (see the EXTRA command). This type of file can be created by GigE cameras in oma2cam or can be created using the CREATEFILE/CONCATENATEFILE/COLSEFILE commands. Note that all exposure information must be entered in the extra space before CREATEFILE is used to open the file.
 */

int seq2hdr_c(int n,char* args){
    int ex;
    DATAWORD cutoff;
    char filename[FILENAME_MAX];
    int narg = sscanf(args,"%s %f",filename, &cutoff);
    if (narg != 2) {
        beep();
        printf("Need two arguments: filename cutoff\n");
        return CMND_ERR;
    }
    
    int err = openfile_c(0, filename);
    if (err) {
        beep();
        printf("Could not open %s\n",filename);
        return err;
    }
    int* specs = iBuffer.getspecs();
    int extraSize = iBuffer.getExtraSize();
    if (extraSize < specs[NFRAMES]+ 1) {
        beep();
        printf("The sequence does not contain enough exposure values.\n");
        free(specs);
        return FILE_ERR;
    }
    extraSize = specs[NFRAMES]+ 1;
    
    Image* exp = new Image[specs[NFRAMES]+ 1];
    
    for(ex=0; ex < specs[NFRAMES]; ex++){
        exp[ex] << iBuffer;
        getNext_c(0,(char*) "NoPrint");
    }
    exp[ex] << iBuffer;
    
    
    float* expValues = iBuffer.getextra();
    
    for( int row=0; row < specs[ROWS]; row++){
        for( int col=0; col < specs[COLS]; col++){
            DATAWORD sum = 0.;
            int num = 0;
            for(int ex=0; ex < extraSize; ex++){
                DATAWORD val = exp[ex].getpix(row,col);
                if (val < cutoff) {
                    sum += val/(expValues[ex]/expValues[0]);
                    num++;
                }
            }
            iBuffer.setpix(row,col, sum/num);
        }
    }
    
    specs[NFRAMES] = 0;     // this is just a single image now
    iBuffer.setspecs(specs);
    
    for(int ex=0; ex < extraSize; ex++){
        exp[ex].free();
        //printf("%f\n",expValues[ex]);
    }
    
    free(specs);
    free(expValues);
    delete[] exp;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}
/* ********** */

/*
 SEQ2IMAGE filename
 Open all frames of a sequence of images to a single image whose height is NFRAMES*FRAMEHEIGHT.
 */

int seq2Image_c(int n,char* args){
    int ex;
    int err;
    err = openfile_c(0, args);
    if (err) {
        beep();
        printf("Could not open %s\n",args);
        return err;
    }
    int* specs = iBuffer.getspecs();    // iBuffer has the first frame
    int frames = specs[NFRAMES];    // this is the index of the last frame
    specs[NFRAMES] = 0;     // this is just a single image now
    iBuffer.setspecs(specs);
    free(specs);
    
    Image result;
    result << iBuffer;
    
    for(ex=0; ex < frames; ex++){
        getNext_c(0,(char*) "NoPrint");
        result.composite(iBuffer);
        err = result.err();
        if (err) {
            beep();
            printf("Composite error.\n");
            return err;
        }
        
    }
    iBuffer.free();
    iBuffer = result;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}
/* ********** */

/*
 IM2SEQUENCE filename frames
 Save the current image as a sequence of images with the specified number of frames. This type of data file can be used by the SEQ2HDR command.
 */

int im2Sequence_c(int n,char* args){
    
    int err,frames;
    char filename[FILENAME_MAX];
    int narg = sscanf(args,"%s %d",filename, &frames);
    
    if (narg != 2) {
        beep();
        printf("Need two arguments: filename frames\n");
        return CMND_ERR;
    }
    if(frames < 1) frames = 1;
    int* specs = iBuffer.getspecs();
    iBuffer.saveFile(filename, SAVE_DATA);
    err = iBuffer.err();
    if (err) {
        beep();
        printf("Could not open %s\n",filename);
        return err;
    }
    specs[NFRAMES] = frames-1;
    specs[ROWS] /= frames;
    
    FILE* big;
    big = fopen(filename, "r+");
    if (big) {                      // set the number of frames
        char txt[HEADLEN];
        int nspecs = NSPECS;
        int nvalues = NVALUES;
        int nrulerchar = NRULERCHAR;
        
        strcpy(txt, OMA2_BINARY_DATA_STRING);
        fwrite(txt, sizeof(char), HEADLEN, big);
        fwrite(&nspecs,sizeof(int),1,big);
        fwrite(&nvalues,sizeof(int),1,big);
        fwrite(&nrulerchar,sizeof(int),1,big);
        fwrite(specs,sizeof(int),nspecs,big);
        fclose(big);
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

/* ********** */
/*
 EXTRA [index] [value]
 Add extra information to the current image in the form of a floating point value. If no argument is given, the command lists extra values in the current image buffer. Indexing starts at 1. With no arguments, the extra values are put into the command_return variables. With one argument, the extra value is put into command_return_1.
 */

int extra_c(int n,char* args){
    int size = iBuffer.getExtraSize();
    extern Variable user_variables[];
    
    if (*args == 0) {
        if ( size) {
            printf("Extra values are as follows:\n");
            float* extra = iBuffer.getextra();
            for (int i = 0; i< NUM_COMMAND_RETURN_VARIABLES; i++){
                printf("%g\n",extra[i]);
                user_variables[i].ivalue = user_variables[i].fvalue = extra[i];
                user_variables[i].is_float = 1;
            }
            for (int i = NUM_COMMAND_RETURN_VARIABLES;i < size; i++){
                printf("%g\n",extra[i]);
                user_variables[i].ivalue = user_variables[i].fvalue = extra[i];
                user_variables[i].is_float = 1;
            }
            
            //free(extra);
            delete[] extra;
            update_UI();
            return NO_ERR;
        } else {
            printf("No extra values are present.\n");
            return NO_ERR;
        }
    }
    float value;
    int nargs = sscanf(args, "%d %f)",&n,&value);
    if (--n < 0) {
        printf("Index must be > 0.\n");
        return CMND_ERR;
    }
    if(nargs == 1 ){
        if(n<size){
            float* extra = iBuffer.getextra();
            printf("Extra value %d is %f:\n",n+1, extra[n]);
            user_variables[0].ivalue = user_variables[0].fvalue = extra[n];
            user_variables[0].is_float = 1;
            //free(extra);
            delete[] extra;
            update_UI();
            return NO_ERR;
        } else {
            beep();
            printf("Extra value %d is not defined\n",n+1);
            return CMND_ERR;
        }
    }
    
    if (n < size) {
        // we aready have space, just fill in the value
        float* extra = iBuffer.getextra();
        extra[n] = value;
        iBuffer.setExtra(extra, size);
        //free(extra);
        delete[] extra;
        return NO_ERR;
    }
    // need more space
    float* newextra = new float[n+1];
    float* extra = iBuffer.getextra();
    for (int i = 0; i < size; i++) {
        newextra[i] = extra[i];
    }
    delete[] extra;
    newextra[n] = value;
    iBuffer.setExtra(newextra, n+1);
    
    return NO_ERR;
    
}

/* ********** */
/*
 DISP2RGB
 Convert the display image to rgb. Use this to turn a false color intensity map into an RGB image or to modify a color image so the values follow the display settings. Returned values are integers between 0 - 255.
 */

int disp2rgb_c(int n,char* args){
    ImageBitmap bitmap;
    unsigned char* pixbytes;
    int saveAutoScale = UIData.autoscale;
    UIData.autoscale = 0;
    bitmap = iBuffer;   // get the bitmap
    pixbytes = bitmap.getpixdata();
    UIData.autoscale = saveAutoScale;
    if (!iBuffer.isColor()) {
        // need a bigger image to handle three colors
        Image newim(iBuffer.height()*3,iBuffer.width());    // allocates space for color image
        newim.copyABD(iBuffer);     // height and color setting are wrong now
        int* specs = newim.getspecs();
        specs[IS_COLOR] = 1;
        specs[ROWS] = iBuffer.height()*3;
        newim.setspecs(specs);
        free(specs);
        iBuffer.free(); // done with this old data
        iBuffer = newim;
        
    }
    
    int height = iBuffer.height();      // remember the height method returns Rows/3 for color images
    for (int r = 0; r < height; r++) {
        for (int c = 0; c < iBuffer.width(); c++) {
            iBuffer.setpix(r, c, *pixbytes++);
            iBuffer.setpix(r+height, c, *pixbytes++);
            iBuffer.setpix(r+2*height, c, *pixbytes++);
        }
    }
    
    bitmap.freeMaps();
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
    
}

/* ********** */
/*
 MASK> value
 Create a mask based on values in the current image greater than or equal to the specified value. Mask values are 0 or 1.
 
 */

int maskGreater_c(int n,char* args){
    float value = n;
    sscanf(args,"%f",&value);
    int* specs = iBuffer.getspecs();
    for (int r = 0; r < specs[ROWS]; r++) {
        for (int c = 0; c < specs[COLS]; c++) {
            if (iBuffer.getpix(r, c) >= value)
                iBuffer.setpix(r, c, 1.);
            else
                iBuffer.setpix(r, c, 0.);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
    
}

/* ********** */
/*
 MASK< value
 Create a mask based on values in the current image less than the specified value. Mask values are 0 or 1.
 
 */

int maskLess_c(int n,char* args){
    float value = n;
    sscanf(args,"%f",&value);
    int* specs = iBuffer.getspecs();
    for (int r = 0; r < specs[ROWS]; r++) {
        for (int c = 0; c < specs[COLS]; c++) {
            if (iBuffer.getpix(r, c) < value)
                iBuffer.setpix(r, c, 1.);
            else
                iBuffer.setpix(r, c, 0.);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
    
}
/* ********** */
/*
 NAN2ZERO
 Set any nan values to 0.
 
 */

int nan2zero_c(int n,char* args){
    float value = n;
    sscanf(args,"%f",&value);
    int* specs = iBuffer.getspecs();
    for (int r = 0; r < specs[ROWS]; r++) {
        for (int c = 0; c < specs[COLS]; c++) {
            if (isnan(iBuffer.getpix(r, c))) iBuffer.setpix(r, c, 0.);
        }
    }
    free(specs);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
    
}
/* ********** */

float x1_ref,y1_ref,x2_ref,y2_ref,x1_i1,x2_i1,x1_i2,x2_i2,y1_i1,y2_i1,y1_i2,y2_i2;
int	  have_match_stuff = 0;
int   image1_width,image1_height,image2_width,image2_height;

int getmatch_c(int n, char* args)		/* get file matching information from a text file */
{
    int err,loadmatch(char*);
    
    err = loadmatch(args);
    return err;
}

int loadmatch(char* name)
{
    
    FILE *fp;
    int notfound = 0;
    
    // 	fp = fopen(name,"r");
    fp = fopen(fullname(name,GET_DATA),"r");
    
    if( fp != NULL) {
        if( fscanf(fp,"%f %f %f %f %f %f",&x1_ref,&y1_ref,&x1_i1,&y1_i1,
                   &x1_i2,&y1_i2) != 6) notfound = 1;
        if( fscanf(fp,"%f %f %f %f %f %f",&x2_ref,&y2_ref,&x2_i1,&y2_i1,
                   &x2_i2,&y2_i2) != 6) notfound = 1;
        if( fscanf(fp,"%d %d",&image1_width,&image1_height) != 2) notfound = 1;
        if( fscanf(fp,"%d %d",&image2_width,&image2_height) != 2) notfound = 1;
        fclose(fp);
        
        if(notfound == 1) {
            beep();
            printf(" Data Format Problem.\n");
            return(FILE_ERR);
        }
        printf(" Reference point 1 is %.2f %.2f\n",x1_ref,y1_ref);
        printf(" Reference point 2 is %.2f %.2f\n",x2_ref,y2_ref);
        printf(" Image 1 is %d by %d.\n",image1_width,image1_height);
        printf(" Image 1 point 1 is %.2f %.2f\n",x1_i1,y1_i1);
        printf(" Image 1 point 2 is %.2f %.2f\n",x2_i1,y2_i1);
        printf(" Image 2 is %d by %d.\n",image2_width,image2_height);
        printf(" Image 2 point 1 is %.2f %.2f\n",x1_i2,y1_i2);
        printf(" Image 2 point 2 is %.2f %.2f\n",x2_i2,y2_i2);
        have_match_stuff = 1;
        return(NO_ERR);
        
    }
    else {
        beep();
        printf(" File Not Found.\n");
        return(FILE_ERR);
    }
}


/* ********** */

int match_c(int n, char* args)			/* Using the data in the current buffer as one input and
                                         the specified file as the other input, create two new
                                         files that have the same resolution and cover the same
                                         region. The new files will be called Match_1 and Match_2.
                                         Use the file matching parameters previously read in */
{
    extern char txt[];
    extern Point substart,subend;	/* these two points define a data subarray */
    
    char scratch[CHPERLN];
    float ax,ay,tan_th1,th1,tan_th2,th2;
    float x1,x2,scale1,scale2;
    
    int i,j,di1,di2;
    Point i2start,i2end;
    //
    // this version ignores the reference image stuff
    //
    if( !have_match_stuff ) {
        beep();
        printf("Load Matching Parameters First (use 'GETMAT filename').\n");
        return CMND_ERR;
    }
    /* Next check the size of the current image (image 1) */
    
    if( (iBuffer.width() != image1_width) || (iBuffer.height() != image1_height)) {
        beep();
        printf("Current Image is not the right size for Image 1.\n");
        return CMND_ERR;
    }
    
    /* Save the name of image2 -- we will get to that later */
    
    for(i=0; *(args+i) != EOL; i++ ) scratch[i] = args[i];
    scratch[i] = 0;
    
    /* get the rotation angle for image 1 */
    ax = x2_i1 - x1_i1;
    ay = y2_i1 - y1_i1;
    
    // the distance between the points will give the scale factor
    scale1 = sqrt(ax*ax + ay*ay);
    // this is the angle made by the points in image 1
    tan_th1 = ay/ax;
    th1 = atan(tan_th1);
    
    /* get the rotation angle for image 2 */
    ax = x2_i2 - x1_i2;
    ay = y2_i2 - y1_i2;
    
    // the distance between the points will give the scale factor
    scale2 = sqrt(ax*ax + ay*ay);
    // this is the angle made by the points in image 2
    tan_th2 = ay/ax;
    th2 = atan(tan_th2);
    
    if(scale1 > scale2){
        beep();
        printf(" Reverse Image 1 and 2 -- Image 1 must be lower rosolution.\n");
        return CMND_ERR;
    }
    
    printf("Image 1: Scale Factor %.3f; Rotation Angle %.3f\n", scale1, th1);
    printf("Image 2: Scale Factor %.3f; Rotation Angle %.3f\n", scale2, th2);
    
    if( fabs(th1 - th2) < (float)( 0.1/iBuffer.height()) ) {
        printf("No Rotation Needed.\n");
    }
    else {
        /* rotate the image in memory by the difference */
        
        th2 = (th1 - th2);              /* th2 is now the difference angle in radians */
        th1 = 180.0 / PI * th2;		/* th1 is now the difference angle in degrees */
        printf( "Rotate by %f\n", th1);
        
        /*
         keylimit(-1);			// disable printing
         sprintf(cmnd,"%f",th1);
         rotate(1,0);			// go rotate image 1
         keylimit(-2);			// reset printing  to previous mode
         */
        
        iBuffer.rotate(th1);
        
        /* In image 1, the old x1_i1,y1_i1 and x2_i1,y2_i1 no longer correspond
         to the reference points because of the rotation -- find the new points */
        
        x1_i1 = x1_i1 - (image1_width)/2.0;
        y1_i1 = y1_i1 - (image1_height)/2.0;
        /* printf(" moved point 1 is %.2f %.2f\n",x1_i1,y1_i1); */
        
        x1 = x1_i1 * cos(-th2) - y1_i1*sin(-th2);
        x2 = x1_i1 * sin(-th2) + y1_i1*cos(-th2);
        /* printf(" rotated 1 point 1 is %.2f %.2f\n",x1,x2); */
        
        x1_i1 = x1 + (iBuffer.width()-1)/2.0;         // different
        y1_i1 = x2 + (iBuffer.height()-1)/2.0;
        printf(" Final point 1 is %.2f %.2f\n",x1_i1,y1_i1);
        
        x2_i1 -= (image1_width)/2.0;
        y2_i1 -= (image1_height)/2.0;
        x1 = x2_i1 * cos(-th2) - y2_i1*sin(-th2);
        x2 = x2_i1 * sin(-th2) + y2_i1*cos(-th2);
        x2_i1 = x1 + (iBuffer.width()-1)/2.0;
        y2_i1 = x2 + (iBuffer.height()-1)/2.0;
        
        printf(" Final point 2 is %.2f %.2f\n",x2_i1,y2_i1);
        
        image1_width = iBuffer.width();
        image1_height = iBuffer.height();
        
    }
    
    // Scale up Image 1 -- the whole thing
    
    i = image1_width*scale2/scale1+0.5;
    j = image1_height*scale2/scale1+0.5;
    
    printf("New Image 1 size: %d by %d\n",i,j);
    
    /*
     keylimit(-1);			// disable printing
     sprintf(cmnd,"%d %d",i,j);
     maknew(1,0);                    // make larger image 1
     keylimit(-2);			// reset printing  to previous mode
     */
    iBuffer.resize(j, i);
    
    printf("New Image 1 size: %d by %d\n",image1_width,image1_height);
    
    x1_i1 -= (image1_width-1)/2.0;
    y1_i1 -= (image1_height-1)/2.0;
    
    x1 = x1_i1 * scale2/scale1;
    x2 = y1_i1 * scale2/scale1;
    
    x1_i1 = x1 + (iBuffer.width()-1)/2.0;
    y1_i1 = x2 + (iBuffer.height()-1)/2.0;
    printf(" Final point 1 is %.2f %.2f\n",x1_i1,y1_i1);
    
    x2_i1 -= (image1_width-1)/2.0;
    y2_i1 -= (image1_height-1)/2.0;
    x1 = x2_i1 * scale2/scale1;
    x2 = y2_i1 * scale2/scale1;
    x2_i1 = x1 + (iBuffer.width()-1)/2.0;
    y2_i1 = x2 + (iBuffer.height()-1)/2.0;
    
    printf(" Final point 2 is %.2f %.2f\n",x2_i1,y2_i1);
    
    image1_width = iBuffer.width();
    image1_height = iBuffer.height();
    
    /* For Image 1, find the cropping coords */
    // use the average of the two points as a position reference
    
    x1_i1 = (x1_i1 + x2_i1)/ 2.0;
    y1_i1 = (y1_i1 + y2_i1)/ 2.0;
    x1_i2 = (x1_i2 + x2_i2)/ 2.0;
    y1_i2 = (y1_i2 + y2_i2)/ 2.0;
    
    substart.h = x1_i1 - x1_i2 + 0.5;
    if(substart.h <= 0) {
        i2start.h = -substart.h;    // crop left of image 2
        substart.h = 0;
    } else {
        i2start.h = 0;              // crop left of image 1; not image2
    }
    substart.v = y1_i1 - y1_i2  + 0.5;
    if(substart.v <= 0) {
        i2start.v = -substart.v;    // crop top of image 2
        substart.v = 0;
    } else {
        i2start.v = 0;              // crop top of image 1; not image2
    }
    
    di1 = image1_width - 1 - x1_i1 + 0.5;  // the distance to the end of image 1
    di2 = image2_width - 1 - x1_i2 + 0.5;  // the distance to the end of image 2
    
    printf(" x1 x2 %.2f %.2f\n",x1,x2);
    
    if(di2 >= di1) {
        subend.h = image1_width - 1;  // keep all of image 1
        i2end.h =  i2start.h + subend.h - substart.h;
    } else {
        i2end.h =  image2_width - 1;  // keep all of image 2
        subend.h = substart.h + i2end.h - i2start.h;
    }
    
    di1 = image1_height - 1 - y1_i1 + 0.5;  // the distance to the end of image 1
    di2 = image2_height - 1 - y1_i2 + 0.5;  // the distance to the end of image 2
    
    if(di2 >= di1) {
        subend.v = image1_height-1;  // keep all of image 1
        i2end.v =  i2start.v + subend.v - substart.v;
    } else {
        i2end.v =  image2_height - 1;  // keep all of image 2
        subend.v = substart.v + i2end.v - i2start.v;
    }
    
    /* save the cropped image in a temp file */
    
    strcpy(txt,"Match_1");
    /*
     saverectangle(fullname(txt,SAVE_DATA));
     setdata(txt);
     fileflush(txt);	// for updating directory
     */
    rect cropRect = {{substart.h,substart.v},{subend.h,subend.v}};
    iBuffer.crop(cropRect);
    iBuffer.getmaxx(PRINT_RESULT);
    iBuffer.saveFile(fullname(txt,SAVE_DATA), LONG_NAME);
    
    printf("Image 1 cropped to %d %d %d %d.\n",substart.h,substart.v,subend.h,subend.v);
    
    
    /* Now work with image 2 */
    
    /* Open Image 2 */
    
    strcpy(txt,scratch);
    /*
     fullname(txt,GET_DATA);
     getfile (0,-1);			// get the file
     keylimit(-2);			// reset printing  to previous mode
     */
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        beep();
        printf("Could not load %s\n",args);
        return new_im.err();
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is image2
    
    /* For Image 2, find the cropping coords */
    
    substart = i2start;
    subend = i2end;
    
    /* save the cropped image in a temp file */
    
    strcpy(txt,"Match_2");
    
    /*
     saverectangle(fullname(txt,SAVE_DATA));
     setdata(txt);
     fileflush(txt);	// for updating directory
     */
    
    rect cropRect2 = {{substart.h,substart.v},{subend.h,subend.v}};
    iBuffer.crop(cropRect2);
    iBuffer.getmaxx(PRINT_RESULT);
    iBuffer.saveFile(fullname(txt,SAVE_DATA), LONG_NAME);
    
    update_UI();
    
    
    printf("Image 2 cropped to %d %d %d %d.\n",substart.h,substart.v,subend.h,subend.v);
    
    /* must read parameters in before each match since we have changed things */
    have_match_stuff = 0;
    return 0;
}

/* ********** */

float a00,a01,a10,a11;
float b00,b01,b10,b11;
int warp_parameters_defined = 0;

int warpar_c(int n, char* args)		// get image warping information from a text file
{
    
    int err;
    
    err = loadwarp(args);
    return err;
}

int loadwarp(char* name)
{
    FILE *fp;
    int notfound = 0;
    
    fp = fopen(fullname(name,GET_DATA),"r");
    
    if( fp != NULL) {
        if( fscanf(fp,"%f %f %f %f\n",&a00,&a01,&a10,&a11) != 4) notfound = 1;
        if( fscanf(fp,"%f %f %f %f\n",&b00,&b01,&b10,&b11) != 4) notfound = 1;
        fclose(fp);
        
        if(notfound == 1) {
            beep();
            printf(" Data Format Problem.\n");
            return(FILE_ERR);
        }
        printf(" a parameters: %f   %f   %f",a00,a01,a10);
        printf("   %f\n",a11);
        printf(" b parameters: %f   %f   %f",b00,b01,b10);
        printf("   %f\n",b11);
        warp_parameters_defined = 1;
        return(NO_ERR);
        
    }
    else {
        beep();
        printf(" File Not Found.\n");
        return(FILE_ERR);
    }
}


/* ********** */

/**************************************************************************************/
/*
 x’ = a00 + a01x + a10y + a11xy
 y’ = b00 + b01x + b10y + b11xy
 */
// warp the image according to parameters specified  with the WARPAR command
int warp_c(int n,char* args)
{
    int i,j,chan2,track2,ix,iy;
    DATAWORD *datp2;
    float xi,yi,x,y;
    float xmax,xmin,ymax,ymin,fx,fy,pixval,subpix=0.2;
    
    
    extern int	dlen,dhi;
    
    if(!warp_parameters_defined){
        beep();
        printf("Parameters Not Defined -- Use 'WARPAR filename' first.\n");
        return CMND_ERR;
    }
    
    xmax = ymax = 0;
    xmin = dlen;
    ymin = dhi;
    
    if(*args) sscanf(args,"%f",&subpix);
    
    printf("Subpixel resolution: %.2f\n", subpix);
    // get the size of the new image
    // look along top row
    y = 0;
    for(x=0; x<iBuffer.width(); x+= subpix){
        xi = xwarp(x,y);
        yi = ywarp(x,y);
        if(xi > xmax) xmax = xi;
        if(xi < xmin) xmin = xi;
        if(yi > ymax) ymax = yi;
        if(yi < ymin) ymin = yi;
        
    }
    // look along bottom row
    y = iBuffer.height()-1;
    for(x=0; x<iBuffer.width(); x+= subpix){
        xi = xwarp(x,y);
        yi = ywarp(x,y);
        if(xi > xmax) xmax = xi;
        if(xi < xmin) xmin = xi;
        if(yi > ymax) ymax = yi;
        if(yi < ymin) ymin = yi;
        
    }
    // look along left column
    x = 0;
    for(y=0; y<iBuffer.height(); y+= subpix){
        xi = xwarp(x,y);
        yi = ywarp(x,y);
        if(xi > xmax) xmax = xi;
        if(xi < xmin) xmin = xi;
        if(yi > ymax) ymax = yi;
        if(yi < ymin) ymin = yi;
        
    }
    // look along right column
    x = iBuffer.width()-1;
    for(y=0; y<iBuffer.height(); y+= subpix){
        xi = xwarp(x,y);
        yi = ywarp(x,y);
        if(xi > xmax) xmax = xi;
        if(xi < xmin) xmin = xi;
        if(yi > ymax) ymax = yi;
        if(yi < ymin) ymin = yi;
        
    }
    printf("xmin: %.2f  xmax: %.2f\n", xmin,xmax);
    printf("ymin: %.2f  ymax: %.2f\n", ymin,ymax);
    
    track2 = ymax - ymin + 1.5;
    chan2 = xmax - xmin + 1.5;
    
    Image warpedImage;
    warpedImage.copyABD(iBuffer);
    warpedImage.resize(track2,chan2);
    if (warpedImage.err()) {
        beep();
        printf("Could not create warped image.\n");
        return warpedImage.err();
    }
    datp2 = warpedImage.data;
    
    /*
     //datp = malloc(size);
     datp = calloc(size,1);
     if(datp == 0) {
     nomemory();
     return -1;
     }
     datp2 = datp + doffset;
     */
    
    for( y=0; y<iBuffer.height(); y += subpix) {
        for( x=0; x<iBuffer.width(); x += subpix) {
            i = x;
            j = y;
            pixval = iBuffer.getpix(j,i);  //idat(j,i);
            xi = xwarp(x,y);
            yi = ywarp(x,y);
            ix = xi;
            iy = yi;
            //coordinates of pixel in the new image
            
            //put the intensity from this pixel into the (up to 4) pixels that this pixel covers
            fx = xi - ix;   // the fractions
            fy = yi - iy;
            //
            // remap origin to 0,0
            xi -= xmin;
            yi -= ymin;
            ix = xi;
            iy = yi;
            // this pixel
            *(datp2+ix+iy*chan2) += pixval * (1.0 - fx) * (1.0 - fy);
            // pixel to the right
            *(datp2+ix+1+iy*chan2) += pixval * (fx) * (1.0 - fy);
            // pixel above
            *(datp2+ix+(iy+1)*chan2) += pixval * (1.0 - fx) * (fy);
            // pixel diagonally across
            *(datp2+ix+1+(iy+1)*chan2) += pixval * (fx) * (fy);
            /*if(i == 100) {
             printf("%d %d\n",i,j);
             printf("%d %d\n",ix,iy);
             printf("%f %f\n",fx,fy);
             printf("%f %f\n\n",xi,yi);
             
             }*/
        }
    }
    iBuffer.free();
    iBuffer =  warpedImage;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

float xwarp(float x, float y)
{
    float xi;
    xi = a00 + a01*x + a10*y + a11 * x * y;
    return xi;
}
float ywarp(float x, float y)
{
    float yi;
    yi = b00 + b01*x + b10*y + b11 * x * y;
    return yi;
}

/* ********** */
/*
 SNR gsmoothx gsmoothy aveSize
 Calculate the signal/noise ratio of the image by first gaussian smoothing the image by the specified amount, then dividing the smoothed image by the original unsmoothed image. The SNR is taken to be the rms deviation calculated over an aveSize x aveSize area (the average is assumed to be 1)centered on each pixel.
 
 */
int snr_c(int n, char* args){
    int gsx,gsy,aveSize,err,r,c,i,j;
    float ave;
    int nargs = sscanf(args, "%d %d %d",&gsx,&gsy,&aveSize);
    if(nargs != 3){
        beep();
        printf("Need three arguments: gsmoothx, gsmoothy, aveSize");
        return CMND_ERR;
    }
    // make a copy of this image
    Image original;
    original << iBuffer;
    
    // gradient smooth according to the first two arguments
    err = gsmooth_c(0, args);
    if(err) return err; // there was a problem with gsmooth
    // iBuffer is the smoothed image
    
    // with no noise, this should be 1
    iBuffer/original;
    
    original.zero();
    aveSize /=2;
    int nsum = (2*aveSize+1)*(2*aveSize+1);
    int height = iBuffer.height();
    if (iBuffer.isColor()) {
        height *=3;
    }
    for(r = aveSize; r < height-aveSize; r++){
        for(c = aveSize; c < iBuffer.width()-aveSize; c++){
            ave = 0;
            for(i = -aveSize; i<aveSize; i++){
                for(j = -aveSize; j<aveSize; j++){
                    ave += pow(iBuffer.getpix(r+i, c+j)-1.,2);
                }
            }
            original.setpix(r, c, 1./sqrt(ave/nsum));
        }
    }
    iBuffer.free();
    iBuffer = original;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
    
}

/* ************************* */

// noise generating functions---------
/*	NOISE mean rms seed
 uniform deviate generator with using built-in random-number
 generator */


int noise_c(int n,char* args)
{
    unsigned int seed = 0;
    float x;
    float mean=0, rms = 1;
    int nt,nc;
    
    // Get the arguments
    sscanf(args,"%f %f %d",&mean,&rms,&seed);
    printf(" Mean: %.2f, rms: %.2f, seed %d\n",mean,rms,seed);
    
    srand(seed);
    rms *= 1.75;
    int height = iBuffer.height();
    if (iBuffer.isColor()) {
        height *=3;
    }
    for(nt=0; nt<height; nt++) {
        for(nc=0; nc<iBuffer.width();nc++){
            x = rand();
            x = (x/RAND_MAX*2.0 -1.0)*rms;
            iBuffer.setpix(nt,nc,mean + x);
        }
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

/* ************************* */

// gaussian noise
//	GNOISE mean rms seed
// gaussian deviate generator using built-in random-number
// generator followed by Box-Muller transform

int gnoise_c(int n,char* args)
{
    unsigned int seed = 0;
    float x;
    float mean=0, rms = 1;
    int nt,nc;
    
    // Get the arguments
    sscanf(args,"%f %f %d",&mean,&rms,&seed);
    printf(" Mean: %.2f, rms: %.2f, seed %d\n",mean,rms,seed);
    
    srand(seed);
    int height = iBuffer.height();
    if (iBuffer.isColor()) {
        height *=3;
    }
    for(nt=0; nt<height; nt++) {
        for(nc=0; nc<iBuffer.width();nc++){
            x = ranfGauss();
            iBuffer.setpix(nt,nc,(x*rms+mean));
        }
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
    
}
// gaussian deviate generator.  source: "Numerical Recipes in C", W.H. Press
float ranfGauss()
{
    static int iset = 0;
    static float gset;
    float fac, rsq, v1, v2;
    
    if (iset==0) {
        do {
            v1 = (float)rand()/(float)(RAND_MAX);
            v2 = (float)rand()/(float)(RAND_MAX);
            v1 = 2.0*v1-1.0;
            v2 = 2.0*v2-1.0;
            rsq = v1*v1+v2*v2;
        } while (rsq>=1.0 || rsq==0.0);
        
        fac = sqrt(-2.0*log(rsq)/rsq);
        gset = v1*fac;
        iset = 1;
        //test = v2*fac;
        return v2*fac;
        
    } else {
        iset = 0;
        //test = gset;
        return gset;
    }
}

/* ************************* */

/*
 // shot noise
 SHOTNOISE seed
 Treat the data as counts and add random root N noise to the data
 
 */
int shotnoise_c(int n,char* args)
{
    unsigned int seed=0;
    float x;
    int nt,nc;
    
    // Get the arguments
    
    // Get the arguments
    sscanf(args,"%d",&seed);
    
    srand(seed);
    
    int height = iBuffer.height();
    if (iBuffer.isColor()) {
        height *=3;
    }
    for(nt=0; nt<height; nt++) {
        for(nc=0; nc<iBuffer.width();nc++){
            x = iBuffer.getpix(nt,nc);
            x += ((float)rand()/(float)RAND_MAX-.5)*sqrtf(x);
            iBuffer.setpix(nt,nc,x);
        }
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/*----------------------------------------------------------------*/

int demosaic_c(int n,char* args){
    int redx = 0,redy = 0, method = 0;
    sscanf(args,"%d %d %d",&redx,&redy,&method);
    if((redx == 0 || redx == 1) && (redy == 0 || redy == 1)){
        printf("First red pixel is at %d %d\n",redx,redy);
    } else {
        redx = redy = 0;
        beep();
        printf("redX and redY must be 0 or 1... \nUsing default values.\nFirst red pixel is at %d %d\n",redx,redy);
    }
    switch (method) {
        case MALVAR:
            printf("Using Malvar algorithm.\n");
            break;
            
        default:
            printf("Using bilinear algorithm.\n");
            break;
    }
    
    
    int* bufferspecs = iBuffer.getspecs();
    Image newIm(bufferspecs[ROWS]*3,bufferspecs[COLS]);
    
    if(newIm.err()){
        return newIm.err();
    }
    newIm.copyABD(iBuffer);
    bufferspecs[ROWS] *=3;
    bufferspecs[IS_COLOR] = 1;
    newIm.setspecs(bufferspecs);
    newIm.demosaic(iBuffer, redx, redy, method);
    
    free(bufferspecs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}

/* ************************* */


int decodeHobj_c(int n,char* args)
{
    int height = iBuffer.height();
    int width = iBuffer.width();
    
    if (iBuffer.isColor()) {
        height *=3;
    }
    decodeHobj(&iBuffer,width, height);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

void decodeHobj(Image* theImage,int width, int height){
    int nt,nc,tweak;
    unsigned int x0,x1;
    
    for(nt=0; nt<height; nt++) {
        for(nc=0; nc<width;nc++){
            // check for crossed a 256 boundary
            /*
             // This bounds checking is not required because of the way the getpix method works
             int dec = 1;
             int inc = 1;
             if (nc == 0) dec = 0;
             if (nc == width-1) inc = 0;
             x0 = iBuffer.getpix(nt,nc-dec);
             x1 = iBuffer.getpix(nt,nc+inc);
             */
            x0 = theImage->getpix(nt,nc-1);
            x1 = theImage->getpix(nt,nc+1);
            x1/=256;
            x0/=256;
            if(x1 != x0){
                // we crossed a boundary
                tweak = 256*(x1-x0);
                theImage->setpix(nt,nc,theImage->getpix(nt,nc)+tweak);
            }
        }
    }
    
}

/* ************************* */


int hobjSettings_c(int n,char* args)
{
    // default values
    int decode = 1;
    int demosaic = 0;
    int clearBad = 0;
    
    int nargs = sscanf(args,"%d %d %d",&decode,&demosaic,&clearBad);
    printf("Settings for .hobj files are:\n");
    if(nargs <= 0){
        if (UIData.decodeHobjFlag){
            printf("Automatic decoding.\n");
            switch (UIData.demosaicHobjFlag) {
                case HOBJ_DOC2RGB:
                    
                    printf("Demosaic using DOC2RGB 0 1 1 2\n");
                    break;
                case HOBJ_BILINEAR:
                    printf("Demosaic using BILINEAR,  Red Pixel at 0,0\n");
                    break;
                case HOBJ_MALVAR:
                    printf("Demosaic using MALVAR,  Red Pixel at 0,0\n");
                    break;
                case HOBJ_NO_DEMOSAIC:
                default:
                    printf("No demosaicing.\n");
                    break;
            }
            if (UIData.clearHobjFlag)
                printf("Automatically clear bad pixels.\n");
            else
                printf("No clearing bad pixels.\n");
            return NO_ERR;
        } else {
            printf("No automatic decoding.\n");
            return NO_ERR;
        }
    }
    UIData.decodeHobjFlag = decode;
    
    if(UIData.decodeHobjFlag){
        printf("Automatic decoding.\n");
        switch (demosaic) {
            case 1:
                UIData.demosaicHobjFlag = HOBJ_DOC2RGB;
                printf("Demosaic using DOC2RGB 0 1 1 2\n");
                break;
            case 2:
                UIData.demosaicHobjFlag = HOBJ_BILINEAR;
                printf("Demosaic using BILINEAR,  Red Pixel at 0,0\n");
                break;
            case 3:
                UIData.demosaicHobjFlag = HOBJ_MALVAR;
                printf("Demosaic using MALVAR,  Red Pixel at 0,0\n");
                break;
            case 0:
            default:
                UIData.demosaicHobjFlag = HOBJ_NO_DEMOSAIC;
                printf("No demosaicing.\n");
                break;
        }
    }else{
        printf("No automatic decoding.\n");
    }
    UIData.clearHobjFlag = clearBad;
    if (UIData.clearHobjFlag && UIData.decodeHobjFlag)
        printf("Automatically clear bad pixels.\n");
    else
        printf("No clearing bad pixels.\n");
    
    
    return NO_ERR;
}

/* ************************* */


int say_c(int n,char* args)
{
    alertSound(args);
    return NO_ERR;
}

/* ***************** */

/* Scatter Plot from first and second half of current image */
/* Size of scatter plot is specified */
/* bin size is determined by the min and max values of each half */

int scatter_c(int n, char* args)
{
    int sizx,sizy,binx,biny,i,j;
    DATAWORD xmin,xmax,ymin,ymax;
    float binsizex,binsizey,x,y;
    
    int halfHeight = iBuffer.height()/2;
    rect topRect={{0,0},{iBuffer.width()-1,halfHeight-1}};
    rect bottomRect={{0,halfHeight},{iBuffer.width()-1,halfHeight*2-1}};
    
    // get default values in case no arguments are given
    sizx = 250;
    sizy = 250;
    
    Image copy;
    copy << iBuffer;
    copy.crop(topRect);
    xmin = copy.min();
    xmax = copy.max();
    
    copy << iBuffer;
    copy.crop(bottomRect);
    ymin = copy.min();
    ymax = copy.max();
    copy.free();
    
    if( sscanf(args,"%d %d %f %f %f %f",&sizx,&sizy,&xmin,&xmax,&ymin,&ymax) != 6) {
        printf("Using xmin xmax of %g\t%g;  ymin ymax of %g\t%g\n",xmin,xmax,ymin,ymax);
    }
    printf("%d x %d Scatter Plot.\n",sizx,sizy);
    Image newIm(sizy,sizx);
    if(newIm.err()){
        return newIm.err();
    }
    newIm.zero();
    binsizex = (xmax - xmin)/sizx;
    binsizey = (ymax - ymin)/sizy;
    
    if( binsizex <= 0.) {
        binsizex = 1.0;
        beep();
        printf("Possible bin size error.\nX Bin size set to 1.\n");
    }
    if( binsizey <= 0.) {
        binsizey = 1.0;
        beep();
        printf("Possible bin size error.\nY Bin size set to 1.\n");
    }
    
    printf("%.2f x bin %.2f  y bin\n %d points.\n",binsizex,binsizey,halfHeight*iBuffer.width());
    for(i=0; i <halfHeight; i++){
        for(j=0; j<iBuffer.width();j++){
            x = (iBuffer.getpix(i, j) - xmin)/binsizex;
            binx = x+.5;
            y = (iBuffer.getpix(i+halfHeight, j) - ymin)/binsizey;
            biny = y+.5;
            newIm.setpix(biny,binx,newIm.getpix(biny,binx)+1);
        }
    }
    newIm.invert();
    newIm.mirror();     // make so y increases from bottom to top
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}

/* ************************* */

/*
 REMAP Value1 Value2 [Value3]
 With two arguments, every occurence of Value1 in the current image is replaced with Value2. With three arguments, values in the range from Value1 to Value2 are set to Value3.
 */

int remap_c(int n, char* args)
{
    DATAWORD v1,v2,v3;
    int narg = sscanf(args,"%f %f %f",&v1,&v2,&v3);
    if( narg < 2) {
        beep();
        printf("At least two arguments are required.\n");
        return CMND_ERR;
    }else if (narg == 2){
        for (int r = 0; r < iBuffer.rows(); r++) {
            for (int c = 0; c < iBuffer.cols(); c++) {
                if (iBuffer.getpix(r,c) == v1) iBuffer.setpix(r,c,v2);
            }
        }
    }else{
        for (int r = 0; r < iBuffer.rows(); r++) {
            for (int c = 0; c < iBuffer.cols(); c++) {
                if (iBuffer.getpix(r,c) >= v1 && iBuffer.getpix(r,c) <= v2) iBuffer.setpix(r,c,v3);
            }
        }
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ************************* */

/*
 BLEED thresholdCount fraction
 For correcting readout errors on a CCD detector, where intensity from one pixel bleeds into an adjacent pixel on readout. No correction is made when the value is less than thresholdCount. For a pixel with pixValue greater than thresholdCount, pixValue is increased by  (pixValue-thresholdCount)*fraction. The pixel in the next column is decreased by the same amount.
 */

int bleed_c(int n, char* args)
{
    DATAWORD thresholdCount,fraction,correction,pixValue;
    int narg = sscanf(args,"%f %f",&thresholdCount,&fraction);
    if( narg < 2) {
        beep();
        printf("Two arguments are required: thresholdCount fraction.\n");
        return CMND_ERR;
    }
    for (int r = 0; r < iBuffer.rows(); r++) {
        for (int c = 0; c < iBuffer.cols()-1; c++) {
            if ((pixValue=iBuffer.getpix(r,c)) >= thresholdCount) {
                correction=(pixValue-thresholdCount)*fraction;
                iBuffer.setpix(r,c,pixValue+correction);
                iBuffer.setpix(r,c+1,iBuffer.getpix(r,c+1)-correction);
            }
        }
    }

    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ************************* */

/*
 C2RGB
 If the current image is a color image, define temporary images named r, g, and b that correspond to the red, green, and blue color channels. The current image buffer is not modified.
 */

int c2rgb_c(int n, char* args)
{
    
    if(!iBuffer.isColor()){
        beep();
        printf("Current image is not a color image.\n");
        return CMND_ERR;
    }
    // copy of the current color image
    Image copy;
    
    // get each component
    copy << iBuffer;
    copy.rgb2color(0);
    n = temp_image_index((char*)"r",1);
    if(n >=0){
        iTempImages[n] << copy;
    } else {
        return MEM_ERR;
    }
    
    copy << iBuffer;
    copy.rgb2color(1);
    n = temp_image_index((char*)"g",1);
    if(n >=0){
        iTempImages[n] << copy;
    } else {
        return MEM_ERR;
    }

    copy << iBuffer;
    copy.rgb2color(2);
    n = temp_image_index((char*)"b",1);
    if(n >=0){
        iTempImages[n] << copy;
    } else {
        return MEM_ERR;
    }
    copy.free();
    update_UI();
    return NO_ERR;
}

/* ************************* */

/*
 ABELCLEAN X
 Try to clean up Abel inverted images.
 Calculate average horizontal gradient magnitude
 If a single line is more than X times greater than the average, replace it with the
 average of the tracks above and below.
 
 */
/*
int abelClean_c(int n, char* args)
{
    float overfactor = 3.0;
    float ave = 0.,grad,imageave=0;
    float *line_grad;
    int nt,nc,i;
    DATAWORD *pt;
    
    int narg = sscanf(args,"%f",&overfactor);
    line_grad = new float[iBuffer.height()+iBuffer.isColor()*2*iBuffer.height()];
    
    for(nt=0; nt< header[NTRAK]; nt++){
        ave = 0;
        for(nc=1; nc<header[NCHAN]; nc++) {
            grad = idat(nt,nc) - idat(nt,nc-1);
            ave += grad*grad;
        }
        line_grad[nt] = ave/nc;
        imageave += ave/nc;
    }
    imageave /= nt;
    pt = datpt + doffset;
    
    for(nt=1; nt< header[NTRAK]-1; nt++){
        if(line_grad[nt] > imageave*overfactor){
            for(nc=0; nc<header[NCHAN]; nc++) {
                *(pt+nc +header[NCHAN]*nt) = (idat(nt-1,nc) + idat(nt+1,nc))/2;
            }
        }
    }
    
    free(line_grad);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;

}
 */


/* ************************* */

int getVariableError(char* name, float*);
float getMaxDiff(float dataArray[], int numPoints,float *average);
/*
 mfc1Range = 20;     %SLPM N2 full scale (coflow)
 %mfc2Range = 0.1;     %SLPM N2 full scale (N2 diluent)
 fuelRange = 0.1;     %SLPM N2 full scale (fuel mixture)
 
 mfc1CorrectionFactor = 0.995276533; % air from Zin spreadsheet tables
 mfc2CorrectionFactor = 1; % N2
 
 % this is for conversion from volts to SLPM
 slpmConversion = [mfc1Range mfc2Range fuelRange] / 5 ...
 .* [mfc1CorrectionFactor mfc2CorrectionFactor fuelCorrectionFactor];
 
 % the following are for conversion from SLPM to velocity
 tempCoefficient = 0.92546163; % SLPM to room temp from Zin spreadsheet tables
 burnerArea = 3.66096154E-06; % from Zin spreadsheet tables
 coflowArea = 4.86050E-04; % from Zin spreadsheet tables
 areaFactor = [coflowArea burnerArea burnerArea];
 
 char name[256]={"/Volumes/ACME/flight/18043/18043B1/18043B1_ACME/20180212_171558.773_ACME_18043B1_00454.hobj"};
 
 v(:,:) = m(:,:).*slpmConversion/tempCoefficient/600 ./ areaFactor;
 */

/*
 ACMEVELOCITY telemetryFileName
 For ACME color data camera images, this returns values for the velocities of the
 coflow, N2, and fuel, along with their relative MAXIMUM deviations. The data for this
 is based on the timestamp in the image file name and data in the telemetry file. The command requires
 the following variables to be defined beforehand:
 mfc2Range
 fuelCorrection
 exposure
 name
 */

//the coefficient of variation (CV), also known as relative standard deviation (RSD)

int acmevelocity_c(int n, char* filename){
    // declarations and initializations
    int  i,j,k,l,fileRow=2;
    FILE *inputFile;    // the file pointer variable
    char longString[2048],time[32],time2[32],c;
    float exposure,mfc1Range=20,mfc2Range,mfc3Range,fuelCorrection;
    mfc1Range = 20;     //SLPM N2 full scale (coflow)
    //mfc3Range = 0.1;     //SLPM N2 full scale (fuel mixture)
    float mfc1CorrectionFactor = 0.995276533; // air from Zin spreadsheet tables
    float mfc2CorrectionFactor = 1;     // N2
    float tempCoefficient = 0.92546163; // SLPM to room temp from Zin spreadsheet tables
    float burnerArea = 3.66096154E-06;  // from Zin spreadsheet tables
    float coflowArea = 4.86050E-04;     // from Zin spreadsheet tables
    
    extern Variable user_variables[];
    
    // get necessary values
    
    if(getVariableError((char*)"mfc2Range", &mfc2Range)) return ARG_ERR;
    if(getVariableError((char*)"mfc3Range", &mfc3Range)) return ARG_ERR;
    if(getVariableError((char*)"exposure", &exposure)) return ARG_ERR;
    if(getVariableError((char*)"fuelCorrection", &fuelCorrection)) return ARG_ERR;
    int index = get_variable_index((char*)"name", 0);
    if(index<0){
        beep();
        printf("Variable 'name' must be defined\n");
        return ARG_ERR;
    }
    
    //for(i=(int)strlen(name)-1; name[i] != '/' ; i--);
    //i+=10;
    double tFile,tData;
    sscanf(&user_variables[index].estring[9],"%lf",&tFile);
    printf("Time File: %lf\n",tFile);
    
    inputFile = fopen(fullname(filename,GET_DATA_NO_SUFFIX),"r");    // read from this file
    
    if(inputFile == NULL){
        beep();
        printf("Can't open file %s.\n",filename);
        return FILE_ERR;
    }
    
    // skip first two lines;
    while(fgetc(inputFile) != '\n');
    while(fgetc(inputFile) != '\n');
    // now skip past times before when this data was taken
    do{
        for(l=0; (c=fgetc(inputFile)) != '\n';l++){     // read a row, replacing commas with spaces
            if(c == ',')
                longString[l]=' ';
            else
                longString[l]=c;
        }
        sscanf(longString,"%s\n",time );
        //remove : from time stamps
        for(i=0,j=0,k=0; i<(int)strlen(time); i++){
            if(time[i] != ':'){
                time2[j++]=time[i];  //it's a number
            } else {
                k++;
            }
            if(k==3){
                time2[j++]='.';
                k=0;
            }
        }
        time2[j]=0;
        sscanf(time2,"%lf",&tData);
        //printf("Time Data: %lf\n",tData);
        //printf("%d characters: %s %s %f.\n",i,time,time2, x);
        fileRow++;
    } while (tData < tFile);
    printf("Image begins in telemetry row %d. Time: %lf\n",fileRow, tData);
    int numRows = exposure/8.+1;
    printf("Integrate over %d rows.\n",numRows);
    float *mfc1,*mfc2,*mfc3,*pta2,*pta3;
    
    mfc1 = new float[numRows];
    mfc2 = new float[numRows];
    mfc3 = new float[numRows];
    pta2 = new float[numRows];
    pta3 = new float[numRows];
    float ignore;
    
    for(int nr = 0; nr < numRows; nr++){
        for(l=0; (c=fgetc(inputFile)) != '\n';l++){     // read a row, replacing commas with spaces
            if(c == ',')
                longString[l]=' ';
            else
                longString[l]=c;
            if(c==EOF)break;
        }
        sscanf(longString,"%s %f %f %f %f %f %f %f",time,&mfc1[nr], &mfc2[nr],&mfc3[nr],
               &ignore,&ignore,&pta2[nr],&pta3[nr]);
        
        mfc1[nr]*=mfc1Range/5*mfc1CorrectionFactor/tempCoefficient/600/coflowArea;
        mfc2[nr]*=mfc2Range/5*mfc2CorrectionFactor/tempCoefficient/600/burnerArea;
        mfc3[nr]*=mfc3Range/5*fuelCorrection/tempCoefficient/600/burnerArea;
        //printf("Time: %s MFC voltages: %f %f %f\n",time,mfc1[nr], mfc2[nr],mfc3[nr]);
    }
    float coflowAveVel,fuelAveVel,n2AveVel,pta2Ave,pta3Ave;
    float coflowMaxDiff = getMaxDiff(mfc1,numRows,&coflowAveVel);
    float n2MaxDiff = getMaxDiff(mfc2,numRows,&n2AveVel);
    float fuelMaxDiff = getMaxDiff(mfc3,numRows,&fuelAveVel);
    ignore = getMaxDiff(pta2,numRows,&pta2Ave);
    ignore = getMaxDiff(pta3,numRows,&pta3Ave);
    float atm = ((pta2Ave+pta3Ave)/2. - 0.5) * 14.5038*10/4/14.69595;
    
    user_variables[0].fvalue = coflowAveVel;
    user_variables[0].is_float=1;
    user_variables[1].fvalue = coflowMaxDiff/coflowAveVel*100;
    user_variables[1].is_float=1;
    user_variables[2].fvalue = n2AveVel;
    user_variables[2].is_float=1;
    user_variables[3].fvalue = n2MaxDiff/coflowAveVel*100;
    user_variables[3].is_float=1;
    user_variables[4].fvalue = fuelAveVel;
    user_variables[4].is_float=1;
    user_variables[5].fvalue = fuelMaxDiff/coflowAveVel*100;
    user_variables[5].is_float=1;
    user_variables[6].ivalue = numRows;
    user_variables[6].is_float=0;
    user_variables[7].fvalue = atm;
    user_variables[7].is_float=1;
    
    
    sprintf(time,"1 %f",exposure);
    extra_c(1,time);
    sprintf(time,"2 %f",mfc2Range);
    extra_c(2,time);
    sprintf(time,"3 %f",fuelCorrection);
    extra_c(3,time);
    sprintf(time,"4 %f",coflowAveVel);
    extra_c(4,time);
    sprintf(time,"5 %f",coflowMaxDiff/coflowAveVel*100);
    extra_c(5,time);
    sprintf(time,"6 %f",n2AveVel);
    extra_c(6,time);
    sprintf(time,"7 %f",n2MaxDiff/coflowAveVel*100);
    extra_c(7,time);
    sprintf(time,"8 %f",fuelAveVel);
    extra_c(8,time);
    sprintf(time,"9 %f",fuelMaxDiff/coflowAveVel*100);
    extra_c(9,time);
    sprintf(time,"10 %f",atm);
    extra_c(9,time);
    
    delete[] mfc1;
    delete[] mfc2;
    delete[] mfc3;
    delete[] pta2;
    delete[] pta3;
    fclose(inputFile);
    return 0;
}

float getMaxDiff(float dataArray[], int numPoints,float *average){
    
    int i;
    // get average
    float max,min,sum;
    sum = max = min = dataArray[0];
    for(i=1; i < numPoints; i++ ){
        sum += dataArray[i];
        if(dataArray[i] > max ) max = dataArray[i];
        if(dataArray[i] < min ) min = dataArray[i];
    }
    *average = sum/numPoints;
    return max-min;
}

int getVariableError(char* name, float* value){
    extern Variable user_variables[];
    
    int index = get_variable_index(name, 0);
    if(index<0){
        beep();
        printf("Variable %s must be defined\n",name);
        return ARG_ERR;
    }
    *value = user_variables[index].fvalue;
    return NO_ERR;
}

/* ************************* */


/*
 FOLD fraction new_width
 Fold an image in half vertically. It is assumed to be symmetric about some nearly verticle axis.
 The center of symmetry is found separately for each row, except if there are dark regions at the top and bottom of the image.
 For the dark regions, the average center of the middle part of the image is used as the center of symmetry.
 Dark regions are rows (at the top and bottom) whose values are all less than fraction*image_max. x0,y0 and x1,y1 are coordinates of the top and bottom of the dark region, center is the average center. These are returned in command_return_1-5.
 */

int fold_c(int n, char* args){
    DATAWORD datval,max_fraction=0.,max_val = 0.;
    int y1,y0,sizx,sizy,new_width,center,x0,x1;
    int nt,nc;
    double xcom=0.,ave=0.,ave_xcom=0.;
    
    extern Variable user_variables[];

    nc = sscanf(args,"%f %d",&max_fraction, &new_width);
    if (nc < 2){
        beep();
        printf("Command format is FOLD fraction new_width\n");
        return CMND_ERR;
    }
    
    Image new_im(iBuffer.rows(),new_width);
    if(new_im.err()){
        beep();
        printf("Could not create image.\n",args);
        return new_im.err();
    }
    max_val = max_fraction*iBuffer.max();
    printf("Data cutoff is at %g\n",max_val);
    printf("max is %g\n",iBuffer.max());
    printf("max_fract is %g\n",max_fraction);
    
    y1 = 0;
    y0 = 0;
    sizx = iBuffer.cols();
    sizy = iBuffer.rows();
    
    for(nt=0; nt< sizy; nt++){
        for(nc=0; nc<sizx; nc++) {
            if(iBuffer.getpix(nt,nc) > max_val) break;
        }
        if(nc != sizx) break;
    }
    y0 = nt;
    x0 = nc;

    for(nt=sizy-1; nt>=0; nt--){
        for(nc=sizx-1; nc>=0; nc--) {
            if(iBuffer.getpix(nt,nc) > max_val) break;
        }
        if(nc != -1) break;
    }
    y1 = nt;
    x1 = nc;
    
    printf("Using region between rows %d and %d\n",y0,y1);
    sizy = y1-y0+1;

    for(nt=y0; nt<= y1; nt++){
        ave = xcom = 0.;
        for(nc=0; nc<sizx; nc++) {
            datval = iBuffer.getpix(nt,nc);
            ave += datval;                    // average
            xcom += nc * (datval);            // x center of mass -- subtract min
            
        }
        ave = ave/(float)sizx;
        
        xcom /= sizx;
        xcom /= (ave);
        ave_xcom += xcom;
        center = xcom+.5;
        
        for(nc=0; nc<new_width; nc++) {
            new_im.setpix(nt,nc,(iBuffer.getpix(nt,center+nc) + iBuffer.getpix(nt,center-nc))/2.0);
        }
    }
    ave_xcom /= sizy;
    center = ave_xcom + .5;
    
    for(nt=0; nt< y0; nt++){
        for(nc=0; nc<new_width; nc++) {
            new_im.setpix(nt,nc,(iBuffer.getpix(nt,center+nc) + iBuffer.getpix(nt,center-nc))/2.0);
        }
    }
    for(nt=y1+1; nt< iBuffer.rows(); nt++){
        for(nc=0; nc<new_width; nc++) {
            new_im.setpix(nt,nc,(iBuffer.getpix(nt,center+nc) + iBuffer.getpix(nt,center-nc))/2.0);
        }
    }

    user_variables[0].fvalue = user_variables[0].ivalue = x0;
    user_variables[0].is_float=0;
    user_variables[1].fvalue = user_variables[1].ivalue = y0;
    user_variables[1].is_float=0;
    user_variables[2].fvalue = user_variables[2].ivalue = x1;
    user_variables[2].is_float=0;
    user_variables[3].fvalue = user_variables[3].ivalue = y1;
    user_variables[3].is_float=0;
    user_variables[4].fvalue = user_variables[4].ivalue = center;
    user_variables[4].is_float=0;

    
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;

}

/* ************************* */


/*
 UNFOLD
 Treat the current image as the right half of an image and "unfold" it to create a new symmetric image.
 
 */

int unfold_c(int n, char* args){
    int colorImage=0;
    if( iBuffer.isColor()){
        int* theSpecs=iBuffer.getspecs();
        theSpecs[IS_COLOR]=0;
        iBuffer.setspecs(theSpecs);
        delete [] theSpecs;
        colorImage=1;
    }
    iBuffer.rotate(90.0);
    Image newIm;
    newIm << iBuffer;
    iBuffer.invert();
    iBuffer.mirror();
    int w=iBuffer.width()-1,h=iBuffer.rows()-1;
    rect cropRect={{0,1},{w,h}};
    iBuffer.crop(cropRect);
    newIm.composite(iBuffer);
    newIm.rotate(-90.);
    
    iBuffer.free();     // release the old data
    iBuffer = newIm;   // this is the new data
    if( colorImage){
        int* theSpecs=iBuffer.getspecs();
        theSpecs[IS_COLOR]=1;
        iBuffer.setspecs(theSpecs);
        delete [] theSpecs;
    }
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;
}
/* ************************* */


/*
 DSATURATE [displaySaturationValue]
 This affects how the display command behaves when the Scale option is selected. If a displaySaturationValue is specified, the Color Max value used will be the dataMaxium*displaySaturationValue. If no argument is given, the current value is printed.
 */

int dsaturate_c(int n,char* args){
    float dSatValue=1;
    int nargs = sscanf(args,"%f",&dSatValue);
    
    if(nargs ==1){
        UIData.displaySaturateValue = dSatValue;
    }
    printf("Display Saturation Value is %f\n",UIData.displaySaturateValue);
    update_UI();
    
    return NO_ERR;
}
/* ************************* */


/*
 EXIT
 Quit the program.
 */

int exit_c(int n,char* args){
    char c=0;
    savsettings(0,&c);
    
    // hardware dependent close operations
#ifdef LJU3
    extern HANDLE hDevice;
    extern int u3_connected;
    if(u3_connected)closeUSBConnection(hDevice);
#endif

    exit(0);
}

/* ************************* */

/*
 GETANGLE fraction
 Calculate the angle that the current image needs to be rotated to align the x center
 of mass with the y axis. The entire image width is used. The start of the rectangle
 begins where maximum along a horizontal line is greater than "fraction" of the maximum
 and continues until the maximum along a horizontal line falls below "fraction" of the maximum
 */

int getangle_c(int n,char* args){
    int y1,y0,sizx,sizy;
    int nt,nc;
    
    double xcom=0.,ave=0.;
    double sx,sy,sx2,sy2,sxy,slope,theta;
    
    DATAWORD datval,fraction=0.,maxVal = 0.;
    
    extern Variable user_variables[];
    
    
    nc = sscanf(args,"%f",&fraction);
    if (nc < 1){
        beep();
        printf("Command format is GETANGLE fraction\n");
        return CMND_ERR;
    }
    DATAWORD* values = iBuffer.getvalues();
    maxVal = fraction*values[MAX];
    
    printf("Data cutoff is at %g\n",maxVal);
    y1 = 0;
    y0 = 0;
    sizx = iBuffer.width();
    sizy = iBuffer.height();
    
    sx = sy = sx2 = sy2 = sxy = 0.;
    
    for(nt=0; nt< sizy; nt++){
        for(nc=0; nc<sizx; nc++) {
            if(iBuffer.getpix(nt,nc) > maxVal) break;
        }
        if(nc != sizx) break;
    }
    y0 = nt;
    
    for(nt=sizy-1; nt>=0; nt--){
        for(nc=0; nc<sizx; nc++) {
            if(iBuffer.getpix(nt,nc) > maxVal) break;
        }
        if(nc != sizx) break;
    }
    y1 = nt;
    
    printf("Using region between rows %d and %d\n",y0,y1);
    sizy = y1-y0+1;
    
    for(nt=y0; nt<= y1; nt++){
        ave = xcom = 0.;
        for(nc=0; nc<sizx; nc++) {
            datval = iBuffer.getpix(nt,nc);
            ave += datval;                    // average
            xcom += nc*datval;            // x center of mass -- subtract min
        }
        ave = ave/(float)sizx;
        xcom /= sizx;
        xcom /= (ave);
        
        sy += xcom;
        sx += nt;
        sxy += xcom*nt;
        sy2 += xcom * xcom;
        sx2 += nt * nt;
        //printf("%d\t%g\n",nt,xcom);
    }
    
    slope = (sizy*sxy - sx*sy)/(sizy*sx2 - sx*sx);
    double r = (sizy*sxy -sx*sy)/sqrt((sizy*sx2-sx*sx)*(sizy*sy2-sy*sy));   // corellatiion coefficient
    printf("Slope: %g rSquare: %g Rows: %d\n",slope,r*r, sizy);  // print r2
    theta = atan(slope);
    theta = -theta*180./PI;
    printf("Angle: %f\n",theta);
    
    user_variables[0].fvalue = theta;
    user_variables[0].is_float = 1;
    user_variables[1].fvalue = xcom;
    user_variables[1].ivalue = xcom;
    user_variables[1].is_float = 1;
    
    update_UI();
    return NO_ERR;
}
/* ************************* */
/*
 MAP minimum maximum
    Map the current image to have values between minimum and maximum.
 */
int map_c(int n,char* args){
    DATAWORD min,max,scale;
    DATAWORD* values = iBuffer.getvalues();
    if( sscanf(args,"%f %f",&min,&max) != 2){
        beep();
        printf("Need two values: MAP minimum maximum\n");
    }
    scale = (max-min)/(values[MAX]-values[MIN]);
    iBuffer-values[MIN];
    iBuffer*scale;
    iBuffer+min;
    
    free(values);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();

    return NO_ERR;

    
}

/* ************************* */

#if defined(MacOSX_UI)

/*
 FLIPPID Nx NcLow NcHigh Power Background
 Perform an inverse Abel transform using the FLiPPID method. The current image must satisfy these conditions: (1) it is a right-side-up, full axisymmetric flame image with an odd number of columns. (2) The flame must be perfectly centered on the center of the image. Nx should be slightly larger than the maximum width (in pixels) of the flame. NcLow and NcHigh relate to a range of radial locations of the maximum; values of -500 and 2500, respectively seem to work for several flames I tested. Power is the power used in the fitting function, and could range from 3 - 7 or more. Higher powers seem to work better for flames with thin soot regions at the edges. Rows with maximum counts less than Background will be filled with 0. The image buffer returns the Abel inverted image. a temporary image named proj is also created -- this is the projected image created from the fitting function and can be comared with the original image to assess the quality of the fit. A lookup table is created based on the values of Nx, NcLow, NcHigh, and Power. The table is saved to a file in a folder named flippidMatrices in the path specified by the Save Data Files preference. Before calculating a new table, the program checks to see if an appropriate table already exists.
 
 */
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_multimin.h>
#include <sys/stat.h>

#define MAXITERATIONS 1000

typedef struct {
    double a;
    double b;
    double c;
} initialGuess;

int Nx,NcLow,NcHigh,power;
int halfWidth;
float deltaX=.01,deltaC=.01;

gsl_matrix *intFile;
gsl_vector *rowData;
gsl_vector *fitData;

double f(double sigma, void *p);
double iInt(double x, double b, double c);
double pEval(double x, double a, double b, double c);
double rEval(double x, double a, double b, double c);
double rmsErr(double *first, double *second,int length);
double rmsErrFit(const gsl_vector *v, void *params);

struct f_params {
    double c;
    double x;
    int p;
};

// function to do interpolation between grid points on integral table.
double iInt(double x, double b, double c){
    double u = x/b;
    if(x < 0.) u = -x/b;
    int i = u/deltaX;
    int j = c/deltaC-NcLow;
    double xi = u/deltaX - i;
    double chi = c/deltaC -NcLow - j;
    
    /*
    if( i > Nx-1) i=Nx-1;
    if (j < 0) j=0;
    if(j > NcHigh-NcLow-1) j=NcHigh-NcLow-1;
    */
    if( i > Nx || i< 0) return gsl_matrix_get(intFile,Nx+1,1);      // lower left value
    if( j< 0 || j > NcHigh-NcLow) return gsl_matrix_get(intFile,Nx+1,1);      // lower left value
    
    if (u-int(u)==0.0 && c-int(c)==0.0)
        return gsl_matrix_get(intFile,i+1,j+1);
    
    if (j==NcHigh-NcLow && i==Nx) return gsl_matrix_get(intFile,Nx+1,1);      // lower left value
    
    if (j==NcHigh-NcLow)
        return (1-xi)*(1-chi)*gsl_matrix_get(intFile,i+1,j+1) + (xi)*(1-chi)*gsl_matrix_get(intFile,i+2,j+1);
    
    if( i==Nx)
        return (1-xi)*(1-chi)*gsl_matrix_get(intFile,i+1,j+1) + (1-xi)*(chi)*gsl_matrix_get(intFile,i+1,j+2);
    
    return (1-xi)*(1-chi)*gsl_matrix_get(intFile,i+1,j+1) + (1-xi)*(chi)*gsl_matrix_get(intFile,i+1,j+2) + (xi)*(1-chi)*gsl_matrix_get(intFile,i+2,j+1) + xi*chi*gsl_matrix_get(intFile,i+2,j+2);
    
 }

// function to calculate P
double pEval(double x, double a, double b, double c){
    return M_2_SQRTPI * a * exp(iInt(x,b,c));   // 2/root(pi)
}

// function to calculate R
double rEval(double x, double a, double b, double c){
    return  a / (b * M_SQRTPI) * exp(c * (x*x/(b*b)) - pow(x/b,2*power ));
}
// return mean square difference between elements of two arrays of specified length
double rmsErr(double *first, double *second, int length){
    double error = 0;
    for(int i=0; i< length; i++){
        error += pow(first[i] - second[i],2);
    }
    return error/length;
}

// function to be integrated
double f(double sigma, void *p) {
    f_params &params= *reinterpret_cast<f_params*>(p);
    double sig2x2 = sigma*sigma + params.x*params.x;
    return exp(params.c*sig2x2-pow(sig2x2,params.p));
}

// function to be minimized
double rmsErrFit(const gsl_vector *v, void *params)
{
    
    double newa = gsl_vector_get(v,0);
    double newb = gsl_vector_get(v,1);
    double newc = gsl_vector_get(v,2);
    for(int c=0; c<iBuffer.width();c++ ){
        gsl_vector_set(fitData, c, pEval(c-halfWidth, newa, newb, newc));
    }
    double result = rmsErr(rowData->data, fitData->data, iBuffer.width());
    return result;
}



int flippid_c(int notUsed,char* args){
    double background;
    int nargs = sscanf(args,"%d %d %d %d %lf",&Nx,&NcLow,&NcHigh,&power,&background);
    
    if(nargs !=5){
        beep();
        printf("Arguments required are Nx NcLow NcHigh Power Background\n");
        return CMND_ERR;
    }
    
    intFile = gsl_matrix_calloc(Nx+2, NcHigh-NcLow+2);  // integral lookup table
    rowData = gsl_vector_alloc(iBuffer.width());
    fitData = gsl_vector_alloc(iBuffer.width());
    double aTrial,aPrev,bTrial,bPrev,cTrial,cPrev;
    
    // ********** the lookup table **********
    int r,c;
    FILE* matFile;
    
    // maybe it's already been calculated
    char fname[CHPERLN]="flippidMatrices";
    mkdir(fullname(fname, SAVE_DATA_NO_SUFFIX),S_IRUSR|S_IWUSR|S_IXUSR|S_IRGRP|S_IXGRP);   // read/write by owner; read by group
    sprintf(fname,"flippidMatrices/FLiPPD_Nx=%d_Nc=%dto%d_pow%d",Nx,NcLow,NcHigh,power);
    matFile = fopen(fullname(fname,CSV_DATA),"r");
    if( matFile ){ // file exists, read in the values
        double value;
        for(r=0;r<Nx+2;r++){
            for(c=0; c<NcHigh-NcLow+1; c++){
                fscanf(matFile,"%lf,",&value);
                gsl_matrix_set(intFile,r,c,value);
            }
            fscanf(matFile,"%lf,\n",&value);
            gsl_matrix_set(intFile,r,c,value);
        }
        fclose(matFile);
    } else {
        // nope -- have to calculate it
        printf("Calculating lookup table...\n");
        // set first column
        for(r=1; r< Nx+2;r++){
            gsl_matrix_set(intFile,r,0,r-1);
        }
        //set first row
        for(c=0; c<NcHigh-NcLow+1;c++){
            gsl_matrix_set(intFile,0,c+1,NcLow+c);
        }
        
        double value,abserr,epsabs=1e-14,epsrel=1e-12;
        f_params params;
        params.p=power;
        gsl_function F;
        F.function = &f;
        F.params = reinterpret_cast<void *>(&params);
        gsl_integration_workspace *w = gsl_integration_workspace_alloc(500);
        
        for(r=0;r<Nx+1;r++){
            params.x = deltaX*r;
            for(c=0; c<NcHigh-NcLow+1; c++){
                params.c=deltaC*(NcLow + c);
                gsl_integration_qagiu(&F, 0, epsabs, epsrel, 500, w, &value, &abserr);
                gsl_matrix_set(intFile,r+1,c+1,log(value));
                
            }
        }
        // save to a file
        matFile = fopen(fname,"w");
        for(r=0;r<Nx+2;r++){
            for(c=0; c<NcHigh-NcLow+1; c++){
                fprintf(matFile,"%.16f,",gsl_matrix_get(intFile,r,c));
            }
            fprintf(matFile,"%.16f,\n",gsl_matrix_get(intFile,r,c));
        }
        fclose(matFile);
        gsl_integration_workspace_free(w);
    }
    // ********** lookup table complete ************
    
    // definitions for minimization
    const gsl_multimin_fminimizer_type *T = gsl_multimin_fminimizer_nmsimplex2;
    gsl_multimin_fminimizer *s = NULL;
    gsl_vector * ss= gsl_vector_alloc (3), *x = gsl_vector_alloc (3);
    gsl_multimin_function minex_func;
    
    minex_func.n = 3;
    minex_func.f = rmsErrFit;
    //minex_func.params = par;
    
    int status;
    double size;
    initialGuess* startGuess = new initialGuess[iBuffer.height()+1];
    // end of minimization defs
    
    Image projection;
    projection << iBuffer;  // this be saved as a temporary image named "proj"
    gsl_vector *centerLine = gsl_vector_alloc(iBuffer.height());
    int minIterations = MAXITERATIONS;
    int maxIterations = 0;
    int noConvergenceCount=0;
    
    int colors = 1;
    if(iBuffer.isColor()) colors = 3;
    //
    int height = iBuffer.height();
    
    // *********** loop over all rows **************
    
    for(int color = 0; color < colors; color++){
        if(color == 0 && colors == 3) printf("Red");
        else if(color == 0 && colors == 1) printf("Greyscale");
        else if(color == 1) printf("\nGreen");
        else printf("\nBlue");
        
        
        // get the center column
        halfWidth = iBuffer.width()/2;
        c=halfWidth+1;
        for(r=0; r<iBuffer.height();r++ ){
            gsl_vector_set(centerLine, r, iBuffer.getpix(r+color*height, c));
        }
        int zMidAll = (int)gsl_vector_max_index(centerLine);
        // now go backwards toward the flame tip until the maximum of the row is at the center
        for(r=zMidAll; r>=0; r--){
            for(c=0; c<iBuffer.width();c++ )
                gsl_vector_set(rowData, c, iBuffer.getpix(r+color*height, c));   // fill in the data for this row
            if( abs(int(gsl_vector_max_index(rowData)) - halfWidth - 1) < 3) break; // max is within +/- 2 pix of centerline
        }
        zMidAll = r;
        if(zMidAll < 0) zMidAll=0;
        double maxCenterValue = iBuffer.getpix(zMidAll+color*height, halfWidth+1);
        printf(" starting at row %d\n",zMidAll);
        
        // start loop on rows working downward from zMidAll
        for(r = zMidAll; r<iBuffer.height();r++){
            int halfMaxIndex;
            for(c=0; c<iBuffer.width();c++ ){
                gsl_vector_set(rowData, c, iBuffer.getpix(r+color*height, c));   // fill in the data for this row
                if(r == zMidAll){
                    if( iBuffer.getpix(r+color*height, c) > maxCenterValue/2.) halfMaxIndex=c;   // this relates to the flame width
                }
            }
            if(gsl_vector_max(rowData) < background){
                for(c=0; c<iBuffer.width();c++ ){
                    projection.setpix(r+color*height, c, 0.);
                    iBuffer.setpix(r+color*height, c, 0.);
                }
            } else {
                
                // first guess
                if(r == zMidAll){
                    startGuess[r].a = aTrial = aPrev = maxCenterValue/1.047;
                    //startGuess[r].b = bTrial = bPrev = (Nx - iBuffer.width() + halfMaxIndex)/0.8;
                    startGuess[r].b = bTrial = bPrev = (halfMaxIndex-iBuffer.width()/2)/0.4; // 20% wider than flame
                    startGuess[r].c = cTrial = cPrev = 0;
                }
                
                if(aPrev == 0.){
                    gsl_vector_set(x, 0, aTrial);
                    gsl_vector_set(x, 1, bTrial);
                    gsl_vector_set(x, 2, cTrial);
                } else {
                    gsl_vector_set(x, 0, aPrev);
                    gsl_vector_set(x, 1, bPrev);
                    gsl_vector_set(x, 2, cPrev);
                }
                //printf("initial a b c %f %f %f\n",gsl_vector_get(x,0),gsl_vector_get(x,1),gsl_vector_get(x,2));
                
                // the minimization for this row
                gsl_vector_set(ss, 0, 1);
                gsl_vector_set(ss, 1, 1);
                gsl_vector_set(ss, 2, 1);
                
                
                s = gsl_multimin_fminimizer_alloc (T, 3);
                gsl_multimin_fminimizer_set (s, &minex_func, x, ss);
                int iter = 0;
                do
                {
                    iter++;
                    status = gsl_multimin_fminimizer_iterate(s);
                    
                    if (status)
                        break;
                    
                    size = gsl_multimin_fminimizer_size (s);
                    status = gsl_multimin_test_size (size, 1e-8);
                    
                    if (status == GSL_SUCCESS)
                    {
                        /*
                         printf ("converged to minimum at\n");
                         printf ("%5d %10.3e %10.3e %10.3e f() = %7.3f size = %.3f\n",
                         iter,
                         gsl_vector_get (s->x, 0),
                         gsl_vector_get (s->x, 1),
                         gsl_vector_get (s->x, 2),
                         s->fval, size);
                         */
                    }
                }
                while (status == GSL_CONTINUE && iter < MAXITERATIONS);
                
                if(iter < minIterations) minIterations=iter;
                if(iter > maxIterations) maxIterations=iter;
                if(iter == MAXITERATIONS) noConvergenceCount++;
                if(r%25 ==0)printf(".");
                
                startGuess[r+1].a = aPrev=gsl_vector_get(s->x, 0);
                startGuess[r+1].b = bPrev=gsl_vector_get(s->x, 1);
                startGuess[r+1].c = cPrev=gsl_vector_get(s->x, 2);
                
                for(int c=0; c<iBuffer.width();c++ ){
                    projection.setpix(r+color*height, c, pEval(c-halfWidth, aPrev, bPrev, cPrev));
                    if(r != zMidAll) iBuffer.setpix(r+color*height, c, rEval(c-halfWidth, aPrev, bPrev, cPrev)); // recalculate this one
                }
                gsl_multimin_fminimizer_free (s);
                // done minimization of this row
            }
        }
        
        // now loop on rows working upward from zMidAll
        for(r = zMidAll; r>=0;r--){;
            for(c=0; c<iBuffer.width();c++ ){
                gsl_vector_set(rowData, c, iBuffer.getpix(r+color*height, c));   // fill in the data for this row
            }
            if(gsl_vector_max(rowData) < background){
                for(c=0; c<iBuffer.width();c++ ){
                    projection.setpix(r+color*height, c, 0.);
                    iBuffer.setpix(r+color*height, c, 0.);
                }
            } else {
                
                
                if(aPrev == 0.){
                    gsl_vector_set(x, 0, aTrial);
                    gsl_vector_set(x, 1, bTrial);
                    gsl_vector_set(x, 2, cTrial);
                } else {
                    gsl_vector_set(x, 0, startGuess[r+1].a);
                    gsl_vector_set(x, 1, startGuess[r+1].b);
                    gsl_vector_set(x, 2, startGuess[r+1].c);
                }
                //printf("initial a b c %f %f %f\n",gsl_vector_get(x,0),gsl_vector_get(x,1),gsl_vector_get(x,2));
                
                // the minimization for this row
                gsl_vector_set(ss, 0, 1);
                gsl_vector_set(ss, 1, 1);
                gsl_vector_set(ss, 2, 1);
                
                
                s = gsl_multimin_fminimizer_alloc (T, 3);
                gsl_multimin_fminimizer_set (s, &minex_func, x, ss);
                int iter = 0;
                do
                {
                    iter++;
                    status = gsl_multimin_fminimizer_iterate(s);
                    
                    if (status)
                        break;
                    
                    size = gsl_multimin_fminimizer_size (s);
                    status = gsl_multimin_test_size (size, 1e-8);
                    
                    if (status == GSL_SUCCESS)
                    {
                        /*
                         printf ("converged to minimum at\n");
                         printf ("%5d %10.3e %10.3e %10.3e f() = %7.3f size = %.3f\n",
                         iter,
                         gsl_vector_get (s->x, 0),
                         gsl_vector_get (s->x, 1),
                         gsl_vector_get (s->x, 2),
                         s->fval, size);
                         */
                    }
                }
                while (status == GSL_CONTINUE && iter < MAXITERATIONS);
                
                if(iter < minIterations) minIterations=iter;
                if(iter > maxIterations) maxIterations=iter;
                if(iter == MAXITERATIONS) noConvergenceCount++;
                if(r%25 ==0)printf(".");
                
                startGuess[r].a=gsl_vector_get(s->x, 0);
                startGuess[r].b=gsl_vector_get(s->x, 1);
                startGuess[r].c=gsl_vector_get(s->x, 2);
                
                for(int c=0; c<iBuffer.width();c++ ){
                    projection.setpix(r+color*height, c, pEval(c-halfWidth, startGuess[r].a, startGuess[r].b, startGuess[r].c));
                    iBuffer.setpix(r+color*height, c, rEval(c-halfWidth, startGuess[r].a, startGuess[r].b, startGuess[r].c));
                }
                gsl_multimin_fminimizer_free (s);
                // done minimization of this row
            }
        }
    }
    
    printf("\nMinimum Iterations:\t%d\nMaximum iterations:\t%d\nNot Converged:\t%d\n\n",minIterations,maxIterations,noConvergenceCount);
    
    gsl_matrix_free(intFile);
    gsl_vector_free (centerLine);
    gsl_vector_free (rowData);
    gsl_vector_free (fitData);
    
    gsl_vector_free(x);
    gsl_vector_free(ss);
    delete[] startGuess;
    
    int n = temp_image_index((char*)"proj",1);
    if(n >=0){
        iTempImages[n] << projection;
    } else {
        return MEM_ERR;
    }
    projection.free();
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    
    return NO_ERR;
}
#endif

