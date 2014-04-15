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
#define SBIG

// end of camera selection section

// select other hardware here

#define LJU3
#define SERIAL_PORT

// end of select other hardware section

//------------------------------------------------------------

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

#ifdef LJU3
int connectU3(void);
#endif

#endif