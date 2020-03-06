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
*/ 


program DtlSkid_communication

/*
# Variables and Constants
*/
int PLC_CODE;
assign PLC_CODE to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg";
monitor PLC_CODE;

int EPICS_CODE;
assign EPICS_CODE to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg";
monitor EPICS_CODE;


ss communication_management {

/* state INITIALIZATION	*/
	state initialization {
		/* Condition: PLC_CODE = 0xFF22 */
		when (PLC_CODE = -222) { 
			printf("State 0xFF22 --> TEST 1");
		} state reset
	}


	state reset {
		/* Condition: PLC_CODE = 0xFF33 */
		when (PLC_CODE = -205) {
			printf("State 0xFF33 --> TEST 2");
		} state initialization
	}

}


