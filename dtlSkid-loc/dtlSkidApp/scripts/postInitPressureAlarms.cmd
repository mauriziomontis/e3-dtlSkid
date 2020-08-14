#==============================================================================
# postInitPressureAlarms.cmd
#- Arguments: SECTION_NAME, DEVICE, DEVICE_POS, SIGNAL, LOLO, LLSV, LOW, LSV, HIGH, HSV, HIHI, HHSV, HYST

#-d /**
#-d   \brief Configure Record fields for DTL SKID pressure sensors.
#-d   \details Set alarms and severity for skid pressure sensors.
#-d   \author Maurizio Montis (INFN-LNL)
#-d   \file
#-d   \param SECTION_NAME Section name, i.e. CWM-CWS04
#-d   \param DEVICE Device name (accordig to ESS Naming Convetion), i.e. PT
#-d   \param DEVICE_POS Device position ( indexaccordig to ESS Naming Convetioni index)
#-d   \param SIGNAL Signal name property (accordig to ESS Naming Convetion), i.e. FBL-
#-d   \param LOLO Lower alarm value
#-d   \param LLSV  Lower alarm severity, i.e. MAJOR
#-d   \param LOW  Low alarm value
#-d   \param LSV  Low alarm severity, i.e MINOR
#-d   \param HIGH  High alarm value
#-d   \param HSV  High alarm severity, i.e. MINOR
#-d   \param HIHI  Higher alarm value
#-d   \param HHSV  Higher alarm severity, i.e. MAJOR
#-d   \param HYST  Alarm deadband
#-d   \note Example call:
#-d   \code
#-d    ${SCRIPTEXEC} "${dtlSkid_DIR}postInitPressureAlarms.cmd", "SECTION_NAME=CWM-CWS04, DEVICE=PT, DEVICE_POS=101, SIGNAL=FBL-, LOLO=0, LLSV=MAJOR, LOW=10, LSV=MINOR, HIGH=40, HSV=MINOR, HIHI=45, HHSV=MAJOR, HYST=3"
#-d   \endcode
#-d */

afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.LOLO" "${LOLO}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.LLSV" "${LLSV}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.LOW" "${LOW}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.LSV" "${LSV}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.HIGH" "${HIGH}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.HSV" "${HSV}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.HIHI" "${HIHI}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.HHSV" "${HHSV}")
afterInit(dbpf "${SECTION_NAME}:WtrC-${DEVICE}-${DEVICE_POS}:${SIGNAL}Prs.HYST" "${HYST}")
