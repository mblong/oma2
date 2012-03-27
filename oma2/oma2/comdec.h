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

int null(int i,char* c);


ComDef   commands[] =    {
    {{"               "},	null},			
    {{"+              "},	plus_c},
    {{"-              "},	minus_c,},
    {{"*              "},	multiply_c},
    {{"/              "},	divide_c,},		
    {{"ADDFILE        "},	addfile_c},
    {{"CROP           "},	croprectangle_c},
    {{"CONCATENATE    "},	concatenatefile_c},
    {{"DIVFILE        "},	divfile_c},
    {{"GET            "},	getfile_c},
    {{"INVERT         "},	invert_c},
    {{"MULFILE        "},	mulfile_c},
    {{"RECTANGLE      "},	rectan_c},
    {{"RGB2RED        "},	rgb2red_c},
    {{"RGB2GREEN      "},	rgb2green_c},
    {{"RGB2BLUE       "},	rgb2blue_c},
    {{"ROTATE         "},	rotate_c},
    {{"SMOOTH         "},	smooth_c},
    {{"SUBFILE        "},	subfile_c},
    {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},0}};


#endif
