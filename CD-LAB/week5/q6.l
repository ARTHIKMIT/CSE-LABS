%{
#include <ctype.h>
#include <stdio.h>
int inComment = 0;  // Flag to track if we are inside a comment
%}

%%
"/*"                { inComment = 1; printf("/*"); }
"*/"                { inComment = 0; printf("*/"); }
"//".*              { printf("%s\n", yytext); }   // Print single-line comments as-is
.                   { 
                        if (!inComment) {
                            if (isupper(yytext[0]))
                                printf("%c", tolower(yytext[0]));
                            else
                                printf("%c", yytext[0]);
                        } else {
                            printf("%c", yytext[0]); // Inside block comment, print as-is
                        }
                    }
\n                  { printf("\n"); }
%%

int main() {
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}
