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

%union {
    int num;
}

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE
%token TITLE_OPEN TITLE_CLOSE META_OPEN P_OPEN P_CLOSE A_OPEN A_CLOSE
%token IMG_OPEN

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF
%token ATTR_SRC ATTR_ALT ATTR_HEIGHT ATTR_WIDTH

%token QUOTE TAG_CLOSE
%token<num> NUMBER
%token TEXT 

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
    HEAD_OPEN head_title_section head_meta_section HEAD_CLOSE
;

head_title_section:
    TITLE_OPEN text TITLE_CLOSE
;

head_meta_section:
    /* empty */
    | head_meta_section meta_tag
;

meta_tag:
    META_OPEN attr_name attr_content TAG_CLOSE
    | META_OPEN attr_charset TAG_CLOSE
;

body:
    BODY_OPEN body_tags BODY_CLOSE
;

body_tags:
    /* empty */
    | body_tags p_tag
    | body_tags a_tag
    | body_tags img_tag
;

p_tag:
    P_OPEN attr_id attr_style TAG_CLOSE text P_CLOSE
    | P_OPEN attr_id TAG_CLOSE text P_CLOSE
;

a_tag:
    A_OPEN attr_id attr_href TAG_CLOSE text A_CLOSE
    | A_OPEN attr_id attr_href TAG_CLOSE A_CLOSE
;

img_tag:
    IMG_OPEN img_attributes TAG_CLOSE
;

img_attributes:
    /* empty */
   | img_attributes attr_src
   | img_attributes attr_alt
   | img_attributes attr_id
   | img_attributes attr_height
   | img_attributes attr_width
;

attr_name:
    ATTR_NAME QUOTE text QUOTE
;

attr_content:
    ATTR_CONTENT QUOTE text QUOTE
;

attr_charset:
    ATTR_CHARSET QUOTE text QUOTE
;

attr_id:
    ATTR_ID QUOTE text QUOTE
;

attr_style:
    ATTR_STYLE QUOTE text QUOTE
;

attr_href:
    ATTR_HREF QUOTE text QUOTE
;

attr_src:
    ATTR_SRC QUOTE text QUOTE
;

attr_alt:
    ATTR_ALT QUOTE text QUOTE 
;

attr_height:
    ATTR_HEIGHT NUMBER { if($2 <= 0) yyerror("Height must a positive integer"); }
;

attr_width:
    ATTR_WIDTH NUMBER  { if($2 <= 0) yyerror("Width must a positive integer"); }
;

text:
    TEXT
    | NUMBER
    | text TEXT
    | text NUMBER
;
%%

/* C code */
int main(int argc, char** argv) {
    bool inputFromFile = false;

    yydebug = 0; // TEMP: Enable debugging

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
