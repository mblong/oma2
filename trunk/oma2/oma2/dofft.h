//
//  dofft.h
//  oma2
//
//  Created by Marshall B. Long on 11/14/13.
//  Copyright (c) 2013 Yale University. All rights reserved.
//

#ifndef oma2_dofft_h
#define oma2_dofft_h

#include "Image.h"
#include "ImageBitmap.h"


int dofft(int n,char* args);
int is_power_2(int i);

int FASTF(float xreal[],float ximag[], int *isize);
void fastf(float r[],float i[], int *n);
int FT2D(float a[],float b[],float work1[],float work2[] ,int *n1,int *n2);
void four1(float data[] ,int nn,int isign);
void realft(float data[],int n,int isign);

#endif
