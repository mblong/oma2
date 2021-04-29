#include "image.h"


// The list of globals -- keep this VERY small
// globals should be named iSomething (note capitalization)
// Whenever possible, imbed things as static variables inside a function
// See fullname() for example, where that is the location of all the prefix/suffix related storage

char    reply[1024];          // buffer for sending messages to be typed out by the user interface
Image   iBuffer(200,200);     // the image buffer
oma2UIData UIData;            // Put all the UI globals here
Image  iTempImages[NUM_TEMP_IMAGES];  // temporary in-memmory images
Image   accumulator;          // the accumulator image
Image   hdrAccumulator;     // the HDR accumulator
Image   hdrCounter;         // the HDR counter
DATAWORD hdrCutoffMax;         // the HDR saturation value
DATAWORD hdrCutoffMin;       // the HDR min value for inclusion in the image
float   hdrMaxScale;        // this is the biggest scale factor -- use to determine largest value in an hdr image
int      hdrFrames=0;       // HDR frame counter

int numberNamedTempImages = 0;
Variable namedTempImages[NUM_TEMP_IMAGES-NUMBERED_TEMP_IMAGES];

int argc = 0;               // these three for dcraw
char *argv[200];
char dcraw_arg[CHPERLN];

//int newWindowFlag = 1;      // set by NEWWINDOW

FILE* nameFilePtr = NULL;   // used in the GETFILENAMES and NEXTFILE commands
FILE* folderFilePtr = NULL;   // used in the GETFOLDERNAMES and NEXTPREFIX commands

char applicationPath[CHPERLN];	// this is the path to the directory that the program is running from
char contentsPath[CHPERLN];		// this is the path to the Contents directory where things like palettes are stored
//float windowScaleFactor = 1.; // this global was moved to the UIData

char windowName[CHPERLN];
char lastname[CHPERLN];
int windowNameMemory = 0;

char binaryExtension[CHPERLN] = {"RAW"};
int bin_rows = 1024, bin_cols = 1360, bin_header = 0, binary_file_bytes_per_data_point = 2 , swap_bytes_flag = 0, unsigned_flag=0;

int printMax = PRINT_RESULT;


FileDecoderExtensions fileDecoderExtensions[] = {
//    {{".nef"},DCRAW},
    {{".NEF"},DCRAW},
    {{".CR2"},DCRAW},
    {{".CR3"},DCRAW},
    {{".CRW"},DCRAW},
    {{".JPG"},JPEG},
    {{".DNG"},JPEG},
    {{".HIF"},JPEG},
    {{".HEIF"},JPEG},
    {{".HEIC"},JPEG},
//    {{".png"},JPEG},
    {{".PNG"},JPEG},
//    {{".tif"},TIFREAD},
    {{".TIF"},TIFREAD},
//    {{".tiff"},TIFREAD},
    {{".TIFF"},TIFREAD},
//   {{".hobj"},HOBJ},
    {{".HOBJ"},HOBJ},
//   {{".hdr"},HDR},
    {{".HDR"},HDR},
//   {{".dat"},OMA},
    {{".DAT"},OMA},
//    {{".o2d"},OMA},
    {{".O2D"},OMA},
    {{".CSV"},TXT},
//    {{".csv"},TXT},
    {{".RAW"},RAW},
    {{""},},
};
// if position of RAW changes, be sure to update definition of #define RAW_FILE_EXT_INDEX 24 in image.h

//extern "C" int get_byte_swap_value(short);
//extern "C" void swap_bytes_routine(char* co, int num,int nb);

Image::Image()              // create an empty Image with default values
{
    data = NULL;
    specs[ROWS]=specs[COLS]=0;

    specs[Y0] = specs[X0] = specs[IS_COLOR] = specs[HAVE_MAX] = 0;
    specs[NFRAMES] = 0; // the first frame is frame 0 
    specs[DX] = specs[DY] = 1;
    error = 0;
    specs[HAS_RULER]=0;
    specs[SAVE_FORMAT]=0;
    values[RULER_SCALE]=1.;
    unit_text[0] = 0;
    is_big_endian = IS_BIG_ENDIAN;
    commentSize = 0;
    comment = NULL;
    extraSize = 0;
    extra = NULL;
}


Image::~Image()
{
    //free();
}


Image::Image(int rows, int cols)
{
    *this = Image();    // default specs
    data = new DATAWORD[rows*cols];
    if(data == 0){
        specs[ROWS]=specs[COLS]=0;
        error = MEM_ERR;
    } else {
        specs[ROWS]=rows;
        specs[COLS]=cols;
        error = NO_ERR;
    }
}

Image::Image(char* filename, int kindOfName)
{
    unsigned long nr,nbyte;
    TWOBYTE header[HEADLEN/2];
    char comment_[COMLEN];
    TWOBYTE trailer[TRAILEN/2];
    int swap_bytes;
    int doffset=80;
    int fd,color,i;
    
    *this = Image();
    
    strncpy(windowName, filename, CHPERLN);
    strncpy(lastname, filename, CHPERLN);
    trimName(windowName);
    windowNameMemory = 2;
    extraSize = 0;
    // default specs set -- now decide what kind of file we are opening
    
    // first check for non-oma files that have special routines for reading
    // these will have a file extension specified -- the suffix will be ignored
    char filenameCopy[CHPERLN];
    strncpy(filenameCopy, filename, CHPERLN);
    int nameLength = (int)strlen(filename);
    for(i=0; i<nameLength; i++) filenameCopy[i] = toupper(filename[i]); // all uppercase for looking at extensions
    
    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == DCRAW
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                color = dcrawGlue(filename,-1,this);
            } else {
                fullname(filename,RAW_DATA);
                color = dcrawGlue(filename,-1,this);
            }
            if(color < 0) error = FILE_ERR;
            if (error) windowNameMemory = 0;
            return;
        }
    }
    
    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == JPEG
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                error = readJpeg(filename,this);
            } else {
                error = readJpeg(fullname(filename,RAW_DATA),this);
            }
            if (error) windowNameMemory = 0;
            return;
        }
    }

    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == TIFREAD
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                error = readTiff(filename,this);
            } else {
                error = readTiff(fullname(filename,RAW_DATA),this);
            }
            if (error) windowNameMemory = 0;
            return;
        }
    }
    
    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == HDR
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                error = readHDR(filename,this);
            } else {
                error = readHDR(fullname(filename,RAW_DATA),this);
            }
            if (error) windowNameMemory = 0;
            return;
        }
    }
    
    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == HOBJ
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                error = readHobj(filename,this);
            } else {
                error = readHobj(fullname(filename,RAW_DATA),this);
            }
            if (error) windowNameMemory = 0;
            return;
        }
    }

    for(i=0; fileDecoderExtensions[i].ext[0]; i++ ){
        int extLength = (int)strlen(fileDecoderExtensions[i].ext);
        if(fileDecoderExtensions[i].decoder == TXT
           && strncmp(&filenameCopy[nameLength-extLength],fileDecoderExtensions[i].ext,extLength) == 0){
            if (kindOfName == LONG_NAME) {
                error = readCsv(filename,this);
            } else {
                error = readCsv(fullname(filename,RAW_DATA),this);
            }
            if (error) windowNameMemory = 0;
            return;
        }
    }

    
    // read a binary file that has an extension specified by the BINEXTENSION command
    // find the extension

    for (i=0; (filename[nameLength-i] != '.') && (i < nameLength); i++);
    i--;
    if (strncmp(&filenameCopy[nameLength-i],binaryExtension,i) == 0 ){
        if (kindOfName == LONG_NAME) {
            error = readBinary(filename,this,bin_rows,bin_cols,bin_header,binary_file_bytes_per_data_point,swap_bytes_flag,unsigned_flag);
        } else {
            error = readBinary(fullname(filename,RAW_DATA),this,bin_rows,bin_cols,bin_header,binary_file_bytes_per_data_point,swap_bytes_flag,unsigned_flag);
        }
        if (error) windowNameMemory = 0;
        return;
    }
    // end special file cases
    
    // if we get here, the assumption is this is oma file format, either new or old

    switch (kindOfName) {
        case LONG_NAME:
            fd = open(filename,READBINARY);
            break;
        case SHORT_NAME:
            fd = open(fullname(filename,GET_DATA),READBINARY);
            break;
//        case HAS_SUFFIX:
//            fd = open(fullname(filename,RAW_DATA),READBINARY);    // means don't add the suffix -- this case never happens
//            break;
        case LEAVE_OPEN:
            fd = open(fullname(filename,GET_DATA),READBINARY);    // assume a short name
            extern int openFileFd;
            openFileFd = fd;
            break;
        case IS_OPEN:
            fd = *(int*)filename;    // we have an open file
            break;
        default:
            fd = -1;
            break;
    }
    
    if(fd == -1) {
        error = FILE_ERR;
        windowNameMemory = 0;
        return;
    }
    static int newFormat = 0;
    static int openFileRows;
    static int openFileCols;
    if(kindOfName != IS_OPEN){
        // read the header
        nr = read(fd,(char*)header,HEADLEN);
        if (strncmp((char*)header, OMA2_BINARY_DATA_STRING,HEADLEN) == 0) { // new save format
            newFormat = 1;
            int nspecs,nvalues,nrulerchar;
            read(fd,&nspecs,sizeof(int));
            read(fd,&nvalues,sizeof(int));
            read(fd,&nrulerchar,sizeof(int));
            // we'll assume that the number of specs, values, and ruler characters won't decrease in future versions, but allow for them to increase
            read(fd,specs,sizeof(int)*nspecs);
            read(fd,values,sizeof(DATAWORD)*nvalues);
            read(fd,unit_text,nrulerchar);
            read(fd,&error,sizeof(int));
            read(fd,&is_big_endian,sizeof(int));
            read(fd,&commentSize,sizeof(int));
            read(fd,&extraSize,sizeof(int));
            if(commentSize){
                comment = new char[commentSize];
                read(fd,comment,commentSize);
            }
            if(extraSize ){ // make room, but we won't read until later
                extra = new float[extraSize];
                read(fd,extra,extraSize*sizeof(float));
            }
            // next the data
            data = new DATAWORD[specs[ROWS]*specs[COLS]];
            if(data == 0){
                specs[ROWS]=specs[COLS]=0;
                error = MEM_ERR;
                close(fd);
                windowNameMemory = 0;
                return;
            }
            openFileRows = specs[ROWS];
            openFileCols = specs[COLS];
        } else {
            newFormat = 0;
            // old data save format
            nr = read((int)fd,comment_,COMLEN);
            nr = read((int)fd,(char*)trailer,TRAILEN);
            
            swap_bytes = process_old_header((TWOBYTE*)header,(char*)comment_,(TWOBYTE*)trailer, this);
            // add the comment
            commentSize = COMLEN;
            comment = new char[COMLEN];
            for(int i = 0; i<COMLEN;i++){
                comment[i] = comment_[i];
            }
            openFileRows = header[NTRAK];
            openFileCols = header[NCHAN];

        }
    } else {
        data = new DATAWORD[openFileRows*openFileCols];
        specs[ROWS] = openFileRows;
        specs[COLS] = openFileCols;
    }
    // now read the data
    if (newFormat) {
        int npts = specs[ROWS]*specs[COLS];
        switch (specs[SAVE_FORMAT]) {
            case UNSIGNED16:
            {
                unsigned short* shortData = new unsigned short[npts];
                nr = read(fd,shortData,sizeof(unsigned short)*npts);
                if (nr != sizeof(unsigned short)*npts) {
                    error = FILE_ERR;
                    delete[] shortData;
                } else {
                    DATAWORD* mydatpt=data;
                    unsigned short* newdatpt=shortData;
                    while ( mydatpt < data+npts ) {
                        *mydatpt++ = *newdatpt++;
                    }
                    delete[] shortData;
                }
                break;
            }
            case SIGNED16:
            {
                short* shortData = new short[npts];
                nr = read(fd,shortData,sizeof(short)*npts);
                if (nr != sizeof(short)*npts) {
                    error = FILE_ERR;
                    delete[] shortData;
                } else {
                    DATAWORD* mydatpt=data;
                    short* newdatpt=shortData;
                    while ( mydatpt < data+npts ) {
                        *mydatpt++ = *newdatpt++;
                    }
                    delete[] shortData;
                }
                break;
            }
            case UNSIGNED8:
            {
                unsigned char* shortData = new unsigned char[npts];
                nr = read(fd,shortData,sizeof(unsigned char)*npts);
                if (nr != sizeof(unsigned char)*npts) {
                    error = FILE_ERR;
                    delete[] shortData;
                } else {
                    DATAWORD* mydatpt=data;
                    unsigned char* newdatpt=shortData;
                    while ( mydatpt < data+npts ) {
                        *mydatpt++ = *newdatpt++;
                    }
                    delete[] shortData;
                }
                break;
            }
            case SIGNED8:
            {
                char* shortData = new char[npts];
                nr = read(fd,shortData,sizeof(char)*npts);
                if (nr != sizeof(char)*npts) {
                    error = FILE_ERR;
                    delete[] shortData;
                } else {
                    DATAWORD* mydatpt=data;
                    char* newdatpt=shortData;
                    while ( mydatpt < data+npts ) {
                        *mydatpt++ = *newdatpt++;
                    }
                    delete[] shortData;
                }
                break;
            }

            default:
                nr = read(fd,data,sizeof(DATAWORD)*npts);
                if (nr != sizeof(DATAWORD)*npts) {
                    error = FILE_ERR;
                }
        }
        

        if(kindOfName != IS_OPEN && kindOfName != LEAVE_OPEN){
            close(fd);
        }
        if (error) windowNameMemory = 0;
        return;
    }
    
    // read data part of old format
    nbyte = specs[ROWS]*specs[COLS]*DATABYTES;
    
    // problem of how to get rid of the old 80 data word offset and still read in old oma files
    data = new DATAWORD[specs[ROWS]*specs[COLS]];
    if(data == 0){
        specs[ROWS]=specs[COLS]=0;
        error = MEM_ERR;
        windowNameMemory = 0;
        return;
    }
    // in old oma files, there is an 80 element data offset -- skip over this
    // could be 2-byte or 4-byte
    // find length
    int dataSize = DATABYTES;
    FILE* f=fopen(filename ,"r");
    fseek(f, 0, SEEK_END);
    if(f != NULL){
        long size = ftell(f)-HEADLEN+COMLEN+TRAILEN;
        fclose(f);
        if (roundf((float)nbyte/size) == 2.) {
            dataSize = 2;
            nbyte = specs[ROWS]*specs[COLS]*dataSize;
        }
    }
    // in the unlikely event that an old oma file has fewer than doffset points
    if (doffset > specs[ROWS]*specs[COLS]) {
        char* junkBuf = new char[doffset*dataSize];
        nr = read((int)fd,junkBuf,doffset*dataSize);   // this will be ignored
        delete[] junkBuf;
    } else {
        nr = read((int)fd,data,doffset*dataSize);   // this will be ignored
    }
    nr = read((int)fd,(char*)data, nbyte);
    if (nr != nbyte) {
        error = FILE_ERR;
    }
    printf("%d Bytes read.\n",(int)nr);
    
    if(dataSize == 2) {
        // this is a 2-byte data file
        // adjust to 4-byte format
        printf("2-byte input file\n");
        if(swap_bytes)  swap_bytes_routine((char*) data,(int) nr,2);
		two_to_four(data,(int)nr/2,trailer[SFACTR]);
    } else {
        if(swap_bytes) swap_bytes_routine((char*) data, (int)nr, DATABYTES);
    }
    
    if(kindOfName != IS_OPEN && kindOfName != LEAVE_OPEN) close(fd);
    if (error) windowNameMemory = 0;
    return;
}


void Image::operator+(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) += val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator-(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) -= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator*(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) *= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator/(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) /= val;
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::power(DATAWORD val){
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) = pow(*(data+i),val);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::rgbMult(float x, float y, float z){
    
    DATAWORD *pt,*pt_green,*pt_blue;
	int num = specs[ROWS]*specs[COLS]/3;
	int i;
	
	pt = data;
	pt_green = pt + num;
	pt_blue =  pt_green + num;
	
	for (i=0; i < num; i++) {
		*(pt++) *= x;
		*(pt_green++) *= y;
		*(pt_blue++) *= z;
	}
    specs[HAVE_MAX]=0;
}

void Image::rgbDiv(float x, float y, float z){
    
    DATAWORD *pt,*pt_green,*pt_blue;
	int num = specs[ROWS]*specs[COLS]/3;
	int i;
	
	pt = data;
	pt_green = pt + num;
	pt_blue =  pt_green + num;
	
	for (i=0; i < num; i++) {
		*(pt++) /= x;
		*(pt_green++) /= y;
		*(pt_blue++) /= z;
	}
    specs[HAVE_MAX]=0;
}

void Image::rgbAdd(float x, float y, float z){
    
    DATAWORD *pt,*pt_green,*pt_blue;
	int num = specs[ROWS]*specs[COLS]/3;
	int i;
	
	pt = data;
	pt_green = pt + num;
	pt_blue =  pt_green + num;
	
	for (i=0; i < num; i++) {
		*(pt++) += x;
		*(pt_green++) += y;
		*(pt_blue++) += z;
	}
    specs[HAVE_MAX]=0;
}

void Image::rgbSub(float x, float y, float z){
    
    DATAWORD *pt,*pt_green,*pt_blue;
	int num = specs[ROWS]*specs[COLS]/3;
	int i;
	
	pt = data;
	pt_green = pt + num;
	pt_blue =  pt_green + num;
	
	for (i=0; i < num; i++) {
		*(pt++) -= x;
		*(pt_green++) -= y;
		*(pt_blue++) -= z;
	}
    specs[HAVE_MAX]=0;
}

void Image::rgbPow(float x, float y, float z){
    
    DATAWORD *pt,*pt_green,*pt_blue;
	int num = specs[ROWS]*specs[COLS]/3;
	int i;
	
	pt = data;
	pt_green = pt + num;
	pt_blue =  pt_green + num;
	
	for (i=0; i < num; i++) {
        
		*(pt+i) = pow(*(pt+i),x);
		*(pt_green+i) = pow(*(pt_green+i),y);
		*(pt_blue+i) = pow(*(pt_blue+i),z);
	}
    specs[HAVE_MAX]=0;
}



void Image::operator+(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) += *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator-(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) -= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator*(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) *= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

void Image::operator/(Image im2){
    if (*this != im2){
        error = SIZE_ERR;
        //return *this;
        return;
    }
    for(int i=0; i<specs[ROWS]*specs[COLS];i++){
        *(data+i) /= *(im2.data+i);
    }
    specs[HAVE_MAX]=0;
    //return *this;
}

Image Image::operator<<(Image im){
    // in case the current image is not empty, free the space
    this->free();
    Image copy;
    // allocate space for data
    copy.data = new DATAWORD[im.specs[ROWS]*im.specs[COLS]];
    if (copy.data==NULL){
        error = MEM_ERR;
        return copy;
    }
    copy.copyABD(im); // get the specs
    // get the data
    for(int i=0; i<im.specs[ROWS]*im.specs[COLS]; i++){
        *(copy.data+i) =  *(im.data+i);
    }
    
    *this = copy;
    return *this;
}

bool Image::operator==(Image im2){
    if (specs[ROWS] == im2.specs[ROWS] && specs[COLS] == im2.specs[COLS]) {
        return true;
    }
    return false;
}

bool Image::operator!=(Image im2){
    return !(*this == im2);
}

int Image::err(){
    return error;
}

int Image::width(){
    if(data)
        return specs[COLS];
    else
        return 0;
}

int Image::height(){
    if(data)
        if(specs[IS_COLOR])
            return specs[ROWS]/3;
        else
            return specs[ROWS];
    else
        return 0;
}


bool Image::isEmpty(){
    if (data == NULL) 
        return true;
    else
        return false;
}

bool Image::isColor(){
    if (specs[IS_COLOR])
        return true;
    else
        return false;
}


void Image::errclear(){
    error=0;
}

void Image::free(){
    if(data != NULL){
        delete[] data;
        data = NULL;
    }
    if(commentSize != 0){
        delete[] comment;
        commentSize = 0;
        comment = NULL;
    }
    if(extraSize != 0){
        delete[] extra;
        extraSize = 0;
        extra = NULL;
    }
    specs[ROWS] = 0;
    specs[COLS] = 0;
    
}

void Image::zero(){
    int npts=specs[ROWS]*specs[COLS];
    DATAWORD* mydatpt=data;
    while ( mydatpt < data+npts ) {
        *mydatpt++ = 0;
    }
}


void Image::clip(DATAWORD clipVal){
    int npts=specs[ROWS]*specs[COLS];
    DATAWORD* mydatpt=data;
    while ( mydatpt < data+npts ) {
        if ( *mydatpt > clipVal ) *mydatpt = clipVal;
        mydatpt++;
    }
}

void Image::floor(DATAWORD floorVal){
    int npts=specs[ROWS]*specs[COLS];
    DATAWORD* mydatpt=data;
    while ( mydatpt < data+npts ) {
        if ( *mydatpt < floorVal ) *mydatpt = floorVal;
        mydatpt++;
    }
}

void Image::abs(){
    int npts=specs[ROWS]*specs[COLS];
    DATAWORD* mydatpt=data;
    while ( mydatpt < data+npts ) {
        *mydatpt = fabs(*mydatpt);
        mydatpt++;
    }
}

DATAWORD Image::min()
{
    if(specs[HAVE_MAX] == 0) getmaxx(NO_PRINT);
    return values[MIN];
}

DATAWORD Image::max()
{
    if(specs[HAVE_MAX] == 0) getmaxx(NO_PRINT);
    return values[MAX];
}

void Image::getmaxx(char printFlag)
{
    DATAWORD *locmin,*locmax,*locrmin,*locrmax,*locgmin,*locgmax,*locbmin,*locbmax;
    DATAWORD *mydatpt;
    DATAWORD rmax=0,gmax=0,bmax=0,rmin=0,gmin=0,bmin=0;
    int npts=specs[ROWS]*specs[COLS];
    
    //if( specs[HAVE_MAX] == 1)return;      // Disable for now. May want to add an argument to this to look at the
                                            // flag or not.
    if(data == NULL || specs[ROWS] < 1  || specs[COLS] < 1){
        error = MEM_ERR;
        return;
    }
    
    mydatpt = data;
    locmin = locmax = mydatpt;
    locrmin = locrmax = locgmin = locgmax = locbmin = locbmax = mydatpt;
    
    if(specs[IS_COLOR]){ 
        for (locrmin = locrmax = mydatpt; mydatpt < data+npts/3; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locrmax ) locrmax = mydatpt;
            if ( *mydatpt < *locrmin ) locrmin = mydatpt;
        }
 
        for (locgmin = locgmax = mydatpt; mydatpt < data+2*npts/3; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locgmax ) locgmax = mydatpt;
            if ( *mydatpt < *locgmin ) locgmin = mydatpt;
        }

        for (locbmin = locbmax = mydatpt; mydatpt < data+npts; mydatpt++ ) {
            if ( *mydatpt > *locmax )  locmax = mydatpt;
            if ( *mydatpt < *locmin )  locmin = mydatpt;
            if ( *mydatpt > *locbmax ) locbmax = mydatpt;
            if ( *mydatpt < *locbmin ) locbmin = mydatpt;
        }
        rmax = *locrmax;
        rmin = *locrmin;
        gmax = *locgmax;
        gmin = *locgmin;
        bmax = *locbmax;
        bmin = *locbmin;

    } else{
        while ( mydatpt < data+npts ) {
            if ( *mydatpt > *locmax ) locmax = mydatpt;
            if ( *mydatpt < *locmin ) locmin = mydatpt;
            mydatpt++;
        }
        
    }
    values[MIN] = *locmin;
    values[MAX] = *locmax;
    values[RMAX] = rmax;
    values[RMIN] = rmin;
    values[GMAX] = gmax;
    values[GMIN] = gmin;
    values[BMAX] = bmax;
    values[BMIN] = bmin;
    
    specs[LMIN] = (int)(locmin - data);
    specs[LMAX] = (int)(locmax - data);
    specs[LRMIN] = (int)(locrmin - data);
    specs[LRMAX] = (int)(locrmax - data);
    specs[LGMIN] = (int)(locgmin - data - npts/3);
    specs[LGMAX] = (int)(locgmax - data - npts/3);
    specs[LBMIN] = (int)(locbmin - data - 2*npts/3);
    specs[LBMAX] = (int)(locbmax - data - 2*npts/3);

    specs[HAVE_MAX] = 1;
    
    /*
     lmx = (int) (locmax - datpt - doffset);
     lmn = (int) (locmin - datpt - doffset);
     n = header[NCHAN];
     header[LMAX] = lmx/n;	      		// This is the row of the max 
     header[NMAX] = lmx - lmx/n*n;   	// Column of max 
     header[LMIN] = lmn/n;	      		// This is the row of the min 
     header[NMIN] = lmn - lmn/n*n;   	// Column of min 
     */
    if (printFlag) {
        if(specs[IS_COLOR]){
            printf("Red Maximum %g at Row %d and Column %d\n", values[RMAX], specs[LRMAX]/specs[COLS], specs[LRMAX]%specs[COLS]);
            printf("Red Minimum %g at Row %d and Column %d\n\n", values[RMIN], specs[LRMIN]/specs[COLS], specs[LRMIN]%specs[COLS]);
            
            printf("Green Maximum %g at Row %d and Column %d\n", values[GMAX], specs[LGMAX]/specs[COLS], specs[LGMAX]%specs[COLS]);
            printf("Green Minimum %g at Row %d and Column %d\n\n", values[GMIN], specs[LGMIN]/specs[COLS], specs[LGMIN]%specs[COLS]);
            
            printf("Blue Maximum %g at Row %d and Column %d\n", values[BMAX], specs[LBMAX]/specs[COLS], specs[LBMAX]%specs[COLS]);
            printf("Blue Minimum %g at Row %d and Column %d\n", values[BMIN], specs[LBMIN]/specs[COLS], specs[LBMIN]%specs[COLS]);
            
        } else {
            printf("Maximum %g at Row %d and Column %d\n", values[MAX], specs[LMAX]/specs[COLS], specs[LMAX]%specs[COLS]);
            printf("Minimum %g at Row %d and Column %d\n", values[MIN], specs[LMIN]/specs[COLS], specs[LMIN]%specs[COLS]);
        }
    }
    
}

void Image::saveFile(char* name, int kindOfName){
    char txt[HEADLEN];
    int nspecs = NSPECS;
    int nvalues = NVALUES;
    int nrulerchar = NRULERCHAR;
    int fd;
    
    strncpy(windowName, name, CHPERLN);
    trimName(windowName);
    windowNameMemory = 2;

    
    switch (kindOfName) {
        case LONG_NAME:
            fd = open(name,WMODE);
            break;
        case SHORT_NAME:
            fd = open(fullname(name,SAVE_DATA),WMODE);
            break;
        case HAS_SUFFIX:
            fd = open(fullname(name,RAW_DATA),WMODE);    // means don't add the suffix
            break;
        case LEAVE_OPEN:
            fd = *(int*)name;    // assumes the argument is a valid fd; don't close the file
            break;
        case IS_OPEN:
            fd = *(int*)name;    // assumes the argument is an open fd; don't write the header information
            break;
        default:
            fd = -1;
            break;
    }
    
    if(fd == -1) {
		beep();
		error = FILE_ERR;
        windowNameMemory = 0;
        return;
	}
    if (kindOfName != IS_OPEN) {
        // write the header
        strcpy(txt, OMA2_BINARY_DATA_STRING);
        write(fd,txt,HEADLEN);   // data identifier string
        // now write information on the sizes of fixed-length buffers (in case this changes)
        write(fd,&nspecs,sizeof(int));
        write(fd,&nvalues,sizeof(int));
        write(fd,&nrulerchar,sizeof(int));
        // now write the image data minus the pointers
        write(fd,this,sizeof(Image)- NUM_IMAGE_PTRS*sizeof(Ptr));
        if (commentSize) {
            write(fd,comment,commentSize);
        }
        if (extraSize) {
            write(fd,extra,extraSize*sizeof(float));
        }
    }
    // now the data
    write(fd,data,sizeof(DATAWORD)*specs[ROWS]*specs[COLS ]);
    

    if(kindOfName != IS_OPEN && kindOfName != LEAVE_OPEN){
        close(fd);
    }
    error = NO_ERR;
    
}

void Image::saveFile(char* name, int kindOfName, int kindOfInt){
    char txt[HEADLEN];
    int nspecs = NSPECS;
    int nvalues = NVALUES;
    int nrulerchar = NRULERCHAR;
    int fd;
    int npts=specs[ROWS]*specs[COLS];
    
    strncpy(windowName, name, CHPERLN);
    trimName(windowName);
    windowNameMemory = 2;

    
    switch (kindOfName) {
        case LONG_NAME:
            fd = open(name,WMODE);
            break;
        case SHORT_NAME:
            fd = open(fullname(name,SAVE_DATA),WMODE);
            break;
        case HAS_SUFFIX:
            fd = open(fullname(name,RAW_DATA),WMODE);    // means don't add the suffix
            break;
        case LEAVE_OPEN:
            fd = *(int*)name;    // assumes the argument is a valid fd; don't close the file
            break;
        case IS_OPEN:
            fd = *(int*)name;    // assumes the argument is an open fd; don't write the header information
            break;
        default:
            fd = -1;
            break;
    }
    
    if(fd == -1) {
        beep();
        error = FILE_ERR;
        windowNameMemory = 0;
        return;
    }
    bool needsUpdate=0;
    switch (kindOfInt){
        case UNSIGNED16:
            // clip any out of bounds values
            if (values[MIN] < 0.) {
                floor(0.);
                values[MIN] = 0;
                needsUpdate=1;
            }
            if (values[MAX] > UINT16_MAX) {
                clip(UINT16_MAX);
                values[MAX] = UINT16_MAX;
                needsUpdate=1;
            }
            specs[SAVE_FORMAT] = UNSIGNED16;
            if (needsUpdate) update_UI();
            break;
        case SIGNED16:
            // clip any out of bounds values
            if (values[MIN] < INT16_MIN) {
                floor(INT16_MIN);
                values[MIN] = INT16_MIN;
                needsUpdate=1;
            }
            if (values[MAX] > INT16_MAX) {
                clip(INT16_MAX);
                values[MAX] = INT16_MAX;
                needsUpdate=1;
            }
            specs[SAVE_FORMAT] = SIGNED16;
            if (needsUpdate) update_UI();
            break;
        case UNSIGNED8:
            // clip any out of bounds values
            if (values[MIN] < 0.) {
                floor(0.);
                values[MIN] = 0;
                needsUpdate=1;
            }
            if (values[MAX] > UCHAR_MAX) {
                clip(UINT16_MAX);
                values[MAX] = UCHAR_MAX;
                needsUpdate=1;
            }
            specs[SAVE_FORMAT] = UNSIGNED8;
            if (needsUpdate) update_UI();
            break;
        case SIGNED8:
            // clip any out of bounds values
            if (values[MIN] < CHAR_MIN) {
                floor(INT16_MIN);
                values[MIN] = CHAR_MIN;
                needsUpdate=1;
            }
            if (values[MAX] > CHAR_MAX) {
                clip(INT16_MAX);
                values[MAX] = CHAR_MAX;
                needsUpdate=1;
            }
            specs[SAVE_FORMAT] = SIGNED8;
            if (needsUpdate) update_UI();
            break;
        default:
            beep();
            error = FILE_ERR;
            windowNameMemory = 0;
            return;
    }
    
    if (kindOfName != IS_OPEN) {
        // write the header
        strcpy(txt, OMA2_BINARY_DATA_STRING);
        write(fd,txt,HEADLEN);   // data identifier string
        // now write information on the sizes of fixed-length buffers (in case this changes)
        write(fd,&nspecs,sizeof(int));
        write(fd,&nvalues,sizeof(int));
        write(fd,&nrulerchar,sizeof(int));
        // now write the image data minus the pointers
        write(fd,this,sizeof(Image)- NUM_IMAGE_PTRS*sizeof(Ptr));
        if (commentSize) {
            write(fd,comment,commentSize);
        }
        if (extraSize) {
            write(fd,extra,extraSize*sizeof(float));
        }
    }
    // now the data
    switch (kindOfInt){
        case UNSIGNED16:
        {   // Note: Need the braces to limit the scope of the pointers
            unsigned short* convertedData = new unsigned short[npts];
            DATAWORD* mydatpt=data;
            unsigned short* newdatpt=convertedData;
            while ( mydatpt < data+npts ) {
                *newdatpt++ = *mydatpt++;
            }
            write(fd,convertedData,sizeof(unsigned short)*npts);
            delete[] convertedData;
            break;
        }
        case SIGNED16:
        {
            short* convertedData = new short[npts];
            DATAWORD* mydatpt=data;
            short* newdatpt=convertedData;
            while ( mydatpt < data+npts ) {
                *newdatpt++ = *mydatpt++;
            }
            write(fd,convertedData,sizeof(short)*npts);
            delete[] convertedData;
            break;
        }
        case UNSIGNED8:
        {   // Note: Need the braces to limit the scope of the pointers
            unsigned char* convertedData = new unsigned char[npts];
            DATAWORD* mydatpt=data;
            unsigned char* newdatpt=convertedData;
            while ( mydatpt < data+npts ) {
                *newdatpt++ = *mydatpt++;
            }
            write(fd,convertedData,sizeof(unsigned char)*npts);
            delete[] convertedData;
            break;
        }
        case SIGNED8:
        {
            char* convertedData = new char[npts];
            DATAWORD* mydatpt=data;
            char* newdatpt=convertedData;
            while ( mydatpt < data+npts ) {
                *newdatpt++ = *mydatpt++;
            }
            write(fd,convertedData,sizeof(char)*npts);
            delete[] convertedData;
            break;
        }
    }

    if(kindOfName != IS_OPEN && kindOfName != LEAVE_OPEN){
        close(fd);
    }
    error = NO_ERR;
    
}


void Image::resize(int newRows, int newCols){
    
    if(specs[IS_COLOR]){
        newRows *= 3;
    }
    // allocate the new image
    Image resized(newRows,newCols);
    resized.copyABD(*this); // get the old specs, some of which will have to be changed
    resized.specs[ROWS] = newRows;
    resized.specs[COLS] = newCols;
    
    int i,j;
	float xi,yi,sx,sy;
    
	sx = (float)(specs[COLS]-1)/(float)(newCols-1);
	sy = (float)(specs[ROWS]-1)/(float)(newRows-1);
	
	for( j=0; j<newRows; j++) {
		for( i=0; i<newCols; i++) {
			xi = i * sx;
			yi = j * sy;
			resized.setpix(j,i,getpix(yi,xi));
		}
	}
    resized.specs[HAVE_MAX]=0;
    
    free();
    *this = resized;
    
    return;
}

DATAWORD* Image::getImageData(){                // returns a pointer to the data; use with extreme caution
    return data;
}

DATAWORD Image::getpix(int r ,int c)   // get a pixel value at the specified row and column
{
	if (data == NULL){
        error = MEM_ERR;
        return 0.;
    }
	if(c < 0) c = 0;
	if(r < 0) r = 0;
	if(c > specs[COLS]-1) c = specs[COLS]-1;
	if(r > specs[ROWS]-1) r = specs[ROWS]-1;
	return  *(data + c + r*specs[COLS]);
}

DATAWORD Image::getpix(float yi, float xi)

{
	float z,xf,yf;
	int ix,iy;
	DATAWORD z1,z2,z3,z4,a00,a11,a10,a01;

	ix = xi;
	iy = yi;
	
	if( (ix+1) >= specs[COLS] || (iy+1) >= specs[ROWS])
		return(getpix(iy,ix));
	
	xf = xi - ix;	/* the fraction part */
	yf = yi - iy;
	//		z3-----------z4
	//		|             |
	//		|             |
	//		|             |
	//		|             |
	//		|             |
	//      z1-----------z2
	
	z1 = getpix(iy,ix);
	z2 = getpix(iy,ix+1);
	z3 = getpix(iy+1,ix);
	z4 = getpix(iy+1,ix+1);

	// Bilinear Interpolation
    
	a00 = z1;
	a10 = z2 - z1;
	a01 = z3 - z1;
	a11 = z1 - z2 - z3 + z4;
	z = a00 + a10*xf + a01*yf + a11*xf*yf;
	
	return(z);
	
}


void Image::setpix(int r ,int c,DATAWORD val)   // set a pixel value at the specified row and column
{
	if (data == NULL){
        error = MEM_ERR;
        return;
    }
	if(c < 0) c = 0;
	if(r < 0) r = 0;
	if(c > specs[COLS]-1) c = specs[COLS]-1;
	if(r > specs[ROWS]-1) r = specs[ROWS]-1;
    *(data + c + r*specs[COLS]) = val;
}

int* Image::getspecs(){             // this allocates space for specs that the user must free
    int* thespecs;
    thespecs = new int [NSPECS];
    for(int i=0; i<NSPECS; i++){
        thespecs[i] = specs[i];
    }
    return thespecs;
}

int Image::rows(){             // this allocates space for specs that the user must free
    return specs[ROWS];
}

int Image::cols(){             // this allocates space for specs that the user must free
    return specs[COLS];
}


DATAWORD* Image::getvalues(){       // this allocates space for values that the user must free
   DATAWORD* thevalues = new DATAWORD[NVALUES];
    for(int i=0; i<NVALUES; i++){
        thevalues[i] = values[i];
    }
    return thevalues;
}

float* Image::getextra(){       // returns a copy of the extra data array
    float* theExtra = new DATAWORD[extraSize];
    for(int i=0; i<extraSize; i++){
        theExtra[i] = extra[i];
    }
    return theExtra;
}

void Image::setExtra(float* ext,int size){
    if (extra){
        delete[] extra;
        extra = NULL;
    }
    if (size <=0) {
        extraSize = 0;
        return;
    }
    extra = new float[size];
    for(int i=0; i<size; i++) extra[i] = ext[i];
    extraSize = size;
}

int Image::getExtraSize(){      // returns the size of the extra data array
    return extraSize;
}


char* Image::getunit_text(){       // this allocates space for unit text that the user must free
    char* thetext = new char[NRULERCHAR];
    for(int i=0; i<NRULERCHAR; i++){
        thetext[i] = unit_text[i];
    }
    return thetext;
}


char* Image::getComment()     // returns a copy of comment buffer (NULL if no such line)
{                               // this allocates space for text that the user must free
    char* thecomment = NULL;
    
    if (commentSize){
        thecomment = new char[commentSize];
        for(int i=0; i<commentSize;i++) thecomment[i]=comment[i];
    }
    return thecomment;
}

void Image::setComment(char* buffer,int n){
    if (comment){
        delete[] comment;
        comment = 0;
    }
    if (n<=2) {
        commentSize = 0;
        return;
    }
    comment = new char[n];
    for(int i=0; i<n; i++) comment[i] = buffer[i];
    commentSize = n;
}

void Image::setspecs(int* newspecs){
    // resize if necessary
    if(newspecs[ROWS]*newspecs[COLS] != specs[ROWS]*specs[COLS]){
        delete[] data;
        data =  new DATAWORD[newspecs[ROWS]*newspecs[COLS]];
        if (data==NULL) {
            specs[ROWS]=specs[COLS]=0;
            error = MEM_ERR;
            return;
        }
    }
    if (data == NULL) { // allocate if necessary
        data =  new DATAWORD[newspecs[ROWS]*newspecs[COLS]];
        if (data==NULL) {
            specs[ROWS]=specs[COLS]=0;
            error = MEM_ERR;
            return;
        }
    }
    if (specs[HAS_RULER] == 1 && newspecs[HAS_RULER] == 0) {
        // delete an existing ruler
        values[RULER_SCALE] = 1.0;
        unit_text[0] = 0;
    }
    for(int i=0; i<NSPECS; i++){
        specs[i] = newspecs[i];
    }
}

void Image::setvalues(float* newvalues){
    for(int i=0; i<NVALUES; i++){
        values[i] = newvalues[i];
    }
}

void Image::setRuler(float rulerScale, char* new_unit_text){
    specs[HAS_RULER] = 1;
    values[RULER_SCALE] = rulerScale;
    strcpy(unit_text, new_unit_text);
}

void Image::copyABD(Image im){    // copy All But Data from one image to another
    
    int i;
    
    for( i=0; i<NSPECS; i++){
        specs[i] = im.specs[i];
    }
    for( i=0; i<NVALUES; i++){
        values[i] = im.values[i];
    }

    for( i=0; i<NRULERCHAR; i++){
        unit_text[i] = im.unit_text[i];
    }

    error = im.error;
    is_big_endian = im.is_big_endian;
    commentSize = im.commentSize;
    comment = im.getComment();
    extraSize = im.extraSize;
    if (extraSize) {
        extra = new float[extraSize];
        for (i=0; i<extraSize; i++) {
            extra[i] = im.extra[i];
        }
    }
}

void Image::crop(rect crop_rect){
    int sizx,sizy,x0,y0;

    x0 = crop_rect.ul.h;
    y0 = crop_rect.ul.v;
    sizx = crop_rect.lr.h - crop_rect.ul.h +1;
    sizy = crop_rect.lr.v - crop_rect.ul.v +1;
    
    if(x0 + sizx > specs[COLS] || y0 + sizy > specs[ROWS]){
        //beep();
        //printf("Rectangle is not contained within the current image.\n");
        error = SIZE_ERR;
        return;
    }
    
    int save_rgb_rectangle = specs[IS_COLOR];
    
    if(save_rgb_rectangle){
        if( y0 + sizy*3 > specs[ROWS] ){
            //beep();
            //printf("Can't save rectangle as RGB image -- rectangle size problem.\n");
            error = SIZE_ERR;
            return;
        } else {
            sizy *= 3;
        }
    }
    
    // get a new image
    Image cropped_image(sizy,sizx);
    if (cropped_image.err()) {
        error = MEM_ERR;
        return;
    }
    
    cropped_image.copyABD(*this); // copy all but the data from the current image
    
    int i=0;
    for (int image_part = 0; image_part < (2 * save_rgb_rectangle)+1 ; image_part++){
		for(int nt=y0+image_part*specs[ROWS]/3; nt<=crop_rect.lr.v+image_part*specs[ROWS]/3; nt++) {
			for(int nc=x0; nc<=crop_rect.lr.h;nc++){
				*(cropped_image.data + i++) = *(data + nc + nt*specs[COLS]);
			}
		}
	}

    //printf("%d x %d Image.\n",sizx,sizy);
	//printf("Current image starts at: %d\t%d\n",x0,y0);
    
    cropped_image.specs[X0] = x0*specs[DX];
    cropped_image.specs[Y0] = y0*specs[DY];
    cropped_image.specs[ROWS] = sizy;
    cropped_image.specs[COLS] = sizx;
    cropped_image.specs[HAVE_MAX] = 0;
    
    this->free();
    *this = cropped_image;
    //return *this;
}

void Image::invert(){
    int size,i,ncolors;
	DATAWORD *datp2,*datp,temp;
	if (specs[IS_COLOR]) {
        size = specs[ROWS] * specs[COLS]/3;
        ncolors = 3;
    } else {
        size = specs[ROWS] * specs[COLS];
        ncolors=1;
    }
    for(int c=0; c<ncolors;c++){
        datp = data + c*size;
        datp2 = data + (c+1)*size -1;
        for(i=0; i < size/2 ; i++){
            temp = *(datp+i);
            *(datp+i) = *(datp2-i);
            *(datp2-i) = temp;
        }
    }
    if (ncolors == 1) {
        specs[LMAX] = size-1-specs[LMAX];
        specs[LMIN] = size-1-specs[LMIN];
    } else {
        specs[HAVE_MAX]=0;
    }
    //return *this;
}

void Image::mirror(){
	int nt,nc,size;
	DATAWORD *datp,temp;
	
	datp = data;
	size = specs[COLS]-1;
    
	for(nt=0; nt<specs[ROWS];nt++){
		for(nc=0; nc<specs[COLS]/2; nc++) {
			temp = *(datp+nc);
			*(datp+nc) = *(datp+size-nc);
			*(datp+size-nc) = temp;
		}
		datp += specs[COLS];
	}
	if (!specs[IS_COLOR]) {
        specs[LMAX] = specs[COLS] - 1 - specs[LMAX];
        specs[LMIN] = specs[COLS] - 1 - specs[LMIN];
    } else {
        specs[HAVE_MAX]=0;
    }
}

void Image::rotate(float angle){
    
    int size,nt,nc,width=0,height=0,midx=0,midy=0,vrel,hrel,i=0;
    float theta,sintheta=0,costheta=1,ntf,ncf,outsideval;
    
    theta = angle / 180.0 * PI;
    sintheta = sin(theta);
    costheta = cos(theta);
    
    if(angle == 180. || angle == -180.){
        invert();
        //return *this;
        return;
    }
    if(angle == 270. || angle == -90.){
        invert();
        angle=90.;
    }
    
    if(angle == 90.) {
        Image rotated(specs[COLS],specs[ROWS]); // new data space
        if(rotated.err()){
            error = MEM_ERR;
            //return *this;
            return;
        }
        rotated.copyABD(*this);                 // copy the specs etc.
        // rotate 90 degrees
        for(nc=specs[COLS]-1; nc >= 0; nc--) {
            for(nt=0; nt<specs[ROWS];nt++){
                *(rotated.data+i++) = *(data + nt*specs[COLS] + nc);
            }
        }
        
        rotated.specs[COLS] = specs[ROWS];
        rotated.specs[ROWS] = specs[COLS];
        rotated.specs[X0] = specs[Y0];
        rotated.specs[Y0] = specs[X0];
        rotated.specs[DX] = specs[DY];
        rotated.specs[DY] = specs[DX];
        
        rotated.specs[HAVE_MAX]=0;
        free();   // free old data buffer
        *this = rotated;
        //return *this;
        return;
    } else {
        printf("%f theta, %f sin, ",theta,sintheta);
        printf("%f cos\n",costheta);
        
        width = specs[COLS]*fabs(costheta) + specs[ROWS]*fabs(sintheta);
        height = specs[ROWS]*fabs(costheta) + specs[COLS]*fabs(sintheta);
        midx = width/2;
        midy = height/2;
        size = width * height;
        printf("%d %d width height\n",width,height);
        
        Image rotated(width,height); // new data space
        if(rotated.err()){
            error = MEM_ERR;
            //return *this;
            return;
        }
        rotated.copyABD(*this);                 // copy the specs etc.

        // for points outside the image, calculate the average of the perimeter
        outsideval = 0.0;
        for(nc=0; nc<specs[COLS]; nc++) {
            outsideval += *(data+nc);   //idat(0,nc);
            outsideval += *(data+nc+(specs[ROWS]-1)*specs[COLS]);
        }
        for(nt=1; nt<specs[ROWS]-1; nt++) {
            outsideval += *(data+nt*specs[COLS]); // idat(nt,0);
            outsideval += *(data+nt*specs[COLS]+specs[COLS]-1); // idat(nt,specs[COLS]-1);
        }
        outsideval = outsideval/(specs[COLS]+specs[ROWS]-2)/2;
        for(nt=0; nt<height;nt++){
            vrel = nt - midy;
            for(nc=0; nc<width; nc++) {
                hrel = nc-midx;
                ncf = hrel*costheta - vrel*sintheta + specs[COLS]/2.0;
                ntf = vrel*costheta + hrel*sintheta + specs[ROWS]/2.0;
                if( (ntf >= 0.0) && (ntf < (float)specs[ROWS]) &&
                   (ncf >= 0.0) && (ncf < (float)specs[COLS])   ) {
                    *(rotated.data+i++) = this->getpix(ntf,ncf);
                } else {
                    
                    *(rotated.data+i++) = outsideval;	
                }
            }
        }
        
        rotated.specs[COLS] = width;
        rotated.specs[ROWS] = height;
        rotated.specs[HAVE_MAX]=0;
        
        this->free();   // free old data buffer
        *this = rotated;
        //return *this;
        return;
    }
}

void Image::rgb2color(int color){
    rect cropr = {{0,0},{specs[COLS]-1,0}};
    int height=specs[ROWS]/3;
    cropr.ul.v = color*height;
    cropr.lr.v = color*height+height-1;
    // now have the crop rectangle
    specs[IS_COLOR] = 0;    // we're not color any more
    this->crop(cropr);
    //return *this;
}

void Image::composite(Image bottom){
    if( this->specs[COLS] != bottom.specs[COLS]){   // images have to be the same width
        error = SIZE_ERR;
        //return *this;
        return;
    }
    Image newim;            // an empty image
    newim.copyABD(*this);   // get the current specs    
    newim.data = new DATAWORD[(specs[ROWS]+bottom.specs[ROWS])* specs[COLS]]; // allocate space
    if (newim.data == NULL) {
        error = MEM_ERR;
        //return *this;
        return;
    }
    newim.specs[ROWS] = specs[ROWS]+bottom.specs[ROWS];
    // copy the data from the top (current) image
    int i;
    for(i=0; i<specs[ROWS]*specs[COLS]; i++){
        *(newim.data+i) = *(data+i);
    }
    // copy the data from the bottom image
    for(int j=0; j<bottom.specs[ROWS]*bottom.specs[COLS]; j++){
        *(newim.data+i++) = *(bottom.data+j);
    }
    
    newim.specs[HAVE_MAX] = 0;
    this->free();   // free old data buffer
    *this = newim;
    //return *this;
}

void Image::demosaic(Image input, int redX, int redY, int method){
    switch(method){
        case MALVAR:
            MalvarDemosaic(data, input.data, input.specs[COLS], input.specs[ROWS],redX,redY);
            break;
        default:
            BilinearDemosaic(data, input.data, input.specs[COLS], input.specs[ROWS],redX,redY);
    }
    
}

