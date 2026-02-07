%{
#include <stdio.h>

int scanfCount = 0;
int printfCount = 0;
%}

%%
scanf           { printf("READ\n"); scanfCount++; }
printf          { printf("WRITE\n"); printfCount++; }
.|\n            { printf("%s", yytext); }   /* print everything else as-is */
%%

int main()
{
    yylex();
    printf("\n\nNumber of scanf  : %d\n", scanfCount);
    printf("Number of printf : %d\n", printfCount);
    return 0;
}

int yywrap()
{
    return 1;
}
