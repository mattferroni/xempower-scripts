import os
from time import gmtime, strftime

class MarcConfiguration:pass
	
	HOME_USER 						= "/home/matteo"
	XEMPOWER_DIR					= HOME_USER+"/xempower"
	SCRIPTS_DIR 					= HOME_USER+"/workspace/scripts/bash/marc"
	TESTS_FOLDER    				= HOME_USER+"/workspace/tests/marc"
	MARC_SCRIPTS_DIR                = HOME_USER+"/workspace/scripts/bash/marc"
	SCHEDULE_DIR					= XEMPOWER_DIR+"/xen/common"
	

	SCHEDULE_FILE					= SCHEDULE_DIR*"/schedule.c"
	START_XENTRACE_TEMPLAT 			= SCRIPTS_DIR+"/start_xentrace_template"
	START_XENTRACE_SCRIPT 			= SCRIPTS_DIR+"/start_xentrace.sh"
	START_XENTRACE_TAIL 			= SCHEDULE_DIR+"/xentrace_tail"
	START_DOMAIN 					= SCRIPTS_DIR+"/start_domain.sh"
	STOP_DOMAIN 					= SCRIPTS_DIR+"/stop_domain.sh"
	STOP_XENTRACE 					= SCRIPTS_DIR+"/stop_xentrace.sh"
	PARSE_DATA 						= SCRIPTS_DIR+"/parse_data.sh"

	#WATTSUP POWER METER VARIABLES
	WATTSUP 						= HOME_USER+"/workspace/watts-up/wattsup"
	WATTSUP_READER 					= SCRIPTS_DIR+"/wattsup_reader"
	WATTUP_DATA_PARSER 				= SCRIPTS_DIR+"/parser_wattsup_output.py"
	WATTSUP_USB 					= "/dev/ttyUSB0"
	#START LOG EVERY 1 SECOND AND WRITE DATA ON INTERNAL MEMORY
	WATTSUP_START_LOG 				= "echo '#L,W,3,I,,1;' > "+WATTSUP_USB
	#START LOG EVERY 3600 SECONDS AND WRITE DATA ON EXTERNAL LINK
	WATTSUP_LOW_LOAD 				= "echo '#L,W,3,E,,3600;' > "+WATTSUP_USB
	#GET ALL DATA IN INTERNAL MEMORY
	WATTSUP_GET_DATA 				= "echo '#D,R,0;' > "+WATTSUP_USB
	#CLEAR INTERNAL MEMORY
	WATTSUP_CLEAR 					= "echo '#R,W,0;' > "+WATTSUP_USB

	SCHEDULES_USED 					= TESTS_FOLDER+"/schedule_used"

	SCHEDULES_TO_STUDY				= 8

	def __init__(self):
		self.now_time 				= strftime("%Y-%m-%d-%H.%M", gmtime())
		self.current_user 			= os.path.expanduser(HOME_USER)
		self.current_test_folder 	= TESTS_FOLDER+"/xentrace-to-rapl-"+str(self.now_time)
		self.mapping_file 			= self.current_test_folder+"/domain_mapping.csv"
		self.wattsup_tmp 			= self.current_test_folder+"/watts-up-tmp"
		self.wattsup_output 		= self.current_test_folder+"/wattsup-watts"



	def cpu_tests(self):



	def mem_tests(self):



	def io_tests(self):


	def cpu_io_tests(self):


	def mem_io_tests(self):

		


