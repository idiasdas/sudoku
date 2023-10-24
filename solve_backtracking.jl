include("utils.jl")

function get_first_empty_cell(board::Matrix{UInt8})::Tuple{Int, Int}
    """Returns the coordinates of the first empty cell in the board.

    Args:
        board: A 9x9 array of integers between 0 and 9.

        Returns:
            A tuple with the coordinates of the first empty cell. If there is no empty cell, returns (0, 0).
    """
    for i in 1:9, j in 1:9
        if board[i, j] == 0
            return i, j
        end
    end
    return 0, 0
end

function backtrack!(moves::Vector{Move}, board::Matrix{UInt8})::Nothing
    """Goes back one move and tries the next value. If the current value is 9, goes back another move and tries the next value.

    Args:
        moves: The list of changes done it the board.
        board: A 9x9 array of integers between 0 and 9.
    """
    if moves[end].value == 9
        undo!(moves, board)
        backtrack!(moves, board)
    else
        next_move = Move(moves[end].row, moves[end].col, moves[end].value + 1)
        undo!(moves, board)
        write_value!(next_move, board)
        push!(moves, next_move)
    end
    return nothing
end

function solve_backtraking!(board::Matrix{UInt8}, show_process::Bool = false)::Tuple{Vector{Move}, Int}
    """Solves a sudoku using backtracking.

    Args:
        board: A 9x9 array of integers between 0 and 9.
        show_process: If true, shows the process of solving the sudoku.

    Returns:
        The number of writes needed to solve the sudoku.
    """
    @assert size(board) == (9, 9)
    @assert all(∈(0:9), board)
    @assert sudoku_is_valid(board)

    moves = Move[]
    mistakes = Move[]
    writes = 0
    while true
        if sudoku_is_valid(board)
            cur_x, cur_y = get_first_empty_cell(board)
            cur_x != 0 || break
            next_move = Move(cur_x, cur_y, 1)
            write_value!(next_move, board)
            push!(moves, next_move)
        else
            backtrack!(moves, board)
        end
        writes += 1
        mistakes = Move[moves[end]] # Show last move in red
        show_process && print_colored_sudoku(board, moves, mistakes)
        show_process && println()
    end
    return moves, writes
end

total_solving_time = 0.0
total_writes = 0
n = 10
show_process = true
for i in 1:1
    sudoku, solution = read_database("sudoku.csv", i)
    println("Solving sudoku $(i)...")
    moves = Move[]
    global total_solving_time += @elapsed solve_backtraking!(sudoku, show_process)
end
println("Total time: $(total_solving_time) seconds")
println("Average time: $(total_solving_time/n) seconds")
