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


int cvHoughCircles_q(int n,char* args){
    using namespace cv;
    
    unsigned char* bits= new unsigned char[iBuffer.height()* iBuffer.width()];
    unsigned char* byteptr=bits;
    DATAWORD* dataptr;
    int cannyThreshold=30, accumulatorThreshold=10,maxRadius=20;
    dataptr=iBuffer.getImageData();
    
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
        *byteptr++ = *dataptr++;
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
    dataptr=iBuffer.getImageData();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *dataptr++ = *byteptr++;
    }
    delete[] bits;
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;

}

int cvAlign_q(int n,char* args){
    
    using namespace cv;
    
    unsigned char* bits= new unsigned char[iBuffer.height()* iBuffer.width()];
    unsigned char* byteptr=bits;
    char tempImageName[128];
    DATAWORD* dataptr = iBuffer.getImageData();
    // Specify the number of iterations.
    int number_of_iterations = 5000;
    // Specify the threshold of the increment
    // in the correlation coefficient between two iterations
    double termination_eps = 1e-10;
    
    extern Image  iTempImages[];
    
    sscanf(args,"%s %i %lf",tempImageName, &number_of_iterations, &termination_eps);
        
    // need checking for bounds of current image, make sure it is monochrome
    
    n = temp_image_index(tempImageName,0);
    if(n >=0){
        if( iTempImages[n].isEmpty()){
            beep();
            printf("Temporary image is not defined.\n");
            return MEM_ERR;
        }
    } else return MEM_ERR;
    // checking for images the same size
    
    if(iBuffer != iTempImages[n]){
        beep();
        printf("Images are not the same size.\n");
        return MEM_ERR;
    }
    
    Image original;
    original<<iTempImages[n];

    
    // need checking for bounds of temp image, make sure it is monochrome
    
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *byteptr++ = *dataptr++;
    }
    Mat im1 = Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits);

    unsigned char* bits2= new unsigned char[iBuffer.height()* iBuffer.width()];
    dataptr = iTempImages[n].getImageData();
    byteptr = bits2;
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *byteptr++ = *dataptr++;
    }

    Mat im2 = Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits2);
    Mat im2_original = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1, original.getImageData());

    // Define the motion model
    //const int warp_mode = MOTION_EUCLIDEAN;
    const int warp_mode = MOTION_HOMOGRAPHY;
    
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
    findTransformECC(
                     im1,
                     im2,
                     warp_matrix,
                     warp_mode,
                     criteria
                     );
    
    // Storage for warped image.
    Mat im2_aligned = Mat(iBuffer.height(), iBuffer.width(), CV_32FC1);
    
    if (warp_mode != MOTION_HOMOGRAPHY)
        // Use warpAffine for Translation, Euclidean and Affine
        warpAffine(im2, im2_aligned, warp_matrix, im1.size(), INTER_LINEAR + WARP_INVERSE_MAP);
    else
        // Use warpPerspective for Homography
        warpPerspective (im2_original, im2_aligned, warp_matrix, im1.size(),INTER_LINEAR + WARP_INVERSE_MAP);
    
    Image newIm(im2_aligned.rows,im2_aligned.cols);
    if(newIm.err()){
        return newIm.err();
    }
    dataptr = newIm.getImageData();
    DATAWORD* resultptr = (DATAWORD*) im2_aligned.ptr();
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *dataptr++ = *resultptr++;
    }

    
    iBuffer.free();
    iBuffer=newIm;
    iBuffer.getmaxx(PRINT_RESULT);
    delete[] bits;
    update_UI();
    return NO_ERR;
}

#endif
