/* Declarations */
%{
    #include "my_html_bison.tab.h"
%}

/* Rules */
%%
[a-zA-z]+ {yylval.str=strdup(yytext); return WORD;}
" " {return SPACE;}
\t  {return SPACE;}
\n  {return EOL;}
. { }
%%

int yywrap(){ }
