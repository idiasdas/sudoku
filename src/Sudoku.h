#pragma once

#include <iostream>
#include <fstream>
#include <string>
#include <exception>

class Sudoku {
private:
    unsigned char m_sudoku[9][9];
    unsigned char m_original_sudoku[9][9];
    unsigned char m_solution[9][9];

public:
    void ReadSudoku();
    void PrintSudoku();
    bool ReadSudokuFromFile(const char *filename, unsigned long int problem_number);
    bool VerifySudoku();
//    void CopySudoku(unsigned char sudoku[9][9]);
    bool SolveRecursevily();
    bool CompareSolution();
    bool SolveBruteForce();

private:
    bool VerifyCell(int row, int col);
    bool VerifyCells();
    bool VerifyRowsAndCols();
    std::pair<int, int> FindEmptyCell();
    std::pair<int, int> FindPreviousModifiedCell();

};
