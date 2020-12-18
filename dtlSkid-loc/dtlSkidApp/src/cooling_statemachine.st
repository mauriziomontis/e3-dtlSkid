/* DTL Cooling State Machine
# State Machine devoted to control the status and the health of DTL cooling sub-system :
#
# Principal States:
# - Initialization:
# 	* Initialize State Machine when EPICS application starts
# - Self-Check:
#       * Verify HW status (connections, devices\'' health, etc.)
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
%%#include <string.h>
%%#include <unistd.h>

/*
# Variables and Constants
*/

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
assign AutoControlCmd to "";
monitor AutoControlCmd;

int AutoControl_ActualStatus;
assign AutoControl_ActualStatus to "";
monitor AutoControl_ActualStatus;


/* Start and Stop Operations */
int StartOperationCmd;
assign StartOperationCmd to "";
monitor StartOperationCmd;
int StopOperationCmd;
assign StopOperationCmd to "";
monitor StopOperationCmd;

/* Maintenance and fault control*/
int MaintenanceReset;
assign MaintenanceReset to "";
monitor MaintenanceReset;
int FaultReset;
assign FaultReset to "";
monitor FaultReset;


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
assign StateMachineCode to "";

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
        printf("[SEQ COOLING] All PVs connected and System in Remote control\n");
        printf("[SEQ COOLING] Starting Self Check Process\n");

       state self_check
	}


/* state SELF_CHECK	*/
	state self_check {
      entry {
        printf("\n[SEQ COOLING] Enter in SELF CHECK status\n");
        StateMachineCode=10;
        pvPut(StateMachineCode);
      }

    /* Error: Temperature sensors status not ok */
      when ( (T0_Temperature_Status == 0) || (T1_Temperature_Status == 0) || (T3_Temperature_Status == 0) || (T4_Temperature_Status == 0) || (T5_Temperature_Status == 0) ) {
        printf("[SEQ COOLING] Error in temperature sensors: one or more devices are not ok\n");
        printf("[SEQ COOLING] System not passed self check: go to FAILURE \n");
      } state failure

  }


/* state STARTUP	*/
state start_up {
  entry {
    printf("\n[SEQ COOLING] Enter in START UP status\n");
    StateMachineCode=30;
    pvPut(StateMachineCode);
  }




  /* No problems with steerers channels */
  when ( (T1_V1_ChEnable == 1) && (T1_H1_ChEnable == 1) && (T1_V2_ChEnable == 1) && (T1_H2_ChEnable == 1) && (T1_V3_ChEnable == 1) && (T1_H3_ChEnable == 1) && (T1_V4_ChEnable == 1) && (T1_H4_ChEnable == 1) && (T1_V5_ChEnable == 1) && (T1_H5_ChEnable == 1) && (T1_V6_ChEnable == 1) && (T1_H6_ChEnable == 1) && (T2_V1_ChEnable == 1) && (T2_H1_ChEnable == 1) && (T2_V2_ChEnable == 1) && (T2_H2_ChEnable == 1) && (T2_V3_ChEnable == 1) && (T2_H3_ChEnable == 1) && (T3_V1_ChEnable == 1) && (T3_H1_ChEnable == 1) && (T3_V2_ChEnable == 1) && (T3_H2_ChEnable == 1) && (T4_V1_ChEnable == 1) && (T4_H1_ChEnable == 1) && (T4_V2_ChEnable == 1) && (T4_H2_ChEnable == 1) && (T5_V1_ChEnable == 1) && (T5_H1_ChEnable == 1) && (T5_V2_ChEnable == 1) && (T5_H2_ChEnable == 1) ) {
  /* Line disconnected (HW) */
      printf("[SEQ COOLING] Channels correctly enabled. Start setpoint reset. \n");
      T1_V1_CurrentSet = 0;
      pvPut(T1_V1_CurrentSet);
      T1_H1_CurrentSet = 0;
      pvPut(T1_H1_CurrentSet);
      T1_V2_CurrentSet = 0;
      pvPut(T1_V2_CurrentSet);
      T1_H2_CurrentSet = 0;
      pvPut(T1_H2_CurrentSet);
      T1_V3_CurrentSet = 0;
      pvPut(T1_V3_CurrentSet);
      T1_H3_CurrentSet = 0;
      pvPut(T1_H3_CurrentSet);
      T1_V4_CurrentSet = 0;
      pvPut(T1_V4_CurrentSet);
      T1_H4_CurrentSet = 0;
      pvPut(T1_H4_CurrentSet);
      T1_V5_CurrentSet = 0;
      pvPut(T1_V5_CurrentSet);
      T1_H5_CurrentSet = 0;
      pvPut(T1_H5_CurrentSet);
      T1_V6_CurrentSet = 0;
      pvPut(T1_V6_CurrentSet);
      T1_H6_CurrentSet = 0;
      pvPut(T1_H6_CurrentSet);
      T2_V1_CurrentSet = 0;
      pvPut(T2_V1_CurrentSet);
      T2_H1_CurrentSet = 0;
      pvPut(T2_H1_CurrentSet);
      T2_V2_CurrentSet = 0;
      pvPut(T2_V2_CurrentSet);
      T2_H2_CurrentSet = 0;
      pvPut(T2_H2_CurrentSet);
      T2_V3_CurrentSet = 0;
      pvPut(T2_V3_CurrentSet);
      T2_H3_CurrentSet = 0;
      pvPut(T2_H3_CurrentSet);
      T3_V1_CurrentSet = 0;
      pvPut(T3_V1_CurrentSet);
      T3_H1_CurrentSet = 0;
      pvPut(T3_H1_CurrentSet);
      T3_V2_CurrentSet = 0;
      pvPut(T3_V2_CurrentSet);
      T3_H2_CurrentSet = 0;
      pvPut(T3_H2_CurrentSet);
      T4_V1_CurrentSet = 0;
      pvPut(T4_V1_CurrentSet);
      T4_H1_CurrentSet = 0;
      pvPut(T4_H1_CurrentSet);
      T4_V2_CurrentSet = 0;
      pvPut(T4_V2_CurrentSet);
      T4_H2_CurrentSet = 0;
      pvPut(T4_H2_CurrentSet);
      T5_V1_CurrentSet = 0;
      pvPut(T5_V1_CurrentSet);
      T5_H1_CurrentSet = 0;
      pvPut(T5_H1_CurrentSet);
      T5_V2_CurrentSet = 0;
      pvPut(T5_V2_CurrentSet);
      T5_H2_CurrentSet = 0;
      pvPut(T5_H2_CurrentSet);
  } state idle

}


/* state IDLE   	*/
state idle {
  entry {
    printf("\n[SEQ COOLING] Enter in IDLE status\n");
    StateMachineCode=20;
    pvPut(StateMachineCode);
  }

  /* Channels are not enabled */
  when ( (T1_V1_ChEnable == 0) || (T1_H1_ChEnable == 0) || (T1_V2_ChEnable == 0) || (T1_H2_ChEnable == 0) || (T1_V3_ChEnable == 0) || (T1_H3_ChEnable == 0) || (T1_V4_ChEnable == 0) || (T1_H4_ChEnable == 0) || (T1_V5_ChEnable == 0) || (T1_H5_ChEnable == 0) || (T1_V6_ChEnable == 0) || (T1_H6_ChEnable == 0) || (T2_V1_ChEnable == 0) || (T2_H1_ChEnable == 0) || (T2_V2_ChEnable == 0) || (T2_H2_ChEnable == 0) || (T2_V3_ChEnable == 0) || (T2_H3_ChEnable == 0) || (T3_V1_ChEnable == 0) || (T3_H1_ChEnable == 0) || (T3_V2_ChEnable == 0) || (T3_H2_ChEnable == 0) || (T4_V1_ChEnable == 0) || (T4_H1_ChEnable == 0) || (T4_V2_ChEnable == 0) || (T4_H2_ChEnable == 0) || (T5_V1_ChEnable == 0) || (T5_H1_ChEnable == 0) || (T5_V2_ChEnable == 0) || (T5_H2_ChEnable == 0) ) {
  /* Line disconnected (HW) */
      printf("[SEQ COOLING] One or more channels are not enabled \n");
      printf("[SEQ COOLING] Try to rescan the system status \n");
  } state self_check

  when ( (Chassis1_enable_RB == 0) || (Chassis2_enable_RB == 0) || (Chassis3_enable_RB == 0) || (Chassis4_enable_RB == 0) || (Chassis5_enable_RB == 0) ) {
      printf("[SEQ COOLING] Error in chassis enable system: one or more chassis are not available\n");
      printf("[SEQ COOLING] System not ok: go to FAILURE \n");
  } state failure

  /* Thermas Switch problem */
  when ( (T1_V1_Termal_OkStat == 0) || (T1_H1_Termal_OkStat == 0) || (T1_V2_Termal_OkStat == 0) || (T1_H2_Termal_OkStat == 0) || (T1_V3_Termal_OkStat == 0) || (T1_H3_Termal_OkStat == 0) || (T1_V4_Termal_OkStat == 0) || (T1_H4_Termal_OkStat == 0) || (T1_V5_Termal_OkStat == 0) || (T1_H5_Termal_OkStat == 0) || (T1_V6_Termal_OkStat == 0) || (T1_H6_Termal_OkStat == 0) || (T2_V1_Termal_OkStat == 0) || (T2_H1_Termal_OkStat == 0) || (T2_V2_Termal_OkStat == 0) || (T2_H2_Termal_OkStat == 0) || (T2_V3_Termal_OkStat == 0) || (T2_H3_Termal_OkStat == 0) || (T3_V1_Termal_OkStat == 0) || (T3_H1_Termal_OkStat == 0) || (T3_V2_Termal_OkStat == 0) || (T3_H2_Termal_OkStat == 0) || (T4_V1_Termal_OkStat == 0) || (T4_H1_Termal_OkStat == 0) || (T4_V2_Termal_OkStat == 0) || (T4_H2_Termal_OkStat == 0) || (T5_V1_Termal_OkStat == 0) || (T5_H1_Termal_OkStat == 0) || (T5_V2_Termal_OkStat == 0) || (T5_H2_Termal_OkStat == 0) ) {
  /* Line disconnected (HW) */
      printf("[SEQ COOLING] Error in line enable system: thermal switch problem in one or more lines \n");
      printf("[SEQ COOLING] System not ok: go to FAILURE \n");
  } state failure

  /* 24V Error */
  when ( (Rack010_24V == 0) || (Rack030_24V == 0) ) {
      printf("[SEQ COOLING] Error in 24V power racks. \n");
      printf("[SEQ COOLING] System not ok: go to FAILURE \n");
  } state failure


  /* Some PVs are disconnected */
  when (pvConnectCount() != pvAssignCount()) {
    printf("[SEQ COOLING] Error in steerer system: one or more PVs are not available for the state machine. \n");
    printf("[SEQ COOLING] System not ok: go to FAILURE \n");
  } state failure

  /* Execute chosen configuration [man|auto] */
  when ( (StartOperationCmd == 1) ) {
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

  } state ready_for_operation
}


/* state READY_FOR_OPERATION 	*/
  state ready_for_operation {

    entry {
      printf("\n[SEQ COOLING] Enter in READY FOR OPERATION status\n");
      StateMachineCode=40;
      pvPut(StateMachineCode);
      }

    /* Chassis problem */
    when ( (Chassis1_enable_RB == 0) || (Chassis2_enable_RB == 0) || (Chassis3_enable_RB == 0) || (Chassis4_enable_RB == 0) || (Chassis5_enable_RB == 0) ) {
      printf("[SEQ COOLING] Error in chassis enable system: one or more chassis are not available\n");
      printf("[SEQ COOLING] System not ok: go to FAILURE \n");
    } state failure

    /* Thermas Switch problem */
    when ( (T1_V1_Termal_OkStat == 0) || (T1_H1_Termal_OkStat == 0) || (T1_V2_Termal_OkStat == 0) || (T1_H2_Termal_OkStat == 0) || (T1_V3_Termal_OkStat == 0) || (T1_H3_Termal_OkStat == 0) || (T1_V4_Termal_OkStat == 0) || (T1_H4_Termal_OkStat == 0) || (T1_V5_Termal_OkStat == 0) || (T1_H5_Termal_OkStat == 0) || (T1_V6_Termal_OkStat == 0) || (T1_H6_Termal_OkStat == 0) || (T2_V1_Termal_OkStat == 0) || (T2_H1_Termal_OkStat == 0) || (T2_V2_Termal_OkStat == 0) || (T2_H2_Termal_OkStat == 0) || (T2_V3_Termal_OkStat == 0) || (T2_H3_Termal_OkStat == 0) || (T3_V1_Termal_OkStat == 0) || (T3_H1_Termal_OkStat == 0) || (T3_V2_Termal_OkStat == 0) || (T3_H2_Termal_OkStat == 0) || (T4_V1_Termal_OkStat == 0) || (T4_H1_Termal_OkStat == 0) || (T4_V2_Termal_OkStat == 0) || (T4_H2_Termal_OkStat == 0) || (T5_V1_Termal_OkStat == 0) || (T5_H1_Termal_OkStat == 0) || (T5_V2_Termal_OkStat == 0) || (T5_H2_Termal_OkStat == 0) ) {
    /* Line disconnected (HW) */
        printf("[SEQ COOLING] Error in line enable system: thermal switch problem in one or more lines \n");
        printf("[SEQ COOLING] System not ok: go to FAILURE \n");
    } state failure

    /* 24V Error */
    when ( (Rack010_24V == 0) || (Rack030_24V == 0) ) {
        printf("[SEQ COOLING] Error in 24V power racks. \n");
        printf("[SEQ COOLING] System not ok: go to FAILURE \n");
    } state failure

    /* Error with Impedance deviance */
    when ( (T1_V1_DeltaImpedance > MAX_DEVIANCE) || (T1_H1_DeltaImpedance > MAX_DEVIANCE) || (T1_V2_DeltaImpedance > MAX_DEVIANCE) || (T1_H2_DeltaImpedance > MAX_DEVIANCE) || (T1_V3_DeltaImpedance > MAX_DEVIANCE) || (T1_H3_DeltaImpedance > MAX_DEVIANCE) || (T1_V4_DeltaImpedance > MAX_DEVIANCE) || (T1_H4_DeltaImpedance > MAX_DEVIANCE) || (T1_V5_DeltaImpedance > MAX_DEVIANCE) || (T1_H5_DeltaImpedance > MAX_DEVIANCE) || (T1_V6_DeltaImpedance > MAX_DEVIANCE) || (T1_H6_DeltaImpedance > MAX_DEVIANCE) || (T2_V1_DeltaImpedance > MAX_DEVIANCE) || (T2_H1_DeltaImpedance > MAX_DEVIANCE) || (T2_V2_DeltaImpedance > MAX_DEVIANCE) || (T2_H2_DeltaImpedance > MAX_DEVIANCE) || (T2_V3_DeltaImpedance > MAX_DEVIANCE) || (T2_H3_DeltaImpedance > MAX_DEVIANCE) || (T3_V1_DeltaImpedance > MAX_DEVIANCE) || (T3_H1_DeltaImpedance > MAX_DEVIANCE) || (T3_V2_DeltaImpedance > MAX_DEVIANCE) || (T3_H2_DeltaImpedance > MAX_DEVIANCE) || (T4_V1_DeltaImpedance > MAX_DEVIANCE) || (T4_H1_DeltaImpedance > MAX_DEVIANCE) || (T4_V2_DeltaImpedance > MAX_DEVIANCE) || (T4_H2_DeltaImpedance > MAX_DEVIANCE) || (T5_V1_DeltaImpedance > MAX_DEVIANCE) || (T5_H1_DeltaImpedance > MAX_DEVIANCE) || (T5_V2_DeltaImpedance > MAX_DEVIANCE) || (T5_H2_DeltaImpedance > MAX_DEVIANCE) ) {
    /* Line disconnected (HW) */
        printf("[SEQ COOLING] Error in steerer system: one or more stereres register HIGH IMPEDANCE DEVIANCE \n");
        printf("[SEQ COOLING] System not ok: go to FAILURE \n");
    } state failure

    /* Stop Operation (for every mode of operation) */
    when ( StopOperationCmd == 1 ) {
        printf("[SEQ COOLING] Stop Control Operations. System goes back to Idle Status.\n");
    } state idle

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

    /* NOTES: */
    /* Case of Operation: RF Conditioning */
    /*
    Conditions:
     - Steerers are OFF
     - Setpoints are at 0A
    */
    /* Case of Operation: Ready for Beam */
    /*
    Conditions:
     - Steerers are ON
     - Setpoints are set at "operative" value
    */

  }



/* state FAILURE	*/
  state failure {

    entry {
        printf("\n[SEQ COOLING] Enter in FAILURE status\n");
        StateMachineCode=50;
        pvPut(StateMachineCode);

        /* Switch off each steerer channel */
        T1_V1_ChEnableCmd = 0;
        pvPut(T1_V1_ChEnableCmd);
        T1_H1_ChEnableCmd = 0;
        pvPut(T1_H1_ChEnableCmd);
        T1_V2_ChEnableCmd = 0;
        pvPut(T1_V2_ChEnableCmd);
        T1_H2_ChEnableCmd = 0;
        pvPut(T1_H2_ChEnableCmd);
        T1_V3_ChEnableCmd = 0;
        pvPut(T1_V3_ChEnableCmd);
        T1_H3_ChEnableCmd = 0;
        pvPut(T1_H3_ChEnableCmd);
        T1_V4_ChEnableCmd = 0;
        pvPut(T1_V4_ChEnableCmd);
        T1_H4_ChEnableCmd = 0;
        pvPut(T1_H4_ChEnableCmd);
        T1_V5_ChEnableCmd = 0;
        pvPut(T1_V5_ChEnableCmd);
        T1_H5_ChEnableCmd = 0;
        pvPut(T1_H5_ChEnableCmd);
        T1_V6_ChEnableCmd = 0;
        pvPut(T1_V6_ChEnableCmd);
        T1_H6_ChEnableCmd = 0;
        pvPut(T1_H6_ChEnableCmd);
        T2_V1_ChEnableCmd = 0;
        pvPut(T2_V1_ChEnableCmd);
        T2_H1_ChEnableCmd = 0;
        pvPut(T2_H1_ChEnableCmd);
        T2_V2_ChEnableCmd = 0;
        pvPut(T2_V2_ChEnableCmd);
        T2_H2_ChEnableCmd = 0;
        pvPut(T2_H2_ChEnableCmd);
        T2_V3_ChEnableCmd = 0;
        pvPut(T2_V3_ChEnableCmd);
        T2_H3_ChEnableCmd = 0;
        pvPut(T2_H3_ChEnableCmd);
        T3_V1_ChEnableCmd = 0;
        pvPut(T3_V1_ChEnableCmd);
        T3_H1_ChEnableCmd = 0;
        pvPut(T3_H1_ChEnableCmd);
        T3_V2_ChEnableCmd = 0;
        pvPut(T3_V2_ChEnableCmd);
        T3_H2_ChEnableCmd = 0;
        pvPut(T3_H2_ChEnableCmd);
        T4_V1_ChEnableCmd = 0;
        pvPut(T4_V1_ChEnableCmd);
        T4_H1_ChEnableCmd = 0;
        pvPut(T4_H1_ChEnableCmd);
        T4_V2_ChEnableCmd = 0;
        pvPut(T4_V2_ChEnableCmd);
        T4_H2_ChEnableCmd = 0;
        pvPut(T4_H2_ChEnableCmd);
        T5_V1_ChEnableCmd = 0;
        pvPut(T5_V1_ChEnableCmd);
        T5_H1_ChEnableCmd = 0;
        pvPut(T5_H1_ChEnableCmd);
        T5_V2_ChEnableCmd = 0;
        pvPut(T5_V2_ChEnableCmd);
        T5_H2_ChEnableCmd = 0;
        pvPut(T5_H2_ChEnableCmd);
    }

    /* System should provide an healthy status to confirm failure reset */
    /* Check on: Chassis, Thermal Switches, 24V Rack Power */
    when ( (FaultReset == 1) &&  (Chassis1_enable_RB == 1) && (Chassis2_enable_RB == 1) && (Chassis3_enable_RB == 1) && (Chassis4_enable_RB == 1) && (Chassis5_enable_RB == 1) && (T1_V1_Termal_OkStat == 1) && (T1_H1_Termal_OkStat == 1) && (T1_V2_Termal_OkStat == 1) && (T1_H2_Termal_OkStat == 1) && (T1_V3_Termal_OkStat == 1) && (T1_H3_Termal_OkStat == 1) && (T1_V4_Termal_OkStat == 1) && (T1_H4_Termal_OkStat == 1) && (T1_V5_Termal_OkStat == 1) && (T1_H5_Termal_OkStat == 1) && (T1_V6_Termal_OkStat == 1) && (T1_H6_Termal_OkStat == 1) && (T2_V1_Termal_OkStat == 1) && (T2_H1_Termal_OkStat == 1) && (T2_V2_Termal_OkStat == 1) && (T2_H2_Termal_OkStat == 1) && (T2_V3_Termal_OkStat == 1) && (T2_H3_Termal_OkStat == 1) && (T3_V1_Termal_OkStat == 1) && (T3_H1_Termal_OkStat == 1) && (T3_V2_Termal_OkStat == 1) && (T3_H2_Termal_OkStat == 1) && (T4_V1_Termal_OkStat == 1) && (T4_H1_Termal_OkStat == 1) && (T4_V2_Termal_OkStat == 1) && (T4_H2_Termal_OkStat == 1) && (T5_V1_Termal_OkStat == 1) && (T5_H1_Termal_OkStat == 1) && (T5_V2_Termal_OkStat == 1) && (T5_H2_Termal_OkStat == 1) && (Rack010_24V == 1) && (Rack030_24V == 1) ) {

        printf("[SEQ COOLING] Failure Stage reset by Operator. \n");
        printf("[SEQ COOLING] Reset conditions satisfied.\n");
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
    /* Check on: Chassis, Thermal Switches, 24V Rack Power */
    when ( (MaintenanceReset == 1) &&  (Chassis1_enable_RB == 1) && (Chassis2_enable_RB == 1) && (Chassis3_enable_RB == 1) && (Chassis4_enable_RB == 1) && (Chassis5_enable_RB == 1) && (T1_V1_Termal_OkStat == 1) && (T1_H1_Termal_OkStat == 1) && (T1_V2_Termal_OkStat == 1) && (T1_H2_Termal_OkStat == 1) && (T1_V3_Termal_OkStat == 1) && (T1_H3_Termal_OkStat == 1) && (T1_V4_Termal_OkStat == 1) && (T1_H4_Termal_OkStat == 1) && (T1_V5_Termal_OkStat == 1) && (T1_H5_Termal_OkStat == 1) && (T1_V6_Termal_OkStat == 1) && (T1_H6_Termal_OkStat == 1) && (T2_V1_Termal_OkStat == 1) && (T2_H1_Termal_OkStat == 1) && (T2_V2_Termal_OkStat == 1) && (T2_H2_Termal_OkStat == 1) && (T2_V3_Termal_OkStat == 1) && (T2_H3_Termal_OkStat == 1) && (T3_V1_Termal_OkStat == 1) && (T3_H1_Termal_OkStat == 1) && (T3_V2_Termal_OkStat == 1) && (T3_H2_Termal_OkStat == 1) && (T4_V1_Termal_OkStat == 1) && (T4_H1_Termal_OkStat == 1) && (T4_V2_Termal_OkStat == 1) && (T4_H2_Termal_OkStat == 1) && (T5_V1_Termal_OkStat == 1) && (T5_H1_Termal_OkStat == 1) && (T5_V2_Termal_OkStat == 1) && (T5_H2_Termal_OkStat == 1) && (Rack010_24V == 1) && (Rack030_24V == 1) ) {

        printf("[SEQ COOLING] Failure Stage reset by Operator. \n");
        printf("[SEQ COOLING] Reset conditions satisfied.\n");
    } state initialization


  }


/* end statemachine */
}
