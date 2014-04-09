//
//  cameraSelector.h
//  oma2
//
//  Created by Marshall B. Long on 3/27/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifndef oma2_cameraSelector_h
#define oma2_cameraSelector_h

// select cameras here

#define GIGE_
#define SERIAL_PORT
#define SBIG

// end of camera selection section


#ifdef GIGE_
// GigE definitions
int gige(int, char*);
// end of GigE definitions
#endif

#ifdef SERIAL_PORT
int serial(int, char*);
int serclo(int, char*);
int open_serial_port(char* dev_name);
#endif


#endif
