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

int getfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not load %s\n",args);
        return new_im.err();
    }
    iBuffer.free();     // release the old data
    iBuffer = new_im;   // this is the new data
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

int addfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
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
    printf1("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int mulfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
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
    printf1("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int subfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
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
    printf1("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int divfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
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
    printf1("Files are not the same size.\n");
    iBuffer.errclear();
    return SIZE_ERR;
}

int compositefile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
        return new_im.err();
    }
    iBuffer.composite(new_im);
    if(iBuffer.err()){
        new_im.free();
        int err = iBuffer.err();
        printf2("Error: %d.\n",err);
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
        
        printf5("Current Rectangle is %d %d %d %d.\n",
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
        printf1("Need 4 Arguments.\n"); 
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

    printf5("Current Rectangle is %d %d %d %d.\n",
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
        printf2("Error: %d.\n",err);
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
        printf2("Error: %d.\n",err);
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
        printf2("Error: %d.\n",err);
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
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
            printf2("Error: %d.\n",err);
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
        specs = iBuffer.getspecs();  // get the new specs
        specs[IS_COLOR] = 1;        // reset the color flag
        iBuffer.setspecs(specs);
        free(specs);
        if(iBuffer.err()){
            int err = iBuffer.err();
            printf2("Error: %d.\n",err);
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
                printf2("Could not load %s\n",args);
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
    printf3("Current Image is %d by %d\n",specs[COLS],specs[ROWS]);
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
        printf1("Rectangle not contained in current image.\n");
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
	
	printf3("Ave:\t%g\trms:\t%g\t# Pts:\t",ave,rms);
	printf2("%d",icount);
	if( bufferspecs[HAS_RULER] ) {
		xcom /= buffervalues[RULER_SCALE];
		ycom /= buffervalues[RULER_SCALE];
	}
	printf3("\tx:\t%g\ty:\t%g",xcom,ycom);
	if( bufferspecs[HAS_RULER]!= 0  && unit_text[0]!=0 ){
		printf2("\t%s\n",unit_text);
	} else {
		printf1("\n");
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
            printf1("Numbered temporary images must be between 0-9\n");
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
		printf2("Temporary image %s not defined.\n",name);
		return(-1);
    }
    printf2("%s is not a valid image name.\n",name);
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
            printf1("Temporary image is not defined.\n");
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
            printf5("Temp Image %d: %d x %d x %d\n",n,
                   iTempImages[n].width(),iTempImages[n].height(),ncolors);
        }
    }
    for (i = 0; i<numberNamedTempImages; i++) {
        n = i+NUMBERED_TEMP_IMAGES;
        if(iTempImages[n].isColor())
            ncolors=3;
        else
            ncolors=1;
        printf5("Temp Image %s: %d x %d x %d\n",namedTempImages[i].vname,
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
            printf1("Images are not the same size.\n");
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
            printf1("Images are not the same size.\n");
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
            printf1("Images are not the same size.\n");
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
            printf1("Images are not the same size.\n");
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
            printf1("Images are not the same width.\n");
            return SIZE_ERR;
        }
        iBuffer.composite(iTempImages[n]);
        iBuffer.getmaxx();
        update_UI();
        return NO_ERR;
    } else
        return MEM_ERR;
}

