/* Declarations */
%{
    #include <stdbool.h>
    #include "stack.h" 

    extern int yylex(void);
    extern int yyerror(char* s);
    extern FILE *yyin;
    extern Stack *st;
%}

%union {
    char* str;
}

%token EOL
%token<str> WORD
%token SPACE

/* Rules */
%%
input:
    | input line
;

line:
    EOL         { printf("\n"); }
    | SPACE     { printf(" "); }
    | WORD      { printf("%s", $1); free($1); }
;
%%

/* C code */
int main(int argc, char** argv) {
    bool inputFromFile = false;

    // Determine if we will be using a file or stdin as input
    if (argc > 1)
        inputFromFile = true;

    // Open the input file, if applicable
    if (inputFromFile) {
        FILE *file = fopen(argv[1], "r");

        if (!file) {
            fprintf(stderr, "Cannot open file %s\n", argv[1]);
            exit(1);
        }

        yyin = file;
    }

    // Call the bison parser
    yyparse();

    // Close the input file, if applicable
    if (inputFromFile)
        fclose(yyin);

    return 0;
}

int yyerror(char* s) {
    printf("Error: %s\n", s);

    return 0;
}
