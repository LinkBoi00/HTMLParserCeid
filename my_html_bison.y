/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>

    #define YYDEBUG 1

    int id_flag=0;
    int name_flag=0;
    int content_flag=0;
    int charset_flag=0;
    int style_flag=0;
    int type_flag=0;
    int for_flag=0;
    int href_flag=0;
    int value_flag=0;
    int src_flag=0;
    int alt_flag=0;
    int height_flag=0;
    int width_flag=0;

    void check_id_flag(int* id);
    void attr_error();
    extern int yylex(void);
    extern int yyerror(char* s);
    extern int lineNumber;
    extern FILE *yyin;
%}

//also title crashes when it sees a tag inside it.should it crash or shou it treat the tag as text?.

%debug // TEMP: Enable debugging

%union{
    int num;
}

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE
%token TITLE_OPEN TITLE_CLOSE META_OPEN P_OPEN P_CLOSE A_OPEN A_CLOSE

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF

%token TAG_CLOSE
%token TEXT ERROR EQUALLS

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
    META_OPEN attr_name attr_content TAG_CLOSE {
        name_flag=0;
        content_flag=0;
    }
    | META_OPEN attr_charset TAG_CLOSE {
        charset_flag=0;
    }
;

body:
    BODY_OPEN body_children BODY_CLOSE
;

body_children:
    /* empty */
    | body_children p_tag
    | body_children a_tag
    | body_children img_tag 
    | body_children form_tag
    | body_children div_tag
;

p_tag:
    p_section text P_CLOSE
;

p_section:
    P_OPEN p_attr TAG_CLOSE
    {
        if(id_flag == 0 ) attr_error();
        id_flag=0;
        style_flag=0;
    }
;

p_attr:
    /*should not be empty*/
    |p_attr attr_id
    |p_attr attr_style
;

a_tag:
    a_tag_section text A_CLOSE
    |a_tag_section text img_tag A_CLOSE //conflict with these 2 lines in case text is empty they are the same line essentially
    |a_tag_section img_tag text A_CLOSE //the conflict lies here
;

a_tag_section:
    A_OPEN a_attr TAG_CLOSE{
        if(id_flag == 0 || href_flag == 0 ) attr_error();
        id_flag = 0;
        href_flag = 0;
    }
;

a_attr:
     /*it shouldnt be empty but flags save us*/
    |a_attr attr_id
    |a_attr attr_href
;

img_tag:
    IMG_OPEN img_attributes TAG_CLOSE {
        if(id_flag == 0 || src_flag == 0 || alt_flag == 0) attr_error();
        id_flag = 0;
        height_flag=0;
        width_flag=0;
        src_flag=0;
        alt_flag=0;
    }
;

img_attributes:
    /*there should not be an empty but our flag checks save us*/
   |img_attributes attr_src
   |img_attributes attr_alt
   |img_attributes attr_id 
   |img_attributes ATTR_HEIGHT INTEGER {
        if($3 <= 0) yyerror("height must a positive integer");
        check_id_flag(&height_flag);
    }
   |img_attributes ATTR_WIDTH INTEGER  {
        if($3 <= 0) yyerror("width must a positive integer");
        check_id_flag(&width_flag);
   }
;

form_tag:
    form_section form_children FORM_CLOSE
;

form_section:
    FORM_OPEN form_attr TAG_CLOSE{
        if(id_flag == 0) attr_error();
        id_flag = 0;
        style_flag = 0;
    }
;

form_attr:
    /*form attributes cant be empty but in case it is empty our flag checks save us*/
    |form_attr attr_id
    |form_attr attr_style 
;

form_children:
    input_tag
    | label_tag
    |form_children input_tag 
    |form_children label_tag 
;

input_tag:
    INPUT_OPEN input_attr TAG_CLOSE //<input section >
    {
        if(id_flag == 0 || type_flag == 0) attr_error();
        id_flag = 0;
        type_flag = 0;
        style_flag=0;
        value_flag=0;
    }
;

input_attr:
    /*error should not be empty flag checks save us*/
    |input_attr attr_type
    |input_attr attr_id
    |input_attr attr_style
    |input_attr attr_value
;

label_tag:
    label_section text LABEL_CLOSE
;

label_section:
    LABEL_OPEN label_attr TAG_CLOSE{
        if(id_flag == 0 || for_flag == 0) attr_error();
        id_flag=0;
        for_flag=0;
        style_flag=0;
    }
;

label_attr:
    /*empty*/
    |label_attr attr_for
    |label_attr attr_style
    |label_attr attr_id
;

div_tag:
    div_section div_children DIV_CLOSE
    |div_section /*empty*/  DIV_CLOSE
;

div_section:
    DIV_OPEN div_attr TAG_CLOSE{
        if(id_flag==0) attr_error();
        id_flag=0;
        style_flag=0;
    }
;

div_attr:
    /*empty rule but flag checks save us again*/
    |div_attr attr_style
    |div_attr attr_id
;

div_children:
    p_tag
    |a_tag
    |img_tag
    |form_tag
    |div_children p_tag
    |div_children a_tag
    |div_children img_tag
    |div_children form_tag
;

attr_name:
    ATTR_NAME EQUALLS text {
        check_id_flag(&name_flag);
    }
;

attr_content:
    ATTR_CONTENT EQUALLS text  {
        check_id_flag(&content_flag);
    }
;

attr_charset:
    ATTR_CHARSET EQUALLS text  {
        check_id_flag(&charset_flag);
    }
;

attr_id:
    ATTR_ID EQUALLS  text  {
        check_id_flag(&id_flag);
    }
;

attr_style:
    ATTR_STYLE EQUALLS  text  {
        check_id_flag(&style_flag);
    }
;

attr_type:
    TYPE EQUALLS  text  {
        check_id_flag(&type_flag);
    }
;

attr_for:
    FOR EQUALLS  text  {
        check_id_flag(&for_flag);
    }
;

attr_href:
    ATTR_HREF EQUALLS  text  {
        check_id_flag(&href_flag);
    }
;

attr_value:
    VALUE EQUALLS text {
        check_id_flag(&value_flag);
    }
;

attr_src:
    ATTR_SRC EQUALLS text {
        check_id_flag(&src_flag);
    }
;

attr_alt:
    ATTR_ALT EQUALLS text  {
        check_id_flag(&alt_flag);
    }
;
 
text:
        
    |text TEXT
;
%%
/* C code */

void check_id_flag(int* id){
    (*id)++;
    if(*id == 2){
        yyerror("Duplicate attribute ");
    }
}

void attr_error(){
    yyerror("too few attributes");
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