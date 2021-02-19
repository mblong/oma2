#include "image_support.h"


extern char reply[1024];
extern oma2UIData UIData;

/*
 These are general purpose C functions that may be used anywhere.
 The assumption is they don't use anything in the oma2 classes unless passed as arguments.
 */

/* ***************************** Support Routines **************************** */

void setUpUIData(){
    
    char text[NEW_PREFIX_CHPERLN];
    strcpy(UIData.version, SETTINGS_VERSION_1);
    extern RGBColor color[256][8];
    
    // setup color palettes
    strcpy(text,PALETTEFILE);
    UIData.thepalette = DEFAULTMAP;
    getpalettefile(text);
    
    strcpy(text,PALETTEFILE2);
    UIData.thepalette = FROMAFILE2;
    getpalettefile(text);
    
    strcpy(text,PALETTEFILE3
           );
    UIData.thepalette = FROMAFILE3;
    getpalettefile(text);
    
    int i, thedepth = 8;
    
    for(int thepalette = BGRBOW; thepalette <= BLUEMAP; thepalette++){
        switch(thepalette) {
            case GRAYMAP:
                for(i=0; i<NCOLORS; i++)
                    color[i][thepalette].red = color[i][thepalette].green =
                    color[i][thepalette].blue = i;
                break;
            case REDMAP:
                for(i=0; i<NCOLORS; i++) {
                    color[i][thepalette].red = i;
                    color[i][thepalette].green = color[i][thepalette].blue = 0; }
                break;
            case BLUEMAP:
                for(i=0; i<NCOLORS; i++) {
                    color[i][thepalette].blue = i;
                    color[i][thepalette].red = color[i][thepalette].green = 0; }
                break;
            case GREENMAP:
                for(i=0; i<NCOLORS; i++) {
                    color[i][thepalette].green = i;
                    color[i][thepalette].red = color[i][thepalette].blue = 0; }
                break;
            case BGRBOW:
                unsigned int thrd = (1 << thedepth)/3;
                unsigned int constant = NCOLORS/thrd;
                for (i=0; i<thrd; i++) {
                    color[i][thepalette].blue = i*constant;
                    color[i][thepalette].red = color[i][thepalette].green = 0;
                    color[i+thrd][thepalette].blue = thrd*constant - i*constant;
                    color[i+thrd][thepalette].green = i*constant;
                    color[i+thrd][thepalette].red = 0;
                    color[i+thrd*2][thepalette].red = i*constant;
                    color[i+thrd*2][thepalette].green = thrd*constant - i*constant;
                    color[i+thrd*2][thepalette].blue = 0;
                }
        }
    }
    // end of palette setup
    
    UIData.r_scale = 1.;
    UIData.g_scale = 1.;
    UIData.b_scale = 1.;
    
    UIData.alphaValue = 0.5;
    
    UIData.highlightSaturated = 0;
    UIData.highlightSaturatedRed = 255;
    UIData.highlightSaturatedGreen = 255;
    UIData.highlightSaturatedBlue = 0;
    
    UIData.decodeHobjFlag = 1;     // setting for automatic decoding Halcon .hobj files
    UIData.demosaicHobjFlag = HOBJ_NO_DEMOSAIC;    // setting for whether or not to demosaic after decoding
    UIData.clearHobjFlag = 0;    // setting for whether or not to automatically clear bad pixels
    UIData.displaySaturateValue = 1.; // when Scale is selected, cmax will be data max * displaySaturateValue

    UIData.autoFloatFlag=1;
}

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



char* fullname(char* fnam,int  type)
{
    
    extern int normal_prefix;                   // this used for UPREFIX command
    
    char const *prefixbuf;
    char const *suffixbuf;
    
    char long_name[CHPERLN];
    
    extern char applicationPath[];
    
    if( type == GET_DATA || type == SAVE_DATA ) {
        switch(normal_prefix) {
            case 0:
                type = GET_DATA;
                break;
            case -1:
                type = SAVE_DATA;
                break;
            default:
            case 1:
                break;
        }
    }
    
    switch (type) {
        case GET_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = UIData.getsuffixbuf;
            break;
        case SETTINGS_DATA:
            prefixbuf = UIData.graphicsprefixbuf;
            suffixbuf = UIData.graphicssuffixbuf;
            break;
            
        case MACROS_DATA:
            prefixbuf = UIData.macroprefixbuf;
            suffixbuf = UIData.macrosuffixbuf;
            break;
        case TIFF_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = ".tiff";
            break;
        case TIF_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = ".tif";
            break;
        case PDF_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = ".pdf";
            break;
        case FTS_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = ".fts";
            break;
        case RAW_DATA:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = "";
            break;
        case CSV_DATA:
            prefixbuf = UIData.saveprefixbuf;
            suffixbuf = ".csv";
            break;
        case SAVE_DATA_NO_SUFFIX:
            prefixbuf = UIData.saveprefixbuf;
            suffixbuf = "";
            break;
        case GET_DATA_NO_SUFFIX:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = "";
            break;
        case GET_FILENAMES:
            prefixbuf = UIData.getprefixbuf;
            suffixbuf = ".txt";
            break;
        case LOAD_SAVE_PREFIX:
            strcpy(UIData.saveprefixbuf,fnam);
            return fnam;
        case LOAD_GET_PREFIX:
            strcpy(UIData.getprefixbuf,fnam);
            return fnam;
        case LOAD_SAVE_SUFFIX:
            strcpy(UIData.savesuffixbuf,fnam);
            return fnam;
        case LOAD_GET_SUFFIX:
            strcpy(UIData.getsuffixbuf,fnam);
            return fnam;
        case LOAD_MACRO_PREFIX:
            strcpy(UIData.macroprefixbuf,fnam);
            return fnam;
        case LOAD_SETTINGS_PREFIX:
            strcpy(UIData.graphicsprefixbuf,fnam);
            return fnam;
        case LOAD_MACRO_SUFFIX:
            strcpy(UIData.macrosuffixbuf,fnam);
            return fnam;
        case LOAD_SETTINGS_SUFFIX:
            strcpy(UIData.graphicssuffixbuf,fnam);
            return fnam;
        default:
        case SAVE_DATA:
            prefixbuf = UIData.saveprefixbuf;
            suffixbuf = UIData.savesuffixbuf;
            
    }
#if defined (MACOS_UI) || (Qt_UI_Mac)
    strlcpy(long_name,prefixbuf,NEW_PREFIX_CHPERLN);
#else
    strcpy(long_name,prefixbuf);
#endif
    if (strlen(long_name) == 0) {
#if defined (MACOS_UI) || (Qt_UI_Mac)
        strlcpy(long_name,applicationPath,NEW_PREFIX_CHPERLN);
#else
        strcpy(long_name,applicationPath);
#endif
    }
    
    //n = CHPERLN - strlen(prefixbuf)-1;
    //strncat(long_name,fnam,n);        // add the middle of the file name
#if defined (MACOS_UI) || (Qt_UI_Mac)
    strlcat(long_name,fnam,CHPERLN);
#else
    strcat(long_name,fnam);
#endif
    //n = CHPERLN - strlen(long_name)-1;
    //strncat(long_name,suffixbuf,n);    // prefix buf now has entire name

#if defined (MACOS_UI) || (Qt_UI_Mac)
    strlcat(long_name,suffixbuf,CHPERLN);
#else
    strcat(long_name,suffixbuf);
#endif
    if( (strlen(long_name) + 8) >= CHPERLN) {
        beep();
        printf(" File Name Is Too Long!\n");
    } else  {
#if defined (MACOS_UI) || (Qt_UI_Mac)
        strlcpy(fnam,long_name,CHPERLN);
#else
        strcpy(fnam,long_name);
#endif
    }
  
    return(fnam);
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

int loadprefs(char* name)
{
    
    char oldname[CHPERLN];
    int fd;
    extern Image iBuffer;
    
    TWOBYTE	header[HEADLEN/2] = { 0,0,0,0,0,1,500,500,1,1,0,0,0,1,1 };
    TWOBYTE	trailer[TRAILEN/2];
    char	comment[COMLEN] = {0};
    TWOBYTE settings[16];
    
    int prefixLength = PREFIX_CHPERLN;
    
    
    
    
    getcwd(oldname,CHPERLN);
    
    if(name == nil) {
        /*
         // load using dialog
         err = getfile_dialog(  PREFS_file);
         if(err) return -1;
         #ifdef DO_MACH_O
         FSRefMakePath(&final_parentFSRef,(unsigned char*)curname,255);
         chdir(curname);
         //printf("%s\n",curname);
         #endif
         */
        return FILE_ERR;
    }
    
    unsigned long len = fsize(name);
    if(len > OLD_SETTINGS_LENGTH) prefixLength = NEW_PREFIX_CHPERLN;
    
    
    fd = open(name,READBINARY);
    
    if(fd == -1) {
        beep();
        printf("Could not load settings from %s\n",name);
        return FILE_ERR;
    }
    
    
    read(fd,(char*)header,HEADLEN);
    if (strcmp((const char*)header, SETTINGS_VERSION_1) == 0) {
        // read oma2 settings
        int nbytes = sizeof(oma2UIData);
        long actualCount = read(fd,(char*)UIData.saveprefixbuf,nbytes-HEADLEN);
        close(fd);
        int* thespecs = iBuffer.getspecs();
        thespecs[ROWS] = UIData.rows;
        thespecs[COLS] = UIData.cols;
        thespecs[X0] = UIData.x0;
        thespecs[Y0] = UIData.y0;
        thespecs[DX] = UIData.dx;
        thespecs[DY] = UIData.dy;
        thespecs[IS_COLOR] = UIData.iscolor;
        thespecs[Y0] = UIData.y0;
        iBuffer.setspecs(thespecs);
        //iBuffer.getmaxx(PRINT_RESULT);
        
        free(thespecs);
        long missingBytes = nbytes - HEADLEN - actualCount;
        //printf("%d missing\n",missingBytes);
        if(missingBytes >= 4*sizeof(int)){
            // set these default values
            UIData.highlightSaturated = 0;
            UIData.highlightSaturatedRed = 255;
            UIData.highlightSaturatedGreen = 255;
            UIData.highlightSaturatedBlue = 0;
            missingBytes -= 4*sizeof(int);
        }
        if(missingBytes >= 3*sizeof(int)){
            // set these default values
            UIData.decodeHobjFlag = 1;     // setting for automatic decoding Halcon .hobj files
            UIData.demosaicHobjFlag  = HOBJ_NO_DEMOSAIC;
            UIData.clearHobjFlag  = 0;      // whether or not to automatically call cclearbad_c
            missingBytes -= 3*sizeof(int);
        }

        if(missingBytes >= sizeof(float)){
            // set these default values
            UIData.displaySaturateValue = 1.0; // when Scale is selected, cmax will be data max * displaySaturateValue
            missingBytes -= sizeof(float);
        }

        return NO_ERR;
    }
    
    // read old oma settings files
    
    read(fd,(char*)comment,COMLEN);
    read(fd,(char*)trailer,TRAILEN);
    
    Image tmp;
    process_old_header(header, comment, trailer, &tmp);
    int* specs = tmp.getspecs();
    iBuffer.setspecs(specs);
    free(specs);
    
    
    read(fd,(char*)UIData.saveprefixbuf,prefixLength);		// file prefixes and suffixes
    read(fd,(char*)UIData.savesuffixbuf,prefixLength);
    read(fd,(char*)UIData.macroprefixbuf,prefixLength);
    read(fd,(char*)UIData.macrosuffixbuf,prefixLength);
    read(fd,(char*)UIData.graphicsprefixbuf,prefixLength);
    read(fd,(char*)UIData.graphicssuffixbuf,prefixLength);
    
    
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     pdatminmax = settings[0];					// for integration plots
     pstdscrnsize = settings[1];
     ponemax = settings[2];
     ponemin = settings[3];
     ponewidth = settings[4];
     poneheight = settings[5];
     poneplotwhite = settings[6];
     pintegrate = settings[7];
     pintx = settings[8];
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     sdatminmax = settings[0];				// for surface plots
     sstdscrnsize = settings[1];
     scolor = settings[2];
     surfmax = settings[3];
     surfmin = settings[4];
     surfwidth = settings[5];
     surfheight = settings[6];
     plotwhite = settings[7];
     incrementby = settings[8];
     persp = settings[9];
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     hautoscale = settings[0];				// for histogram plots
     hstdscrnsize = settings[1];
     histmax = settings[2];
     histmin = settings[3];
     histwidth = settings[4];
     histheight = settings[5];
     hclear = settings[6];
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     lgwidth = settings[0];					// for coutour plots
     lgheight = settings[1];
     nlevls = settings[2];
     ctrmax = settings[3];
     ctrmin = settings[4];
     datminmax = settings[5];
     stdscrnsize = settings[6];
     colorctrs = settings[7];
     noctrtyping = settings[8];
     inwhite = settings[9];
     //	linegraphicstofile = settings[10];
     //	linedrawing = settings[11];				// don't need to save/restore this
     */
    float clevls[10];
    read(fd,(char*)clevls,40);
    /*
     if(do_swap) swap_bytes_routine((char*)clevls,40,4);
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     pixsiz = settings[0];					// various things
     cmin = settings[1];
     cmax = settings[2];
     newwindowflag = settings[3];
     detector = settings[4];
     cminmaxinc = settings[5];
     autoupdate = settings[6];
     toolselected = settings[7];
     showselection = settings[8];
     docalcs = settings[9];
     autoscale = settings[10];
     dlen =	settings[11];
     dhi = settings[12];
     c_font = settings[13];
     s_font = settings[14];
     showruler = settings[15];
     
     
     if( detector != 0) detectorspecified = 1;	// If saved detector type is CCD, no
     //	automatic type switching based on
     //	image size will be done; if saved
     //	type is SIT, type switching will be
     //	enabled.
     
     */
    
    //read(fd,(char*)Nu200_par,CAM_PARMS*2);		// Parameters for the Nu200
    //read(fd,(char*)settings,64-CAM_PARMS*2);      // Get rid of this extra
    read(fd,(char*)settings,32);
    read(fd,(char*)settings,32);
    
    /*
     if(do_swap) swap_bytes_routine((char*)Nu200_par,CAM_PARMS*2,2);
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     
     star_time = settings[0];					// Star 1 Settings
     star_treg = settings[1];
     star_auto = settings[2];
     star_gain = settings[3];
     
     */
    read(fd,(char*)settings,32);
    /*
     if(do_swap) swap_bytes_routine((char*)settings,32,2);
     
     plotline = settings[0];					// moe various things
     
     enable_dcs = settings[1];				// ST-6 settings
     abg_state = settings[2];
     head_offset = settings[3];
     temp_control = settings[4];
     serial_port = settings[5];
     */
    float exposure_time,set_temp;
    read(fd,(char*)&exposure_time,4);
    read(fd,(char*)&set_temp,4);
    
    
    read(fd,(char*)UIData.getprefixbuf,prefixLength);		// file prefixes and suffixes for get data commands
    read(fd,(char*)UIData.getsuffixbuf,prefixLength);
    
    close(fd);
    //err = setvol("", oldvol);
    //HSetVol(NULL,v_ref_num,dir_ID);
    
    chdir(oldname);
    
    //setfonts(oldfont,-1);		// removed
    /*
     if(Status_window != 0){
     SetPortWindowPort(Status_window);
     
     //setup_status_fonts();
     //printcmin_cmax();
     update_status();
     }
     */
    return NO_ERR;
    
}

int saveprefs(char* name)
{
    //int fd = creat(name,PMODE);
    int fd = open(name,WMODE);
    if(fd == -1) {
        beep();
        printf("Could not open preferences: %s",name);
        return FILE_ERR;
    }
    
    int nbytes = sizeof(oma2UIData);
    write(fd,(char*)&UIData,nbytes);
    
    
    close(fd);
    return NO_ERR;
}

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
            printf("%f Pixels per %s.\n",im->values[RULER_SCALE],im->unit_text);
            
        } else {
            printf("%f Pixels per Unit.\n",im->values[RULER_SCALE]);
            
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

int getpalettefile(char* name)
{
    // read from a file into the palette specified by UIData.thepalette
    extern RGBColor color[256][8];
    
    unsigned short i;
    int fd;
    unsigned char thecolors[256];
    
    fd = open(name,READBINARY);
    if(fd == -1) {
        beep();
        return -1;
    }
    read(fd,thecolors,256);
    for(i=0; i<256; i++)
        color[i][UIData.thepalette].red = thecolors[i];
    
    read(fd,thecolors,256);
    for(i=0; i<256; i++)
        color[i][UIData.thepalette].green = thecolors[i];
    
    read(fd,thecolors,256);
    for(i=0; i<256; i++)
        color[i][UIData.thepalette].blue = thecolors[i];
    
    return 0;
}

//********************************************************
//*** GTIFF - Import a greyscale TIFF file (8 or 16 bit)
//***         uses LibTIFF
//***         P. Kalt (2003) after J.Fielding
//********************************************************

#ifdef MacOSX_UI
int readTiff(char* filename,Image* im)
{
    
    uint16 		photometric;
    uint16 		compression;
    uint16 		bitspersample;
    uint16 		bytespersample;
    uint16 		config;
    uint32 		rowsperstrip = (uint32) -1;
    uint16 		fillorder = 1;
    
    uint16 		spp;
    TIFF 		*image;
    uint32 		w, h, countbyte;
    uint32 		*bytecounts;
    
    extern int is_big_endian;
    extern Variable user_variables[];
    
    //****/  V A R I A B L E S - Added by PKALT 8Apr03
    
    DATAWORD		*datpk2,*pt_green,*pt_blue;	// Pointer to buffer
    uint8  			*buffer, tempbyte;			// PKALT lets give it a try
    int				count;		// Loop counters...
    unsigned long	imageOffset;
    unsigned long	bufferSize;
    unsigned long	result;
    int				stripMax, stripCount;
    int				IFDPageNo;				// Page number for Multiple Images in 1 TIFF file
    tsize_t			stripSize;
    unsigned short		pkDW;
    int npts;
    
    IFDPageNo = 0;
    
    image = TIFFOpen(filename, "r");
    if (image == NULL) {
        beep();
        printf("Error Opening TIFF File %s\n", filename);
        return FILE_ERR;
    }
    
    //***
    //***  L i b T I F F   C A L L S   T O   G E T F I E L D
    //***
    //**  Move to the Right Directory (For multifile TIFF images)
    
    /* this seems to exclude tiff files from a movie sequence, so take it out
     
     for (count=0; count < IFDPageNo; count++){
     if (TIFFReadDirectory(image) == 0){
     beep();
     printf("File only has %d IFD's\n", count+1);
     return(-1);
     }
     }
     */
    // Read the TIFF fields
    TIFFGetField(image, TIFFTAG_PHOTOMETRIC, &photometric);
    
    if (TIFFGetField(image, TIFFTAG_FILLORDER, &fillorder)) {
        if(fillorder != FILLORDER_MSB2LSB) printf("Fill Order is strange!!\n");
    }
    
    if (TIFFGetField(image, TIFFTAG_BITSPERSAMPLE, &bitspersample)) {
        printf("%d bits per sample.\n",bitspersample);
    }
    bytespersample = (short)bitspersample/8;
    //printf("%d bytes per sample.\n",bytespersample);
    TIFFGetField(image, TIFFTAG_SAMPLESPERPIXEL, &spp);
    if (spp != 1 && spp != 3) {
        printf("Samples per pixel recorded as: %d\nDisregard...\n",spp);
        spp = 1;
    } else {
        printf("%d Samples per pixel\n",spp);
    }
    
    TIFFGetField(image, TIFFTAG_IMAGEWIDTH,  &w);
    TIFFGetField(image, TIFFTAG_IMAGELENGTH, &h);
    TIFFGetField(image, TIFFTAG_PLANARCONFIG, &config);
    
    if (config != PLANARCONFIG_CONTIG) {
        printf("Can only handle contiguous data packing\n");
    }
    TIFFGetField(image, TIFFTAG_COMPRESSION, &compression);
    
    if (TIFFGetField(image, TIFFTAG_ROWSPERSTRIP, &rowsperstrip)) {
        //printf("%d rows per strip.\n",rowsperstrip);
    }
    
    TIFFGetField(image, TIFFTAG_STRIPBYTECOUNTS, &bytecounts);
    
    // Find the number of strips in the image and their size
    stripSize = TIFFStripSize (image);
    stripMax = TIFFNumberOfStrips (image);
    imageOffset = 0;
    
    // Allocate the memory for the buffer used in TIFFReadImage
    bufferSize = TIFFNumberOfStrips (image) * stripSize;
    //printf("%d buff size\n",bufferSize);
    if((buffer = (uint8 *) malloc(bufferSize)) == NULL){
        beep();
        printf("Cannot Allocate Memory for TIFF File Read\n");
        return MEM_ERR;
    }
    
    // Sort out the OMA impdef variables for the header
    im->specs[COLS] = w;
    im->specs[ROWS] = h*spp;
    im->specs[DX] = im->specs[DY] = 1;
    im->specs[X0] = im->specs[Y0] = 0;
    npts = im->specs[COLS]*im->specs[ROWS];
    
    if(spp == 3){
        im->specs[IS_COLOR] = 1;
    } else {
        im->specs[IS_COLOR] = 0;
    }
    
    // Allocate memory for the new OMA image
    im->setspecs(im->specs);
    if(im->error){
        return MEM_ERR;
    }
    
    datpk2 = im->data;
    pt_green = datpk2 + h*w;
    pt_blue =  pt_green + h*w;
    
    // The number of TOTAL bytes remaining to be read (initially the whole lot)
    countbyte = w * h * bytespersample*spp;
    
    //Transfer the image from the LibTIFF to Buffers
    for (stripCount = 0; stripCount<stripMax; stripCount++){
        if((result = TIFFReadEncodedStrip (image, stripCount,
                                           buffer + imageOffset,
                                           stripSize)) == -1){
            beep();
            printf("Read error on input strip number %d\n", stripCount);
            return(-1);
        }
        imageOffset += result;
    }
    
    // Deal with Photometric Interpretations
    
    /*
     if(photometric != PHOTOMETRIC_MINISBLACK){
     // Flip bits
     printf("Fixing the Photometric Interpretation\n");
     for(count = 0; count< bufferSize; count++)
     buffer[count] = ~buffer[count];
     }
     */
    
    //if (photometric == PHOTOMETRIC_MINISBLACK) printf("Photometric: Min is BLACK\n");
    //if (photometric == PHOTOMETRIC_MINISWHITE) printf("Photometric: Min is WHITE\n");
    
    // Deal with the FILL Order
    if(fillorder != FILLORDER_MSB2LSB){
        // We need to swap bits - ABCDEFGH becomes HGFEDCBA
        printf("Fixing the Fill Order to Big Endian\n");
        for(count = 0; count<bufferSize; count++){
            tempbyte = 0;
            if(buffer[count] & 128) tempbyte += 1;
            if(buffer[count] & 64) tempbyte += 2;
            if(buffer[count] & 32) tempbyte += 4;
            if(buffer[count] & 16) tempbyte += 8;
            if(buffer[count] & 8) tempbyte += 16;
            if(buffer[count] & 4) tempbyte += 32;
            if(buffer[count] & 2) tempbyte += 64;
            if(buffer[count] & 1) tempbyte += 128;
            buffer[count] = tempbyte;
        }
    }
    
    //  Move the Buffer to the image
    for (count = 0; count < npts; count++) {
        if (bytespersample != 1) {
            if(is_big_endian)
                //pkDW =  ((buffer[count*bytespersample]<<8| buffer[count*bytespersample+1]))/2;
                pkDW =  ((buffer[count*bytespersample]<<8| buffer[count*bytespersample+1]));
            else
                pkDW =  ((buffer[count*bytespersample+1]<<8| buffer[count*bytespersample]));
        } else {
            pkDW = (DATAWORD)(buffer[count]);
        }
        if(spp == 3){
            switch (count%3){
                case 0:
                    *(datpk2++) = pkDW;
                    break;
                case 1:
                    *(pt_green++) = pkDW;
                    break;
                case 2:
                    *(pt_blue++) = pkDW;
                    break;
            }
        } else {
            *(datpk2++) = pkDW;
        }
    }
    
    //Clode the TIFF File using the LibTIFF call
    (void) TIFFClose(image);
    
    // Pass the OMA image to datpt
    
    // Free up loose memory
    if (buffer) _TIFFfree(buffer);
    
    if( bitspersample == 16){
        //trailer[SFACTR] = 2;
    }
    user_variables[0].fvalue = user_variables[0].ivalue = spp;
    return NO_ERR;
}
#endif

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
        beep();
        printf("Could not allocate %d x %d image\n",bin_rows,bin_cols);
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
        printf("%d Bytes read.\n",nr);
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
        printf("%d Bytes read.\n",nr);
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
        printf("%d Bytes read.\n",nr);
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
        printf("%d Bytes read.\n",nr);
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
    
    theImage->getmaxx(PRINT_RESULT);
    update_UI();
    
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
        beep();
        printf("Posible error is CSV file read.\n");
    }
    if(rows*cols < imageArray.size()){
        beep();
        printf("Can't make image from CSV file.\n");
        return MEM_ERR;
    }
    Image newIm(rows,cols);
    memcpy(newIm.data, &imageArray[0], imageArray.size()*sizeof(float));
    // I assume the memory from the vector will be freed when this goes out of scope.
    
    theImage->free();     // release the old data
    *theImage = newIm;   // this is the new data
    theImage->getmaxx(PRINT_RESULT);
    update_UI();

    return NO_ERR;
}

/* ********** */
int readHobj(char* filename,Image* theImage){
    int fd;
    extern int windowNameMemory;
    extern int bayer;
    char buffer[256];
    char* pointer;

    printf("Read .hobj format image.\n");
    
    fd = open(filename,READBINARY);
    if(fd == -1) {
        windowNameMemory = 0;
        return FILE_ERR;
    }
    unsigned long filesize = fsize(filename);
    read(fd,buffer,84);
    pointer = buffer+72;
    swap_bytes_routine(pointer,4,4);   // 4 bytes taken 4 at a time (1 int)
    int imagePixels = *((int*)pointer);
    
    swap_bytes_routine(buffer+80,4,2);   // 4 bytes taken two at a time (2 shorts)
    short rows = *((short*)buffer+40)+1;
    short cols = *((short*)buffer+41)+1;
    
    printf("Image width/height is %d x %d. %d image pixels\n",cols,rows, imagePixels);
    
    unsigned char* ptr2 = new unsigned char[rows*6]; // skip over this part that has row, start pix, end pix for each row
    if(ptr2 == 0) {
        close(fd);
        return MEM_ERR;
    }
    
    read(fd,ptr2,rows*6);	// skip over the header
    delete[] ptr2;
    
    printf("%d data offset.\n",84+rows*6 +16);
    read(fd,buffer,16);
    swap_bytes_routine(buffer,16,4); // 16 bytes taken 4 at a time (4 ints)
    
    int samplesPerPix = *(int*)buffer;
    /* Notes on color hobj files:
        if there are 3 samples per pixel (an rgb color image), just reading in three times the pixels
        and decoding doesn't work. Assuming the order is RGB, the green in not coded the same way -- it is
        stored as little endian and has none of the crossing 256 boundry stuff. There also seems to be some
        extra information so there is an offset on the on the LHS of the image
     */
    unsigned long bytesPerPix = *((int*)buffer+1);    // not sure what this is
    bytesPerPix = filesize/samplesPerPix/imagePixels;
    printf("%d samples per pixel; %d bytes per pixel\n",samplesPerPix,bytesPerPix);
    close(fd);
    
    // integer arguments to readBinary:
    //  bin_rows, bin_cols, bin_header, binary_file_bytes_per_data_point, swap_bytes_flag, unsigned_flag

    int bin_header = 84+rows*6 + 16;

    readBinary(filename,theImage,rows*samplesPerPix,cols,bin_header,(int)bytesPerPix,1, 1);
    
    if(bytesPerPix == 2 && UIData.decodeHobjFlag == 1){
        decodeHobj(theImage, theImage->width(), theImage->height());
    }
    
    if(UIData.clearHobjFlag !=0 && UIData.decodeHobjFlag == 1){
        bayer=1;
        clearbad_c(0, (char*)"");
    }
        
    if(UIData.demosaicHobjFlag !=HOBJ_NO_DEMOSAIC && UIData.decodeHobjFlag == 1){
        
        if (UIData.demosaicHobjFlag == HOBJ_DOC2RGB){
            int bayer[2][2] = {{0,1},{1,2}};
            int newrow = theImage->specs[ROWS]/2;
            int newcol = theImage->specs[COLS]/2;
            int row,col;
            Image red(newrow,newcol),green(newrow,newcol),blue(newrow,newcol);
            for (row=0; row < newrow*2; row++) {
                for (col=0; col < newcol*2; col++){
                    switch (bayer[row&1][col&1]){
                        case 0:		// red
                            red.setpix(row/2,col/2,theImage->getpix(row,col));   //*datp++;
                            break;
                        case 1:		// green
                            if(row&1){
                                green.setpix(row/2,col/2,(green.getpix(row/2,col/2)+theImage->getpix(row,col))/2.);
                            } else {
                                green.setpix(row/2,col/2,theImage->getpix(row,col));// =  *datp++;
                            }
                            break;
                        case 2:		// blue
                            blue.setpix(row/2,col/2,theImage->getpix(row,col));// *pt_blue++ =  *datp++;
                            break;
                    }
                }
                //if(header[NCHAN]&1) datp++;	// there may be an odd number of columns
            }
            red.composite(green);
            red.composite(blue);
            theImage->free();     // release the old data
            *theImage = red;   // this is the new data
            theImage->specs[IS_COLOR] = 1;
            green.free();
            blue.free();
        } else if(UIData.demosaicHobjFlag == HOBJ_BILINEAR){
            Image newIm(theImage->height()*3,theImage->width());
            if(newIm.err()){
                return newIm.err();
            }
            newIm.specs[IS_COLOR] = 1;
            newIm.demosaic(*theImage, 0, 0, 0);
            theImage->free();     // release the old data
            *theImage = newIm;   // this is the new data
            
        } else if(UIData.demosaicHobjFlag == HOBJ_MALVAR){
            Image newIm(theImage->height()*3,theImage->width());
            if(newIm.err()){
                return newIm.err();
            }
            newIm.specs[IS_COLOR] = 1;
            newIm.demosaic(*theImage, 0, 0, 1);
            theImage->free();     // release the old data
            *theImage = newIm;   // this is the new data
        }
            
    }
            
    theImage->getmaxx(PRINT_RESULT);
    update_UI();
    
    
    return NO_ERR;
}

/* ********** */

/***********************************************************************************
 Created:	17:9:2002
 FileName: 	hdrloader.cpp
 Author:		Igor Kravtchenko
 
 Info:		Load HDR image and convert to a set of float32 RGB triplet.
 ************************************************************************************/

int readHDR(char* filename,Image* im){
    
    DATAWORD	*datpk2,*pt_green,*pt_blue;	// Pointer to buffer
    HDRLoaderResult result;
    int returnOK,count,npts;
    float *hdrptr;
    extern char  *fullname();
    
    returnOK = loadHDR(filename, &result);
    
    if (!returnOK) {
        beep();
        printf("Could not load HDR from %s.\n", filename);
        return FILE_ERR;
    }
    
    printf("%d %d width height\n", result.width,result.height);
    
    // Sort out the OMA impdef variables for the header
    im->specs[COLS] = result.width;
    im->specs[ROWS] = result.height*3;
    im->specs[DX] = im->specs[DY] = 1;
    im->specs[X0] = im->specs[Y0] = 0;
    npts = im->specs[COLS]*im->specs[ROWS];
    
    im->specs[IS_COLOR] = 1;
    
    // Allocate memory for the new OMA image (including Headers)
    im->setspecs(im->specs);
    if(im->error){
        return MEM_ERR;
    }
    
    datpk2 = im->data;
    pt_green = datpk2 + result.width*result.height;
    pt_blue =  pt_green + result.width*result.height;
    hdrptr = result.cols;
    
    for (count = 0; count < npts; count++) {
        switch (count%3){
            case 0:
                *(datpk2++) = *(hdrptr++);
                break;
            case 1:
                *(pt_green++) = *(hdrptr++);
                break;
            case 2:
                *(pt_blue++) = *(hdrptr++);
                break;
        }
    }
    free(result.cols);
    
    return NO_ERR;
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
