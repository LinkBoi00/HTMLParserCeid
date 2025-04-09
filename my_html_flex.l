/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%x TEXT
%x ATTR_VALUE

%x P_STATE

/* Rules */
%%
"<MYHTML>"              { return MYHTML_OPEN; }
"</MYHTML>"             { return MYHTML_CLOSE; }

"<head>"                { return HEAD_OPEN; }
"</head>"               { return HEAD_CLOSE; }
"<title>"               { BEGIN(TEXT); return HEAD_TITLE_OPEN; }
<TEXT>"</title>"        { BEGIN(INITIAL); return HEAD_TITLE_CLOSE; }
"<meta"                 { return HEAD_META_START; }
"name="                 { return HEAD_META_NAME; }
"content="              { return HEAD_META_CONTENT; }
"charset="              { return HEAD_META_CHARSET; }

"<body>"                { return BODY_OPEN; }
"</body>"               { return BODY_CLOSE; }
"<p"                    { BEGIN(P_STATE); return BODY_P_START; }
<P_STATE>"</p>"         { BEGIN(INITIAL); return BODY_P_CLOSE; }

<P_STATE>"id="          { return ATTR_ID; }
<P_STATE>"style="       { return ATTR_STYLE; }

["]                     { BEGIN(ATTR_VALUE); return QUOTE; }
<ATTR_VALUE>["]         { BEGIN(INITIAL); return QUOTE; }
<ATTR_VALUE>[^\"]+      { return ATTR_VALUE_CONTENT; }

<P_STATE,TEXT>[^<]+     { return TEXT_VALUE_CONTENT; }

">"                     { return TAG_CLOSE; }

[ \t\r]+                { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { return ERROR; }
%%

/* C code */
