#include <stdio.h>

int main (int argc, char *argv[])
{
        FILE *fp;
        char buffer[4096];
        fp = popen("mount ","r");
        fread(buffer,sizeof(char),sizeof(buffer),fp);
        printf("%s\n",buffer);
        pclose(fp);
        return 0;
}
