#include <iostream>
#include <fstream>
#include <string>
#include <exception>

void read_sudoku( unsigned char sudoku[][9]){
    /*
        Reads the sudoku from the console and store it in the sudoku array.
    */
    char temp;
    for(int i = 0; i < 81; i++){
        std::cin >> temp;
        sudoku[i/9][i%9] = (unsigned char) (temp - '0');
    }
}

void print_sudoku( unsigned char sudoku[][9]){
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

bool read_sudoku_from_file( unsigned char sudoku[][9], unsigned char solution[][9], const char *filename, unsigned long int problem_number){
    /*
        Reads the sudoku from a file and store it in the sudoku array.
        The file must have the following format:
        81 numbers representing the sudoku, a comma, and followed by 81 numbers representing the solution.
    */
    std::ifstream sudoku_file;
    std::string line;

    try{
        sudoku_file.open(filename);
        std::getline(sudoku_file, line); // skips header
        sudoku_file.seekg(164 * (problem_number), std::ios::cur); //Each line has 163 characters (81 digits + ',' + 81 digits + '\n')
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

    // std::cout << line << std::endl;
    for(int i = 0; i < 81; i++){
        sudoku[i/9][i%9] = (unsigned char) (line[i] - '0');
        if(solution != nullptr) solution[i/9][i%9] = (unsigned char) (line[i+82] - '0');
    }

    return true;
}

bool verify_cell(unsigned char sudoku[][9], int row, int col){
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

bool verify_cells(unsigned char sudoku[][9]){
    /*
        Returns false if a number is repeated in any 3x3 cell in the sudoku.
        It does not consider the 0s as repeated numbers.
    */
    for (int i = 0; i < 3; i++){
        for (int j = 0; j <3; j++){
            if (!verify_cell(sudoku, i*3, j*3)) return false;
        }
    }
    return true;
}

bool verify_rows_and_cols(unsigned char sudoku[][9]){
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

void copySudoku(unsigned char sudoku[][9], unsigned char copy[][9]){
    /*
        Copies the sudoku to the copy array.
    */
    for (int i = 0; i < 81; i++){
        copy[i/9][i%9] = sudoku[i/9][i%9];
    }
}

int main(){
    /*
        Reads a sudoku from the command line, prints it in a readable format and verify its validity.
    */
    unsigned char sudoku[9][9];
    unsigned char copy_sudoku[9][9];
    unsigned char solution[9][9];

    read_sudoku_from_file(sudoku, solution, "../sudoku.csv", 0);
    copySudoku(sudoku, copy_sudoku);

    // for (int i = 0; i < 9; i++){
    //     if (read_sudoku_from_file(sudoku, solution, "../sudoku.csv", i)){
    //         std::cout << "PROBLEM(" << i << "):" << std::endl;
    //         print_sudoku(sudoku);
    //         std::cout << "SOLUTION:" << std::endl;
    //         print_sudoku(solution);
    //         std::cout << "---------------:" << std::endl;
    //     }
    // }



    return 0;
}
