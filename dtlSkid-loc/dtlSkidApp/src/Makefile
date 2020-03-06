TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#=============================
# Build the IOC application

PROD_IOC = dtlSkid
# dtlSkid.dbd will be created and installed
DBD += dtlSkid.dbd

# dtlSkid.dbd will be made up from these files:
dtlSkid_DBD += base.dbd

# Include dbd files from all support applications:
#dtlSkid_DBD += xxx.dbd

# Add all the support libraries needed by this IOC
#dtlSkid_LIBS += xxx

# dtlSkid_registerRecordDeviceDriver.cpp derives from dtlSkid.dbd
dtlSkid_SRCS += dtlSkid_registerRecordDeviceDriver.cpp

# Build the main IOC entry point on workstation OSs.
dtlSkid_SRCS_DEFAULT += dtlSkidMain.cpp
dtlSkid_SRCS_vxWorks += -nil-

# Add support from base/src/vxWorks if needed
#dtlSkid_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

# Finally link to the EPICS Base libraries
dtlSkid_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

