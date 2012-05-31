#include "Image_support.h"

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



char* fullname(char* fnam,int  type)
{

    static int normal_prefix = 1;                   // this used for UPREFIX command
    
	char const *prefixbuf;		
	char const *suffixbuf;
	
	char long_name[CHPERLN];
	
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
 	
	
	strlcpy(long_name,prefixbuf,NEW_PREFIX_CHPERLN);
	
	
	//n = CHPERLN - strlen(prefixbuf)-1;
	//strncat(long_name,fnam,n);		// add the middle of the file name 
	strlcat(long_name,fnam,CHPERLN);
    
	//n = CHPERLN - strlen(long_name)-1;
	//strncat(long_name,suffixbuf,n);	// prefix buf now has entire name 
	strcat(long_name,suffixbuf);
    
	if( (strlen(long_name) + 8) >= CHPERLN) {
	    //beep();
	    printf1(" File Name Is Too Long!\n"); 
	} else  {
	    strlcpy(fnam,long_name,CHPERLN);
    }
    
    return(fnam);
}

/* ____________________________ load settings... ____________________________*/

int loadprefs(char* name)
{
    
    char oldname[CHPERLN];
    int fd;
    char txt[CHPERLN];
    extern Image iBuffer;

    extern char contents_path[];
    
    TWOBYTE	header[HEADLEN/2] = { 0,0,0,0,0,1,500,500,1,1,0,0,0,1,1 };
    TWOBYTE	trailer[TRAILEN/2];
    char	comment[COMLEN] = {0};
    TWOBYTE settings[16];
    

    
#ifdef DO_MACH_O
	getcwd(oldname,CHPERLN);
#endif
	if(name == nil) {
   		/*
		err = getfile_dialog(  PREFS_file);
		if(err) return -1;
#ifdef DO_MACH_O
        FSRefMakePath(&final_parentFSRef,(unsigned char*)curname,255);
        chdir(curname);
        //printf("%s\n",curname);
#endif
         */
	} else {
		if(strcmp(name,SETTINGSFILE) == 0){
			//chdir(contents_path);
		}
		strcpy(txt,name);
	}

    fd = open(txt,O_RDONLY);
    
    if(fd == -1) {
		//beep();
		return -1;
	}
	
	//oldfont = c_font;
	
    read(fd,(char*)header,HEADLEN);
    if (strcmp((const char*)header, SETTINGS_VERSION_1) == 0) {
        int nbytes = sizeof(oma2UIData);
        read(fd,(char*)UIData.saveprefixbuf,nbytes-HEADLEN);    // 
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
        //iBuffer.getmaxx();


        return 0;
    }
	
    read(fd,(char*)comment,COMLEN);
    read(fd,(char*)trailer,TRAILEN);
    
    Image tmp;
    process_old_header(header, comment, trailer, &tmp);
    iBuffer.setspecs(tmp.getspecs());
    
	/*
	if( detectorspecified == 0) {
		if(nbyte > 110*110*2) { // assume that big pics are CCD, small ones from a SIT 
			detector = CCD;
			doffset = 80;}
		else {
			detector = SIT;
			doffset = 0;
		}
	}
	nbyte += doffset*DATABYTES; 
	nbyte = (nbyte+511)/512*512;
	
	if(nbyte == 0 || checkpar()==1) {
		beep();
		printf(" Problem in Default Settings!\n");
		header[NCHAN] = header[NTRAK] = 1;
	}
	*/
	
    
	
  	read(fd,(char*)UIData.saveprefixbuf,PREFIX_CHPERLN);		// file prefixes and suffixes 
  	read(fd,(char*)UIData.savesuffixbuf,PREFIX_CHPERLN);
  	read(fd,(char*)UIData.macroprefixbuf,PREFIX_CHPERLN);
  	read(fd,(char*)UIData.macrosuffixbuf,PREFIX_CHPERLN);
  	read(fd,(char*)UIData.graphicsprefixbuf,PREFIX_CHPERLN);
  	read(fd,(char*)UIData.graphicssuffixbuf,PREFIX_CHPERLN);
	
    
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
    
    
  	read(fd,(char*)UIData.getprefixbuf,PREFIX_CHPERLN);		// file prefixes and suffixes for get data commands
  	read(fd,(char*)UIData.getsuffixbuf,PREFIX_CHPERLN);
    
    close(fd);
	//err = setvol("", oldvol);
	//HSetVol(NULL,v_ref_num,dir_ID);
#ifdef DO_MACH_O
	chdir(oldname);
#endif
	//setfonts(oldfont,-1);		// removed
    /*
	if(Status_window != 0){
		SetPortWindowPort(Status_window);
        
		//setup_status_fonts();
		//printcmin_cmax();
		update_status();
	}
     */
	return 0;
	
}

int saveprefs(char* name)
{
    int fd = creat(name,PMODE);
    if(fd == -1) {
		//beep();
		return -1;
	}
    
    int nbytes = sizeof(oma2UIData);
    write(fd,(char*)&UIData,nbytes);
    

    close(fd);
    return 0;
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
        im->has_ruler = 1;
        
        scpt = (TWOBYTE*) &(im->ruler_scale);
        if(swap_bytes) {
            *(scpt+1) = trailer[RULER_SCALE];
            *(scpt) = trailer[RULER_SCALE+1];	
            // need to change the order of values in the trailer as well
            tmp_2byte = trailer[RULER_SCALE];
            trailer[RULER_SCALE] = trailer[RULER_SCALE+1];
            trailer[RULER_SCALE+1] = tmp_2byte;
        } else {
            *(scpt) = trailer[RULER_SCALE];
            *(scpt+1) = trailer[RULER_SCALE+1];
        }
        
        strcpy(im->unit_text,(char*) &trailer[RULER_UNITS]);
        if( im->unit_text[0] ){
            printf3("%f Pixels per %s.\n",im->ruler_scale,im->unit_text);
            
        } else {
            printf2("%f Pixels per Unit.\n",im->ruler_scale);
            
        }
    } else {
        im->has_ruler = 0;
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
	
    fd = open(name,O_RDONLY);
    if(fd == -1) {
        //beep();
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

