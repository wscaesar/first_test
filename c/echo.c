#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{       
        int re;
        char *a = "hello! Iam fine thank you !!!";
        char *file ="./test.txt"; 
        char bundle[100];
        sprintf(bundle, "echo \"[%s]\" > %s",a,file);
        re = system(bundle);
        re = system("cat test.txt");
        if(re)
        ;
        return 0;
}
