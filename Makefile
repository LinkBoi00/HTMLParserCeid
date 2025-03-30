all: comp_

comp_:
	flex my_hmtl_flex.l
	bison -d -t my_html_bison.y
	gcc lex.yy.c my_html_bison.tab.c

clean:
	rm -f lex.yy.c my_html_bison.tab.c my_html_bison.tab.h a.out