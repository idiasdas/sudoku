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

