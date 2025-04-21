/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>

    #define YYDEBUG 1

    int id_flag=0;
    void check_id_flag(int* id);
    extern int yylex(void);
    extern int yyerror(char* s);
    extern int lineNumber;
    extern FILE *yyin;
%}

/*for some reason it has warnings in grammar and crashes*/

//επισης καθε ενα που εχει =πχ id μπορει να εχει κενα,μαλλον 
//πρεπει να ορισουμε εναν κανονα = EQUALLS και να κανουμε αλλαγες ετσι 
//ωστε αν υπαρχει κενο στο = να μην βγαλει λαθος

%debug // TEMP: Enable debugging

%union{
    int num;
}

%token COMMENT_OPEN COMMENT_CLOSE COMMENT_ERROR

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE
%token TITLE_OPEN TITLE_CLOSE META_OPEN P_OPEN P_CLOSE A_OPEN A_CLOSE

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF

%token QUOTE TAG_CLOSE SINGLE_QUOTE
%token TEXT

%token IMG_OPEN ATTR_SRC ATTR_ALT ATTR_HEIGHT ATTR_WIDTH 
%token<num> INTEGER

%token FORM_OPEN FORM_CLOSE
%token LABEL_OPEN LABEL_CLOSE FOR
%token INPUT_OPEN TYPE VALUE
%token DIV_OPEN DIV_CLOSE

/* Rules */
%%
input:
    myhtml_file
;

myhtml_file:
    MYHTML_OPEN head body MYHTML_CLOSE {printf("compiles\n");}
    | MYHTML_OPEN body MYHTML_CLOSE {printf("compiles\n"); }
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
    | body_tags form_tag
    | body_tags div_tag
;

p_tag:
    p_section text P_CLOSE
;

p_section:
    P_OPEN p_children TAG_CLOSE
    {
        id_flag=0;
    }
;

p_children:
    /*empty children this is a mistake its children cant be empty*/
    |p_children attr_id
    |p_children attr_style
;

a_tag:
    a_tag_section text A_CLOSE 
    | a_tag_section A_CLOSE
    | a_tag_section text img_tag A_CLOSE
    | a_tag_section img_tag text A_CLOSE
    {
        id_flag = 0;
    }
;

a_tag_section:
    A_OPEN a_tag_children TAG_CLOSE{
        id_flag = 0;
    }
;

a_tag_children:
    /* empty */
    |a_tag_children attr_id
    |a_tag_children attr_href
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
    ATTR_ID QUOTE text QUOTE {
        check_id_flag(&id_flag);
    }
;

attr_style:
    ATTR_STYLE QUOTE text QUOTE
;

attr_type:
    TYPE QUOTE text QUOTE
;

attr_for:
    FOR QUOTE text QUOTE
;

attr_href:
    ATTR_HREF QUOTE text QUOTE
;

attr_value:
    VALUE SINGLE_QUOTE text SINGLE_QUOTE
;

img_tag:
    IMG_OPEN img_attributes TAG_CLOSE {
        id_flag = 0;
    }
;

img_attributes:
   |img_attributes ATTR_SRC QUOTE text QUOTE
   |img_attributes ATTR_ALT QUOTE text QUOTE 
   |img_attributes attr_id 
   |img_attributes ATTR_HEIGHT INTEGER {if($3 <= 0) yyerror("height must a positive integer");}
   |img_attributes ATTR_WIDTH INTEGER  {if($3 <= 0) yyerror("width must a positive integer");}
;

form_tag:
    form_section form_body FORM_CLOSE
    {
        id_flag = 0;
    }
;

form_section:
    /*wrong for some reason it has conflicts*/
    |FORM_OPEN form_children TAG_CLOSE{
        id_flag = 0;
    }
;

form_children:
    /*wrong should not be empty*/
    |form_children attr_id
    |form_children attr_style
;

form_body:
    |form_body input_tag
    |form_body label_tag
;

input_tag:
    INPUT_OPEN input_section TAG_CLOSE //<input section >
    {
        id_flag = 0;
    }
;

input_section:
    |input_section attr_type
    |input_section attr_id
    |input_section attr_style
    |input_section attr_value
;

label_tag:
    label_section text LABEL_CLOSE{
        id_flag = 0;
    }
;

label_section:
    LABEL_OPEN label_children TAG_CLOSE{
        id_flag=0;
    }
;

label_children:
    /*empty*/
    |label_children attr_for
    |label_children attr_style
    |label_children attr_id
;

div_tag:
    div_section div_children DIV_CLOSE//<div id style > <a> <p> ... </div>
    {
        id_flag = 0;
    }
    |div_section /*empty*/  DIV_CLOSE
;

div_section:
    DIV_OPEN div_attr TAG_CLOSE{
        id_flag=0;
    }
;

div_attr:
    |div_attr attr_style
    |div_attr attr_id
;

div_children:
    |div_children p_tag
    |div_children a_tag
    |div_children img_tag
    |div_children form_tag
;


//comment:
//    /* empty */
//    |COMMENT_OPEN /*no text*/  COMMENT_CLOSE
//    |COMMENT_OPEN text COMMENT_CLOSE
//;

text:
    TEXT
    | text TEXT
;
%%
/* C code */

void check_id_flag(int* id){
    (*id)++;
    if(*id == 2){
        yyerror("Duplicate attribute ");
    }
    //printf("line:%d id:%d\n",lineNumber,id_flag);
}

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

    exit(1);
}