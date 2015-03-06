//
//  serial.mm
//  oma2
//
//  Created by Marshall B. Long on 3/28/14.
//  Copyright (c) 2014 Yale University. All rights reserved.
//


#ifdef SERIAL_PORT

#include "oma2.h"
#include <unistd.h>

#define beep cbeep
#define printf cprintf

void beep();
int printf(const char* format, ...);

//#include "UI.h"


// use unix terminal control routies
#include <termios.h> /* POSIX terminal control definitions */

int serial_fd; /* File descriptor for the port */
struct termios serial_options;
int serial_inited = 0;

int open_serial_port(char* args){
    char dev[256];
    int time=0,baud=9600;
    sscanf(args, "%s %d %d",dev,&baud,&time);
    
    serial_fd = open(dev, O_RDWR | O_NOCTTY | O_NDELAY);
    //serial_fd = open(dev_name, O_RDWR | O_NOCTTY );
    if (serial_fd == -1) {
		return -1;
    }else{
		//fcntl(serial_fd, F_SETFL, 0);
		//fcntl(serial_fd, F_SETFL, FNDELAY);		// return at once from a read, even if there are no characters ready
        fcntl(serial_fd, F_SETFL);
    }
    
    //Get the current options for the port...
    tcgetattr(serial_fd, &serial_options);
    
    // Set the baud
    //cfsetispeed(&serial_options, B9600);
    //cfsetospeed(&serial_options, B9600);
    cfsetispeed(&serial_options, baud);
    cfsetospeed(&serial_options, baud);
    
    // Enable the receiver and set local mode...
    
    serial_options.c_cflag |= (CLOCAL | CREAD);
    
	serial_options.c_cflag &= ~CSIZE; /* Mask the character size bits */
    serial_options.c_cflag |= CS8;    /* Select 8 data bits */
	serial_options.c_cflag &= ~PARENB;
	serial_options.c_cflag &= ~CSTOPB;
	serial_options.c_cflag &= ~CSIZE;
	serial_options.c_cflag |= CS8;
    
    serial_options.c_cc[VTIME]    = time;     // inter-character timer unused -- this is 0.1 seconds
    serial_options.c_cc[VMIN]     = 0;     // blocking -- will return if no character in VTIME*.1d seconds
    
    
    
    //options.c_cflag &= ~CNEW_RTSCTS;
	
    // Set the new options for the port...
    tcsetattr(serial_fd, TCSANOW, &serial_options);
    int err = tcgetattr(serial_fd, &serial_options);
    if(err==0){
        printf("Opened port %s with baud rate %d and read timeout %.1f seconds\n",dev,baud,time*.1);
    } else {
        printf("Opened port %s; options may not be set properly\n");
    }
	return 0;
}

int serclo(int n, char* args)
{
	if(serial_inited == 0) {
		beep();
		printf("Serial port not initialized.\n");
		return -1;
	} else {
		close(serial_fd);
		serial_inited = 0;
		return 0;
	}
    
    
}


int serial(int n, char* args)
{
	long length,i;
    
    //extern char cmnd[];
	char buffer[ESTRING_LENGTH];
	extern Variable user_variables[];
	
	if(serial_inited == 0) {
        if(open_serial_port(args) != 0){
			beep();
            printf("Can't open serial port specified by %s.\n",args);
			return -1;
		} else {
			serial_inited = 1;
			return 0;
		}
	}
    length = strlen(args);
	if( length == 0 ) {
		beep();
		printf("Nothing sent\n");
		return -1;
	}
    args[length] = 13;	// add a <CR> (=13)
	length++;
    write(serial_fd, args, length);
    
	//echo any reply
	length = read(serial_fd, buffer, ESTRING_LENGTH-1);
	
    for(i = read(serial_fd, &buffer[length], ESTRING_LENGTH-1-length); i+length < ESTRING_LENGTH-1 && i > 0; length +=i) {
        i = read(serial_fd, &buffer[length+i], ESTRING_LENGTH-1-length-i);
        //beep();
    }
    if (length > 0) {
        for(i=0;i<length;i++)buffer[i] &= 127;
        buffer[length] = 0;
        printf("%ld characters returned:\n",length);
        printf("%s\n",buffer);
        strcpy(&user_variables[0].estring[0],buffer);
        user_variables[0].is_float = -1;
    }

    //printf("sent %d characters -%s-\n",length,args);
	return 0;
}



#endif

