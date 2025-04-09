/* Declarations */
%{
    #include "my_html_bison.tab.h"
    int lineNumber = 1;
%}

/* Rules */
%%

"<MYHTML>" {return START_MYHTML;}
"</MYHTML>" {return CLOSING_MYHTML;}

"<head>" {return START_HEAD;}
"</head>" {return CLOSING_HEAD;}

"<title>" {return START_TITLE;}
"</title>" {return CLOSING_TITLE;}

[[:space:]]+ ;
\n { lineNumber++; }

[^<]+ {yylval.str = strdup(yytext); return TEXT;}
. {}
%%