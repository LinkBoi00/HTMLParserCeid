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

//yywrap needs to return 1 or else it will keep parsing after we reatch eof

int yywrap(){ 
    return 1; 
}
