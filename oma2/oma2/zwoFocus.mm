#include "oma2.h"
#include "UI.h"
#include "stdio.h"
#include "EAF_focuser.h"
#ifdef _WINDOWS
#include <windows.h>
#else
#include <sys/time.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h> 


#define Sleep(a) usleep((a)*1000)
#endif

bool bRun = true;
bool focuserConnected = false;
int iSelectedID;
int currentPos;
int maxPos;
int steps=100;
int target;
float fTemp;

EAF_INFO EAFInfo;

/*
 void IntHandle(int i)
{
	bRun = false;
}
*/

/* ZFOCUS [cmnd command_args]
    available commands:
    MOVe steps --- increment or decrement current position by the specified number of steps
    GOto targetPosition --- move the the specified target position
    MAX maxPosition --- set the Maximum allowed position
    SET position --- set the current position to the specfied value
    
 */

int  zFocus(int n, char* args)
{
    long i;
    int nargs;
    char dummy[CHPERLN];
    EAF_ERROR_CODE err;
    
    //signal(SIGINT, IntHandle);
    if(!focuserConnected){
        int EAF_count = EAFGetNum();
        if(EAF_count <= 0)
        {
            beep();
            printf("No focuser connected.\n");
            return HARD_ERR;
        }
        else {
            
            EAFGetID(0, &EAFInfo.ID);
            EAFGetProperty(EAFInfo.ID, &EAFInfo);
            printf("Focuser is %s.\n", EAFInfo.Name);
            
            EAFGetID(0, &iSelectedID);
            
            focuserConnected = true;
            if(EAFOpen(iSelectedID) != EAF_SUCCESS)
            {
                beep();
                printf("Focuser open error.\n");
                return HARD_ERR;
            }
        }
        zwoWindow
        EAFGetTemp(iSelectedID, &fTemp);
        printf("Temperature=%g\n", fTemp);
        EAFGetMaxStep(iSelectedID, &maxPos);
        printf("Max position: %d\n", maxPos);
        EAFGetPosition(iSelectedID, &currentPos);
        printf("Current position: %d\n", currentPos);
        printf("Max position allowed: %d\n", EAFInfo.MaxStep);
        if(!focuserConnected) {zwoWindow}
        zwoUpdate
        return NO_ERR;
    }
    for(i=0; i<3; i++) args[i] = toupper(args[i]);
    if( strncmp(args,"MOV",3) == 0){                // MOVe
        EAFGetPosition(iSelectedID, &currentPos);
        sscanf(args,"%s %d",dummy, &steps);
        target = currentPos + steps;
        if(target < 0 || target > maxPos){
            beep();
            printf("Invalid target position.\n");
            return CMND_ERR;
        }
        err = EAFMove(iSelectedID, target);
        if(err == EAF_SUCCESS)
            printf("Moving.");
        bool isMoving = false;
        while(1)
        {
            bool pbHandControl;
            err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
            if(err != EAF_SUCCESS || !isMoving)
                break;
            Sleep(500);
            EAFGetPosition(iSelectedID, &currentPos);
            zwoUpdate
            printf("%d\n",currentPos);
        }
        EAFGetPosition(iSelectedID, &currentPos);
        printf("\nCurrent position: %d\n", currentPos);
        zwoUpdate
        return NO_ERR;
    } else if ( strncmp(args,"GO",2) == 0){         //GOto
        sscanf(args,"%s %d",dummy, &target);
        if(target < 0 || target > maxPos){
            beep();
            printf("Invalid target position.\n");
            return CMND_ERR;
        }
        err = EAFMove(iSelectedID, target);
        if(err == EAF_SUCCESS)
            printf("Moving.");
        bool isMoving = false;
        while(1)
        {
            bool pbHandControl;
            err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
            if(err != EAF_SUCCESS || !isMoving)
                break;
            Sleep(500);
            printf(".");
        }
        EAFGetPosition(iSelectedID, &currentPos);
        printf("\nCurrent position: %d\n", currentPos);
        zwoUpdate
        return NO_ERR;
    } else if ( strncmp(args,"MAX",3) == 0){         //MAX
        int newMax;
        sscanf(args,"%s %d",dummy, &newMax);
        if(focuserSetMaxPosition(newMax)){
            printf("Invalid maximum position setting.\n");
            return CMND_ERR;
        }
        printf("Max position set to %d\n", maxPos);
        zwoUpdate
        return NO_ERR;
    }  else if ( strncmp(args,"SET",3) == 0){         //SET
        sscanf(args,"%s %d",dummy, &target);
        if(focuserResetPosition(target)){
            printf("Invalid position setting.\n");
            return CMND_ERR;
        }
        printf("Current position: %d\n", currentPos);
        zwoUpdate
        return NO_ERR;
    }else {
        
        beep();
        printf("Unknown ZFOCUSER Command.\nValid commands are:\n\tMOVe [steps to move] -- Move by specified number of steps. If specified, the number of steps to move is reset to the given value.\n\tGOto Position -- Moves to specified Position\n\tMAX newMaxPosion -- Resets allowed maximum position\n\tSET newCurrentPosition --  Sets current position to specified value.\n");
        
    }
    
    
    
    
    //EAFClose(iSelectedID);
    return NO_ERR;
}

int focuserMoveSteps(int numSteps){
    EAF_ERROR_CODE err;
    EAFGetPosition(iSelectedID, &currentPos);
    target = currentPos + numSteps;
    if(target < 0 || target > maxPos){
        return CMND_ERR;
    }
    err = EAFMove(iSelectedID, target);
    bool isMoving = false;
    while(1)
    {
        bool pbHandControl;
        err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
        if(err != EAF_SUCCESS || !isMoving)
            break;
        Sleep(500);
    }
    EAFGetPosition(iSelectedID, &currentPos);
    return NO_ERR;
}

int focuserGoto(int target){
    EAF_ERROR_CODE err;
    if(target < 0 || target > maxPos){
        beep();
        return CMND_ERR;
    }
    err = EAFMove(iSelectedID, target);
    bool isMoving = false;
    while(1)
    {
        bool pbHandControl;
        err = EAFIsMoving(iSelectedID, &isMoving, &pbHandControl);
        if(err != EAF_SUCCESS || !isMoving)
            break;
        Sleep(500);
        EAFGetPosition(iSelectedID, &currentPos);
        zwoUpdate
    }
    EAFGetPosition(iSelectedID, &currentPos);
    return NO_ERR;
}

int focuserResetPosition(int target){
    if(target > 0 && target <= maxPos ){
        EAF_ERROR_CODE err = EAFResetPostion(iSelectedID, target);
        EAFGetPosition(iSelectedID, &currentPos);
        return NO_ERR;
    } else {
        beep();
        return CMND_ERR;
    }
}

int focuserSetMaxPosition(int newMax){
    if(newMax < 0 || newMax > EAFInfo.MaxStep){
        beep();
        return CMND_ERR;
    }
    EAF_ERROR_CODE err = EAFSetMaxStep(iSelectedID, newMax);
    EAFGetMaxStep(iSelectedID, &maxPos);
    return NO_ERR;
}
/*
	while(1)
	{
		err = EAFGetProperty(iSelectedID, & EAFInfo);
		if(err != EAF_ERROR_MOVING )
			break;
		Sleep(500);
	} 

	printf("Max step: %d", EAFInfo.MaxStep);

	bool bMoving = false;

	while(1)
	{
		bool pbHandControl;
		err = EAFIsMoving(iSelectedID, &bMoving, &pbHandControl);
		if(err != EAF_SUCCESS || !bMoving)
	    		break;
		Sleep(500);
	} 
	
	//int currentPos;
	EAFGetPosition(iSelectedID, &currentPos);
	printf("\ncurrent position: %d\n", currentPos);

	int targetPos;
	char szInput[16];
	printf("\nPlease input target position, type \'q\' to quit:\n");
	while(1)
	{	
	//	safe_flush(stdin);
		scanf("%s", szInput);

		if(!strcmp(szInput, "q"))
			break;
		targetPos = atoi(szInput);
		printf("\nmove to: %d\n", targetPos);

		if(targetPos < 0)
			continue;

		bRun = true;
		err = EAFMove(iSelectedID, targetPos);
		if(err == EAF_SUCCESS)
			printf("\nMoving..., press CTRL+C to abort\n\n");
		while(1)
		{
			if(!bRun)
			{
				printf("\nMove is aborted\n");
				EAFStop(iSelectedID);
			}
			EAFGetPosition(iSelectedID, &currentPos);			
			printf("current position: %d\n", currentPos);
			
			bool pbHandControl;
			err = EAFIsMoving(iSelectedID, &bMoving, &pbHandControl);
			if(err != EAF_SUCCESS || !bMoving )
					break;
			Sleep(500);
		} 

		printf("\nPlease input target position, type \'q\' to quit:\n");

	}
	EAFClose(iSelectedID);
	printf("main function over\n");
	return 0;
*/







