/* Declarations */
%{
    #include "my_html_bison.tab.h"
    int lineNumber = 1;
%}

/* Rules */
%%

"<MYHTML>" {printf("start my ");return START_MYHTML;}
"</MYHTML>" {return CLOSING_MYHTML;}

"<head>" {printf("start head ");return START_HEAD;}
"</head>" {return CLOSING_HEAD;}

"<title>" {printf("<");return START_TITLE;}
"</title>" {return CLOSING_TITLE;}

[ \t\r]+ {printf("white space");}
\n { lineNumber++; }

[^<]+ {return TEXT;}
. {}
%%
