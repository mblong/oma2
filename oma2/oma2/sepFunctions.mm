#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include "sep.h"
#include "oma2.h"
#include "image.h"
#include <vector>
#include "openCVroutines.h"
#include <opencv2/opencv.hpp>

using namespace std;
using namespace cv;

//#include <opencv2/opencv.hpp>

//#include <opencv2/core.hpp>
//#include <opencv2/opencv.hpp>
//#include <opencv2/highgui.hpp>
//#include <opencv2/video.hpp>
//#include <opencv2/photo.hpp>
#include <opencv2/calib3d.hpp>


using namespace std;
using namespace cv;


extern Image iBuffer;
extern Image  iTempImages[];
extern Variable user_variables[];

sep_catalog* catalog = NULL;
vector<Point3f> theStars;
int absolute=0;
float globalBackMedian=0, globalBackRMS=0;

/*
STARCLEAR
 Delete the catalog of stars found with the STARS command.
 */
int starClear(int n, char* args)
{
    if(catalog){
        sep_catalog_free(catalog);
        catalog=NULL;
        theStars.clear();
    }
    return NO_ERR;
}

/*
STARS Factor Radius SizeFactor EllipticityFactor
 Assume the image is a deep sky image, and identify the stars. Uses the SEP algorithms (https://github.com/kbarbary/sep). Background is subtracted and stored as temp image bkg. Factor specifies the threshold multiplier factor -- the threshold will be factor*globalRms. Default is 1.5.
 */
int stars(int n, char* args)
{
    //char *fname1, *fname2;
    int i, status, nx, ny;
    double *flux, *fluxerr, *fluxt, *fluxerrt, *area, *areat;
    short *flag, *flagt;
    float *data;
    //sep_bkg *bkg = NULL;
    float conv[] = {1,2,1, 2,4,2, 1,2,1};
    
    if(catalog){
        sep_catalog_free(catalog);
        catalog=NULL;
        theStars.clear();
    }
    
    status = 0;
    flux = fluxerr = NULL;
    flag = NULL;
    nx = iBuffer.width();
    //ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    ny = iBuffer.height();
    if(iBuffer.isColor()){
        data = iBuffer.getImageData()+nx*ny;    // for color images, use the green channel to find stars
    } else {
        data = iBuffer.getImageData();
    }
    
    float factor=2.0;
    float radius = 5.0;
    float sizeFactor=4.0;
    float ellipticityFactor=2.0;
    sscanf(args,"%f %f %f %f", &factor,&radius,&sizeFactor,&ellipticityFactor);
    
    Image copy;
    copy << iBuffer;
    // get the background
    starBack(0,NULL);
    n = temp_image_index((char*)"bkg",1);
    if(n >=0){
        iTempImages[n] << iBuffer;
    } else {
        beep();
        printf("Error saving temp image 'bkg'\n");
    }
    copy - iBuffer; // subtract the background
    iBuffer.free(); // done with the background
    iBuffer = copy;
    
    /*
    // background estimation
    sep_image im = {data, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
    status = sep_background(&im, 64, 64, 3, 3, 0.0, &bkg);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    //printf("median %.3f   rms %.3f\n",sep_bkg_global( bkg), sep_bkg_globalrms(bkg));
    
    // evaluate background
    imback = (float *)malloc((nx * ny)*sizeof(float));
    status = sep_bkg_array(bkg, imback, SEP_TFLOAT);
    if (status) {
        sep_bkg_free(bkg);
        printErr(status);        return status;
    }else {
        // save to temp image
        Image copy;
        copy.copyABD(iBuffer); // get the specs
        int* specs = iBuffer.getspecs();
        specs[IS_COLOR] = 0;
        specs[ROWS] = ny;
        copy.setspecs(specs);
        free(specs);
        copy.setImageData(imback);
        n = temp_image_index((char*)"bkg",1);
        if(n >=0){
            iTempImages[n] << copy;
        } else {
            beep();
            printf("Error saving temp image 'bkg'\n");
        }
        copy.free();
    }
    
    // subtract background
    status = sep_bkg_subarray(bkg, data, im.dtype);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    */
    
    // extract sources
    // Note that we set deblend_cont = 1.0 to turn off deblending.
    //
    sep_image im = {iBuffer.getImageData() +iBuffer.isColor()*nx*ny, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
    status = sep_extract(&im, factor*globalBackRMS, SEP_THRESH_ABS,
                         5, conv, 3, 3, SEP_FILTER_CONV,
                         32, .005, 1, 1.0, &catalog);
    if (status){
        //sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    if( catalog->nobj == 0){
        //sep_bkg_free(bkg);
        beep();
        printf("No stars found.\n");
        return CMND_ERR;
    }
    
    // aperture photometry
    im.noise = &globalBackRMS;  /* set image noise level */
    im.ndtype = SEP_TFLOAT;
    fluxt = flux = (double *)malloc(catalog->nobj * sizeof(double));
    fluxerrt = fluxerr = (double *)malloc(catalog->nobj * sizeof(double));
    areat = area = (double *)malloc(catalog->nobj * sizeof(double));
    flagt = flag = (short *)malloc(catalog->nobj * sizeof(short));
    double aveEllipticity=0,aveSize=0;
    for (i=0; i<catalog->nobj; i++, fluxt++, fluxerrt++, flagt++, areat++){
        sep_sum_circle(&im,catalog->x[i], catalog->y[i], radius, 0, 5, 0,fluxt, fluxerrt, areat, flagt);
        aveEllipticity += (catalog->a[i] - catalog->b[i])/catalog->a[i];
        aveSize += catalog->a[i] + catalog->b[i];
    }
    aveEllipticity/=catalog->nobj;
    aveSize/=catalog->nobj;
    printf("Average Ellipticity: %g Average Size: %g\n",aveEllipticity,aveSize/2);
        
    for (i=0; i<catalog->nobj; i++)
    {
        if (absolute){
            if(catalog->a[i] + catalog->b[i] <= sizeFactor && (catalog->a[i] - catalog->b[i])/catalog->a[i] <= ellipticityFactor){
                theStars.push_back(Point3f(catalog->x[i],catalog->y[i],catalog->flux[i]));  // save this star
            } else {
                catalog->flag[i] = SEP_OBJ_EXCLUDE;
            }
        } else {
            if(catalog->a[i] + catalog->b[i] <= sizeFactor*aveSize && (catalog->a[i] - catalog->b[i])/catalog->a[i] <= ellipticityFactor*aveEllipticity){
                theStars.push_back(Point3f(catalog->x[i],catalog->y[i],catalog->flux[i]));  // save this star
            } else {
                catalog->flag[i] = SEP_OBJ_EXCLUDE;
            }
        }
    }
    // arrange stars from brightest to dimmest
    sort(theStars.begin(), theStars.end(), [](const Point3f& a, const Point3f& b) {
        return a.z > b.z;  // Assuming intensity is stored in the 'z' component
    });
    
    printf("Top three:\n");
    for(i=0; i<3;i++){
        printf("%.2f %.2f %.0f\n",theStars[i].x,theStars[i].y,theStars[i].z);
    }
    
    /* clean-up & exit */
    //sep_bkg_free(bkg);
    free(flux);
    free(fluxerr);
    free(flag);
    update_UI();
    return status;
}

/*
 STARMATCH [Factor Radius SizeFactor EllipticityFactor NumStars]
     Assume the current deep sky image is to be matched with an image whose stars have already been indentified with the STARS command. The first four arguemnts are the same as the for the STARS command, and should probably match.  NumStars specifies how many stars should be used in searching for matching stars between the two images. These are used to determine the affine transform used to match the images.
 */
int starMatch(int n, char* args)
{
    int i, status, nx, ny;
    double *flux, *fluxerr, *fluxt, *fluxerrt, *area, *areat;
    short *flag, *flagt;
    float *data;
    //sep_bkg *bkg = NULL;
    float conv[] = {1,2,1, 2,4,2, 1,2,1};
    sep_catalog* matchCatalog = NULL;
    
    if(catalog == NULL){
        beep();
        printf("No catalog is present. Use the STARS comand on the first image.\n");
        return CMND_ERR;
    }
    
    status = 0;
    flux = fluxerr = NULL;
    flag = NULL;
    nx = iBuffer.width();
    //ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    ny = iBuffer.height();
    //data = iBuffer.getImageData();
    float factor=2.5;
    int numpts = 10;
    float radius=5;
    float sizeFactor=4.0;
    float ellipticityFactor=2.0;
    
    
    sscanf(args,"%f %f %f %f %d", &factor,&radius,&sizeFactor,&ellipticityFactor,&numpts);
    Image original;
    original << iBuffer;
    
    Image copy;
    copy << iBuffer;
    // get the background
    starBack(0,NULL);
    copy - iBuffer; // subtract the background
    iBuffer.free(); // done with the background
    iBuffer = copy;
    
    /*
     // background estimation
     sep_image im = {data, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
     status = sep_background(&im, 64, 64, 3, 3, 0.0, &bkg);
     if (status){
     sep_bkg_free(bkg);
     printErr(status);
     return status;
     }
     
     Image original;
     original << iBuffer;
     
     // subtract background
     status = sep_bkg_subarray(bkg, data, im.dtype);
     if (status){
     sep_bkg_free(bkg);
     printErr(status);
     return status;
     }
     */
    
    // extract sources
    // Note that we set deblend_cont = 1.0 to turn off deblending.
    //
    sep_image im = {iBuffer.getImageData() + iBuffer.isColor()*nx*ny, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
    status = sep_extract(&im, factor*globalBackRMS, SEP_THRESH_ABS,
                         5, conv, 3, 3, SEP_FILTER_CONV,
                         32, .005, 1, 1.0, &matchCatalog);
    if (status){
        //sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    
    // aperture photometry
    im.noise = &globalBackRMS;  /* set image noise level */
    im.ndtype = SEP_TFLOAT;
    fluxt = flux = (double *)malloc(matchCatalog->nobj * sizeof(double));
    fluxerrt = fluxerr = (double *)malloc(matchCatalog->nobj * sizeof(double));
    areat = area = (double *)malloc(matchCatalog->nobj * sizeof(double));
    flagt = flag = (short *)malloc(matchCatalog->nobj * sizeof(short));
    double aveEllipticity=0,aveSize=0;
    for (i=0; i<matchCatalog->nobj; i++, fluxt++, fluxerrt++, flagt++, areat++){
        sep_sum_circle(&im,matchCatalog->x[i], matchCatalog->y[i], radius, 0, 5, 0,fluxt, fluxerrt, areat, flagt);
        aveEllipticity += (matchCatalog->a[i] - matchCatalog->b[i])/matchCatalog->a[i];
        aveSize += matchCatalog->a[i] + matchCatalog->b[i];
    }
    aveEllipticity/=matchCatalog->nobj;
    aveSize/=matchCatalog->nobj;
    
    vector<Point3f> matchStars;
    
    for (i=0; i<matchCatalog->nobj; i++){
        if (absolute){
            if(matchCatalog->a[i] + matchCatalog->b[i] <= sizeFactor && (matchCatalog->a[i] - matchCatalog->b[i])/matchCatalog->a[i] <= ellipticityFactor){
                matchStars.push_back(Point3f(matchCatalog->x[i],matchCatalog->y[i],matchCatalog->flux[i]));  // save this star
            } else {
                matchCatalog->flag[i] = SEP_OBJ_EXCLUDE;
            }
        } else {
            if(matchCatalog->a[i] + matchCatalog->b[i] <= sizeFactor*aveSize && (matchCatalog->a[i] - matchCatalog->b[i])/matchCatalog->a[i] <= ellipticityFactor*aveEllipticity){
                matchStars.push_back(Point3f(matchCatalog->x[i],matchCatalog->y[i],matchCatalog->flux[i]));  // save this star
            } else {
                matchCatalog->flag[i] = SEP_OBJ_EXCLUDE;
            }
        }
    }
    // sort according to intesity
    sort(matchStars.begin(), matchStars.end(), [](const Point3f& a, const Point3f& b) {
        return a.z > b.z;  // Assuming intensity is stored in the 'z' component
    });
    
    float minDist,dist;
    int minIndex;
    Point3f temp;
    for(i=0; i<numpts;i++){
        minDist = pow(matchStars[i].x-theStars[i].x,2) + pow(matchStars[i].y-theStars[i].y,2);
        minIndex = i;
        for(int j=i+1; j<numpts; j++){
            dist = pow(matchStars[j].x-theStars[i].x,2) + pow(matchStars[j].y-theStars[i].y,2);
            if(dist < minDist){
                minDist = dist;
                minIndex = j;
            }
        }
        if(minIndex != i){  // change order
            temp = matchStars[i];
            matchStars[i] = matchStars[minIndex];
            matchStars[minIndex] = temp;
        }
        //printf("%.2f %.2f %.0f\n",matchStars[i].x,matchStars[i].y,matchStars[i].z);
    }
    
    // Extract matched keypoints
    //vector<Point2f> pointsBase, pointsAlign;
    //Point2f pointsBase[6], pointsAlign[6];
    vector<Point2f> pointsBase, pointsAlign;
    for (i=0; i<numpts;i++) {
        //pointsBase[i] = (Point2f(theStars[i].x,theStars[i].y));
        //pointsAlign[i] = (Point2f(matchStars[i].x,matchStars[i].y));
        pointsBase.push_back(Point2f(theStars[i].x,theStars[i].y));
        pointsAlign.push_back(Point2f(matchStars[i].x,matchStars[i].y));
    }
    
    vector<uchar> inliers(numpts, 0);
    // Find the homography transformation between the keypoints
    //Mat H = findHomography(pointsAlign, pointsBase, RANSAC);
    //Mat H = getAffineTransform(pointsBase,pointsAlign);
    Mat H = estimateAffine2D(pointsBase, pointsAlign,inliers,RANSAC);
    int inlie=0;
    for(i=0; i<numpts; i++)
        inlie += inliers.at(i);
    pprintf("%d inliers of %d\n",inlie,numpts);
    user_variables[0].ivalue = user_variables[0].fvalue = inlie;
    user_variables[0].is_float = 0;
    
    
    // Apply the transformation to align the images
    // warpAffine(imageToAlign, alignedImage, H, baseImage.size());
    // Use warpAffine for Translation, Euclidean and Affine
    DATAWORD* bgrArray;
    Mat im2_original;
    Mat im2_aligned;
    DATAWORD* bluePtr;
    DATAWORD* greenPtr;
    DATAWORD* dataPtr;
    
    
    if(original.isColor()){
        // need a BGR array for this
        int size=iBuffer.height()*iBuffer.width();
        bgrArray=new DATAWORD[size*3];
        DATAWORD* bgrPtr=bgrArray;
        dataPtr = original.getImageData();
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<size; i++){     
            *bgrPtr++ = *bluePtr++;
            *bgrPtr++ = *greenPtr++;
            *bgrPtr++ = *dataPtr++;
        }
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3, bgrArray);
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3);
    } else {
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1, original.getImageData());
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1);
    }

    warpAffine(im2_original, im2_aligned, H, im2_original.size(), INTER_LINEAR + WARP_INVERSE_MAP);
    
    Image newIm=Image(nx*(1+original.isColor()*2),ny);
    newIm.copyABD(original);
    dataPtr = newIm.getImageData();
    DATAWORD* resultPtr = (DATAWORD*) im2_aligned.ptr();
    if(original.isColor()){
        delete[] bgrArray;
        int size=nx*ny;
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *bluePtr++ = *resultPtr++;
            *greenPtr++ = *resultPtr++;
            *dataPtr++ = *resultPtr++;
        }
    } else {
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *dataPtr++ = *resultPtr++;
        }
    }
    im2_original.release();
    im2_aligned.release();
    
    original.free();
    iBuffer.free();
    iBuffer=newIm;
    iBuffer.getmaxx(PRINT_RESULT);

    /* clean-up & exit */
    //sep_bkg_free(bkg);
    sep_catalog_free(matchCatalog);
    free(flux);
    free(fluxerr);
    free(flag);
    update_UI();
    return status;
}


void printErr(int status){
    beep();
    char errtext[512];
    sep_get_errdetail(errtext);
    printf("FAILED with status: %d --- %s\n", status,errtext);
}

/*
STARBACK [tileSize filtersize]
 Assume the image is a deep sky image, and use the SEP algorithms (https://github.com/kbarbary/sep) to find the background. tileSize is the size (in pixels) of a region grouped together -- default is 64. filtersize is the size (in tiles) of the filter -- default is 3.
 */
int starBack(int n, char* args)
{
    int status, nx, ny,tileSize=64,filterSize=3;
    //float *data, *imback;
    sep_bkg *bkg = NULL;
    
    status = 0;
    nx = iBuffer.width();
    //ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    ny = iBuffer.height();
    if(args) sscanf(args,"%d %d", &tileSize,&filterSize);
    // background estimation for each color separately
    sep_image im = {NULL, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
    for (int i=0; i< 1+iBuffer.isColor()*2; i++) {
        im.data = iBuffer.getImageData() + nx*ny*i;
        status = sep_background(&im, tileSize, tileSize, filterSize, filterSize, 0.0, &bkg);
        if (status){
            sep_bkg_free(bkg);
            printErr(status);
            return status;
        }
        printf("For color %d:\tMedian %.2f\tRMS %.2f\n",i+1,sep_bkg_global( bkg), sep_bkg_globalrms(bkg));
        if(i<2){
            globalBackMedian = sep_bkg_global( bkg);
            globalBackRMS = sep_bkg_globalrms(bkg);
        }
        /* evaluate background */
        //imback = (float *)malloc((nx * ny)*sizeof(float));
        status = sep_bkg_array(bkg, (float *)im.data, SEP_TFLOAT);
        if (status) {
            sep_bkg_free(bkg);
            printErr(status);
            return status;
        }
    }
    sep_bkg_free(bkg);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return status;
}

/*
 STARABSOLUTE [absoluteFlag]
     If the argument is present, the absoluteFlag is set accordingly. Otherwise, the current value of absoluteFlag is printed.
 */
int starAbsolute(int n, char* args){
    
    if (*args) {
        sscanf(args, "%d",&absolute);
    }
    printf("absoluteFlag is %d\n", absolute);
    return NO_ERR;
}



double *ones_dbl(int nx, int ny)
{
    int i, npix;
    double *im, *imt;
    
    im = (double *)malloc((npix = nx*ny)*sizeof(double));
    imt = im;
    for (i=0; i<npix; i++, imt++)
        *imt = 1.0;
    
    return im;
}


float *uniformf(float a, float b, int n)
/* an array of n random numbers from the uniform interval (a, b) */
{
    int i;
    float *result;
    
    result = (float*)malloc(n*sizeof(float));
    for (i=0; i<n; i++)
        result[i] = a + (b-a) * rand() / ((double)RAND_MAX);
    
    return result;
}

float *ones(int nx, int ny)
{
    int i, npix;
    float *im, *imt;
    
    im = (float *)malloc((npix = nx*ny)*sizeof(float));
    imt = im;
    for (i=0; i<npix; i++, imt++)
        *imt = 1.0;
    
    return im;
}

void addbox(float *im, int w, int h, float xc, float yc, float r, float val)
/* n = sersic index */
{
    int xmin, xmax, ymin, ymax;
    int x, y;
    
    int rmax = (int)r;
    
    xmin = (int)xc - rmax;
    xmin = (xmin < 0)? 0: xmin;
    xmax = (int)xc + rmax;
    xmax = (xmax > w)? w: xmax;
    ymin = (int)yc - rmax;
    ymin = (ymin < 0)? 0: ymin;
    ymax = (int)yc + rmax;
    ymax = (ymax > h)? h: ymax;
    
    for (y=ymin; y<ymax; y++)
        for (x=xmin; x<xmax; x++)
            im[x+w*y] += val;
    
}


float *tile_flt(float *im, int nx, int ny, int ntilex, int ntiley,
                int *nxout, int *nyout)
{
    int i, x, y;
    int npixout;
    float *imout;
    
    *nxout = ntilex * nx;
    *nyout = ntiley * ny;
    npixout = *nxout * *nyout;
    
    imout = (float*)malloc(npixout*sizeof(float));
    for (i=0; i<npixout; i++)
    {
        x = (i%(*nxout)) % nx; /* corresponding x on small im */
        y = (i/(*nxout)) % ny; /* corresponding y on small im */
        imout[i] = im[y*nx + x];
    }
    return imout;
}

/***************************************************************************/
/* aperture photometry */

/*
 int naper, j;
 float *xcs, *ycs;
 
 im = ones(nx, ny);
 naper = 1000;
 flux = fluxerr = 0.0;
 flag = 0;
 
 float rs[] = {3., 5., 10., 20.};
 for (j=0; j<4; j++)
 {
 r = rs[j];
 xcs = uniformf(2.*r, nx - 2.*r, naper);
 ycs = uniformf(2.*r, ny - 2.*r, naper);
 
 printf("sep_apercirc() [r=%4.1f]   ", r);
 t0 = gettime_ns();
 for (i=0; i<naper; i++)
 sep_apercirc(im, NULL, SEP_TFLOAT, nx, ny, 0.0, 0.0,
 xcs[i], ycs[i], r, 5, &flux, &fluxerr, &flag);
 t1 = gettime_ns();
 printf("%6.3f us/aperture\n", (double)(t1 - t0) / 1000. / naper);
 free(xcs);
 free(ycs);
 }
 
 
 
 */

