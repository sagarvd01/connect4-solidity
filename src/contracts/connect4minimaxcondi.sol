// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Connect4{
    uint ROW_COUNT = 6;
    uint COL_COUNT = 7;
    uint WINDOW_LENGTH = 4;
    uint PLAYER_PIECE = 1;
    uint EMPTY_PIECE = 0;
    uint AI_PIECE = 2;
    int MATH_INF = 100000000;
    struct playerStates{
        uint[7][6] boardState;
        uint8 playerWins;
        uint8 computerWins;
        uint8 tiedGames;
        string message;
    }
    mapping(address => playerStates) gameState;

    function newGame() public returns (playerStates memory){
        _setMessage(msg.sender, "");
        for(uint i = 0; i < ROW_COUNT; i++){
            for(uint j = 0; j < COL_COUNT; j++){
                gameState[msg.sender].boardState[i][j] = 0;
            }
        }
        return gameState[msg.sender];
    }
    function getGameState() external view returns(playerStates memory){
        return gameState[msg.sender];
    }
    function _recordMove(uint[7][6] memory board, uint row, uint col, uint player) private pure returns (uint[7][6] memory){
        board[row][col] = player;
        return board;
    }
    function _checkColEmpty(uint[7][6] memory board, uint col) private view returns (bool){
        if(board[ROW_COUNT - 1][col] == 0){
            return true;
        }
        return false;
    }
    function _getEmptyRow(uint[7][6] memory board, uint col) private view returns (uint row){
        for(uint i = 0; i < ROW_COUNT; i++){
            if(board[i][col] == 0){
                row = i;
                break;
            }
        }
        return row;
    }
    function _gameOver(uint[7][6] memory board) private view returns (bool gameover){
        gameover = true;
        for(uint i = 0; i < ROW_COUNT; i++){
            for(uint j = 0; j < COL_COUNT; j++){
                if(board[i][j] == 0){
                    gameover = false;
                    break;
                }
            }
        }
        return gameover;
    }
    function _max(int a, int b) private pure returns (int){
        return a > b ? a : b;
    }
    function _min(int a, int b) private pure returns (int){
        return a < b ? a : b;
    }
    function _checkIfWon(uint[7][6] memory board, uint playerIndex) private view returns (bool){
        for(uint i = 0; i < ROW_COUNT; i++){
            for(uint j = 0; j < COL_COUNT - 3; j++){
                bool win = true;
                for(uint k = j; k < j + 4; k++){
                    if(board[i][k] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
            }
        }
        for(uint i = 0; i < COL_COUNT; i++){
            for(uint j = 0; j < ROW_COUNT - 3; j++){
                bool win = true;
                for(uint k = j; k < j + 4; k++){
                    if(board[k][i] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
            }
        }
        for(uint i = 0; i < ROW_COUNT - 3; i++){
            for(uint j = 0; j < COL_COUNT - 3; j++){
                //can't use for loop coz of https://github.com/ethereum/solidity/issues/13212
                bool win = true;
                for(uint k = 0; k < WINDOW_LENGTH; k++){
                    if(board[i + k][j + k] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
                // if( board[i][j] == playerIndex &&
                //     board[i + 1][j + 1] == playerIndex &&
                //     board[i + 2][j + 2] == playerIndex &&
                //     board[i + 3][j + 3] == playerIndex){
                //         return true;
                //     }
            }
        }
        for(uint i = 0; i < ROW_COUNT - 3; i++){
            for(uint j = 3; j < COL_COUNT; j++){
                //can't use for loop coz of https://github.com/ethereum/solidity/issues/13212
                bool win = true;
                for(uint k = 0; k < WINDOW_LENGTH; k++){
                    if(board[i + k][j - k] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
                // if( board[i][j] == playerIndex &&
                //     board[i + 1][j - 1] == playerIndex &&
                //     board[i + 2][j - 2] == playerIndex &&
                //     board[i + 3][j - 3] == playerIndex){
                //         return true;
                //     }
            }
        }
        return false;
    }
    function _evaluateWindow(uint[4] memory window, uint piece) private view returns (int score){
        score = 0;
        uint opp_piece = PLAYER_PIECE;
        if(piece == PLAYER_PIECE){
            opp_piece = AI_PIECE;
        }
        uint piece_count = 0;
        uint op_piece_count = 0;
        uint empty_count = 0;
        for(uint i = 0; i < WINDOW_LENGTH; i++){
            if(window[i] == piece){
                piece_count++;
            }
            else
            if(window[i] == opp_piece){
                op_piece_count++;
            }
            else
            if(window[i] == 0){
                empty_count++;
            }
        }
        if(piece_count == 4){
            score += 100;
        }
        else if(piece_count == 3 && empty_count == 1){
            score += 5;
        }
        else if(piece_count == 2 && empty_count == 2){
            score += 2;
        }
        
        if(op_piece_count == 3 && empty_count == 1){
            score -= 4;
        }
        return score;
    }
    function _scorePosition(uint[7][6] memory board, uint piece) private view returns (int){
        uint[6] memory center_array;
        int score = 0;
        uint center_col = COL_COUNT / 2;
        for(uint i = 0; i < ROW_COUNT; i++){
            center_array[i] = board[i][center_col];
            if(board[i][center_col] == piece){
                score++;
            }
        }
        score = score * 3;

        //horizontal score
        for(uint i = 0; i < ROW_COUNT; i++){
            // uint[7] memory row = board[i]; 
            for(uint j = 0; j < COL_COUNT - 3; j++){
                uint index = 0;
                uint[4] memory window;
                for(uint k = j; k < j + WINDOW_LENGTH; k++){
                    window[index] = board[i][k];
                    index++;
                    score += _evaluateWindow(window, piece);
                }
            }
        }

        //vertical score
        for(uint i = 0; i < COL_COUNT; i++){
            for(uint j = 0; j < ROW_COUNT - 3; j++){
                uint index = 0;
                uint[4] memory window;
                for(uint k = j; k < k + WINDOW_LENGTH; k++){
                    window[index] = board[k][i];
                    index++;
                    score += _evaluateWindow(window, piece);
                }
            }
        }

        //positive slope
        for(uint i = 0; i < ROW_COUNT - 3; i++){
            for(uint j = 0; j < COL_COUNT - 3; j++){
                uint index = 0;
                uint[4] memory window;
                for(uint k = 0; k < WINDOW_LENGTH; k++){
                    window[index] = board[i + k][j + k];
                    index++;
                    score += _evaluateWindow(window, piece);
                }
            }
        }

        //negative slope
        for(uint i = 0; i < ROW_COUNT - 3; i++){
            for(uint j = 3; j < COL_COUNT; j++){
                uint index = 0;
                uint[4] memory window;
                for(uint k = 0; k < WINDOW_LENGTH; k++){
                    window[index] = board[i + k][j - k];
                    index++;
                    score += _evaluateWindow(window, piece);
                }
            }
        }
        return score;
    }
    function _getValidCols(uint[7][6] memory board) private view returns (uint[] memory availCols){
        uint index = 0;
        for(uint i = 0; i < COL_COUNT; i++){
            if(_checkColEmpty(board, i)){
                availCols[index] = i;
                index++;
            }
        }
        return availCols;
    }
    function _isTerminalNode(uint[7][6] memory board) private view returns (bool){
        return (_checkIfWon(board, PLAYER_PIECE) || _checkIfWon(board, AI_PIECE) || _gameOver(board));
    }

    function _random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%251;
        // return uint(uint256(()%251));
    }
    function _copyBoard(uint[7][6] memory board) private view returns(uint[7][6] memory newBoard){
        for(uint i = 0; i < ROW_COUNT; i++){
            for(uint j = 0; j < COL_COUNT; j++){
                newBoard[i][j] = board[i][j];
            }
        }
        return newBoard;
    }
    function _dropPiece(uint[7][6] memory board, uint row, uint col, uint piece) private pure returns(uint[7][6] memory){
        board[row][col] = piece;
        return board;
    }
    function _minimax(uint[7][6] memory board, uint depth, int alpha, int beta, bool maximizingPlayer, bool val) private view returns (int){ //if val true, return value else column
        uint[] memory validLocs = _getValidCols(board);
        bool isTerminal = _isTerminalNode(board);
        
        if(depth == 0 || isTerminal){
            if(isTerminal){
                if(_checkIfWon(board, AI_PIECE)){
                    return 100000;
                }
                else
                if(_checkIfWon(board, PLAYER_PIECE)){
                    return -100000;
                }
                else{
                    //gameover
                    return 0;
                }
            }
            else{
                return _scorePosition(board, AI_PIECE);
            }
        }

        if(maximizingPlayer){
            int value = -MATH_INF;
            uint column = validLocs[_random() % validLocs.length];
            
            for(uint i = 0; i < validLocs.length; i++){
                uint col = validLocs[i];
                uint row = _getEmptyRow(board, col);
                uint[7][6] memory boardCopy = _copyBoard(board);
                boardCopy = _dropPiece(boardCopy, row, col, AI_PIECE);
                int newScore = _minimax(boardCopy, depth - 1, alpha, beta, false, true);
                if(newScore > value){
                    value = newScore;
                    column = col;
                }
                alpha = _max(alpha, value);

                if(alpha >= beta){
                    break;
                }
            }
            return val ? value : int(column);
        }
        else{
            int value = MATH_INF;
            uint column = validLocs[_random() % validLocs.length];

            for(uint i = 0; i < validLocs.length; i++){
                uint col = validLocs[i];
                uint row = _getEmptyRow(board, col);
                uint[7][6] memory boardCopy = _copyBoard(board);
                boardCopy = _dropPiece(boardCopy, row, col, PLAYER_PIECE);
                int newScore = _minimax(boardCopy, depth - 1, alpha, beta, true, true);

                if(newScore < value){
                    value = newScore;
                    column = col;
                }
                beta = _min(beta, value);

                if(alpha >= beta){
                    break;
                }
            }
            return val ? value : int(column);
        }
    }

    function _setMessage(address player, string memory message) private{
        gameState[player].message = message;
    }

    function _aiMove(address player) private{
        uint[7][6] memory bd_copy = _copyBoard(gameState[player].boardState);
        uint col = uint(_minimax(bd_copy, 5, -MATH_INF, MATH_INF, true, false));
        if(_checkColEmpty(bd_copy, col)){
            uint row = _getEmptyRow(bd_copy, col);
            gameState[player].boardState[row][col] = AI_PIECE;

            if(_checkIfWon(gameState[player].boardState, AI_PIECE)){
                gameState[player].computerWins++;
                _setMessage(player, "Computer Wins");
            }
            else
            if(_gameOver(gameState[player].boardState)){
                gameState[player].tiedGames++;
                _setMessage(player, "Game Tied");
                newGame();
            }
        }
    }
    function playerMove(uint col) external returns (playerStates memory){
        _setMessage(msg.sender, "");
        if(_checkColEmpty(gameState[msg.sender].boardState, col)){
            uint row = _getEmptyRow(gameState[msg.sender].boardState, col);
            gameState[msg.sender].boardState[row][col] = PLAYER_PIECE;

            if(_checkIfWon(gameState[msg.sender].boardState, PLAYER_PIECE)){
                gameState[msg.sender].playerWins++;
                _setMessage(msg.sender, "Player Wins");
            }
            else
            if(_gameOver(gameState[msg.sender].boardState)){
                gameState[msg.sender].tiedGames++;
                _setMessage(msg.sender, "Game Tied");
                newGame();
            }
            else{
                _aiMove(msg.sender);
            }
            return gameState[msg.sender];
        }
        else{
            _setMessage(msg.sender, "Invalid Move");
            return gameState[msg.sender];
        }
    }
}