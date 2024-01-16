//
//  openCVroutines.cpp
//  oma2
//
//  Created by Marshall Long on 1/7/21.
//  Copyright © 2021 Yale University. All rights reserved.
//

#ifdef OPENCV_ROUTINES

#include "openCVroutines.h"


extern Image   iBuffer;       // the image buffer
extern ImageBitmap iBitmap;   // the bitmap buffer
extern oma2UIData UIData;


//static cv::VideoWriter outputVideo;
static cv::Mat frame;
static cv::Size frame_size;
#ifdef HOMEBREW
static bool videoOpened = 0;
#endif

extern ImageBitmap iBitmap;

extern int printMax;

int vidAddFrame_q(int n,char* args){
#ifdef HOMEBREW
    using namespace cv;

    //QImage theImage = wPointer->getVideoFrame();
    if(videoOpened && iBitmap.getpixdata() && iBitmap.getwidth() && iBitmap.getheight()){
        frame = Mat(iBitmap.getheight(), iBitmap.getwidth(), CV_8UC3, iBitmap.getpixdata());
        cvtColor(frame, frame, COLOR_RGB2BGR);
        outputVideo.write(frame);
        return NO_ERR;
    }
    beep();
    printf("Open video file first.\n");
#else
    beep();
    printf("Command requires a more complete opencv library -- available with homebrew.\n");
    
#endif
    return FILE_ERR;
}

int vidOpenFile_q(int n,char* args){
#ifdef HOMEBREW
    using namespace cv;
    int frames_per_second=15;
    char filename[CHPERLN];

    int narg = sscanf(args,"%d %s",&frames_per_second,filename);
    if(narg !=2){
        beep();
        printf("Two arguments needed: framesPerSecond filename\n");
        return CMND_ERR;
    }
    if(videoOpened){
        beep();
        printf("A video file is already open.\n");
        return CMND_ERR;
    }

    //QImage theImage = wPointer->getVideoFrame();
    //frame = Mat(iBitmap.getheight(), iBitmap.getwidth(), CV_8UC3, iBitmap.getpixdata());
    frame_size= cv::Size(iBitmap.getwidth(), iBitmap.getheight());

    //qDebug()<<theImage.bytesPerLine()<<" "<<theImage.height()<<endl;

    outputVideo = VideoWriter(fullname(filename,SAVE_DATA_NO_SUFFIX), VideoWriter::fourcc('M', 'J', 'P', 'G'),
                                frames_per_second, frame_size, true);

    if(outputVideo.isOpened()){
        //outputVideo.write(frame);
        videoOpened=1;
        return NO_ERR;
    } else {
        beep();
        printf("Could not open VideoWriter.\n");
    }

#else
    beep();
    printf("Command requires a more complete opencv library -- available with homebrew.\n");
    
#endif
    return FILE_ERR;
}

int vidCloseFile_q(int n,char* args){
#ifdef HOMEBREW
    using namespace cv;
    if(videoOpened){
        outputVideo.release();
        videoOpened=0;
        return NO_ERR;
    }
    beep();
    printf("No open video file.\n");
#else
    beep();
    printf("Command requires a more complete opencv library -- available with homebrew.\n");
    
#endif
    return FILE_ERR;
}


/*
CVHOUGHCIRCLES [cannyThreshold accumulatorThreshold maxRadius]
 Works on monochrome images. Default values are 30 10 20 for cannyThreshold accumulatorThreshold maxRadius. Map the monochrome image to 0-255 first.
 
*/

std::vector<cv::Vec3f> circles;

int cvHoughCircles_q(int n,char* args){
    using namespace cv;
    
    unsigned char* bits= new unsigned char[iBuffer.height()* iBuffer.width()];
    unsigned char* byteptr=bits;
    DATAWORD* dataPtr;
    int cannyThreshold=30, accumulatorThreshold=10,maxRadius=20;
    dataPtr=iBuffer.getImageData();
    
    if(!circles.empty()) circles.erase(circles.begin(), circles.end());
    
    int narg = sscanf(args,"%d %d %d",&cannyThreshold, &accumulatorThreshold,&maxRadius);
    
    // need checking for bounds of current image, make sure it is monochrome
    
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *byteptr++ = *dataPtr++;
    }
    
    frame=Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits);
    
    HoughCircles(frame, circles, HOUGH_GRADIENT, 1,
                frame.rows/256,  // change this value to detect circles with different distances to each other
                 cannyThreshold, accumulatorThreshold, 1, maxRadius // change the last two parameters
                                                                    // (min_radius & max_radius) to detect larger circles
    );
    for( size_t i = 0; i < circles.size(); i++ ){
        Vec3i c = circles[i];
        cv::Point center = cv::Point(c[0], c[1]);
        // circle center
        circle( frame, center, 1, 100, 1, LINE_AA);
        // circle outline
        int radius = c[2];
        circle( frame, center, radius, 255, 1, LINE_AA);
    }
    
    printf("%d circles processed.\n",circles.size());
    
    byteptr=bits;
    dataPtr=iBuffer.getImageData();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *dataPtr++ = *byteptr++;
    }
    delete[] bits;
    iBuffer.getmaxx(printMax);
    update_UI();
    return NO_ERR;

}

/*
FILLCIRCLES [extraRadiusAll extraRadiusEdge excludeRadius]
 Tries to correct coma. Using the circles found with the CVHOUGHCIRCLES command, this finds the intensity within each circle and then redistributes that intesity into a Gaussian distribution centered on the circle. extraRadiusAll adds a percentage radius to each circle (e.g., 0.1 makes each circle's radius 10% larger); extraRadiusEdge adds an increasing percentage radius to circles depending on how far the circle is from the image center; excludeRadius excludes circles within the specified radius of the image center.
 
*/


int fillCircles_q(int n,char* args){
    if(circles.empty()) {
        beep();
        printf("No circles have been found -- use CVHOUGHCIRCLES first");
        return CMND_ERR;
    }
    
    
    
    float extraRadiusAll=0., extraRadiusEdge=0.2,excludeRadius=.2;
    int width = iBuffer.width(), height = iBuffer.height(),j,k,m;
    float maxImageDimension = width;
    float *mask,norm;
    DATAWORD sum;
    
    sscanf(args,"%f %f %f",&extraRadiusAll, &extraRadiusEdge, &excludeRadius);
    
    if(height > width) maxImageDimension = height;
    
    float distanceFromCenter;
    for( size_t i = 0; i < circles.size(); i++ ){
        cv::Vec3i cInt;
        cv::Vec3f c = circles[i];
        distanceFromCenter = sqrt(pow(c[0]-width/2,2)+pow(c[1]-height/2,2));
        if(distanceFromCenter/maxImageDimension < excludeRadius) continue;
        // use this radius
        c[2]=c[2]*(1.+extraRadiusAll)*(1.+distanceFromCenter/maxImageDimension*extraRadiusEdge);
        for(j=0; j<3; j++) cInt[j]=round(c[j]);
        
        
        // get a (now gaussian) mask for intensity weighting
        mask = (float*) malloc(pow(cInt[2]*2+1,2) * sizeof(float));
        norm = 0;
        m=0;
        float sigx = c[2]/2.;
        for(k=-cInt[2]; k<=cInt[2]; k++) {
            for(j=-cInt[2]; j<=cInt[2]; j++) {
                //m=(j + cInt[2])*(cInt[2]*2+1) + (k + cInt[2]);
                mask[m]=exp(-(k*k/(sigx*sigx)+j*j/(sigx*sigx))/2.);
                norm += mask[m++];
            }
        }
        // get the intensity inside the circle for each color
        for(int color=0; color < iBuffer.isColor()*2+1; color++){
            sum=0.;
            n=0;
            for( j=cInt[0]-cInt[2]; j<=cInt[0]+cInt[2]; j++) {      // column
                for( k=cInt[1]-cInt[2]; k<=cInt[1]+cInt[2]; k++) {  // row
                    if( (j-cInt[0])*(j-cInt[0]) + (k-cInt[1])*(k-cInt[1]) <= cInt[2]*cInt[2]) {
                        sum += iBuffer.getpix(k+color*height,j);
                        n++;
                    }
                }
            }
            // set the intensity inside the circle
            m=0;
            for( j=cInt[0]-cInt[2]; j<=cInt[0]+cInt[2]; j++) {      // column
                for( k=cInt[1]-cInt[2]; k<=cInt[1]+cInt[2]; k++) {  // row
                    if( (j-cInt[0])*(j-cInt[0]) + (k-cInt[1])*(k-cInt[1]) <= cInt[2]*cInt[2]) {
                        //m=(j - dys)*(dx - dxs) + (i - dxs);
                        m = (j-cInt[0]+cInt[2])+(k-cInt[1]+cInt[2])*(cInt[2]*2+1);
                        iBuffer.setpix(k+color*height,j,sum*mask[m]/norm+iBuffer.getpix(k+color*height,j));
                    }
                }
            }
        }
        free(mask);
    }
    return NO_ERR;
}

/*
CVALIGN tempImageName [maxIterations terminationEpsilon warpMode floorValue]
 Align the specified temporary image with the one in the current buffer. The default values are maxIterations=1000 terminationEpsilon=1E-6  warpMode=0 (Euclidean matching; warpMode!=0 uses Homographic matching). If the optional floorValue is specified, the images used for finding the mapping will have values < floorValue set to floorValue and the new minimum set to zero.
 
*/
int cvAlignOriginal_q(int n,char* args){
    
    using namespace cv;
    
    char tempImageName[128];
    DATAWORD* dataPtr = iBuffer.getImageData();
    // Specify the number of iterations.
    int number_of_iterations = 1000;
    // Specify the threshold of the increment
    // in the correlation coefficient between two iterations
    double termination_eps = 1e-6;
    // Define the motion model
    int warp_mode = MOTION_EUCLIDEAN;
    int mode=0;
    DATAWORD floorValue;
    extern Variable user_variables[];
    extern Image  iTempImages[];
    
    int nargs=sscanf(args,"%s %d %lf %d %f",tempImageName, &number_of_iterations, &termination_eps, &mode,&floorValue);
    if(nargs < 1){
        beep();
        printf("Must specify temp image.\n");
        return CMND_ERR;
    }

    // is tempImage valid?
    n = temp_image_index(tempImageName,0);
    if(n >=0){
        if( iTempImages[n].isEmpty()){
            beep();
            printf("Temporary image is not defined.\n");
            return MEM_ERR;
        }
    } else{
        beep();
        printf("Temporary image is not valid.\n");
        return MEM_ERR;
    }
    // checking for images the same size
    
    if(iBuffer != iTempImages[n]){
        beep();
        printf("Images are not the same size.\n");
        return MEM_ERR;
    }
    
    if(mode){
        warp_mode = MOTION_HOMOGRAPHY;
        printf("Align %s to the current image with Max Iterations: %d, Epsilon: %g, using Homographic Match.\n",
               tempImageName,number_of_iterations,termination_eps);

    } else {
        warp_mode = MOTION_EUCLIDEAN;
        printf("Align %s to the current image with Max Iterations: %d, Epsilon: %g, using Euclidean Match.\n",
               tempImageName,number_of_iterations,termination_eps);

    }
    
    // need isColor case
    bool colorImage=false;
    if(iBuffer.isColor()){
        colorImage=true;
        rgb2grey_c(0, nil);     // iBuffer is now greyscale
    }
    // image1
    unsigned char* bits= new unsigned char[iBuffer.height()* iBuffer.width()];
    unsigned char* byteptr=bits;
    
    DATAWORD* values = iBuffer.getvalues();
    DATAWORD* resultValues = iBuffer.getvalues();
    DATAWORD scale = 255./(values[MAX]-values[MIN]);
    DATAWORD minval=values[MIN];
    if(nargs == 5){
        scale = 255./(values[MAX]-floorValue);
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image1 (iBuffer) to 8 bit and convert to uint8
            if(*dataPtr < floorValue) *dataPtr = floorValue;
            *byteptr++ = ((*dataPtr++)-floorValue)*scale;
        }
    } else {
        floorValue=minval;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image1 (iBuffer) to 8 bit and convert to uint8
            *byteptr++ = ((*dataPtr++)-floorValue)*scale;
        }
    }
    free(values);

    Mat im1 = Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits);    // this 8-bit version of image1 will be used for alignment

    // image2
    Image original;
    original<<iTempImages[n];
    
    unsigned char* bits2= new unsigned char[iBuffer.height()* iBuffer.width()];
    byteptr = bits2;
    
    if(colorImage){
        iBuffer.free();             // copy the temp image to iBuffer and make monochrome
        iBuffer<<iTempImages[n];
        rgb2grey_c(0, nil);
        dataPtr = iBuffer.getImageData();
        values = iBuffer.getvalues();
    } else{
        dataPtr = iTempImages[n].getImageData();
        values = iTempImages[n].getvalues();
    }
    scale = 255./(values[MAX]-values[MIN]);
    minval=values[MIN];
    if(nargs == 5){
        scale = 255./(values[MAX]-floorValue);
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            if(*dataPtr < floorValue) *dataPtr = floorValue;
            *byteptr++ = ((*dataPtr++)-floorValue)*scale;
        }
    } else {
        floorValue=minval;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            *byteptr++ = ((*dataPtr++)-floorValue)*scale;
        }
    }
    free(values);
    
    Mat im2 = Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits2);   // this 8-bit version of image2 will be used for alignment
    DATAWORD* bgrArray;
    Mat im2_original;
    Mat im2_aligned;
    DATAWORD* bluePtr;
    DATAWORD* greenPtr;

    // Set a 2x3 or 3x3 warp matrix depending on the motion model.
    Mat warp_matrix;
    
    // Initialize the matrix to identity
    if ( warp_mode == MOTION_HOMOGRAPHY )
        warp_matrix = Mat::eye(3, 3, CV_32F);
    else
        warp_matrix = Mat::eye(2, 3, CV_32F);
    
    // Define termination criteria
    TermCriteria criteria (TermCriteria::COUNT+TermCriteria::EPS, number_of_iterations, termination_eps);
    
    // Run the ECC algorithm. The results are stored in warp_matrix.
    double cc;
    try {
    cc = findTransformECC(
                     im1,
                     im2,
                     warp_matrix,
                     warp_mode,
                     criteria
                     );
    }
    catch( cv::Exception& e )
    {
        beep();
        const char* err_msg = e.what();
        printf("exception caught: %s\n",err_msg);
        delete[] bits;
        delete[] bits2;
        free(resultValues);
        return CMND_ERR;
    }
    user_variables[0].ivalue = user_variables[0].fvalue = cc;
    user_variables[0].is_float = 1;


    if(cc==-1.){
        beep();
        printf("Error aligning images.\n");
        delete[] bits;
        delete[] bits2;
        free(resultValues);
        return CMND_ERR;
    } else {
        pprintf("Transform returned %g.\n",cc);
    }
    
    if(colorImage){
        // need a BGR array for this
        int size=iBuffer.height()*iBuffer.width();
        bgrArray=new DATAWORD[size*3];
        DATAWORD* bgrPtr=bgrArray;
        dataPtr = original.getImageData();
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<size; i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            *bgrPtr++ = *bluePtr++;
            *bgrPtr++ = *greenPtr++;
            *bgrPtr++ = *dataPtr++;
        }
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3, bgrArray);
    } else {
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1, original.getImageData());
    }
    
    
    // Storage for warped image.
    if(colorImage){
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3);
    } else {
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1);
    }
    if (warp_mode != MOTION_HOMOGRAPHY)
        // Use warpAffine for Translation, Euclidean and Affine
        warpAffine(im2_original, im2_aligned, warp_matrix, im1.size(), INTER_LINEAR + WARP_INVERSE_MAP);
    else
        // Use warpPerspective for Homography
        warpPerspective (im2_original, im2_aligned, warp_matrix, im1.size(),INTER_LINEAR + WARP_INVERSE_MAP);
    
    Image newIm;

    DATAWORD* resultPtr = (DATAWORD*) im2_aligned.ptr();
    if(colorImage){
        newIm=Image(im2_aligned.rows*3,im2_aligned.cols);
        dataPtr = newIm.getImageData();
        delete[] bgrArray;
        int size=iBuffer.height()*iBuffer.width();
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *bluePtr++ = *resultPtr++;
            *greenPtr++ = *resultPtr++;
            *dataPtr++ = *resultPtr++;
        }
        int* specs= newIm.getspecs();
        specs[IS_COLOR]= 1;
        newIm.setspecs(specs);
        free(specs);
    } else {
        newIm=Image(im2_aligned.rows,im2_aligned.cols);
        dataPtr = newIm.getImageData();
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *dataPtr++ = *resultPtr++;
        }
    }
    im1.release();
    im2.release();
    im2_original.release();
    im2_aligned.release();
    
    original.free();
    iBuffer.free();
    iBuffer=newIm;
    iBuffer.setvalues(resultValues);
    free(resultValues);
    iBuffer.getmaxx(printMax);
    delete[] bits;
    delete[] bits2;
    update_UI();
    return NO_ERR;
}


/*
CVALIGN tempImageName [maxIterations terminationEpsilon warpMode floorValue]
 Align the specified temporary image with the one in the current buffer. The default values are maxIterations=1000 terminationEpsilon=1E-6  warpMode=0 (Euclidean matching; warpMode!=0 uses Homographic matching). If the optional floorValue is specified, the images used for finding the mapping will have values < floorValue set to floorValue and the new minimum set to zero.
 
*/
int cvAlign_q(int n,char* args){
    
    using namespace cv;
    
    char tempImageName[128];
    DATAWORD* dataPtr = iBuffer.getImageData();
    // Specify the number of iterations.
    int number_of_iterations = 1000;
    // Specify the threshold of the increment
    // in the correlation coefficient between two iterations
    double termination_eps = 1e-6;
    // Define the motion model
    int warp_mode = MOTION_EUCLIDEAN;
    int mode=0;
    DATAWORD floorValue;
    extern Variable user_variables[];
    extern Image  iTempImages[];
    
    int nargs=sscanf(args,"%s %d %lf %d %f",tempImageName, &number_of_iterations, &termination_eps, &mode,&floorValue);
    if(nargs < 1){
        beep();
        printf("Must specify temp image.\n");
        return CMND_ERR;
    }

    // is tempImage valid?
    n = temp_image_index(tempImageName,0);
    if(n >=0){
        if( iTempImages[n].isEmpty()){
            beep();
            printf("Temporary image is not defined.\n");
            return MEM_ERR;
        }
    } else{
        beep();
        printf("Temporary image is not valid.\n");
        return MEM_ERR;
    }
    // checking for images the same size
    
    if(iBuffer != iTempImages[n]){
        beep();
        printf("Images are not the same size.\n");
        return MEM_ERR;
    }
    
    if(mode){
        warp_mode = MOTION_HOMOGRAPHY;
        printf("Align %s to the current image with Max Iterations: %d, Epsilon: %g, using Homographic Match.\n",
               tempImageName,number_of_iterations,termination_eps);

    } else {
        warp_mode = MOTION_EUCLIDEAN;
        printf("Align %s to the current image with Max Iterations: %d, Epsilon: %g, using Euclidean Match.\n",
               tempImageName,number_of_iterations,termination_eps);

    }
    
    bool colorImage=false;
    if(iBuffer.isColor()){
        colorImage=true;
        rgb2grey_c(0, nil);     // iBuffer is now greyscale
    }
    // ********* image1 ***********
    float* bits= new float[iBuffer.height()* iBuffer.width()];
    float* byteptr=bits;
    
    DATAWORD* values = iBuffer.getvalues();
    DATAWORD* resultValues = iBuffer.getvalues();
    DATAWORD minval=values[MIN];
    if(nargs == 5){
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            if(*dataPtr < floorValue) *dataPtr = floorValue;
            *byteptr++ = ((*dataPtr++)-floorValue);
        }
    } else {
        floorValue=minval;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *byteptr++ = ((*dataPtr++)-floorValue);
        }
    }
    // minimum value is now 0 in all cases
    free(values);
    Mat im1 = Mat(iBuffer.height(), iBuffer.width(), CV_32F, bits);
    
    // ********* image2 ***********
    Image original;
    original<<iTempImages[n];
    float* bits2= new float[iBuffer.height()* iBuffer.width()];
    byteptr = bits2;
    
    if(colorImage){
        iBuffer.free();             // copy the temp image to iBuffer and make monochrome
        iBuffer<<iTempImages[n];
        rgb2grey_c(0, nil);
        dataPtr = iBuffer.getImageData();
        values = iBuffer.getvalues();
    } else{
        dataPtr = iTempImages[n].getImageData();
        values = iTempImages[n].getvalues();
    }
    minval=values[MIN];
    if(nargs == 5){
        //scale = 255./(values[MAX]-floorValue);
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            if(*dataPtr < floorValue) *dataPtr = floorValue;
            *byteptr++ = ((*dataPtr++)-floorValue);
        }
    } else {
        floorValue=minval;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            *byteptr++ = ((*dataPtr++)-floorValue);
        }
    }
    free(values);
    Mat im2 = Mat(iBuffer.height(), iBuffer.width(), CV_32F, bits2);
    
    DATAWORD* bgrArray;
    Mat im2_original;
    Mat im2_aligned;
    DATAWORD* bluePtr;
    DATAWORD* greenPtr;

    // Set a 2x3 or 3x3 warp matrix depending on the motion model.
    Mat warp_matrix;
    
    // Initialize the matrix to identity
    if ( warp_mode == MOTION_HOMOGRAPHY )
        warp_matrix = Mat::eye(3, 3, CV_32F);
    else
        warp_matrix = Mat::eye(2, 3, CV_32F);
    
    // Define termination criteria
    TermCriteria criteria (TermCriteria::COUNT+TermCriteria::EPS, number_of_iterations, termination_eps);
    
    // Run the ECC algorithm. The results are stored in warp_matrix.
    double cc;
    try {
    cc = findTransformECC(
                     im1,
                     im2,
                     warp_matrix,
                     warp_mode,
                     criteria
                     );
    }
    catch( cv::Exception& e )
    {
        beep();
        const char* err_msg = e.what();
        printf("exception caught: %s\n",err_msg);
        delete[] bits;
        delete[] bits2;
        free(resultValues);
        return CMND_ERR;
    }
    user_variables[0].ivalue = user_variables[0].fvalue = cc;
    user_variables[0].is_float = 1;


    if(cc==-1.){
        beep();
        printf("Error aligning images.\n");
        delete[] bits;
        delete[] bits2;
        free(resultValues);
        return CMND_ERR;
    } else {
        pprintf("Transform returned %g.\n",cc);
    }
    

    
    if(colorImage){
        // need a BGR array for this
        int size=iBuffer.height()*iBuffer.width();
        bgrArray=new DATAWORD[size*3];
        DATAWORD* bgrPtr=bgrArray;
        dataPtr = original.getImageData();
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<size; i++){     // map image2 (the temp image) to 8 bit and convert to uint8
            *bgrPtr++ = *bluePtr++;
            *bgrPtr++ = *greenPtr++;
            *bgrPtr++ = *dataPtr++;
        }
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3, bgrArray);
    } else {
        im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1, original.getImageData());
    }
    
    
    // Storage for warped image.
    if(colorImage){
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC3);
    } else {
        im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1);
    }
    if (warp_mode != MOTION_HOMOGRAPHY)
        // Use warpAffine for Translation, Euclidean and Affine
        warpAffine(im2_original, im2_aligned, warp_matrix, im1.size(), INTER_LINEAR + WARP_INVERSE_MAP);
    else
        // Use warpPerspective for Homography
        warpPerspective (im2_original, im2_aligned, warp_matrix, im1.size(),INTER_LINEAR + WARP_INVERSE_MAP);
    
    Image newIm;

    DATAWORD* resultPtr = (DATAWORD*) im2_aligned.ptr();
    if(colorImage){
        newIm=Image(im2_aligned.rows*3,im2_aligned.cols);
        dataPtr = newIm.getImageData();
        delete[] bgrArray;
        int size=iBuffer.height()*iBuffer.width();
        bluePtr=dataPtr+2*size;
        greenPtr=dataPtr+size;
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *bluePtr++ = *resultPtr++;
            *greenPtr++ = *resultPtr++;
            *dataPtr++ = *resultPtr++;
        }
        int* specs= newIm.getspecs();
        specs[IS_COLOR]= 1;
        newIm.setspecs(specs);
        free(specs);
    } else {
        newIm=Image(im2_aligned.rows,im2_aligned.cols);
        dataPtr = newIm.getImageData();
        for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
            *dataPtr++ = *resultPtr++;
        }
    }
    im1.release();
    im2.release();
    im2_original.release();
    im2_aligned.release();
    
    original.free();
    iBuffer.free();
    iBuffer=newIm;
    iBuffer.setvalues(resultValues);
    free(resultValues);
    iBuffer.getmaxx(printMax);
    delete[] bits;
    delete[] bits2;
    update_UI();
    return NO_ERR;
}


/*
CVDENOISE h_luminance h_color [block_size search_window_size ]
 Use the opencv fastNlMeansDenoisingColored function to denoise the current image. The 8-bit data in the current display window is used as input so the result will also be 8-bit data scaled from 0 - 255.
 
*/
int cvDenoise_q(int n,char* args){
    using namespace cv;
    
    int searchSize=21;
    int blockSize=7;
    float hColor=3,hLuminance=3;
    Mat src;
    
    int nargs=sscanf(args,"%f %f %d %d",&hLuminance, &hColor, &blockSize, &searchSize);
    if(nargs < 2){
        beep();
        printf("Must specify hLuminance and hColor.\n");
        return CMND_ERR;
    }
    
    src = Mat(iBitmap.getheight(), iBitmap.getwidth(), CV_8UC3, iBitmap.getpixdata());
    // cvtColor(frame, frame, COLOR_RGB2BGR);   // not needed?
    
    fastNlMeansDenoisingColored(src,src,hLuminance,blockSize,searchSize);

    //[appController updateModifiedDataWindow];
    bitmap2rgb_c(0,(char*)null);
    
    
    return NO_ERR;
}

/*
CVNLDENOISE strength [templateWindowSize searchWindowSize]
 Use the opencv fastNlMeansDenoising function to denoise the current image. The data is converted to 16-bit unsigned integers -- in some cases, consider remapping to 0 65535 to use the full dynamic range (MAP 0 65535).
 
*/


int cvNLDenoise_q(int n,char* args){
    using namespace cv;
    
    int searchSize=21;
    int blockSize=7;
    std::vector<float> hLuminance(1);
    float h;
    Mat src,dst;
    
    int nargs=sscanf(args,"%f %d %d",&h, &blockSize, &searchSize);
    if(nargs < 1){
        beep();
        printf("Must specify strength.\n");
        return CMND_ERR;
    }
    
    hLuminance[0]=h;
    
    unsigned short* bits= new unsigned short[iBuffer.height()* iBuffer.width()];
    unsigned short* shortptr=bits;

    DATAWORD* dataPtr = iBuffer.getImageData();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *shortptr++ = *dataPtr++;
    }

    
    //src = Mat(iBuffer.height(), iBuffer.width(), CV_8U, bits);
    src = Mat(iBuffer.height(), iBuffer.width(), CV_16U, bits);
    //dst = Mat(iBuffer.height(), iBuffer.width(), CV_16U, dstbits);
    
    
    fastNlMeansDenoising(src,src,hLuminance,blockSize,searchSize,NORM_L1);

    shortptr=bits;
    dataPtr = iBuffer.getImageData();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *dataPtr++ = *shortptr++;
    }
    delete[] bits;
    update_UI();

    return NO_ERR;
}

// written by Bard

void denoiseMonochromeImage(unsigned short *imageData, int nRows, int nColumns, double denoisingStrength) {
  // Convert the image data to an OpenCV Mat object.
  cv::Mat image(nRows, nColumns, CV_16U, imageData);

  // Apply denoising.
  cv::fastNlMeansDenoising(image, image, denoisingStrength);

  // Convert the image back to a 16-bit array.
  for (int i = 0; i < nRows; i++) {
    for (int j = 0; j < nColumns; j++) {
      imageData[i * nColumns + j] = image.at<unsigned short>(i, j);
    }
  }
}

#endif
  
