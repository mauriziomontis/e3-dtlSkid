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
#
# developed by Maurizio Montis | INFN-LNL
# mail: maurizio.montis@lnl.infn.it
*/ 


program DtlSkid_communication

/*
# Libraries
*/
%%#include <stdio.h>

/*
# Variables and Constants
*/
int PLC_CODE;
assign PLC_CODE to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg";
monitor PLC_CODE;

int EPICS_CODE;
assign EPICS_CODE to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg";
monitor EPICS_CODE;

string State_Machine;
assign State_Machine to "CWM-CWS04:Ctrl-Intf-001:StateMachine";


/*
# Debug Mode: 
*/

double DEBUG=1;



/*
# State Machine Definition
*/

ss communication_management {

/* state INITIALIZATION	*/
	state initialization {
		/* Verify PV availability */
		when (pvConnectCount()==pvAssignCount()) { 
			printf("State Machine Initialization Complete\n\t PVs connected:\n\t - EPICS Communication: %s\n\t - PLC Communication: %s\n\n", EPICS_CODE, PLC_CODE);
			State_Machine="State Machine Initialization";
			pvPut(State_Machine);
		} state iocCommSetup
	}

/* state iocCommSetup */ 
	state iocCommSetup {
		/* Set EPICS CODE to 0xDD22 [-8909] when PLC CODE is 0xFF22 [-222] */
		when ( (PLC_CODE == -222) ) {
			EPICS_CODE=-8926;
			pvPut(EPICS_CODE);
			printf("Start Data Synchronization: PLC --> EPICS\n\t Actual values: EPICS_CODE: %x\t PLC_CODE: %x\n\n", EPICS_CODE, PLC_CODE);
			State_Machine="Synchronization Mode";
			pvPut(State_Machine);
		} state dataSync
	}

/* state dataSync */
        state dataSync {
                when(PLC_CODE == -239 || PLC_CODE == -256 ) {
			/* Arbitrary set to 0xDD00 [-8960] */
			EPICS_CODE=-8960;
			pvPut(EPICS_CODE);
                        printf("Reset Synchronization due to Connection Lost\n\t Actual values: EPICS_CODE: %x\t PLC_CODE: %x\n\n", EPICS_CODE, PLC_CODE);
			State_Machine="Reset Synchronization";
			pvPut(State_Machine);
                } state iocCommSetup
		
		when(PLC_CODE == -205 && (delay(2))) {
			EPICS_CODE=-8909;
                        pvPut(EPICS_CODE);
                        printf("Remote Control Enabled: EPICS <--> PLC Communicatio Estamblished\n\t Actual values: EPICS_CODE: %x\t PLC_CODE: %x\n\n", EPICS_CODE, PLC_CODE);
                        State_Machine="Remote Control Enabled";
                        pvPut(State_Machine);
		} state remoteControl
	}

/* state remoteControl*/ 
	state remoteControl {
		when(PLC_CODE == -256 || PLC_CODE == -239 || PLC_CODE == 222) {
			/* Arbitrary set to 0xDD00 [-8960] */
			EPICS_CODE=-8960;
                        pvPut(EPICS_CODE);
                        printf("Reset Synchronization due to Connection Lost\n\t Actual values: EPICS_CODE: %x\t PLC_CODE: %x\n\n", EPICS_CODE, PLC_CODE);
                        State_Machine="Reset Synchronization";
                        pvPut(State_Machine);		
		} state iocCommSetup
	}


}


