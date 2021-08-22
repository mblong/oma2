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


static cv::VideoWriter outputVideo;
static cv::Mat frame;
static cv::Size frame_size;
static bool videoOpened = 0;

extern ImageBitmap iBitmap;

extern int printMax;

int vidAddFrame_q(int n,char* args){
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
    return FILE_ERR;
}

int vidOpenFile_q(int n,char* args){
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
        return FILE_ERR;
    }
}

int vidCloseFile_q(int n,char* args){
    using namespace cv;
    if(videoOpened){
        outputVideo.release();
        videoOpened=0;
        return NO_ERR;
    }
    beep();
    printf("No open video file.\n");
    return FILE_ERR;

}


/*
CVHOUGHCIRCLES [cannyThreshold accumulatorThreshold maxRadius]
 Works on monochrome images. Default values are 30 10 20 for cannyThreshold accumulatorThreshold maxRadius. Map the monochrome image to 0-255 first.
 
*/

int cvHoughCircles_q(int n,char* args){
    using namespace cv;
    
    unsigned char* bits= new unsigned char[iBuffer.height()* iBuffer.width()];
    unsigned char* byteptr=bits;
    DATAWORD* dataPtr;
    int cannyThreshold=30, accumulatorThreshold=10,maxRadius=20;
    dataPtr=iBuffer.getImageData();
    
    int narg = sscanf(args,"%d %d %d",&cannyThreshold, &accumulatorThreshold,&maxRadius);
    /*
     if(narg !=2){
        beep();
        printf("Two arguments needed: framesPerSecond filename\n");
        return CMND_ERR;
    }
     */
    
    // need checking for bounds of current image, make sure it is monochrome
    
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *byteptr++ = *dataPtr++;
    }
    
    frame=Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits);
    std::vector<Vec3f> circles;
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
        return CMND_ERR;
    }
    user_variables[0].ivalue = user_variables[0].fvalue = cc;
    user_variables[0].is_float = 1;


    if(cc==-1.){
        beep();
        printf("Error aligning images.\n");
        delete[] bits;
        delete[] bits2;
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
    iBuffer.getmaxx(printMax);
    delete[] bits;
    delete[] bits2;
    update_UI();
    return NO_ERR;
}

/*
CVDENOISE h_luminance h_color [search_window_size block_size]
 Use the opencv fastNlMeansDenoisingColored function to denoise the current image. The 8-bit data in the current display window is used as input so the result will also be 8-bit data scaled from 0 - 255.
 
*/
int cvDenoise_q(int n,char* args){
    using namespace cv;
    
    int searchSize=21;
    int blockSize=7;
    float hColor=3,hLuminance=3;
    Mat src;
    
    int nargs=sscanf(args,"%f %f %d %d",&hLuminance, &hColor, &searchSize, &blockSize);
    if(nargs < 2){
        beep();
        printf("Must specify hLuminance and hColor.\n");
        return CMND_ERR;
    }
    
    src = Mat(iBitmap.getheight(), iBitmap.getwidth(), CV_8UC3, iBitmap.getpixdata());
    // cvtColor(frame, frame, COLOR_RGB2BGR);   // not needed?
    
    fastNlMeansDenoisingColored(src,src,hLuminance,hColor,blockSize,searchSize);

    //[appController updateModifiedDataWindow];
    bitmap2rgb_c(0,(char*)null);
    
    
    return NO_ERR;
}


#endif
