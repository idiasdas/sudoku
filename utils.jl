using Base.Iterators: partition, repeated
using CSV
using Crayons

function print_sudoku(sudoku::Array{Int, 2})::Nothing
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

function print_colored_line(line::Array{Int}, original::Array{Int})::Nothing
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
                print(Crayon(foreground = :green)( " ", string(line[j])))
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

