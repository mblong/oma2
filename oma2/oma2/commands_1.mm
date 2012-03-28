#include "commands_1.h"

// the globals

extern char    reply[1024];   // buffer for sending messages to be typed out by the user interface
extern Image   iBuffer;       // the image buffer
extern rect    iRect;         // the image sub-rectagle (for cropping for example), 


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
        sprintf(reply,"Could not load %s\n",args);
        send_reply;
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
        sprintf(reply,"Could not open %s\n",args);
        send_reply;
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
    sprintf(reply,"Files are not the same size.\n");
    send_reply;
    iBuffer.errclear();
    return SIZE_ERR;
}

extern "C" int mulfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        sprintf(reply,"Could not open %s\n",args);
        send_reply;
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
    sprintf(reply,"Files are not the same size.\n");
    send_reply;
    iBuffer.errclear();
    return SIZE_ERR;
}

extern "C" int subfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        sprintf(reply,"Could not open %s\n",args);
        send_reply;
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
    sprintf(reply,"Files are not the same size.\n");
    send_reply;
    iBuffer.errclear();
    return SIZE_ERR;
}

extern "C" int divfile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        sprintf(reply,"Could not open %s\n",args);
        send_reply;
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
    sprintf(reply,"Files are not the same size.\n");
    send_reply;
    iBuffer.errclear();
    return SIZE_ERR;
}

extern "C" int concatenatefile_c(int n,char* args){
    Image new_im(fullname(args,GET_DATA));
    if(new_im.err()){
        sprintf(reply,"Could not open %s\n",args);
        send_reply;
        return new_im.err();
    }
    if(iBuffer.concat(new_im).err()){
        new_im.free();
        int err = iBuffer.err();
        sprintf(reply,"Error: %d.\n",err);
        send_reply;
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    new_im.free();
    update_UI();
    return NO_ERR;
}

extern "C" int croprectangle_c(int n,char* args){
    if(iBuffer.crop(iRect).err()){
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
    
    if(narg == 0){
        
        sprintf(reply,"Current Rectangle is %d %d %d %d.\n",
               iRect.ul.h,iRect.ul.v,iRect.lr.h,iRect.lr.v);
        send_reply;
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
        sprintf(reply,"Need 4 Arguments.\n"); 
        send_reply;
        return -1;
    }
    iRect = new_rect;
    start = iRect.ul;
    end = iRect.lr;
    // remove restriction on the way a rectangle is defined
    // previously, the assumption was that all rectangles were defined from the upper left to lower right
    if(end.h < start.h){
        iRect.lr.h = start.h;
        iRect.ul.h = end.h;
    }
    if(end.v < start.v){
        iRect.lr.v = start.v;
        iRect.ul.v = end.v;
    }

    sprintf(reply,"Current Rectangle is %d %d %d %d.\n",
           iRect.ul.h,iRect.ul.v,iRect.lr.h,iRect.lr.v);
    send_reply;
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
    if(iBuffer.rgb2color(0).err()){
        int err = iBuffer.err();
        sprintf(reply,"Error: %d.\n",err);
        send_reply;
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int rgb2green_c(int n,char* args){
    if(iBuffer.rgb2color(1).err()){
        int err = iBuffer.err();
        sprintf(reply,"Error: %d.\n",err);
        send_reply;
        iBuffer.errclear();
        return err;
    }
    iBuffer.getmaxx();
    update_UI();
    return NO_ERR;
}

extern "C" int rgb2blue_c(int n,char* args){
    if(iBuffer.rgb2color(2).err()){
        int err = iBuffer.err();
        sprintf(reply,"Error: %d.\n",err);
        send_reply;
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
    int narg = sscanf(args,"%f",&angle);
    if(narg == 0) angle = 90.;
    if (!specs[IS_COLOR]) {
        if(iBuffer.rotate(angle).err()){
            int err = iBuffer.err();
            sprintf(reply,"Error: %d.\n",err);
            send_reply;
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
            sprintf(reply,"Error: %d.\n",err);
            send_reply;
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


/************************************************************************/
/*

*/
//extern char	saveprefixbuf[];		/* save data file prefix buffer */
//extern char	savesuffixbuf[];		/* save data file suffix buffer */
//extern char	getprefixbuf[];		/* get data file prefix buffer */
//extern char	getsuffixbuf[];		/* get data file suffix buffer */
//extern char	graphicsprefixbuf[];	/* graphics file prefix buffer */
//extern char	graphicssuffixbuf[];	/* graphics file suffix buffer */
//extern char	macroprefixbuf[];     /* macro file prefix buffer */
//extern char	macrosuffixbuf[];     /* macro file suffix buffer */


// update the User Interface
// for omaT, this glues the new Image class results into the old globals-based system
// In general though, this is a way to update user interface values after a command

void update_UI(){
    /*
    DATAWORD* vals = iBuffer.getvalues();
    printf(" min/max: %g %g\n",vals[MIN],vals[MAX]);
    int * imspecs = iBuffer.getspecs();
    printf(" r/c: %d %d\n",imspecs[ROWS],imspecs[COLS]);
    printf(" have/loc: %d %d\n",imspecs[HAVE_MAX],imspecs[LMAX]);
    free(vals);
    free(imspecs);
    */
/*    int r,c,i=0;
    int *imspecs;
    
    
    

	have_max = 0;

	update_status();
    printxyzstuff_nib(iRect.ul.h,iRect.ul.v, 0);
    printxyzstuff_nib(iRect.lr.h,iRect.lr.v,1);
 
    free(imspecs);
 */
}

