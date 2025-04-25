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
%token IMG_OPEN FORM_OPEN FORM_CLOSE LABEL_OPEN LABEL_CLOSE INPUT_OPEN DIV_OPEN DIV_CLOSE

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF
%token ATTR_SRC ATTR_ALT ATTR_HEIGHT ATTR_WIDTH ATTR_FOR ATTR_TYPE ATTR_VALUE

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
    META_OPEN meta_tag_attributes TAG_CLOSE
;

meta_tag_attributes:
    attr_name attr_content
    | attr_charset
;

body:
    BODY_OPEN body_tags BODY_CLOSE
;

body_tags:
    /* empty */
    | body_tags p_tag
    | body_tags a_tag
    | body_tags img_tag
    | body_tags form_tag
    | body_tags div_tag
;

p_tag:
    P_OPEN p_tag_attributes TAG_CLOSE /* empty */ P_CLOSE
    | P_OPEN p_tag_attributes TAG_CLOSE text P_CLOSE
;

p_tag_attributes:
    attr_id
    | attr_id attr_style
    | attr_style attr_id
;

a_tag:
    a_tag_section /* empty */ A_CLOSE
    | a_tag_section img_tag text A_CLOSE
    | a_tag_section text img_tag A_CLOSE
    | a_tag_section text A_CLOSE
;

a_tag_section:
    A_OPEN a_tag_attributes TAG_CLOSE
;

a_tag_attributes:
    attr_id attr_href
    | attr_href attr_id
;

img_tag:
    IMG_OPEN img_attributes TAG_CLOSE
;

img_attributes:
    /* Should not be empty */
   | img_attributes attr_src
   | img_attributes attr_alt
   | img_attributes attr_id
   | img_attributes attr_height
   | img_attributes attr_width
;

form_tag:
    FORM_OPEN form_attributes TAG_CLOSE form_children FORM_CLOSE
;

form_attributes:
    attr_id
    | attr_id attr_style
;

form_children:
    input_tag
    | label_tag
    | form_children input_tag
    | form_children label_tag
;

input_tag:
    INPUT_OPEN input_attributes TAG_CLOSE
;

input_attributes:
    /* Should not be empty */ 
    | input_attributes attr_type
    | input_attributes attr_id
    | input_attributes attr_style
    | input_attributes attr_value
;

label_tag:
    LABEL_OPEN label_attributes TAG_CLOSE text LABEL_CLOSE
;

label_attributes:
    /* Should not be empty */
    | label_attributes attr_for
    | label_attributes attr_style
    | label_attributes attr_id
;

div_tag:
    DIV_OPEN div_attributes TAG_CLOSE div_children DIV_CLOSE
;

div_attributes:
    attr_id attr_style
    | attr_style attr_id
;

div_children:
    /* empty */
    | div_children p_tag
    | div_children a_tag
    | div_children img_tag
    | div_children form_tag
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

attr_type:
    ATTR_TYPE QUOTE text QUOTE
;

attr_for:
    ATTR_FOR QUOTE text QUOTE
;

attr_value:
    ATTR_VALUE QUOTE text QUOTE
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
