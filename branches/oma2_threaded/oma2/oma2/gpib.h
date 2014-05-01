//
//  gpib.h
//  oma2
//
//  Created by Marshall Long on 5/1/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//

#ifndef oma2_gpib_h
#define oma2_gpib_h

#define INIT		0
#define RUN			1
#define INFO		2
#define SEND		3
#define TRANS		4
#define BYE			5
#define FLUSH		6
/*#define TAKE		7 */
#define RECEIVE 	8
#define ASK			9
#define FORCE_INIT	10

#define PHOTOMETRICS_CC200		0
#define PRINCETON_INSTRUMENTS_1	1
#define STAR_1					2
#define OSCOPE					3

#define HEADERLENGTH 80

int omaio(int code,int index, char* string);
void waitreply(void);

#endif
