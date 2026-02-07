/*
1. Using getNextToken( ) implemented in Lab No 3, design a Lexical Analyser to implement the following symbol tables.
    a. local symbol table
    b. global symbol table
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#define MAX 50

typedef enum {
    KEYWORD, IDENTIFIER, NUMBER,
    OPERATOR, SPECIAL, END
} TokenType;

typedef struct {
    int row, col;
    TokenType type;
    char lexeme[MAX];
} Token;


typedef struct {
    char name[50];
    char datatype[20];
    int scope;      // 0 = global, 1 = local
} Symbol;

Symbol globalTable[50];
Symbol localTable[50];

int gCount = 0, lCount = 0;

char *keywords[] = {
    "int","float","char","if","else",
    "while","for","return","void","main"
};

int isKeyword(char *s) {
    for (int i = 0; i < 10; i++)
        if (!strcmp(s, keywords[i]))
            return 1;
    return 0;
}

int existsGlobal(char *name) {
    for (int i = 0; i < gCount; i++)
        if (!strcmp(globalTable[i].name, name))
            return 1;
    return 0;
}

int existsLocal(char *name) {
    for (int i = 0; i < lCount; i++)
        if (!strcmp(localTable[i].name, name))
            return 1;
    return 0;
}

void addGlobal(char *name, char *type) {
    if (existsGlobal(name)) return;
    strcpy(globalTable[gCount].name, name);
    strcpy(globalTable[gCount].datatype, type);
    globalTable[gCount].scope = 0;
    gCount++;
}

void addLocal(char *name, char *type) {
    if (existsLocal(name)) return;
    strcpy(localTable[lCount].name, name);
    strcpy(localTable[lCount].datatype, type);
    localTable[lCount].scope = 1;
    lCount++;
}

void displayTables() {
    int i;

    printf("\n\nGLOBAL SYMBOL TABLE\n");
    printf("-------------------\n");
    printf("Name\tType\n");
    for (i = 0; i < gCount; i++)
        printf("%s\t%s\n", globalTable[i].name, globalTable[i].datatype);

    printf("\nLOCAL SYMBOL TABLE\n");
    printf("------------------\n");
    printf("Name\tType\n");
    for (i = 0; i < lCount; i++)
        printf("%s\t%s\n", localTable[i].name, localTable[i].datatype);
}

Token getNextToken(FILE *fp) {
    static int row = 1, col = 0;
    Token t;
    char ch, next;
    int i;

    while ((ch = fgetc(fp)) != EOF) {
        col++;

        if (ch == '\n') {
            row++; col = 0;
            continue;
        }

        if (isspace(ch)) continue;

        if (ch == '#') {
            while ((ch = fgetc(fp)) != '\n' && ch != EOF);
            row++; col = 0;
            continue;
        }

        if (ch == '/') {
            next = fgetc(fp);
            if (next == '/') {
                while ((ch = fgetc(fp)) != '\n' && ch != EOF);
                row++; col = 0;
                continue;
            }
            if (next == '*') {
                char prev = 0;
                while ((ch = fgetc(fp)) != EOF) {
                    if (ch == '\n') {
                        row++; col = 0;
                    }
                    if (prev == '*' && ch == '/') break;
                    prev = ch;
                }
                continue;
            }
            ungetc(next, fp);
        }

        if (ch == '"') {
            while ((ch = fgetc(fp)) != '"' && ch != EOF)
                if (ch == '\n') {
                    row++; col = 0;
                }
            continue;
        }

        t.row = row;
        t.col = col;

        if (isalpha(ch) || ch == '_') {
            i = 0;
            t.lexeme[i++] = ch;
            while (isalnum(ch = fgetc(fp)) || ch == '_') {
                t.lexeme[i++] = ch;
                col++;
            }
            t.lexeme[i] = '\0';
            ungetc(ch, fp);

            t.type = isKeyword(t.lexeme) ? KEYWORD : IDENTIFIER;
            return t;
        }

        if (isdigit(ch)) {
            i = 0;
            t.lexeme[i++] = ch;
            while (isdigit(ch = fgetc(fp))) {
                t.lexeme[i++] = ch;
                col++;
            }
            t.lexeme[i] = '\0';
            ungetc(ch, fp);

            t.type = NUMBER;
            return t;
        }

        if (strchr("+-*/=<>&|!", ch)) {
            t.lexeme[0] = ch;
            t.lexeme[1] = '\0';
            t.type = OPERATOR;
            return t;
        }

        if (strchr(";(),{}[]", ch)) {
            t.lexeme[0] = ch;
            t.lexeme[1] = '\0';
            t.type = SPECIAL;
            return t;
        }
    }

    t.type = END;
    return t;
}

int main() {
    FILE *fp = fopen("test.c", "r");
    if (!fp) {
        printf("File not found\n");
        return 1;
    }

    Token t, prev;
    char currentType[20] = "";
    int scopeLevel = 0;
    int paramMode = 0;

    prev.type = END;

    while ((t = getNextToken(fp)).type != END) {

        if (t.type == SPECIAL && t.lexeme[0] == '(')
            paramMode = 1;
        else if (t.type == SPECIAL && t.lexeme[0] == ')')
            paramMode = 0;

        if (t.type == SPECIAL && t.lexeme[0] == '{')
            scopeLevel++;
        else if (t.type == SPECIAL && t.lexeme[0] == '}')
            scopeLevel--;

        if (t.type == KEYWORD &&
           (!strcmp(t.lexeme,"int") ||
            !strcmp(t.lexeme,"float") ||
            !strcmp(t.lexeme,"char") ||
            !strcmp(t.lexeme,"void"))) {

            strcpy(currentType, t.lexeme);
        }

        if (t.type == IDENTIFIER && prev.type == KEYWORD) {

            Token next = getNextToken(fp);

            if (next.lexeme[0] == '(') {
                addGlobal(t.lexeme, currentType);
            }
            else {
                if (!paramMode) {
                    if (scopeLevel == 0)
                        addGlobal(t.lexeme, currentType);
                    else
                        addLocal(t.lexeme, currentType);
                }
            }

            prev = next;
            continue;
        }

        prev = t;
    }

    displayTables();
    fclose(fp);
    return 0;
}
