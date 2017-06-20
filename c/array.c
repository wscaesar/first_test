#include <stdio.h>

int main (int argc, char *argv[])
{
        struct poz
        {
                int a;
                int b ;
        };
        struct poz pozume[8];
        printf("%ld\n",sizeof(pozume)/sizeof(pozume[0]));
        
        
        return 0;
}
