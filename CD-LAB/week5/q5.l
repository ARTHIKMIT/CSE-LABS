%{
#include <stdio.h>
#include <stdlib.h>
%}

%%
[0-9]+     { 
              int num = atoi(yytext);         // Convert string to integer
              printf("Decimal: %d -> Hexadecimal: 0x%X\n", num, num);
           }
.|\n       { printf("%s", yytext); }       // Print other characters as-is
%%

int main() {
    printf("Enter text with decimal numbers:\n");
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
