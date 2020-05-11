/* DTL Skid State Machine - EPICS <-> PLC Communication management
# Control the data exchange between PVs:
# * CWM-CWS04:Ctrl-Intf-001:PLCCommMsg
# * CWM-CWS04:Ctrl-Intf-001:EPICSCommMsg
#
# Code used by DTL Skid PLC application is:
# - PLC side:
# 	* State 0,1: 0xFFFF FFFF FFFF FF00 (-256)
# 	* State 2,3: 0xFFFF FFFF FFFF FF11 (-239)
# 	* State 4:   0xFFFF FFFF FFFF FF22 (-222)
# 	* State 5:   0xFFFF FFFF FFFF FF33 (-205)
# 	* State 6:   0xFFFF FFFF FFFF FF44 (-188)
# - EPICS side:
#       * Condition 1 (_ACK):  0xFFFF FFFF FFFF DD22 (-8926)
#       * Condition 2 (_DONE): 0xFFFF FFFF FFFF DD33 (-8909)
#
# Sync must be done forcing execution of PV: CWM-CWS04:Ctrl-Intf-001:EPICSExecSync
#
# When syncronization is completed and PLC state machine is in State 6, sync is disabled setting PV: CWM-CWS04:Ctrl-Intf-001:EPICSSyncLck (automatic)
#
# developed by Maurizio Montis | INFN-LNL
# mail: maurizio.montis@lnl.infn.it
*/ 


program DtlSkid_communication

/*
# Libraries
*/

%%#include <stdio.h>
%%#include <string.h>

/*
# Variables and Constants
*/
int PLC_CODE;
assign PLC_CODE to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg";
monitor PLC_CODE;

int EPICS_CODE;
assign EPICS_CODE to "CWM-CWS04:Ctrl-Intf-001:EPICSCommMsg";
monitor EPICS_CODE;

int EPICS_FORCE_SYNC;
assign EPICS_FORCE_SYNC to "CWM-CWS04:Ctrl-Intf-001:EPICSExecSync";
monitor EPICS_FORCE_SYNC;

int EPICS_LOCK_SYNC;
assign EPICS_LOCK_SYNC to "CWM-CWS04:Ctrl-Intf-001:EPICSSyncLck";
monitor EPICS_LOCK_SYNC;

//string smStatus;
//assign smStatus to "CWM-CWS04:Ctrl-Intf-001:SMStat";


/* Configurations" */ 
int actual_force_val = 0;
int wait_sync = 120;  		//wait syncronization in seconds
int remote_check_time = 300; //remote state heartbeat in seconds


/* Debug Mode: */
double DEBUG=1;


/*
# State Machine Definition
*/

ss communication_management {

/* state INITIALIZATION	*/
	state initialization {
		entry {
			printf("\n\nPreliminary sync wait time executed due to Application Startup\n\n");
		}
		/* Verify PV availability */
		//when ( (pvConnectCount()==pvAssignCount()) && delay(wait_sync) ) {
		when (pvConnectCount()==pvAssignCount()) { 
			printf("State Machine Initialization Complete\n\t PVs connected:\n\t - EPICS Communication: %x\n\t - PLC Communication: %x\n\n", EPICS_CODE, PLC_CODE);
			//smStatus="State Machine Initialization";
			//pvPut(smStatus);
		} state setSync
	}

/* state SET SYNC */ 
	state setSync {
		/* Execute Epics Synchronization */
		when (PLC_CODE == -222) {
			/* Security check: set EPICS_CODE to an arbitrary value */
			EPICS_CODE=7117;
			pvPut(EPICS_CODE); 
			if (DEBUG == 1) { printf("\n\n[SEQ Message] Set EPICS Communication Code 0x00001BCD [7117]\n"); }
			
			/* Force Syncronization*/
			actual_force_val=pvGet(EPICS_FORCE_SYNC);
			EPICS_FORCE_SYNC=actual_force_val+1;
			pvPut(EPICS_FORCE_SYNC);
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS_FORCE_SYNC to %d\n", EPICS_FORCE_SYNC); }  
		} state syncDone
	}
	
/* state SYNC DONE */ 
	state syncDone {
		when(delay(wait_sync)) {
			/* Set EPICS CODE to 0xDD22 [-8926] */
			EPICS_CODE=-8926;
			pvPut(EPICS_CODE);
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS Communication Code 0xFFFFDD22 [-8926]\n"); }
		} state confirmSync
		
		when( PLC_CODE == -256 ) {
			/* Communication issue */
			/* Security check: set EPICS_CODE to an arbitrary value */
			EPICS_CODE=7227;
			pvPut(EPICS_CODE); 
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS Communication Code 0x00001C3B [7227] during syncronization stage\n"); }
		} state setSync	
		
		//when( PLC_CODE == -239 ) {
		//	/* Communication issue - floating transmission */ 
		//	if (DEBUG == 1) { printf("[SEQ Message] PLC_CODE floating: reset sync check timeout\n"); }
		//} state syncDone	
	}
	
/* state FAST SYNC DONE*/
/* 
	used when PLC_CODE -239 happens in syncDone state
	set EPICS CODE to -8926 with a minor wait_sync timeout 
	[TBC]
*/ 
	
/* state CONFIRM SYNC */ 	
	state confirmSync {
		when(PLC_CODE == -205) {
		/* Set EPICS CODE to 0xDD33 [-8909] */
			EPICS_CODE=-8909;
			pvPut(EPICS_CODE);
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS Communication Code 0xFFFFDD33 [-8909]\n"); }			
		} state remoteControl
			
		when( PLC_CODE == -256 ) {
			/* Communication issue */
			/* Security check: set EPICS_CODE to an arbitrary value */
			EPICS_CODE=7227;
			pvPut(EPICS_CODE); 
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS Communication Code 0x00001C3B [7227] during confirm sync stage\n"); }
		} state setSync	
		
		when( PLC_CODE == -239 ) {
			/* Communication issue - floating transmission */ 
			if (DEBUG == 1) { printf("[SEQ Message] PLC_CODE floating: reset sync check timeout\n"); }
		} state syncDone		
	}

/* state remoteControl*/ 
	state remoteControl {
		
		when( (PLC_CODE == -256) || (PLC_CODE == -239) ) {
			/* Communication issue */
			/* Security check: set EPICS_CODE to an arbitrary value */
			EPICS_CODE=7337;
			pvPut(EPICS_CODE); 
			if (DEBUG == 1) { printf("[SEQ Message] Set EPICS Communication Code 0x00001CA9 [7337] while in remote control stage\n"); }
		} state setSync
		
		when(delay(remote_check_time)) {
			/* Check remote status*/
			if (DEBUG == 1) { printf("[SEQ Message] EPICS<-->PLC Communication in Remote Control\n"); }
		} state remoteControl		
	}

}


