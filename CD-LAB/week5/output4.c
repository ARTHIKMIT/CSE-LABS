#include <stdio.h>

int main() {
    int a, b;
    WRITE
("Enter two numbers: ");
    READ
("%d %d", &a, &b);
    WRITE
("Sum = %d\n", a + b);
    return 0;
}


Number of scanf  : 1
Number of printf : 2
