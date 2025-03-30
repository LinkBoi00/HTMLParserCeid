/* Declarations */
%{
extern int yylex(void);
extern int yyerror(char* s);
%}

/* Rules */
%%
input:

%%

/* C code */
int main(int argc, char** argv) {
    printf("Hello World from bison\n");

    return 0;
}

int yyerror(char* s) {
    printf("Error: %s\n", s);

    return 0;
}
