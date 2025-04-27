BUILD_DIR = build
LIBS_DIR = libs
TESTS_DIR = tests
OUTPUT_FILE = $(BUILD_DIR)/my_html_parser.out
TEST_FILES = $(wildcard $(TESTS_DIR)/test-*.txt)
CFLAGS =-I$(LIBS_DIR)/include -lfl

all: target

target:
	mkdir -p $(BUILD_DIR)
	flex -o $(BUILD_DIR)/lex.yy.c my_html_flex.l
	bison -d -t -o $(BUILD_DIR)/my_html_bison.tab.c my_html_bison.y
	gcc $(CFLAGS) $(BUILD_DIR)/lex.yy.c \
		$(BUILD_DIR)/my_html_bison.tab.c \
		$(LIBS_DIR)/linked_list.c \
		-o $(OUTPUT_FILE)

clean:
	rm -rf $(BUILD_DIR)

run: clean target
	@echo "\nRunning parser with example.txt"
	./$(OUTPUT_FILE) example.txt

test: run
	@for test_file in $(TEST_FILES); do \
		echo "----------------------------------"; \
		echo "Running test: $$test_file"; \
		./$(OUTPUT_FILE) $$test_file; \
	done

valgrind: clean target
	@echo "\nRunning parser (example.txt) with valgrind"
	valgrind --leak-check=full --track-origins=yes  --show-leak-kinds=all ./$(OUTPUT_FILE) example.txt
