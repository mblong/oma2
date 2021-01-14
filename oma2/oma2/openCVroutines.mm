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
    for(int i=0; i<iBuffer.height()* iBuffer.width(); i++){
        *byteptr++ = *dataptr++;
    }
    
    frame=Mat(iBuffer.height(), iBuffer.width(), CV_8UC1, bits);
    std::vector<Vec3f> circles;
    HoughCircles(frame, circles, HOUGH_GRADIENT, 1,
                frame.rows/256,  // change this value to detect circles with different distances to each other
                30, 10, 1, 30 // change the last two parameters
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
    iBuffer.getmaxx(PRINT_RESULT);
    update_UI();
    return NO_ERR;

}


#endif
