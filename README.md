# HTMLParserCeid

Parser for a custom HTML-like language ("myHTML") developed using Flex and Bison, created as part of CEID's Compilers course. The project includes lexical and syntax analysis, conforming to a simplified HTML grammar.

## Features
* Performs lexical analysis (recognises language tokens) with Flex
* Performs syntax analysis with Bison
* Error reporting with line numbers
* Successfully implements all parts of the task's description

## Dependencies
- [Flex](https://github.com/westes/flex) (fast lexical analyzer generator)
- [Bison](https://www.gnu.org/software/bison/) (GNU parser generator, similar to Yacc)
- `gcc` (or any C compiler like)
- `make` (optional, for automated build)

## Instructions
The included Makefile contains targets: target (default), clean, run, test, valgrind (debugging).

To compile the program, run:
```
$ make
```

To compile and run the program with example.txt as input, run:
```
$ make run
```

To compile and run the program with all test files (located in tests/) as inputs, run:
```
$ make tests
```

## Notes on Part2-C
The current implementation does not allow reference (via id) to tags that appear later in the myHTML file. It expects a top-down (C-like), nested structure and therefore does not allow forward references. For example, the following myHTML document would be invalid because p tag with id=par1 is defined after referencing it via its id with href="#par1".

```html
<MYHTML>
<body>
    <a id="hyper2" href="#par1">
        <img src="image.jpg" id="myimg321" alt="Example Image" height=9 width=9 >
    </a>

    <p id = "par1" style=" backround_color: red; color: blue; font_size: 76%; font_family: calibri; ">This is my project.</p>
</body>
</MYHTML>
```

## License

See the LICENSE file for details.