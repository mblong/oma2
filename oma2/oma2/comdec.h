//
//  comdec.h
//  oma2
//
//  Created by Marshall Long on 3/26/12.
//  Copyright (c) 2012 Yale University. All rights reserved.
//

#ifndef oma2_comdec_h
#define oma2_comdec_h

#include "oma2.h"
#include "UI.h"
#include "commands_1.h"
#include "gluedCommands.h"
#include "ImageBitmap.h"
#include "dofft.h"

#include <string>
#include <ctime>


#ifdef MacOSX_UI
#import "CommandView.h"
#endif

#ifdef ANDOR_
int andor(int, char*);
#endif

#ifdef SBIG
int sbig(int,char*);
#endif

#ifdef LJU3
int ain(int,char*);
int waithi(int,char*);
int dout(int,char*);
int aout(int,char*);
int din(int,char*);
#endif

#ifdef GPHOTO
int capture(int n, char* args);
int camlistsettings(int n, char* args);
int camexpose(int n, char* args);
int camgetsetting(int n, char* args);
int camsetsetting(int n, char* args);
#endif

#ifdef VISA
int synch(int n,char* args);
int conect(int n,char* args);
int run(int n,char* args);
int discon(int n,char* args);
int inform(int n,char* args);
int flush(int n,char* args);
int send(int n,char* args);
int ask(int n,char* args);
int transfer(int n,char* args);
int receiv(int n,char* args);
int gpibdv(int n,char* args);

#endif



// function prototypes for routines in comdec.cpp

int fill_in_command(char* dest,char* source,int val);
int do_assignment(char*);
int get_variable_index(char* name, int def_flag);
int is_variable_char(char ch);
Expression_Element evaluate_string(char* ex_string);
Expression_Element evaluate(int start, int end);
int vprint(int index);
void clear_buffer_to_end(char*);
int stopmacro();
std::string getVariablesString(std::string varString);
std::string getTempImagesString(std::string varString);

// function prototypes for commands in comdec.cpp
int display(int, char*);
int erase(int, char*);
int endifcmnd(int, char*);
int execut(int, char*);
int help(int n, char* args);
int ifcmnd(int, char*);
int ifnotcmnd(int, char*);
int lmacro(int, char*);
int loop(int, char*);
int loopend(int, char*);
int loopbreak(int, char*);
int macro(int, char*);
int null(int,char*);
int rmacro(int, char*);
int variab(int, char*);
int vfloat(int, char*);
int floatAuto(int, char*);
int vint(int, char*);
int varClear(int, char*);
int getsettings(int,char*);
int savsettings(int,char*);
int defmac(int,char*);
int logg(int,char*);
int dmnmx(int,char*);
int labelData(int, char*);
int stopOnError(int, char*);
int imp_pause(int, char*);

int gettextline(int, char*);
int keylimit(int n);

float aveInRect();
float rmsInRect();

#endif
