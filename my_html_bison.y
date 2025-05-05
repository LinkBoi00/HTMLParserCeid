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
    //int yylex_destroy(void);
    extern void yylex_destroy();
    extern FILE *yyin;

    bool parse_success = true;
    Linked_list* id_list;
    Adress_list* input_adresses;
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

    struct Style {
        int has_backround;
        int has_color;
        int has_font_size;
        int has_font_family;
    }typedef Style;

    void validateImgAttrs(Attributes attrs);
    void validateInputAttrs(Attributes attrs);

    void validateStyle(Style style);
}

%debug // TEMP: Enable debugging

%union {
    Attributes attrs;
    Style style;
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

%token BACKROUND_COLOR COLOR FONT_FAMILY FONT_SIZE SEMICOLON COLON QUOTE

%type<attrs> img_attributes input_attributes
%type<style> style_characteristics

//%destructor { free($$); } <str> //destructor to automatically free memory of strings
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
    | input_attributes ATTR_ID EQUALS QUOTED_STRING { //since this is a special case we do it this way so we can compare it 
        $$ = $1;
        $$.has_id++;
        (!find_match(id_list,$4))? emplace_back(id_list,$4) : yyerror("Duplicate id");

        Node* temp=id_list->tail;
        insert_adress(input_adresses,temp);
        
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
        free($3);
    }
;

attr_content:
    ATTR_CONTENT EQUALS QUOTED_STRING{
        free($3);
    }
;

attr_charset:
    ATTR_CHARSET EQUALS QUOTED_STRING{
        free($3);
    }
;

attr_id:
    ATTR_ID EQUALS QUOTED_STRING{
        (!find_match(id_list,$3))? emplace_back(id_list,$3) : yyerror("Duplicate id");
    }
;

attr_style:
    ATTR_STYLE EQUALS QUOTE style_characteristics QUOTE{
        validateStyle($4);
    }
;

style_characteristics:
    { $$=(Style) {0,0,0,0}; }
    |style_characteristics BACKROUND_COLOR COLON text SEMICOLON{
        $$=$1;
        $$.has_backround++;
    }
    |style_characteristics COLOR COLON text SEMICOLON{
        $$=$1;
        $$.has_color++;
    }
    |style_characteristics FONT_FAMILY COLON text SEMICOLON{
        $$=$1;
        $$.has_font_family++;
    }
    |style_characteristics FONT_SIZE COLON NUMBER SEMICOLON{
        if ($4 <= 0) yyerror("font size must be a possitive integer");
        $$=$1;
        $$.has_font_size++;
    }
;

attr_href:
    ATTR_HREF EQUALS QUOTED_STRING{
        free($3);
    }
;

attr_src:
    ATTR_SRC EQUALS QUOTED_STRING{
        free($3);
    }
;

attr_alt:
    ATTR_ALT EQUALS QUOTED_STRING{
        free($3);
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
       free($3);
    }
;


attr_for:
    ATTR_FOR EQUALS QUOTED_STRING{
        pNode* temp=check_adress(input_adresses,$3);//get the adress that links our for attribute with the id of an input
        if(temp == NULL ) yyerror("value in for must be linked with a singular input id");//if its null it means that for either has  a duplicate input id value or none
        else delete_adress_node(input_adresses,temp);
        free($3);
    }
;

attr_value:
    ATTR_VALUE EQUALS QUOTED_STRING{
        free($3);
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
    input_adresses = newAdressList();
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
        printf("\nmyHTMLParser: Parsing completed successfully and the file is valid,proceeding to now print the myHTML file...\n");
        fseek(yyin,0,SEEK_SET);
        char c;
        while( (c = fgetc(yyin)) != EOF ){
            putchar(c);
        }
    }

    // Close the input file, if applicable
    if (inputFromFile)
        fclose(yyin);

    //print_list(id_list);//just to check all the ids to make sure its correct
    delete_list(id_list);//free memorry of id_list
    delete_adress_list(input_adresses);//free memory of input_adresses
    yylex_destroy();//clear flex internal buffers
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

void validateStyle(Style style){
    if (style.has_backround>1 || style.has_color>1 || style.has_font_family>1 || style.has_font_size>1){
        yyerror("style attribute allows at most one each of optional: backround_color, color, font_family, font_size");
    }
}

int yyerror(char* s) {
    printf("\nError: %s in line number %d \n", s, lineNumber);
    parse_success = false;

    exit(1);
}
