# Final projects: build a console game

[Back to the course guide](../README.md)

The two project briefs ask you to combine the course concepts into a small playable game. Choose a brief and one of its three game ideas:

| Brief | Approach |
| --- | --- |
| [Procedural final project](Final%20Project.pdf) | Build around variables, functions, loops, conditionals and arrays. |
| [Object-oriented final project](Final%20Project%20OOP.pdf) | Use class objects and inheritance for the game. It presents the same three ideas with this additional requirement. |

Editable Pages originals accompany both PDFs. The briefs are original classroom documents; this folder contains ideas and reference programs, not completed C++ final-project solutions.

## Game choices

- **Choose Your Own Adventure:** a branching story with at least 18 nodes, at least three character statistics, and random events in at least four nodes.
- **Camel:** a turn-based resource-management game. Balance travel speed, water, health and distance while trying to cross a desert and stay ahead of pursuit.
- **Star Trek:** a grid-based space game with movement, phasers, limited torpedoes, shields and random warp repositioning. Arrays and a repeated game loop are central to the brief.

Read the chosen PDF for its exact requirements. The OOP brief repeats some procedural wording, including global variables for story statistics; its opening instruction explicitly asks for classes and inheritance. Use it as a starting point for discussing which object owns each piece of state.

## Historical BASIC references

The `basic_games` folder contains plain-text BASIC programs for reading and comparison:

| Program | Reference idea |
| --- | --- |
| [AMAZING.BAS](basic_games/AMAZING.BAS) | Maze generation |
| [CAMEL.BAS](basic_games/CAMEL.BAS) | Desert travel and resource management |
| [CHASE.BAS](basic_games/CHASE.BAS) | Grid-based pursuit |
| [LUNAR.BAS](basic_games/LUNAR.BAS) | Lunar landing simulation |
| [STARTREK.BAS](basic_games/STARTREK.BAS) | Space exploration and combat |
| [WUMPUS.BAS](basic_games/WUMPUS.BAS) | Exploring a connected cave system |

The included [source note](basic_games/_info.txt) credits David H. Ahl's *BASIC Computer Games* and *More BASIC Computer Games*. `STARTREK.BAS` also credits modifications and corrections by Lorenz Wiest in 2014. Preserve those attributions and the credits inside the programs. These files are BASIC source, not C++ starter files: study their rules and control flow, then implement your own C++ version. Running the original `.BAS` files requires a compatible BASIC environment; none is supplied or verified here.
