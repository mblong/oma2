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
//#include <opencv2/opencv.hpp>

//#include <opencv2/core.hpp>
//#include <opencv2/opencv.hpp>
//#include <opencv2/highgui.hpp>
//#include <opencv2/video.hpp>
//#include <opencv2/photo.hpp>



using namespace std;
using namespace cv;


extern Image iBuffer;
extern Image  iTempImages[];

sep_catalog* catalog = NULL;
vector<Point3f> theStars;

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
STARS Factor
 Assume the image is a deep sky image, and identify the stars. Uses the SEP algorithms (https://github.com/kbarbary/sep). Background is subtracted and stored as temp image bkg. Factor specifies the threshold multiplier factor -- the threshold will be factor*globalRms. Default is 1.5.
 */
int stars(int n, char* args)
{
    //char *fname1, *fname2;
    int i, status, nx, ny;
    double *flux, *fluxerr, *fluxt, *fluxerrt, *area, *areat;
    short *flag, *flagt;
    float *data, *imback;
    sep_bkg *bkg = NULL;
    float conv[] = {1,2,1, 2,4,2, 1,2,1};
    
    if(catalog){
        sep_catalog_free(catalog);
        catalog=NULL;
    }
    
    status = 0;
    flux = fluxerr = NULL;
    flag = NULL;
    nx = iBuffer.width();
    ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    data = iBuffer.getImageData();
    float factor=1.5;
    sscanf(args,"%f", &factor);
    
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
    //print_time("sep_bkg_array()", t1-t0);
    
    /* subtract background */
    status = sep_bkg_subarray(bkg, data, im.dtype);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    //print_time("sep_bkg_subarray()", t1-t0);
    
    // extract sources
    // Note that we set deblend_cont = 1.0 to turn off deblending.
    //
    status = sep_extract(&im, factor*bkg->globalrms, SEP_THRESH_ABS,
                         5, conv, 3, 3, SEP_FILTER_CONV,
                         32, .005, 1, 1.0, &catalog);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    
    // aperture photometry
    im.noise = &(bkg->globalrms);  /* set image noise level */
    im.ndtype = SEP_TFLOAT;
    fluxt = flux = (double *)malloc(catalog->nobj * sizeof(double));
    fluxerrt = fluxerr = (double *)malloc(catalog->nobj * sizeof(double));
    areat = area = (double *)malloc(catalog->nobj * sizeof(double));
    flagt = flag = (short *)malloc(catalog->nobj * sizeof(short));
    for (i=0; i<catalog->nobj; i++, fluxt++, fluxerrt++, flagt++, areat++){
        sep_sum_circle(&im,catalog->x[i], catalog->y[i], 5.0, 0, 5, 0,fluxt, fluxerrt, areat, flagt);
    }
    
    // print results
    //printf("writing to file: %s\n", fname2);
    //catout = fopen(fname2, "w+");
    //printf( "# SEP catalog\n");
    //printf( "# 1 NUMBER\n");
    //printf( "# 2 X_IMAGE (0-indexed)\n");
    //printf( "# 3 Y_IMAGE (0-indexed)\n");
    //printf( "# 4 FLUX\n");
    //printf( "# 5 FLUXERR\n");
    
    
    for (i=0; i<catalog->nobj; i++)
    {
        //printf( "%3d %#11.7g %#11.7g %#11.7g %#11.7g %#11.3g %#11.3g %#11.3g\n",i+1, catalog->x[i], catalog->y[i], flux[i], fluxerr[i],catalog->a[i],catalog->b[i],catalog->theta[i]);
        theStars.push_back(Point3f(catalog->x[i],catalog->y[i],catalog->flux[i]));
    }
    sort(theStars.begin(), theStars.end(), [](const Point3f& a, const Point3f& b) {
        return a.z > b.z;  // Assuming intensity is stored in the 'z' component
    });
    printf("Top three:\n");
    for(i=0; i<3;i++){
        pprintf("%.2f %.2f %.0f\n",theStars[i].x,theStars[i].y,theStars[i].z);
    }
    
    /* clean-up & exit */
    sep_bkg_free(bkg);
    //free(data);
    free(flux);
    free(fluxerr);
    free(flag);
    //sep_catalog_free(catalog);
    update_UI();
    return status;
}

/*
STARMATCH Factor
 Assume the current image is to be matched with an image.
 */
int starMatch(int n, char* args)
{
    int i, status, nx, ny;
    double *flux, *fluxerr, *fluxt, *fluxerrt, *area, *areat;
    short *flag, *flagt;
    float *data, *imback;
    sep_bkg *bkg = NULL;
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
    ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    data = iBuffer.getImageData();
    float factor=1.5;
    sscanf(args,"%f", &factor);
    
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
    /*
    imback = (float *)malloc((nx * ny)*sizeof(float));
    status = sep_bkg_array(bkg, imback, SEP_TFLOAT);
    if (status) {
        sep_bkg_free(bkg);
        printErr(status);        return status;
    }else {
        // save to temp image
        Image copy;
        copy.copyABD(iBuffer); // get the specs
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
    */
    
    Image original;
    original << iBuffer;

    // subtract background
    status = sep_bkg_subarray(bkg, data, im.dtype);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    
    // extract sources
    // Note that we set deblend_cont = 1.0 to turn off deblending.
    //
    status = sep_extract(&im, factor*bkg->globalrms, SEP_THRESH_ABS,
                         5, conv, 3, 3, SEP_FILTER_CONV,
                         32, .005, 1, 1.0, &matchCatalog);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    
    // aperture photometry
    im.noise = &(bkg->globalrms);  /* set image noise level */
    im.ndtype = SEP_TFLOAT;
    fluxt = flux = (double *)malloc(matchCatalog->nobj * sizeof(double));
    fluxerrt = fluxerr = (double *)malloc(matchCatalog->nobj * sizeof(double));
    areat = area = (double *)malloc(matchCatalog->nobj * sizeof(double));
    flagt = flag = (short *)malloc(matchCatalog->nobj * sizeof(short));
    for (i=0; i<matchCatalog->nobj; i++, fluxt++, fluxerrt++, flagt++, areat++){
        sep_sum_circle(&im,matchCatalog->x[i], matchCatalog->y[i], 5.0, 0, 5, 0,fluxt, fluxerrt, areat, flagt);
    }
        
    vector<Point3f> matchStars;
    
    for (i=0; i<matchCatalog->nobj; i++)
    {
        matchStars.push_back(Point3f(matchCatalog->x[i],matchCatalog->y[i],matchCatalog->flux[i]));
    }
    sort(matchStars.begin(), matchStars.end(), [](const Point3f& a, const Point3f& b) {
        return a.z > b.z;  // Assuming intensity is stored in the 'z' component
    });
    printf("Top three:\n");
    for(i=0; i<10;i++){
        pprintf("%.2f %.2f %.0f\n",matchStars[i].x,matchStars[i].y,matchStars[i].z);
    }
    
    // Extract matched keypoints
   //vector<Point2f> pointsBase, pointsAlign;
    Point2f pointsBase[6], pointsAlign[6];
    for (i=0; i<6;i++) {
        pointsBase[i] = (Point2f(theStars[i].x,theStars[i].y));
        pointsAlign[i] = (Point2f(matchStars[i].x,matchStars[i].y));
    }
    
 
    // Find the homography transformation between the keypoints
    //Mat H = findHomography(pointsAlign, pointsBase, RANSAC);
    Mat H = getAffineTransform(pointsBase,pointsAlign);

    // Apply the transformation to align the images
    //warpAffine(imageToAlign, alignedImage, H, baseImage.size());
    // Use warpAffine for Translation, Euclidean and Affine
    Mat im2_original;
    Mat im2_aligned;
    im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1, original.getImageData());
    im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1);
    
    warpAffine(im2_original, im2_aligned, H, im2_original.size(), INTER_LINEAR + WARP_INVERSE_MAP);
    
    DATAWORD* resultPtr = (DATAWORD*) im2_aligned.ptr();
    DATAWORD* dataPtr = iBuffer.getImageData();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *dataPtr++ = *resultPtr++;
    }
    
    original.free();
    im2_original.release();
    im2_aligned.release();

    /* clean-up & exit */
    sep_bkg_free(bkg);
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
    float *data, *imback;
    sep_bkg *bkg = NULL;
        
    status = 0;
    nx = iBuffer.width();
    ny = iBuffer.height()*(1+iBuffer.isColor()*2);
    data = iBuffer.getImageData();
    //float factor=1.5;
    sscanf(args,"%d %d", &tileSize,&filterSize);
    
    /* background estimation */
    sep_image im = {data, NULL, NULL, NULL, SEP_TFLOAT, 0, 0, 0, nx, ny, 0.0, SEP_NOISE_NONE, 1.0, 0.0};
    
    status = sep_background(&im, tileSize, tileSize, filterSize, filterSize, 0.0, &bkg);
    if (status){
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }
    //printf("median %.3f   rms %.3f\n",sep_bkg_global( bkg), sep_bkg_globalrms(bkg));
    
    /* evaluate background */
    imback = (float *)malloc((nx * ny)*sizeof(float));    
    status = sep_bkg_array(bkg, imback, SEP_TFLOAT);
    if (status) {
        sep_bkg_free(bkg);
        printErr(status);
        return status;
    }else {
        // save to current image buffer
        iBuffer.setImageData(imback);
    }
    sep_bkg_free(bkg);
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return status;
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

