#include <stdio.h>
void fun(int *);
int main (int argc, char *argv[])
{
        int *p, a = 2;
        a++;
        p = &a;
       fun(p); 
       printf("%d\n",a);
        return 0;
}
 
void fun (int *a)
{
        int b = 3;
        b++;
        b+=*a;
        *a = b;
}
