include("utils.jl")

function write_value!(value::UInt8, pos_x::UInt8, pos_y::UInt8, board::Matrix{UInt8})::Bool
    """ Tries to write a `value` on `board[pos_x, pos_y]`. You cannot overwrite values different than 0.

    Args:
        value: The new value.
        pos_x: X coordinate on the board.
        pos_y: Y coordinate on the board.
        board: The current board.

    Returns:
        If this new value leads to an invalid board, the value is not written and returns false.
        If the current value board[pos_x, pos_y] is 0, the value is updated to 'value' and returns true. Otherwise it returns false.
    """
    @assert sudoku_is_valid(board)
    @assert all(∈(1:9), (value, pos_x, pos_y))
    old_value = board[pos_x, pos_y]
    if  old_value != 0
        return false
    end
    board[pos_x, pos_y] = value
    if ! sudoku_is_valid(board)
        board[pos_x, pos_y] = old_value
        return false
    else
        return true
    end
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
    moves = []
    mistakes = []

    println("Let's play. Type `help` to see the available commands.")
    while true
        if ! isempty(board)
            print_colored_sudoku(board, moves, mistakes)
            mistakes = []
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
                moves = []
            catch e
                println("Problem reading puzzle from database sudoku.csv")
                println(e)
            end
        elseif cmd == "write"
            try
                value = parse(UInt8, args[1])
                x = parse(UInt8, args[2])
                y = parse(UInt8, args[3])
                write_value!(value, x, y, board) || throw(ArgumentError("Invalid move!"))
                push!(moves, (value, x, y))
            catch e
                println("Problem writting value on board!")
                println(e)
            end
        elseif cmd == "show_moves"
            if ! isempty(moves)
                println("The following moves were made in this board:")
                for move in moves
                    println(move)
                end
            else
                println("The board has no changes.")
            end
        elseif cmd == "undo"
            if ! isempty(moves)
                move = pop!(moves)
                board[move[2], move[3]] = 0
            else
                println("There is nothing to undo.")
            end
        elseif cmd == "check"
            mistakes = []
            for x in moves
                if board[x[2], x[3]] != solution[x[2], x[3]]
                    push!(mistakes, x)
                end
            end
        else
            println("Unknown command. Type `help` for ... help.")
        end
    end
end

main_loop()
