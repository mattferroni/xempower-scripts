#include<stdio.h>
#include<unistd.h>
#include<termios.h>
#include<errno.h>


int main(int argc, char **argv){

    char before_char,current_char;
    int check_on,scan,ret;
    FILE *fp,*output;
    struct termios t;

    if(argc < 3){
    	printf("You have to specify the tty (/dev/tty*) and the output file\n");
    	return -1;
    }
    if ((fp = fopen(argv[1],"r")) == NULL) {
        printf("Error opening pipe!\n");
        return -1;
    }

    if((output = fopen(argv[2],"a+")) == NULL){
    	printf("Error creating output file!\n");
        return -1;
    }

    scan = 1;
    check_on = 0;
    before_char = 0;

    int fd = fileno(fp);
    ret = tcgetattr(fd, &t);
    
    if(ret){
    	printf("error %d\n",errno);
    	return -1;
    }
	
	cfmakeraw(&t);
	cfsetispeed(&t, B115200);
	cfsetospeed(&t, B115200);
	tcflush(fd, TCIFLUSH);
	t.c_iflag |= IGNPAR;
	t.c_cflag &= ~(CSTOPB | CSIZE);
	t.c_cflag |= CS8;
	ret = tcsetattr(fd, TCSANOW, &t);
	
	if(ret){
    	printf("error %d\n",errno);
    	return -1;
    }

    
    while (scan) {
    	current_char = (char)fgetc(fp);
        if(before_char == '#' && current_char == 'l'){
           check_on = 1;	
        }
        if(check_on == 1 && current_char == ';'){
        	scan = 0;
        }
        fprintf(output,"%c",current_char);
        before_char = current_char;
    }
    fprintf(output,"\n");
	fflush(output);
	fclose(output);
	fflush(fp);
	fclose(fp);
  	
    return 0;
}