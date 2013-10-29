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


ImageBitmap::ImageBitmap(){
    pixdata = 0;            //
    width = height = UIData.iscolor = 0;
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


void ImageBitmap::operator=(Image im){
	//Ptr ptr;
	pdptr = &pixdata;
	int k = 0, i,j,n=0;
	int ntrack = im.specs[ROWS];
	int nchan = im.specs[COLS];
	int nth;
	float pix_scale;
    int pindx;
    
    int allocate_new=1;
	
    if(UIData.autoscale){
        UIData.cmax = im.values[MAX];
        UIData.cmin = im.values[MIN];
    }
    //printf("%g %g cmin cmax\n",cmin,cmax);
    
	crange = UIData.cmax - UIData.cmin;
	cmin = UIData.cmin;
	
	if( UIData.pixsiz > 0 ){
		nth = 1;
		pix_scale = 1.0;
	} else {
		nth = abs(UIData.pixsiz);
		pix_scale=1.0/nth;
	}
    
    width = im.specs[COLS]/nth;
    if (im.specs[IS_COLOR]) 
        height = im.specs[ROWS]/nth/3;
	else
        height = im.specs[ROWS]/nth;

	
	if(allocate_new){
        if(pixdata) free(pixdata);
		pixdata = (PIXBYTES*)calloc(width*height,4);
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
	if(pixdata == NULL){
		beep();
		printf("memory error\n");
		//return pixdata;
	}
    if (im.specs[IS_COLOR]) {
        thePalette = -1;
        DATAWORD *pt_green,*pt_blue;
        pt_green = im.data + nchan*ntrack/3;
        pt_blue =  pt_green + nchan*ntrack/3;
        int k=0;

        if( UIData.pixsiz > 0 ) {
            for(i=0; i < ntrack/3; i++){
                for(j=0; j < nchan; j++){
                    *(pixdata+n++) = scale_pixval(*(im.data+k)*UIData.r_scale);
                    *(pixdata+n++) = scale_pixval(*(pt_green+k)*UIData.g_scale);
                    *(pixdata+n++) = scale_pixval(*(pt_blue+k++)*UIData.b_scale);
                    *(pixdata+n++) =0xFF;
                }
            }
        }else {     // this case isn't implemented
            i = 0;
            while(++i < ntrack/nth){
                j = 0;
                while( j++ < nchan/nth){
                    pindx = scale_pixval(*(im.data+k));
                    k += nth;                
                    *(pixdata+n++) = color[pindx][UIData.thepalette].red;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].green;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].blue;
                    *(pixdata+n++) =0xFF;
                }
                k = i * nth * nchan;
            }
        }
    } else {
        thePalette = UIData.thepalette;
        if( UIData.pixsiz > 0 ) {
            for(i=0; i < ntrack; i++){
                for(j=0; j < nchan; j++){
                    pindx = scale_pixval(*(im.data+k++));
                    *(pixdata+n++) = color[pindx][UIData.thepalette].red;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].green;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].blue;
                    *(pixdata+n++) =0xFF;
                }
            }
        }else {
            i = 0;
            while(++i < ntrack/nth){
                j = 0;
                while( j++ < nchan/nth){
                    pindx = scale_pixval(*(im.data+k));
                    k += nth;                
                    *(pixdata+n++) = color[pindx][UIData.thepalette].red;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].green;
                    *(pixdata+n++) = color[pindx][UIData.thepalette].blue;
                    *(pixdata+n++) =0xFF;
                }
                k = i * nth * nchan;
            }
        }
    }
}

PIXBYTES* ImageBitmap::getpixdata(){
    return pixdata;
}

PIXBYTES** ImageBitmap::getpixdatap(){
    return pdptr;
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
