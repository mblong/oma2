#include "oma2.h"
#include "UI.h"


char reply[256];

int null(int,char*);
int plus(int,char*);
int comdec(char*);

int null(int i,char* c){
    return 0;
};
int plus(int i,char* c){
    sprintf(reply,"arg is: %d\n",i);
    send_reply;
    return 1;
}


ComDef   commands[] =    {
    {{"               "},	null},			
    {{"+              "},	plus},		
    {{{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}},0}};


int comdec(char* cmnd){
    int     (*fnc)(int,char*);
    int     c,i=0,cp=0,clst=0; 
    int     chindx = 0;     /* index of first character after command */
    int     sign = 1;       /* sign of integer argument */
    int     ivalue = 0;     /* integer value */
    ComDef  *clist_ptr;

    
    clist_ptr = commands;
    
    // while not end of command ... 
    
    while ( cmnd[i] != EOL  && cmnd[i] != ' ' && cmnd[i]!= ';' && cmnd[i]!= '\n'){
        if ( toupper(cmnd[i]) !=  clist_ptr[cp].text.name[i] ) {
            cp++;           /* next command */
            i = 0;
            if ( clist_ptr[cp].text.name[i] == EOL ){
                /*
                 if( clst == 0 ) {
                 clst = 1;
                 clist_ptr = my_commands;
                 cp = 0;
                 } else {
                 nosuch();
                 */ 
                sprintf(reply,"No such command: %s",cmnd);
                send_reply;
                return -1;
                //}
            }
        } else {
            i++;
        }
    }
    if( cmnd[i]== '\n') cmnd[i]=0;
    if (clst == 0 )
        fnc =  commands[cp].fnc;
    //else
    //    fnc = my_commands[cp].fnc;
    
    // next check for an integer argument
    
    if (cmnd[i] != EOL && cmnd[i] != ';') {
        chindx = ++i; // save a pointer to the first character after command 
        while ( cmnd[i] != EOL && cmnd[i] != ';' && cmnd[i] != ' ') {
            c = cmnd[i++];
            if (c == '+' )
                sign *= 1;
            if (c == '-' )
                sign *= -1;
            if (c >= '0' && c <= '9')
                ivalue = 10 * ivalue + c - '0';
        }
    }
    ivalue *= sign;
    //      printf("%d\n%d\n",ivalue,chindx);       
    
    // Now Execute the Appropriate Command -- unless this is in an IF whose condition is not met
    
    //if(if_condition_met ||fnc == endifcmnd || fnc == ifcmnd)
    int error_return = (*fnc)(ivalue,chindx+cmnd);
    
    
    return error_return;
}

