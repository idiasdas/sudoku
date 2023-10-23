include("utils.jl")

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
