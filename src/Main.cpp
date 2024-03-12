#include <iostream>
#include <fstream>
#include <string>

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

void read_sudoku_from_file( unsigned char *sudoku, const char *filename){
    /*
        Reads the sudoku from a file and store it in the sudoku array.
    */
    std::ifstream sudoku_file;
    sudoku_file.open(filename);
    std::string line;
    std::getline(sudoku_file, line);
    std::getline(sudoku_file, line);
    std::getline(sudoku_file, line);

    std::cout << line << std::endl;

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
            current_value = sudoku[i][j];
            if (current_value != 0){
                if (row_count[current_value - 1] == 0) row_count[current_value - 1] = 1;
                else return false;
            }
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

int main(){
    /*
        Reads a sudoku from the command line, prints it in a readable format and verify its validity.
    */
    unsigned char sudoku[9][9];
    // read_sudoku(sudoku);
    // print_sudoku(sudoku);
    // if (verify_cells(sudoku)) std::cout << "Valid" << std::endl;
    // else std::cout << "Invalid" << std::endl;

    read_sudoku_from_file((unsigned char *) sudoku, "../sudoku.csv");
    return 0;
}
