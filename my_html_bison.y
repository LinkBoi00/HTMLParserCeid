/* Declarations */
%{
    #include <stdbool.h>
    #include "stack.h" 
    extern int lineNumber;
    extern int yylex(void);
    extern int yyerror(char* s);
    extern FILE *yyin;
%}

%union{
    char* str;
}


%token <str> TEXT
%token START_MYHTML
%token CLOSING_MYHTML
%token START_HEAD
%token CLOSING_HEAD
%token START_TITLE
%token CLOSING_TITLE
%token EOL
%token SPACE


/* Rules */
%%
input:
    file
;

file:
    START_MYHTML head CLOSING_MYHTML {printf("compiles");}//<MYHTML> head...stuff </MYHTML>
;

head:
    START_HEAD title CLOSING_HEAD
;

title:
    START_TITLE TEXT CLOSING_TITLE
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

        yyparse(); //call the bison parser

        fclose(yyin);
    }
    
    return 0;
}

int yyerror(char* s) {
     printf("\nError: %s in line number %d \n", s, lineNumber);

    return 0;
}
