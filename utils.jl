using Base.Iterators: partition, repeated
using CSV

struct Move
    row::UInt8
    col::UInt8
    value::UInt8
end

function print_colored_line(line::Vector{UInt8}, line_number::Int, moves::Vector{Move}, mistakes::Vector{Move} = Move[])::Nothing
    """Prints the current board line.

    Args:
        line: A vector of 9 integers between 0 and 9.
        line_number: The line number.
        moves: The list of changes done it the board.
        mistakes: The list of mistakes done in the board.
    """
    @assert size(line) == (9,)
    @assert all(∈(0:9), line)
    chars = (' ' , '1':'9'...)
    for i in 1:3:9
        for j in i:i+2
            if Move(line_number, j, line[j]) in mistakes
                printstyled(" ", string(line[j]), color = :red)
            elseif Move(line_number, j, line[j]) in moves
                printstyled(" ", string(line[j]), color = :green)
            else
                print(" ", chars[line[j] + 1])
            end
        end
        print(" │")
    end
    println("\b ")
end

function print_colored_sudoku(board:: Matrix{UInt8}, moves::Vector{Move}, mistakes::Vector{Move} = Move[])::Nothing
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
            print_colored_line(board[j,:], j, moves, mistakes)
        end
    end
end

function block_is_valid(block::Vector{UInt8})::Bool
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

function sudoku_is_valid(board::Matrix{UInt8})::Bool
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

function string_to_sudoku(sudoku_txt::String)::Matrix{UInt8}
    """Reads a sequence of 81 characters and returns an Integer matrix 9x9.

    Args:
        sudoku_txt: An string representing a sudoku board.

    Returns:
        The sudoku board as a matrix.
    """
    @assert length(sudoku_txt) == 81
    sudoku = zeros(UInt8, 9, 9)

    for (i, num) in enumerate(sudoku_txt)
        sudoku[i] = UInt8(num) - UInt8('0')
    end
    return sudoku' # Returns the transpose
end

function read_database(filename::String, puzzle_number::Int)::Tuple{Matrix{UInt8}, Matrix{UInt8}}
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

function write_value!(move::Move, board::Matrix{UInt8})::Bool
    """ Tries to write a `value` on `board[pos_x, pos_y]`. You cannot overwrite values different than 0.

    Args:
        move: The move to be written.
        board: The current board.

    Returns:
        If the current value board[pos_x, pos_y] is 0, the value is updated to 'value' and returns true. Otherwise it returns false.
    """
    @assert sudoku_is_valid(board)
    @assert all(∈(1:9), (move.value, move.row, move.col))
    board[move.row, move.col] == 0 ? board[move.row, move.col] = move.value : return false
    return true
end

function undo!(moves::Vector{Move}, board::Matrix{UInt8})::Bool
    """Undoes the last move in the board.

    Args:
        moves: The list of moves done so far.
        board: The current board.

    Returns:
        If there is a move to undo, it is undone and returns true. Otherwise it returns false.
    """
    if isempty(moves)
        return false
    end
    move = pop!(moves)
    board[move.row, move.col] = 0
    return true
end
