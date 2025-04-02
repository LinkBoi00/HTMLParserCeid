all: target

target:
	mkdir -p build/
	flex -o build/lex.yy.c my_html_flex.l
	bison -d -t -o build/my_html_bison.tab.c my_html_bison.y
	gcc build/lex.yy.c build/my_html_bison.tab.c -o build/my_html_parser.out -lfl

clean:
	rm -rf build/
