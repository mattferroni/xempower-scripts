import os,sys,collections,subprocess

OUTPUT_DIR="./files"
DICTIONARY="./dictionary_label.csv"
FIRST_LINE_XENTRACE="echo \"0x0100f003  CPU%(cpu)d  %(tsc)d (+%(reltsc)8d)  event (0x%(event)016x)  dom%(1)d, vCPU%(2)d"
FIRST_LINE_XENTRACE_END="\" > $CURRENT_FOLDER/pmc_trace_human.format"
SECOND_LINE_XENTRACE="echo \"0x0100f003  %(tsc)d,%(cpu)d,%(1)d,%(2)d"
SECOND_LINE_XENTRACE_END="\" > $CURRENT_FOLDER/pmc_trace_matlab.format"
THIRD_LINE_XENTRACE="echo \"TSC,CPU,DOM,vCPU"
THIRD_LINE_XENTRACE_END="\" > $CURRENT_FOLDER/pmc.csv"
FINAL_LINE_XENTRACE="sudo xentrace -D -e 0x0100f000 $CURRENT_FOLDER/trace.data &"
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

current_dir = os.getcwd()
dictionary_label = collections.OrderedDict()
label_list = list()

with open(DICTIONARY) as f:
    content = f.readlines()
    for line in content:
    	label_list.append(line)
    	data = line.split(",")
    	dictionary_label[data[0]] = data[1].replace("\n","")

print label_list
for i in range(0,8):
	schedule = OUTPUT_DIR+"/schedule.c"
	xentrace = OUTPUT_DIR+"/xentrace_tail"
	if i != 0:
		schedule = schedule+str(i)
		xentrace = xentrace+str(i)

	open(schedule, "a+").write("//SCHEDULE "+str(i)+"\n")
	open(schedule, "a+").writelines([l for l in open("./first_schedule_template").readlines()])
	start_xentrace_string = FIRST_LINE_XENTRACE
	second_line_xentrace = SECOND_LINE_XENTRACE
	third_line_xentrace = THIRD_LINE_XENTRACE
	IA32_PERFEVTSEL_index = 0
	open(schedule, "a+").write("\n")
	for index in range(i*4,(i+1)*4):
		value = "    write_msr(IA32_PERFEVTSEL"+str(IA32_PERFEVTSEL_index)+", "+label_list[index].split(",")[0]+", ZERO_VALUE);"
		label = label_list[index].split(",")[1].replace("\n","")
		start_xentrace_string = start_xentrace_string+", "+label+"=%("+str(IA32_PERFEVTSEL_index+3)+")8d"
		second_line_xentrace = second_line_xentrace+",%("+str(IA32_PERFEVTSEL_index+3)+")d"
		third_line_xentrace = third_line_xentrace+","+label
		open(schedule, "a+").write(value+"\n")
		IA32_PERFEVTSEL_index = IA32_PERFEVTSEL_index + 1

	open(schedule, "a+").writelines([l for l in open("./second_schedule_template").readlines()])
	start_xentrace_string = start_xentrace_string + FIRST_LINE_XENTRACE_END
	second_line_xentrace = second_line_xentrace + SECOND_LINE_XENTRACE_END
	third_line_xentrace = third_line_xentrace + THIRD_LINE_XENTRACE_END
	#WRITE XENTRACE TAIL
	open(xentrace, "a+").write(start_xentrace_string+"\n"+second_line_xentrace+"\n"+third_line_xentrace+"\n\n"+FINAL_LINE_XENTRACE)