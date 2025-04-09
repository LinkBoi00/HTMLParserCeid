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
"<title>"               { return TITLE_OPEN; }
"</title>"              { return TITLE_CLOSE; }
"<meta"                 { return META_OPEN; }
"<body>"                { return BODY_OPEN; }
"</body>"               { return BODY_CLOSE; }
"<p"                    { return P_OPEN; }
"</p>"                  { return P_CLOSE; }

"name="                 { return ATTR_NAME; }
"content="              { return ATTR_CONTENT; }
"charset="              { return ATTR_CHARSET; }
"id="                   { return ATTR_ID; }
"style="                { return ATTR_STYLE; }

["]                     { return QUOTE; }
">"                     { return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { return TEXT; }
%%
