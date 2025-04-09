/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%x TITLE
%x ATTR_VALUE

/* Rules */
%%
"<MYHTML>"              { printf("MYHTML_OPEN\n"); return MYHTML_OPEN; }
"</MYHTML>"             { printf("MYHTML_CLOSE\n"); return MYHTML_CLOSE; }

"<head>"                { printf("HEAD_OPEN\n"); return HEAD_OPEN; }
"</head>"               { printf("HEAD_CLOSE\n"); return HEAD_CLOSE; }

"<title>"               { printf("HEAD_TITLE_OPEN\n"); BEGIN(TITLE); return HEAD_TITLE_OPEN; }
<TITLE>"</title>"       { printf("HEAD_TITLE_CLOSE\n"); BEGIN(INITIAL); return HEAD_TITLE_CLOSE; }
<TITLE>[^<]+            { printf("HEAD_TITLE_CONTENT\n"); return HEAD_TITLE_CONTENT; }

"<meta"                 { printf("HEAD_META_OPEN\n"); return HEAD_META_START; }
"name="                 { printf("HEAD_META_NAME\n"); return HEAD_META_NAME; }
"content="              { printf("HEAD_META_CONTENT\n"); return HEAD_META_CONTENT; }
"charset="              { printf("HEAD_META_CHARSET\n"); return HEAD_META_CHARSET; }

\"                      { printf("QUOTE\n"); BEGIN(ATTR_VALUE); return QUOTE; }
<ATTR_VALUE>\"          { printf("QUOTE\n"); BEGIN(INITIAL); return QUOTE; }
<ATTR_VALUE>[^\"]+      { printf("ATTR_VALUE_CONTENT\n"); return ATTR_VALUE_CONTENT; }

">"                     { printf("TAG_CLOSE\n"); return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { printf("ERROR\n"); return ERROR; }
%%

/* C code */
