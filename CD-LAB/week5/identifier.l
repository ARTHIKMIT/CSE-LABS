%{
#include <stdio.h>
%}

%%
[a-zA-Z_][a-zA-Z0-9_]*   printf("Identifier\n");
[ \t\n]+                ;   /* ignore spaces */
.                       ;   /* ignore other characters */
%%

int yywrap()
{
    return 1;
}

int main()
{
    printf("Enter input:\n");
    yylex();
    return 0;
}
