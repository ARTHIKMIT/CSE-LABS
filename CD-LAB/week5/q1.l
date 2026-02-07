%{
#include <stdio.h>

int vowels = 0;
int consonants = 0;
%}

%%
[aeiouAEIOU]        { vowels++; }
[b-df-hj-np-tv-zB-DF-HJ-NP-TV-Z] { consonants++; }
\n                  { /* ignore newline */ }
.                   { /* ignore other characters */ }
%%

int main()
{
    printf("Enter input text:\n");
    yylex();
    printf("Number of vowels     : %d\n", vowels);
    printf("Number of consonants : %d\n", consonants);
    return 0;
}

int yywrap()
{
    return 1;
}
