//
//  cameraSelector.h
//  oma2
//
//  Created by Marshall B. Long on 3/27/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifndef oma2_cameraSelector_h
    #define oma2_cameraSelector_h

    /* Note about external dynamic libraries:

     Must use the install_name_tool to modify dylibs to be relative to where they can be found in oma2cam.app
     They are copied to the included Frameworks folder in the app Contents
     This could be done in a script in a separate build phase, but once it's done it won't have to be done again as long as the dylibs that are part of the project are used.
     
     example of some script commands:
     # this ensures the embedded dynamic libraries are found
     export DYLIB=liblabjackusb.dylib
     install_name_tool -id @executable_path/../Frameworks/$DYLIB $SRCROOT/oma2/$DYLIB
     #install_name_tool -change $SRCROOT/oma2/$DYLIB @executable_path/../Frameworks/$DYLIB "$TARGET_BUILD_DIR/$TARGET_NAME.app/Contents/MacOS/$PRODUCT_NAME"
     
     From the command line:
     1) copy the dylib into the oma source code folder
     2) make the oma source code folder the current directory
     3) make sure the dylib copy has write (and execute?) access:
        chmod a+wx libgsl*
     4) set the name of the dylib
        export DYLIB=libgsl.23.dylib
     5) use install_name_tool:
        install_name_tool -id @executable_path/../Frameworks/$DYLIB $DYLIB
     
     In the project settings:
     6) add the dylib to the Libraries folder
     7) add the dylib file to Frameworks in the appropriate Copy Files part of the Build Phases
     8) there shouldn't be any related -lLIBNAME in the Other Linker Flags settings in the Build Settings
     9) when committing and pushing to the repository, be sure to check the box next to the dylib file name so it gets added
     
    */

    #define OPENCV_ROUTINES

    // select cameras here

    #define GIGE_     //
    #define SBIG
    #define GPHOTO      // requires installing gphoto2 and its libraries: e.g., brew install gphoto2
                        // if this is undefined, remove -lgphoto2 from Build Settings>Linking>Other Linker Flags

    // end of camera selection section

    // select other hardware here

    #define LJU3                //
    #define SERIAL_PORT
    //#define VISA              // no longer supported

    // end of select other hardware section

    //------------------------------------------------------------

    #ifdef GIGE_
        // GigE definitions
        int gige(int, char*);
        // end of GigE definitions
    #endif

    #ifdef SERIAL_PORT
        #ifdef __cplusplus
            extern "C"{
        #endif
        int serial(int, char*);
        int serclo(int, char*);
        int open_serial_port(char* dev_name);
        #ifdef __cplusplus
            }
        #endif
    #endif

    #ifdef LJU3
        #include "u3.h"
        int connectU3(void);
    #endif

#endif
