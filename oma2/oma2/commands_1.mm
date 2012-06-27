#include "commands_1.h"

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData; 


extern "C" int plus_c(int n,char* args){
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

extern "C" int minus_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer-val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int divide_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer/val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int multiply_c(int n,char* args){
    DATAWORD val;
    if( sscanf(args,"%f",&val) != 1)
		val = n;
    (iBuffer*val);
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int getfile_c(int n,char* args){
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

extern "C" int addfile_c(int n,char* args){
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

extern "C" int mulfile_c(int n,char* args){
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

extern "C" int subfile_c(int n,char* args){
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

extern "C" int divfile_c(int n,char* args){
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

extern "C" int concatenatefile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        printf2("Could not open %s\n",args);
        return new_im.err();
    }
    iBuffer.concat(new_im);
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

extern "C" int croprectangle_c(int n,char* args){
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


extern "C" int rectan_c(int n, char* args)
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

extern "C" int invert_c(int n,char* args){
    iBuffer.invert();
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int rgb2red_c(int n,char* args){
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

extern "C" int rgb2green_c(int n,char* args){
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

extern "C" int rgb2blue_c(int n,char* args){
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


extern "C" int rotate_c(int n,char* args){
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
            iBuffer.concat(color[c]);
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

extern "C" int smooth_c(int n,char* args){
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

/*
int calc(Point *start,Point *end)
{
	double xcom,ycom,ave,rms,ftemp;		// centroid coordinates,average, and rms 
	int icount,nt,nc;
	DATAWORD idat(int,int),datval;
	
	extern int showruler,plotline;
	extern int ruler_scale_defined;
	extern float ruler_scale;
	extern char unit_text[];
	extern Variable user_variables[];	
	extern DATAWORD min;
	
	if(start->v > end->v) {
		nt = end->v;
		end->v = start->v;
		start->v = nt;
	}
	if(start->h > end->h) {
		nt = end->h;
		end->h = start->h;
		start->h = nt;
	}
    
    if(UIData.toolselected == 
	
	if( showruler ) {
		if( plotline ) {
			do_line_plot(start,end);
			return 0;
		}	
		nt = start->v - end->v;
		nc = start->h - end->h;
		ftemp = nc;
		ycom = nt;
		xcom = nt*nt+nc*nc;
		xcom = sqrt(xcom);
		if( ruler_scale_defined ) {
			ftemp /= ruler_scale;
			xcom /= ruler_scale;
			ycom /= ruler_scale;
		}
		pprintf("∂x:\t%.2f\t∂y:\t%.2f",ftemp,ycom);		// For some goddamn reason, only can put 2 things on a line 
		if( ruler_scale_defined && unit_text[0] )
			pprintf("\tL:\t%.2f\t%s\n",xcom,unit_text);
		else
			pprintf("\tL:\t%.2f\n",xcom);
		return 0;
	}
	icount = 0;
	xcom = ycom = ave = rms = 0.0;
	
	//printf("%d %d %d %d \n", start->v,start->h,end->v,end->h);
	for(nt=start->v; nt<=end->v; nt++) {
		for(nc=start->h; nc<=end->h; nc++) {
			datval = idat(nt,nc);		
			ave += datval;					// average 
			xcom += nc * (datval-min);			// x center of mass -- subtract min
			ycom += nt * (datval-min);			// y center of mass -- subtract min 
			rms += datval*datval;			// rms 
			icount++;						// number of points 
		}
	}
	xcom /= icount;
	ycom /= icount;
	ave = ave/(float)icount;
	xcom /= (ave-min);
	ycom /= (ave-min);
	
	rms = rms/icount - ave*ave;	
	rms = sqrt(rms);
	
	pprintf("Ave:\t%g\trms:\t%g\t# Pts:\t",ave,rms);
	pprintf("%d",icount);
	if( ruler_scale_defined ) {
		xcom /= ruler_scale;
		ycom /= ruler_scale;
	}
	pprintf("\tx:\t%g\ty:\t%g",xcom,ycom);
	if( ruler_scale_defined && unit_text[0] )
		pprintf("\t%s\n",unit_text);
	else
		pprintf("\n");
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
 */

/************************************************************************/
/*

*/

