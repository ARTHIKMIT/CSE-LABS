%{
#include <stdio.h>

int posInt = 0;
int negInt = 0;
int posFloat = 0;
int negFloat = 0;
%}

%%
[-][0-9]+"."[0-9]+    { negFloat++; }
[+][0-9]+"."[0-9]+    { posFloat++; }
[0-9]+"."[0-9]+       { posFloat++; }

[-][0-9]+             { negInt++; }
[+][0-9]+             { posInt++; }
[0-9]+                { posInt++; }

[ \t\n]+              ;   /* ignore spaces */
.                     ;   /* ignore other characters */
%%

int main()
{
    printf("Enter input:\n");
    yylex();
    printf("\nPositive Integers        : %d", posInt);
    printf("\nNegative Integers        : %d", negInt);
    printf("\nPositive Floating Numbers: %d", posFloat);
    printf("\nNegative Floating Numbers: %d\n", negFloat);
    return 0;
}

int yywrap()
{
    return 1;
}
