#include<iostream>

#define POSITION(row, col) (row*9 + col)

/**
 * @brief Reads the sudoku from the console and store it in the sudoku array.
 *
 * @param sudoku The array where the sudoku will be stored.
 */
void read_sudoku( unsigned char *sudoku){
    char temp;
    for(int i = 0; i < 81; i++){
        std::cin >> temp;
        sudoku[i] = (unsigned char) (temp - '0');
    }
}

/**
 * @brief Prints the sudoku in the console in a human readable format.
 *
 * @param sudoku The array where the sudoku is stored.
 */
void print_sudoku( unsigned char *sudoku){
    for(int i = 0; i < 81; i++){
        std::cout << (int) sudoku[i] << " ";
        if((i+1) % 9 == 0){
            std::cout << std::endl;
        }
    }
}

/**
 * @brief Returns false if a number is repeared in a 3x3 cell starting at cell_position. It does not consider the 0s as repeated numbers.
 *
 * @param sudoku The array where the sudoku is stored.
 * @param cell_position The position of the top left cell of the 3x3 cell in the sudoku array.
 * @return true
 * @return false
 */
bool verify_cell(unsigned char *sudoku, int cell_position){
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

/**
 * @brief  Returns false if a number is repeared in any 3x3 cell in the sudoku.
    It does not consider the 0s as repeated numbers.
 *
 * @param sudoku
 * @return true
 * @return false
 */
bool verify_cells(unsigned char *sudoku){
    for (int i = 0; i < 3; i++){
        for (int j = 0; j <3; j++){
            if (!verify_cell(sudoku, POSITION(i*3, j*3))) return false;
        }
    }
    return true;
}

/**
 * @brief Verifies if any number is repeated in any row or column of the sudoku.
 *
 * @param sudoku
 * @return true
 * @return false
 */
bool verify_rows_and_cols(unsigned char *sudoku){
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
