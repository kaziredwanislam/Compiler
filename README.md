Project Overview

This project is a complete, custom compiler for a subset of the C programming language. It translates high-level C-like source code into 8086 Assembly Language (.MODEL SMALL). The compiler pipeline is implemented from scratch using Flex for lexical analysis, Bison for syntax and semantic parsing, and custom C++ classes for symbol table management and code generation.
Architecture & File Breakdown

The compiler operates in four distinct phases, handled by the following core files:

    2005108.l (Lexical Analyzer / Scanner):

        Powered by Flex.

        Reads the raw source code and tokenizes it (identifying keywords, operators, identifiers, and constants).

        Strips out whitespace, tracks line counts, and handles both single and multi-line comments.

        Catches lexical errors like unterminated strings or invalid character combinations.

    2005108.y (Syntax & Semantic Analyzer / Parser):

        Powered by Bison.

        Defines the Context-Free Grammar (CFG) for the language.

        Constructs the parse tree and performs rigorous semantic analysis.

        Enforces type checking, verifies function parameter matches, checks array bounds, and catches logical errors (e.g., division by zero, void variable declarations, or duplicate declarations).

    2005108.cpp (Symbol Table):

        A custom Hash Table implementation used to store and retrieve variable and function metadata.

        Manages scope resolution. It handles nested blocks (entering and exiting scopes) ensuring variables are only accessible where permitted.

        Tracks memory offsets for variables, which is critical for the later assembly translation.

    2005108ICG_classFile.cpp (Intermediate / Target Code Generator):

        The backend engine. It traverses the syntax structures built by the parser and translates them into standard 8086 Assembly.

        Manages the hardware stack (PUSH, POP, MOV BP, SP) for function calls and local variables.

        Translates control flow (If/Else, Loops) into assembly jump labels (JMP, JE, JNE, etc.).

        Injects a custom I/O library (print_output, new_line) directly into the assembly so the compiled programs can print integers to the console.                                                         

    Run.sh:
        This file contains necessary commands for running these files.
        
