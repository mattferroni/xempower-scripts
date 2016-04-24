import os,sys,collections,subprocess

FIRST_PART_TEMPLATE = "./first-part-template"
SECOND_PART_TEMPLATE = "./second-part-template"
DICTIONARY = "./dictionary.csv"
OUTPUT_FOLDER = "./output"

MAX_ITERATION  = "\nMAX_ITERATION="
VARIABLE_PART_1 = "\necho $(date +%s.%N) \" - Sending commands to Marc domain...\"\nssh marc@10.0.0.5 'screen -d -m " 

VARIABLE_PART_2 = "echo $(date +%s.%N) \" - Command sent\"\nsleep 150s\necho $(date +%s.%N) \" - Sending commands to Marc domain...\"\nssh marc@10.0.0.4 'screen -d -m "

VARIABLE_PART_3 = "echo $(date +%s.%N) \" - Command sent\"\nsleep 150s\n"


if not os.path.exists(OUTPUT_FOLDER):
    os.makedirs(OUTPUT_FOLDER)

with open(DICTIONARY) as input:
	current_file = 0
	content = input.readlines()
	for line in content:
		first_bench = line.split(",")[0]
		second_bench = line.split(",")[1].replace("\n","")
		if current_file == 0:
			file_name = OUTPUT_FOLDER+"/current.sh"
		else:
			file_name = OUTPUT_FOLDER+"/current.sh"+str(current_file)
		open(file_name,"a+").writelines([l for l in open(FIRST_PART_TEMPLATE).readlines()])
		open(file_name,"a+").write(MAX_ITERATION+str(len(content)))
		open(file_name,"a+").write(VARIABLE_PART_1+str(first_bench)+"'\n")
		open(file_name,"a+").write(VARIABLE_PART_2+str(second_bench)+"'\n")
		open(file_name,"a+").write(VARIABLE_PART_3)
		open(file_name,"a+").write("NAME_BENCH="+first_bench.split("/")[-1].split(" ")[0]+"_"+second_bench.split("/")[-1].split(" ")[0]+"\n")
		open(file_name,"a+").writelines([l for l in open(SECOND_PART_TEMPLATE).readlines()])
		subprocess.call(['chmod', '0755', file_name])
		current_file = current_file + 1

