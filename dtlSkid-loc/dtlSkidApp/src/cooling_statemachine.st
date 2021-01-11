/* DTL Cooling State Machine
# State Machine devoted to control the status and the health of DTL cooling sub-system :
#
# Principal States:
# - Initialization:
# 	* Initialize State Machine when EPICS application starts
# - Self-Check:
#       * Verify HW status (connections, devices health, etc.)
# - Start-Up:
#       * Prepare the sub-system to perform operations
# - Idle:
#       * Machine is in attendance of external ok
# - Ready-for-operation:
#       * Machine prepared for operation
# - Failure:
#       * Machine goes in safe mode because of HW/SW problems
# - Maintenance:
#       * Status where the machine is under maintenance. Useful to indicate possible operation and works on the apparatus
#
#
# developed by Maurizio Montis | INFN-LNL
# mail: maurizio.montis@lnl.infn.it
*/

program cooling_statemachine

/*
# Libraries
*/

%%#include <stdio.h>
%%#include <stdlib.h>
%%#include <string.h>
%%#include <unistd.h>

/*
# Variables and Constants
*/

/* Ok Status */
int Main_OK_Status;
assign Main_OK_Status to "CWM-CWS04:Ctrl-Intf-001:OkStat-RB";
monitor Main_OK_Status;
int T1_OK_Status;
assign T1_OK_Status to "CWM-CWS04:Ctrl-Intf-001:DTL-010Ok-RB";
monitor T1_OK_Status;
int T2_OK_Status;
assign T2_OK_Status to "CWM-CWS04:Ctrl-Intf-001:DTL-020Ok-RB";
monitor T2_OK_Status;
int T3_OK_Status;
assign T3_OK_Status to "CWM-CWS04:Ctrl-Intf-001:DTL-030Ok-RB";
monitor T3_OK_Status;
int T4_OK_Status;
assign T4_OK_Status to "CWM-CWS04:Ctrl-Intf-001:DTL-040Ok-RB";
monitor T4_OK_Status;
int T5_OK_Status;
assign T5_OK_Status to "CWM-CWS04:Ctrl-Intf-001:DTL-050Ok-RB";
monitor T5_OK_Status;

/* Temperature sensors - value */
double T0_Temperature_Value;
assign T0_Temperature_Value to "CWM-CWS04:WtrC-TT-022:AITmp";
monitor T0_Temperature_Value;
double T1_Temperature_Value;
assign T1_Temperature_Value to "CWM-CWS04:WtrC-TT-101:AITmp";
monitor T1_Temperature_Value;
double T2_Temperature_Value;
assign T2_Temperature_Value to "CWM-CWS04:WtrC-TT-201:AITmp";
monitor T2_Temperature_Value;
double T3_Temperature_Value;
assign T3_Temperature_Value to "CWM-CWS04:WtrC-TT-301:AITmp";
monitor T3_Temperature_Value;
double T4_Temperature_Value;
assign T4_Temperature_Value to "CWM-CWS04:WtrC-TT-401:AITmp";
monitor T4_Temperature_Value;
double T5_Temperature_Value;
assign T5_Temperature_Value to "CWM-CWS04:WtrC-TT-501:AITmp";
monitor T5_Temperature_Value;

/* Temperature sensors - status */ /* 0=NOK|1=OK */
int T0_Temperature_Status;
assign T0_Temperature_Status to "CWM-CWS04:WtrC-TT-022:OkStat";
monitor T0_Temperature_Status;
int T1_Temperature_Status;
assign T1_Temperature_Status to "CWM-CWS04:WtrC-TT-101:OkStat";
monitor T1_Temperature_Status;
int T2_Temperature_Status;
assign T2_Temperature_Status to "CWM-CWS04:WtrC-TT-201:OkStat";
monitor T2_Temperature_Status;
int T3_Temperature_Status;
assign T3_Temperature_Status to "CWM-CWS04:WtrC-TT-301:OkStat";
monitor T3_Temperature_Status;
int T4_Temperature_Status;
assign T4_Temperature_Status to "CWM-CWS04:WtrC-TT-401:OkStat";
monitor T4_Temperature_Status;
int T5_Temperature_Status;
assign T5_Temperature_Status to "CWM-CWS04:WtrC-TT-501:OkStat";
monitor T5_Temperature_Status;

/* Temperature sensors - interlock status */ /* 0=NOK|1=OK */
int T0_Temperature_Ilk_Status;
assign T0_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-022:Ilk-OkStat";
monitor T0_Temperature_Ilk_Status;
int T1_Temperature_Ilk_Status;
assign T1_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-101:Ilk-OkStat";
monitor T1_Temperature_Ilk_Status;
int T2_Temperature_Ilk_Status;
assign T2_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-201:Ilk-OkStat";
monitor T2_Temperature_Ilk_Status;
int T3_Temperature_Ilk_Status;
assign T3_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-301:Ilk-OkStat";
monitor T3_Temperature_Ilk_Status;
int T4_Temperature_Ilk_Status;
assign T4_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-401:Ilk-OkStat";
monitor T4_Temperature_Ilk_Status;
int T5_Temperature_Ilk_Status;
assign T5_Temperature_Ilk_Status to "CWM-CWS04:WtrC-TT-501:Ilk-OkStat";
monitor T5_Temperature_Ilk_Status;

/* Temperature sensors - interlock enable command */ /* 0=EN|1=NOT_EN */
int T0_Temperature_Ilk_Enable_Cmd;
assign T0_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-022:Ilk-NotEnb";
monitor T0_Temperature_Ilk_Enable_Cmd;
int T1_Temperature_Ilk_Enable_Cmd;
assign T1_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-101:Ilk-NotEnb";
monitor T1_Temperature_Ilk_Enable_Cmd;
int T2_Temperature_Ilk_Enable_Cmd;
assign T2_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-201:Ilk-NotEnb";
monitor T2_Temperature_Ilk_Enable_Cmd;
int T3_Temperature_Ilk_Enable_Cmd;
assign T3_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-301:Ilk-NotEnb";
monitor T3_Temperature_Ilk_Enable_Cmd;
int T4_Temperature_Ilk_Enable_Cmd;
assign T4_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-401:Ilk-NotEnb";
monitor T4_Temperature_Ilk_Enable_Cmd;
int T5_Temperature_Ilk_Enable_Cmd;
assign T5_Temperature_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-TT-501:Ilk-NotEnb";
monitor T5_Temperature_Ilk_Enable_Cmd;

/* Temperature sensors - interlock enable command readback */ /* 0=EN|1=NOT_EN */
int T0_Temperature_Ilk_Enable_Cmd_RB;
assign T0_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-022:Ilk-NotEnb-RB";
monitor T0_Temperature_Ilk_Enable_Cmd_RB;
int T1_Temperature_Ilk_Enable_Cmd_RB;
assign T1_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-101:Ilk-NotEnb-RB";
monitor T1_Temperature_Ilk_Enable_Cmd_RB;
int T2_Temperature_Ilk_Enable_Cmd_RB;
assign T2_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-201:Ilk-NotEnb-RB";
monitor T2_Temperature_Ilk_Enable_Cmd_RB;
int T3_Temperature_Ilk_Enable_Cmd_RB;
assign T3_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-301:Ilk-NotEnb-RB";
monitor T3_Temperature_Ilk_Enable_Cmd_RB;
int T4_Temperature_Ilk_Enable_Cmd_RB;
assign T4_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-401:Ilk-NotEnb-RB";
monitor T4_Temperature_Ilk_Enable_Cmd_RB;
int T5_Temperature_Ilk_Enable_Cmd_RB;
assign T5_Temperature_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-TT-501:Ilk-NotEnb-RB";
monitor T5_Temperature_Ilk_Enable_Cmd_RB;

/* Temperature sensors - interlock auto hold command */ /* 0=EN|1=NOT_EN */
int T0_Temperature_Ilk_AutoHold_Cmd;
assign T0_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-022:Ilk-Hold";
monitor T0_Temperature_Ilk_AutoHold_Cmd;
int T1_Temperature_Ilk_AutoHold_Cmd;
assign T1_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-101:Ilk-Hold";
monitor T1_Temperature_Ilk_AutoHold_Cmd;
int T2_Temperature_Ilk_AutoHold_Cmd;
assign T2_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-201:Ilk-Hold";
monitor T2_Temperature_Ilk_AutoHold_Cmd;
int T3_Temperature_Ilk_AutoHold_Cmd;
assign T3_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-301:Ilk-Hold";
monitor T3_Temperature_Ilk_AutoHold_Cmd;
int T4_Temperature_Ilk_AutoHold_Cmd;
assign T4_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-401:Ilk-Hold";
monitor T4_Temperature_Ilk_AutoHold_Cmd;
int T5_Temperature_Ilk_AutoHold_Cmd;
assign T5_Temperature_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-TT-501:Ilk-Hold";
monitor T5_Temperature_Ilk_AutoHold_Cmd;

/* Temperature sensors - interlock auto hold command readback */ /* 0=EN|1=NOT_EN */
int T0_Temperature_Ilk_AutoHold_Cmd_RB;
assign T0_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-022:Ilk-Hold-RB";
monitor T0_Temperature_Ilk_AutoHold_Cmd_RB;
int T1_Temperature_Ilk_AutoHold_Cmd_RB;
assign T1_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-101:Ilk-Hold-RB";
monitor T1_Temperature_Ilk_AutoHold_Cmd_RB;
int T2_Temperature_Ilk_AutoHold_Cmd_RB;
assign T2_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-201:Ilk-Hold-RB";
monitor T2_Temperature_Ilk_AutoHold_Cmd_RB;
int T3_Temperature_Ilk_AutoHold_Cmd_RB;
assign T3_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-301:Ilk-Hold-RB";
monitor T3_Temperature_Ilk_AutoHold_Cmd_RB;
int T4_Temperature_Ilk_AutoHold_Cmd_RB;
assign T4_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-401:Ilk-Hold-RB";
monitor T4_Temperature_Ilk_AutoHold_Cmd_RB;
int T5_Temperature_Ilk_AutoHold_Cmd_RB;
assign T5_Temperature_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-TT-501:Ilk-Hold-RB";
monitor T5_Temperature_Ilk_AutoHold_Cmd_RB;

/* Temperature sensors - reset command */
int T0_Temperature_Reset_Cmd;
assign T0_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-022:Ilck-RstCmd";
monitor T0_Temperature_Reset_Cmd;
int T1_Temperature_Reset_Cmd;
assign T1_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-101:Ilck-RstCmd";
monitor T1_Temperature_Reset_Cmd;
int T2_Temperature_Reset_Cmd;
assign T2_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-201:Ilck-RstCmd";
monitor T2_Temperature_Reset_Cmd;
int T3_Temperature_Reset_Cmd;
assign T3_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-301:Ilck-RstCmd";
monitor T3_Temperature_Reset_Cmd;
int T4_Temperature_Reset_Cmd;
assign T4_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-401:Ilck-RstCmd";
monitor T4_Temperature_Reset_Cmd;
int T5_Temperature_Reset_Cmd;
assign T5_Temperature_Reset_Cmd to "CWM-CWS04:WtrC-TT-501:Ilck-RstCmd";
monitor T5_Temperature_Reset_Cmd;

/* Flux sensors - value */
double T0_Flux_Value;
assign T0_Flux_Value to "CWM-CWS04:WtrC-FIT-022:Flw";
monitor T0_Flux_Value;
double T1_Flux_Value;
assign T1_Flux_Value to "CWM-CWS04:WtrC-FIT-101:Flw";
monitor T1_Flux_Value;
double T2_Flux_Value;
assign T2_Flux_Value to "CWM-CWS04:WtrC-FIT-201:Flw";
monitor T2_Flux_Value;
double T3_Flux_Value;
assign T3_Flux_Value to "CWM-CWS04:WtrC-FIT-301:Flw";
monitor T3_Flux_Value;
double T4_Flux_Value;
assign T4_Flux_Value to "CWM-CWS04:WtrC-FIT-401:Flw";
monitor T4_Flux_Value;
double T5_Flux_Value;
assign T5_Flux_Value to "CWM-CWS04:WtrC-FIT-501:Flw";
monitor T5_Flux_Value;

/* Flux sensors - status */ /* 0=NOK|1=OK */
int T0_Flux_Status;
assign T0_Flux_Status to "CWM-CWS04:WtrC-FIT-022:Ok";
monitor T0_Flux_Status;
int T1_Flux_Status;
assign T1_Flux_Status to "CWM-CWS04:WtrC-FIT-101:Ok";
monitor T1_Flux_Status;
int T2_Flux_Status;
assign T2_Flux_Status to "CWM-CWS04:WtrC-FIT-201:Ok";
monitor T2_Flux_Status;
int T3_Flux_Status;
assign T3_Flux_Status to "CWM-CWS04:WtrC-FIT-301:Ok";
monitor T3_Flux_Status;
int T4_Flux_Status;
assign T4_Flux_Status to "CWM-CWS04:WtrC-FIT-401:Ok";
monitor T4_Flux_Status;
int T5_Flux_Status;
assign T5_Flux_Status to "CWM-CWS04:WtrC-FIT-501:Ok";
monitor T5_Flux_Status;

/* Flux sensors - interlock status */ /* 0=NOK|1=OK */
int T0_Flux_Ilk_Status;
assign T0_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-022:Ilk-OkStat";
monitor T0_Flux_Ilk_Status;
int T1_Flux_Ilk_Status;
assign T1_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-101:Ilk-OkStat";
monitor T1_Flux_Ilk_Status;
int T2_Flux_Ilk_Status;
assign T2_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-201:Ilk-OkStat";
monitor T2_Flux_Ilk_Status;
int T3_Flux_Ilk_Status;
assign T3_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-301:Ilk-OkStat";
monitor T3_Flux_Ilk_Status;
int T4_Flux_Ilk_Status;
assign T4_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-401:Ilk-OkStat";
monitor T4_Flux_Ilk_Status;
int T5_Flux_Ilk_Status;
assign T5_Flux_Ilk_Status to "CWM-CWS04:WtrC-FIT-501:Ilk-OkStat";
monitor T5_Flux_Ilk_Status;

/* Flux sensors - interlock enable command */ /* 0=EN|1=NOT_EN */
int T0_Flux_Ilk_Enable_Cmd;
assign T0_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-022:Ilk-NotEnb";
monitor T0_Flux_Ilk_Enable_Cmd;
int T1_Flux_Ilk_Enable_Cmd;
assign T1_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-101:Ilk-NotEnb";
monitor T1_Flux_Ilk_Enable_Cmd;
int T2_Flux_Ilk_Enable_Cmd;
assign T2_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-201:Ilk-NotEnb";
monitor T2_Flux_Ilk_Enable_Cmd;
int T3_Flux_Ilk_Enable_Cmd;
assign T3_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-301:Ilk-NotEnb";
monitor T3_Flux_Ilk_Enable_Cmd;
int T4_Flux_Ilk_Enable_Cmd;
assign T4_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-401:Ilk-NotEnb";
monitor T4_Flux_Ilk_Enable_Cmd;
int T5_Flux_Ilk_Enable_Cmd;
assign T5_Flux_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-FIT-501:Ilk-NotEnb";
monitor T5_Flux_Ilk_Enable_Cmd;

/* Flux sensors - interlock enable command readback */ /* 0=EN|1=NOT_EN */
int T0_Flux_Ilk_Enable_Cmd_RB;
assign T0_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-022:Ilk-NotEnb-RB";
monitor T0_Flux_Ilk_Enable_Cmd_RB;
int T1_Flux_Ilk_Enable_Cmd_RB;
assign T1_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-101:Ilk-NotEnb-RB";
monitor T1_Flux_Ilk_Enable_Cmd_RB;
int T2_Flux_Ilk_Enable_Cmd_RB;
assign T2_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-201:Ilk-NotEnb-RB";
monitor T2_Flux_Ilk_Enable_Cmd_RB;
int T3_Flux_Ilk_Enable_Cmd_RB;
assign T3_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-301:Ilk-NotEnb-RB";
monitor T3_Flux_Ilk_Enable_Cmd_RB;
int T4_Flux_Ilk_Enable_Cmd_RB;
assign T4_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-401:Ilk-NotEnb-RB";
monitor T4_Flux_Ilk_Enable_Cmd_RB;
int T5_Flux_Ilk_Enable_Cmd_RB;
assign T5_Flux_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-FIT-501:Ilk-NotEnb-RB";
monitor T5_Flux_Ilk_Enable_Cmd_RB;

/* Flux sensors - interlock auto hold command */ /* 0=EN|1=NOT_EN */
int T0_Flux_Ilk_AutoHold_Cmd;
assign T0_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-022:Ilk-Hold";
monitor T0_Flux_Ilk_AutoHold_Cmd;
int T1_Flux_Ilk_AutoHold_Cmd;
assign T1_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-101:Ilk-Hold";
monitor T1_Flux_Ilk_AutoHold_Cmd;
int T2_Flux_Ilk_AutoHold_Cmd;
assign T2_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-201:Ilk-Hold";
monitor T2_Flux_Ilk_AutoHold_Cmd;
int T3_Flux_Ilk_AutoHold_Cmd;
assign T3_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-301:Ilk-Hold";
monitor T3_Flux_Ilk_AutoHold_Cmd;
int T4_Flux_Ilk_AutoHold_Cmd;
assign T4_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-401:Ilk-Hold";
monitor T4_Flux_Ilk_AutoHold_Cmd;
int T5_Flux_Ilk_AutoHold_Cmd;
assign T5_Flux_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-FIT-501:Ilk-Hold";
monitor T5_Flux_Ilk_AutoHold_Cmd;

/* Flux sensors - interlock auto hold command readback */ /* 0=EN|1=NOT_EN */
int T0_Flux_Ilk_AutoHold_Cmd_RB;
assign T0_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-022:Ilk-Hold-RB";
monitor T0_Flux_Ilk_AutoHold_Cmd_RB;
int T1_Flux_Ilk_AutoHold_Cmd_RB;
assign T1_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-101:Ilk-Hold-RB";
monitor T1_Flux_Ilk_AutoHold_Cmd_RB;
int T2_Flux_Ilk_AutoHold_Cmd_RB;
assign T2_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-201:Ilk-Hold-RB";
monitor T2_Flux_Ilk_AutoHold_Cmd_RB;
int T3_Flux_Ilk_AutoHold_Cmd_RB;
assign T3_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-301:Ilk-Hold-RB";
monitor T3_Flux_Ilk_AutoHold_Cmd_RB;
int T4_Flux_Ilk_AutoHold_Cmd_RB;
assign T4_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-401:Ilk-Hold-RB";
monitor T4_Flux_Ilk_AutoHold_Cmd_RB;
int T5_Flux_Ilk_AutoHold_Cmd_RB;
assign T5_Flux_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-FIT-501:Ilk-Hold-RB";
monitor T5_Flux_Ilk_AutoHold_Cmd_RB;

/* Flux sensors - reset command */
int T0_Flux_Reset_Cmd;
assign T0_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-022:Ilck-RstCmd";
monitor T0_Flux_Reset_Cmd;
int T1_Flux_Reset_Cmd;
assign T1_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-101:Ilck-RstCmd";
monitor T1_Flux_Reset_Cmd;
int T2_Flux_Reset_Cmd;
assign T2_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-201:Ilck-RstCmd";
monitor T2_Flux_Reset_Cmd;
int T3_Flux_Reset_Cmd;
assign T3_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-301:Ilck-RstCmd";
monitor T3_Flux_Reset_Cmd;
int T4_Flux_Reset_Cmd;
assign T4_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-401:Ilck-RstCmd";
monitor T4_Flux_Reset_Cmd;
int T5_Flux_Reset_Cmd;
assign T5_Flux_Reset_Cmd to "CWM-CWS04:WtrC-FIT-501:Ilck-RstCmd";
monitor T5_Flux_Reset_Cmd;

/* Pressure sensors - value */
double T0_Pressure_1_Value;
assign T0_Pressure_1_Value to "CWM-CWS04:WtrC-PT-023:Prs";
monitor T0_Pressure_1_Value;
double T0_Pressure_2_Value;
assign T0_Pressure_2_Value to "CWM-CWS04:WtrC-PT-024:Prs";
monitor T0_Pressure_2_Value;
double T1_Pressure_1_Value;
assign T1_Pressure_1_Value to "CWM-CWS04:WtrC-PT-101:Prs";
monitor T1_Pressure_1_Value;
double T1_Pressure_2_Value;
assign T1_Pressure_2_Value to "CWM-CWS04:WtrC-PT-102:Prs";
monitor T1_Pressure_2_Value;
double T2_Pressure_1_Value;
assign T2_Pressure_1_Value to "CWM-CWS04:WtrC-PT-201:Prs";
monitor T2_Pressure_1_Value;
double T2_Pressure_2_Value;
assign T2_Pressure_2_Value to "CWM-CWS04:WtrC-PT-202:Prs";
monitor T2_Pressure_2_Value;
double T3_Pressure_1_Value;
assign T3_Pressure_1_Value to "CWM-CWS04:WtrC-PT-301:Prs";
monitor T3_Pressure_1_Value;
double T3_Pressure_2_Value;
assign T3_Pressure_2_Value to "CWM-CWS04:WtrC-PT-302:Prs";
monitor T3_Pressure_2_Value;
double T4_Pressure_1_Value;
assign T4_Pressure_1_Value to "CWM-CWS04:WtrC-PT-401:Prs";
monitor T4_Pressure_1_Value;
double T4_Pressure_2_Value;
assign T4_Pressure_2_Value to "CWM-CWS04:WtrC-PT-402:Prs";
monitor T4_Pressure_2_Value;
double T5_Pressure_1_Value;
assign T5_Pressure_1_Value to "CWM-CWS04:WtrC-PT-501:Prs";
monitor T5_Pressure_1_Value;
double T5_Pressure_2_Value;
assign T5_Pressure_2_Value to "CWM-CWS04:WtrC-PT-502:Prs";
monitor T5_Pressure_2_Value;

/* Pressure sensors - status */ /* 0=NOK|1=OK */
int T0_Pressure_1_Status;
assign T0_Pressure_1_Status to "CWM-CWS04:WtrC-PT-023:OkStat";
monitor T0_Pressure_1_Status;
int T0_Pressure_2_Status;
assign T0_Pressure_2_Status to "CWM-CWS04:WtrC-PT-024:OkStat";
monitor T0_Pressure_2_Status;
int T1_Pressure_1_Status;
assign T1_Pressure_1_Status to "CWM-CWS04:WtrC-PT-101:OkStat";
monitor T1_Pressure_1_Status;
int T1_Pressure_2_Status;
assign T1_Pressure_2_Status to "CWM-CWS04:WtrC-PT-102:OkStat";
monitor T1_Pressure_2_Status;
int T2_Pressure_1_Status;
assign T2_Pressure_1_Status to "CWM-CWS04:WtrC-PT-201:OkStat";
monitor T2_Pressure_1_Status;
int T2_Pressure_2_Status;
assign T2_Pressure_2_Status to "CWM-CWS04:WtrC-PT-202:OkStat";
monitor T2_Pressure_2_Status;
int T3_Pressure_1_Status;
assign T3_Pressure_1_Status to "CWM-CWS04:WtrC-PT-301:OkStat";
monitor T3_Pressure_1_Status;
int T3_Pressure_2_Status;
assign T3_Pressure_2_Status to "CWM-CWS04:WtrC-PT-302:OkStat";
monitor T3_Pressure_2_Status;
int T4_Pressure_1_Status;
assign T4_Pressure_1_Status to "CWM-CWS04:WtrC-PT-401:OkStat";
monitor T4_Pressure_1_Status;
int T4_Pressure_2_Status;
assign T4_Pressure_2_Status to "CWM-CWS04:WtrC-PT-402:OkStat";
monitor T4_Pressure_2_Status;
int T5_Pressure_1_Status;
assign T5_Pressure_1_Status to "CWM-CWS04:WtrC-PT-501:OkStat";
monitor T5_Pressure_1_Status;
int T5_Pressure_2_Status;
assign T5_Pressure_2_Status to "CWM-CWS04:WtrC-PT-502:OkStat";
monitor T5_Pressure_2_Status;

/* Pressure sensors - interlock status */ /* 0=NOK|1=OK */
int T0_Pressure_1_Ilk_Status;
assign T0_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-023:Ilk-OkStat";
monitor T0_Pressure_1_Ilk_Status;
int T0_Pressure_2_Ilk_Status;
assign T0_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-024:Ilk-OkStat";
monitor T0_Pressure_2_Ilk_Status;
int T1_Pressure_1_Ilk_Status;
assign T1_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-101:Ilk-OkStat";
monitor T1_Pressure_1_Ilk_Status;
int T1_Pressure_2_Ilk_Status;
assign T1_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-102:Ilk-OkStat";
monitor T1_Pressure_2_Ilk_Status;
int T2_Pressure_1_Ilk_Status;
assign T2_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-201:Ilk-OkStat";
monitor T2_Pressure_1_Ilk_Status;
int T2_Pressure_2_Ilk_Status;
assign T2_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-202:Ilk-OkStat";
monitor T2_Pressure_2_Ilk_Status;
int T3_Pressure_1_Ilk_Status;
assign T3_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-301:Ilk-OkStat";
monitor T3_Pressure_1_Ilk_Status;
int T3_Pressure_2_Ilk_Status;
assign T3_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-302:Ilk-OkStat";
monitor T3_Pressure_2_Ilk_Status;
int T4_Pressure_1_Ilk_Status;
assign T4_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-401:Ilk-OkStat";
monitor T4_Pressure_1_Ilk_Status;
int T4_Pressure_2_Ilk_Status;
assign T4_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-402:Ilk-OkStat";
monitor T4_Pressure_2_Ilk_Status;
int T5_Pressure_1_Ilk_Status;
assign T5_Pressure_1_Ilk_Status to "CWM-CWS04:WtrC-PT-501:Ilk-OkStat";
monitor T5_Pressure_1_Ilk_Status;
int T5_Pressure_2_Ilk_Status;
assign T5_Pressure_2_Ilk_Status to "CWM-CWS04:WtrC-PT-502:Ilk-OkStat";
monitor T5_Pressure_2_Ilk_Status;

/* Pressure sensors - interlock enable command */ /* 0=EN|1=NOT_EN */
int T0_Pressure_1_Ilk_Enable_Cmd;
assign T0_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-023:Ilk-NotEnb";
monitor T0_Pressure_1_Ilk_Enable_Cmd;
int T0_Pressure_2_Ilk_Enable_Cmd;
assign T0_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-024:Ilk-NotEnb";
monitor T0_Pressure_2_Ilk_Enable_Cmd;
int T1_Pressure_1_Ilk_Enable_Cmd;
assign T1_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-101:Ilk-NotEnb";
monitor T1_Pressure_1_Ilk_Enable_Cmd;
int T1_Pressure_2_Ilk_Enable_Cmd;
assign T1_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-102:Ilk-NotEnb";
monitor T1_Pressure_2_Ilk_Enable_Cmd;
int T2_Pressure_1_Ilk_Enable_Cmd;
assign T2_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-201:Ilk-NotEnb";
monitor T2_Pressure_1_Ilk_Enable_Cmd;
int T2_Pressure_2_Ilk_Enable_Cmd;
assign T2_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-202:Ilk-NotEnb";
monitor T2_Pressure_2_Ilk_Enable_Cmd;
int T3_Pressure_1_Ilk_Enable_Cmd;
assign T3_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-301:Ilk-NotEnb";
monitor T3_Pressure_1_Ilk_Enable_Cmd;
int T3_Pressure_2_Ilk_Enable_Cmd;
assign T3_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-302:Ilk-NotEnb";
monitor T3_Pressure_2_Ilk_Enable_Cmd;
int T4_Pressure_1_Ilk_Enable_Cmd;
assign T4_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-401:Ilk-NotEnb";
monitor T4_Pressure_1_Ilk_Enable_Cmd;
int T4_Pressure_2_Ilk_Enable_Cmd;
assign T4_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-402:Ilk-NotEnb";
monitor T4_Pressure_2_Ilk_Enable_Cmd;
int T5_Pressure_1_Ilk_Enable_Cmd;
assign T5_Pressure_1_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-501:Ilk-NotEnb";
monitor T5_Pressure_1_Ilk_Enable_Cmd;
int T5_Pressure_2_Ilk_Enable_Cmd;
assign T5_Pressure_2_Ilk_Enable_Cmd to "CWM-CWS04:WtrC-PT-502:Ilk-NotEnb";
monitor T5_Pressure_2_Ilk_Enable_Cmd;

/* Pressure sensors - interlock enable command readback */ /* 0=EN|1=NOT_EN */
int T0_Pressure_1_Ilk_Enable_Cmd_RB;
assign T0_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-023:Ilk-NotEnb-RB";
monitor T0_Pressure_1_Ilk_Enable_Cmd_RB;
int T0_Pressure_2_Ilk_Enable_Cmd_RB;
assign T0_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-024:Ilk-NotEnb-RB";
monitor T0_Pressure_2_Ilk_Enable_Cmd_RB;
int T1_Pressure_1_Ilk_Enable_Cmd_RB;
assign T1_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-101:Ilk-NotEnb-RB";
monitor T1_Pressure_1_Ilk_Enable_Cmd_RB;
int T1_Pressure_2_Ilk_Enable_Cmd_RB;
assign T1_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-102:Ilk-NotEnb-RB";
monitor T1_Pressure_2_Ilk_Enable_Cmd_RB;
int T2_Pressure_1_Ilk_Enable_Cmd_RB;
assign T2_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-201:Ilk-NotEnb-RB";
monitor T2_Pressure_1_Ilk_Enable_Cmd_RB;
int T2_Pressure_2_Ilk_Enable_Cmd_RB;
assign T2_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-202:Ilk-NotEnb-RB";
monitor T2_Pressure_2_Ilk_Enable_Cmd_RB;
int T3_Pressure_1_Ilk_Enable_Cmd_RB;
assign T3_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-301:Ilk-NotEnb-RB";
monitor T3_Pressure_1_Ilk_Enable_Cmd_RB;
int T3_Pressure_2_Ilk_Enable_Cmd_RB;
assign T3_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-302:Ilk-NotEnb-RB";
monitor T3_Pressure_2_Ilk_Enable_Cmd_RB;
int T4_Pressure_1_Ilk_Enable_Cmd_RB;
assign T4_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-401:Ilk-NotEnb-RB";
monitor T4_Pressure_1_Ilk_Enable_Cmd_RB;
int T4_Pressure_2_Ilk_Enable_Cmd_RB;
assign T4_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-402:Ilk-NotEnb-RB";
monitor T4_Pressure_2_Ilk_Enable_Cmd_RB;
int T5_Pressure_1_Ilk_Enable_Cmd_RB;
assign T5_Pressure_1_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-501:Ilk-NotEnb-RB";
monitor T5_Pressure_1_Ilk_Enable_Cmd_RB;
int T5_Pressure_2_Ilk_Enable_Cmd_RB;
assign T5_Pressure_2_Ilk_Enable_Cmd_RB to "CWM-CWS04:WtrC-PT-502:Ilk-NotEnb-RB";
monitor T5_Pressure_2_Ilk_Enable_Cmd_RB;

/* Pressure sensors - interlock auto hold command */ /* 0=EN|1=NOT_EN */
int T0_Pressure_1_Ilk_AutoHold_Cmd;
assign T0_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-023:Ilk-Hold";
monitor T0_Pressure_1_Ilk_AutoHold_Cmd;
int T0_Pressure_2_Ilk_AutoHold_Cmd;
assign T0_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-024:Ilk-Hold";
monitor T0_Pressure_2_Ilk_AutoHold_Cmd;
int T1_Pressure_1_Ilk_AutoHold_Cmd;
assign T1_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-101:Ilk-Hold";
monitor T1_Pressure_1_Ilk_AutoHold_Cmd;
int T1_Pressure_2_Ilk_AutoHold_Cmd;
assign T1_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-102:Ilk-Hold";
monitor T1_Pressure_2_Ilk_AutoHold_Cmd;
int T2_Pressure_1_Ilk_AutoHold_Cmd;
assign T2_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-201:Ilk-Hold";
monitor T2_Pressure_1_Ilk_AutoHold_Cmd;
int T2_Pressure_2_Ilk_AutoHold_Cmd;
assign T2_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-202:Ilk-Hold";
monitor T2_Pressure_2_Ilk_AutoHold_Cmd;
int T3_Pressure_1_Ilk_AutoHold_Cmd;
assign T3_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-301:Ilk-Hold";
monitor T3_Pressure_1_Ilk_AutoHold_Cmd;
int T3_Pressure_2_Ilk_AutoHold_Cmd;
assign T3_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-302:Ilk-Hold";
monitor T3_Pressure_2_Ilk_AutoHold_Cmd;
int T4_Pressure_1_Ilk_AutoHold_Cmd;
assign T4_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-401:Ilk-Hold";
monitor T4_Pressure_1_Ilk_AutoHold_Cmd;
int T4_Pressure_2_Ilk_AutoHold_Cmd;
assign T4_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-402:Ilk-Hold";
monitor T4_Pressure_2_Ilk_AutoHold_Cmd;
int T5_Pressure_1_Ilk_AutoHold_Cmd;
assign T5_Pressure_1_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-501:Ilk-Hold";
monitor T5_Pressure_1_Ilk_AutoHold_Cmd;
int T5_Pressure_2_Ilk_AutoHold_Cmd;
assign T5_Pressure_2_Ilk_AutoHold_Cmd to "CWM-CWS04:WtrC-PT-502:Ilk-Hold";
monitor T5_Pressure_2_Ilk_AutoHold_Cmd;

/* Pressure sensors - interlock auto hold command readback */ /* 0=EN|1=NOT_EN */
int T0_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T0_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-023:Ilk-Hold-RB";
monitor T0_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T0_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T0_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-024:Ilk-Hold-RB";
monitor T0_Pressure_2_Ilk_AutoHold_Cmd_RB;
int T1_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T1_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-101:Ilk-Hold-RB";
monitor T1_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T1_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T1_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-102:Ilk-Hold-RB";
monitor T1_Pressure_2_Ilk_AutoHold_Cmd_RB;
int T2_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T2_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-201:Ilk-Hold-RB";
monitor T2_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T2_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T2_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-202:Ilk-Hold-RB";
monitor T2_Pressure_2_Ilk_AutoHold_Cmd_RB;
int T3_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T3_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-301:Ilk-Hold-RB";
monitor T3_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T3_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T3_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-302:Ilk-Hold-RB";
monitor T3_Pressure_2_Ilk_AutoHold_Cmd_RB;
int T4_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T4_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-401:Ilk-Hold-RB";
monitor T4_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T4_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T4_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-402:Ilk-Hold-RB";
monitor T4_Pressure_2_Ilk_AutoHold_Cmd_RB;
int T5_Pressure_1_Ilk_AutoHold_Cmd_RB;
assign T5_Pressure_1_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-501:Ilk-Hold-RB";
monitor T5_Pressure_1_Ilk_AutoHold_Cmd_RB;
int T5_Pressure_2_Ilk_AutoHold_Cmd_RB;
assign T5_Pressure_2_Ilk_AutoHold_Cmd_RB to "CWM-CWS04:WtrC-PT-502:Ilk-Hold-RB";
monitor T5_Pressure_2_Ilk_AutoHold_Cmd_RB;

/* Pressure sensors - reset command */
int T0_Pressure_1_Reset_Cmd;
assign T0_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-023:Ilck-RstCmd";
monitor T0_Pressure_1_Reset_Cmd;
int T0_Pressure_2_Reset_Cmd;
assign T0_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-024:Ilck-RstCmd";
monitor T0_Pressure_2_Reset_Cmd;
int T1_Pressure_1_Reset_Cmd;
assign T1_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-101:Ilck-RstCmd";
monitor T1_Pressure_1_Reset_Cmd;
int T1_Pressure_2_Reset_Cmd;
assign T1_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-102:Ilck-RstCmd";
monitor T1_Pressure_2_Reset_Cmd;
int T2_Pressure_1_Reset_Cmd;
assign T2_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-201:Ilck-RstCmd";
monitor T2_Pressure_1_Reset_Cmd;
int T2_Pressure_2_Reset_Cmd;
assign T2_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-202:Ilck-RstCmd";
monitor T2_Pressure_2_Reset_Cmd;
int T3_Pressure_1_Reset_Cmd;
assign T3_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-301:Ilck-RstCmd";
monitor T3_Pressure_1_Reset_Cmd;
int T3_Pressure_2_Reset_Cmd;
assign T3_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-302:Ilck-RstCmd";
monitor T3_Pressure_2_Reset_Cmd;
int T4_Pressure_1_Reset_Cmd;
assign T4_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-401:Ilck-RstCmd";
monitor T4_Pressure_1_Reset_Cmd;
int T4_Pressure_2_Reset_Cmd;
assign T4_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-402:Ilck-RstCmd";
monitor T4_Pressure_2_Reset_Cmd;
int T5_Pressure_1_Reset_Cmd;
assign T5_Pressure_1_Reset_Cmd to "CWM-CWS04:WtrC-PT-501:Ilck-RstCmd";
monitor T5_Pressure_1_Reset_Cmd;
int T5_Pressure_2_Reset_Cmd;
assign T5_Pressure_2_Reset_Cmd to "CWM-CWS04:WtrC-PT-502:Ilck-RstCmd";
monitor T5_Pressure_2_Reset_Cmd;

/* Pump device - enable command */
int T0_Pump_Enable_Cmd;
assign T0_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-001:Enb";
monitor T0_Pump_Enable_Cmd;
int T1_Pump_Enable_Cmd;
assign T1_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-101:Enb";
monitor T1_Pump_Enable_Cmd;
int T2_Pump_Enable_Cmd;
assign T2_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-201:Enb";
monitor T2_Pump_Enable_Cmd;
int T3_Pump_Enable_Cmd;
assign T3_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-301:Enb";
monitor T3_Pump_Enable_Cmd;
int T4_Pump_Enable_Cmd;
assign T4_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-401:Enb";
monitor T4_Pump_Enable_Cmd;
int T5_Pump_Enable_Cmd;
assign T5_Pump_Enable_Cmd to "CWM-CWS04:WtrC-P-501:Enb";
monitor T5_Pump_Enable_Cmd;

/* Pump device - enable readback */
int T0_Pump_Enable_RB;
assign T0_Pump_Enable_RB to "CWM-CWS04:WtrC-P-001:Enb-RB";
monitor T0_Pump_Enable_RB;
int T1_Pump_Enable_RB;
assign T1_Pump_Enable_RB to "CWM-CWS04:WtrC-P-101:Enb-RB";
monitor T1_Pump_Enable_RB;
int T2_Pump_Enable_RB;
assign T2_Pump_Enable_RB to "CWM-CWS04:WtrC-P-201:Enb-RB";
monitor T2_Pump_Enable_RB;
int T3_Pump_Enable_RB;
assign T3_Pump_Enable_RB to "CWM-CWS04:WtrC-P-301:Enb-RB";
monitor T3_Pump_Enable_RB;
int T4_Pump_Enable_RB;
assign T4_Pump_Enable_RB to "CWM-CWS04:WtrC-P-401:Enb-RB";
monitor T4_Pump_Enable_RB;
int T5_Pump_Enable_RB;
assign T5_Pump_Enable_RB to "CWM-CWS04:WtrC-P-501:Enb-RB";
monitor T5_Pump_Enable_RB;

/* Pump device - start command */
int T0_Pump_Start_Cmd;
assign T0_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-001:StartCmd";
monitor T0_Pump_Start_Cmd;
int T1_Pump_Start_Cmd;
assign T1_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-101:StartCmd";
monitor T1_Pump_Start_Cmd;
int T2_Pump_Start_Cmd;
assign T2_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-201:StartCmd";
monitor T2_Pump_Start_Cmd;
int T3_Pump_Start_Cmd;
assign T3_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-301:StartCmd";
monitor T3_Pump_Start_Cmd;
int T4_Pump_Start_Cmd;
assign T4_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-401:StartCmd";
monitor T4_Pump_Start_Cmd;
int T5_Pump_Start_Cmd;
assign T5_Pump_Start_Cmd to "CWM-CWS04:WtrC-P-501:StartCmd";
monitor T5_Pump_Start_Cmd;

/* Pump device - Stop command */
int T0_Pump_Stop_Cmd;
assign T0_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-001:StopCmd";
monitor T0_Pump_Stop_Cmd;
int T1_Pump_Stop_Cmd;
assign T1_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-101:StopCmd";
monitor T1_Pump_Stop_Cmd;
int T2_Pump_Stop_Cmd;
assign T2_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-201:StopCmd";
monitor T2_Pump_Stop_Cmd;
int T3_Pump_Stop_Cmd;
assign T3_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-301:StopCmd";
monitor T3_Pump_Stop_Cmd;
int T4_Pump_Stop_Cmd;
assign T4_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-401:StopCmd";
monitor T4_Pump_Stop_Cmd;
int T5_Pump_Stop_Cmd;
assign T5_Pump_Stop_Cmd to "CWM-CWS04:WtrC-P-501:StopCmd";
monitor T5_Pump_Stop_Cmd;

/* Pump device - On Status */
int T0_Pump_OnStat;
assign T0_Pump_OnStat to "CWM-CWS04:WtrC-P-001:OnStat";
monitor T0_Pump_OnStat;
int T1_Pump_OnStat;
assign T1_Pump_OnStat to "CWM-CWS04:WtrC-P-101:OnStat";
monitor T1_Pump_OnStat;
int T2_Pump_OnStat;
assign T2_Pump_OnStat to "CWM-CWS04:WtrC-P-201:OnStat";
monitor T2_Pump_OnStat;
int T3_Pump_OnStat;
assign T3_Pump_OnStat to "CWM-CWS04:WtrC-P-301:OnStat";
monitor T3_Pump_OnStat;
int T4_Pump_OnStat;
assign T4_Pump_OnStat to "CWM-CWS04:WtrC-P-401:OnStat";
monitor T4_Pump_OnStat;
int T5_Pump_OnStat;
assign T5_Pump_OnStat to "CWM-CWS04:WtrC-P-501:OnStat";
monitor T5_Pump_OnStat;

/* Pump device - General Ok Status */ /* 0=NOK|1=OK */
int T0_Pump_General_Ok_Stat;
assign T0_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-001:OkStat";
monitor T0_Pump_General_Ok_Stat;
int T1_Pump_General_Ok_Stat;
assign T1_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-101:OkStat";
monitor T1_Pump_General_Ok_Stat;
int T2_Pump_General_Ok_Stat;
assign T2_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-201:OkStat";
monitor T2_Pump_General_Ok_Stat;
int T3_Pump_General_Ok_Stat;
assign T3_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-301:OkStat";
monitor T3_Pump_General_Ok_Stat;
int T4_Pump_General_Ok_Stat;
assign T4_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-401:OkStat";
monitor T4_Pump_General_Ok_Stat;
int T5_Pump_General_Ok_Stat;
assign T5_Pump_General_Ok_Stat to "CWM-CWS04:WtrC-P-501:OkStat";
monitor T5_Pump_General_Ok_Stat;

/* Pump device - FC Ok Status */ /* 0=NOK|1=OK */
int T0_Pump_FC_Ok_Status;
assign T0_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-001:FC-OkStat";
monitor T0_Pump_FC_Ok_Status;
int T1_Pump_FC_Ok_Status;
assign T1_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-101:FC-OkStat";
monitor T1_Pump_FC_Ok_Status;
int T2_Pump_FC_Ok_Status;
assign T2_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-201:FC-OkStat";
monitor T2_Pump_FC_Ok_Status;
int T3_Pump_FC_Ok_Status;
assign T3_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-301:FC-OkStat";
monitor T3_Pump_FC_Ok_Status;
int T4_Pump_FC_Ok_Status;
assign T4_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-401:FC-OkStat";
monitor T4_Pump_FC_Ok_Status;
int T5_Pump_FC_Ok_Status;
assign T5_Pump_FC_Ok_Status to "CWM-CWS04:WtrC-P-501:FC-OkStat";
monitor T5_Pump_FC_Ok_Status;

/* Pump device - LFC Ok Status */ /* 0=NOK|1=OK */
int T0_Pump_LFC_Ok_Status;
assign T0_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-001:LFC-OkStat";
monitor T0_Pump_LFC_Ok_Status;
int T1_Pump_LFC_Ok_Status;
assign T1_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-101:LFC-OkStat";
monitor T1_Pump_LFC_Ok_Status;
int T2_Pump_LFC_Ok_Status;
assign T2_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-201:LFC-OkStat";
monitor T2_Pump_LFC_Ok_Status;
int T3_Pump_LFC_Ok_Status;
assign T3_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-301:LFC-OkStat";
monitor T3_Pump_LFC_Ok_Status;
int T4_Pump_LFC_Ok_Status;
assign T4_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-401:LFC-OkStat";
monitor T4_Pump_LFC_Ok_Status;
int T5_Pump_LFC_Ok_Status;
assign T5_Pump_LFC_Ok_Status to "CWM-CWS04:WtrC-P-501:LFC-OkStat";
monitor T5_Pump_LFC_Ok_Status;

/* Pump device - LPIC Ok Status */ /* 0=NOK|1=OK */
int T0_Pump_LPIC_Ok_Status;
assign T0_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-001:LPIC-OkStat";
monitor T0_Pump_LPIC_Ok_Status;
int T1_Pump_LPIC_Ok_Status;
assign T1_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-101:LPIC-OkStat";
monitor T1_Pump_LPIC_Ok_Status;
int T2_Pump_LPIC_Ok_Status;
assign T2_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-201:LPIC-OkStat";
monitor T2_Pump_LPIC_Ok_Status;
int T3_Pump_LPIC_Ok_Status;
assign T3_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-301:LPIC-OkStat";
monitor T3_Pump_LPIC_Ok_Status;
int T4_Pump_LPIC_Ok_Status;
assign T4_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-401:LPIC-OkStat";
monitor T4_Pump_LPIC_Ok_Status;
int T5_Pump_LPIC_Ok_Status;
assign T5_Pump_LPIC_Ok_Status to "CWM-CWS04:WtrC-P-501:LPIC-OkStat";
monitor T5_Pump_LPIC_Ok_Status;

/* Pump device - interlock Ok Status */ /* 0=NOK|1=OK */
int T0_Pump_Ilck_Ok_Status;
assign T0_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-001:Ilck-OkStat";
monitor T0_Pump_Ilck_Ok_Status;
int T1_Pump_Ilck_Ok_Status;
assign T1_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-101:Ilck-OkStat";
monitor T1_Pump_Ilck_Ok_Status;
int T2_Pump_Ilck_Ok_Status;
assign T2_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-201:Ilck-OkStat";
monitor T2_Pump_Ilck_Ok_Status;
int T3_Pump_Ilck_Ok_Status;
assign T3_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-301:Ilck-OkStat";
monitor T3_Pump_Ilck_Ok_Status;
int T4_Pump_Ilck_Ok_Status;
assign T4_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-401:Ilck-OkStat";
monitor T4_Pump_Ilck_Ok_Status;
int T5_Pump_Ilck_Ok_Status;
assign T5_Pump_Ilck_Ok_Status to "CWM-CWS04:WtrC-P-501:Ilck-OkStat";
monitor T5_Pump_Ilck_Ok_Status;

/* Pump device - Error Reset */
int T0_Pump_Error_Reset;
assign T0_Pump_Error_Reset to "CWM-CWS04:WtrC-P-001:ErrRstCmd";
monitor T0_Pump_Error_Reset;
int T1_Pump_Error_Reset;
assign T1_Pump_Error_Reset to "CWM-CWS04:WtrC-P-101:ErrRstCmd";
monitor T1_Pump_Error_Reset;
int T2_Pump_Error_Reset;
assign T2_Pump_Error_Reset to "CWM-CWS04:WtrC-P-201:ErrRstCmd";
monitor T2_Pump_Error_Reset;
int T3_Pump_Error_Reset;
assign T3_Pump_Error_Reset to "CWM-CWS04:WtrC-P-301:ErrRstCmd";
monitor T3_Pump_Error_Reset;
int T4_Pump_Error_Reset;
assign T4_Pump_Error_Reset to "CWM-CWS04:WtrC-P-401:ErrRstCmd";
monitor T4_Pump_Error_Reset;
int T5_Pump_Error_Reset;
assign T5_Pump_Error_Reset to "CWM-CWS04:WtrC-P-501:ErrRstCmd";
monitor T5_Pump_Error_Reset;

/* Valve YSV device - enable command */
int T0_Valve_1_Enable_Cmd;
assign T0_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-YSV-001:Enb";
monitor T0_Valve_1_Enable_Cmd;
int T0_Valve_2_Enable_Cmd;
assign T0_Valve_2_Enable_Cmd to "CWM-CWS04:WtrC-YSV-002:Enb";
monitor T0_Valve_2_Enable_Cmd;

/* Valve YSV device - enable readback */
int T0_Valve_1_Enable_RB;
assign T0_Valve_1_Enable_RB to "CWM-CWS04:WtrC-YSV-001:Enb-RB";
monitor T0_Valve_1_Enable_RB;
int T0_Valve_2_Enable_RB;
assign T0_Valve_2_Enable_RB to "CWM-CWS04:WtrC-YSV-002:Enb-RB";
monitor T0_Valve_2_Enable_RB;

/* Valve YSV device - Open command */
int T0_Valve_1_Open_Cmd;
assign T0_Valve_1_Open_Cmd to "CWM-CWS04:WtrC-YSV-001:OpenCmd";
monitor T0_Valve_1_Open_Cmd;
int T0_Valve_2_Open_Cmd;
assign T0_Valve_2_Open_Cmd to "CWM-CWS04:WtrC-YSV-002:OpenCmd";
monitor T0_Valve_2_Open_Cmd;

/* Valve YSV device - Open readback */
int T0_Valve_1_Open_RB;
assign T0_Valve_1_Open_RB to "CWM-CWS04:WtrC-YSV-001:Opened";
monitor T0_Valve_1_Open_RB;
int T0_Valve_2_Open_RB;
assign T0_Valve_2_Open_RB to "CWM-CWS04:WtrC-YSV-002:Opened";
monitor T0_Valve_2_Open_RB;

/* Valve YSV device - Close command */
int T0_Valve_1_Close_Cmd;
assign T0_Valve_1_Close_Cmd to "CWM-CWS04:WtrC-YSV-001:CloseCmd";
monitor T0_Valve_1_Close_Cmd;
int T0_Valve_2_Close_Cmd;
assign T0_Valve_2_Close_Cmd to "CWM-CWS04:WtrC-YSV-002:CloseCmd";
monitor T0_Valve_2_Close_Cmd;

/* Valve YSV device - Close readback */
int T0_Valve_1_Close_RB;
assign T0_Valve_1_Close_RB to "CWM-CWS04:WtrC-YSV-001:Closed";
monitor T0_Valve_1_Close_RB;
int T0_Valve_2_Close_RB;
assign T0_Valve_2_Close_RB to "CWM-CWS04:WtrC-YSV-002:Closed";
monitor T0_Valve_2_Close_RB;

/* Valve YSV device - ok status */
int T0_Valve_1_Ok_Stat;
assign T0_Valve_1_Ok_Stat to "CWM-CWS04:WtrC-YSV-001:OkStat";
monitor T0_Valve_1_Ok_Stat;
int T0_Valve_2_Ok_Stat;
assign T0_Valve_2_Ok_Stat to "CWM-CWS04:WtrC-YSV-002:OkStat";
monitor T0_Valve_2_Ok_Stat;

/* Valve YSV device - error reset command */
int T0_Valve_1_Error_Reset;
assign T0_Valve_1_Error_Reset to "CWM-CWS04:WtrC-YSV-001:ErrRstCmd";
monitor T0_Valve_1_Error_Reset;
int T0_Valve_2_Error_Reset;
assign T0_Valve_2_Error_Reset to "CWM-CWS04:WtrC-YSV-002:ErrRstCmd";
monitor T0_Valve_2_Error_Reset;

/* Valve TCV device - enable command */
int T0_Valve_1_Enable_Cmd;
assign T0_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-001:Enb";
monitor T0_Valve_1_Enable_Cmd;
int T1_Valve_1_Enable_Cmd;
assign T1_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-101:Enb";
monitor T1_Valve_1_Enable_Cmd;
int T2_Valve_1_Enable_Cmd;
assign T2_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-201:Enb";
monitor T2_Valve_1_Enable_Cmd;
int T3_Valve_1_Enable_Cmd;
assign T3_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-301:Enb";
monitor T3_Valve_1_Enable_Cmd;
int T4_Valve_1_Enable_Cmd;
assign T4_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-401:Enb";
monitor T4_Valve_1_Enable_Cmd;
int T5_Valve_1_Enable_Cmd;
assign T5_Valve_1_Enable_Cmd to "CWM-CWS04:WtrC-TCV-501:Enb";
monitor T5_Valve_1_Enable_Cmd;

/* Valve TCV device - enable readback */
int T0_Valve_1_Enable_RB;
assign T0_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-001:Enb-RB";
monitor T0_Valve_1_Enable_RB;
int T1_Valve_1_Enable_RB;
assign T1_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-101:Enb-RB";
monitor T1_Valve_1_Enable_RB;
int T2_Valve_1_Enable_RB;
assign T2_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-201:Enb-RB";
monitor T2_Valve_1_Enable_RB;
int T3_Valve_1_Enable_RB;
assign T3_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-301:Enb-RB";
monitor T3_Valve_1_Enable_RB;
int T4_Valve_1_Enable_RB;
assign T4_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-401:Enb-RB";
monitor T4_Valve_1_Enable_RB;
int T5_Valve_1_Enable_RB;
assign T5_Valve_1_Enable_RB to "CWM-CWS04:WtrC-TCV-501:Enb-RB";
monitor T5_Valve_1_Enable_RB;

/* Valve TCV device - manual position command */
int T0_Valve_1_Manual_Cmd;
assign T0_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-001:FBL-ManOn";
monitor T0_Valve_1_Manual_Cmd;
int T1_Valve_1_Manual_Cmd;
assign T1_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-101:FBL-ManOn";
monitor T1_Valve_1_Manual_Cmd;
int T2_Valve_1_Manual_Cmd;
assign T2_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-201:FBL-ManOn";
monitor T2_Valve_1_Manual_Cmd;
int T3_Valve_1_Manual_Cmd;
assign T3_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-301:FBL-ManOn";
monitor T3_Valve_1_Manual_Cmd;
int T4_Valve_1_Manual_Cmd;
assign T4_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-401:FBL-ManOn";
monitor T4_Valve_1_Manual_Cmd;
int T5_Valve_1_Manual_Cmd;
assign T5_Valve_1_Manual_Cmd to "CWM-CWS04:WtrC-TCV-501:FBL-ManOn";
monitor T5_Valve_1_Manual_Cmd;

/* Valve TCV device - manual position readback */
int T0_Valve_1_Manual_RB;
assign T0_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-001:FBL-ManOn-RB";
monitor T0_Valve_1_Manual_RB;
int T1_Valve_1_Manual_RB;
assign T1_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-101:FBL-ManOn-RB";
monitor T1_Valve_1_Manual_RB;
int T2_Valve_1_Manual_RB;
assign T2_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-201:FBL-ManOn-RB";
monitor T2_Valve_1_Manual_RB;
int T3_Valve_1_Manual_RB;
assign T3_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-301:FBL-ManOn-RB";
monitor T3_Valve_1_Manual_RB;
int T4_Valve_1_Manual_RB;
assign T4_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-401:FBL-ManOn-RB";
monitor T4_Valve_1_Manual_RB;
int T5_Valve_1_Manual_RB;
assign T5_Valve_1_Manual_RB to "CWM-CWS04:WtrC-TCV-501:FBL-ManOn-RB";
monitor T5_Valve_1_Manual_RB;

/* Valve TCV device - manual position command */
double T0_Valve_1_Manual_Position_Cmd;
assign T0_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-001:FBL-ManPos";
monitor T0_Valve_1_Manual_Position_Cmd;
double T1_Valve_1_Manual_Position_Cmd;
assign T1_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-101:FBL-ManPos";
monitor T1_Valve_1_Manual_Position_Cmd;
double T2_Valve_1_Manual_Position_Cmd;
assign T2_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-201:FBL-ManPos";
monitor T2_Valve_1_Manual_Position_Cmd;
double T3_Valve_1_Manual_Position_Cmd;
assign T3_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-301:FBL-ManPos";
monitor T3_Valve_1_Manual_Position_Cmd;
double T4_Valve_1_Manual_Position_Cmd;
assign T4_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-401:FBL-ManPos";
monitor T4_Valve_1_Manual_Position_Cmd;
double T5_Valve_1_Manual_Position_Cmd;
assign T5_Valve_1_Manual_Position_Cmd to "CWM-CWS04:WtrC-TCV-501:FBL-ManPos";
monitor T5_Valve_1_Manual_Position_Cmd;

/* Valve TCV device - manual position readback */
double T0_Valve_1_Manual_Position_RB;
assign T0_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-001:FBL-ManPos-RB";
monitor T0_Valve_1_Manual_Position_RB;
double T1_Valve_1_Manual_Position_RB;
assign T1_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-101:FBL-ManPos-RB";
monitor T1_Valve_1_Manual_Position_RB;
double T2_Valve_1_Manual_Position_RB;
assign T2_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-201:FBL-ManPos-RB";
monitor T2_Valve_1_Manual_Position_RB;
double T3_Valve_1_Manual_Position_RB;
assign T3_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-301:FBL-ManPos-RB";
monitor T3_Valve_1_Manual_Position_RB;
double T4_Valve_1_Manual_Position_RB;
assign T4_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-401:FBL-ManPos-RB";
monitor T4_Valve_1_Manual_Position_RB;
double T5_Valve_1_Manual_Position_RB;
assign T5_Valve_1_Manual_Position_RB to "CWM-CWS04:WtrC-TCV-501:FBL-ManPos-RB";
monitor T5_Valve_1_Manual_Position_RB;

/* Valve TCV device - manual position */
double T0_Valve_1_Manual_Position;
assign T0_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-001:Pos";
monitor T0_Valve_1_Manual_Position;
double T1_Valve_1_Manual_Position;
assign T1_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-101:Pos";
monitor T1_Valve_1_Manual_Position;
double T2_Valve_1_Manual_Position;
assign T2_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-201:Pos";
monitor T2_Valve_1_Manual_Position;
double T3_Valve_1_Manual_Position;
assign T3_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-301:Pos";
monitor T3_Valve_1_Manual_Position;
double T4_Valve_1_Manual_Position;
assign T4_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-401:Pos";
monitor T4_Valve_1_Manual_Position;
double T5_Valve_1_Manual_Position;
assign T5_Valve_1_Manual_Position to "CWM-CWS04:WtrC-TCV-501:Pos";
monitor T5_Valve_1_Manual_Position;

/* Valve TCV device - temperature setpoint */
double T0_Valve_1_Temperature_Setpoint;
assign T0_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-001:TmpSP";
monitor T0_Valve_1_Temperature_Setpoint;
double T1_Valve_1_Temperature_Setpoint;
assign T1_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-101:TmpSP";
monitor T1_Valve_1_Temperature_Setpoint;
double T2_Valve_1_Temperature_Setpoint;
assign T2_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-201:TmpSP";
monitor T2_Valve_1_Temperature_Setpoint;
double T3_Valve_1_Temperature_Setpoint;
assign T3_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-301:TmpSP";
monitor T3_Valve_1_Temperature_Setpoint;
double T4_Valve_1_Temperature_Setpoint;
assign T4_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-401:TmpSP";
monitor T4_Valve_1_Temperature_Setpoint;
double T5_Valve_1_Temperature_Setpoint;
assign T5_Valve_1_Temperature_Setpoint to "CWM-CWS04:WtrC-TCV-501:TmpSP";
monitor T5_Valve_1_Temperature_Setpoint;

/* Valve TCV device - general status */ /* 0=NOK|1=OK */
int T0_Valve_1_General_Status;
assign T0_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-001:OkStat";
monitor T0_Valve_1_General_Status;
int T1_Valve_1_General_Status;
assign T1_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-101:OkStat";
monitor T1_Valve_1_General_Status;
int T2_Valve_1_General_Status;
assign T2_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-201:OkStat";
monitor T2_Valve_1_General_Status;
int T3_Valve_1_General_Status;
assign T3_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-301:OkStat";
monitor T3_Valve_1_General_Status;
int T4_Valve_1_General_Status;
assign T4_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-401:OkStat";
monitor T4_Valve_1_General_Status;
int T5_Valve_1_General_Status;
assign T5_Valve_1_General_Status to "CWM-CWS04:WtrC-TCV-501:OkStat";
monitor T5_Valve_1_General_Status;

/* Valve TCV device - interlock status */ /* 0=NOK|1=OK */
int T0_Valve_1_Ilck_Status;
assign T0_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-001:Ilck-OkStat";
monitor T0_Valve_1_Ilck_Status;
int T1_Valve_1_Ilck_Status;
assign T1_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-101:Ilck-OkStat";
monitor T1_Valve_1_Ilck_Status;
int T2_Valve_1_Ilck_Status;
assign T2_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-201:Ilck-OkStat";
monitor T2_Valve_1_Ilck_Status;
int T3_Valve_1_Ilck_Status;
assign T3_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-301:Ilck-OkStat";
monitor T3_Valve_1_Ilck_Status;
int T4_Valve_1_Ilck_Status;
assign T4_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-401:Ilck-OkStat";
monitor T4_Valve_1_Ilck_Status;
int T5_Valve_1_Ilck_Status;
assign T5_Valve_1_Ilck_Status to "CWM-CWS04:WtrC-TCV-501:Ilck-OkStat";
monitor T5_Valve_1_Ilck_Status;

/* Valve TCV device - error reset */
int T0_Valve_1_Error_Reset;
assign T0_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-001:ErrRstCmd";
monitor T0_Valve_1_Error_Reset;
int T1_Valve_1_Error_Reset;
assign T1_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-101:ErrRstCmd";
monitor T1_Valve_1_Error_Reset;
int T2_Valve_1_Error_Reset;
assign T2_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-201:ErrRstCmd";
monitor T2_Valve_1_Error_Reset;
int T3_Valve_1_Error_Reset;
assign T3_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-301:ErrRstCmd";
monitor T3_Valve_1_Error_Reset;
int T4_Valve_1_Error_Reset;
assign T4_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-401:ErrRstCmd";
monitor T4_Valve_1_Error_Reset;
int T5_Valve_1_Error_Reset;
assign T5_Valve_1_Error_Reset to "CWM-CWS04:WtrC-TCV-501:ErrRstCmd";
monitor T5_Valve_1_Error_Reset;

/* EPICS <-> PLC Communication */
double EPICS_Message;
assign EPICS_Message to "CWM-CWS04:Ctrl-Intf-001:EPICSCommMsg";
monitor EPICS_Message;

double PLC_Message;
assign PLC_Message to "CWM-CWS04:Ctrl-Intf-001:PLCCommMsg"
monitor PLC_Message;


/* Manual/Auto Control  */
int AutoControlCmd;
assign AutoControlCmd to "DTL:WtrC:AutoCmd";
monitor AutoControlCmd;

int AutoControl_ActualStatus;
assign AutoControl_ActualStatus to "DTL:WtrC:AutoCmd-RB";
monitor AutoControl_ActualStatus;

/* Manual Test Procedure Completed Command*/
int Manual_Test_Done;
assign Manual_Test_Done to "DTL:WtrC:TestDone";
monitor Manual_Test_Done;

/* Start and Stop Operations */
int StartOperationCmd;
assign StartOperationCmd to "DTL:WtrC:OpRun";
monitor StartOperationCmd;
int StopOperationCmd;
assign StopOperationCmd to "DTL:WtrC:OpStop";
monitor StopOperationCmd;

/* Maintenance and fault control*/
int MaintenanceReset;
assign MaintenanceReset to "DTL:WtrC:MaintenanceRst";
monitor MaintenanceReset;
int FaultReset;
assign FaultReset to "DTL:WtrC:FaultRst";
monitor FaultReset;

/* Working Temperatures (from main DTL stame machine) */
double Cooling_RFCond_Working_Temperature;
assign Cooling_RFCond_Working_Temperature to "DTL:WtrC:RFCondWorkingTmp";
monitor Cooling_RFCond_Working_Temperature;
double Cooling_BeamOp_Working_Temperature;
assign Cooling_BeamOp_Working_Temperature to "DTL:WtrC:BeamOpWorkingTmp";
monitor Cooling_BeamOp_Working_Temperature;
double Cooling_NoBeam_Working_Temperature;
assign Cooling_NoBeam_Working_Temperature to "DTL:WtrC:NoBeamWorkingTmp";
monitor Cooling_NoBeam_Working_Temperature;
double Cooling_Delta_Working_Temperature;
assign Cooling_Delta_Working_Temperature to "TL:WtrC:DeltaWorkingTmp";
monitor Cooling_Delta_Working_Temperature;


/* Delta Frequency Detuning */
/*
 * RF Freq Low Threshold Δf1
 * RF Freq High Threshold Δf2
 * | Δf1 | < | Δf2 |
*/
double Freq_High_Delta;
assign Freq_High_Delta to "DTL:RFS:BeamOpHDeltaFreq"
monitor Freq_High_Delta;
double Freq_Low_Delta;
assign Freq_Low_Delta to "DTL:RFS:BeamOpHDeltaFreq"
monitor Freq_Low_Delta;

/* DTL Frequency Detuning  */
double DTL_Frequency_Detuning;
assign  DTL_Frequency_Detuning to "";
monitor DTL_Frequency_Detuning;

/*
# Stages Code:
# 	0  -> INIT
# 	10 -> SELF-CHECK
# 	20 -> IDLE
# 	30 -> START-UP
# 	40 -> READY FOR OPERATION
# 	50 -> FAILURE
# 	60 -> MAINTENANCE
*/
int StateMachineCode;
assign StateMachineCode to "DTL:WtrC:StateMachine";

/*
# DTL Operational State Machine Code:
# 	0   -> INIT
# 	101 -> STAND-BY
# 	202 -> RF CONDITIONING
# 	303 -> RF START-UP
# 	404 -> READY FOR OPERATION
# 	505 -> NO ACCELERATED BEAM
# 	606 -> MAINTENANCE
*/
int dtlOperationalCode;
assign dtlOperationalCode to "DTL::StateMachine";
monitor dtlOperationalCode;



/* Constants */
double MAX_FLUX_CHECK=10;       // [L/min]
double MIN_FLUX_CHECK=3;        // [L/min]
double MAX_PRESS_CHECK=10;      // [bar]
double MIN_PRESS_CHECK=3;       // [bar]

double TCV_PRELIMINARY_POS=50;  // [%]


/* Internal Variables */
int dtl_operation_code_prev=0;

/* Debug Mode: */
double DEBUG=1;



/*
# State Machine Definition
*/

ss  cooling_statemachine {

/* state INITIALIZATION	*/
	state initialization {
      entry {
        printf("\n\nPreliminary controls executed due to Application Startup - Intialization\n\n");
        StateMachineCode=0;
        pvPut(StateMachineCode);
      }

      /* Start control only when skid is in remote control */
      when ( (pvConnectCount()==pvAssignCount()) && (PLC_Message == -188) ) {
        printf("[SEQ COOLING] All PVs connected and System in Remote Control\n");
        printf("[SEQ COOLING] Starting Self Check Process\n");
        /* Actual man|auto control initialization */
        AutoControl_ActualStatus = AutoControlCmd;
        pvPut(AutoControl_ActualStatus);

        /* Preliminary set OK status */
        T1_OK_Status=1;
        pvPut(T1_OK_Status);
        T2_OK_Status=1;
        pvPut(T2_OK_Status);
        T3_OK_Status=1;
        pvPut(T3_OK_Status);
        T4_OK_Status=1;
        pvPut(T4_OK_Status);
        T5_OK_Status=1;
        pvPut(T5_OK_Status);
        Main_OK_Status=1;
        pvPut(Main_OK_Status);


      } state self_check
	}


/* state SELF_CHECK	*/
	state self_check {
      entry {
        printf("\n[SEQ COOLING] Enter in SELF CHECK status\n");
        StateMachineCode=10;
        pvPut(StateMachineCode);

        /* preliminary reset all devices */
        printf("\n[SEQ COOLING] Reset error for any device.\n");
        /* Pumps */
        T0_Pump_Error_Reset=1;
        pvPut(T0_Pump_Error_Reset);
        T1_Pump_Error_Reset=1;
        pvPut(T1_Pump_Error_Reset);
        T2_Pump_Error_Reset=1;
        pvPut(T2_Pump_Error_Reset);
        T3_Pump_Error_Reset=1;
        pvPut(T3_Pump_Error_Reset);
        T4_Pump_Error_Reset=1;
        pvPut(T4_Pump_Error_Reset);
        T5_Pump_Error_Reset=1;
        pvPut(T5_Pump_Error_Reset);
        /* Temperature Sensors */
        T0_Temperature_Reset_Cmd=1;
        pvPut(T0_Temperature_Reset_Cmd);
        T1_Temperature_Reset_Cmd=1;
        pvPut(T1_Temperature_Reset_Cmd);
        T2_Temperature_Reset_Cmd=1;
        pvPut(T2_Temperature_Reset_Cmd);
        T3_Temperature_Reset_Cmd=1;
        pvPut(T3_Temperature_Reset_Cmd);
        T4_Temperature_Reset_Cmd=1;
        pvPut(T4_Temperature_Reset_Cmd);
        T5_Temperature_Reset_Cmd=1;
        pvPut(T5_Temperature_Reset_Cmd);
        /* Flux Sensors */
        T0_Flux_Reset_Cmd=1;
        pvPut(T0_Flux_Reset_Cmd);
        T1_Flux_Reset_Cmd=1;
        pvPut(T1_Flux_Reset_Cmd);
        T2_Flux_Reset_Cmd=1;
        pvPut(T2_Flux_Reset_Cmd);
        T3_Flux_Reset_Cmd=1;
        pvPut(T3_Flux_Reset_Cmd);
        T4_Flux_Reset_Cmd=1;
        pvPut(T4_Flux_Reset_Cmd);
        T5_Flux_Reset_Cmd=1;
        pvPut(T5_Flux_Reset_Cmd);
        /* Pressure Sensors */
        T0_Pressure_1_Reset_Cmd=1;
        pvPut(T0_Pressure_1_Reset_Cmd);
        T0_Pressure_2_Reset_Cmd=1;
        pvPut(T0_Pressure_2_Reset_Cmd);
        T1_Pressure_1_Reset_Cmd=1;
        pvPut(T1_Pressure_1_Reset_Cmd);
        T1_Pressure_2_Reset_Cmd=1;
        pvPut(T1_Pressure_2_Reset_Cmd);
        T2_Pressure_1_Reset_Cmd=1;
        pvPut(T2_Pressure_1_Reset_Cmd);
        T2_Pressure_2_Reset_Cmd=1;
        pvPut(T2_Pressure_2_Reset_Cmd);
        T3_Pressure_1_Reset_Cmd=1;
        pvPut(T3_Pressure_1_Reset_Cmd);
        T3_Pressure_2_Reset_Cmd=1;
        pvPut(T3_Pressure_2_Reset_Cmd);
        T4_Pressure_1_Reset_Cmd=1;
        pvPut(T4_Pressure_1_Reset_Cmd);
        T4_Pressure_2_Reset_Cmd=1;
        pvPut(T4_Pressure_2_Reset_Cmd);
        T5_Pressure_1_Reset_Cmd=1;
        pvPut(T5_Pressure_1_Reset_Cmd);
        T5_Pressure_2_Reset_Cmd=1;
        pvPut(T5_Pressure_2_Reset_Cmd);
        /* YSV Valves */
        T0_Valve_1_Error_Reset=1;
        pvPut(T0_Valve_1_Error_Reset);
        T0_Valve_2_Error_Reset=1;
        pvPut(T0_Valve_2_Error_Reset);
        /* TCV Valves */
        T0_Valve_1_Error_Reset=1;
        pvPut(T0_Valve_1_Error_Reset);
        T1_Valve_1_Error_Reset=1;
        pvPut(T1_Valve_1_Error_Reset);
        T2_Valve_1_Error_Reset=1;
        pvPut(T2_Valve_1_Error_Reset);
        T3_Valve_1_Error_Reset=1;
        pvPut(T3_Valve_1_Error_Reset);
        T4_Valve_1_Error_Reset=1;
        pvPut(T4_Valve_1_Error_Reset);
        T5_Valve_1_Error_Reset=1;
        pvPut(T5_Valve_1_Error_Reset);

        /* restore reset command */   /* TO CHECK IF TOGGLE OR NOT */
        /* Pumps */
        T0_Pump_Error_Reset=0;
        pvPut(T0_Pump_Error_Reset);
        T1_Pump_Error_Reset=0;
        pvPut(T1_Pump_Error_Reset);
        T2_Pump_Error_Reset=0;
        pvPut(T2_Pump_Error_Reset);
        T3_Pump_Error_Reset=0;
        pvPut(T3_Pump_Error_Reset);
        T4_Pump_Error_Reset=0;
        pvPut(T4_Pump_Error_Reset);
        T5_Pump_Error_Reset=0;
        pvPut(T5_Pump_Error_Reset);
        /* Temperature Sensors */
        T0_Temperature_Reset_Cmd=0;
        pvPut(T0_Temperature_Reset_Cmd);
        T1_Temperature_Reset_Cmd=0;
        pvPut(T1_Temperature_Reset_Cmd);
        T2_Temperature_Reset_Cmd=0;
        pvPut(T2_Temperature_Reset_Cmd);
        T3_Temperature_Reset_Cmd=0;
        pvPut(T3_Temperature_Reset_Cmd);
        T4_Temperature_Reset_Cmd=0;
        pvPut(T4_Temperature_Reset_Cmd);
        T5_Temperature_Reset_Cmd=0;
        pvPut(T5_Temperature_Reset_Cmd);
        /* Flux Sensors */
        T0_Flux_Reset_Cmd=0;
        pvPut(T0_Flux_Reset_Cmd);
        T1_Flux_Reset_Cmd=0;
        pvPut(T1_Flux_Reset_Cmd);
        T2_Flux_Reset_Cmd=0;
        pvPut(T2_Flux_Reset_Cmd);
        T3_Flux_Reset_Cmd=0;
        pvPut(T3_Flux_Reset_Cmd);
        T4_Flux_Reset_Cmd=0;
        pvPut(T4_Flux_Reset_Cmd);
        T5_Flux_Reset_Cmd=0;
        pvPut(T5_Flux_Reset_Cmd);
        /* Pressure Sensors */
        T0_Pressure_1_Reset_Cmd=0;
        pvPut(T0_Pressure_1_Reset_Cmd);
        T0_Pressure_2_Reset_Cmd=0;
        pvPut(T0_Pressure_2_Reset_Cmd);
        T1_Pressure_1_Reset_Cmd=0;
        pvPut(T1_Pressure_1_Reset_Cmd);
        T1_Pressure_2_Reset_Cmd=0;
        pvPut(T1_Pressure_2_Reset_Cmd);
        T2_Pressure_1_Reset_Cmd=0;
        pvPut(T2_Pressure_1_Reset_Cmd);
        T2_Pressure_2_Reset_Cmd=0;
        pvPut(T2_Pressure_2_Reset_Cmd);
        T3_Pressure_1_Reset_Cmd=0;
        pvPut(T3_Pressure_1_Reset_Cmd);
        T3_Pressure_2_Reset_Cmd=0;
        pvPut(T3_Pressure_2_Reset_Cmd);
        T4_Pressure_1_Reset_Cmd=0;
        pvPut(T4_Pressure_1_Reset_Cmd);
        T4_Pressure_2_Reset_Cmd=0;
        pvPut(T4_Pressure_2_Reset_Cmd);
        T5_Pressure_1_Reset_Cmd=0;
        pvPut(T5_Pressure_1_Reset_Cmd);
        T5_Pressure_2_Reset_Cmd=0;
        pvPut(T5_Pressure_2_Reset_Cmd);
        /* YSV Valves */
        T0_Valve_1_Error_Reset=0;
        pvPut(T0_Valve_1_Error_Reset);
        T0_Valve_2_Error_Reset=0;
        pvPut(T0_Valve_2_Error_Reset);
        /* TCV Valves */
        T0_Valve_1_Error_Reset=0;
        pvPut(T0_Valve_1_Error_Reset);
        T1_Valve_1_Error_Reset=0;
        pvPut(T1_Valve_1_Error_Reset);
        T2_Valve_1_Error_Reset=0;
        pvPut(T2_Valve_1_Error_Reset);
        T3_Valve_1_Error_Reset=0;
        pvPut(T3_Valve_1_Error_Reset);
        T4_Valve_1_Error_Reset=0;
        pvPut(T4_Valve_1_Error_Reset);
        T5_Valve_1_Error_Reset=0;
        pvPut(T5_Valve_1_Error_Reset);

        /* Disable Pumps */
        printf("[SEQ COOLING] Preliminary Disable Pumps \n");
        T0_Pump_Enable_Cmd=0;
        pvPut(T0_Pump_Enable_Cmd);
        T1_Pump_Enable_Cmd=0;
        pvPut(T1_Pump_Enable_Cmd);
        T2_Pump_Enable_Cmd=0;
        pvPut(T2_Pump_Enable_Cmd);
        T3_Pump_Enable_Cmd=0;
        pvPut(T3_Pump_Enable_Cmd);
        T4_Pump_Enable_Cmd=0;
        pvPut(T4_Pump_Enable_Cmd);
        T5_Pump_Enable_Cmd=0;
        pvPut(T5_Pump_Enable_Cmd);

        /* Disable Valves */
        printf("[SEQ COOLING] Preliminary Disable YSV valves. \n");
        T0_Valve_1_Enable_Cmd=0;
        pvPut(T0_Valve_1_Enable_Cmd);
        T0_Valve_2_Enable_Cmd=0;
        pvPut(T0_Valve_2_Enable_Cmd);
        printf("[SEQ COOLING] Preliminary Disable TCV valves. \n");
        T0_Valve_1_Enable_Cmd=0;
        pvPut(T0_Valve_1_Enable_Cmd);
        T1_Valve_1_Enable_Cmd=0;
        pvPut(T1_Valve_1_Enable_Cmd);
        T2_Valve_1_Enable_Cmd=0;
        pvPut(T2_Valve_1_Enable_Cmd);
        T3_Valve_1_Enable_Cmd=0;
        pvPut(T3_Valve_1_Enable_Cmd);
        T4_Valve_1_Enable_Cmd=0;
        pvPut(T4_Valve_1_Enable_Cmd);
        T5_Valve_1_Enable_Cmd=0;
        pvPut(T5_Valve_1_Enable_Cmd);

      }

      /* Error: Temperature sensors status not ok */
      when ( (T0_Temperature_Status == 0) || (T1_Temperature_Status == 0) || (T2_Temperature_Status == 0) || (T3_Temperature_Status == 0) || (T4_Temperature_Status == 0) || (T5_Temperature_Status == 0) ) {
        printf("[SEQ COOLING] Error in temperature sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Temperature sensors interlock status not ok */
      when ( ((T0_Temperature_Ilk_Status == 0) && (T0_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T1_Temperature_Ilk_Status == 0) && (T1_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T2_Temperature_Ilk_Status == 0) && (T2_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T3_Temperature_Ilk_Status == 0) && (T3_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T4_Temperature_Ilk_Status == 0) && (T4_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T5_Temperature_Ilk_Status == 0) && (T5_Temperature_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in temperature sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Flux sensors status not ok */
      when ( T0_Flux_Status == 0) || (T1_Flux_Status == 0) || (T2_Flux_Status == 0) || (T3_Flux_Status == 0) || (T4_Flux_Status == 0) || (T5_Flux_Status == 0) ) {
        printf("[SEQ COOLING] Error in flux sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Flux sensors interlock status not ok */
      when ( ((T0_Flux_Ilk_Status == 0) && (T0_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T1_Flux_Ilk_Status == 0) && (T1_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T2_Flux_Ilk_Status == 0) && (T2_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T3_Flux_Ilk_Status == 0) && (T3_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T4_Flux_Ilk_Status == 0) && (T4_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T5_Flux_Ilk_Status == 0) && (T5_Flux_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in flux sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pressure sensors status not ok  */
      when ( (T0_Pressure_1_Status == 0) || (T0_Pressure_2_Status == 0) || (T1_Pressure_1_Status == 0) || (T1_Pressure_2_Status == 0) || (T2_Pressure_1_Status == 0) || (T2_Pressure_2_Status == 0) || (T3_Pressure_1_Status == 0) || (T3_Pressure_2_Status == 0) || (T4_Pressure_1_Status == 0) || (T4_Pressure_2_Status == 0) || (T5_Pressure_1_Status == 0) || (T5_Pressure_2_Status == 0) ) {
        printf("[SEQ COOLING] Error in pressure sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pressure sensors interlock status not ok  */
      when ( ((T0_Pressure_1_Ilk_Status == 0) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T0_Pressure_2_Ilk_Status == 0) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T1_Pressure_1_Ilk_Status == 0) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T1_Pressure_2_Ilk_Status == 0) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T2_Pressure_1_Ilk_Status == 0) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T2_Pressure_2_Ilk_Status == 0) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T3_Pressure_1_Ilk_Status == 0) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T3_Pressure_2_Ilk_Status == 0) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T4_Pressure_1_Ilk_Status == 0) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T4_Pressure_2_Ilk_Status == 0) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T5_Pressure_1_Ilk_Status == 0) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T5_Pressure_2_Ilk_Status == 0) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in pressure sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps general status not ok  */
      when ( (T0_Pump_General_Ok_Status == 0) || (T1_Pump_General_Ok_Status == 0) || (T2_Pump_General_Ok_Status == 0) || (T3_Pump_General_Ok_Status == 0) || (T4_Pump_General_Ok_Status == 0) || (T5_Pump_General_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - general status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps FC status not ok  */
      when ( (T0_Pump_FC_Ok_Status == 0) || (T1_Pump_FC_Ok_Status == 0) || (T2_Pump_FC_Ok_Status == 0) || (T3_Pump_FC_Ok_Status == 0) || (T4_Pump_FC_Ok_Status == 0) || (T5_Pump_FC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - FC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps LFC status not ok  */
      when ( (T0_Pump_LFC_Ok_Status == 0) || (T1_Pump_LFC_Ok_Status == 0) || (T2_Pump_LFC_Ok_Status == 0) || (T3_Pump_LFC_Ok_Status == 0) || (T4_Pump_LFC_Ok_Status == 0) || (T5_Pump_LFC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - LFC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps LPIC status not ok  */
      when ( (T0_Pump_LPIC_Ok_Status == 0) || (T1_Pump_LPIC_Ok_Status == 0) || (T2_Pump_LPIC_Ok_Status == 0) || (T3_Pump_LPIC_Ok_Status == 0) || (T4_Pump_LPIC_Ok_Status == 0) || (T5_Pump_LPIC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - LPIC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps Ilck status not ok  */
      when ( (T0_Pump_Ilck_Ok_Status == 0) || (T1_Pump_Ilck_Ok_Status == 0) || (T2_Pump_Ilck_Ok_Status == 0) || (T3_Pump_Ilck_Ok_Status == 0) || (T4_Pump_Ilck_Ok_Status == 0) || (T5_Pump_Ilck_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - Ilck status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: YSV valves status not ok  */
      when ( (T0_Valve_1_Ok_Stat == 0) || (T0_Valve_2_Ok_Stat == 0) ) {
        printf("[SEQ COOLING] Error in YSV valves: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: TCV valves general status not ok  */
      when ( (T0_Valve_1_General_Status == 0) || (T1_Valve_1_General_Status == 0) || (T2_Valve_1_General_Status == 0) || (T3_Valve_1_General_Status == 0) || (T4_Valve_1_General_Status == 0) || (T5_Valve_1_General_Status == 0) ) {
        printf("[SEQ COOLING] Error in TCV valves - general status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: TCV valves interlock status not ok  */
      when ( (T0_Valve_1_Ilck_Status == 0) || (T1_Valve_1_Ilck_Status == 0) || (T2_Valve_1_Ilck_Status == 0) || (T3_Valve_1_Ilck_Status == 0) || (T4_Valve_1_Ilck_Status == 0) || (T5_Valve_1_Ilck_Status == 0) ) {
        printf("[SEQ COOLING] Error in TCV valves - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Lost remote connection to PLC */
      when (PLC_Message != -188) {
        printf("[SEQ COOLING] Communication to PLC not in Remote: one or more events modified communication status\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state initialization

      /* No error in any device (and in remote communication) */
      when( (PLC_Message == -188) && (T0_Temperature_Status == 1) && (T1_Temperature_Status == 1) && (T2_Temperature_Status == 1) && (T3_Temperature_Status == 1) && (T4_Temperature_Status == 1) && (T5_Temperature_Status == 1) && ((T0_Temperature_Ilk_Status == 1) && (T0_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T1_Temperature_Ilk_Status == 1) && (T1_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T2_Temperature_Ilk_Status == 1) && (T2_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T3_Temperature_Ilk_Status == 1) && (T3_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T4_Temperature_Ilk_Status == 1) && (T4_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T5_Temperature_Ilk_Status == 1) && (T5_Temperature_Ilk_Enable_Cmd_RB == 1)) && ( T0_Flux_Status == 1) && (T1_Flux_Status == 1) && (T2_Flux_Status == 1) && (T3_Flux_Status == 1) && (T4_Flux_Status == 1) && (T5_Flux_Status == 1) && ((T0_Flux_Ilk_Status == 1) && (T0_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T1_Flux_Ilk_Status == 1) && (T1_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T2_Flux_Ilk_Status == 1) && (T2_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T3_Flux_Ilk_Status == 1) && (T3_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T4_Flux_Ilk_Status == 1) && (T4_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T5_Flux_Ilk_Status == 1) && (T5_Flux_Ilk_Enable_Cmd_RB == 1)) && (T0_Pressure_1_Status == 1) && (T0_Pressure_2_Status == 1) && (T1_Pressure_1_Status == 1) && (T1_Pressure_2_Status == 1) && (T2_Pressure_1_Status == 1) && (T2_Pressure_2_Status == 1) && (T3_Pressure_1_Status == 1) && (T3_Pressure_2_Status == 1) && (T4_Pressure_1_Status == 1) && (T4_Pressure_2_Status == 1) && (T5_Pressure_1_Status == 1) && (T5_Pressure_2_Status == 1) && ((T0_Pressure_1_Ilk_Status == 1) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T0_Pressure_2_Ilk_Status == 1) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T1_Pressure_1_Ilk_Status == 1) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T1_Pressure_2_Ilk_Status == 1) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T2_Pressure_1_Ilk_Status == 1) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T2_Pressure_2_Ilk_Status == 1) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T3_Pressure_1_Ilk_Status == 1) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T3_Pressure_2_Ilk_Status == 1) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T4_Pressure_1_Ilk_Status == 1) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T4_Pressure_2_Ilk_Status == 1) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T5_Pressure_1_Ilk_Status == 1) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T5_Pressure_2_Ilk_Status == 1) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && (T0_Pump_General_Ok_Status == 1) && (T1_Pump_General_Ok_Status == 1) && (T2_Pump_General_Ok_Status == 1) && (T3_Pump_General_Ok_Status == 1) && (T4_Pump_General_Ok_Status == 1) && (T5_Pump_General_Ok_Status == 1) && (T0_Pump_FC_Ok_Status == 1) && (T1_Pump_FC_Ok_Status == 1) && (T2_Pump_FC_Ok_Status == 1) && (T3_Pump_FC_Ok_Status == 1) && (T4_Pump_FC_Ok_Status == 1) && (T5_Pump_FC_Ok_Status == 1) && (T0_Pump_LFC_Ok_Status == 1) && (T1_Pump_LFC_Ok_Status == 1) && (T2_Pump_LFC_Ok_Status == 1) && (T3_Pump_LFC_Ok_Status == 1) && (T4_Pump_LFC_Ok_Status == 1) && (T5_Pump_LFC_Ok_Status == 1) && (T0_Pump_LPIC_Ok_Status == 1) && (T1_Pump_LPIC_Ok_Status == 1) && (T2_Pump_LPIC_Ok_Status == 1) && (T3_Pump_LPIC_Ok_Status == 1) && (T4_Pump_LPIC_Ok_Status == 1) && (T5_Pump_LPIC_Ok_Status == 1) && (T0_Pump_Ilck_Ok_Status == 1) && (T1_Pump_Ilck_Ok_Status == 1) && (T2_Pump_Ilck_Ok_Status == 1) && (T3_Pump_Ilck_Ok_Status == 1) && (T4_Pump_Ilck_Ok_Status == 1) && (T5_Pump_Ilck_Ok_Status == 1) && (T0_Valve_1_Ok_Stat == 1) && (T0_Valve_2_Ok_Stat == 1) && (T0_Valve_1_General_Status == 1) && (T1_Valve_1_General_Status == 1) && (T2_Valve_1_General_Status == 1) && (T3_Valve_1_General_Status == 1) && (T4_Valve_1_General_Status == 1) && (T5_Valve_1_General_Status == 1) && (T0_Valve_1_Ilck_Status == 1) && (T1_Valve_1_Ilck_Status == 1) && (T2_Valve_1_Ilck_Status == 1) && (T3_Valve_1_Ilck_Status == 1) && (T4_Valve_1_Ilck_Status == 1) && (T5_Valve_1_Ilck_Status == 1) ) {
          printf("[SEQ COOLING] Self Check Passed. \n");


    } state idle

  }


/* state IDLE   	*/
  state idle {
    entry {
      printf("\n[SEQ COOLING] Enter in IDLE status\n");
      StateMachineCode=20;
      pvPut(StateMachineCode);

      StopOperationCmd=0;
      pvPut(StopOperationCmd);
    }

    /* Error: Temperature sensors status not ok */
    when ( (T0_Temperature_Status == 0) || (T1_Temperature_Status == 0) || (T2_Temperature_Status == 0) || (T3_Temperature_Status == 0) || (T4_Temperature_Status == 0) || (T5_Temperature_Status == 0) ) {
      printf("[SEQ COOLING] Error in temperature sensors: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Temperature sensors interlock status not ok */
    when ( ((T0_Temperature_Ilk_Status == 0) && (T0_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T1_Temperature_Ilk_Status == 0) && (T1_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T2_Temperature_Ilk_Status == 0) && (T2_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T3_Temperature_Ilk_Status == 0) && (T3_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T4_Temperature_Ilk_Status == 0) && (T4_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T5_Temperature_Ilk_Status == 0) && (T5_Temperature_Ilk_Enable_Cmd_RB == 0)) ) {
      printf("[SEQ COOLING] Error in temperature sensors - interlock status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Flux sensors status not ok */
    when ( T0_Flux_Status == 0) || (T1_Flux_Status == 0) || (T2_Flux_Status == 0) || (T3_Flux_Status == 0) || (T4_Flux_Status == 0) || (T5_Flux_Status == 0) ) {
      printf("[SEQ COOLING] Error in flux sensors: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Flux sensors interlock status not ok */
    when ( ((T0_Flux_Ilk_Status == 0) && (T0_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T1_Flux_Ilk_Status == 0) && (T1_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T2_Flux_Ilk_Status == 0) && (T2_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T3_Flux_Ilk_Status == 0) && (T3_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T4_Flux_Ilk_Status == 0) && (T4_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T5_Flux_Ilk_Status == 0) && (T5_Flux_Ilk_Enable_Cmd_RB == 0)) ) {
      printf("[SEQ COOLING] Error in flux sensors - interlock status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pressure sensors status not ok  */
    when ( (T0_Pressure_1_Status == 0) || (T0_Pressure_2_Status == 0) || (T1_Pressure_1_Status == 0) || (T1_Pressure_2_Status == 0) || (T2_Pressure_1_Status == 0) || (T2_Pressure_2_Status == 0) || (T3_Pressure_1_Status == 0) || (T3_Pressure_2_Status == 0) || (T4_Pressure_1_Status == 0) || (T4_Pressure_2_Status == 0) || (T5_Pressure_1_Status == 0) || (T5_Pressure_2_Status == 0) ) {
      printf("[SEQ COOLING] Error in pressure sensors: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pressure sensors interlock status not ok  */
    when ( ((T0_Pressure_1_Ilk_Status == 0) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T0_Pressure_2_Ilk_Status == 0) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T1_Pressure_1_Ilk_Status == 0) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T1_Pressure_2_Ilk_Status == 0) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T2_Pressure_1_Ilk_Status == 0) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T2_Pressure_2_Ilk_Status == 0) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T3_Pressure_1_Ilk_Status == 0) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T3_Pressure_2_Ilk_Status == 0) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T4_Pressure_1_Ilk_Status == 0) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T4_Pressure_2_Ilk_Status == 0) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T5_Pressure_1_Ilk_Status == 0) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T5_Pressure_2_Ilk_Status == 0) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 0)) ) {
      printf("[SEQ COOLING] Error in pressure sensors - interlock status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pumps general status not ok  */
    when ( (T0_Pump_General_Ok_Status == 0) || (T1_Pump_General_Ok_Status == 0) || (T2_Pump_General_Ok_Status == 0) || (T3_Pump_General_Ok_Status == 0) || (T4_Pump_General_Ok_Status == 0) || (T5_Pump_General_Ok_Status == 0) ) {
      printf("[SEQ COOLING] Error in pumps - general status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pumps FC status not ok  */
    when ( (T0_Pump_FC_Ok_Status == 0) || (T1_Pump_FC_Ok_Status == 0) || (T2_Pump_FC_Ok_Status == 0) || (T3_Pump_FC_Ok_Status == 0) || (T4_Pump_FC_Ok_Status == 0) || (T5_Pump_FC_Ok_Status == 0) ) {
      printf("[SEQ COOLING] Error in pumps - FC status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pumps LFC status not ok  */
    when ( (T0_Pump_LFC_Ok_Status == 0) || (T1_Pump_LFC_Ok_Status == 0) || (T2_Pump_LFC_Ok_Status == 0) || (T3_Pump_LFC_Ok_Status == 0) || (T4_Pump_LFC_Ok_Status == 0) || (T5_Pump_LFC_Ok_Status == 0) ) {
      printf("[SEQ COOLING] Error in pumps - LFC status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pumps LPIC status not ok  */
    when ( (T0_Pump_LPIC_Ok_Status == 0) || (T1_Pump_LPIC_Ok_Status == 0) || (T2_Pump_LPIC_Ok_Status == 0) || (T3_Pump_LPIC_Ok_Status == 0) || (T4_Pump_LPIC_Ok_Status == 0) || (T5_Pump_LPIC_Ok_Status == 0) ) {
      printf("[SEQ COOLING] Error in pumps - LPIC status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: Pumps Ilck status not ok  */
    when ( (T0_Pump_Ilck_Ok_Status == 0) || (T1_Pump_Ilck_Ok_Status == 0) || (T2_Pump_Ilck_Ok_Status == 0) || (T3_Pump_Ilck_Ok_Status == 0) || (T4_Pump_Ilck_Ok_Status == 0) || (T5_Pump_Ilck_Ok_Status == 0) ) {
      printf("[SEQ COOLING] Error in pumps - Ilck status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: YSV valves status not ok  */
    when ( (T0_Valve_1_Ok_Stat == 0) || (T0_Valve_2_Ok_Stat == 0) ) {
      printf("[SEQ COOLING] Error in YSV valves: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: TCV valves general status not ok  */
    when ( (T0_Valve_1_General_Status == 0) || (T1_Valve_1_General_Status == 0) || (T2_Valve_1_General_Status == 0) || (T3_Valve_1_General_Status == 0) || (T4_Valve_1_General_Status == 0) || (T5_Valve_1_General_Status == 0) ) {
      printf("[SEQ COOLING] Error in TCV valves - general status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Error: TCV valves interlock status not ok  */
    when ( (T0_Valve_1_Ilck_Status == 0) || (T1_Valve_1_Ilck_Status == 0) || (T2_Valve_1_Ilck_Status == 0) || (T3_Valve_1_Ilck_Status == 0) || (T4_Valve_1_Ilck_Status == 0) || (T5_Valve_1_Ilck_Status == 0) ) {
      printf("[SEQ COOLING] Error in TCV valves - interlock status: one or more devices are not ok\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state failure

    /* Lost remote connection to PLC */
    when (PLC_Message != -188) {
      printf("[SEQ COOLING] Communication to PLC not in Remote: one or more events modified communication status\n");
      printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
    } state initialization


    /* Execute chosen configuration [man|auto] */
    when ( (PLC_Message == -188) && (StartOperationCmd == 1) ) {
        if ( (AutoControl_ActualStatus == 0) && (AutoControl_ActualStatus == AutoControlCmd) ) {
          printf("[SEQ COOLING] Start Control Operations in MANUAL Mode\n");
        }
        else if ( (AutoControl_ActualStatus == 1) && (AutoControl_ActualStatus == AutoControlCmd) ) {
          printf("[SEQ COOLING] Start Control Operations in AUTOMATIC Mode\n");
        }
        else if ( (AutoControl_ActualStatus == 1) && (AutoControl_ActualStatus != AutoControlCmd) ) {
          printf("[SEQ COOLING] Updated control configuration\n");
          printf("[SEQ COOLING] Start Control Operations in MANUAL Mode\n");
          AutoControl_ActualStatus = AutoControlCmd;
          pvPut(AutoControl_ActualStatus);
        }
        else if ( (AutoControl_ActualStatus == 0) && (AutoControl_ActualStatus != AutoControlCmd) ) {
          printf("[SEQ COOLING] Updated control configuration\n");
          printf("[SEQ COOLING] Start Control Operations in AUTOMATIC Mode\n");
          AutoControl_ActualStatus = AutoControlCmd;
          pvPut(AutoControl_ActualStatus);
        }
        else {
          printf("[SEQ COOLING] This message should not appear :)\n");
        }

    } state start_up
  }



/* state STARTUP	*/
state start_up {

  entry {
    printf("\n[SEQ COOLING] Enter in START UP status\n");
    StateMachineCode=30;
    pvPut(StateMachineCode);
  }

  /* Error: Temperature sensors status not ok */
  when ( (T0_Temperature_Status == 0) || (T1_Temperature_Status == 0) || (T2_Temperature_Status == 0) || (T3_Temperature_Status == 0) || (T4_Temperature_Status == 0) || (T5_Temperature_Status == 0) ) {
    printf("[SEQ COOLING] Error in temperature sensors: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Temperature sensors interlock status not ok */
  when ( ((T0_Temperature_Ilk_Status == 0) && (T0_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T1_Temperature_Ilk_Status == 0) && (T1_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T2_Temperature_Ilk_Status == 0) && (T2_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T3_Temperature_Ilk_Status == 0) && (T3_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T4_Temperature_Ilk_Status == 0) && (T4_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T5_Temperature_Ilk_Status == 0) && (T5_Temperature_Ilk_Enable_Cmd_RB == 0)) ) {
    printf("[SEQ COOLING] Error in temperature sensors - interlock status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Flux sensors status not ok */
  when ( T0_Flux_Status == 0) || (T1_Flux_Status == 0) || (T2_Flux_Status == 0) || (T3_Flux_Status == 0) || (T4_Flux_Status == 0) || (T5_Flux_Status == 0) ) {
    printf("[SEQ COOLING] Error in flux sensors: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Flux sensors interlock status not ok */
  when ( ((T0_Flux_Ilk_Status == 0) && (T0_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T1_Flux_Ilk_Status == 0) && (T1_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T2_Flux_Ilk_Status == 0) && (T2_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T3_Flux_Ilk_Status == 0) && (T3_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T4_Flux_Ilk_Status == 0) && (T4_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T5_Flux_Ilk_Status == 0) && (T5_Flux_Ilk_Enable_Cmd_RB == 0)) ) {
    printf("[SEQ COOLING] Error in flux sensors - interlock status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pressure sensors status not ok  */
  when ( (T0_Pressure_1_Status == 0) || (T0_Pressure_2_Status == 0) || (T1_Pressure_1_Status == 0) || (T1_Pressure_2_Status == 0) || (T2_Pressure_1_Status == 0) || (T2_Pressure_2_Status == 0) || (T3_Pressure_1_Status == 0) || (T3_Pressure_2_Status == 0) || (T4_Pressure_1_Status == 0) || (T4_Pressure_2_Status == 0) || (T5_Pressure_1_Status == 0) || (T5_Pressure_2_Status == 0) ) {
    printf("[SEQ COOLING] Error in pressure sensors: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pressure sensors interlock status not ok  */
  when ( ((T0_Pressure_1_Ilk_Status == 0) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T0_Pressure_2_Ilk_Status == 0) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T1_Pressure_1_Ilk_Status == 0) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T1_Pressure_2_Ilk_Status == 0) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T2_Pressure_1_Ilk_Status == 0) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T2_Pressure_2_Ilk_Status == 0) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T3_Pressure_1_Ilk_Status == 0) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T3_Pressure_2_Ilk_Status == 0) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T4_Pressure_1_Ilk_Status == 0) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T4_Pressure_2_Ilk_Status == 0) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T5_Pressure_1_Ilk_Status == 0) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T5_Pressure_2_Ilk_Status == 0) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 0)) ) {
    printf("[SEQ COOLING] Error in pressure sensors - interlock status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pumps general status not ok  */
  when ( (T0_Pump_General_Ok_Status == 0) || (T1_Pump_General_Ok_Status == 0) || (T2_Pump_General_Ok_Status == 0) || (T3_Pump_General_Ok_Status == 0) || (T4_Pump_General_Ok_Status == 0) || (T5_Pump_General_Ok_Status == 0) ) {
    printf("[SEQ COOLING] Error in pumps - general status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pumps FC status not ok  */
  when ( (T0_Pump_FC_Ok_Status == 0) || (T1_Pump_FC_Ok_Status == 0) || (T2_Pump_FC_Ok_Status == 0) || (T3_Pump_FC_Ok_Status == 0) || (T4_Pump_FC_Ok_Status == 0) || (T5_Pump_FC_Ok_Status == 0) ) {
    printf("[SEQ COOLING] Error in pumps - FC status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pumps LFC status not ok  */
  when ( (T0_Pump_LFC_Ok_Status == 0) || (T1_Pump_LFC_Ok_Status == 0) || (T2_Pump_LFC_Ok_Status == 0) || (T3_Pump_LFC_Ok_Status == 0) || (T4_Pump_LFC_Ok_Status == 0) || (T5_Pump_LFC_Ok_Status == 0) ) {
    printf("[SEQ COOLING] Error in pumps - LFC status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pumps LPIC status not ok  */
  when ( (T0_Pump_LPIC_Ok_Status == 0) || (T1_Pump_LPIC_Ok_Status == 0) || (T2_Pump_LPIC_Ok_Status == 0) || (T3_Pump_LPIC_Ok_Status == 0) || (T4_Pump_LPIC_Ok_Status == 0) || (T5_Pump_LPIC_Ok_Status == 0) ) {
    printf("[SEQ COOLING] Error in pumps - LPIC status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: Pumps Ilck status not ok  */
  when ( (T0_Pump_Ilck_Ok_Status == 0) || (T1_Pump_Ilck_Ok_Status == 0) || (T2_Pump_Ilck_Ok_Status == 0) || (T3_Pump_Ilck_Ok_Status == 0) || (T4_Pump_Ilck_Ok_Status == 0) || (T5_Pump_Ilck_Ok_Status == 0) ) {
    printf("[SEQ COOLING] Error in pumps - Ilck status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: YSV valves status not ok  */
  when ( (T0_Valve_1_Ok_Stat == 0) || (T0_Valve_2_Ok_Stat == 0) ) {
    printf("[SEQ COOLING] Error in YSV valves: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: TCV valves general status not ok  */
  when ( (T0_Valve_1_General_Status == 0) || (T1_Valve_1_General_Status == 0) || (T2_Valve_1_General_Status == 0) || (T3_Valve_1_General_Status == 0) || (T4_Valve_1_General_Status == 0) || (T5_Valve_1_General_Status == 0) ) {
    printf("[SEQ COOLING] Error in TCV valves - general status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Error: TCV valves interlock status not ok  */
  when ( (T0_Valve_1_Ilck_Status == 0) || (T1_Valve_1_Ilck_Status == 0) || (T2_Valve_1_Ilck_Status == 0) || (T3_Valve_1_Ilck_Status == 0) || (T4_Valve_1_Ilck_Status == 0) || (T5_Valve_1_Ilck_Status == 0) ) {
    printf("[SEQ COOLING] Error in TCV valves - interlock status: one or more devices are not ok\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state failure

  /* Lost remote connection to PLC */
  when (PLC_Message != -188) {
    printf("[SEQ COOLING] Communication to PLC not in Remote: one or more events modified communication status\n");
    printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
  } state initialization

  /* Possibility to modify [MAN|AUTO] control during operations without changing state*/
  when ( AutoControl_ActualStatus != AutoControlCmd ) {
      AutoControl_ActualStatus = AutoControlCmd;
      pvPut(AutoControl_ActualStatus);
      if ( AutoControl_ActualStatus == 0 ) {
        printf("[SEQ COOLING] Control Configuration changed to MANUAL .\n");
      }
      else if ( AutoControl_ActualStatus == 1 ) {
        printf("[SEQ COOLING] Control Configuration changed to AUTOMATIC.\n");
      }
  } state start_up

  /* Stop Operation (for every mode of operation) */
  when ( StopOperationCmd == 1 ) {
      printf("[SEQ COOLING] Stop Control Operations. System goes back to Idle Status.\n");
      StartOperationCmd=0;
      pvPut(StartOperationCmd);
  } state idle

  /* Test procedure in manual mode */
	when ( (AutoControl_ActualStatus == 0) && (Manual_Test_Done == 1) ) {
		printf("[SEQ COOLING] Manual Startup Procedure Completed \n");
    Manual_Test_Done=0;
    pvPut(Manual_Test_Done);

	} state internal_check

  /* Pump start-up procedure in auto mode */
  when ( (AutoControl_ActualStatus == 1) && (Manual_Test_Done == 1) ) {
		printf("[SEQ COOLING] Starting Automatic Startup Procedure \n");

    /* enable pumps and reset errors */
    printf("[SEQ COOLING] Enable Pumps \n");
    T0_Pump_Enable_Cmd=1;
    pvPut(T0_Pump_Enable_Cmd);
    T1_Pump_Enable_Cmd=1;
    pvPut(T1_Pump_Enable_Cmd);
    T2_Pump_Enable_Cmd=1;
    pvPut(T2_Pump_Enable_Cmd);
    T3_Pump_Enable_Cmd=1;
    pvPut(T3_Pump_Enable_Cmd);
    T4_Pump_Enable_Cmd=1;
    pvPut(T4_Pump_Enable_Cmd);
    T5_Pump_Enable_Cmd=1;
    pvPut(T5_Pump_Enable_Cmd);

    /* enable valves */
    printf("[SEQ COOLING] Enable YSV valves. \n");
    T0_Valve_1_Enable_Cmd=1;
    pvPut(T0_Valve_1_Enable_Cmd);
    T0_Valve_2_Enable_Cmd=1;
    pvPut(T0_Valve_2_Enable_Cmd);
    printf("[SEQ COOLING] Enable TCV valves. \n");
    T0_Valve_1_Enable_Cmd=1;
    pvPut(T0_Valve_1_Enable_Cmd);
    T1_Valve_1_Enable_Cmd=1;
    pvPut(T1_Valve_1_Enable_Cmd);
    T2_Valve_1_Enable_Cmd=1;
    pvPut(T2_Valve_1_Enable_Cmd);
    T3_Valve_1_Enable_Cmd=1;
    pvPut(T3_Valve_1_Enable_Cmd);
    T4_Valve_1_Enable_Cmd=1;
    pvPut(T4_Valve_1_Enable_Cmd);
    T5_Valve_1_Enable_Cmd=1;
    pvPut(T5_Valve_1_Enable_Cmd);

    /* Set TCV valves in Manual */
    printf("[SEQ COOLING] Set TCV valves in manual mode. \n");
    T0_Valve_1_Manual_Cmd=1;
    pvPut(T0_Valve_1_Manual_Cmd);
    T1_Valve_1_Manual_Cmd=1;
    pvPut(T1_Valve_1_Manual_Cmd);
    T2_Valve_1_Manual_Cmd=1;
    pvPut(T2_Valve_1_Manual_Cmd);
    T3_Valve_1_Manual_Cmd=1;
    pvPut(T3_Valve_1_Manual_Cmd);
    T4_Valve_1_Manual_Cmd=1;
    pvPut(T4_Valve_1_Manual_Cmd);
    T5_Valve_1_Manual_Cmd=1;
    pvPut(T5_Valve_1_Manual_Cmd);

    /* Set TCV valves preliminary position */
    printf("[SEQ COOLING] Set TCV valves preliminary position. \n");
    T0_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T0_Valve_1_Manual_Cmd);
    T1_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T1_Valve_1_Manual_Cmd);
    T2_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T2_Valve_1_Manual_Cmd);
    T3_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T3_Valve_1_Manual_Cmd);
    T4_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T4_Valve_1_Manual_Cmd);
    T5_Valve_1_Manual_Position_Cmd=TCV_PRELIMINARY_POS;
    pvPut(T5_Valve_1_Manual_Cmd);

    /* Start Pumps */
    printf("[SEQ COOLING] Start Pumps \n");
    T0_Pump_Start_Cmd=1;
    pvPut(T0_Pump_Start_Cmd);
    sleep(5);
    T1_Pump_Start_Cmd=1;
    pvPut(T1_Pump_Start_Cmd);
    sleep(2);
    T2_Pump_Start_Cmd=1;
    pvPut(T2_Pump_Start_Cmd);
    sleep(2);
    T3_Pump_Start_Cmd=1;
    pvPut(T3_Pump_Start_Cmd);
    sleep(2);
    T4_Pump_Start_Cmd=1;
    pvPut(T4_Pump_Start_Cmd);
    sleep(2);
    T5_Pump_Start_Cmd=1;
    pvPut(T5_Pump_Start_Cmd);
    sleep(2);

    Manual_Test_Done=0;
    pvPut(Manual_Test_Done);

  } state internal_check

}


 /* internal state INTERNAL CHECK */
 state internal_check {

     entry {
       printf("\n[SEQ COOLING] Enter in INTERNAL CHECK status (internal status)\n");

     }

     /* Check if fluxes and pressures are NOT good in manual mode  */
     when ( (AutoControl_ActualStatus == 0) && ( (T0_Flux_Value > MAX_FLUX_CHECK+0.5) || (T0_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T1_Flux_Value > MAX_FLUX_CHECK+0.5) || (T1_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T2_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T2_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T3_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T3_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T4_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T4_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T5_Flux_Value > MAX_FLUX_CHECK+0.5) || (T5_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T0_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T0_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T0_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T0_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T1_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T1_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T1_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T1_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T2_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T2_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T2_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T2_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T3_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T3_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T3_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T3_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T4_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T4_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T4_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T4_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T5_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T5_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T5_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T5_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) ) {
        printf("[SEQ COOLING] Internal Check in Manual Mode: parameters are NOT ok.\n");
        printf("[SEQ COOLING] System not passed internal check: go to STARTUP.\n");

     } state start_up

     /* Check if fluxes and pressures are good in manual mode  */
     when ( (AutoControl_ActualStatus == 0) && ( (T0_Flux_Value < MAX_FLUX_CHECK) && (T0_Flux_Value > MIN_FLUX_CHECK) ) && ( (T1_Flux_Value < MAX_FLUX_CHECK) && (T1_Flux_Value > MIN_FLUX_CHECK) ) && ( (T2_Flux_Value < MAX_FLUX_CHECK) && (T2_Flux_Value > MIN_FLUX_CHECK) ) && ( (T3_Flux_Value < MAX_FLUX_CHECK) && (T3_Flux_Value > MIN_FLUX_CHECK) ) && ( (T4_Flux_Value < MAX_FLUX_CHECK) && (T4_Flux_Value > MIN_FLUX_CHECK) ) && ( (T5_Flux_Value < MAX_FLUX_CHECK) && (T5_Flux_Value > MIN_FLUX_CHECK) ) && ( (T0_Pressure_1_Value < MAX_PRESS_CHECK) && (T0_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T0_Pressure_2_Value < MAX_PRESS_CHECK) && (T0_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T1_Pressure_1_Value < MAX_PRESS_CHECK) && (T1_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T1_Pressure_2_Value < MAX_PRESS_CHECK) && (T1_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T2_Pressure_1_Value < MAX_PRESS_CHECK) && (T2_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T2_Pressure_2_Value < MAX_PRESS_CHECK) && (T2_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T3_Pressure_1_Value < MAX_PRESS_CHECK) && (T3_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T3_Pressure_2_Value < MAX_PRESS_CHECK) && (T3_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T4_Pressure_1_Value < MAX_PRESS_CHECK) && (T4_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T4_Pressure_2_Value < MAX_PRESS_CHECK) && (T4_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T5_Pressure_1_Value < MAX_PRESS_CHECK) && (T5_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T5_Pressure_2_Value < MAX_PRESS_CHECK) && (T5_Pressure_2_Value > MIN_PRESS_CHECK) ) ) {
        printf("[SEQ COOLING] Internal Check in Manual Mode: parameters are ok.\n");
        printf("[SEQ COOLING] System passed internal check: go to READY FOR OPERATION.\n");

     } state ready_for_operation

     /* Check if fluxes and pressures are NOT good in automatic mode  */
     when ( (AutoControl_ActualStatus == 1) && ( (T0_Flux_Value > MAX_FLUX_CHECK+0.5) || (T0_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T1_Flux_Value > MAX_FLUX_CHECK+0.5) || (T1_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T2_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T2_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T3_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T3_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T4_Flux_Value  > MAX_FLUX_CHECK+0.5) || (T4_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T5_Flux_Value > MAX_FLUX_CHECK+0.5) || (T5_Flux_Value < MIX_FLUX_CHECK-0.5) ) && ( (T0_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T0_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T0_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T0_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T1_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T1_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T1_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T1_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T2_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T2_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T2_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T2_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T3_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T3_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T3_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T3_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T4_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T4_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T4_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T4_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) &&  (T5_Pressure_1_Value > MAX_PRESS_CHECK+0.5) || (T5_Pressure_1_Value < MIN_PRESS_CHECK-0.5) ) && ( (T5_Pressure_2_Value > MAX_PRESS_CHECK+0.5) || (T5_Pressure_2_Value < MIN_PRESS_CHECK-0.5) ) ) {
        printf("[SEQ COOLING] Internal Check in Manual Mode: parameters are NOT ok.\n");
        printf("[SEQ COOLING] System not passed internal check: go to STARTUP.\n");

     } state start_up

     /* Check if fluxes and pressures are good in automatic mode  */
     when ( (AutoControl_ActualStatus == 1) && ( (T0_Flux_Value < MAX_FLUX_CHECK) && (T0_Flux_Value > MIN_FLUX_CHECK) ) && ( (T1_Flux_Value < MAX_FLUX_CHECK) && (T1_Flux_Value > MIN_FLUX_CHECK) ) && ( (T2_Flux_Value < MAX_FLUX_CHECK) && (T2_Flux_Value > MIN_FLUX_CHECK) ) && ( (T3_Flux_Value < MAX_FLUX_CHECK) && (T3_Flux_Value > MIN_FLUX_CHECK) ) && ( (T4_Flux_Value < MAX_FLUX_CHECK) && (T4_Flux_Value > MIN_FLUX_CHECK) ) && ( (T5_Flux_Value < MAX_FLUX_CHECK) && (T5_Flux_Value > MIN_FLUX_CHECK) ) && ( (T0_Pressure_1_Value < MAX_PRESS_CHECK) && (T0_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T0_Pressure_2_Value < MAX_PRESS_CHECK) && (T0_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T1_Pressure_1_Value < MAX_PRESS_CHECK) && (T1_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T1_Pressure_2_Value < MAX_PRESS_CHECK) && (T1_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T2_Pressure_1_Value < MAX_PRESS_CHECK) && (T2_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T2_Pressure_2_Value < MAX_PRESS_CHECK) && (T2_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T3_Pressure_1_Value < MAX_PRESS_CHECK) && (T3_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T3_Pressure_2_Value < MAX_PRESS_CHECK) && (T3_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T4_Pressure_1_Value < MAX_PRESS_CHECK) && (T4_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T4_Pressure_2_Value < MAX_PRESS_CHECK) && (T4_Pressure_2_Value > MIN_PRESS_CHECK) ) &&  (T5_Pressure_1_Value < MAX_PRESS_CHECK) && (T5_Pressure_1_Value > MIN_PRESS_CHECK) ) && ( (T5_Pressure_2_Value < MAX_PRESS_CHECK) && (T5_Pressure_2_Value > MIN_PRESS_CHECK) ) ) {
        printf("[SEQ COOLING] Internal Check in Manual Mode: parameters are ok.\n");
        printf("[SEQ COOLING] System passed internal check: go to READY FOR OPERATION.\n");

     } state ready_for_operation

 }


/* state READY_FOR_OPERATION 	*/
  state ready_for_operation {

    entry {
      printf("\n[SEQ COOLING] Enter in READY FOR OPERATION status\n");
      StateMachineCode=40;
      pvPut(StateMachineCode);

      /* Enable Water flow circulation */
      printf("\n[SEQ COOLING] Enable water flow circulation.\n");
       /* ********** */
       /* Conditions */
       /* ********** */

    }

      /* Error: Temperature sensors status not ok */
      when ( (T0_Temperature_Status == 0) || (T1_Temperature_Status == 0) || (T2_Temperature_Status == 0) || (T3_Temperature_Status == 0) || (T4_Temperature_Status == 0) || (T5_Temperature_Status == 0) ) {
        printf("[SEQ COOLING] Error in temperature sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Temperature sensors interlock status not ok */
      when ( ((T0_Temperature_Ilk_Status == 0) && (T0_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T1_Temperature_Ilk_Status == 0) && (T1_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T2_Temperature_Ilk_Status == 0) && (T2_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T3_Temperature_Ilk_Status == 0) && (T3_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T4_Temperature_Ilk_Status == 0) && (T4_Temperature_Ilk_Enable_Cmd_RB == 0)) || ((T5_Temperature_Ilk_Status == 0) && (T5_Temperature_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in temperature sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Flux sensors status not ok */
      when ( T0_Flux_Status == 0) || (T1_Flux_Status == 0) || (T2_Flux_Status == 0) || (T3_Flux_Status == 0) || (T4_Flux_Status == 0) || (T5_Flux_Status == 0) ) {
        printf("[SEQ COOLING] Error in flux sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Flux sensors interlock status not ok */
      when ( ((T0_Flux_Ilk_Status == 0) && (T0_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T1_Flux_Ilk_Status == 0) && (T1_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T2_Flux_Ilk_Status == 0) && (T2_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T3_Flux_Ilk_Status == 0) && (T3_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T4_Flux_Ilk_Status == 0) && (T4_Flux_Ilk_Enable_Cmd_RB == 0)) || ((T5_Flux_Ilk_Status == 0) && (T5_Flux_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in flux sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pressure sensors status not ok  */
      when ( (T0_Pressure_1_Status == 0) || (T0_Pressure_2_Status == 0) || (T1_Pressure_1_Status == 0) || (T1_Pressure_2_Status == 0) || (T2_Pressure_1_Status == 0) || (T2_Pressure_2_Status == 0) || (T3_Pressure_1_Status == 0) || (T3_Pressure_2_Status == 0) || (T4_Pressure_1_Status == 0) || (T4_Pressure_2_Status == 0) || (T5_Pressure_1_Status == 0) || (T5_Pressure_2_Status == 0) ) {
        printf("[SEQ COOLING] Error in pressure sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pressure sensors interlock status not ok  */
      when ( ((T0_Pressure_1_Ilk_Status == 0) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T0_Pressure_2_Ilk_Status == 0) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T1_Pressure_1_Ilk_Status == 0) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T1_Pressure_2_Ilk_Status == 0) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T2_Pressure_1_Ilk_Status == 0) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T2_Pressure_2_Ilk_Status == 0) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T3_Pressure_1_Ilk_Status == 0) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T3_Pressure_2_Ilk_Status == 0) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T4_Pressure_1_Ilk_Status == 0) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T4_Pressure_2_Ilk_Status == 0) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 0)) || ((T5_Pressure_1_Ilk_Status == 0) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 0)) ||  ((T5_Pressure_2_Ilk_Status == 0) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 0)) ) {
        printf("[SEQ COOLING] Error in pressure sensors - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps general status not ok  */
      when ( (T0_Pump_General_Ok_Status == 0) || (T1_Pump_General_Ok_Status == 0) || (T2_Pump_General_Ok_Status == 0) || (T3_Pump_General_Ok_Status == 0) || (T4_Pump_General_Ok_Status == 0) || (T5_Pump_General_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - general status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps FC status not ok  */
      when ( (T0_Pump_FC_Ok_Status == 0) || (T1_Pump_FC_Ok_Status == 0) || (T2_Pump_FC_Ok_Status == 0) || (T3_Pump_FC_Ok_Status == 0) || (T4_Pump_FC_Ok_Status == 0) || (T5_Pump_FC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - FC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps LFC status not ok  */
      when ( (T0_Pump_LFC_Ok_Status == 0) || (T1_Pump_LFC_Ok_Status == 0) || (T2_Pump_LFC_Ok_Status == 0) || (T3_Pump_LFC_Ok_Status == 0) || (T4_Pump_LFC_Ok_Status == 0) || (T5_Pump_LFC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - LFC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps LPIC status not ok  */
      when ( (T0_Pump_LPIC_Ok_Status == 0) || (T1_Pump_LPIC_Ok_Status == 0) || (T2_Pump_LPIC_Ok_Status == 0) || (T3_Pump_LPIC_Ok_Status == 0) || (T4_Pump_LPIC_Ok_Status == 0) || (T5_Pump_LPIC_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - LPIC status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: Pumps Ilck status not ok  */
      when ( (T0_Pump_Ilck_Ok_Status == 0) || (T1_Pump_Ilck_Ok_Status == 0) || (T2_Pump_Ilck_Ok_Status == 0) || (T3_Pump_Ilck_Ok_Status == 0) || (T4_Pump_Ilck_Ok_Status == 0) || (T5_Pump_Ilck_Ok_Status == 0) ) {
        printf("[SEQ COOLING] Error in pumps - Ilck status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

      /* Error: YSV valves status not ok  */
      when ( (T0_Valve_1_Ok_Stat == 0) || (T0_Valve_2_Ok_Stat == 0) ) {
        printf("[SEQ COOLING] Error in YSV valves: one or more devices are not ok\n");
        printf("[SEQ COOLING] System in error: go to FAILURE \n");
      } state failure

      /* Error: TCV valves general status not ok  */
      when ( (T0_Valve_1_General_Status == 0) || (T1_Valve_1_General_Status == 0) || (T2_Valve_1_General_Status == 0) || (T3_Valve_1_General_Status == 0) || (T4_Valve_1_General_Status == 0) || (T5_Valve_1_General_Status == 0) ) {
        printf("[SEQ COOLING] Error in TCV valves - general status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System in error: go to FAILURE \n");
      } state failure

      /* Error: TCV valves interlock status not ok  */
      when ( (T0_Valve_1_Ilck_Status == 0) || (T1_Valve_1_Ilck_Status == 0) || (T2_Valve_1_Ilck_Status == 0) || (T3_Valve_1_Ilck_Status == 0) || (T4_Valve_1_Ilck_Status == 0) || (T5_Valve_1_Ilck_Status == 0) ) {
        printf("[SEQ COOLING] Error in TCV valves - interlock status: one or more devices are not ok\n");
        printf("[SEQ COOLING] System in error: go to FAILURE \n");
      } state failure

      /* Error in YSV position */  /* TO CHECK */
      when ( ( (T0_Valve_1_Close_RB == T0_Valve_1_Open_RB) || (T0_Valve_2_Close_RB == T0_Valve_2_Open_RB) ) && (delay(5)) ) {
        printf("[SEQ COOLING] Error in YSV valves: [open|close] position not clear\n");
        printf("[SEQ COOLING] System in error: go to FAILURE \n");

      } state failure

      /* Possibility to modify [MAN|AUTO] control during operations without changing state*/
      when ( AutoControl_ActualStatus != AutoControlCmd ) {
          AutoControl_ActualStatus = AutoControlCmd;
          pvPut(AutoControl_ActualStatus);
          if ( AutoControl_ActualStatus == 0 ) {
            printf("[SEQ COOLING] Control Configuration changed to MANUAL .\n");
          }
          else if ( AutoControl_ActualStatus == 1 ) {
            printf("[SEQ COOLING] Control Configuration changed to AUTOMATIC.\n");
          }
      } state ready_for_operation


      /* Stop Operation (for every mode of operation) */
      when ( StopOperationCmd == 1 ) {
          printf("[SEQ COOLING] Stop Control Operations. System goes back to Idle Status.\n");
          StartOperationCmd=0;
          pvPut(StartOperationCmd);
      } state idle

      /* ************************************ */
      /* Lost remote communication - managed? */
      /* ************************************ */


      /* DTL Orchestration: case STAND-BY (dtlOperationalCode == 101)  */
      when (dtlOperationalCode == 101) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in STAND-BY stage\n");
          dtl_operation_code_prev=dtlOperationalCode;

        }
      } state ready_for_operation


      /* DTL Orchestration: case RF CONDITIONING (dtlOperationalCode == 202)  */
      when (dtlOperationalCode == 202) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in RF CONDITIONING stage\n");
          dtl_operation_code_prev=dtlOperationalCode;

          /* System can work in [MAN|AUTO] modes */
          if (AutoControl_ActualStatus == 0) {
            printf("[SEQ COOLING] System in MANUAL mode\n");

            /* Set TCV valves in manual mode */
            T0_Valve_1_Manual_Cmd=1;
            pvPut(T0_Valve_1_Manual_Cmd);
            T1_Valve_1_Manual_Cmd=1;
            pvPut(T1_Valve_1_Manual_Cmd);
            T2_Valve_1_Manual_Cmd=1;
            pvPut(T2_Valve_1_Manual_Cmd);
            T3_Valve_1_Manual_Cmd=1;
            pvPut(T3_Valve_1_Manual_Cmd);
            T4_Valve_1_Manual_Cmd=1;
            pvPut(T4_Valve_1_Manual_Cmd);
            T5_Valve_1_Manual_Cmd=1;
            pvPut(T5_Valve_1_Manual_Cmd);

          }
          else if (AutoControl_ActualStatus == 1) {
            printf("[SEQ COOLING] System in AUTOMATIC mode\n");

            /* TCV: Set temperatures setpoint to Cooling_RFCond_Working_Temperature */
            T0_Valve_1_Manual_Cmd=0;
            pvPut(T0_Valve_1_Manual_Cmd);
            T1_Valve_1_Manual_Cmd=0;
            pvPut(T1_Valve_1_Manual_Cmd);
            T2_Valve_1_Manual_Cmd=0;
            pvPut(T2_Valve_1_Manual_Cmd);
            T3_Valve_1_Manual_Cmd=0;
            pvPut(T3_Valve_1_Manual_Cmd);
            T4_Valve_1_Manual_Cmd=0;
            pvPut(T4_Valve_1_Manual_Cmd);
            T5_Valve_1_Manual_Cmd=0;
            pvPut(T5_Valve_1_Manual_Cmd);

            T0_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T0_Valve_1_Temperature_Setpoint);
            T1_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T1_Valve_1_Temperature_Setpoint);
            T2_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T2_Valve_1_Temperature_Setpoint);
            T3_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T3_Valve_1_Temperature_Setpoint);
            T4_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T4_Valve_1_Temperature_Setpoint);
            T5_Valve_1_Temperature_Setpoint=Cooling_RFCond_Working_Temperature;
            pvPut(T5_Valve_1_Temperature_Setpoint);

            /* YSV: open/close set */  //TBD - example with close
            T0_Valve_1_open_Cmd=1;
            pvPut(T0_Valve_1_Close_Cmd);
            T0_Valve_2_Close_Cmd=1;
            pvPut(T0_Valve_2_Close_Cmd);

          }
        }

      } state ready_for_operation

      /* DTL Orchestration: case START-UP (dtlOperationalCode == 303)  */
      when (dtlOperationalCode == 303) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in RF START-UP stage\n");
          dtl_operation_code_prev=dtlOperationalCode;

          /* System can work only in AUTO mode */
          if (AutoControl_ActualStatus == 0) {
            printf("[SEQ COOLING] Updated control configuration: system cannot operate in MANUAL mode\n");
            printf("[SEQ COOLING] Start Control Operations in AUTOMATIC Mode\n");
            AutoControlCmd=1;
            AutoControl_ActualStatus = AutoControlCmd;
            pvPut(AutoControlCmd);
            pvPut(AutoControl_ActualStatus);
          }

          /* Forced - to be clean */
          if (AutoControl_ActualStatus == 1) {
            printf("[SEQ COOLING] System in AUTOMATIC mode\n");

            /* TCV: Set temperatures setpoint to Cooling_BeamOp_Working_Temperature */
            T0_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T0_Valve_1_Temperature_Setpoint);
            T1_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T1_Valve_1_Temperature_Setpoint);
            T2_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T2_Valve_1_Temperature_Setpoint);
            T3_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T3_Valve_1_Temperature_Setpoint);
            T4_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T4_Valve_1_Temperature_Setpoint);
            T5_Valve_1_Temperature_Setpoint=Cooling_BeamOp_Working_Temperature;
            pvPut(T5_Valve_1_Temperature_Setpoint);

            /* YSV: open/close set */  //TBD - example with close
            T0_Valve_1_open_Cmd=1;
            pvPut(T0_Valve_1_Close_Cmd);
            T0_Valve_2_Close_Cmd=1;
            pvPut(T0_Valve_2_Close_Cmd);

          }
        }

      } state temperature_control_mode_check


      /* DTL Orchestration: case READY FOR OPERATION (dtlOperationalCode == 404)  */
      when (dtlOperationalCode == 404) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in READY FOR OPERATION stage\n");
          dtl_operation_code_prev=dtlOperationalCode;

          /* System can work only in AUTO mode */
          /* --> already check in RF STARTUP stage */

          /* System temperature already set in STARTUP stage (previous "when" condition) */
          /* System valves already set in STARTUP stage */
        }

      } state temperature_control_mode_check


      /* DTL Orchestration: case NO ACCELERATED BEAM (dtlOperationalCode == 505)  */
      when (dtlOperationalCode == 505) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in NO BEAM OPERATION stage\n");
          dtl_operation_code_prev=dtlOperationalCode;

          /* System can work in [MAN|AUTO] modes */
          if (AutoControl_ActualStatus == 0) {
            printf("[SEQ COOLING] System in MANUAL mode\n");

            /* Set TCV valves in manual mode */
            T0_Valve_1_Manual_Cmd=1;
            pvPut(T0_Valve_1_Manual_Cmd);
            T1_Valve_1_Manual_Cmd=1;
            pvPut(T1_Valve_1_Manual_Cmd);
            T2_Valve_1_Manual_Cmd=1;
            pvPut(T2_Valve_1_Manual_Cmd);
            T3_Valve_1_Manual_Cmd=1;
            pvPut(T3_Valve_1_Manual_Cmd);
            T4_Valve_1_Manual_Cmd=1;
            pvPut(T4_Valve_1_Manual_Cmd);
            T5_Valve_1_Manual_Cmd=1;
            pvPut(T5_Valve_1_Manual_Cmd);

          }
          else if (AutoControl_ActualStatus == 1) {
            printf("[SEQ COOLING] System in AUTOMATIC mode\n");

            /* TCV: Set temperatures setpoint to Cooling_NoBeam_Working_Temperature */
            T0_Valve_1_Manual_Cmd=0;
            pvPut(T0_Valve_1_Manual_Cmd);
            T1_Valve_1_Manual_Cmd=0;
            pvPut(T1_Valve_1_Manual_Cmd);
            T2_Valve_1_Manual_Cmd=0;
            pvPut(T2_Valve_1_Manual_Cmd);
            T3_Valve_1_Manual_Cmd=0;
            pvPut(T3_Valve_1_Manual_Cmd);
            T4_Valve_1_Manual_Cmd=0;
            pvPut(T4_Valve_1_Manual_Cmd);
            T5_Valve_1_Manual_Cmd=0;
            pvPut(T5_Valve_1_Manual_Cmd);

            T0_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T0_Valve_1_Temperature_Setpoint);
            T1_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T1_Valve_1_Temperature_Setpoint);
            T2_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T2_Valve_1_Temperature_Setpoint);
            T3_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T3_Valve_1_Temperature_Setpoint);
            T4_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T4_Valve_1_Temperature_Setpoint);
            T5_Valve_1_Temperature_Setpoint=Cooling_NoBeam_Working_Temperature;
            pvPut(T5_Valve_1_Temperature_Setpoint);

            /* YSV: open/close set */  //TBD - example with close
            T0_Valve_1_open_Cmd=1;
            pvPut(T0_Valve_1_Close_Cmd);
            T0_Valve_2_Close_Cmd=1;
            pvPut(T0_Valve_2_Close_Cmd);

          }
        }

      } state ready_for_operation

      /* DTL Orchestration: case MAINTENANCE (dtlOperationalCode == 606)  */
      when (dtlOperationalCode == 606) {
        /* First time in this stage */
        if (dtl_operation_code_prev != dtlOperationalCode) {
          printf("[SEQ COOLING] DTL operation in MAINTENANCE stage\n");
          dtl_operation_code_prev=dtlOperationalCode;
          printf("[SEQ COOLING] System goes in IDLE status\n");

          /* note: check if StartOperationCmd is set to Zero before jump to next state */

        }
      } state idle

  }


/* state TEMPERATURE_CONTROL_MODE_CHECK (internal state) */
state temperature_control_mode_check {

  /* transition RF STARTUP -> BEAM OPERATION */ /* check if T0 must be kept */
  when ( (dtlOperationalCode == 404) && (T0_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T0_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) && (T1_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T1_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) && (T2_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T2_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) (T3_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T3_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) && (T4_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T4_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) && (T5_Temperature_Value >= Cooling_BeamOp_Working_Temperature-Cooling_Delta_Working_Temperature) && (T5_Temperature_Value <= Cooling_BeamOp_Working_Temperature+Cooling_Delta_Working_Temperature) && (abs(DTL_Frequency_Detuning)>=abs(Freq_Low_Delta)) )  {
    printf("[SEQ COOLING] Conditions for RF STARTUP -> BEAM OPERATION verified \n");
    printf("[SEQ COOLING] Frequency Detuning inside range [-Δf1,+Δf1] \n");
    printf("[SEQ COOLING] System in Temperature Control Mode \n");

    /*
     * Set PVs related to cooling system
     */

  } state ready_for_operation

  /* transition BEAM OPERATION -> RF STARTUP */
  when ( (dtlOperationalCode == 303) && (abs(DTL_Frequency_Detuning)>=abs(Freq_High_Delta)) ) {
    printf("[SEQ COOLING] Conditions for BEAM OPERATION -> RF STARTUP verified \n");
    printf("[SEQ COOLING] Frequency Detuning outside range [-Δf2,+Δf2] \n");
    printf("[SEQ COOLING] System in Position Control Mode \n");

    /*
     * Set PVs related to cooling system
     */

  } state ready_for_operation

}


/* state FAILURE	*/
  state failure {

    entry {
        printf("\n[SEQ COOLING] Enter in FAILURE status\n");
        StateMachineCode=50;
        pvPut(StateMachineCode);

        /* Reset OK status */
        T1_OK_Status=0;
        pvPut(T1_OK_Status);
        T2_OK_Status=0;
        pvPut(T2_OK_Status);
        T3_OK_Status=0;
        pvPut(T3_OK_Status);
        T4_OK_Status=0;
        pvPut(T4_OK_Status);
        T5_OK_Status=0;
        pvPut(T5_OK_Status);
        Main_OK_Status=0;
        pvPut(Main_OK_Status);

    }

    /* System should provide an healthy status to confirm failure reset */
    when ( (FaultReset == 1) && (PLC_Message == -188) && (T0_Temperature_Status == 1) && (T1_Temperature_Status == 1) && (T2_Temperature_Status == 1) && (T3_Temperature_Status == 1) && (T4_Temperature_Status == 1) && (T5_Temperature_Status == 1) && ((T0_Temperature_Ilk_Status == 1) && (T0_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T1_Temperature_Ilk_Status == 1) && (T1_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T2_Temperature_Ilk_Status == 1) && (T2_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T3_Temperature_Ilk_Status == 1) && (T3_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T4_Temperature_Ilk_Status == 1) && (T4_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T5_Temperature_Ilk_Status == 1) && (T5_Temperature_Ilk_Enable_Cmd_RB == 1)) && ( T0_Flux_Status == 1) && (T1_Flux_Status == 1) && (T2_Flux_Status == 1) && (T3_Flux_Status == 1) && (T4_Flux_Status == 1) && (T5_Flux_Status == 1) && ((T0_Flux_Ilk_Status == 1) && (T0_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T1_Flux_Ilk_Status == 1) && (T1_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T2_Flux_Ilk_Status == 1) && (T2_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T3_Flux_Ilk_Status == 1) && (T3_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T4_Flux_Ilk_Status == 1) && (T4_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T5_Flux_Ilk_Status == 1) && (T5_Flux_Ilk_Enable_Cmd_RB == 1)) && (T0_Pressure_1_Status == 1) && (T0_Pressure_2_Status == 1) && (T1_Pressure_1_Status == 1) && (T1_Pressure_2_Status == 1) && (T2_Pressure_1_Status == 1) && (T2_Pressure_2_Status == 1) && (T3_Pressure_1_Status == 1) && (T3_Pressure_2_Status == 1) && (T4_Pressure_1_Status == 1) && (T4_Pressure_2_Status == 1) && (T5_Pressure_1_Status == 1) && (T5_Pressure_2_Status == 1) && ((T0_Pressure_1_Ilk_Status == 1) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T0_Pressure_2_Ilk_Status == 1) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T1_Pressure_1_Ilk_Status == 1) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T1_Pressure_2_Ilk_Status == 1) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T2_Pressure_1_Ilk_Status == 1) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T2_Pressure_2_Ilk_Status == 1) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T3_Pressure_1_Ilk_Status == 1) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T3_Pressure_2_Ilk_Status == 1) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T4_Pressure_1_Ilk_Status == 1) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T4_Pressure_2_Ilk_Status == 1) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T5_Pressure_1_Ilk_Status == 1) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T5_Pressure_2_Ilk_Status == 1) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && (T0_Pump_General_Ok_Status == 1) && (T1_Pump_General_Ok_Status == 1) && (T2_Pump_General_Ok_Status == 1) && (T3_Pump_General_Ok_Status == 1) && (T4_Pump_General_Ok_Status == 1) && (T5_Pump_General_Ok_Status == 1) && (T0_Pump_FC_Ok_Status == 1) && (T1_Pump_FC_Ok_Status == 1) && (T2_Pump_FC_Ok_Status == 1) && (T3_Pump_FC_Ok_Status == 1) && (T4_Pump_FC_Ok_Status == 1) && (T5_Pump_FC_Ok_Status == 1) && (T0_Pump_LFC_Ok_Status == 1) && (T1_Pump_LFC_Ok_Status == 1) && (T2_Pump_LFC_Ok_Status == 1) && (T3_Pump_LFC_Ok_Status == 1) && (T4_Pump_LFC_Ok_Status == 1) && (T5_Pump_LFC_Ok_Status == 1) && (T0_Pump_LPIC_Ok_Status == 1) && (T1_Pump_LPIC_Ok_Status == 1) && (T2_Pump_LPIC_Ok_Status == 1) && (T3_Pump_LPIC_Ok_Status == 1) && (T4_Pump_LPIC_Ok_Status == 1) && (T5_Pump_LPIC_Ok_Status == 1) && (T0_Pump_Ilck_Ok_Status == 1) && (T1_Pump_Ilck_Ok_Status == 1) && (T2_Pump_Ilck_Ok_Status == 1) && (T3_Pump_Ilck_Ok_Status == 1) && (T4_Pump_Ilck_Ok_Status == 1) && (T5_Pump_Ilck_Ok_Status == 1) && (T0_Valve_1_Ok_Stat == 1) && (T0_Valve_2_Ok_Stat == 1) && (T0_Valve_1_General_Status == 1) && (T1_Valve_1_General_Status == 1) && (T2_Valve_1_General_Status == 1) && (T3_Valve_1_General_Status == 1) && (T4_Valve_1_General_Status == 1) && (T5_Valve_1_General_Status == 1) && (T0_Valve_1_Ilck_Status == 1) && (T1_Valve_1_Ilck_Status == 1) && (T2_Valve_1_Ilck_Status == 1) && (T3_Valve_1_Ilck_Status == 1) && (T4_Valve_1_Ilck_Status == 1) && (T5_Valve_1_Ilck_Status == 1) ) {
      printf("[SEQ COOLING] Failure Stage reset by Operator. \n");
      printf("[SEQ COOLING] Reset conditions satisfied.\n");

      /* Reset FaultReset command */
      FaultReset=0;
      pvPut(FaultReset);

    } state maintenance

  }


/* state MAINTENANCE	*/
  state maintenance {

    entry {
        printf("\n[SEQ COOLING] Enter in MAINTENANCE status\n");
        StateMachineCode=60;
        pvPut(StateMachineCode);
    }

    /* System should provide an healthy status to confirm failure reset */
    when ( (MaintenanceReset == 1) && (PLC_Message == -188) && (T0_Temperature_Status == 1) && (T1_Temperature_Status == 1) && (T2_Temperature_Status == 1) && (T3_Temperature_Status == 1) && (T4_Temperature_Status == 1) && (T5_Temperature_Status == 1) && ((T0_Temperature_Ilk_Status == 1) && (T0_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T1_Temperature_Ilk_Status == 1) && (T1_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T2_Temperature_Ilk_Status == 1) && (T2_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T3_Temperature_Ilk_Status == 1) && (T3_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T4_Temperature_Ilk_Status == 1) && (T4_Temperature_Ilk_Enable_Cmd_RB == 1)) && ((T5_Temperature_Ilk_Status == 1) && (T5_Temperature_Ilk_Enable_Cmd_RB == 1)) && ( T0_Flux_Status == 1) && (T1_Flux_Status == 1) && (T2_Flux_Status == 1) && (T3_Flux_Status == 1) && (T4_Flux_Status == 1) && (T5_Flux_Status == 1) && ((T0_Flux_Ilk_Status == 1) && (T0_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T1_Flux_Ilk_Status == 1) && (T1_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T2_Flux_Ilk_Status == 1) && (T2_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T3_Flux_Ilk_Status == 1) && (T3_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T4_Flux_Ilk_Status == 1) && (T4_Flux_Ilk_Enable_Cmd_RB == 1)) && ((T5_Flux_Ilk_Status == 1) && (T5_Flux_Ilk_Enable_Cmd_RB == 1)) && (T0_Pressure_1_Status == 1) && (T0_Pressure_2_Status == 1) && (T1_Pressure_1_Status == 1) && (T1_Pressure_2_Status == 1) && (T2_Pressure_1_Status == 1) && (T2_Pressure_2_Status == 1) && (T3_Pressure_1_Status == 1) && (T3_Pressure_2_Status == 1) && (T4_Pressure_1_Status == 1) && (T4_Pressure_2_Status == 1) && (T5_Pressure_1_Status == 1) && (T5_Pressure_2_Status == 1) && ((T0_Pressure_1_Ilk_Status == 1) && (T0_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T0_Pressure_2_Ilk_Status == 1) && (T0_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T1_Pressure_1_Ilk_Status == 1) && (T1_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T1_Pressure_2_Ilk_Status == 1) && (T1_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T2_Pressure_1_Ilk_Status == 1) && (T2_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T2_Pressure_2_Ilk_Status == 1) && (T2_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T3_Pressure_1_Ilk_Status == 1) && (T3_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T3_Pressure_2_Ilk_Status == 1) && (T3_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T4_Pressure_1_Ilk_Status == 1) && (T4_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T4_Pressure_2_Ilk_Status == 1) && (T4_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && ((T5_Pressure_1_Ilk_Status == 1) && (T5_Pressure_1_Ilk_Enable_Cmd_RB == 1)) &&  ((T5_Pressure_2_Ilk_Status == 1) && (T5_Pressure_2_Ilk_Enable_Cmd_RB == 1)) && (T0_Pump_General_Ok_Status == 1) && (T1_Pump_General_Ok_Status == 1) && (T2_Pump_General_Ok_Status == 1) && (T3_Pump_General_Ok_Status == 1) && (T4_Pump_General_Ok_Status == 1) && (T5_Pump_General_Ok_Status == 1) && (T0_Pump_FC_Ok_Status == 1) && (T1_Pump_FC_Ok_Status == 1) && (T2_Pump_FC_Ok_Status == 1) && (T3_Pump_FC_Ok_Status == 1) && (T4_Pump_FC_Ok_Status == 1) && (T5_Pump_FC_Ok_Status == 1) && (T0_Pump_LFC_Ok_Status == 1) && (T1_Pump_LFC_Ok_Status == 1) && (T2_Pump_LFC_Ok_Status == 1) && (T3_Pump_LFC_Ok_Status == 1) && (T4_Pump_LFC_Ok_Status == 1) && (T5_Pump_LFC_Ok_Status == 1) && (T0_Pump_LPIC_Ok_Status == 1) && (T1_Pump_LPIC_Ok_Status == 1) && (T2_Pump_LPIC_Ok_Status == 1) && (T3_Pump_LPIC_Ok_Status == 1) && (T4_Pump_LPIC_Ok_Status == 1) && (T5_Pump_LPIC_Ok_Status == 1) && (T0_Pump_Ilck_Ok_Status == 1) && (T1_Pump_Ilck_Ok_Status == 1) && (T2_Pump_Ilck_Ok_Status == 1) && (T3_Pump_Ilck_Ok_Status == 1) && (T4_Pump_Ilck_Ok_Status == 1) && (T5_Pump_Ilck_Ok_Status == 1) && (T0_Valve_1_Ok_Stat == 1) && (T0_Valve_2_Ok_Stat == 1) && (T0_Valve_1_General_Status == 1) && (T1_Valve_1_General_Status == 1) && (T2_Valve_1_General_Status == 1) && (T3_Valve_1_General_Status == 1) && (T4_Valve_1_General_Status == 1) && (T5_Valve_1_General_Status == 1) && (T0_Valve_1_Ilck_Status == 1) && (T1_Valve_1_Ilck_Status == 1) && (T2_Valve_1_Ilck_Status == 1) && (T3_Valve_1_Ilck_Status == 1) && (T4_Valve_1_Ilck_Status == 1) && (T5_Valve_1_Ilck_Status == 1) ) {
      printf("[SEQ COOLING] Failure Stage reset by Operator. \n");
      printf("[SEQ COOLING] Reset conditions satisfied.\n");

      /* Reset MaintenanceReset command */
      MaintenanceReset=0;
      pvPut(MaintenanceReset);

    } state initialization

  }


/* end statemachine */
}
