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

// Things for loops in macros
#define NESTDEPTH 20		// Should add checking for overflow; just make big for now
// depth of execute commands
#define EX_NEST_DEPTH 40	// Should add checking for overflow; just make big for now

#define MAX_VAR_LENGTH 32
#define MAX_VAR 200
#define ESTRING_LENGTH 128
#define MBUFLEN 10240     	/* number of bytes in macro buffer */
#define VBUFLEN	1024		/* the storage for variable names in macros */


typedef struct {
	char name[16];
} Cname;

typedef struct {
	Cname text;
	int (*fnc)(int,char*);
} ComDef;

typedef struct {
	char vname[MAX_VAR_LENGTH];
	int ivalue;
	float fvalue;
	int is_float;
	char estring[ESTRING_LENGTH];
} Variable;

typedef struct {
	char op_char;
	int ivalue;
	float fvalue;
	char estring[ESTRING_LENGTH];
} Expression_Element;


// function prototypes for routines in comdec.cpp

int fill_in_command(char* dest,char* source,int val);
int do_assignment(char*);
int get_variable_index(char* name, int def_flag);
int is_variable_char(char ch);
Expression_Element evaluate_string(char* ex_string);
Expression_Element evaluate(int start, int end);
int vprint(int index);

// function prototypes for commands in comdec.cpp
int display_c(int, char*);
int endifcmnd(int, char*);
int execut(int, char*);
int ifcmnd(int, char*);
int loop(int, char*);
int loopend(int, char*);
int loopbreak(int, char*);
int macro(int, char*);
int null(int,char*);
int rmacro(int, char*);
int variab(int, char*);

ComDef   commands[] =    {
    {{"               "},	null},			
    {{"+              "},	plus_c},
    {{"-              "},	minus_c,},
    {{"*              "},	multiply_c},
    {{"/              "},	divide_c,},		
    {{"ADDFILE        "},	addfile_c},
    {{"CROP           "},	croprectangle_c},
    {{"CONCATENATE    "},	concatenatefile_c},
    {{"DISPLAY        "},	display_c},
    {{"DIVFILE        "},	divfile_c},
    {{"EXECUTE        "},	execut},
    {{"GET            "},	getfile_c},
    {{"INVERT         "},	invert_c},
    {{"LOOP           "},	loop},
    {{"LOOBBREAK      "},	loopbreak},
    {{"LOOPEND        "},	loopend},
    {{"MACRO          "},	macro},
    {{"MULFILE        "},	mulfile_c},
    {{"RECTANGLE      "},	rectan_c},
    {{"RGB2RED        "},	rgb2red_c},
    {{"RGB2GREEN      "},	rgb2green_c},
    {{"RGB2BLUE       "},	rgb2blue_c},
    {{"ROTATE         "},	rotate_c},
    {{"SMOOTH         "},	smooth_c},
    {{"SUBFILE        "},	subfile_c},
    {{"VARIABLES      "},	variab},
    {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},0}};


#endif
