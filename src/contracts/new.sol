// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Connect4{
    uint256 rows = 6;
    uint256 cols = 7;
    struct playerStates{
        uint256[7][6] boardState;
        uint256 playerWins;
        uint256 computerWins;
        uint256 tiedGames;
    }
    mapping(address => playerStates) gameState;
    event StringFailure(string stringFailure);
    event BytesFailure(bytes bytesFailure);
    constructor(){
        
    }
    function newGame() public returns (playerStates memory){
        // gameState[msg.sender].boardState = [[0x00,0x00,0x00,0x00,0x00,0x00,0x00],[0x00,0x00,0x00,0x00,0x00,0x00,0x00],[0x00,0x00,0x00,0x00,0x00,0x00,0x00],[0x00,0x00,0x00,0x00,0x00,0x00,0x00],[0x00,0x00,0x00,0x00,0x00,0x00,0x00],[0x00,0x00,0x00,0x00,0x00,0x00,0x00]];
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols; j++){
                gameState[msg.sender].boardState[i][j] = 0x00;
            }
        }
        return gameState[msg.sender];
    }
    function getGameState() external view returns(playerStates memory){
        return gameState[msg.sender];
    }
    function recordMove(uint256 rowIndex, uint256 colIndex, uint256 value, address player) private returns(bool){
        gameState[player].boardState[rowIndex][colIndex] = value;
        bool winner = _checkWinningMove(value, player);
        if(winner == true){
            if(value == 1){
                gameState[msg.sender].playerWins++;
            }
            else{
                gameState[msg.sender].computerWins++;
            }
            return false;
        }
        bool gameOn = _isGameOn(player);
        if(gameOn == false){
            gameState[player].tiedGames++;
            newGame();
            return false;
        }
        return true;

    }
    function playerMove(uint256 colId) external returns(playerStates memory){
        uint256 availableRow;
        for(uint256 i = 0; i < rows; i++){
            if(gameState[msg.sender].boardState[i][colId] == 0){
                availableRow = i;
                break;
            }
        }
        bool cont = recordMove(availableRow, colId, 1, msg.sender);
        if(cont == true){
            aiMove();
        }
        return gameState[msg.sender];
        // gameState[msg.sender].boardState[availableRow][colId] = 1;
    }
    function _isValidLocation(uint256 colId, address player) private view returns (bool){
        bool isValidLoc = false;
        if(gameState[player].boardState[rows - 1][colId] == 0){
            isValidLoc = true;
        }
        return isValidLoc;
    }
    function _getValidColumns(address player) private view returns (uint256[] memory){
        uint256 colLength = 0;
        uint256 colIndex = 0;
        for(uint256 i = 0; i < cols; i++){
            if(_isValidLocation(i, player)){
                // validCols[i] = true;
                colLength++;
            }
        }
        uint256[] memory validCols = new uint256[](colLength);
        for(uint256 i = 0; i < cols; i++){
            if(_isValidLocation(i, player)){
                validCols[colIndex] = i;
                colIndex++;
            }
        }
        return validCols;
    }
    function _getOpenRow(uint256 colId, address player) private view returns(uint256){
        uint256 openRow;
        for(uint256 i = 0; i < rows; i++){
            if(gameState[player].boardState[i][colId] == 0){
                openRow = i;
                break;
            }
        }
        return openRow;
    }
    function _place(uint256[7][6] memory board, uint256 row, uint256 col, uint256 piece) private returns (uint256[7][6] memory){
        board[row][col] = piece;
        return board;
    }
    function _gameOver(uint[7][6] memory board) private view returns (bool){
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols; j++){
                if(board[i][j] == 0){
                    return false;
                }
            }
        }
        return true;
    }
    function evaluateBoard(uint256[7][6] memory board) private returns (int256 score) {
    // initialize the score to 0
        score = 0;

        // loop through the rows and columns of the board
        for (uint256 i = 0; i < 7; i++) {
            for (uint256 j = 0; j < 6; j++) {
                // if the cell is empty, skip it
                if (board[i][j] == 0) {
                    continue;
                }

                // check the horizontal consecutive pieces
                uint256 consecutive = 1; // count the current cell
                uint256 k = 1;
                while (i + k < 7 && board[i+k][j] == board[i][j]) {
                    consecutive++;
                    k++;
                }
                k = 1;
                while (i - k >= 0 && board[i-k][j] == board[i][j]) {
                    consecutive++;
                    k++;
                }

                // update the score based on the number of consecutive pieces
                if (consecutive == 4) {
                    // 4 consecutive pieces is a win
                    if (board[i][j] == 1) {
                        // maximizing player wins
                        score = 100;
                    }
                    else {
                        // minimizing player wins
                        score = -100;
                    }
                }
                else if (consecutive == 3) {
                    // 3 consecutive pieces is a strong potential for a win
                    if (board[i][j] == 1) {
                        // maximizing player has a strong potential for a win
                        score += 10;
                    }
                    else {
                        // minimizing player has a strong potential for a win
                        score -= 10;
                    }
                }
                else if (consecutive == 2) {
                    // 2 consecutive pieces is a potential for a win
                    if (board[i][j] == 1) {
                        // maximizing player has a potential for a win
                        score += 1;
                    }
                    else {
                        // minimizing player has a potential for a win
                        score -= 1;
                    }
                }

                // reset the consecutive count
                consecutive = 1;

                // check the vertical consecutive pieces
                k = 1;
                while (j + k < 6 && board[i][j+k] == board[i][j]) {
                    consecutive++;
                    k++;
                }

                // update the score based on the number of consecutive pieces
                if (consecutive == 4) {
                    // 4 consecutive pieces is a win
                    if (board[i][j] == 1) {
                        // maximizing player wins
                        score = 100;
                    }
                    else {
                        // minimizing player wins
                        score = -100;
                    }
                }
                else if (consecutive == 3) {
                    // 3 consecutive pieces is a strong potential for a win
                    if (board[i][j] == 1) {
                        // maximizing player has a strong potential for a win
                        score += 10;
                    }
                    else {
                        // minimizing player has a strong potential for a win
                        score -= 10;
                    }
                }
            }
        }
        return score;
    }
    function columnFull(uint256[7][6] memory board, uint256 column) private returns (bool) {
        return board[column][5] != 0;
    }
    function makeMove(uint256[7][6] memory board, uint256 column, bool isMaximizingPlayer) private returns (uint256[7][6] memory) {
        // find the first empty cell in the column
        uint256 row = 0;
        while (row < rows && board[column][row] != 0) {
            row++;
        }

        // place the piece on the board
        if (isMaximizingPlayer) {
            board[column][row] = 1;
        }
        else {
            board[column][row] = 2;
        }

        return board;
    }
    function _max(int256 a, int256 b) private pure returns (int256) {
        return a > b ? a : b;
    }
    function _min(int256 a, int256 b) private pure returns (int256) {
        return a < b ? a : b;
    }
    function minimax(uint[7][6] memory board, bool isMaximizingPlayer, uint256 depth, int256 alpha, int256 beta) private returns (int256 bestColumn) {
        if (_gameOver(board) || depth == 0) {
            return evaluateBoard(board);
        }

        // if it is the maximizing player's turn
        if (isMaximizingPlayer) {
            // initialize the best score to a very low value
            int256 bestScore = -100;

            // loop through all the columns to determine the best move
            for (uint256 i = 0; i < 7; i++) {
                // check if the column is full
                if (!columnFull(board, i)) {
                    // make a copy of the board and make the move
                    uint256[7][6] memory newBoard = board;
                    newBoard = makeMove(newBoard, i, true); // true represents the maximizing player

                    // recursively call minimax on the new board and update the best score and column if necessary
                    int256 score = minimax(newBoard, false, depth - 1, alpha, beta);
                    if (score > bestScore) {
                        bestScore = score;
                        bestColumn = int256(i);
                    }

                    // update alpha
                    alpha = _max(alpha, bestScore);

                    // prune the search tree if possible
                    if (beta <= alpha) {
                        break;
                    }
                }
            }

            return bestColumn;
        }
        // if it is the minimizing player's turn
        else {
            // initialize the best score to a very high value
            int256 bestScore = 100;

            // loop through all the columns to determine the best move
            for (uint256 i = 0; i < 7; i++) {
                // check if the column is full
                if (!columnFull(board, i)) {
                    // make a copy of the board and make the move
                    uint256[7][6] memory newBoard = board;
                    newBoard = makeMove(newBoard, i, false); // false represents the minimizing player

                    // recursively call minimax on the new board and update the best score and column if necessary
                    int256 score = minimax(newBoard, true, depth - 1, alpha, beta);
                    if (score < bestScore) {
                        bestScore = score;
                        bestColumn = int256(i);
                    }

                    // update beta
                    beta = _min(beta, bestScore);

                    // prune the search tree if possible
                    if (beta <= alpha) {
                        break;
                    }
                }
            }

            return bestColumn;
        }
    }
    function _isWinningMove(uint256[7][6] memory board, uint256 piece, address player) private view returns (bool){
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols - 3; j++){
                if(board[i][j] == piece && board[i][j + 1] == piece && board[i][j + 2] == piece && board[i][j + 3] == piece){
                    return true;
                }
            }
        }
        for(uint256 i = 0; i < rows - 3; i++){
            for(uint256 j = 0; j < cols; j++){
                if(board[i][j] == piece && board[i + 1][j] == piece && board[i + 2][j] == piece && board[i + 3][j] == piece){
                    return true;
                }
            }
        }
        for(uint256 i = 0; i < rows - 3; i++){
            for(uint256 j = 0; j < cols - 3; j++){
                if(board[i][j] == piece && board[i + 1][j + 1] == piece && board[i + 2][j + 2] == piece && board[i + 3][j + 3] == piece){
                    return true;
                }
            }
        }
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols - 3; j++){
                if(board[i][j] == piece && board[i + 1][j + 1] == piece && board[i + 2][j + 2] == piece && board[i + 3][j + 3] == piece){
                    return true;
                }
            }
        }
    }
    function _pickBestMove(uint256 playerIndex, address player) private returns (uint256){
        uint256[7][6] memory boardState = gameState[player].boardState;
        uint256[] memory validCols = _getValidColumns(player);
        int256 bestScore = -10000;
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, validCols))) % validCols.length;
        uint256 bestCol = validCols[random];
        for(uint256 i = 0; i < validCols.length; i++){
            uint256 row = _getOpenRow(i, player);
            uint256[7][6] memory boardCopy = gameState[player].boardState;
            boardCopy = _place(boardCopy, row, i, 2);
            
        }


    }
    function _checkWinningMove(uint256 playerIndex, address player) private view returns (bool){
        //Check horizontally
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols - 3; j++){
                bool win = true;
                for(uint256 k = j; k < j + 4; k++){
                    if(gameState[player].boardState[i][k] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
            }
        }
        //check vertically
        for(uint256 i = 0; i < cols; i++){
            for(uint256 j = 0; j < rows - 3; j++){
                bool win = true;
                for(uint256 k = j; k < j + 4; k++){
                    if(gameState[player].boardState[k][i] != playerIndex){
                        win = false;
                        break;
                    }
                }
                if(win == true){
                    return true;
                }
            }
        }
        //check diagonally 1-9
        for(uint256 i = 0; i < rows - 3; i++){
            for(uint256 j = 0; j < cols - 3; j++){
                //can't use for loop coz of https://github.com/ethereum/solidity/issues/13212
                if( gameState[player].boardState[i][j] == playerIndex &&
                    gameState[player].boardState[i + 1][j + 1] == playerIndex &&
                    gameState[player].boardState[i + 2][j + 2] == playerIndex &&
                    gameState[player].boardState[i + 3][j + 3] == playerIndex){
                        return true;
                    }
            }
        }
        //check diagonally 3-7
        for(uint256 i = 0; i < rows - 3; i++){
            for(uint256 j = 3; j < cols; j++){
                //can't use for loop coz of https://github.com/ethereum/solidity/issues/13212
                if( gameState[player].boardState[i][j] == playerIndex &&
                    gameState[player].boardState[i + 1][j - 1] == playerIndex &&
                    gameState[player].boardState[i + 2][j - 2] == playerIndex &&
                    gameState[player].boardState[i + 3][j - 3] == playerIndex){
                        return true;
                    }
            }
        }
        return false;
    }
    function _isGameOn(address player) private view returns (bool){
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols; j++){
                if(gameState[player].boardState[i][j] == 0){
                    return true;
                }
            }
        }
        return false;
    }
    function aiMove() private{

    }
}