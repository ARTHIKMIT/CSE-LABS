%{
#include <stdio.h>
#include <string.h>

int words = 0;
int chars = 0;
int blanks = 0;
int lines = 0;
%}

%%
[ \t]+          { blanks += yyleng; chars += yyleng; }
\n              { lines++; chars++; }
[a-zA-Z0-9]+    { words++; chars += yyleng; }
.               { chars++; }
%%

int main()
{
    printf("Enter the text:\n");
    yylex();
    printf("\nNumber of lines      : %d", lines);
    printf("\nNumber of words      : %d", words);
    printf("\nNumber of blanks     : %d", blanks);
    printf("\nNumber of characters : %d\n", chars);
    return 0;
}

int yywrap()
{
    return 1;
}
