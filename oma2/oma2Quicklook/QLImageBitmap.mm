//
//  QLImageBitmap.cpp
//  oma2
//
//  Created by Marshall Long on 3/30/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//
#include "QLImageBitmap.h"

QLImageBitmap iBitmap;    // a global -- the bitmap for the iBuffer image


//RGBColor color[256][8];
unsigned char customPalette[768];
DATAWORD cmax,cmin,crange;
float pixsiz;


QLImageBitmap::QLImageBitmap(){
    pixdata = 0;            //
    intensity = 0;
    width = height = 0;
    pixsiz = 1;
    
}

int QLImageBitmap::scale_pixval(DATAWORD val)
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

void QLImageBitmap::operator=(QLImage im){
	//Ptr ptr;
	pdptr = &pixdata;
	int k = 0, i,j,n=0;
	int ntrack = im.specs[ROWS];
	int nchan = im.specs[COLS];
    int pindx;
        
	crange = cmax - cmin;
	//cmin = cmin;
	   
    width = im.specs[COLS];
    if (im.specs[IS_COLOR])
        height = im.specs[ROWS]/3;
	else
        height = im.specs[ROWS];

    if(pixdata) free(pixdata);
    pixdata = (PIXBYTES*)malloc(width*height*3);
        
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

        
        for(i=0; i < ntrack/3; i++){
            for(j=0; j < nchan; j++){
                pindx = scale_pixval(*(im.data+k));
                *(pixdata+n++) = pindx;
                pindx = scale_pixval(*(pt_green+k));
                *(pixdata+n++) = pindx;
                pindx = scale_pixval(*(pt_blue+k++));
                *(pixdata+n++) = pindx;
 
            }
        }
    } else {
        for(i=0; i < ntrack; i++){
            for(j=0; j < nchan; j++){
                pindx = scale_pixval(*(im.data+k++));
                 *(pixdata+n++) = pindx;
                *(pixdata+n++) = pindx;
                *(pixdata+n++) = pindx;
            }
        }
    }
}

PIXBYTES* QLImageBitmap::getpixdata(){
    return pixdata;
}

PIXBYTES* QLImageBitmap::getintensitydata(){
    return intensity;
}

PIXBYTES** QLImageBitmap::getpixdatap(){
    return pdptr;
}

void QLImageBitmap::freeMaps(){
    if(pixdata) free(pixdata);
    pixdata = NULL;
    
    if(intensity) free(intensity);
    intensity = NULL;
}


int QLImageBitmap::getwidth(){
    return width;
}

int QLImageBitmap::getheight(){
    return height;
}

int QLImageBitmap::getpalette(){
    return thePalette;
}

