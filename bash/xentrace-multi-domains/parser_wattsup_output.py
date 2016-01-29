import os,sys

if len(sys.argv) < 3:
	print "You have to specify the source and output files\n"
	sys.exit(-1)

with open(sys.argv[2],"a+") as output:
	with open(sys.argv[1]) as f:
	    content = f.readlines()
	    for line in content:
	    	data_line = line.split(",")
	    	power = data_line[3]
	    	if power.isdigit():
	    		output.write(str(float(power)/10)+"\n")


