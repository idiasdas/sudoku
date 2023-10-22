include("utils.jl")

function write_value!(value::Int, pos_x::Int, pos_y::Int, board::Matrix{Int})::Bool
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
    write value x y: Writes `value` at (`x`,`y`).
    undo: Undo the last move.
    show_moves: Shows the list of moves done so far."""

    board = Matrix{Int}(undef, 0, 0)
    original = Matrix{Int}(undef, 0, 0)
    solution = Matrix{Int}(undef, 0, 0)
    puzzle_number = 0
    moves = []


    println("Let's play. Type `help` to see the available commands.")
    while true
        if ! isempty(board)
            print_colored_sudoku(board, original)
        end
        print("Enter command: ")
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
                @assert isa(puzzle_number, Int)
                original,solution = read_database("sudoku.csv", puzzle_number)
                board = copy(original)
                moves = []
            catch e
                println("Problem reading puzzle from database sudoku.csv")
                println(e)
            end
        elseif cmd == "write"
            try
                value = parse(Int, args[1])
                x = parse(Int, args[2])
                y = parse(Int, args[3])
                @assert write_value!(value,x,y,board)
                push!(moves,(value,x,y))
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
                board[move[2],move[3]] = 0
            else
                println("There is nothing to undo.")
            end
        else
            println("Unknown command. Type `help` for ... help.")
        end
    end
end

main_loop()
