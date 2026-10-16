# Chess: an eight-part C++ exercise

[Back to the course guide](../README.md)

This series grows a small console program from conditionals and functions into a set of classes using inheritance and polymorphism. You enter a board position and piece type; the later programs draw the piece and its attack pattern on an otherwise empty 8×8 board.

The exercise is about C++ programming, not building a complete chess engine. It has no turn-based match, opposing pieces, pawns, check/checkmate or full legal-move system. It is separate from the Ages of Chess Unity application.

## Working through the parts

Read each worksheet and attempt its tasks in order. Start from that part's starter code, or compare it with your completed previous part. Open the solved version after attempting the changes. The original worksheet line numbers may differ from the checked-in files; use the named functions and comments to locate the relevant code.

| Part | Worksheet | Main exercise | Starter | Worked solution |
| --- | --- | --- | --- | --- |
| 1 | [PDF](chess1/Chess%20-%20Part%201.pdf) | Selection: replace if/else with switch; accept piece letters in either case. | [Starter](chess1/chess1.cpp) | [Solution](chess1/chess1_solved.cpp) |
| 2 | [PDF](chess2/Chess%20-%20Part%202.pdf) | Functions: extract and reuse input and piece-type validation. | [Starter](chess2/chess2.cpp) | [Solution](chess2/chess2_solved.cpp) |
| 3 | [PDF](chess3/Chess%20-%20Part%203.pdf) | Board drawing: finish rook/queen patterns and extract drawBoard(). | [Starter](chess3/chess3.cpp) | [Solution](chess3/chess3_solved.cpp) |
| 4 | [PDF](chess4/Chess%20-%20Part%204.pdf) | A Chess class, member state, constructors/destructors, and separate source/header files. | [Starter](chess4/chess4.cpp) | [Solution](chess4/chess4_solved/) |
| 5 | [PDF](chess5/Chess%20-%20Part%205.pdf) | Heap allocation and ownership; extract a Piece class. | [Starter](chess5/chess5/) | [Solution](chess5/chess5_solved/) |
| 6 | [PDF](chess6/Chess%20-%20Part%206.pdf) | Move piece-specific drawing into Piece.getSymbolAt(). | [Starter](chess6/chess6/) | [Solution](chess6/chess6_solved/) |
| 7 | [PDF](chess7/Chess%20-%20Part%207.pdf) | Inheritance: derive Rook from Piece, with a virtual base destructor. At this stage all pieces draw as rooks. | [Starter](chess7/chess7/) | [Solution](chess7/chess7_solved/) |
| 8 | [PDF](chess8/Chess%20-%20Part%208.pages.pdf) | Polymorphism: virtual dispatch and separate rook, knight, bishop, queen and king classes. | [Starter](chess8/chess8/) | [Solution](chess8/chess8_solved/) |

Part 4 also has a [single-file solved version](chess4/chess4_solved.cpp) for comparison with the split-file version. All worksheets have editable Pages originals in the same folders.

Parts 1–3 fit after the lessons on branching, loops and functions. Parts 4–6 use classes, headers, pointers and dynamic allocation; parts 7–8 use inheritance and polymorphism. These are suggested points to return to the exercise, not additional prerequisites beyond the concepts being demonstrated.

## Building the examples

From the **Libraries repository root**:

```sh
cd "C++/C++ Teaching/_Chess Example"
mkdir -p /tmp/lowke-cpp
c++ -std=c++11 -Wall -Wextra chess1/chess1.cpp -o /tmp/lowke-cpp/chess1
/tmp/lowke-cpp/chess1
```

The unmodified part 1 starter asks for row and column values from 1 to 8, then a **numeric** piece choice: 0 rook, 1 knight, 2 bishop, 3 queen, 4 king. Its last prompt says “letter”, but changing the code to accept letters is part of the exercise. For example, enter `4`, `4`, then `0` to select a rook.

For the final split-file solution, start from the `_Chess Example` folder used above:

```sh
cd chess8/chess8_solved
c++ -std=c++11 -Wall -Wextra main.cpp chess.cpp piece.cpp rook.cpp knight.cpp bishop.cpp queen.cpp king.cpp -o /tmp/lowke-cpp/chess8
/tmp/lowke-cpp/chess8
```

The final solution asks for row, column and a piece letter (`R`, `N`, `B`, `Q` or `K`). The later project folders also contain makefiles. Compile within one selected starter or solution directory; do not combine source from multiple stages. To build other single-file stages, substitute the selected `.cpp` file in the first command.

## Verification

On 16 October 2026, all 17 starter and solved variants compiled with Apple Clang 21.0.0 using `-std=c++11 -Wall -Wextra`. The part 1 starter accepted `4`, `4`, `0`, reporting a rook. Every letter-input variant accepted uppercase and lowercase choices, and all 14 versions using `askType()` correctly retried after an invalid letter.

The part 8 solved project also built with `-Werror` and passed AddressSanitizer/UndefinedBehaviorSanitizer runs for all five piece types in both cases, including out-of-range row/column and invalid-letter retries. Separate sanitized checks confirmed that deleting a derived object through `Piece*` calls its derived destructor in the inherited-class versions (part 7 solved and both part 8 variants).

These checks cover compilation, selected input paths and object destruction. They are not exhaustive tests of every attack pattern or malformed input/end-of-file handling.
