#include<stdio.h>
#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>
int main (int argc, char *argv[])
{
        char *msg="I‘m fine!!!";
        char info[20];
        sprintf(info,"%s",msg);
        printf("%s\n",info);
        return 0;
}
