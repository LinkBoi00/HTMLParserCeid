/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%x ATTR_VALUE TEXT_VALUE

/* Rules */
%%
"<MYHTML>"              { return MYHTML_OPEN; }
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }
"</head>"               { return HEAD_CLOSE; }
"<title>"               { BEGIN(TEXT_VALUE); return TITLE_OPEN; }
"</title>"              { return TITLE_CLOSE; }
"<meta"                 { return META_OPEN; }

"name="                 { return ATTR_NAME; }
"content="              { return ATTR_CONTENT; }
"charset="              { return ATTR_CHARSET; }

["]                     { BEGIN(ATTR_VALUE); return QUOTE; }
<ATTR_VALUE>["]         { BEGIN(INITIAL); return QUOTE; }
<ATTR_VALUE>[^\"]+      { return ATTR_VALUE_CONTENT; }

">"                     { return TAG_CLOSE; }

<TEXT_VALUE>[^<]+       { BEGIN(INITIAL); return TEXT; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { return ERROR; }
%%
