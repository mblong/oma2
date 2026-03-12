//
//  ImageBitmap.cpp
//  oma2
//
//  Created by Marshall Long on 3/30/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//
#include "ImageBitmap.h"

ImageBitmap iBitmap;    // a global -- the bitmap for the iBuffer image

extern oma2UIData  UIData;
RGBColor color[256][8];
unsigned char customPalette[768];


ImageBitmap::ImageBitmap(){
    pixdata = 0;            //
    pixdata16 = 0;
    intensity = 0;
    width = height = 0;
    hdrActive = 0;
    UIData.pixsiz = 1;
    
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

int ImageBitmap::scale_pixval16(DATAWORD val)
{
    int pval;
    float fpval;
    
    fpval = (val-cmin) * (NCOLORS16-1);
    pval = fpval/crange;
    if( pval > (NCOLORS16-1))
        pval = (NCOLORS16-1);
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
	
    if(UIData.autoscale){
        UIData.cmax = im.values[MAX] - (im.values[MAX]-im.values[MIN])*(1.0 - UIData.displaySaturateValue);
        UIData.cmin = im.values[MIN] + (im.values[MAX]-im.values[MIN])*UIData.displayFloorValue;
    }
    //printf("%g %g cmin cmax\n",cmin,cmax);
    
	crange = UIData.cmax - UIData.cmin;
	cmin = UIData.cmin;
	   
    width = im.specs[COLS];
    if (im.specs[IS_COLOR])
        height = im.specs[ROWS]/3;
	else
        height = im.specs[ROWS];
    
	
    hdrActive = 0;
    
	if(allocate_new){
        if(pixdata) free(pixdata);
		pixdata = (PIXBYTES*)malloc(width*height*3);
        
        if(pixdata16) free(pixdata16);
        pixdata16 = NULL;
        if(im.specs[IS_COLOR] && UIData.useHDR){
            pixdata16 = (PIXBYTES16*)malloc(width*height*3*sizeof(PIXBYTES16));
            if(pixdata16 != NULL) hdrActive = 1;
        }
        
        if(intensity) free(intensity);
        if(im.specs[IS_COLOR])
            intensity = (PIXBYTES*)malloc(width*height*3);
        else
            intensity = (PIXBYTES*)malloc(width*height);
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
	if(pixdata == NULL || intensity == NULL){
		beep();
		printf("memory error\n");
		return;
	}
    if (im.specs[IS_COLOR]) {
        thePalette = -1;
        DATAWORD *pt_green,*pt_blue;
        pt_green = im.data + nchan*ntrack/3;
        pt_blue =  pt_green + nchan*ntrack/3;
        int k=0;
        float r,g,b;
        
        int saturated;
        float rExp=1./UIData.redGamma;
        float gExp=1./UIData.greenGamma;
        float bExp=1./UIData.blueGamma;
        float rmax=im.values[RMAX];
        float gmax=im.values[GMAX];
        float bmax=im.values[BMAX];
        int n16=0;
        int pindx16;
        DATAWORD scaledVal;
        
        for(i=0; i < ntrack/3; i++){
            for(j=0; j < nchan; j++){
                saturated = 0;
                
                // Red channel
                if(UIData.redGamma != 1.){
                    r = *(im.data+k)/rmax;
                    scaledVal = rmax*UIData.r_scale*pow(r,rExp);
                }else{
                    scaledVal = *(im.data+k)*UIData.r_scale;
                }
                pindx = scale_pixval(scaledVal);
                if(pindx == NCOLORS-1) saturated = 1;
                *(pixdata+n++) = pindx;
                *(intensity+m++) = pindx;
                if(hdrActive){
                    pindx16 = scale_pixval16(scaledVal);
                    *(pixdata16+n16++) = pindx16;
                }
                
                // Green channel
                if(UIData.greenGamma != 1.){
                    g = *(pt_green+k)/gmax;
                    scaledVal = gmax*UIData.g_scale*pow(g,gExp);
                }else{
                    scaledVal = *(pt_green+k)*UIData.g_scale;
                }
                pindx = scale_pixval(scaledVal);
                if(pindx == NCOLORS-1) saturated = 1;
                *(pixdata+n++) = pindx;
                *(intensity+m++) = pindx;
                if(hdrActive){
                    pindx16 = scale_pixval16(scaledVal);
                    *(pixdata16+n16++) = pindx16;
                }
                
                // Blue channel
                if(UIData.blueGamma != 1.){
                    b = *(pt_blue+k++)/bmax;
                    scaledVal = bmax*UIData.b_scale*pow(b,bExp);
                }else{
                    scaledVal = *(pt_blue+k++)*UIData.b_scale;
                }
                pindx = scale_pixval(scaledVal);
                if(pindx == NCOLORS-1) saturated = 1;
                *(pixdata+n++) = pindx;
                *(intensity+m++) = pindx;
                if(hdrActive){
                    pindx16 = scale_pixval16(scaledVal);
                    *(pixdata16+n16++) = pindx16;
                }
                
                if(saturated & UIData.highlightSaturated){
                    *(pixdata+n-3)= UIData.highlightSaturatedRed;
                    *(pixdata+n-2)= UIData.highlightSaturatedGreen;
                    *(pixdata+n-1)= UIData.highlightSaturatedBlue;
                    if(hdrActive){
                        *(pixdata16+n16-3)= UIData.highlightSaturatedRed * 257;
                        *(pixdata16+n16-2)= UIData.highlightSaturatedGreen * 257;
                        *(pixdata16+n16-1)= UIData.highlightSaturatedBlue * 257;
                    }
                }
            }
        }
    } else {
        thePalette = UIData.thepalette;
        
        for(i=0; i < ntrack; i++){
            for(j=0; j < nchan; j++){
                pindx = scale_pixval(*(im.data+k++));
                if(UIData.highlightSaturated && pindx == NCOLORS-1){
                    *(pixdata+n++) = UIData.highlightSaturatedRed;;
                    *(pixdata+n++) = UIData.highlightSaturatedGreen;
                    *(pixdata+n++) = UIData.highlightSaturatedBlue;
                    
                } else{
                    *(pixdata+n++) = color[pindx][UIData.thepalette].red;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].green;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].blue;
                }
                /*
                 // Could set alpha value to 0 or FF according to a threshold; used this to make icon
                 if (pindx < 10) {
                 *(pixdata+n++) = 0;
                 }else{
                 *(pixdata+n++) = 0xFF;
                 }
                 */
                *(intensity+m++) =pindx;
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

PIXBYTES16* ImageBitmap::getpixdata16(){
    return pixdata16;
}

int ImageBitmap::isHDR(){
    return hdrActive;
}

PIXBYTES** ImageBitmap::getpixdatap(){
    return pdptr;
}

void ImageBitmap::freeMaps(){
    if(pixdata) free(pixdata);
    pixdata = NULL;
    
    if(pixdata16) free(pixdata16);
    pixdata16 = NULL;
    hdrActive = 0;
    
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

//************************************
/*
 Ptr Get_rgb_from_image_buffer(int allocate_new)
 {
 Ptr ptr;
 
 long k = 0, i,j,n=0;
 int ntrack = im.specs[ROWS];
 int nchan = im.specs[COLS];
 int nth;
 float pix_scale;
 
 float fpindx;
 DATAWORD crange,cm,ncm1,indx;
 int pindx;
 
 
 
 crange = cmax - cmin;
 ncm1 = (ncolor-1);
 cm = cmin;
 
 if( pixsiz > 0 ){
 nth = 1;
 pix_scale = 1.0;
 } else {
 nth = abs(pixsiz);
 pix_scale=1.0/nth;
 }
 
 if(allocate_new)
 ptr = calloc(header[NCHAN]/nth*header[NTRAK]/nth,4);
 else{
 // try and reuse the same window, but be sure the size is the same
 if( oma_wind[gwnum-1].width == header[NCHAN]/nth &&
 oma_wind[gwnum-1].height == header[NTRAK]/nth) {
 ptr = oma_wind[gwnum-1].window_rgb_data;
 } else {
 if(oma_wind[gwnum-1].window_rgb_data != 0) 
 free(oma_wind[gwnum-1].window_rgb_data);
 return NULL;
 }
 }
 if(ptr == NULL){
 beep();
 printf("memory error\n");
 return ptr;
 }
 oma_wind[gwnum].width = header[NCHAN]/nth;
 oma_wind[gwnum].height = header[NTRAK]/nth;
 if( pixsiz > 0 ) {
 for(i=0; i < ntrack; i++){
 for(j=0; j < nchan; j++){
 indx = *(point+k++) - cm;
 fpindx = (float)indx * ncm1;
 pindx = fpindx/crange;
 if( pindx > ncm1)
 pindx = ncm1;
 if( pindx < 0)
 pindx = 0;
 ++pindx;
 *(ptr+n++) =pindx;
 *(ptr+n++) = color[pindx][thepalette].red/256;
 *(ptr+n++) = color[pindx][thepalette].green/256;
 *(ptr+n++) = color[pindx][thepalette].blue/256;
 }
 }
 }else {
 i = 0;
 while(++i < ntrack/nth){
 j = 0;
 while( j++ < nchan/nth){
 indx = *(point+k) - cm;
 k += nth;
 fpindx = (float)indx * ncm1;
 pindx = fpindx/crange;
 if( pindx > ncm1)
 pindx = ncm1;
 if( pindx < 0)
 pindx = 0;
 ++pindx;
 // *(ptr+n++) = 0xFF;
 *(ptr+n++) =pindx;
 *(ptr+n++) = color[pindx][thepalette].red/256;
 *(ptr+n++) = color[pindx][thepalette].green/256;
 *(ptr+n++) = color[pindx][thepalette].blue/256;
 }
 k = i * nth * nchan;
 }
 }
 
 
 return ptr;
 
 }
 
 
 Ptr Get_color_rgb_from_image_buffer(int allocate_new)
 {
 Ptr ptr;
 DATAWORD* point = datpt+doffset;
 long k = 0, i,j,n=0;
 int ntrack = specs[ROWS];
 int nchan = specs[COLS];
 int nth,intensity;
 float pix_scale;
 DATAWORD *pt_green,*pt_blue;
 
 //float fpindx;
 extern DATAWORD crange;
 extern float r_scale,g_scale,b_scale;
 //int pindx;
 
 crange = cmax - cmin;
 //ncm1 = (ncolor-1);
 //cm = cmin;
 
 if( pixsiz > 0 ){
 nth = 1;
 pix_scale = 1.0;
 } else {
 nth = abs(pixsiz);
 pix_scale=1.0/nth;
 }
 
 if(allocate_new)
 ptr = calloc(header[NCHAN]/nth*header[NTRAK]/nth/3,4);
 else{
 // try and reuse the same window, but be sure the size is the same
 if( oma_wind[gwnum-1].width == header[NCHAN]/nth &&
 oma_wind[gwnum-1].height == header[NTRAK]/nth/3) {
 ptr = oma_wind[gwnum-1].window_rgb_data;
 } else {
 if(oma_wind[gwnum-1].window_rgb_data != 0) 
 free(oma_wind[gwnum-1].window_rgb_data);
 return NULL;
 }
 }
 if(ptr == NULL){
 beep();
 printf("memory error\n");
 return ptr;
 }
 oma_wind[gwnum].width = header[NCHAN]/nth;
 oma_wind[gwnum].height = header[NTRAK]/nth/3;
 pt_green = point + nchan*ntrack/3;
 pt_blue =  pt_green + nchan*ntrack/3;
 
 if( pixsiz > 0 ) {
 for(i=0; i < ntrack/3; i++){
 for(j=0; j < nchan; j++){
 *(ptr+n+1) = scale_pixval(*(point+k)*r_scale);
 *(ptr+n+2) = scale_pixval(*(pt_green+k)*g_scale);
 *(ptr+n+3) = scale_pixval(*(pt_blue+k++)*b_scale);
 intensity = ( (unsigned char) *(ptr+n+1) + (unsigned char) *(ptr+n+2) + (unsigned char) *(ptr+n+3))/3;
 *(ptr+n) = intensity;
 n += 4;
 }
 }
 }else {
 i = 0;
 while(++i < ntrack/nth/3){
 j = 0;
 while( j++ < nchan/nth){
 *(ptr+n+1) = scale_pixval(*(point+k)*r_scale);
 *(ptr+n+2) = scale_pixval(*(pt_green+k)*g_scale);
 *(ptr+n+3) = scale_pixval(*(pt_blue+k)*b_scale);
 intensity = ( (unsigned char) *(ptr+n+1) + (unsigned char) *(ptr+n+2) + (unsigned char) *(ptr+n+3))/3;
 *(ptr+n) = intensity;
 k += nth;
 n += 4;
 }
 k = i * nth * nchan;
 }
 }
 return ptr;
 }
 */
