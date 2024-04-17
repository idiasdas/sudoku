#include "Sudoku.h"

void Sudoku::ReadSudoku(){
    /*
        Reads the sudoku from the console and store it in the sudoku array.
    */
    char temp;
    for(int i = 0; i < 81; i++){
        std::cin >> temp;
        m_sudoku[i/9][i%9] = (unsigned char) (temp - '0');
    }
}

void Sudoku::PrintSudoku(){
    /*
        Prints the sudoku in the console in a human readable format.
    */
    for(int i = 0; i < 81; i++){
        std::cout << (int) m_sudoku[i/9][i%9] << " ";
        if((i+1) % 9 == 0){
            std::cout << std::endl;
        }
    }
}

bool Sudoku::ReadSudokuFromFile(const char *filename, unsigned long int problem_number){
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
        m_sudoku[i/9][i%9] = (unsigned char) (line[i] - '0');
        m_solution[i/9][i%9] = (unsigned char) (line[i+82] - '0');
    }

    return true;
}

bool Sudoku::VerifyCell(int row, int col){
    /*
        Returns false if a number is repeared in a 3x3 cell starting at row col.
        It does not consider the 0s as repeated numbers.
    */
    unsigned char cell_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char current_value;
    for (int i = 0; i < 3; i++){
        for (int j = 0; j < 3; j++){
            current_value = m_sudoku[row + i][col + j];
            if (current_value != 0 ){
                if (cell_count[current_value - 1] == 0) cell_count[current_value - 1] = 1;
                else return false;
            }
        }
    }
    return true;
}

bool Sudoku::VerifyCells(){
    /*
        Returns false if a number is repeated in any 3x3 cell.
    */
    for (int i = 0; i < 9; i+=3){
        for (int j = 0; j < 9; j+=3){
            if (!VerifyCell(i, j)) return false;
        }
    }
    return true;
}

bool Sudoku::VerifyRowsAndCols(){
    /*
        Returns false if a number is repeated in any row or column.
    */
    unsigned char row_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char col_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char current_value;
    for (int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++){
            current_value = m_sudoku[i][j];
            if (current_value != 0){
                if (row_count[current_value - 1] == 0) row_count[current_value - 1] = 1;
                else return false;
            }
            current_value = m_sudoku[j][i];
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

bool Sudoku::VerifySudoku(){
    /*
        Verifies if the sudoku is valid.
    */
    return VerifyCells() && VerifyRowsAndCols();
}

std::pair<int, int> Sudoku::FindEmptyCell(){
    /*
        Returns the position of the first empty cell in the sudoku.
        If no cell is empty, it returns a position with row and col equal to -1.
    */
    std::pair<int, int> empty_cell;
    empty_cell.first = -1;
    empty_cell.second = -1;
    for (int i = 0; i < 81; i++){
        if (m_sudoku[i/9][i%9] == 0){
            empty_cell.first = i/9;
            empty_cell.second = i%9;
            break;
        }
    }
    return empty_cell;
}

bool Sudoku::SolveRecursevily(){
    /*
        Solves the sudoku with recursion.
    */
    std::pair empty_cell = FindEmptyCell();

    if (empty_cell.first == -1 && VerifySudoku()) return true;

    for (int i = 1; i < 10; i++){
        m_sudoku[empty_cell.first][empty_cell.second] = i;
        if (VerifySudoku() && SolveRecursevily()) return true;
    }

    m_sudoku[empty_cell.first][empty_cell.second] = 0;

    return false;
}

bool Sudoku::CompareSolution(){
    /*
        Compares the sudoku with the solution.
    */
    for (int i = 0; i < 81; i++){
        if (m_sudoku[i/9][i%9] != m_solution[i/9][i%9]) return false;
    }
    return true;
}



std::pair<int, int> Sudoku::FindPreviousModifiedCell(){
    /*
        Returns the position of the last modified cell in the sudoku.
        If no cell was modified, it returns a position with row and col equal to -1.
        It assumes that every modification was made in order (left right, up down).
    */
    std::pair<int, int> modified_cell = {-1, -1};
    std::pair<int, int> empty_cell = FindEmptyCell();
    int start = 80;
    if (empty_cell.first > 0 || empty_cell.second > 0)
        start = empty_cell.first * 9 + empty_cell.second - 1;
    else return modified_cell;

    for (int i = start; i >= 0; i--){
        if (m_sudoku[i/9][i%9] != m_original_sudoku[i/9][i%9]){
            modified_cell.first = i/9;
            modified_cell.second = i%9;
            break;
        }
    }

    return modified_cell;
}

bool Sudoku::SolveBruteForce(){
    /*
        Solves the sudoku with brute force. It follows the idea of the recursive algorithm, but it uses a while loop instead of recursion.
    */
    bool solving = true;
    unsigned char copy_sudoku[9][9];
    copySudoku(sudoku, copy_sudoku);
    std::pair<int, int> current_cell = findEmptyCell(sudoku);
    while(solving){
        if (current_cell.first == -1 && verifySudoku(sudoku)) break;

        if (sudoku[current_cell.first][current_cell.second] < 9){
            sudoku[current_cell.first][current_cell.second]++;
            if (verifySudoku(sudoku)){
                current_cell = findEmptyCell(sudoku);
            }
        }
        else{
            if(current_cell.first == 0 && current_cell.second == 0) return false;
            sudoku[current_cell.first][current_cell.second] = 0;
            current_cell = findPreviousModifiedCell(sudoku, copy_sudoku);
        }
    }
    return true;
}
