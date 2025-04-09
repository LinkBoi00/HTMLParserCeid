/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>

    #define YYDEBUG 1

    extern int yylex(void);
    extern int yyerror(char* s);

    extern int lineNumber;
    extern FILE *yyin;
%}

%debug // TEMP: Enable debugging

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE
%token HEAD_TITLE_OPEN TEXT_VALUE_CONTENT HEAD_TITLE_CLOSE
%token HEAD_META_START
%token HEAD_META_NAME HEAD_META_CONTENT HEAD_META_CHARSET

%token BODY_OPEN BODY_CLOSE
%token BODY_P_START BODY_P_CLOSE

%token QUOTE
%token ATTR_ID ATTR_STYLE
%token ATTR_VALUE_CONTENT
%token TAG_CLOSE
%token ERROR

/* Rules */
%%
input:
    myhtml_file
;

myhtml_file:
    MYHTML_OPEN head body MYHTML_CLOSE
    | MYHTML_OPEN body MYHTML_CLOSE
;

head:
    HEAD_OPEN title_section meta_section HEAD_CLOSE
;

title_section:
    HEAD_TITLE_OPEN TEXT_VALUE_CONTENT HEAD_TITLE_CLOSE
;

meta_section:
    /* empty */
    | meta_section meta_tag
;

meta_tag:
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

body:
//    BODY_OPEN body_children BODY_CLOSE
    BODY_OPEN p_section BODY_CLOSE
;

/*
body_children:

    | p_section body_children
    | a_section body_children
    | img_section body_children
    | form_section body_children
    | div_section body_children
;
*/

p_section:
    /* empty */
    | p_section p_tag
;

p_tag:
    BODY_P_START attr_id TAG_CLOSE BODY_P_CLOSE
;

attr_id:
    ATTR_ID ATTR_VALUE_CONTENT ATTR_STYLE ATTR_VALUE_CONTENT
;


%%

/* C code */
int main(int argc, char** argv) {
    bool inputFromFile = false;

    yydebug = 1; // TEMP: Enable debugging

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
