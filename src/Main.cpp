#include <iostream>
#include "Sudoku.h"

int main(){
    /*
        Reads a sudoku from the command line, prints it in a readable format and verify its validity.
    */
    Sudoku sudoku;

    for (int i = 0; i < 1000000; i++){
        if(! sudoku.ReadSudokuFromFile("../sudoku.csv", i)) {
            std::cout << "PROBLEM(" << i << "):" << std::endl;
            exit(1);
        }
        if (!sudoku.SolveBruteForce()) {
            std::cout << "PROBLEM(" << i << "):" << std::endl;
            exit(1);
        }
        else if (!sudoku.CompareSolution()){
            std::cout << "PROBLEM(" << i << "):" << std::endl;
            exit(1);
        }

        std::cout << "Solved: " << i << std::endl;
    }

    return 0;
}
