/* Declarations */
%{
    #include "my_html_bison.tab.h"

    int lineNumber = 1;
%}

%x TITLE

/* Rules */
%%
"<MYHTML>"              { printf("MYHTML_OPEN\n"); return MYHTML_OPEN; }
"</MYHTML>"             { printf("MYHTML_CLOSE\n"); return MYHTML_CLOSE; }

"<head>"                { printf("HEAD_OPEN\n"); return HEAD_OPEN; }
"</head>"               { printf("HEAD_CLOSE\n"); return HEAD_CLOSE; }

"<title>"               { printf("HEAD_TITLE_OPEN\n"); BEGIN(TITLE); return HEAD_TITLE_OPEN; }
<TITLE>"</title>"       { printf("HEAD_TITLE_CLOSE\n"); BEGIN(INITIAL); return HEAD_TITLE_CLOSE; }
<TITLE>[^<]+            { printf("HEAD_TITLE_CONTENT\n"); return HEAD_TITLE_CONTENT; }


[ \t\r]+              { /* Ignore whitespaces */ }
\n                      { lineNumber++; }
.                       { printf("ERROR\n"); return ERROR; }
%%

/* C code */
