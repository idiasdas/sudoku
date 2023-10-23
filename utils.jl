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

function print_colored_line(line::Vector{Int}, moves::Vector{Any}, mistakes::Vector{Any} = [])::Nothing
    """Prints the current board line.

    Args:
        board: The current line.
        moves: A list of the changes done in the board.
        mistakes: A list of the mistakes done in the board.
    """
    @assert size(line) == (9,)
    @assert all(∈(0:9), line)
    chars = (' ' , '1':'9'...)
    for i in 1:3:9
        for j in i:i+2
            if (line[j], i, j) in mistakes
                printstyled(" ", string(line[j]), color = :red)
            elseif (line[j], i, j) in moves
                printstyled(" ", string(line[j]), color = :green)
            else
                print(" ", chars[line[j] + 1])
            end
        end
        print(" │")
    end
    println("\b ")
end

function print_colored_sudoku(board:: Matrix{Int}, moves::Vector{Any}, mistakes::Vector{Any} = [])::Nothing
    """Prints a sudoku to the console with colors. The initial values are shown in green.

    Args:
        board: A 9x9 array of integers between 0 and 9.
        moves: The list of changes done it the board.
        mistakes: The list of mistakes done in the board.
    """
    @assert size(board) == (9, 9)
    @assert all(∈(0:9), board)
    # "───────┼───────┼───────"
    separatorrow = join(repeated('─'^7, 3), '┼')

    isfirst = true
    for i in 1:3:9
        isfirst ? (isfirst = false) : println(separatorrow)
        for j in i:i+2
            print_colored_line(board[j,:],moves, mistakes)
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
    @assert length(block) == 9
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

    # No repeated numbers in each line or column
    for i in 1:9
        block_is_valid(vec(board[i, :])) || return false
        block_is_valid(vec(board[:, i])) || return false
    end

    # No repeated numbers in each block
    for ii in partition(1:9, 3), jj in partition(1:9, 3)
        block_is_valid(vec(board[ii, jj])) || return false
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

function read_database(filename::String, puzzle_number::Int)::Tuple{Matrix{Int}, Matrix{Int}}
    """Reads the csv file with puzzles and solutions

    Args:
        filename: Name of the database
        puzzle_number: Number of the puzzle to read

    Returns: A tuple with two matrixes: the puzzle and the solution
    """
    open(filename,"r") do in_file
        # Ignores lines before the puzzle. Including the csv header.
        for _ in 1:puzzle_number
            readline(in_file)
        end
        line = readline(in_file)
        # Each line contains two sequences of digits separated by a comma.
        exp = r"(\d+),(\d+)"
        m = match(exp, line)
        sudoku = string_to_sudoku(String(m[1]))
        solution = string_to_sudoku(String(m[2]))
        return sudoku, solution
    end
end
