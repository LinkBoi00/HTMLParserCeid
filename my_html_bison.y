/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include "linked_list.h"

    #define YYDEBUG 1

    extern int yylex(void);
    extern int yyerror(char* s);
    
    extern int lineNumber;
    extern int title_size;
    extern FILE *yyin;

    bool parse_success = true;
    Linked_list* id_list;
%}

%code requires {
    struct Attributes {
        int has_id;
        int has_src;
        int has_alt;
        int has_type;
        int has_width;
        int has_height;
        int has_style;
        int has_value;
    } typedef Attributes;

    void validateImgAttrs(Attributes attrs);
    void validateInputAttrs(Attributes attrs);
}

%debug // TEMP: Enable debugging

%union {
    Attributes attrs;
    int num;
    char* str;
}

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE
%token TITLE_OPEN TITLE_CLOSE META_OPEN P_OPEN P_CLOSE A_OPEN A_CLOSE
%token IMG_OPEN FORM_OPEN FORM_CLOSE LABEL_OPEN LABEL_CLOSE INPUT_OPEN DIV_OPEN DIV_CLOSE

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF
%token ATTR_SRC ATTR_ALT ATTR_HEIGHT ATTR_WIDTH ATTR_FOR ATTR_TYPE ATTR_VALUE

%token EQUALS TAG_CLOSE
%token<num> NUMBER
%token<str> QUOTED_STRING
%token TEXT ERROR

%type<attrs> img_attributes input_attributes

%destructor { free($$); } <str> //destructor to automatically free memory of strings
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
    TITLE_OPEN text TITLE_CLOSE {
        if (title_size > 60) yyerror("Title size is larger than 60 characters");
    }
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
    IMG_OPEN img_attributes TAG_CLOSE {
        validateImgAttrs($2);
    }
;

img_attributes:
    {
        $$ = (Attributes){0, 0, 0, 0, 0, 0, 0, 0};
    }
   | img_attributes attr_src {
        $$ = $1;
        $$.has_src++;
   }
   | img_attributes attr_alt {
        $$ = $1;
        $$.has_alt++;
   }
   | img_attributes attr_id {
        $$ = $1;
        $$.has_id++;
   }
   | img_attributes attr_height {
        $$ = $1;
        $$.has_height++;
   }
   | img_attributes attr_width {
        $$ = $1;
        $$.has_width++;
   }
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
    INPUT_OPEN input_attributes TAG_CLOSE {
        validateInputAttrs($2);
    }
;

input_attributes:
    {
        $$ = (Attributes){0, 0, 0, 0, 0, 0, 0, 0};
    }
    | input_attributes attr_type {
        $$ = $1;
        $$.has_type++;
   }
    | input_attributes attr_id {
        $$ = $1;
        $$.has_id++;
   }
    | input_attributes attr_style {
        $$ = $1;
        $$.has_style++;
   }
    | input_attributes attr_value {
        $$ = $1;
        $$.has_value++;
   }
;

label_tag:
    LABEL_OPEN label_attributes TAG_CLOSE text LABEL_CLOSE
;

label_attributes:
    attr_id attr_for
    | attr_for attr_id
    | attr_id attr_for attr_style
    | attr_id attr_style attr_for
    | attr_style attr_id attr_for
    | attr_style attr_for attr_id
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
    ATTR_NAME EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_content:
    ATTR_CONTENT EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_charset:
    ATTR_CHARSET EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_id:
    ATTR_ID EQUALS QUOTED_STRING{
        (!find_match(id_list,$3))? emplace_back(id_list,$3) : yyerror("Duplicate id");
    }
;

attr_style:
    ATTR_STYLE EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_href:
    ATTR_HREF EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_src:
    ATTR_SRC EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_alt:
    ATTR_ALT EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_height:
    ATTR_HEIGHT EQUALS NUMBER { if($3 <= 0) yyerror("Height must a positive integer"); }
;

attr_width:
    ATTR_WIDTH EQUALS NUMBER { if($3 <= 0) yyerror("Width must a positive integer"); }
;

attr_type:
    ATTR_TYPE EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_for:
    ATTR_FOR EQUALS QUOTED_STRING{
        (void)$3;
    }
;

attr_value:
    ATTR_VALUE EQUALS QUOTED_STRING{
        (void)$3;
    }
;

text:
    TEXT
    | text TEXT
;
%%

/* C code */
int main(int argc, char** argv) {
    bool inputFromFile = false;

    id_list = newList(); //the linked list we store the ids in
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

    // Show diagnostic message
    if (parse_success) {
        printf("\nmyHTMLParser: Parsing completed successfully and the file is valid.\n");
    }

    // Close the input file, if applicable
    if (inputFromFile)
        fclose(yyin);

    //print_list(id_list);//just to check all the ids to make sure its correct
    delete_list(id_list);
    return 0;
}

void validateImgAttrs(Attributes attrs) {
    if (attrs.has_id != 1 || attrs.has_src != 1 || attrs.has_alt != 1) {
        yyerror("img tag requires exactly one each of: id, src, alt");
    }
    if (attrs.has_width > 1 || attrs.has_height > 1) {
        yyerror("img tag allows at most one each of optional: width, height");
    }
}

void validateInputAttrs(Attributes attrs) {
    if (attrs.has_id != 1 || attrs.has_type != 1) {
        yyerror("input tag requires exactly one each of: id, type");
    }

    if (attrs.has_value > 1 || attrs.has_style > 1) {
        yyerror("input tag allows at most one each of optional: value, style");
    }
}

int yyerror(char* s) {
    printf("\nError: %s in line number %d \n", s, lineNumber);
    parse_success = false;

    exit(1);
}
