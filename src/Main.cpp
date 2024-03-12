#include<iostream>

#define POSITION(row, col) (row*9 + col)

void read_sudoku( unsigned char *sudoku){
    /*
        Reads the sudoku from the console and store it in the sudoku array.
    */
    char temp;
    for(int i = 0; i < 81; i++){
        std::cin >> temp;
        sudoku[i] = (unsigned char) (temp - '0');
    }
}

void print_sudoku( unsigned char *sudoku){
    /*
        Prints the sudoku in the console in a human readable format.
    */
    for(int i = 0; i < 81; i++){
        std::cout << (int) sudoku[i] << " ";
        if((i+1) % 9 == 0){
            std::cout << std::endl;
        }
    }
}

bool verify_cell(unsigned char *sudoku, int cell_position){
    /*
        Returns false if a number is repeared in a 3x3 cell starting at cell_position.
        It does not consider the 0s as repeated numbers.
    */
    unsigned char cell_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char row = (unsigned char) cell_position / 9;
    unsigned char col = (unsigned char) cell_position % 9;
    unsigned char current_value;
    for (int i = 0; i < 3; i++){
        for (int j = 0; j < 3; j++){
            current_value = sudoku[POSITION(row + i,col + j)];
            if (current_value != 0 ){
                if (cell_count[current_value - 1] == 0) cell_count[current_value - 1] = 1;
                else return false;
            }
        }
    }
    return true;
}

bool verify_cells(unsigned char *sudoku){
    /*
        Returns false if a number is repeated in any 3x3 cell in the sudoku.
        It does not consider the 0s as repeated numbers.
    */
    for (int i = 0; i < 3; i++){
        for (int j = 0; j <3; j++){
            if (!verify_cell(sudoku, POSITION(i*3, j*3))) return false;
        }
    }
    return true;
}

bool verify_rows_and_cols(unsigned char *sudoku){
    /*
        Verifies if any number is repeated in any row or column of the sudoku.
    */
    unsigned char row_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char col_count[9] = {0,0,0,0,0,0,0,0,0};
    unsigned char current_value;
    for (int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++){
            current_value = sudoku[POSITION(i,j)];
            if (current_value != 0){
                if (row_count[current_value - 1] == 0) row_count[current_value - 1] = 1;
                else return false;
            }
            current_value = sudoku[POSITION(j,i)];
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
    unsigned char sudoku[81];
    read_sudoku(sudoku);
    print_sudoku(sudoku);
    if (verify_cells(sudoku)) std::cout << "Valid" << std::endl;
    else std::cout << "Invalid" << std::endl;
    return 0;
}
