/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>

// Declare the lexical analyzer function
    extern int yyerror();
    extern int yylex();
    extern FILE *yyin;
%}

%union{
    char* str;
}

%token EOL
%token<str> WORD
%token SPACE

/* Rules */
%%
input:
    | input line
    | line
;

line:
    EOL { printf("\n"); }
    | SPACE { printf(" "); }
    | WORD { printf("%s",$1); free($1); }
;

%%

/* C code */
int main(int argc,char** argv){
    
    if (argc >1){
        yyin=fopen(argv[1], "r");

        if(!yyin){
            perror("file not oppening or doesnt exist");
            return 1;
        }
    }

    yyparse(); //call the bison parser

    if(argc>1) fclose(yyin);
    
    return 0;
}

int yyerror(char* s){
    printf("Error:%s", s);
    
    return 0;
}
