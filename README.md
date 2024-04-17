# SUDOKU

This repository contains an implementation of Sudoku including:
- Recursive solving
- Backtracking
- Brute force

Hopefully, soon there will be a neural network implemented from scratch capable of solving it as well.

### Quick Start

Configure CMake and build Sudoku executable with:

```bash
$ cmake -S <sudoku-project-root> -B <sudoku-project-root>/build -DCMAKE_BUILD_TYPE=Debug
$ make -C <sudoku-project-root>/build
```

By default, the executable tries to read the file `<sudoku-project-root>/sudoku.csv`. You can download this file or rename `example_sudoku.csv`.


Then, run the executable. It should solve every problem within the `sudoku.csv`.
