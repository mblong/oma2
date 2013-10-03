#include "commands_1.h"

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData;

extern Image  iTempImages[];
extern int numberNamedTempImages;
extern Variable namedTempImages[];

int plus_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer+val);
    iBuffer.getmaxx();
    update_UI();
    //cout << "test message\n";
    return NO_ERR;
}

int null_c(int n,char* args){
    return NO_ERR;
}

int minus_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer-val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int divide_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer/val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int multiply_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer*val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int savefile_c(int n,char* args)
{
	if(*args == 0){	// no file name was specified
		return FILE_ERR;
	} else { // otherwise, add the prefix and suffix and use the name specified
		iBuffer.saveFile(args);
		return iBuffer.err();
	}
}


int getfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not load %s\n",args);
        return new_im.err();
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int addfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer+new_im);
        iBuffer.getmaxx();
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int mulfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer*new_im);
        iBuffer.getmaxx();
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int subfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer-new_im);
        iBuffer.getmaxx();
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int divfile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    if(iBuffer == new_im){
        (iBuffer/new_im);
        iBuffer.getmaxx();
        new_im.free();
        update_UI();
        return NO_ERR;
    }
    new_im.free();
    printf("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int compositefile_c(int n,char* args){
    Image new_im(args,SHORT_NAME);
    if(new_im.err()){
        printf("Could not open %s\n",args);
        return new_im.err();
    }
    iBuffer.composite(new_im);
    if(iBuffer.err()){
        new_im.free();
        int err = iBuffer.err();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    new_im.free();
    update_UI();
    return NO_ERR;
}

int croprectangle_c(int n,char* args){
    iBuffer.crop(UIData.iRect);
    if(iBuffer.err()){
        int err = iBuffer.err();
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}


int rectan_c(int n, char* args)
{
    int narg;
    point start,end;
    rect new_rect;
    
    // For this need 4 arguments 
    narg = sscanf(args,"%d %d %d %d",&new_rect.ul.h,&new_rect.ul.v,&new_rect.lr.h,&new_rect.lr.v);
    
    if(*args == 0){
        
        printf("Current Rectangle is %d %d %d %d.\n",
               UIData.iRect.ul.h,UIData.iRect.ul.v,UIData.iRect.lr.h,UIData.iRect.lr.v);
        /*
        user_variables[0].ivalue = substart.h;
        user_variables[0].is_float = 0;
        user_variables[1].ivalue = substart.v;
        user_variables[1].is_float = 0;
        user_variables[2].ivalue = subend.h;
        user_variables[2].is_float = 0;
        user_variables[3].ivalue = subend.v;
        user_variables[3].is_float = 0;
        */
        return NO_ERR;
    }
    
    if(narg != 4) {
        //beep();
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
    /*
    user_variables[0].ivalue = substart.h;
    user_variables[0].is_float = 0;
    user_variables[1].ivalue = substart.v;
    user_variables[1].is_float = 0;
    user_variables[2].ivalue = subend.h;
    user_variables[2].is_float = 0;
    user_variables[3].ivalue = subend.v;
    user_variables[3].is_float = 0;
    */
    update_UI();
    return NO_ERR;
}

int list_c(int n, char* args){
    
    int lc,i;
    
    lc = 1;
    i = 0;
    char* comment = iBuffer.getComment();
    int* specs = iBuffer.getspecs();
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
    return NO_ERR;
    
    
    
}

int invert_c(int n,char* args){
    iBuffer.invert();
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int rgb2red_c(int n,char* args){
    iBuffer.rgb2color(0);
    if(iBuffer.err()){
        int err = iBuffer.err();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int rgb2green_c(int n,char* args){
    iBuffer.rgb2color(1);
    if(iBuffer.err()){
        int err = iBuffer.err();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int rgb2blue_c(int n,char* args){
    iBuffer.rgb2color(2);    
    if(iBuffer.err()){
        int err = iBuffer.err();
        printf("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

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

int rotate_c(int n,char* args){
    float angle;
    int* specs= iBuffer.getspecs();
    sscanf(args,"%f",&angle);
    if(*args == 0) angle = 90.;
    if (!specs[IS_COLOR]) {
        iBuffer.rotate(angle);
        if(iBuffer.err()){
            int err = iBuffer.err();
            printf("Error: %d.\n",err);
            iBuffer.errclear();
            return err;
        }
        free(specs);
        iBuffer.getmaxx();
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
            printf("Error: %d.\n",err);
            iBuffer.errclear();
            return err;
        }
        iBuffer.getmaxx();
        update_UI();
        return NO_ERR;
    }
}

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
    
    if(smoothed.err()){
        return smoothed.err();
    }
    smoothed.copyABD(iBuffer);
    
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
    free(bufferspecs);  // release buffer copy
    iBuffer.free();     // release the old data
    iBuffer = smoothed;   // this is the new data
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int size_c(int n,char* args){
    int width, height;
    if(*args){
        int narg = sscanf(args,"%d %d",&width,&height); 
        if (narg == 2){
            Image new_im(height,width);
            if(new_im.err()){
                printf("Could not load %s\n",args);
                return new_im.err();
            }
            iBuffer.free();     // release the old data
            iBuffer = new_im;   // this is the new data
            iBuffer.getmaxx();
            update_UI();
            return NO_ERR;
        }
    } 
    int* specs = iBuffer.getspecs();
    printf("Current Image is %d by %d\n",specs[COLS],specs[ROWS]);
    free(specs);
    return NO_ERR;
 
}

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

int calc_cmd_c(int n, char* args)
{
    point substart,subend;
    int* bufferspecs = iBuffer.getspecs();
	
	substart = UIData.iRect.ul;
    subend = UIData.iRect.lr;
    
    if (subend.h > bufferspecs[COLS]-1 ||
        subend.v > bufferspecs[ROWS]-1 ||
        substart.h < 0 ||
        substart.v < 0){
        free(bufferspecs);
        printf("Rectangle not contained in current image.\n");
        return ARG_ERR;
    }
	
	calc(substart,subend);
    free(bufferspecs);
	return 0;
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

    icount = 0;
	xcom = ycom = ave = rms = 0.0;
	
	//printf("%d %d %d %d \n", start->v,start->h,end->v,end->h);
	for(nt=start.v; nt<=end.v; nt++) {
		for(nc=start.h; nc<=end.h; nc++) {
			datval = iBuffer.getpix(nt,nc);		
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
	
	printf("Ave:\t%g\trms:\t%g\t# Pts:\t",ave,rms);
	printf("%d",icount);
	if( bufferspecs[HAS_RULER] ) {
		xcom /= buffervalues[RULER_SCALE];
		ycom /= buffervalues[RULER_SCALE];
	}
	printf("\tx:\t%g\ty:\t%g",xcom,ycom);
	if( bufferspecs[HAS_RULER]!= 0  && unit_text[0]!=0 ){
		printf("\t%s\n",unit_text);
	} else {
		printf("\n");
    }

    free( buffervalues);
    free( bufferspecs);
    free( unit_text);
    return 0;

}

/* ********** */

// return the index of a temporary image
// or return -1 if there was a problem
int temp_image_index (char* name,int define)
{
    int i,j;
    
    // numbered temporary image?
    if(name[0] >= '0' && name[0] <= '9'){   // this is the 0-9 naming case
        // just to be sure, be sure this isn't a number > 9
        sscanf(name, "%d",&i);
        if( i > 9){
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
		//beep();
		printf("Temporary image %s not defined.\n",name);
		return(-1);
    }
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
            printf("Temporary image is not defined.\n");
            return MEM_ERR;
        }
        iBuffer << iTempImages[n];
        iBuffer.getmaxx();
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

/* ********** */
/*
FTEMPIMAGE tempImage
    Free memory associated with temporary image tempImage.
    tempImage must be in the range 0-9, or correspond to a named image.
*/
int ftemp_c(int n, char* args)
{
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
        return NO_ERR;
    }
    return MEM_ERR;
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
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer + iTempImages[n];
        iBuffer.getmaxx();
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
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer - iTempImages[n];
        iBuffer.getmaxx();
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
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer * iTempImages[n];
        iBuffer.getmaxx();
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
            printf("Images are not the same size.\n");
            return SIZE_ERR;
        }
        iBuffer / iTempImages[n];
        iBuffer.getmaxx();
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
            printf("Images are not the same width.\n");
            return SIZE_ERR;
        }
        iBuffer.composite(iTempImages[n]);
        iBuffer.getmaxx();
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
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
    extern int newWindowFlag;
    if(n)
        newWindowFlag = 1;
    else
        newWindowFlag =0;
    return NO_ERR;
    
}
/* ********** */
