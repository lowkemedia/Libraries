# Getting started with the C++ examples

[Back to the course guide](../README.md)

You need a text editor, a terminal, and a C++ compiler with its standard library. The commands below use a Unix-style shell on macOS or Linux (including an appropriately configured Windows Linux environment). They assume `c++` is already available; `g++` or `clang++` can be used in its place if that is your installed compiler.

The original [Getting Started PDF](Getting%20Started.pdf) covers Xcode preferences, comments, indentation and the first program. The [Bash on Windows 10 PDF](Bash%20on%20Windows10.pdf) preserves the original beta-era setup instructions; it is historical rather than a current installation guide. You can use an editor or IDE of your choice and still follow the language exercises.

## Your first program

Starting in the **Libraries repository root**, move into the teaching folder:

```sh
cd "C++/C++ Teaching"
```

The remaining commands in this guide start there. Quote paths because the folder names contain spaces.

```sh
mkdir -p /tmp/lowke-cpp
c++ -std=c++11 -Wall -Wextra "02 Getting Started/hello.cpp" -o /tmp/lowke-cpp/hello
/tmp/lowke-cpp/hello
```

Expected output:

```text
Hello World
```

`-std=c++11` selects the language version used by later examples, `-Wall -Wextra` enables useful warnings, and `-o` names the executable. `/tmp/lowke-cpp` keeps generated programs outside the course files. Open [hello.cpp](hello.cpp), change the greeting, save, and compile again to see your change.

For a later example that demonstrates modifying array elements through references:

```sh
c++ -std=c++11 -Wall -Wextra "19 Range-Based for Loops/range_based_for.cpp" -o /tmp/lowke-cpp/range-for
/tmp/lowke-cpp/range-for
```

It prints the values `1 2 3 4 5`, followed by `2 4 6 8 10`.

## Choosing what to compile

- Most short examples are independent `.cpp` programs. Compile one at a time; combining the whole folder often gives multiple definitions of `main()`.
- A split-file exercise needs its `.cpp` implementation files compiled together, with its headers alongside them. The [chess guide](../_Chess%20Example/README.md#building-the-examples) gives a concrete example.
- Starter files, solved files and `_alt` variants are separate versions. Choose one version for each build.
- Many programs prompt for input. Run them in a terminal where you can type, and supply the kind of value requested. Not every example handles malformed input or end-of-file.

Most examples use standard-library console facilities, but portability varies. For example, the [Tic Tac Toe solution](../25%20Classes/_hw/hw_tictactoe/solution/tictactoe/tictactoe.cpp) uses `Windows.h` and `Sleep`, so it will not compile unchanged with a Linux/macOS toolchain. These commands do not establish that every exercise builds on every system.

## Checks recorded for this guide

On 16 October 2026, `hello.cpp` and `range_based_for.cpp` compiled with Apple Clang 21.0.0 using the options above and produced the stated output. The [chess guide](../_Chess%20Example/README.md#verification-and-known-limits) records the narrower checks and warnings for its examples. The course has no automated test suite; a successful build is not a check of every algorithm or input case.
