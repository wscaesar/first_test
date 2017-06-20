#include <stdio.h>
#include <string.h>

int main (int argc, char *argv[])
{
        /*在字符串中添加'\0'可以截断字符串*/
        char *a;
        char b[20] = "asdfg*gfghgh";
        a = strchr(b,'*');
        *a = '\0';
        a ++;
        printf("a = %s\nb = %s\n",a,b);
        return 0;
}
