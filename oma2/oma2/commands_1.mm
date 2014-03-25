#include "commands_1.h"

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData;

extern Image  iTempImages[];
extern Image   accumulator;   // the accumulator
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

/* ********** */

int savefile_c(int n,char* args)
{
	if(*args == 0){	// no file name was specified
		return FILE_ERR;
	} else { // otherwise, add the prefix and suffix and use the name specified
		iBuffer.saveFile(args,SHORT_NAME);
		return iBuffer.err();
	}
}

/* ********** */

int fwdatm_c(int n,char* args)
{
	int	i,nt,nc;
	FILE *fp;
	
	n = 0;
	fp = fopen(fullname(args,SAVE_DATA),"w");
	if( fp != NULL) {
		i=0;
        int* specs = iBuffer.getspecs();
		for(nt=0; nt<specs[ROWS]; nt++){
			for(nc=0; nc<specs[COLS]; nc++){
				fprintf(fp,"%g\t",iBuffer.getpix(nt,nc));
			}
			fprintf(fp,"\n");
		}
    	fclose(fp);
	}
	else {
        
		beep();
        printf("Could not open file: %s\n",args);
		return FILE_ERR;
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
    iBuffer.getmaxx();
    update_UI();
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
        iBuffer.getmaxx();
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
        iBuffer.getmaxx();
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
        iBuffer.getmaxx();
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
    iBuffer.getmaxx();
    new_im.free();
    update_UI();
    return NO_ERR;
}

/* ********** */

int croprectangle_c(int n,char* args){
    iBuffer.crop(UIData.iRect);
    if(iBuffer.err()){
        // crop already prints out error messages (an exception -- normally error messages are done in the command)
        int err = iBuffer.err();
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

/* ***************** */

/* Put a "frame" around the current image -- making it a new size
 
 FRAME NewWidth NewHeight [Value] [X0] [Y0]
 
 default value is 0
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
	
	switch(i) {
        case 2:
        case 3:
            x0 = -(sizx - (float)specs[COLS])/2.;
        case 4:
            y0 = -(sizy - (float)specs[ROWS])/2.;
	}
	
	Image im;
    // error check?
    im.copyABD(iBuffer);
    int oldWidth = specs[COLS];
    int oldHeight = specs[ROWS];
    specs[ROWS] = sizy;
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
	printf("Frame Value: %d\n",value);
	
	
	for(i=0; i<sizy; i++){
		for(j=0; j<sizx; j++) {
			if(i+y0<0 || i+y0 >=oldHeight ||
			   j+x0<0 || j+x0 >=oldWidth) {
                im.setpix(i,j,value);
			}else {
                if(fraction)
                    im.setpix(i,j,iBuffer.getpix(j+x0,i+y0));
                else
                    im.setpix(i,j,iBuffer.getpix((int)j+x0,(int)i+y0));
			}
		}
	}
    free(specs);  // release specs copy
    iBuffer.free();     // release the old data
    iBuffer = im;   // this is the new data
    iBuffer.getmaxx();
    update_UI();
	return 0;
    
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
    iBuffer.getmaxx();
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

/* ********** */

int invert_c(int n,char* args){
    iBuffer.invert();
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

/* ********** */

int mirror_c(int n,char* args){
    iBuffer.mirror();
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
            beep();
            printf("Error: %d.\n",err);
            iBuffer.errclear();
            return err;
        }
        iBuffer.getmaxx();
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

/* ********** */

int gsmooth_c(int n, char* args)
//  Gaussian Smoothing of the Data
// GSMOOT NX [NY]
// sigma_x = (NX-1)/3.5
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
	sigx = dx/1.75;
    
	dy = (dy-1)/2;
	dys = -dy;
	sigy = dy/1.75;
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}




/* ********** */
/*
int
gsmooth2(int n, int index)
//  Gaussian Smoothing of the Data
// GSMOOT NX [NY]
// sigma_x = (NX-1)/6.0
{
	DATAWORD *datp,*datp2;
	extern int	doffset;
	DATAWORD idat(int,int);
	
	int dx,dy,dxs,dys,i,j,m,size,nt,nc;
	float sigx,sigy,*mask,norm,sum;
	
	mask = 0;
    
	if(n <= 0) n = 3;
	
	dx = dy = n;	// the smoothing amounts
	
	// Check to see if there was a second argument
	for ( i = index; cmnd[i] != EOL; i++) {
		if(cmnd[i] == ' ') {
			sscanf(&cmnd[index],"%d %d",&dx,&dy);
			break;
		}
	}
	if (dx/2 == dx/2.0) {
		beep();
		printf("THE X SIZE OF THE REGION MUST BE ODD!\n");
		
		return -1;
	}
	if (dy/2 == dy/2.0) {
		printf("THE Y SIZE OF THE REGION MUST BE ODD!\n");
		beep();
		return -1;
	}
    
	size = (header[NCHAN] * specs[ROWS] + MAXDOFFSET) * DATABYTES;
	size = (size+511)/512*512;	// make a bit bigger for file reads
    
	datp2 = datp = malloc(size);
	if(datp == 0) {
		nomemory();
		return -1;
	}
	
	norm = 0;
    
	dx = (dx-1)/2;
	dxs = -dx;
	sigx = dx/3.0;
    
	dy = (dy-1)/2;
	dys = -dy;
	sigy = dy/3.0;
	printf("Sigx=%5.2f, Sigy=%5.2f, ",sigx,sigy);
	printf("pixels=%d x %d\n",dx*2+1,dy*2+1);
	
	if ( sigy == 0 ) sigy = 1;
	if ( sigx == 0 ) sigx = 1;
	
	if(dx == 0 && dy == 0) return(0);	// The 1 x 1 smoothing case
    
	// Set loop limit so only have to do "<", not "<="
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
	
	
	for(nc=0; nc<doffset; nc++)
		*(datp++) = *(datpt+nc);	// copy the CCD header
	for(nt=0; nt<header[NTRAK]; nt++) {
		for(nc=0; nc<header[NCHAN];nc++){
			sum = 0;
			
			for(i=dxs; i<dx; i++) {
				for(j=dys; j<dy; j++) {
					m = (j - dys)*(dx - dxs) + (i - dxs);
					
					sum += idat(nt+j,nc+i)*mask[m];
				}
			}
			*(datp++) = sum/norm;
		}
	}
	if(mask!=0) {free(mask); mask = 0;}
	free(datpt);
	datpt = datp2;
	have_max = 0;
	maxx();
	setarrow();	
	return 0;
}
 */

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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    
    iBuffer.getmaxx();
	update_UI();
	return NO_ERR;
}

/* ********** */

int positive_c(int n, char* args)
{
    iBuffer.floor(0.);
    iBuffer.getmaxx();
	update_UI();
	return NO_ERR;
}

/* ********** */

int clip_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    
    iBuffer.clip(clipval);
    iBuffer.getmaxx();
	update_UI();
	return NO_ERR;

}

/* ********** */

int clipbottom_c(int n, char* args)
{
    DATAWORD clipval = n;
    sscanf(args,"%f",&clipval);
    
    iBuffer.floor(clipval);
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
	update_UI();
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
        subend.v > bufferspecs[ROWS]-1 ||
        substart.h < 0 ||
        substart.v < 0){
        free(bufferspecs);
        beep();
        printf("Rectangle not contained in current image.\n");
        return SIZE_ERR;
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
    extern Variable user_variables[];

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
    if( bufferspecs[HAS_RULER] ) {
		xcom /= buffervalues[RULER_SCALE];
		ycom /= buffervalues[RULER_SCALE];
	}
	
	pprintf("Ave:\t%g\t rms:\t%g\t # Pts:\t%d\t x:\t%g\t y:\t%g",ave,rms,icount,xcom,ycom);
	
	if( bufferspecs[HAS_RULER]!= 0  && unit_text[0]!=0 ){
		pprintf("\t%s \n",unit_text);
	} else {
		pprintf(" \n");
    }

    free( buffervalues);
    free( bufferspecs);
    free( unit_text);
    // return values available as variables
	user_variables[0].fvalue = ave;
	user_variables[0].is_float = 1;
	user_variables[1].fvalue = rms;
	user_variables[1].is_float = 1;
	user_variables[2].fvalue = xcom;
	user_variables[2].is_float = 1;
	user_variables[3].fvalue = ycom;
	user_variables[3].is_float = 1;

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
            beep();
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
            beep();
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
            beep();
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
            beep();
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
            beep();
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
    iBuffer.getmaxx();
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
    extern int newWindowFlag;
    if(n)
        newWindowFlag = 1;
    else
        newWindowFlag =0;
    return NO_ERR;
    
}
/* ********** */

/*
 GETFILENAMES NameFile
 Open NameFile (currently uses macro prefix and suffix) which contains the names of files.
 The NEXTFILE command is used to open the next file. NameFile is left open until all files
 have been accessed.
 */

int getFileNames_c(int n,char* args)			// open a file containing file names
{
    extern FILE* nameFilePtr;
    
    if( nameFilePtr != NULL) fclose(nameFilePtr);
    
    nameFilePtr = fopen(fullname(args,MACROS_DATA),"r");
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
 NEXTFILE [prefix]
 Open the next file specified in the FileNames file that was opened with the GetFileNames command.
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
    strncpy( user_variables[0].estring,txt,strlen(txt)-4);
    user_variables[0].estring[strlen(txt)-4] = 0;   // need to end this explicitly
    
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
    iBuffer.getmaxx();
    update_UI();
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
			fprintf(fptr_local, "%s\n",args);
		} else {
			beep();
			printf("Error: No file open. File pointer is NULL\n");
			return OMA_FILE;
		}
	}
	return NO_ERR;
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
#endif
	return NO_ERR;
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
#endif
	return NO_ERR;
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
        iBuffer.getmaxx();
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
        iBuffer.getmaxx();
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
        iBuffer.getmaxx();
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
        iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

/* ********** */
/*
 FINDBAD Counts
 
 Searches the current image buffer for pixels whose value is more than "Counts" above that of it's
 nearest eight neighbors. Those pixels are tagged as hot pixels.
 
 */

int hot_pix[NUMHOT];	// store info on hot pixels
int num_hot = 0;
int ccd_width = 0;
int ccd_height = 0;

int findbad_c(int n, char* args){
	int i,j;
	DATAWORD ave_val;
	num_hot = 0;
    int* specs = iBuffer.getspecs();
	ccd_width = specs[COLS];
	ccd_height = specs[ROWS];
	if( n == 0) n = 200;		// a reasonable default value
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
		for(k = 0; k < num_hot; k++){
			fscanf(fp,"%d %d",&j,&i);
			hot_pix[k] = i*ccd_width + j;
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
        for(k = 0; k < num_hot; k++){
            fprintf(fp,"%d\t%d\n",hot_pix[k]%ccd_width,hot_pix[k]/ccd_width);
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
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
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


float* xptr[10] = {0*10};		// have a maximum of 10 functions
float* yptr[10] = {0*10};
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    iBuffer.getmaxx();
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
    if(accumulator.err()){
        return accumulator.err();
    }
    accumulator.copyABD(iBuffer);
    accumulator.zero();

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
        printf("Accumulator is not the corret size for the current image.\n");
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
    iBuffer << accumulator;
    iBuffer.getmaxx();
    update_UI();
    return iBuffer.err();
}

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
	float *acpoint,mx=0,mn=0;
	unsigned int  acsize = 0;
    
    point substart,subend;
    int* specs = iBuffer.getspecs();
	
	substart = UIData.iRect.ul;
    subend = UIData.iRect.lr;

    xdirection = n;
    
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
			if( pyend > specs[ROWS])
				pyend = specs[ROWS];
            
		}
		else {
			pxstart = 0;
			pxend = specs[COLS];
			pystart = 0;
			pyend = specs[ROWS];
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
			if(j==pxstart)
				mn = mx = sum;
			*(acpoint + j) = sum;
			if( *(acpoint+j) > mx) mx = *(acpoint+j);
			if( *(acpoint+j) < mn) mn = *(acpoint+j);
		}
        
		specs[COLS] = abs(pxend - pxstart);
		
		if(!integratefill) {
			specs[ROWS] = 1;
		}
        
        iBuffer.setspecs(specs);

		for (i=0; i<specs[ROWS]; i++) {
			for(j=0; j < specs[COLS]; j++) {
				if(do_average)
				    iBuffer.setpix(i,j, *(acpoint+j+pxstart)/(pyend-pystart));
				else
				    iBuffer.setpix(i,j, *(acpoint+j+pxstart));
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
			if( pxend > specs[ROWS])
				pxend = specs[ROWS];
			if( pystart < 0 )
				pystart = 0;
			if( pyend > specs[COLS])
				pyend = specs[COLS];
            
		}
		else {
			pxstart = 0;
			pxend = specs[ROWS];
			pystart = 0;
			pyend = specs[COLS];
		}
		
		acsize = specs[ROWS]*sizeof(DATAWORD);
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
			if(j==pxstart)
				mn = mx = sum;
			*(acpoint + j) = sum;
			if( *(acpoint+j) > mx) mx = *(acpoint+j);
			if( *(acpoint+j) < mn) mn = *(acpoint+j);
		}
		
		specs[ROWS] = abs(pxend - pxstart);
		
		if(!integratefill) {
			specs[COLS] = 1;
		}
		iBuffer.setspecs(specs);
        
		for (i=0; i<specs[ROWS]; i++) {
			for(j=0; j < specs[COLS]; j++) {
			    if(do_average)
                    iBuffer.setpix(i,j, *(acpoint+i+pxstart)/(pyend-pystart));
			    else
                    iBuffer.setpix(i,j, *(acpoint+i+pxstart));
			}
		}
        
		

	}
    free(acpoint);
    free(specs);
    iBuffer.getmaxx();
    update_UI();
    return iBuffer.err();
}

int integrate_c(int n,char* args){
    return integrateFill(n,args, false );
}

int intfill_c(int n,char* args){
    return integrateFill(n,args, true );
}

int ln_c(int n,char* args){
    for(int nt=0; nt<iBuffer.rows(); nt++) {
		for (int nc =0; nc<iBuffer.cols(); nc++){
			iBuffer.setpix(nt, nc, logf(iBuffer.getpix(nt, nc)));
		}
	}
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}




