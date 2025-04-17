/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%option stack

%x COMMENT_STATE
%x IMG_STATE

/* Rules */
%%
"<!--"                  {yy_push_state(COMMENT_STATE); return COMMENT_OPEN;}
<COMMENT_STATE>"--"     {return COMMENT_ERROR;}
<COMMENT_STATE>"-->"    {yy_pop_state(); return COMMENT_CLOSE;}
<COMMENT_STATE>.        {return TEXT;}

"<MYHTML>"              { return MYHTML_OPEN; }//has 2 children head and body
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }//has 2 children tittle and meta
"</head>"               { return HEAD_CLOSE; }
"<title>"               { return TITLE_OPEN; }//text only
"</title>"              { return TITLE_CLOSE; }

"<body>"                { return BODY_OPEN; }//its children are p a img form div
"</body>"               { return BODY_CLOSE; }//doesnt have id and it must exist

"<p"                    { return P_OPEN; }
"</p>"                  { return P_CLOSE; }
"<a"                    { return A_OPEN; }
"</a>"                  { return A_CLOSE; }

"<meta"                 { return META_OPEN; }
"name="                 { return ATTR_NAME; }
"content="              { return ATTR_CONTENT; }
"charset="              { return ATTR_CHARSET; }

"id="                   { return ATTR_ID; }
"style="                { return ATTR_STYLE; }
"href="                 { return ATTR_HREF; }

"<img"                  {return IMG_OPEN;}
"src="                  {return ATTR_SRC;}
"alt="                  {return ATTR_ALT;}
"height="               {yy_push_state(IMG_STATE);return ATTR_HEIGHT;}
"width="                {yy_push_state(IMG_STATE);return ATTR_WIDTH;}
<IMG_STATE>[0-9]+       {yy_pop_state(); yylval.num = atoi(yytext); return INTEGER;}
<IMG_STATE>-[0-9]+       {yy_pop_state(); yylval.num = atoi(yytext); return INTEGER;}

"<form"                 { return FORM_OPEN; }
"</form>"               { return FORM_CLOSE;}
"<input"                { return INPUT_OPEN; }

"<label"                { return LABEL_OPEN; }
"</label>"              { return LABEL_CLOSE; }
"for="                  { return FOR; }
"type="                 { return TYPE; }
"value="                { return VALUE;}

"<div"                  { return DIV_OPEN; }
"</div>"                { return DIV_CLOSE; }

["]                     { return QUOTE; }
[']                     { return SINGLE_QUOTE;}
">"                     { return TAG_CLOSE; }  

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { return TEXT; }
%%