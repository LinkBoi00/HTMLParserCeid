/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    #include "linked_list.h"

    #define YYDEBUG 1

    extern int yylex(void);
    extern int yyerror(char* s);
    extern void yylex_destroy();
    
    extern int lineNumber;
    extern int title_size;
    extern FILE *yyin;

    int validate_url(char* s,int index,int size);

    bool parse_success = true;

    // Input tag type attribute
    int submit_input_count = 0;
    int checkbox_input_count = 0;
    bool is_input_submit_last = false;

    // Form tag checkbox-count attribute
    int checkbox_count_value = -1;

    // Linked list for IDs
    Linked_list* id_list;
    Address_list* input_addresses;
%}

%code requires {
    struct ImgAttributes {
        int has_id;
        int has_src;
        int has_alt;
        int has_type;
        int has_width;
        int has_height;
    } typedef ImgAttributes;

    struct InputAttributes {
        int has_id;
        int has_type;
        int has_style;
        int has_value;
    } typedef InputAttributes;

    struct StyleCharacteristics {
        int has_backround;
        int has_color;
        int has_font_size;
        int has_font_family;
    } typedef StyleCharacteristics;
    
    void validateImgAttrs(ImgAttributes attrs);
    void validateInputAttrs(InputAttributes attrs);
    void validateStyle(StyleCharacteristics styleChars);
    void validate_url(char* s);
}

%debug // TEMP: Enable debugging

%union {
    ImgAttributes imgAttrs;
    InputAttributes inputAttrs;
    StyleCharacteristics styleChars;
    int num;
    char* str;
}

%token MYHTML_OPEN MYHTML_CLOSE

%token HEAD_OPEN HEAD_CLOSE BODY_OPEN BODY_CLOSE
%token TITLE_OPEN TITLE_CLOSE META_OPEN P_OPEN P_CLOSE A_OPEN A_CLOSE
%token IMG_OPEN FORM_OPEN FORM_CLOSE LABEL_OPEN LABEL_CLOSE INPUT_OPEN DIV_OPEN DIV_CLOSE

%token ATTR_NAME ATTR_CONTENT ATTR_CHARSET ATTR_ID ATTR_STYLE ATTR_HREF
%token ATTR_SRC ATTR_ALT ATTR_HEIGHT ATTR_WIDTH ATTR_FOR ATTR_TYPE ATTR_VALUE
%token ATTR_CHECKBOXES

%token<str> QUOTED_STRING
%token<num> NUMBER
%token TEXT ERROR EQUALS TAG_CLOSE

%type<imgAttrs> img_attributes
%type<inputAttrs> input_attributes

%type<styleChars> multiple_style_characteristics
%token BACKROUND_COLOR COLOR FONT_FAMILY FONT_SIZE SEMICOLON COLON QUOTE

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
        $$ = (ImgAttributes){0, 0, 0, 0, 0, 0};
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
    FORM_OPEN form_attributes TAG_CLOSE form_children FORM_CLOSE {
        if (submit_input_count > 1) {
            yyerror("Only one submit input tag is allowed per form");
        }
        if (submit_input_count == 1 && is_input_submit_last == false) {
            yyerror("Submit input tag must be the last input tag in a form");
        }

        if (checkbox_count_value < 0 && checkbox_input_count > 0) {
            yyerror("checkbox-count attribute missing, but checkbox input tag found");
        }

        if (checkbox_count_value > 0) {
            if (checkbox_count_value != checkbox_input_count) {
                if (checkbox_input_count == 0) {
                    yyerror("checkbox-count attribute used, but no checkbox input tag found");
                } else {    
                printf("Expected %d checkbox input tags, got %d", checkbox_count_value, checkbox_input_count);
                yyerror("Checkbox input tags amount mismatch");
                }
            }
        }

        submit_input_count = 0;
        checkbox_input_count = 0;
        checkbox_count_value = -1;
    }
;

form_attributes:
    attr_id
    | attr_id attr_style
    | attr_style attr_id
    | attr_id attr_checkboxes
    | attr_id attr_checkboxes attr_style
    | attr_id attr_style attr_checkboxes
    | attr_style attr_checkboxes attr_id
    | attr_style attr_id attr_checkboxes
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
        $$ = (InputAttributes){0, 0, 0, 0};
    }
    | input_attributes attr_type {
        $$ = $1;
        $$.has_type++;
    }
    // Since this is a special case we do it this way so we can compare it
    | input_attributes ATTR_ID EQUALS QUOTED_STRING {
        $$ = $1;
        $$.has_id++;
        (!find_match(id_list,$4))? emplace_back(id_list,$4) : yyerror("Duplicate id");

        Node* temp=id_list->tail;
        insert_address(input_addresses,temp);
        free($4);
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
    ATTR_NAME EQUALS QUOTED_STRING {
        free($3);
    }
;

attr_content:
    ATTR_CONTENT EQUALS QUOTED_STRING {
        free($3);
    }
;

attr_charset:
    ATTR_CHARSET EQUALS QUOTED_STRING {
        free($3);
    }
;

attr_id:
    ATTR_ID EQUALS QUOTED_STRING {
        (!find_match(id_list, $3)) ? emplace_back(id_list, $3) : yyerror("Duplicate id");
        free($3);
    }
;

attr_style:
    ATTR_STYLE EQUALS QUOTE single_style_characteristics QUOTE
    |ATTR_STYLE EQUALS QUOTE multiple_style_characteristics QUOTE{
        validateStyle($4);
    }
    
;

single_style_characteristics:
    BACKROUND_COLOR COLON text
    |COLOR COLON text 
    |FONT_FAMILY COLON text 
    |FONT_SIZE COLON NUMBER{
        if ($3 <= 0) yyerror("Font size must be a possitive integer");
    }
;

multiple_style_characteristics:
    { $$=(StyleCharacteristics) {0,0,0,0}; }
    |BACKROUND_COLOR COLON text SEMICOLON multiple_style_characteristics {
        $$=$5;
        $$.has_backround++;
    }
    |COLOR COLON text SEMICOLON multiple_style_characteristics{
        $$=$5;
        $$.has_color++;
    }
    |FONT_FAMILY COLON text SEMICOLON multiple_style_characteristics{
        $$=$5;
        $$.has_font_family++;
    }
    |FONT_SIZE COLON NUMBER SEMICOLON multiple_style_characteristics{
        if ($3 <= 0) yyerror("Font size must be a possitive integer");
        $$=$5;
        $$.has_font_size++;
    }
;

attr_href:
    ATTR_HREF EQUALS QUOTED_STRING {
        validate_url($3);
        free($3);
    }
;

attr_src:
    ATTR_SRC EQUALS QUOTED_STRING {
        validate_url($3);
        free($3);
    }
;

attr_alt:
    ATTR_ALT EQUALS QUOTED_STRING {
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
    ATTR_TYPE EQUALS QUOTED_STRING {
        if (strcmp($3, "text") != 0 && strcmp($3, "checkbox") != 0 &&
            strcmp($3, "radio") != 0 && strcmp($3, "submit") != 0) {
            yyerror("Invalid input type value. Allowed: text, checkbox, radio, submit");
        }

        if (strcmp($3, "submit") == 0) {
            submit_input_count++;
            is_input_submit_last = true;
        } else {
            is_input_submit_last = false;
        }

        if (strcmp($3, "checkbox") == 0) {
            checkbox_input_count++;
        }

        free($3);
    }
;


attr_for:
    ATTR_FOR EQUALS QUOTED_STRING {
        // Get the address that links our for attribute with the id of an input
        pNode* temp=check_address(input_addresses,$3);

        // If its null it means that for either has  a duplicate input id value or none
        if (temp == NULL )
            yyerror("for attribute must be linked uniquely with an input tag's id");
        else
            delete_address_node(input_addresses,temp);

        free($3);
    }
;

attr_value:
    ATTR_VALUE EQUALS QUOTED_STRING {
        free($3);
    }
;

attr_checkboxes:
    ATTR_CHECKBOXES EQUALS NUMBER {
        if($3 <= 0) {
            yyerror("checkboxes-count must be a positive integer");
        }
        checkbox_count_value = $3;
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

    id_list = newList();
    input_addresses = newAddressList();
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

    // De-allocate memory
    yylex_destroy();
    delete_list(id_list);
    delete_address_list(input_addresses);

    return 0;
}

int _check_full_relative_url(char* s, int index, int size) {
    while(index < size) {
        if (s[index] == ' ') {
            yyerror("Whitespaces not allowed in URLs, use %20 for spaces or a +");
        } else if (s[index] == '/' && index+1<size && s[index+1] == '/' && index+2<size && s[index+2] == ':'){
            yyerror("//: is not allowed in URL");
        } else if (s[index] == '/' && index+1<size && s[index+1] == '/'){
            yyerror("// is not allowed in path");
        }
        index++;
    }

    return index;
}

void validate_url(char* s) {
    int index = 0;
    char* buffer;
    int size = strlen(s);

    // Ignore starting whitespaces
    while(s[index] == ' ') index++;

    // Check for element ID or URL
    if (s[index++] == '#') {
        buffer=strndup(s + index, size - 1);
        
        if (!find_match(id_list,buffer))
            yyerror("#id_list, id_list must have the name of an existing id in the file");
        
        free(buffer);
    } else {
        char* https=NULL;
        if(index+8 <= size) https=strndup(s + index-1, 8);

        char* http=NULL;
        if(index+7 <= size) http=strndup(s + index-1, 7);

        bool isHttps = false;
        bool isHttp = false;
        if(isHttps = (strcmp(https,"https://") == 0) || (isHttp = (strcmp(http,"http://"))) == 0 ) {
            if (isHttps) index += 8;
            if (isHttp) index += 7;

            _check_full_relative_url(s, index, size);
        } else {
            _check_full_relative_url(s, index, size);
        }

        free(https);
        free(http);
    }
}

void validateImgAttrs(ImgAttributes attrs) {
    if (attrs.has_id != 1 || attrs.has_src != 1 || attrs.has_alt != 1) {
        yyerror("img tag requires exactly one each of: id, src, alt");
    }
    if (attrs.has_width > 1 || attrs.has_height > 1) {
        yyerror("img tag allows at most one each of optional: width, height");
    }
}

void validateInputAttrs(InputAttributes attrs) {
    if (attrs.has_id != 1 || attrs.has_type != 1) {
        yyerror("input tag requires exactly one each of: id, type");
    }

    if (attrs.has_value > 1 || attrs.has_style > 1) {
        yyerror("input tag allows at most one each of optional: value, style");
    }
}

void validateStyle(StyleCharacteristics styleChars){
    if (styleChars.has_backround>1 || styleChars.has_color>1 || styleChars.has_font_family>1 || styleChars.has_font_size>1){
        yyerror("style attribute allows at most one each of optional: backround_color, color, font_family, font_size");
    }
}

int yyerror(char* s) {
    printf("\nError: %s in line number %d \n", s, lineNumber);
    parse_success = false;

    exit(1);
}
