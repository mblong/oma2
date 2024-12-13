//
//  ImageBitmap.cpp
//  oma2
//
//  Created by Marshall Long on 3/30/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//
#include "ImageBitmap.h"

ImageBitmap iBitmap;    // a global -- the bitmap for the iBuffer image


//RGBColor color[256][8];
unsigned char customPalette[768];
DATAWORD cmax,cmin,crange;
float pixsiz;


ImageBitmap::ImageBitmap(){
    pixdata = 0;            //
    intensity = 0;
    width = height = 0;
    pixsiz = 1;
    
}

int ImageBitmap::scale_pixval(DATAWORD val)
{
    int pval;
    float fpval;
    
    fpval = (val-cmin) * (NCOLORS-1);
    pval = fpval/crange;
    if( pval > (NCOLORS-1))
        pval = (NCOLORS-1);
    if( pval < 0)
        pval = 0;
    return pval;
}

void ImageBitmap::operator=(Image im){
	//Ptr ptr;
	pdptr = &pixdata;
	int k = 0, i,j,n=0,m=0;
	int ntrack = im.specs[ROWS];
	int nchan = im.specs[COLS];
    int pindx;
    
    int allocate_new=1;
	
    
        //cmax = im.values[MAX] ;
        //cmin = im.values[MIN] ;
    
    ////printf("%g %g cmin cmax\n",cmin,cmax);
    
	crange = cmax - cmin;
	//cmin = cmin;
	   
    width = im.specs[COLS];
    if (im.specs[IS_COLOR])
        height = im.specs[ROWS]/3;
	else
        height = im.specs[ROWS];
    
	
	if(allocate_new){
        if(pixdata) free(pixdata);
		pixdata = (PIXBYTES*)malloc(width*height*3);
        
    }else{
		// try and reuse the same window, but be sure the size is the same
		/*if( oma_wind[gwnum-1].width == im.specs[COLS]/nth &&
         oma_wind[gwnum-1].height == im.specs[ROWS]/nth) {
         pixdata = oma_wind[gwnum-1].window_rgb_data;
         } else {
         if(oma_wind[gwnum-1].window_rgb_data != 0)
         free(oma_wind[gwnum-1].window_rgb_data);
         return NULL;
         }
         */
	}
	if(pixdata == NULL ){
		//beep();;
		//printf("memory error\n");
		return;
	}
    if (im.specs[IS_COLOR]) {
        thePalette = -1;
        DATAWORD *pt_green,*pt_blue;
        pt_green = im.data + nchan*ntrack/3;
        pt_blue =  pt_green + nchan*ntrack/3;
        int k=0;
        float r,g,b;
        
        /*
         if (r_gamma != 1.) {
         r = *(point+k)/rmax;
         *(ptr+n+1) = scale_pixval(rmax*r_scale*powf(r,1./r_gamma));
         } else {
         *(ptr+n+1) = scale_pixval(*(point+k)*r_scale);
         }
         
         */
        int saturated;

        float rmax=im.values[RMAX];
        float gmax=im.values[GMAX];
        float bmax=im.values[BMAX];
        
        for(i=0; i < ntrack/3; i++){
            for(j=0; j < nchan; j++){
                saturated = 0;
                
                
                pindx = scale_pixval(*(im.data+k));
                *(pixdata+n++) = pindx;
                pindx = scale_pixval(*(pt_green+k));
                *(pixdata+n++) = pindx;
                pindx = scale_pixval(*(pt_blue+k++));
                *(pixdata+n++) = pindx;
 
            }
        }
    } else {
        thePalette = 2;
        
        for(i=0; i < ntrack; i++){
            for(j=0; j < nchan; j++){
                pindx = scale_pixval(*(im.data+k++));
                /*
                *(pixdata+n++) = color[pindx][thePalette].red;
                *(pixdata+n++) = color[pindx][thePalette].green;
                *(pixdata+n++) = color[pindx][thePalette].blue;
                 */
                // use a grayscale palette
                *(pixdata+n++) = pindx;
                *(pixdata+n++) = pindx;
                *(pixdata+n++) = pindx;
                
                /*
                 // Could set alpha value to 0 or FF according to a threshold; used this to make icon
                 if (pindx < 10) {
                 *(pixdata+n++) = 0;
                 }else{
                 *(pixdata+n++) = 0xFF;
                 }
                 */
                
            }
        }
    }
}

PIXBYTES* ImageBitmap::getpixdata(){
    return pixdata;
}

PIXBYTES* ImageBitmap::getintensitydata(){
    return intensity;
}

PIXBYTES** ImageBitmap::getpixdatap(){
    return pdptr;
}

void ImageBitmap::freeMaps(){
    if(pixdata) free(pixdata);
    pixdata = NULL;
    
    if(intensity) free(intensity);
    intensity = NULL;
}


int ImageBitmap::getwidth(){
    return width;
}

int ImageBitmap::getheight(){
    return height;
}

int ImageBitmap::getpalette(){
    return thePalette;
}

