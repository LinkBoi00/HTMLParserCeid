BUILD_DIR = build
OUTPUT_FILE = $(BUILD_DIR)/my_html_parser.out
CFLAGS = -lfl

all: target

target:
	mkdir -p $(BUILD_DIR)
	flex -o $(BUILD_DIR)/lex.yy.c my_html_flex.l
	bison -d -t -o $(BUILD_DIR)/my_html_bison.tab.c my_html_bison.y
	gcc $(CFLAGS) $(BUILD_DIR)/lex.yy.c \
		$(BUILD_DIR)/my_html_bison.tab.c \
		-o $(OUTPUT_FILE)

clean:
	rm -rf $(BUILD_DIR)

run:
	./$(OUTPUT_FILE) test.txt
