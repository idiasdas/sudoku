#include <iostream>
#include <fstream>
#include <string>
#include <exception>

struct position{
    int row;
    int col;
};

void readSudoku( unsigned char sudoku[][9]){
    /*
        Reads the sudoku from the console and store it in the sudoku array.
    */
    char temp;
    for(int i = 0; i < 81; i++){
        std::cin >> temp;
        sudoku[i/9][i%9] = (unsigned char) (temp - '0');
    }
}

void printSudoku( unsigned char sudoku[][9]){
    /*
        Prints the sudoku in the console in a human readable format.
    */
    for(int i = 0; i < 81; i++){
        std::cout << (int) sudoku[i/9][i%9] << " ";
        if((i+1) % 9 == 0){
            std::cout << std::endl;
        }
    }
}

bool readSudokuFromFile( unsigned char sudoku[][9], unsigned char solution[][9], const char *filename, unsigned long int problem_number){
    /*
        Reads the sudoku from a file and store it in the sudoku array.
        The file must have the following format:
        81 numbers representing the sudoku, a comma, and followed by 81 numbers representing the solution.
    */
    std::ifstream sudoku_file;
    std::string line;

    try{
        sudoku_file.open(filename);
        // skips header
        std::getline(sudoku_file, line);
        // Jumps to the <problem_number> line. Each line has 164 characters (81 digits + ',' + 81 digits + '\n')
        sudoku_file.seekg(164 * (problem_number), std::ios::cur);
        std::getline(sudoku_file, line);
    }
    catch( std::exception &e){
        std::cout << "Error: " << e.what() << std::endl;
        return false;
    }

    if(line.size() != 163) {
        std::cout << "Invalid file format" << std::endl;
        return false;
    }

    for(int i = 0; i < 81; i++){
        sudoku[i/9][i%9] = (unsigned char) (line[i] - '0');
        if(solution != nullptr) solution[i/9][i%9] = (unsigned char) (line[i+82] - '0');
    }

    return true;
}

bool verifyCell(unsigned char sudoku[][9], int row, int col){
    /*
        Returns false if a number is repeared in a 3x3 cell starting at row col.
        It does not consider the 0s as repeated numbers.
    */
    unsigned char cell_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char current_value;
    for (int i = 0; i < 3; i++){
        for (int j = 0; j < 3; j++){
            current_value = sudoku[row + i][col + j];
            if (current_value != 0 ){
                if (cell_count[current_value - 1] == 0) cell_count[current_value - 1] = 1;
                else return false;
            }
        }
    }
    return true;
}

bool verifyCells(unsigned char sudoku[][9]){
    /*
        Returns false if a number is repeated in any 3x3 cell in the sudoku.
        It does not consider the 0s as repeated numbers.
    */
    for (int i = 0; i < 3; i++){
        for (int j = 0; j <3; j++){
            if (!verifyCell(sudoku, i*3, j*3)) return false;
        }
    }
    return true;
}

bool verifyRowsAndCols(unsigned char sudoku[][9]){
    /*
        Verifies if any number is repeated in any row or column of the sudoku.
    */
    unsigned char row_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char col_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char current_value;
    for (int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++){
            //verifies the j-th row
            current_value = sudoku[i][j];
            if (current_value != 0){
                if (row_count[current_value - 1] == 0) row_count[current_value - 1] = 1;
                else return false;
            }
            //verifies the j-th column
            current_value = sudoku[j][i];
            if (current_value != 0){
                if (col_count[current_value - 1] == 0) col_count[current_value - 1] = 1;
                else return false;
            }
        }
        for (int j = 0; j < 9; j++){
            row_count[j] = 0;
            col_count[j] = 0;
        }
    }
    return true;
}

bool verifySudoku(unsigned char sudoku[][9]){
    /*
        Verifies if the sudoku board is valid.
    */
    return verifyCells(sudoku) && verifyRowsAndCols(sudoku);
}

void copySudoku(unsigned char sudoku[][9], unsigned char copy[][9]){
    /*
        Copies the sudoku to the copy array.
    */
    for (int i = 0; i < 81; i++){
        copy[i/9][i%9] = sudoku[i/9][i%9];
    }
}

position findEmptyCell(unsigned char sudoku[][9]){
    /*
        Returns the position of the first empty cell in the sudoku.
        If no cell is empty, it returns a position with row and col equal to -1.
    */
    position empty_cell;
    empty_cell.row = -1;
    empty_cell.col = -1;
    for (int i = 0; i < 81; i++){
        if (sudoku[i/9][i%9] == 0){
            empty_cell.row = i/9;
            empty_cell.col = i%9;
            break;
        }
    }
    return empty_cell;
}

bool solveRecursevily(unsigned char sudoku[][9]){
    /*
        Solves the sudoku with recursion.
    */
    position empty_cell = findEmptyCell(sudoku);

    if (empty_cell.row == -1 && verifySudoku(sudoku)) return true;

    for (int i = 1; i < 10; i++){
        sudoku[empty_cell.row][empty_cell.col] = i;
        if (verifySudoku(sudoku) && solveRecursevily(sudoku)) return true;
    }

    sudoku[empty_cell.row][empty_cell.col] = 0;

    return false;
}

bool compareSolution(unsigned char sudoku[][9], unsigned char solution[][9]){
    /*
        Compares the sudoku with the solution.
    */
    for (int i = 0; i < 81; i++){
        if (sudoku[i/9][i%9] != solution[i/9][i%9]) return false;
    }
    return true;
}

position findPreviousModifiedCell(unsigned char sudoku[][9], unsigned char original_sudoku[][9]){
    /*
        Returns the position of the last modified cell in the sudoku.
        If no cell was modified, it returns a position with row and col equal to -1.
        It assumes that every modification was made in order (left right, up down).
    */
    position modified_cell = {.row = -1, .col = -1};
    position empty_cell = findEmptyCell(sudoku);
    int start = 80;
    if (empty_cell.row > 0 || empty_cell.col > 0)
        start = empty_cell.row * 9 + empty_cell.col - 1;
    else return modified_cell;

    for (int i = start; i >= 0; i--){
        if (sudoku[i/9][i%9] != original_sudoku[i/9][i%9]){
            modified_cell.row = i/9;
            modified_cell.col = i%9;
            break;
        }
    }

    return modified_cell;
}

bool solveBruteForce(unsigned char sudoku[][9]){
    /*
        Solves the sudoku with brute force. It follows the idea of the recursive algorithm, but it uses a while loop instead of recursion.
    */
    bool solving = true;
    unsigned char copy_sudoku[9][9];
    copySudoku(sudoku, copy_sudoku);
    position current_cell = findEmptyCell(sudoku);
    while(solving){
        if (current_cell.row == -1 && verifySudoku(sudoku)) break;

        if (sudoku[current_cell.row][current_cell.col] < 9){
            sudoku[current_cell.row][current_cell.col]++;
            if (verifySudoku(sudoku)){
                current_cell = findEmptyCell(sudoku);
            }
        }
        else{
            if(current_cell.row == 0 && current_cell.col == 0) return false;
            sudoku[current_cell.row][current_cell.col] = 0;
            current_cell = findPreviousModifiedCell(sudoku, copy_sudoku);
        }
    }
    return true;
}

int main(){
    /*
        Reads a sudoku from the command line, prints it in a readable format and verify its validity.
    */
    unsigned char sudoku[9][9];
    unsigned char solution[9][9];

    for (int i = 0; i < 1000000; i++){
        readSudokuFromFile(sudoku, solution, "../sudoku.csv", i);
        if (!solveBruteForce(sudoku)) {
            std::cout << "PROBLEM(" << i << "):" << std::endl;
            exit(1);
        }
        else if (!compareSolution(sudoku, solution)){
            std::cout << "PROBLEM(" << i << "):" << std::endl;
            exit(1);
        }

        std::cout << "Solved: " << i << std::endl;
    }

    return 0;
}
