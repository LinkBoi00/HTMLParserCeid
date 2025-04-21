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

/*εχουμε προβλημα στο γεγονος πως το id και τα χαρακτηριστηκα απο καθε 
tag μπορουν να εμφανιστουν οπως να ειναι οποτε η πρεπει να κανουμε διακριτα μαθ
για να βρουμε ολους τους δυνατους συνδιασμους η να βαλουμε flags globaly τα οποια θα 
γινονται 0 μολις τελειωσει ο συνολικος κανονας.*/

//επισης καθε ενα που εχει =πχ id μπορει να εχει κενα,μαλλον 
//πρεπει να ορισουμε εναν κανονα = EQUALLS και να κανουμε αλλαγες ετσι 
//ωστε αν υπαρχει κενο στο = να μην βγαλει λαθος

//can value have " inside??? and can the others have that too?? wont we have a problem with the QUOTE token

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
    | body_tags img_tag //its a bit unclear if he wants the image tag to also belong to the body tag
    | body_tags form_tag
    | body_tags div_tag
;

p_tag:
    P_OPEN attr_id attr_style TAG_CLOSE text P_CLOSE
    | P_OPEN attr_style attr_id TAG_CLOSE text P_CLOSE
    | P_OPEN attr_id TAG_CLOSE text P_CLOSE
;

a_tag:
    A_OPEN attr_id attr_href TAG_CLOSE text A_CLOSE 
    | A_OPEN attr_id attr_href TAG_CLOSE A_CLOSE
    | A_OPEN attr_id attr_href TAG_CLOSE text img_tag A_CLOSE
    | A_OPEN attr_id attr_href TAG_CLOSE img_tag text A_CLOSE
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
    /*empty*/
    |ATTR_STYLE QUOTE text QUOTE
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
   |img_attributes attr_id {
       check_id_flag(&id_flag);
   }
   |img_attributes ATTR_HEIGHT INTEGER {if($3 <= 0) yyerror("height must a positive integer");}
   |img_attributes ATTR_WIDTH INTEGER  {if($3 <= 0) yyerror("width must a positive integer");}
;

form_tag:
    FORM_OPEN attr_id attr_style TAG_CLOSE form_body FORM_CLOSE
    |FORM_OPEN attr_style attr_id TAG_CLOSE form_body FORM_CLOSE
;

form_body:
    |form_body input_tag
    |form_body label_tag
;

input_tag:
    INPUT_OPEN input_section TAG_CLOSE //<input section >
;

input_section:
    |input_section attr_type
    |input_section attr_id
    |input_section attr_style
    |input_section attr_value
;

label_tag:
    LABEL_OPEN label_section TAG_CLOSE text LABEL_CLOSE
;

label_section:
    |label_section attr_for
    |label_section attr_style
    |label_section attr_id
;

div_tag:
    DIV_OPEN div_attr TAG_CLOSE div_children DIV_CLOSE//<div id style > <a> <p> ... </div>
    |DIV_OPEN div_attr TAG_CLOSE /*empty*/  DIV_CLOSE//<div id style > </div>
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