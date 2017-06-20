#include <stdio.h>

int main (int argc, char *argv[])
{
        int i;
        for (i = 0; i < argc; i++ ){
        printf("argv[%d] =%s\n",i,argv[i]);
        }
        printf("[%s:%s:%d:%s:%s]\n",__FILE__,__func__,__LINE__,__TIME__,__DATE__);
        return 0;
}
