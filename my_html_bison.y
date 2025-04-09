/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>

    extern int yylex(void);
    extern int yyerror(char* s);

    extern int lineNumber;
    extern FILE *yyin;
%}

%token MYHTML_OPEN MYHTML_CLOSE
%token HEAD_OPEN HEAD_CLOSE
%token HEAD_TITLE_OPEN HEAD_TITLE_CONTENT HEAD_TITLE_CLOSE
%token HEAD_META_START
%token HEAD_META_NAME HEAD_META_CONTENT HEAD_META_CHARSET

%token QUOTE
%token ATTR_VALUE_CONTENT
%token TAG_CLOSE
%token ERROR

/* Rules */
%%
input:
    myhtml_file
;

myhtml_file:
    MYHTML_OPEN head MYHTML_CLOSE
;

head:
    HEAD_OPEN title meta HEAD_CLOSE
;

title:
    HEAD_TITLE_OPEN HEAD_TITLE_CONTENT HEAD_TITLE_CLOSE
;

meta:
    /* empty */
    | meta meta_attr
;

meta_attr:
    HEAD_META_START meta_attr_name meta_attr_content TAG_CLOSE
    | HEAD_META_START meta_attr_charset TAG_CLOSE
;

meta_attr_name:
    HEAD_META_NAME QUOTE ATTR_VALUE_CONTENT QUOTE
;

meta_attr_content:
    HEAD_META_CONTENT QUOTE ATTR_VALUE_CONTENT QUOTE
;

meta_attr_charset:
    HEAD_META_CHARSET QUOTE ATTR_VALUE_CONTENT QUOTE
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
    printf("\nError: %s in line number %d \n", s, lineNumber);

    return 0;
}
