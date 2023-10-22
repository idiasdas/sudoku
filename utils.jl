using Base.Iterators: partition, repeated
using CSV
# using Crayons

function print_sudoku(sudoku::Matrix{Int})::Nothing
    """Prints a sudoku to the console.

    Args:
        sudoku: A 9x9 array of integers between 0 and 9.
    """
    @assert size(sudoku) == (9, 9)
    @assert all(∈(0:9), sudoku)

    # "───────┼───────┼───────"
    separatorrow = join(repeated('─'^7, 3), '┼')
    # "0123456789"
    chars = (' ' , '1':'9'...)
    isfirst = true

    for rows in partition(eachrow(sudoku), 3)
        isfirst ? (isfirst = false) : println(separatorrow)
        for row in rows
            for triple in partition(row, 3)
                print.(' ', chars[triple .+ 1])
                print(" │")
            end
            println("\b ")
        end
    end
end

function print_colored_line(line::Vector{Int}, original::Vector{Int})::Nothing
    """Prints the current board line. Shows the original numbers in green.

    Args:
        board: The current line.
        original: The initial state of the line.
    """
    @assert size(line) == (9,)
    @assert all(∈(0:9), line)
    @assert size(original) == (9,)
    @assert all(∈(0:9), original)
    chars = (' ' , '1':'9'...)
    for i in 1:3:9
        for j in i:i+2
            if line[j] != 0 && line[j] == original[j]
                printstyled(" ", string(line[j]), color = :green)
            else
                print(" ", chars[line[j] + 1])
            end
        end
        print(" │")
    end
    println("\b ")
end

function print_colored_sudoku(board:: Matrix{Int}, original::Matrix{Int})::Nothing
    """Prints a sudoku to the console with colors. The initial values are shown in green.

    Args:
        board: A 9x9 array of integers between 0 and 9.
        original: The initial values of the board.
    """
    @assert size(board) == (9, 9)
    @assert all(∈(0:9), board)
    # "───────┼───────┼───────"
    separatorrow = join(repeated('─'^7, 3), '┼')

    isfirst = true
    for i in 1:3:9
        isfirst ? (isfirst = false) : println(separatorrow)
        for j in i:i+2
            print_colored_line(board[j,:],original[j,:])
        end
    end
end

function block_is_valid(block::Vector{Int})::Bool
    """Checks if a block is valid. Can contain only number between 0 and 9. Any number from 1 to 9 cannot appear twice.

    Args:
        block: A vector of 9 integers between 0 and 9.

    Returns:
        True if the block is valid, False otherwise.
    """
    @assert all(∈(0:9), block)
    count_num = zeros(Int, 10)
    for x in block
        count_num[x + 1] += 1
    end
    return all(<=(1), count_num[2:end])
end

function sudoku_is_valid(board::Matrix{Int})::Bool
    """Checks if a board is valid. Can contain only number between 0 and 9. Any number from 1 to 9 cannot appear twice on a row, column, or slice.

    Args:
        board: A 9x9 array of integers between 0 and 9.

    Returns:
        True if the board is valid, False otherwise.
    """
    @assert size(board) == (9, 9)
    @assert all(∈(0:9), board)

    # No repeated numbers in each line
    for line in eachrow(board)
        for number in (1:9)
            if (count(x -> x == number, line) > 1)
                return false
            end
        end
    end

    # No repeated numbers in each column
    for column in eachcol(board)
        for number in (1:9)
            if (count(x -> x == number, column) > 1)
                return false
            end
        end
    end

    # No repeated numbers in each sector
    for line_sector in (0:2)
        for column_sector in (0:2)
            sector = board[3*line_sector + 1 : 3*line_sector+ 3, 3*column_sector+ 1 : 3*column_sector + 3]
            for number in (1:9)
                if (count(x -> x == number, sector) > 1)
                    return false
                end
            end
        end
    end
    return true
end

function string_to_sudoku(sudoku_txt::String)::Matrix{Int}
    """Reads a sequence of 81 characters and returns an Integer matrix 9x9.

    Args:
        sudoku_txt: An string representing a sudoku board.

    Returns:
        The sudoku board as a matrix.
    """
    @assert length(sudoku_txt) == 81
    sudoku = zeros(Int, 9, 9)

    for (i, num) in enumerate(sudoku_txt)
        sudoku[i] = Int(num) - Int('0')
    end
    return sudoku' # Returns the transpose
end

function read_database(filename::String, puzzle::Int)::Tuple{Matrix{Int}, Matrix{Int}}
    """Reads the csv file with puzzles and solutions

    Args:
        filename: Name of the database
        puzzle: Number of the puzzle to read

    Returns: A tuple with two matrixes: the puzzle and the solution
    """

    open(filename,"r") do in_file
        # Ignores lines before the puzzle. Including the csv header.
        for i in (1:puzzle)
            readline(in_file)
        end
        # Each line contains two sequences of digits separated by a comma.
        line = readline(in_file)
        exp = r"(\d+),(\d+)"
        m = match(exp, line)
        sudoku = string_to_sudoku(String(m[1]))
        solution = string_to_sudoku(String(m[2]))
        return sudoku, solution
    end
end
