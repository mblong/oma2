
#include "comdec.h"



extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;

ComDef   commands[] =    {
    {{"               "},	null},			
    {{"+              "},	plus_c},
    {{"-              "},	minus_c,},
    {{"*              "},	multiply_c},
    {{"/              "},	divide_c,},
    {{"^              "},	power_c,},
    {{"ADDFILE        "},	addfile_c},
    {{"ADDTMPIMAGE    "},	addtmp_c},
    {{"ABELINV        "},   abelinv_g},
    {{"ABELPREP       "},   abelprep_g},
    {{"ABELRECT       "},   abelrect_g},
    {{"ACCUMULATE     "},   accumulate_c},
    {{"ACDELETE       "},   acdelete_c},
    {{"ACADD          "},   acadd_c},
    {{"ACGET          "},   acget_c},

    {{"BLOCK          "},	block_g},
    {{"BIT8           "},	bit8_c},
    {{"BIT16          "},	bit16_c},
    {{"CALCULATE      "},	calc_cmd_c},
    {{"CALCALL        "},	calcall_c},
    {{"CLIP           "},	clip_c},
    {{"CLIPFRACTION   "},	clipfraction_c},
    {{"CLIPBOTTOM     "},	clipbottom_c},
    {{"CLIPFBOTTOM    "},	clipfbottom_c},
    {{"CROP           "},	croprectangle_c},
    {{"CROPR          "},	croprectangle_c},
    {{"COLUMNS        "},	columns_c},
    {{"COMPOSITE      "},	compositefile_c},
    {{"COMTEMPIMAGE   "},	comtmp_c},
    {{"COLORFLAG      "},	colorflag_c},
    {{"CYL2           "},	cyl2_g},
    {{"CMINMX         "},	setcminmax_c},
    {{"CLEARBADPIX    "},	clearbad_c},
    {{"CREATEFILE     "},	createfile_c},
    {{"CONCATFILE     "},	concatfile_c},
    {{"CLOSEFILE      "},	closefile_c},
    
    {{"DISPLAY        "},	display},
    {{"DMACRO         "},	defmac},
    {{"DMNMX          "},	dmnmx},
    {{"DIVFILE        "},	divfile_c},
    {{"DIVTMPIMAGE    "},	divtmp_c},
    {{"DIFFX          "},	diffx_c},
    {{"DIFFY          "},	diffy_c},
    {{"DCRAWARGS      "},	dcrawarg_c},
    {{"DELAY          "},	delay_c},
    {{"DX             "},	dx_c},
    {{"DY             "},	dy_c},
    {{"DOC2RGB        "},	doc2rgb_c},
    
    {{"ERASE          "},	erase},
    {{"ENDIF          "},	endifcmnd},
    {{"ECHO           "},	echo_c},
    {{"EXECUTE        "},	execut},
        
    {{"FLOATVARIABLE  "},	vfloat},
    {{"FCLOSE         "},	fclose_c},
    {{"FECHO          "},	fecho_c},
    {{"FOPEN          "},	fopen_c},
    {{"FRAME          "},	frame_c},
    {{"FTEMPIMAGE     "},	ftemp_c},
    {{"FFT            "},	dofft},
    {{"FOLD           "},	fold_g},
    {{"FINDBADPIX     "},	findbad_c},
    {{"FWDATMATLAB    "},	fwdatm_c},
        
    {{"GET            "},	getfile_c},
    {{"GETRGB         "},	getfile_c},
    {{"GETFILENAMES   "},	getFileNames_c},
    {{"GETSETTINGS    "},	getsettings},
    {{"GETFUNCTION    "},	getfun_c},
    {{"GMACRO         "},	gmacro_c},
    {{"GAUSSIAN       "},	gaussian_c},
    {{"GTEMPIMAGE     "},	gtemp_c},
    {{"GRADIENT       "},	gradient_c},
    {{"GREY2RGB       "},	grey2rgb_c},
    {{"GSMOOTH        "},	gsmooth_c},
    {{"GETNEXT        "},	getNext_c},
    
    {{"HELP           "},	help},
        
    {{"IF             "},	ifcmnd},
    {{"IFNOT          "},	ifnotcmnd},
    {{"INVERT         "},	invert_c},
    {{"INTEGRATE      "},	integrate_c},
    {{"INTFILL        "},	intfill_c},
    {{"INTVARIABLE    "},	vint},
        
    {{"KILLBOX        "},	killBox_c},
    {{"KWABEL         "},	kwabel_g},
        
    {{"LIST           "},	list_c},
    {{"LOG            "},	logg},
    {{"LMACRO         "},	lmacro},
    {{"LABELDATA      "},	labelData},
    {{"LOOP           "},	loop},
    {{"LOOPBREAK      "},	loopbreak},
    {{"LOOPND         "},	loopend},
    {{"LTEMPIMAGE     "},	ltemp_c},
    {{"LOOKUP         "},	lookup_c},
    {{"LN             "},	ln_c},
        
    {{"MACRO          "},	macro},
    {{"MAKNEW         "},	resize_c},
    {{"MIRROR         "},	mirror_c},
    {{"MULFILE        "},	mulfile_c},
    {{"MULTMPIMAGE    "},	multmp_c},
        
    {{"NEWWINDOW      "},	newWindow_c},
    {{"NEXTFILE       "},	nextFile_c},
        
    {{"OPENFILE       "},	openfile_c},
        
    {{"PIXSIZE        "},	pixSize_c},
    {{"PALETTE        "},	palette_c},
    {{"POSITIVE       "},	positive_c},
    {{"PAUSE          "},	imp_pause},
    {{"POWER          "},	power_c},
    {{"RMACRO         "},	rmacro},
    {{"RECTANGLE      "},	rectan_c},
    {{"RGB2GREY       "},	rgb2grey_c},
    {{"RGB2RED        "},	rgb2red_c},
    {{"RGB2GREEN      "},	rgb2green_c},
    {{"RGB2BLUE       "},	rgb2blue_c},
    {{"ROWS           "},	rows_c},
    {{"ROTATE         "},	rotate_c},
    {{"READBADPIX     "},	readbad_c},
    {{"RAMP           "},	ramp_c},
    {{"RNDOFF         "},	roundoff_c},
    {{"RNDUP          "},	roundUp_c},
    {{"RULER         "},	ruler_c},
    
    
    {{"SAVEFILE       "},	savefile_c},
    {{"SAVSETTINGS    "},	savsettings},
    {{"SATIFF         "},	satiff_c},
    {{"SATIFFSCALED   "},	satiffscaled_c},
    {{"SIZE           "},	size_c},
    {{"SINGRID        "},	sinGrid_c},
    {{"STEMPIMAGE     "},	stemp_c},
    {{"STRMACRO       "},	stringmacro_c},
    {{"STOPONERROR    "},	stopOnError},
    {{"SMOOTH         "},	smooth_c},
    {{"SUBFILE        "},	subfile_c},
    {{"SUBTMPIMAGE    "},	subtmp_c},
    {{"SHELL          "},	sysCommand_c},
    
    {{"TSMOOTH        "},	tsmooth_c},
    
    {{"UPREFIX       "},	uprefix_c},
    
    {{"VARIABLES      "},	variab},
    
    {{"WRITEBADPIX    "},	writebad_c},
    
    {{"X0             "},	x0_c},
    
    {{"Y0             "},	y0_c},
    
    {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},0}};


ComDef   hardwareCommands[] =    {
#ifdef ANDOR_
    {{"ANDOR          "},   andor},
#endif
    
#ifdef LJU3
    {{"AINPUT         "},   ain},
    {{"AOUTPUT        "},   aout},
#endif
    
#ifdef VISA
    {{"ASK            "},	ask},			/*  @gpib.c */
#endif

#ifdef GPHOTO
    {{"CAPTURE        "},	capture},
    {{"CAMLISTSETTINGS"},	camlistsettings},
    {{"CAMEXPOSE      "},	camexpose},
    {{"CAMGETSETTING  "},	camgetsetting},
    {{"CAMSETSETTING  "},	camsetsetting},
#endif

#ifdef VISA
    {{"CONECT         "},	conect},			/* @gpib.c */
#endif

#ifdef LJU3
    {{"DOUTPUT        "},   dout},
#endif

#ifdef GIGE_
    {{"GIGE           "},	gige},
#endif

#ifdef VISA
    {{"GPIBDV         "},	gpibdv},			/* @gpib.c */
#endif

#ifdef VISA
    {{"RECEIVE        "},	receiv},			/*  @gpib.c */
    {{"RUN            "},	run},               /*  @gpib.c */
#endif

#ifdef SERIAL_PORT
    {{"SERIAL         "},	serial},
    {{"SERCLOSE       "},	serclo},
#endif

#ifdef VISA
    {{"SEND           "},	send},			/*  @gpib.c */
#endif

    
#ifdef SBIG
    {{"SBIG           "},	sbig},
#endif

#ifdef LJU3
    {{"WAITHI         "},   waithi},
#endif
    {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},0}};


// if this is set, don't print anything
unsigned char no_print = 0;
unsigned char from_noprint=0;
unsigned char printall = 1;		// the flag for "priority only" printing

/* Things for loops in macros */

int var_char_count = 0;
short startval[NESTDEPTH];
short endval[NESTDEPTH];
short stepval[NESTDEPTH];
short lvar[NESTDEPTH];
short lvar_max = 0;
short loopdepth = 0;
short executedepth[EX_NEST_DEPTH] = {0};
short inloop = 0;

int branchto[NESTDEPTH];
int macro_line_number = 0;
int exe_line_number[EX_NEST_DEPTH] = {0};
int macro_stopable = 1;
int stopMacroNow = 0;
int int_value = 0;			//%v in a macro is replaced by this value
int inc_value = 1;			//%v is incremented by this amount after use
int last_x_val,last_y_val;	// %x and %y fill in values -- should come from mouse interaction


// Things for IF statements
int if_condition_met = 1;
int ifdepth = 0;
int if_condition[NESTDEPTH];
int error_return = 0;
int which_ex_buffer = -1;

int stop_on_error = 0;
int isErrorText = 0;

// Things for command history
#define HISTORY_BUFFER_SIZE 10000
char cmnd_history[HISTORY_BUFFER_SIZE];
int hist_index=0;
int selected_hist_index = 0;
int stored_commands=0;

//char* fullname();
int update_pause(),vprint(),get_variable_index();

char    commentBuffer[MBUFLEN] = {0};    	    	/* the comment buffer */

char    macbuf[MBUFLEN] = {0};    	    	/* the macro buffer */
char*   exbuf[EX_NEST_DEPTH];    	    	// the execute buffers 
char	macstring[COMLEN]={0};             /* strings that can be inserted in macros */
char	variable_names[VBUFLEN] = {0};		/* variable names in macros */

int     maccount,macflag,macptr,macval;
int     macincrement = 1;	/* the increment for macros */
int     exflag,exptr[EX_NEST_DEPTH],exval[EX_NEST_DEPTH];

int pause_flag = 0;
char pause_string[CHPERLN];



ComDef  *clist_ptr;
//extern ComDef my_commands[];

Variable user_variables[MAX_VAR] = {{{"command_return_1"},0,0.0,0,{""}},
    {{"command_return_2"},0,0.0,0,{""}},
    {{"command_return_3"},0,0.0,0,{""}},
    {{"command_return_4"},0,0.0,0,{""}},
    {{"command_return_5"},0,0.0,0,{""}},
    {{"command_return_6"},0,0.0,0,{""}},
    {{"command_return_7"},0,0.0,0,{""}},
    {{"command_return_8"},0,0.0,0,{""}},
    {{"command_return_9"},0,0.0,0,{""}},
    {{"command_return_10"},0,0.0,0,{""}}
};
int num_variables = 10;

// an array of expression elements
// this global array is used to evaluate the RHS of an assignment statement
// the elements can be numbers, variables, or operators
Expression_Element exp_el[CHPERLN];





int comdec(char* cmnd)
{
    int     c,i,cp,clst,j,k;
    int     chindx = 0;     /* index of first character after command */
    int     sign = 1;       /* sign of integer argument */
    int     ivalue = 0;     /* integer value */
    static int command_return;
    
    //extern char* exbuf[];     /* the execute buffer */
    char  txtbuf[CHPERLN];		// temp text buffer
    extern int maccount,macflag,macptr,macval,macincrement;
    extern int windowNameMemory;
    //extern int exflag,exptr[],exval[];
    
    int     (*fnc)(int,char*);
    
    stopMacroNow = 0;
    
    switch (command_return) {
        case GET_MACRO_LINE:
            command_return = error_return = defmac(1,cmnd);
            return command_return;
            break;
        case GET_COMMENT_LINE:
            command_return = error_return = logg(1,cmnd);
            return command_return;
            break;
            
        default:
            break;
    }
    
    while(true){
        chindx = 0;     /* index of first character after command */
        sign = 1;       /* sign of integer argument */
        ivalue = 0;     /* integer value */
        int assignmentDone = 0;
        
        
        
        /* --------------------- Code Starts Here ------------------------- */
        if (exflag == 0) which_ex_buffer=-1;    // this was not reset in the stop macro command, so do it now
        
        if (exflag) {
            
            /* Get next line from the execute buffer. */
            
            exptr[which_ex_buffer] = 0;
            for( i=0; i<exe_line_number[which_ex_buffer]; i++) {			// point to the appropriate line number
                while ( *(exbuf[which_ex_buffer] + exptr[which_ex_buffer]) != 0 )
                    exptr[which_ex_buffer]++;
                exptr[which_ex_buffer]++;
            }
            
            fill_in_command(cmnd,exbuf[which_ex_buffer]+exptr[which_ex_buffer],exval[which_ex_buffer]);
            /* sprintf(cmnd,exbuf+exptr,exval); */
            
            while ( *(exbuf[which_ex_buffer] + ++exptr[which_ex_buffer]) ) ;	// move past the current command
            
            /* Now have the command, echo it to terminal */
            
            exe_line_number[which_ex_buffer]++;					/* next line unless modified by loop */
            printf(" E-%d-%d: %s\n",which_ex_buffer+1,exe_line_number[which_ex_buffer],cmnd);
            
            /* Now adjust pointers */
            
            if ( *(exbuf[which_ex_buffer] + ++exptr[which_ex_buffer]) == EOL && (executedepth[which_ex_buffer] == loopdepth) ) {
                //if ( *(exbuf + ++exptr) == EOL && inloop == 0 ) {
                exval[which_ex_buffer]++;
                exptr[which_ex_buffer] = 0;
                // get rid of the execute buffer
                //free(exbuf[which_ex_buffer]);
                //printf("%d\n",exbuf[which_ex_buffer]);
                which_ex_buffer--;
                
                if(which_ex_buffer < 0){
                    exflag = 0;
                    if_condition_met = 1;
                }
            }
            //if(macro_stopable) checkevents();		// if the macro is stopable, check for possible events
            if(macro_stopable){
                checkEvents;
                if (stopMacroNow) {
                    stopmacro();
                }
            }
            
        } else {
            if (macflag) {
                
                // Get the appropriate line from the macro buffer.
                macptr = 0;
                for( i=0; i<macro_line_number; i++) {
                    while ( *(macbuf + macptr) != 0 )
                        macptr++;
                    macptr++;
                }
                
                fill_in_command(cmnd,macbuf+macptr,macval);
                
                /* Now have the command, echo it to terminal */
                
                macro_line_number++;				/* next line unless modified by loop */
                printf(" M%d: %s\n",macro_line_number,cmnd);
                
                while ( *(macbuf + (++macptr) ) ) ;
                
                /* Now adjust macro pointers */
                
                if ( *( macbuf+ ++macptr) == EOL  && inloop == 0) {
                    /* if (all commands have been done) */
                    //update_status();	     		/*  report the macro value used */
                    macval += macincrement;	     		/*  increment value */
                    macro_line_number = 0;				/* go back to the first line */
                    if ( --maccount == 0 ) {     		/* check for done with macros */
                        macflag = 0;
                        macro_line_number = lvar_max = loopdepth = var_char_count = 0;
                        //ifdepth = 0;
                        if_condition_met = 1;
                        if(from_noprint) {
                            keylimit(-2);
                            from_noprint = 0;
                        }
                    }
                }
                //if(macro_stopable)checkevents();		// if the macro is stopable, check for possible events
                if(macro_stopable){
                    checkEvents;
                    if (stopMacroNow) {
                        stopmacro();
                    }
                }
                // (such as cancel macro) before each command */
            }
            
            else {
                
                //getlin(txtbuf);   /* go get a line from the terminal */
                strcpy(txtbuf, cmnd);
                fill_in_command(cmnd,txtbuf,macval);
            }
        }
        cp = i = clst = 0;         /* cp is command pointer */
        
        clist_ptr = commands;
        
        // Now have the command text -- save that to history buffer, unless we are in a macro or execute
        if(!macflag && !exflag) { // don't buffer stuff going on inside macros and execs
            i = (int)strlen(cmnd);
            if(i>0){
                while( hist_index + i >= HISTORY_BUFFER_SIZE) {
                    // buffer full -- get rid of earliest commands
                    for(j=0; cmnd_history[j] != 0; j++){};
                    j+=2;	// j is the number of characters to be overwritten
                    for(k=0; k< hist_index ; k++){
                        if( k+j < HISTORY_BUFFER_SIZE) cmnd_history[k] = cmnd_history[k+j-1];  // overwrite oldest command
                    }
                    stored_commands--;
                    cmnd_history[hist_index - j]=0;
                    hist_index = hist_index - j+1;
                    
                }
                strcpy(&cmnd_history[hist_index],cmnd);
                cmnd_history[hist_index+i]=0;		// be sure EOL is in there
                hist_index +=  i+1;
                selected_hist_index = hist_index;
                stored_commands++;
                /*
                 // command history diagnostics
                 printf("%s\n%d stored; %d index\n",cmnd,stored_commands,hist_index);
                 for(i=0; i<hist_index; i++){
                 if(cmnd_history[i]!=0) printf("%c",cmnd_history[i]);
                 else printf("!");
                 }
                 printf("\n");
                 */
            }
        }
        
        i = 0;
        
        // First, check for an "=" --> means this is an assignment command
        while ( cmnd[i] != EOL  && cmnd[i]!= ';'){
            if ( cmnd[i++] == '='){
                if(if_condition_met) do_assignment(cmnd);		// don't do assignments if an if condition is not met
                if(exflag==0 && macflag==0) return NO_ERR;
                assignmentDone = 1;
            }
        }
        
        
        i = 0;
        // while not end of command ...
        while ( cmnd[i] != EOL  && cmnd[i] != ' ' && cmnd[i]!= ';' && !assignmentDone){
            if ( toupper(cmnd[i]) !=  clist_ptr[cp].text.name[i] ) {
                cp++;           /* next command */
                i = 0;
                if ( clist_ptr[cp].text.name[i] == EOL ){
                    if( clst == 0 ) {
                        clst = 1;
                        clist_ptr = hardwareCommands;
                        cp = 0;
                    } else {
                        beep();
                        printf("No such command: %s\n",cmnd);
                        if (macflag || exflag) {
                            i=-1;   // in a macro with invalid command
                            break;
                        }
                        return CMND_ERR;
                    }
                }
            } else {
                i++;
            }
        }
        if(i>=0 && !assignmentDone){    // we have a command from the list
            
            if (clst == 0 )
                fnc =  commands[cp].fnc;
            else
                fnc = hardwareCommands[cp].fnc;
            
            // next check for an integer argument
            ivalue = 0;
            if (cmnd[i] != EOL && cmnd[i] != ';') {
                chindx = ++i; // save a pointer to the first
                //   character after command
                while ( cmnd[i] != EOL && cmnd[i] != ';'
                       && cmnd[i] != ' ') {
                    c = cmnd[i++];
                    if (c == '+' )
                        sign *= 1;
                    if (c == '-' )
                        sign *= -1;
                    if (c >= '0' && c <= '9')
                        ivalue = 10 * ivalue + c - '0';
                }
            }
            ivalue *= sign;
            if (chindx == 0) {  // if no arguments, pass a null string
                *cmnd = 0;
            }
            
            // Now Execute the Appropriate Command -- unless this is in an IF whose condition is not met
            
            if(if_condition_met ||fnc == endifcmnd || fnc == ifcmnd){
                command_return = error_return = (*fnc)(ivalue,&cmnd[chindx]);
                if(exflag==0 && macflag==0) break;
            }
        }
        if (pause_flag) {
            break;
        }
    }
    windowNameMemory--;
    return command_return;
}


int fill_in_command(char* dest,char* source,int val)
{
	int i=0;
	int j=0;
	int k,l,m,n,match,nn,arg_index,numdig = 0;
	int is_arg = 0;
	//DateTimeRec datetime;
	//float ave_in_rect(),rms_in_rect();
    char txt[1024] = {0};
    
	extern char saveprefixbuf[], getprefixbuf[];
	extern char lastname[];
	
	extern TWOBYTE trailer[],header[];
	//extern int start_oma_time;
	//int oma_time;
	//float nclocks;
    
    int* specs= iBuffer.getspecs();
    DATAWORD* values = iBuffer.getvalues();
 	
	// ignore spaces or tabs at the beginning of a command
	while( *(source+i) == ' ' || *(source+i) == '\t') {
		i++;
	}
    
    /*    
     if (!if_condition_met) {    // don't do this command -- just copy ';' to destination
     *(dest+j++)= ';';
     *(dest+j)= '\0';
     return 0;
     }
     */	
	while( *(source+i) != '\0' ) {
        if(*(source+i) == ';') break;
		while( is_arg ){
			is_arg = 0;
			switch( *(source+i++)) {
                case '1':				// allow %3d for example -- include leading zeros
                case '2':				// no 2 digit lengths
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9':
                    i--;
                    numdig = *(source+i++) - '0';	// this should be the # of digits in the number
                    //pprintf("number of digits is %d\n",numdig);
                    is_arg = 1;						//	haven't cleared the arg yet -- it better be d
                    break;				
                case 'd':
                    if(numdig != 0) {
                        sprintf(txt,"%d",val);
                        //pprintf("digits: %d  length: %d\n",numdig,strlen(txt));
                        for(nn = (int)strlen(txt); nn < numdig; nn++){
                            *(dest+j++) = '0';
                        }
                        numdig = 0;
                    }
                    sprintf(dest+j,"%d",val);
                    while(*(dest+j)) 
                        j++;
                    
                    break;
                case 's':
                    sprintf(dest+j,"%s",macstring);
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'p':
                    txt[0] = 0;
                    sprintf(dest+j,"%s",fullname(txt, SAVE_DATA));
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'q':
                    txt[0] = 0;
                    sprintf(dest+j,"%s",fullname(txt, GET_DATA));
                    while(*(dest+j)) 
                        j++;
                    break;
/*				case 'f':
                    sprintf(dest+j,"%s",lastname);
                    while(*(dest+j)) 
                        j++;
                    break;*/
                case 'b':
                    sprintf(dest+j,DATAFMT,values[MAX]);
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'l':
                    sprintf(dest+j,DATAFMT,values[MIN]);
                    while(*(dest+j)) 
                        j++;
                    break;
/*                case 'm':
                    sprintf(dest+j,"%d",trailer[SFACTR]);
                    while(*(dest+j)) 
                        j++;
                    break;*/
                case 'v':
                    sprintf(dest+j,"%d",int_value);
                    int_value +=inc_value;
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'e':
                    sprintf(dest+j,"%d",error_return);
                    while(*(dest+j)) 
                        j++;
                    break;
/*                case 'a':
                    sprintf(dest+j,"%g",ave_in_rect());
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'r':
                    sprintf(dest+j,"%g",rms_in_rect());
                    while(*(dest+j)) 
                        j++;
                    break;*/
                case 'w':
                    sprintf(dest+j,"%d",specs[COLS]);
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'h':
                    sprintf(dest+j,"%d",specs[ROWS]);
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'x':
                    sprintf(dest+j,"%d",last_x_val);
                    while(*(dest+j)) 
                        j++;
                    break;
                case 'y':
                    sprintf(dest+j,"%d",last_y_val);
                    while(*(dest+j)) 
                        j++;
                    break;
                    
/*                case 'c':
                    oma_time = TickCount();
                    nclocks = oma_time - start_oma_time;
                    //oma_time /= CLOCKS_PER_SEC;
                    sprintf(dest+j,"%f",nclocks/60.);
                    while(*(dest+j)) 
                        j++;
                    break;*/
                    
/*                case 't':
                    GetTime(&datetime);
                    sprintf(dest+j,"%2d/%2d/%2d %2d:%2d:%2d",datetime.month,
                            datetime.day,
                            datetime.year%100,
                            datetime.hour,
                            datetime.minute,
                            datetime.second);
                    while(*(dest+j)) 
                        j++;
                    break;*/
                    
                default:
                    
                    break;
			}                 	// end of switch 
			// printf("Proc:%c. Next:%c\n",*(source+i-1),*(source+i)); 	
		} // end of is_arg processing
		
		if( *(source+i) == '\0' ) break; // end of command text
		
		if( *(source+i) == '\'' ) {			// a single quote will skip the following character without further interpretation
			i++;							// skip to next character
			*(dest+j++) = *(source+i++);	// just save the character
		}
		
		
		if( *(source+i) == '@' ) {			// this case for loop variable  or other variable
			i++;							// skip to next character 
			k = 0;
			// allow @4varnam -- similar to %4d
			// four digits with leading zeros
			if(*(source+i) > '0' && *(source+i) <='9'){
				// the digit is there
				numdig = *(source+i++) - '0';	// the # of digits in the number
			}
			while( (*(source+i) != ' ') && 
                  (*(source+i) != '\0') &&
                  (*(source+i) != '\\') &&		// Allow specification of end of variable with a '\'
                  (*(source+i) != ')') &&		// variable names can't have these special characters in them
                  (*(source+i) != '+') &&		// plus they could be there in arithmetic statements
                  (*(source+i) != '-') &&
                  (*(source+i) != '*') &&
                  (*(source+i) != '/') &&
                  (*(source+i) != '^') &&
                  (*(source+i) != '\t') &&
                  (*(source+i) != ';') ) {
                txt[k++] = *(source+i++);
			}
			
			txt[k] = '\0';			// txt now has the variable name
			m = 0;					// point to characters in the loop variable table 
			k = 0;					// indicate if a match was found 
			
			// look through the loop variables to find a match 
			for (n = 0; n<lvar_max; n++) {	
				match = 1;
				for( l = 0; *(variable_names+m) != '\0';l++) {
					// printf("%c",*(variable_names+m)); 
					if( *(variable_names+m)	!= txt[l] )
						match = 0;
					m++;
				}
				m++;
				
				if( txt[l] == '\0' && match == 1) {		// if true, we have the match
					k=1;
					//
					if(numdig != 0) {
						sprintf(txt,"%d",startval[n]);
						//pprintf("digits: %d  length: %d\n",numdig,strlen(txt));
						for(nn = (int)strlen(txt); nn < numdig; nn++){
							*(dest+j++) = '0';
						}
						numdig = 0;
					}	
					//
					sprintf(dest+j,"%d",startval[n]);	
					while(*(dest+j)) 
						j++;
					break;	// exit the variable search loop having put in the numeric value
				}
			}
			if( k == 0) {	// no loop variable -- check to see if there is another variable
				arg_index = get_variable_index(txt,0);
				if(arg_index < 0 ) {
                    *(dest+j) = 0; // end the returned command line here
                    if (if_condition_met) {     // only call out errors if we are actually doing this command
                        beep();
                        printf(" No variable to match %s.\n",txt);
                        return arg_index;
                    } else {
                        // this command isn't going to be done 
                        return 0;
                    }
				}
				if(user_variables[arg_index].is_float == -1){   // this is a string variable
					sprintf(dest+j,"%s",user_variables[arg_index].estring);
				} else {
					if(numdig != 0 ) {   
						if(user_variables[arg_index].is_float){
							sprintf(dest+j,"%f",user_variables[arg_index].fvalue);
							//pprintf("digits: %d  length: %d\n",numdig,strlen(txt));
							*(dest+j+numdig) = 0;	// mark end of string after a specified number of digits
						} else {
							sprintf(txt,"%d",user_variables[arg_index].ivalue);
							//pprintf("digits: %d  length: %d\n",numdig,strlen(txt));
							for(nn = (int)strlen(txt); nn < numdig; nn++){
								*(dest+j++) = '0';
							}
							numdig = 0;
						}	
					}
					if(user_variables[arg_index].is_float){
						if( numdig !=0){
							numdig=0;
						}else {
							sprintf(dest+j,"%g",user_variables[arg_index].fvalue);
						}
					} else {
						sprintf(dest+j,"%d",user_variables[arg_index].ivalue);
					}
				}
				while(*(dest+j)) 
					j++;
			}
            
            if(*(source+i) == '\\' ) i++;		// don't actually put the '\' in the command string
            // end of *(source+i) == @ case
		} else {
			if( *(source+i) != '%' ) {
				*(dest+j++) = *(source+i++);	// nothing special, just save the character
			} else {
				is_arg = 1;
				i++;
			}
		}
	}
	*(dest+j) = 0;
    
    free(specs);
    free(values);
	return 0;
}

int treat_as_float = 0;		// for arithmetic on RHS of assignment
// need to decide when to do float to integer conversion and when not to

// the command had an = in it, so do an assignment
// define variable on LHS if it isn't already defined
// evaluate RHS
int do_assignment(char* cmnd)
{
	//extern char cmnd[];
	
	int is_variable_char(char);
	
	int i,j,varlen;
	int var_index;
	char name[MAX_VAR_LENGTH];
	Expression_Element ex_result;
	
	// get rid of spaces or tabs in the command -- we just don't need them
	for(i=0; i< strlen(cmnd); i++){
		if(cmnd[i] == '"')  break;  // exception is if there is a string -- leave spaces after first quote
		if(cmnd[i] == ' ' || cmnd[i] == '	'){
			j= i;
			while(cmnd[j] != 0){
				cmnd[j] = cmnd[j+1];
				j++;
			}
			i--;	// maybe we have multiple spaces
		}
	}
	
	// get variable to left of "="
	i = varlen = 0;
	varlen = 0;
	while (cmnd[i] != '=' && varlen < MAX_VAR_LENGTH-1){
		name[varlen++] = cmnd[i++];
	}
	name[varlen] = 0;
    
	// get the index of this variable -- define it if not already there
	var_index = get_variable_index(name,1);
	if(var_index < 0) {
		beep();
		printf("Assignment error variable index:%d\n",var_index);
		return var_index;
	}
	
	// move pointer to the first character beyond the =
	while ( cmnd[i] != '=' ) i++;
	i++;
	
	// Now we are pointing to the RHS of the assignment statement
	//
	ex_result = evaluate_string(&cmnd[i]);	// get the result of the expression
	if( ex_result.op_char == 'e'){
		beep();
		printf("Assignment error -2\n");
		return -2;
	}
	if(ex_result.op_char == 's'){
		strcpy(&user_variables[var_index].estring[0],&ex_result.estring[0]);
		user_variables[var_index].is_float = -1;
	} else {
		if(treat_as_float)
			user_variables[var_index].ivalue = ex_result.fvalue;
		else
			user_variables[var_index].ivalue = ex_result.ivalue;
		user_variables[var_index].fvalue = ex_result.fvalue;
	}
	
	//printf("%d values; %c\n",rhs_vals,exp_el[0].op_char);
	vprint(var_index);
	return 0;
}

// return the index of a variable if it is already defined
// if def_flag == 1, define it if it is undefined
// if def_flag == 0, return error -2 if it is undefined
int get_variable_index(char* name, int def_flag)
{
	int i,j;
	//printf("lookup %s from %d variables\n",name,num_variables);
	// check to see if this is already defined
	for(i=0; i< num_variables; i++){
		for(j=0; j< strlen(name); j++){
			if( *(name+j) != user_variables[i].vname[j])
				break;
		}
		if( j == strlen(name) && j == strlen(user_variables[i].vname))
			return i;
	}
	
	if( i == num_variables && def_flag == 1){	// add a new variable to the list
		if(num_variables >= MAX_VAR){	// TOO MANY VARIABLES
			return -1;
		}
		for(j=0; j<= strlen(name); j++)
			user_variables[num_variables].vname[j] = *(name+j);
		user_variables[num_variables].ivalue = 0;
		user_variables[num_variables].fvalue = 0;
		user_variables[num_variables].is_float = 0;		// default is integer
		num_variables++;
		return num_variables-1;
	}
	return -2;	// undefined variable
}

int is_variable_char(char ch)
{
	if( ch == '+' || ch == '-' || ch == '*'|| ch == '/' || ch == ')' || ch == '^'
       || ch == '<'|| ch == '>' || ch == 0 )
		return 0;
	return 1;
}

// the argument here is the RHS of an assignment statement
// expression elements are picked off and placed in the global exp_el array
// 
Expression_Element evaluate_string(char* ex_string)
{	
	int is_variable_char(char);
	
	int i,j,k,varlen,rhs_vals;
	int arg_index,nestdepth;
	char vname[MAX_VAR_LENGTH] = {0};
	Expression_Element ex_result;
	/*
     printf("string is %s\n",ex_string);
     for(i=0; ex_string[i] != EOL && ex_string[i] != ';';i++){ 
     printf("%c",ex_string[i]);
     }
     */
	i= 0;
	rhs_vals = 0;
	treat_as_float = 0;
    // get the expression elements from the string
	while(ex_string[i] != EOL && ex_string[i] != ';'){ // While not the end of the command
		// if this is a string
		if( ex_string[i] == '"'){
			j = 0;
			while(ex_string[++i] != '"' && ex_string[i] != EOL){
				ex_result.estring[j++] = ex_string[i];
			}
			ex_result.estring[j] = 0;
			ex_result.op_char = 's';
			return(ex_result);
		}
		// if this is an operator
		if( ex_string[i] == '*' || ex_string[i] == '/' || ex_string[i] == '-' || ex_string[i] == '+' || ex_string[i] == '^'
           || ex_string[i] == ')'|| ex_string[i] == '('|| ex_string[i] == '>'|| ex_string[i] == '<'){
			exp_el[rhs_vals++].op_char = ex_string[i++];
		}
		// if this is a number
		else if( (ex_string[i] >= '0' && ex_string[i] <= '9') || ex_string[i] == '.'){ 
			if(ex_string[i] == '.') treat_as_float = 1;	// if there are numbers with decimal pts, treat the whole expression as float
			j = sscanf(&ex_string[i],"%d",&exp_el[rhs_vals].ivalue);
			j = sscanf(&ex_string[i],"%f",&exp_el[rhs_vals].fvalue);
			if(j != 1){
				beep();
				printf("Assignment error -4\n");
				ex_result.op_char = 'e';
				return(ex_result);	// some problem here
			}
			exp_el[rhs_vals].op_char = 'v';
			i++;
			rhs_vals++;
			while ( (ex_string[i] >= '0' && ex_string[i] <= '9') || ex_string[i]== '.'|| ex_string[i]== 'e'){
				if(ex_string[i] == '.') treat_as_float = 1;	// if there are numbers with decimal pts, treat the whole expression as float
				if(ex_string[i]== 'e'){
					if(ex_string[i+1] == '-' || ex_string[i+1] == '+') i++;	// skip a - or + after e
				}
				i++;	// skip rest of number
			}
		} else {
			// this may be a variable -- get the variable name
			varlen=0;
			while ( is_variable_char((char)ex_string[i]) == 1 && varlen < MAX_VAR_LENGTH-1){
				vname[varlen++] = ex_string[i++];
			}
			vname[varlen] = 0;
			
			arg_index = get_variable_index(vname,0);
			if(arg_index < 0) {
				beep();
				printf("Assignment error -- name: %s\n",vname);
				ex_result.op_char = 'e';
				return(ex_result);	// some problem here
			}
			exp_el[rhs_vals].ivalue = user_variables[arg_index].ivalue;
			exp_el[rhs_vals].fvalue = user_variables[arg_index].fvalue;
			if(user_variables[arg_index].is_float == -1) { // this is a string variable
				strcpy(&exp_el[rhs_vals].estring[0],&user_variables[arg_index].estring[0]); // copy the string too
				exp_el[rhs_vals].op_char = 's';
			} else {
				exp_el[rhs_vals].op_char = 'v';
			}
			rhs_vals++;
			//printf(" variable is %s; expression is %s\n", vname,&ex_string[i]);
		}
	}
	// have now filled in the exp_el array with all the expression elements
    // evaluate the expression elements
    if(rhs_vals == 1 && (exp_el[0].op_char == 'v' || exp_el[0].op_char == 's')){ // simple assignment
		ex_result =  exp_el[0];
		//vprint(var_index);
		return(ex_result);
	}
    // a more complicated expression
	nestdepth = 1;
	while(nestdepth >0){
        // process elements in parenthesis (if any)
		for(i=0; i<rhs_vals; i++){
			if(exp_el[i].op_char == '(') {	// look for matching )
				nestdepth++;
    inside:		for(j=i+1; j<rhs_vals; j++){
                    if(exp_el[j].op_char == '(') { // must be nested, start over
                        i = j;
                        nestdepth++;
                        goto inside;
                    }
                    if(exp_el[j].op_char == ')') { // matched pair, evaluate
                        ex_result = evaluate(i+1,j);
                        if( ex_result.op_char == 'e'){
                            beep();
                            printf("Assignment error -3\n");
                            ex_result.op_char = 'e';
                            return(ex_result);	// some problem here
                        }
                        
                        // now compress the expression
                        exp_el[i] = ex_result;
                        
                        for(k=j+1; k<rhs_vals; k++){
                            exp_el[i+k-j] = exp_el[k];
                        }
                        rhs_vals -= (j-i);
                        break;
                    }
                }
				
			}
		}
		nestdepth--;
	}
	
	ex_result = evaluate(0,rhs_vals);
	return(ex_result);
    
}


// evaluate expression elements from the global exp_el array
// start with element  'start', end with element 'end-1'
// these elements won't have any parenthesis in them
Expression_Element evaluate(int start, int end)
{
	int i,div_mul_result=0,last_op;
	Expression_Element eres;        // the expression result that will be returned
	float x,y;
	
	eres.ivalue = 0;
	eres.fvalue = 0.0;
	eres.op_char = 'e';
	
	
	// could begin with a unary operator
	if (exp_el[start].op_char == '-' && exp_el[start+1].op_char == 'v'){
		exp_el[start+1].ivalue = -exp_el[start+1].ivalue;
		exp_el[start+1].fvalue = -exp_el[start+1].fvalue;
		start++;
	}
    
	if (exp_el[start].op_char == '+' && exp_el[start+1].op_char == 'v'){
		start++;
	}
	
    // first process ^ * and /
	last_op = -2;
	for(i=start+1; i < end; i+= 2){
		if(exp_el[i].op_char == 'v' || exp_el[i+1].op_char != 'v')
			return eres; // error
		if(last_op != i-2)
            div_mul_result = i-1;	// this to take care of 2*3*4/5 case
		if (exp_el[i].op_char == '^'){	
			x = exp_el[div_mul_result].ivalue;
			y = exp_el[i+1].ivalue;
			exp_el[div_mul_result].ivalue = pow(x,y);
			exp_el[div_mul_result].fvalue = pow(exp_el[div_mul_result].fvalue,exp_el[i+1].fvalue);
			last_op = i;
		} else if (exp_el[i].op_char == '*'){			
			exp_el[div_mul_result].ivalue *= exp_el[i+1].ivalue;
			exp_el[div_mul_result].fvalue *= exp_el[i+1].fvalue;
			last_op = i;
		} else if (exp_el[i].op_char == '/'){
			exp_el[div_mul_result].fvalue /= exp_el[i+1].fvalue;
			// What about integer division by zero??
			// Do usual integer arithmetic rules if the divisor is not zero
			// if it is zero, take the value calculated by the floating point operation
			if(exp_el[i+1].ivalue != 0)
				exp_el[div_mul_result].ivalue /= exp_el[i+1].ivalue;
			else
				exp_el[div_mul_result].ivalue = exp_el[div_mul_result].fvalue+0.5;
			
			last_op = i;
		}
	}
	
	if(exp_el[start].op_char == 'v'){
		eres.ivalue = exp_el[start].ivalue;
		eres.fvalue = exp_el[start].fvalue;
	}
	// next process + -
	for(i=start+1; i < end; i+= 2){
		if(exp_el[i].op_char == 'v' || exp_el[i+1].op_char != 'v')
			return eres; // error
		if(exp_el[i].op_char == '+'){
			eres.ivalue += exp_el[i+1].ivalue;
			eres.fvalue += exp_el[i+1].fvalue;
		} else if (exp_el[i].op_char == '-'){
			eres.ivalue -= exp_el[i+1].ivalue;
			eres.fvalue -= exp_el[i+1].fvalue;
		}
        
		//printf("%c %d\n",eres.op_char,eres.ivalue);
	}	
	
    // next process < and >
	for(i=start+1; i < end; i+= 2){
		if(exp_el[i].op_char == 'v' || exp_el[i+1].op_char != 'v')
			return eres; // error
		if(exp_el[i].op_char == '<'){
			if(eres.fvalue<exp_el[i+1].fvalue){
				eres.ivalue = 1;
				eres.fvalue = 1.0;
			}else {
				eres.ivalue = 0;
				eres.fvalue = 0.0;
			}
		} else if (exp_el[i].op_char == '>'){
			if(eres.fvalue > exp_el[i+1].fvalue){
				eres.ivalue = 1;
				eres.fvalue = 1.0;
			}else {
				eres.ivalue = 0;
				eres.fvalue = 0.0;
			}
		}
        
		//printf("%c %d\n",eres.op_char,eres.ivalue);
	}	
    
	eres.op_char = 'v';
	return eres; 
	
    
}

int vprint(int index)
{
	if(user_variables[index].is_float > 0){
		printf("%s: %g\n", user_variables[index].vname,user_variables[index].fvalue);
	}else if(user_variables[index].is_float == 0){
		printf("%s: %d\n", user_variables[index].vname,user_variables[index].ivalue);
	}else{
		printf("%s: %s\n", user_variables[index].vname,&user_variables[index].estring[0]);
    }
	return 0;
}


/* ------------------------------------------------------------------------- */
/*									Commands								 */
/* ------------------------------------------------------------------------- */

// **********

 int null(int i,char* c){
     return 0;
 };

// **********

int display(int n, char* args){
    iBitmap = iBuffer;
    display_data;
    update_UI();
    return NO_ERR;
}

// **********

int dmnmx(int n, char* args){
    label_data_minMax;
    return NO_ERR;
}

// **********

int labelData(int n, char* args){
    label_data;
    return NO_ERR;
}
// **********

int erase(int n, char* args){
    if (*args == 0 || n < 0) { // of no argument or negative argument
        n = -1;
    }
    erase_window;
    return 0;
}


// ********** 

int imp_pause(int n,char* args)
{
    extern int macflag,exflag;
	
	if(*args == 0)
        sprintf(pause_string, "PAUSED");
    else
        strlcpy(pause_string,args,CHPERLN);
    // this string will be spoken during pause
    if (macflag || exflag) {    // don't set this unless we are in a macro
        pause_flag = 1;
    }
    
    update_status();
    alertSound(pause_string);
    return NO_ERR;
    
}
/*
// **********

int pmacro(int n)
{
    extern int maccount,macflag,macptr,macval;
    extern char* macbuf;
    
    if ( *macbuf == 0){
        beep();
        printf ("No Macro Defined.\n");
        return -1;
    }
    
    macro_line_number = lvar_max = loopdepth = var_char_count = inloop = 0;
    
    macflag = maccount = 1;
    macval = n;
    if (maccount <= 0) 
        maccount = 1;
    macptr = 0;
    return 0;
}
 
*/

/* ********** */

void clear_buffer_to_end(char* buffer)
{
	int i=0;	
	
	while( *(buffer+i++) ) {
		while( *(buffer+i++)){};
	}
	//printf("%d\n",i);
	while( i<MBUFLEN) 
		*(buffer+i++) = 0;
	
}

/* ********** */

//The LOG coommand

int logg(int n,char* args)
{
    int j,k,index=0;
    int nc = 1;
	char tempbuf[MBUFLEN];
	static int get_next_line = 0,i=0, line_num;
    
    if (!get_next_line) {
        
        if (n == 0) n = 1;
        line_num = n;
        // to get pointer no the next character, skip past n-1 zeros in the comment buffer
        
        j = n;
        while (--j) { 			// find the start of the specified line
            for(k = i; commentBuffer[i];i++ ){};
            i++;
            if ( k+1 == i) {
                beep();
                printf("Log Is Not That Long.\n");
                return ARG_ERR;
            }
            
        }
        //if(n > 1 && macbuf[i+1] != 0)i++;
        
        while ( (args[index] != EOL) && (args[index] != ';') ) {
            if(args[index++] == ' ') { 	// if there is a macro definition on this line
                j = (int)strlen(&args[index])+1;	// the length of what we are going to add
                nc = i;
                k = 0;
                if (*(commentBuffer+nc) != EOL){ // if there are more lines, they will have to be tacked on at the end
                    while (*(commentBuffer+nc++)){};	 // nc is now the start of the next line or EOL
                    
                    while(*(commentBuffer+nc) ) {
                        while(*(commentBuffer+nc))
                            *(tempbuf+k++) = *(commentBuffer+nc++);
                        *(tempbuf+k++) = *(commentBuffer+nc++);		/* remember the 0 */
                    }
                    /* printf("%d characters to be appended\n",k); */
                }
                
                if ( (i + k + j) >= MBUFLEN) {
                    beep();
                    printf ("Macro Buffer Overflow.\n");
                    return MEM_ERR;
                }
                while((args[index] != EOL) && (args[index] != ';')) {
                    *(commentBuffer+i++) = args[index++];
                }
                *(commentBuffer+i++) = EOL;
                
                for(j=0; j<k; j++) {
                    *(commentBuffer+i++) = *(tempbuf+j);
                }
                *(commentBuffer+i) = EOL;
                iBuffer.setComment(commentBuffer,i+1);
                i = 0;
                return NO_ERR;
            }
        }
        
        // at this point we are looking for new lines of text
        printf("Line #%d: ",line_num++);
        get_next_line = 1;
        return GET_COMMENT_LINE;
    }
    nc = (int)strlen(args);
    if (nc) {
        if ( (i+nc) >= MBUFLEN ) {
			beep();
            printf ("Macro Buffer Overflow.\n");
            *(commentBuffer+i) = EOL;
            clear_buffer_to_end(commentBuffer);
            get_next_line=i=0;
            return MEM_ERR;
        }
        
        for (j = 0;args[j];j++) {
            *(commentBuffer + i++) = args[j];
        }
        *(commentBuffer + i++) = EOL;
        printf("Line #%d: ",line_num++);
        return GET_COMMENT_LINE;
    }
    *(commentBuffer+i) = EOL;
	clear_buffer_to_end(commentBuffer);		/* insert trailing zeros after the comment */
    iBuffer.setComment(commentBuffer,i+1);
    get_next_line=i=0;
    
	return NO_ERR;
}

// **********


int defmac(int n,char* args)
{
    int j,k,index=0;
    int nc = 1;
	char tempbuf[MBUFLEN];
	static int get_next_line = 0,i=0, line_num;
    
    if (!get_next_line) {
        
        if (n == 0) n = 1;
        line_num = n;
        // to get pointer no the next character, skip past n-1 zeros in the macro buffer
        
        j = n;
        while (--j) { 			// find the start of the specified line
            for(k = i; macbuf[i];i++ ){};
            i++;
            if ( k+1 == i) {
                beep();
                printf("Macro Is Not That Long.\n");
                return ARG_ERR;
            }
            
        }
        //if(n > 1 && macbuf[i+1] != 0)i++;
        
        while ( (args[index] != EOL) && (args[index] != ';') ) {
            if(args[index++] == ' ') { 	// if there is a macro definition on this line
                j = (int)strlen(&args[index])+1;	// the length of what we are going to add
                nc = i;
                k = 0;
                if (*(macbuf+nc) != EOL){ // if there are more lines, they will have to be tacked on at the end
                    while (*(macbuf+nc++)){};	 // nc is now the start of the next line or EOL
                    
                    while(*(macbuf+nc) ) {
                        while(*(macbuf+nc))
                            *(tempbuf+k++) = *(macbuf+nc++);
                        *(tempbuf+k++) = *(macbuf+nc++);		/* remember the 0 */
                    }
                    /* printf("%d characters to be appended\n",k); */
                }
                
                if ( (i + k + j) >= MBUFLEN) {
                    beep();
                    printf ("Macro Buffer Overflow.\n");
                    return MEM_ERR;
                }
                while((args[index] != EOL) && (args[index] != ';')) {
                    *(macbuf+i++) = args[index++];
                }
                *(macbuf+i++) = EOL;
                
                for(j=0; j<k; j++) {
                    *(macbuf+i++) = *(tempbuf+j);
                }
                *(macbuf+i++) = EOL;
                i = 0;
                return NO_ERR;
            }
        }
        
        // at this point we are looking for new lines of text
        printf("Line #%d: ",line_num++);
        get_next_line = 1;
        return GET_MACRO_LINE;
    }
    nc = (int)strlen(args);
    if (nc) {
        if ( (i+nc) >= MBUFLEN ) {
			beep();
            printf ("Macro Buffer Overflow.\n");
            *(macbuf+i) = EOL;
            clear_buffer_to_end(macbuf);
            get_next_line=i=0;
            return MEM_ERR;
        }
        
        for (j = 0;args[j];j++) {
            *(macbuf + i++) = args[j];
        }
        *(macbuf + i++) = EOL;
        printf("Line #%d: ",line_num++);
        return GET_MACRO_LINE;
    }
    *(macbuf+i) = EOL;
	clear_buffer_to_end(macbuf);		/* insert trailing zeros after the macro */
    get_next_line=i=0;
	return NO_ERR;
}

// ********** 
int lmacro(int n, char* args)
{
    int lc,i;
    
    lc = 1;
    i = 0;
    while (*(macbuf+i)) {
        printf( "Line #%d: ",lc++);
		printf( "%s\n",macbuf+i);
        while (*(macbuf+i)) {
            i++;
        }
        i++;
    }
    return 0;
}

// ********** 

int macro(int n, char* args)
{
	//extern unsigned char from_noprint;
    if ( *macbuf == 0){
		beep();
        printf("No Macro Defined.\n");
        return CMND_ERR;
    }
	
	keylimit(-1);
	from_noprint = 1;
	rmacro(n,args);
	return NO_ERR;
    
}


// *********** 


int rmacro(int n, char* args)
{
    extern int maccount,macflag,macptr,macval,macincrement;
    
	int i;
	int j = 1;
	
	macro_line_number = lvar_max = loopdepth = var_char_count = inloop = 0;
    
    
    if ( *macbuf == 0){
		beep();
        printf("No Macro Defined.\n");
        return CMND_ERR;
    }
	
	macflag = 1;
    macval = 1;
    maccount = n/macincrement;
	if (n !=0) j = n;
    
	// Check to see if there was a second argument 
	
	for ( i = 0; args[i] != EOL; i++) {
		if(args[i] == ' ') { 
			sscanf(args,"%d %d",&i,&j);
			macval = i;
			maccount = (j - i)/macincrement + 1;
			break;
		}
	}
    if (maccount <= 0)  maccount = 1;
    macptr = 0;
	printf("Start Macro: from %d to %d, steps of %d.\n",macval,j,macincrement);
	return NO_ERR;
}

/* ********** */

int keylimit(int n)
/* limit printing command */
{
    // make a buffer so nested klimit commands work in macro/execute when klimit is built in
    // to commands
	extern unsigned char printall;
	static unsigned char saveprintall[100];
    static int printall_depth = 0;
	
	switch(n) {
        case 0:
            printall = 1;
            break;
        case -1:				/* turn off printing now but save old status */
            saveprintall[printall_depth++] = printall;
            if(printall_depth >= 100){
                printall_depth = 99;
                beep();
                printf("KLIMIT depth overflow.\n");
            }
            printall = 0;
            break;
        case -2:
            if(printall_depth <= 0){
                printall_depth = 1;
                beep();
                printf("KLIMIT depth underflow.\n");
                break;
            }
            printall = saveprintall[--printall_depth];	/* restore old status */
            break;
        default:
            printall = 1;
	}
	return 0;
}

/*
// ********** 

int imacro(int n)			// set a flag that determines if a macro checks for events during execution 
{
	extern int macro_stopable;
	
	macro_stopable = n;
	return 0;
	
}
*/
// ********** 

int stopmacro()
{
	extern int macflag,macval,exflag;
	extern unsigned char from_noprint;
        
    macflag = 0;
    macro_line_number = lvar_max = loopdepth = var_char_count = inloop = 0;
    ifdepth=0;          // not inside any if condition
    ;
    exflag = 0;
    inloop = 0;
    ifdepth=0;           // not inside any if condition
    //which_ex_buffer = -1; // resetting this now leads to a crash when stop_on_error is set in certain cases -- ????
    if_condition_met = 1;
    if(from_noprint) {
        keylimit(-2);
        from_noprint = 0;
    }
    
    if(macflag){
		printf("Macro Stopped at Value %d.\n",macval);
	}
	if(exflag){
		printf("Execute aborted.\n");
	}

    
	return 0;
    
}

// ********** 

//#define READMODE O_RDONLY  // Read file mode.

int execut(int n, char* args)


{
	//extern int exflag,exptr[],exval[];
	//extern char* exbuf[];
	extern char* fullname(char*,int);
	
	int fd,nread,i;
	
	which_ex_buffer++;  // next buffer
    
	if(exbuf[which_ex_buffer] == 0) 
		exbuf[which_ex_buffer] = (char*) calloc(MBUFLEN,1);
	else
		for(i=0; i< MBUFLEN; i++) *(exbuf[which_ex_buffer]+i)=0;	// clear buffer
	
	fd = open(fullname(args,MACROS_DATA),READMODE);
    
	if(fd == -1) {
		beep();
		printf("Execute File '%s' Not Found.\n",args);
		//free(exbuf[which_ex_buffer]);
		which_ex_buffer--;
		return -1;
	}
	nread = (int)read(fd,exbuf[which_ex_buffer],MBUFLEN);
	printf("%d Bytes Read.\n",nread);
	
 	// the format of macro files has changed -- now they are formatted text files 
	// previously, they were constant length files containing C strings 
	// this code should read both formats 
	
	for(i=0; i<nread ; i++) {
		if( *(exbuf[which_ex_buffer]+i) == 0x0D || *(exbuf[which_ex_buffer]+i) == 0x0A )
			*(exbuf[which_ex_buffer]+i) = 0x00;		// change CR or LF to null 
	}	
	*(exbuf[which_ex_buffer]+nread) = 0;				// one extra to signify end of buffer 
	*(exbuf[which_ex_buffer]+nread+1) = 0;				// one more in case there was no <cr><lf> at end of macro
	
	for(i=0; i<nread ; i++) {
		if( *(exbuf[which_ex_buffer]+i) == 0x0){  // end of line
			if( *(exbuf[which_ex_buffer]+i+1) == 0x0) { // second 0 means end of execute text
				*(exbuf[which_ex_buffer]+i+1) = ';';	// end each execute command with a null command
				*(exbuf[which_ex_buffer]+i+2) = 0x0;
				*(exbuf[which_ex_buffer]+i+3) = 0x0;
				break;
			}
		}
        
	}
    
	close(fd);
    
    exflag = exval[which_ex_buffer] = 1;
    exptr[which_ex_buffer] = 0;
    exe_line_number[which_ex_buffer] = 0;
    executedepth[which_ex_buffer] = loopdepth;
	return 0;
}

/*
// ********** 
int ifnotexist(int n, int index)
{
	extern int macflag,exflag;
	
    char tmptxt[CHPERLN];    // scratch space
	int fd,fd2;
	int this_test;
	
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IFNEXS must be within a Macro.\n");
		
		return -1;
	}
    
    strcpy(tmptxt,&cmnd[index]);
	
	fd = open(fullname(&cmnd[index],SAVE_DATA),READMODE);
    fd2 = open(fullname(tmptxt,GET_DATA),READMODE);
	
	if (fd == -1 && fd2 == -1) {
		this_test = 1;
	} else {
		close(fd);
        close(fd2);
		this_test = 0;
	}
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}	
	}
	
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
	
}

// ********** 
int ifexist(int n, int index)
{
	extern int macflag,exflag;
	
    char tmptxt[CHPERLN];    // scratch space
	int fd,fd2;
	int this_test;
	
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IFEXST must be within a Macro.\n");
		
		return -1;
	}
    
    strcpy(tmptxt,&cmnd[index]);
	
	fd = open(fullname(&cmnd[index],SAVE_DATA),READMODE);
    fd2 = open(fullname(tmptxt,GET_DATA),READMODE);
	if (fd == -1 && fd2 == -1) {
		this_test = 0;
	} else {
		close(fd);
        close(fd2);
		this_test = 1;
	}
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}	
	}
	
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
}

// ********** 

int ifnotdefined(int n, int index)	// set flag to use integer value of a variable
{
	extern int macflag,exflag;
	
	int this_test;
	int arg_index;
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IFNDEF must be within a Macro.\n");
		return -1;
	}
	
	// Make the test to see if the argument exists
	arg_index = get_variable_index(&cmnd[index],0);
	if(arg_index < 0) {	// If variable wasn't defined then 
		this_test = 1;    // test returns true
	} else {
		this_test = 0;
	}
	
	// Set the LOOP conditions
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}	
	}
	
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
	
}

// ********** 

int ifdefined(int n, int index)	// set flag to use integer value of a variable
{
	extern int macflag,exflag;
	
	int this_test;
	int arg_index;
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IFNDEF must be within a Macro.\n");
		return -1;
	}
	
	// Make the test to see if the argument exists
	arg_index = get_variable_index(&cmnd[index],0);
	if(arg_index < 0) {	// If variable wasn't defined then 
		this_test = 0;    // test returns true
	} else {
		this_test = 1;
	}
	
	// Set the LOOP conditions
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}	
	}
	
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
	
}

// ********** 
*/

int ifcmnd(int n, char* args)
{
	extern int macflag,exflag;
	Expression_Element ex_result;
	int this_test,i,j;
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IF must be within a Macro.\n");
		return -1;
	}
	
	// get rid of spaces in the expression -- we just don't need them
	for(i=0; i< strlen(args); i++){
		if(args[i] == ' '){
			j= i;
			while(args[j] != 0){
				args[j] = args[j+1];
				j++;
			}
			i--;	// maybe we have multiple spaces
		}
	}
	
	ex_result = evaluate_string(args);
	
	if( ex_result.ivalue != 0){	// IF condition is met
		this_test = 1;
	} else {
		this_test = 0;
	}
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}	
	}
    
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	//printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
    
}

int ifnotcmnd(int n, char* args)
{
	extern int macflag,exflag;
	Expression_Element ex_result;
	int this_test,i,j;
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("IF must be within a Macro.\n");
		return -1;
	}
	
	// get rid of spaces in the expression -- we just don't need them
	for(i=0; i< strlen(args); i++){
		if(args[i] == ' '){
			j= i;
			while(args[j] != 0){
				args[j] = args[j+1];
				j++;
			}
			i--;	// maybe we have multiple spaces
		}
	}
	
	ex_result = evaluate_string(args);
	
	if( ex_result.ivalue == 0){	// IF condition is NOT met
		this_test = 1;
	} else {
		this_test = 0;
	}
	if(ifdepth == 0) if_condition_met = this_test;
	else{	// we're nested -- check to make sure that one above is true
		if(if_condition[ifdepth-1]){
			if_condition_met = this_test;
		}
	}
    
	if_condition[ifdepth] = this_test;
	ifdepth++;
    if(ifdepth >= NESTDEPTH){
        beep();
        printf("IF buffer overflow.\n");
        return -1;
    }
	//printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
    
}

// ********** 

int endifcmnd(int n, char* args)
{
	if( ifdepth <1){
		beep();
		printf("IF nesting error,\n");
		printf("IF condition: %d; depth %d\n",if_condition_met,ifdepth);
		ifdepth = 0;
		if_condition_met = 1;
		return 1;
	}
    
	ifdepth--;
	if(ifdepth == 0)
		if_condition_met = 1;
	else
		if_condition_met = if_condition[ifdepth-1];
	
	//printf("if condition: %d; depth %d\n",if_condition_met,ifdepth);
	return 0;
    
}

// ********** 

int loop(int n,char* args)
{
	int start,end,step,narg,k,l,m,match;
	char vname[COMLEN];
	
	extern int macflag,exflag;
	
	if( (macflag == 0) && (exflag == 0)) {
		beep();
		printf("Loops must be within a Macro.\n");
		return CMND_ERR;
	}
	
	narg = sscanf(args,"%s %d %d %d",vname,&start,&end,&step);
	if( narg < 3 ){
		beep();
		printf("Not enough arguments for LOOP.\n");
		return CMND_ERR;
	}
	if( narg == 3 )
		step = 1;
	
	if( ((start > end) && step > 0) ||
       ((start < end) && step < 0) ||
       (step == 0) ) {
        beep();
        printf("Invalid arguments for LOOP.\n");
        return CMND_ERR;
	}
	
	
	// look through the loop variables to see if this one already exists 
	k=m=0;
	for (n = 0; n<lvar_max; n++) {	
		match = 1;
		for( l = 0; *(variable_names+m) != '\0';l++) {
			if( *(variable_names+m)	!= vname[l] )
				match = 0;
			m++;
		}
		m++;
		// printf("\n%d length\n",l); 
        
		if( vname[l] == '\0' && match == 1) {	// if true, we have the match 
			k=1;
			break;
		}
	}
    
	
	if( k == 0) {								// if new name, add it to the list 
		for( n=0; vname[n] != '\0'; n++)
			*(variable_names+n+var_char_count) = vname[n];
		*(variable_names+n+var_char_count) = vname[n];
		var_char_count += n+1;
		n = lvar_max;
		lvar_max++;
	}
	// n is the location in the variable list arrays for this variable 
	
	lvar[loopdepth] = n;
	
	// printf("LOOP ------- loopdepth:%d, variable:%d\n",loopdepth,n); 
	
	endval[n] = end;
	stepval[n] = step;
	startval[n] = start;
	
	if( exflag ) 
		branchto[n] = exe_line_number[which_ex_buffer];	// loop to the line after the loop command 
	else
		branchto[n] = macro_line_number;// loop to the line after the loop command 
    
	loopdepth++;		// the depth of the loop 
    // note that no overflow checking is done -- nesting greater that NESTDEPTH
    // will crash
    
	inloop=1;
	
	// printf("%s %d %d %d var,start,end,step\n",vname,start,end,step); 
	return NO_ERR;
    
}
// ********** 

int loopbreak(int n,char* args)			// break out of the current loop
{
	int i,j;	
	char loopnd_string[7]={"LOOPND"};
	 
	//extern char* exbuf[];    // the macro buffer
	//extern int exflag,exptr[],exval[];
	extern int macptr;
	
	
	if(loopdepth <= 0) {
		beep();
		printf("Loop break not in a loop\n");
		return -1;
	}
	
	//printf("%d\n" ,loopnd_string[6]);
	
	if(exflag) {	// loop in execute
		// have to set macro_line_number to point past loopnd
		exptr[which_ex_buffer] = 0;
		for( i=0; i<exe_line_number[which_ex_buffer]; i++) {
			while ( *(exbuf[which_ex_buffer] + exptr[which_ex_buffer]) != 0 )
				exptr[which_ex_buffer]++;
			exptr[which_ex_buffer]++;
		}
		// exptr now points to the next command after the loopbr
		// go through commands in the macro buffer until loopnd is found
		i = j= 0;
		// ignore spaces or tabs at the beginning of a command
		while( *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) == ' ' || *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) == '\t')i++; 
		
		//printf("point to:%s -- line %d\n",macbuf+macptr+i,macro_line_number);
        
		while ( *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) != EOL && *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) != ' ' 
                //&& *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) != ';'
                ){
			if ( toupper(*(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i)) !=  loopnd_string[j] ) {
				// this is not loopnd -- look at next command 
				i = j= 0;
                
				while ( *(exbuf[which_ex_buffer] + exptr[which_ex_buffer]) != 0 )
					exptr[which_ex_buffer]++;
				exptr[which_ex_buffer]++;
				// ignore spaces or tabs at the beginning of a command
				while( *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) == ' ' || *(exbuf[which_ex_buffer]+exptr[which_ex_buffer]+i) == '\t')i++; 
				//printf("now to:%s -- line_number %d\n",macbuf+macptr+i,macro_line_number);
				exe_line_number[which_ex_buffer]++;
			} else {
				i++;
				j++;
				//printf("%d\n",i);
			}
        }
        
		exe_line_number[which_ex_buffer]++;	// point to one after
		loopdepth--;
		if(loopdepth == 0) {
			inloop = 0;
		}	
		if ( *(exbuf[which_ex_buffer] + ++exptr[which_ex_buffer]) == EOL && (executedepth[which_ex_buffer] == loopdepth) ) {
            //if ( *(exbuf[which_ex_buffer] + ++exptr[which_ex_buffer]) == EOL && inloop == 0 ) {
			exval[which_ex_buffer]++;
			exptr[which_ex_buffer] = 0;
			exflag = 0;
			if_condition_met = 1;
		}	
        
	} else {		// loop in macro
		// have to set macro_line_number to point past loopnd
		macptr = 0;
		for( i=0; i<macro_line_number; i++) {
			while ( *(macbuf + macptr) != 0 )
				macptr++;
			macptr++;
		}
		// macptr now points to the next command
		// go through commands in the macro buffer until loopnd is found
		i = j= 0;
		// ignore spaces or tabs at the beginning of a command
		while( *(macbuf+macptr+i) == ' ' || *(macbuf+macptr+i) == '\t')i++; 
		
		//printf("point to:%s -- line %d\n",macbuf+macptr+i,macro_line_number);
        
		while ( *(macbuf+macptr+i) != EOL && *(macbuf+macptr+i) != ' ' 
            //&& *(macbuf+macptr+i) != ';'
            ){
			if ( toupper(*(macbuf+macptr+i)) !=  loopnd_string[j] ) {
				// next command 
				i = j= 0;
                
				while ( *(macbuf + macptr) != 0 )
					macptr++;
				macptr++;
				// ignore spaces or tabs at the beginning of a command
				while( *(macbuf+macptr+i) == ' ' || *(macbuf+macptr+i) == '\t')i++; 
                
				
				//printf("now to:%s -- line_number %d\n",macbuf+macptr+i,macro_line_number);
				macro_line_number++;
			} else {
				i++;
				j++;
				//printf("%d\n",i);
			}
        }
        
		macro_line_number++;	// point to one after
		loopdepth--;
		if(loopdepth == 0) {
			inloop = 0;
		}	
        
	}
    // presumably this is within an if statement
    // so do the endif bookkeeping
    if( ifdepth >0 ){
        endifcmnd(0,0);
    }
    return 0;
}

// ********** 

int loopend(int n,char* args)
{
	int loopvar_index;
	extern int exflag;
    
	if(loopdepth <= 0) {
		beep();
		printf("Loop Mismatch\n");
		return -1;
	}
	
	
	// loopvar_index = loopdepth-1 + loopvar-loopdepth; 
	loopvar_index = lvar[loopdepth-1];
	
	//printf("LOOP END -----loopdepth:%d, variable:%d\n",loopdepth-1,loopvar_index);
	
	startval[loopvar_index] += stepval[loopvar_index];
	
	if (stepval[loopvar_index ] > 0) {
		if( startval[loopvar_index] <= endval[loopvar_index] ) {
			if( exflag )
				exe_line_number[which_ex_buffer] = branchto[loopvar_index];
			else
				macro_line_number = branchto[loopvar_index];
			return 0;
		}
	} else {
		if( startval[loopvar_index] >= endval[loopvar_index] ) {
			if( exflag )
				exe_line_number[which_ex_buffer] = branchto[loopvar_index];
			else
				macro_line_number = branchto[loopvar_index];
			return 0;
		}
	}
	
	// end of loop 
    
	loopdepth--;
	if(loopdepth == 0) {
		inloop = 0;
	}
	return 0;
}

// ********** 

/*
 These commands SAVE and GET a file called OMA Settings from the
 with the directory specified in the SETTINGS FILE part of the file settings menu.
 This was formerly the GRAPHICS FILES menu.
 */


int getsettings(int n,char* args)	
{
	char txt[CHPERLN];
	//extern char cmnd[];
	int err;
	
	if(*args == 0){	// no file name was specified, use the default name and get it from the oma application
		strcpy(txt,SETTINGSFILE);
		err = loadprefs(txt);
	} else { // otherwise, add the prefix and suffix and use the name specified
		err = loadprefs((char*)fullname(args, SETTINGS_DATA));
    }
    update_UI();
    return err;
    
}

// ********** 

int savsettings(int n,char* args)
{
	char txt[CHPERLN];
	int err;
	
	if(*args == 0){	// no file name was specified, use the default name and put it in the oma application
		strlcpy(txt,SETTINGSFILE,CHPERLN);
		err = saveprefs(txt);
		return err;
	} else { // otherwise, add the prefix and suffix and use the name specified
		err = saveprefs((char*)fullname(args, SETTINGS_DATA));
		return err;
	}
}

// ********** 

int variab(int n, char* args)	// print values of defined variables
{
	int i;
	for(i=0; i<num_variables; i++){
		vprint(i);
	}
	return 0;
    
}

// ********** 

int vfloat(int n, char* args)	// set flag to use floating pt value of a variable
{
	int arg_index;
	//extern char cmnd[];
	
	arg_index = get_variable_index(args,0);
	
	if(arg_index < 0) {	// it wasn't defined yet, so define it and set it to 0
		arg_index = get_variable_index(args,1);
		if(arg_index < 0) {	// maybe there was still a problem
            beep();
            printf("Assignment error arg index:%d\n",arg_index);
            return arg_index;
		}
	}
	user_variables[arg_index].is_float=1;
	
	vprint(arg_index);
    
	return 0;
}

// ********** 

int vint(int n, char* args)	// set flag to use integer value of a variable
{
	int arg_index;
	//extern char cmnd[];
	
	arg_index = get_variable_index(args,0);
	
	if(arg_index < 0) {	// it wasn't defined yet, so define it and set it to 0
		arg_index = get_variable_index(args,1);
		if(arg_index < 0) {	// maybe there was still a problem
            beep();
            printf("Assignment error arg index:%d\n",arg_index);
            return arg_index;
		}
	}
	user_variables[arg_index].is_float=0;
	
	vprint(arg_index);
	return 0;
    
}
// ********** 
 
 

/* STOP_ON_ERROR flag
 If flag = 1, macro or execute commands will stop on error conditions. If flag = 0
 (default) execution will continue. 
 */


int stopOnError(int n, char* args)
{
	if(n == 0){
		stop_on_error = 0;
        printf("Macros will not stop on error condition.\n");
	}else{
		stop_on_error = 1;
        printf("Macros will stop on error condition.\n");
    }
	return 0;
    
}
/*
// ********** 

int prflag(int n, char* args)	// set flag to use enable/disable printing
{
	if(n == 0)
		no_print=1;
	else
		no_print=0;
    
	return 0;
    
}


*/


// ********** 

int help(int n, char* args)
{
    //extern  ComDef    commands[];
    int i=0,fd,status,length,j;
    //int j,status,length;
	//int fd,gethelpfile(),gettextline();
	char string[CHPERLN];
    enum {LOOKING_FOR_MATCH,LISTING};
       
    if(*args == 0) {
        printf("Available Commands are:\n" );
       
        for (i = 0; commands[i].text.name[0] != EOL; i++ ) {
            printf( "%s\n", commands[i].text.name);
        }
        
        if (hardwareCommands[0].text.name[0] != EOL) {
            printf( "Available Hardware-Related Commands Are:\n" );
        }
        for (i = 0; hardwareCommands[i].text.name[0] != EOL; i++ ) {
            printf( "%s\n", hardwareCommands[i].text.name);
        }

    }
    else {
        fd = open(HELPFILE,READMODE);
        if( fd == -1) {
            printf("'OMA HELP' File Not Found.\n");
            return FILE_ERR;
        }

        for( i = 0; (args[i] = toupper(args[i])) != EOL; i++ ) ; // convert to uppercase 
        status = LOOKING_FOR_MATCH;
        
        while((length = gettextline(fd,string)) > 0) {
            switch (status) {
				case LOOKING_FOR_MATCH:
					for( j = 0; j<i; j++) {
						if( args[j] != string[j])
							break;
					}
					if( j != i )
						break;
					printf("%s",string);
					status = LISTING;
					break;
				case LISTING:
					if( length <= 2) {
						status = LOOKING_FOR_MATCH;
						printf("\n");
						break; 
					}
					printf("%s",string);
            }
        }
        close(fd);
    }
    return NO_ERR;
}

/* get a line of text from a file specified by fd */
#define BREAK_AFTER 80
int gettextline(int fd, char* textline)
{
	static int i = -2;
	int n = 0;
	static int j = 0;
    static char textbuf[1024];
	
	if( i == -2 ){				// read the first time
		i = (int)read(fd,textbuf,1024);
	}
	
	while(  textbuf[j]  != '\n' ) {
		
		if( j >= i) {
			i = (int)read(fd,textbuf,1024);
			j = 0;
			if( i < 1) {
				return -1;	// end of file or error
			}
            //goto next_char;
		} else {
            if( n >  BREAK_AFTER && textbuf[j] == ' '){
				// cut things off here
				textline[n++] =  '\n';		// Unix uses <lf> for new line
				//j++;

				textline[n++] ='\t'	;		// tab over
				textline[n] = 0;
				return n;
			}
			textline[n++] = textbuf[j++];
			
			// this for lines that may be too long
			if(n >=CHPERLN-2) {
				n = CHPERLN-3;
			}
		}
        //next_char:
	}

	textline[n++] =  '\n';		// Unix uses <lf> for new line
	j++;

	textline[n] = 0;
	return n;
}

/* ********** */


