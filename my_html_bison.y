/* Declarations */
%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    extern int yylex(void);
    extern int yyerror(char* s);
    #define YYDEBUG 1
    extern int lineNumber;
    extern FILE *yyin;
%}

%debug // TEMP: Enable debugging

%token TAG_OPEN TAG_CLOSE
%token MYHTML

%token HEAD
%token TITLE CONTENT TITLE_END

%token META
%token META_NAME META_CONTENT META_CHARSET

%token BODY BODY_END
%token P P_CLOSE

%token QUOTE
%token ATTR_ID ATTR_STYLE
%token ATTR_CONTENT
%token END

/* Rules */
%%
input:
    myhtml_file
;

myhtml_file:
    TAG_OPEN MYHTML head body TAG_CLOSE MYHTML
    | TAG_OPEN MYHTML body TAG_CLOSE MYHTML
;

head:
    TAG_OPEN HEAD title_section meta_section TAG_CLOSE HEAD
;

title_section:
    TAG_OPEN TITLE CONTENT TITLE_END//<title> ... </title>
;

meta_section:
    /* empty */
    |meta_tag meta_section
;

meta_tag:
    TAG_OPEN META meta_attr_name meta_attr_content END
    | TAG_OPEN META meta_attr_charset END
;

meta_attr_name:
    META_NAME QUOTE ATTR_CONTENT QUOTE
;

meta_attr_content:
    META_CONTENT QUOTE ATTR_CONTENT QUOTE
;

meta_attr_charset:
    META_CHARSET QUOTE ATTR_CONTENT QUOTE
;

body:

    |TAG_OPEN BODY p_section TAG_CLOSE BODY//<body> ... </body> *for some reason crashes here
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
    TAG_OPEN P attr_id TAG_CLOSE P
;

attr_id:
    ATTR_ID QUOTE ATTR_CONTENT QUOTE ATTR_STYLE QUOTE ATTR_CONTENT QUOTE END CONTENT P_CLOSE
    //id="..." style="..." > ....</p>
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