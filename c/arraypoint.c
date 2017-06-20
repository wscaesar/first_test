#include<stdio.h>

char * fun(char *p)
{
        char ap[6];
        ap[0] = 'h';
        ap[1] = 'e';
        ap[2] = 'l';
        ap[3] = 'l';
        ap[4] = 'o';
        ap[5] = '0';
        
        p = ap;
        printf("fun-%s\n",p); 
        return p;
}

int main (int argc, char *argv[])
{
        char *p = "world";
        p = fun(p);
        printf("main-%s\n",p); 
        return 0;
}
