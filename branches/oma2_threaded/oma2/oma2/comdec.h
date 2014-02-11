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

#ifdef MacOSX_UI
#import "CommandView.h"
#endif



// function prototypes for routines in comdec.cpp

int fill_in_command(char* dest,char* source,int val);
int do_assignment(char*);
int get_variable_index(char* name, int def_flag);
int is_variable_char(char ch);
Expression_Element evaluate_string(char* ex_string);
Expression_Element evaluate(int start, int end);
int vprint(int index);
void clear_macro_to_end();
int stopmacro();

// function prototypes for commands in comdec.cpp
int display(int, char*);
int erase(int, char*);
int endifcmnd(int, char*);
int execut(int, char*);
int help(int n, char* args);
int ifcmnd(int, char*);
int lmacro(int, char*);
int loop(int, char*);
int loopend(int, char*);
int loopbreak(int, char*);
int macro(int, char*);
int null(int,char*);
int rmacro(int, char*);
int variab(int, char*);
int vfloat(int, char*);
int vint(int, char*);
int getsettings(int,char*);
int savsettings(int,char*);
int defmac(int,char*);
int dmnmx(int,char*);
int labelData(int, char*);
int stopOnError(int, char*);
int imp_pause(int, char*);

int gettextline(int, char*);
int keylimit(int n);

#endif
