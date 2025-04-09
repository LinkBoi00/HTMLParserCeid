/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%option stack

%x TITLE_SECTION
%x ATTR_VALUE
%x P_STATE
%x QUOTE_SECTION
%x CONSUME

/* Rules */
%%
\n                      {lineNumber++;}
"MYHTML>"              { printf("myhtml>\n"); return MYHTML; }
"head>"                { printf("head>\n"); return HEAD; }

"</title>"              { printf("</title>\n"); return TITLE_END;}//so that we dont triger title> and start going to another state
"title>"               { printf("title> "); BEGIN(TITLE_SECTION); return TITLE; }

"meta"                 { printf("meta ");return META; }
"name="                 { printf("name= "); return META_NAME; }
"content="              { printf("content= "); return META_CONTENT; }
"charset="              { printf("charset= ");return META_CHARSET; }
["]                     { BEGIN(ATTR_VALUE); return QUOTE; }
>                       { printf(">\n"); return END;}
<ATTR_VALUE>["]         { BEGIN(INITIAL); return QUOTE; }
<ATTR_VALUE>[^\"]+      { return ATTR_CONTENT; }

"body>"                { printf("body>\n"); return BODY; }

"p"                    { printf("p ");BEGIN(P_STATE); return P; }
"</p>"                  {printf("</p>\n"); return P_CLOSE;}
<P_STATE>\"            { printf("\""); BEGIN(QUOTE_SECTION);return QUOTE;}
<P_STATE>">"            { printf("> "); BEGIN(TITLE_SECTION); return END;}
<P_STATE>"id="          { printf("id= "); return ATTR_ID; }
<P_STATE>"style="       { printf("style= "); return ATTR_STYLE; }
<CONSUME>\"             {printf("\"");BEGIN(P_STATE); return QUOTE;}
<QUOTE_SECTION>[^"]+     {printf("called");BEGIN(CONSUME); return ATTR_CONTENT;}
<TITLE_SECTION>[^<]+     {printf("..stuf.. "); BEGIN(INITIAL); return CONTENT; }

"<"                     { printf("<"); return TAG_OPEN;}
"</"                    { printf("</");return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
.                       { }
%%