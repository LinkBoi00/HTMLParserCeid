/* Declarations */
%{
    #include "my_html_bison.tab.h"
    int lineNumber = 1;
%}

%option stack

%x IMG_STATE
%x COMMENT_STATE

/* Rules */
%%
"="                    { return EQUALLS;}
[>]                     { return TAG_CLOSE; }
"<!--"                  {yy_push_state(COMMENT_STATE);}
<COMMENT_STATE>"--"     { return ERROR; }
<COMMENT_STATE>"-->"    {yy_pop_state(); /*return to previous state*/}
<COMMENT_STATE>.        { /*ignore the text in the comment*/ }
"<MYHTML>"              { return MYHTML_OPEN; }
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }
"</head>"               { return HEAD_CLOSE; }
"<title>"               { return TITLE_OPEN; }
"</title>"              { return TITLE_CLOSE; }

"<body>"                { return BODY_OPEN; }
"</body>"               { return BODY_CLOSE; }

"<p"                    { return P_OPEN; }
"</p>"                  { return P_CLOSE; }
"<a"                    { return A_OPEN; }
"</a>"                  { return A_CLOSE; }

"<meta"                 { return META_OPEN; }
"name"                  { return ATTR_NAME; }
"content"               { return ATTR_CONTENT; }
"charset"               { return ATTR_CHARSET; }

"id"                    { return ATTR_ID; }
"style"                 { return ATTR_STYLE; }
"href"                  { return ATTR_HREF; }

"<img"                  { return IMG_OPEN; }
"src"                   { return ATTR_SRC; }
"alt"                   { return ATTR_ALT; }
"height"                { yy_push_state(IMG_STATE); return ATTR_HEIGHT; }
"width"                 { yy_push_state(IMG_STATE); return ATTR_WIDTH; }
<IMG_STATE>"="          { /*ignore =*/ }
<IMG_STATE>[ \t\r]+         { /*ignore whitespace*/ }
<IMG_STATE>[0-9]+       { yy_pop_state(); yylval.num = atoi(yytext); return INTEGER; }
<IMG_STATE>-[0-9]+      { yy_pop_state(); yylval.num = atoi(yytext); return INTEGER; }

"<form"                 { return FORM_OPEN; }
"</form>"               { return FORM_CLOSE;}
"<input"                { return INPUT_OPEN; }

"<label"                { return LABEL_OPEN; }
"</label>"              { return LABEL_CLOSE; }
"for"                   { return FOR; }
"type"                  { return TYPE; }
"value"                 { return VALUE;}

"<div"                  { return DIV_OPEN; }
"</div>"                { return DIV_CLOSE; }

\"[^\"]*\"              { return TEXT; } //reads double quotes
\'[^\"]*\'              { return TEXT; } //reads single quotes
[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { /*do nothing*/ }
%%