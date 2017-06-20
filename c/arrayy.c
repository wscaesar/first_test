#include <stdio.h>
#include <string.h>

int main (int argc, char *argv[])
{
        char a[] = 
        {
                [0] = 'a',
                [1] = 'b',
                [2] = '\0'
        };
        printf("%s\n",a);       
        return 0;
}

