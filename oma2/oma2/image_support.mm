#include "Image_support.h"

extern char reply[1024];
extern oma2UIData UIData;

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



char* fullname(char* fnam,int  type)
{

    static int have_full_name = 0;
    static int normal_prefix = 1;                   // this used for UPREFIX command
    
	char const *prefixbuf;		
	char const *suffixbuf;
	
	char long_name[CHPERLN];
	
	
	if( have_full_name ) return(fnam);
	
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
        default:
        case SAVE_DATA:
            prefixbuf = UIData.saveprefixbuf;		
            suffixbuf = UIData.savesuffixbuf;
            
	}
 	
	//strncpy(long_name,prefixbuf,CHPERLN);
	strcpy(long_name,prefixbuf);
	
	
	//n = CHPERLN - strlen(prefixbuf)-1;
	//strncat(long_name,fnam,n);		// add the middle of the file name 
	strcat(long_name,fnam);
    
	//n = CHPERLN - strlen(long_name)-1;
	//strncat(long_name,suffixbuf,n);	// prefix buf now has entire name 
	strcat(long_name,suffixbuf);
    
	if( (strlen(long_name) + 8) >= CHPERLN) {
	    //beep();
	    printf1(" File Name Is Too Long!\n"); 
	} else  {
	    //strncpy(fnam,long_name,CHPERLN);	// put the full name back in the command line 
	    strcpy(fnam,long_name);
    }
    //*(prefixbuf+n) = '\0';	// reset end of string in the prefix 
    return(fnam);
}

