/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%x TITLE
%x ATTR_VALUE

/* Rules */
%%
"<MYHTML>"              { return MYHTML_OPEN; }
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }
"</head>"               { return HEAD_CLOSE; }

"<title>"               { BEGIN(TITLE); return HEAD_TITLE_OPEN; }
<TITLE>"</title>"       { BEGIN(INITIAL); return HEAD_TITLE_CLOSE; }
<TITLE>[^<]+            { return HEAD_TITLE_CONTENT; }

"<meta"                 { return HEAD_META_START; }
"name="                 { return HEAD_META_NAME; }
"content="              { return HEAD_META_CONTENT; }
"charset="              { return HEAD_META_CHARSET; }

["]                     { BEGIN(ATTR_VALUE); return QUOTE; }
<ATTR_VALUE>["]         { BEGIN(INITIAL); return QUOTE; }
<ATTR_VALUE>[^\"]+      { return ATTR_VALUE_CONTENT; }

">"                     { return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { return ERROR; }
%%

/* C code */