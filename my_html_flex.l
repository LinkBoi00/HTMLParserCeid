/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

/* Rules */
%%
"<MYHTML>"              { return MYHTML_OPEN; }
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }
"</head>"               { return HEAD_CLOSE; }
"<title>"               { return TITLE_OPEN; }
"</title>"              { return TITLE_CLOSE; }
"<meta"                 { return META_OPEN; }
"<body>"                { return BODY_OPEN; }
"</body>"               { return BODY_CLOSE; }
"<p"                    { return P_OPEN; }
"</p>"                  { return P_CLOSE; }
"<a"                    { return A_OPEN; }
"</a>"                  { return A_CLOSE; }
"<img"                  { return IMG_OPEN; }
"<form"                 { return FORM_OPEN; }
"</form>"               { return FORM_CLOSE;}
"<input"                { return INPUT_OPEN; }
"<label"                { return LABEL_OPEN; }
"</label>"              { return LABEL_CLOSE; }
"<div"                  { return DIV_OPEN; }
"</div>"                { return DIV_CLOSE; }

"name="                 { return ATTR_NAME; }
"content="              { return ATTR_CONTENT; }
"charset="              { return ATTR_CHARSET; }
"id="                   { return ATTR_ID; }
"style="                { return ATTR_STYLE; }
"href="                 { return ATTR_HREF; }
"src="                  { return ATTR_SRC; }
"alt="                  { return ATTR_ALT; }
"height="               { return ATTR_HEIGHT; }
"width="                { return ATTR_WIDTH; }
"for="                  { return ATTR_FOR; }
"type="                 { return ATTR_TYPE; }
"value="                { return ATTR_VALUE; }

["]                     { return QUOTE; }
">"                     { return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
-?[0-9]+                { yylval.num = atoi(yytext); return NUMBER; }
.                       { return TEXT; }
%%
