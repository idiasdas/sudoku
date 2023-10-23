include("utils.jl")

function write_value!(move::Move, board::Matrix{UInt8})::Bool
    """ Tries to write a `value` on `board[pos_x, pos_y]`. You cannot overwrite values different than 0.

    Args:
        move: The move to be written.
        board: The current board.

    Returns:
        If this new value leads to an invalid board, the value is not written and returns false.
        If the current value board[pos_x, pos_y] is 0, the value is updated to 'value' and returns true. Otherwise it returns false.
    """
    @assert sudoku_is_valid(board)
    @assert all(∈(1:9), (move.value, move.row, move.col))

    board[move.row, move.col] == 0 ? board[move.row, move.col] = move.value : return false
    if !sudoku_is_valid(board)
        board[move.row, move.col] = 0
        return false
    end
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
    @assert sudoku_is_valid(board)
    if isempty(moves)
        return false
    end
    move = pop!(moves)
    board[move.row, move.col] = 0
    return true
end

function main_loop()::Nothing
    commands_list = """help: Shows this list.
    exit: Closes the program.
    open x: Opens sudoku puzze number `x`.
    write value x y: Writes `value` at (`x`, `y`).
    undo: Undo the last move.
    show_moves: Shows the list of moves done so far.
    check: Shows if any of the moves done so far are not in the solution."""

    board = Matrix{UInt8}(undef, 0, 0)
    original = Matrix{UInt8}(undef, 0, 0)
    solution = Matrix{UInt8}(undef, 0, 0)
    puzzle_number = 0
    moves = Move[]
    mistakes = Move[]

    println("Let's play. Type `help` to see the available commands.")
    while true
        if ! isempty(board)
            print_colored_sudoku(board, moves, mistakes)
            mistakes = Move[]
        end
        print("\nEnter command: ")
        cmd_line = readline()
        cmd = split(cmd_line, " ")[1]
        args = length(split(cmd_line, " ")) >1 ? split(cmd_line, " ")[2:end] : []
        if cmd == "exit"
            println("Exiting program.")
            break
        elseif cmd == "help"
            println(commands_list)
        elseif cmd == "open"
            try
                puzzle_number = parse(Int, args[1])
                original, solution = read_database("sudoku.csv", puzzle_number)
                board = copy(original)
                moves = Vector{Move}(undef, 0)
            catch e
                println("Problem reading puzzle from database sudoku.csv")
                println(e)
            end
        elseif cmd == "write"
            try
                move = Move(parse(UInt8, args[2]), parse(UInt8, args[3]), parse(UInt8, args[1]))
                write_value!(move, board) || throw(ArgumentError("Invalid move!"))
                push!(moves, move)
            catch e
                println("Problem writting value on board!")
                println(e)
            end
        elseif cmd == "show_moves"
            if ! isempty(moves)
                println("The following moves were made in this board:")
                for move in moves
                    println("\t($(move.row), $(move.col)) = $(move.value)")
                end
            else
                println("The board has no changes.")
            end
        elseif cmd == "undo"
            undo!(moves, board) || println("There is nothing to undo.")
        elseif cmd == "check"
            mistakes = [move for move in moves if move.value != solution[move.row, move.col]]
        else
            println("Unknown command. Type `help` for ... help.")
        end
    end
end

main_loop()
