/* Declarations */
%{
    #include "my_html_bison.tab.h"
    #include <string.h>

    int lineNumber = 1;
    int title_size = 0;
%}

%option stack

%x TAG_START_STATE COMMENT_STATE TITLE_STATE

/* Rules */
%%
<INITIAL,TITLE_STATE>"<!--"             { yy_push_state(COMMENT_STATE); }
<COMMENT_STATE>"--"                     { return ERROR; }
<COMMENT_STATE>"-->"                    { yy_pop_state(); }
<COMMENT_STATE>.                        { /*ignore the text in the comment*/ }

"<MYHTML>"                              { return MYHTML_OPEN; }
"</MYHTML>"                             { return MYHTML_CLOSE; }

"<head>"                                { return HEAD_OPEN; }
"</head>"                               { return HEAD_CLOSE; }
"<title>"                               { yy_push_state(TITLE_STATE); return TITLE_OPEN; }
"<meta"                                 { yy_push_state(TAG_START_STATE); return META_OPEN; }
"<body>"                                { return BODY_OPEN; }
"</body>"                               { return BODY_CLOSE; }
"<p"                                    { yy_push_state(TAG_START_STATE); return P_OPEN; }
"</p>"                                  { return P_CLOSE; }
"<a"                                    { yy_push_state(TAG_START_STATE); return A_OPEN; }
"</a>"                                  { return A_CLOSE; }
"<img"                                  { yy_push_state(TAG_START_STATE); return IMG_OPEN; }
"<form"                                 { yy_push_state(TAG_START_STATE); return FORM_OPEN; }
"</form>"                               { return FORM_CLOSE;}
"<input"                                { yy_push_state(TAG_START_STATE); return INPUT_OPEN; }
"<label"                                { yy_push_state(TAG_START_STATE); return LABEL_OPEN; }
"</label>"                              { return LABEL_CLOSE; }
"<div"                                  { yy_push_state(TAG_START_STATE); return DIV_OPEN; }
"</div>"                                { return DIV_CLOSE; }

<INITIAL,TITLE_STATE>"</title>"         { yy_pop_state(); return TITLE_CLOSE; }
<TITLE_STATE>[^<]+                      { title_size += strlen(yytext); return TEXT; }
<TITLE_STATE>"<"                        { title_size++; }

<TAG_START_STATE>"name"                 { return ATTR_NAME; }
<TAG_START_STATE>"content"              { return ATTR_CONTENT; }
<TAG_START_STATE>"charset"              { return ATTR_CHARSET; }
<TAG_START_STATE>"id"                   { return ATTR_ID; }
<TAG_START_STATE>"style"                { return ATTR_STYLE; }
<TAG_START_STATE>"href"                 { return ATTR_HREF; }
<TAG_START_STATE>"src"                  { return ATTR_SRC; }
<TAG_START_STATE>"alt"                  { return ATTR_ALT; }
<TAG_START_STATE>"height"               { return ATTR_HEIGHT; }
<TAG_START_STATE>"width"                { return ATTR_WIDTH; }
<TAG_START_STATE>"for"                  { return ATTR_FOR; }
<TAG_START_STATE>"type"                 { return ATTR_TYPE; }
<TAG_START_STATE>"value"                { return ATTR_VALUE; }

<TAG_START_STATE>"="                    { return EQUALS; }
<TAG_START_STATE>\"[^"]*\"              { return QUOTED_STRING; }
<TAG_START_STATE>\'[^']*\'              { return QUOTED_STRING; }

<TAG_START_STATE>-?[0-9]+               { yylval.num = atoi(yytext); return NUMBER; }
<TAG_START_STATE>">"                    { yy_pop_state(); return TAG_CLOSE; }

<*>[ \t\r]+                             { /* Ignore whitespaces */ }
<*>\n                                   { lineNumber++; }
<INITIAL,TAG_START_STATE>.              { return TEXT; }
%%
