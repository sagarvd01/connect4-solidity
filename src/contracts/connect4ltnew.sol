// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Connect4{
    uint256 rows = 6;
    uint256 cols = 7;
    string[] logs;
    struct errorLog{
        int256 score;
        uint[7][6] board;
        int256 alpha;
        int256 beta;
        uint256 depth;
    }
    struct nums{
        int256 bestScore;
        int256 bestCol;
        int256 score;
    }
    struct playerStates{
        uint256[7][6] boardState;
        uint256 playerWins;
        uint256 computerWins;
        uint256 tiedGames;
    }
    errorLog[] el;
    nums[] nm;
    mapping(address => playerStates) gameState;
    
    constructor(){
        
    }
    function newGame() public returns (playerStates memory){
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols; j++){
                gameState[msg.sender].boardState[i][j] = 0x00;
            }
        }
        return gameState[msg.sender];
    }
    function getLogStruct() external view returns(errorLog[] memory){
        return el;
    }
    function getNms() external view returns(nums[] memory){
        return nm;
    }
    function getGameState() external view returns(playerStates memory){
        return gameState[msg.sender];
    }
    function getLogs() external view returns (string[] memory){
        return logs;
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
            aiMove(msg.sender);
            logs.push("AI move done");
        }
        return gameState[msg.sender];
    }
    function _place(uint256[7][6] memory board, uint256 row, uint256 col, uint256 piece) private pure returns (uint256[7][6] memory){
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
        score = 0;
        logs.push("Inside EvaluateBoard");
        // return 3;
        for (uint256 i = 0; i < 7; i++) {
            for (uint256 j = 0; j < 6; j++) {
                if (board[i][j] == 0) {
                    continue;
                }
                uint256 consecutive = 1;
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

                if (consecutive == 4) {
                    if (board[i][j] == 1) {
                        score = 100;
                    }
                    else {
                        score = -100;
                    }
                }
                else if (consecutive == 3) {
                    if (board[i][j] == 1) {
                        score += 10;
                    }
                    else {
                        score -= 10;
                    }
                }
                else if (consecutive == 2) {
                    if (board[i][j] == 1) {
                        score += 1;
                    }
                    else {
                        score -= 1;
                    }
                }

                consecutive = 1;

                k = 1;
                while (j + k < 6 && board[i][j+k] == board[i][j]) {
                    consecutive++;
                    k++;
                }

                if (consecutive == 4) {
                    if (board[i][j] == 1) {
                        score = 100;
                    }
                    else {
                        score = -100;
                    }
                }
                else if (consecutive == 3) {
                    if (board[i][j] == 1) {
                        score += 10;
                    }
                    else {
                        score -= 10;
                    }
                }
                else if (consecutive == 2) {
                    if (board[i][j] == 1) {
                        score += 1;
                    }
                    else {
                        score -= 1;
                    }
                }

                consecutive = 1;
                k = 1;
                while (i + k < 7 && j + k < 6 && board[i+k][j+k] == board[i][j]) {
                    consecutive++;
                    k++;
                }
                k = 1;
                while (i - k >= 0 && j - k >= 0 && board[i-k][j-k] == board[i][j]) {
                    consecutive++;
                    k++;
                }

                if (consecutive == 4) {
                    if (board[i][j] == 1) {
                        score = 100;
                    }
                    else {
                        score = -100;
                    }
                }
                //
                else if (consecutive == 3) {
                    if (board[i][j] == 1) {
                        score += 10;
                    }
                    else {
                        score -= 10;
                    }
                }
                else if (consecutive == 2) {
                    if (board[i][j] == 1) {
                        score += 1;
                    }
                    else {
                        score -= 1;
                    }
                }

                consecutive = 1;
                k = 1;
                while (i + k < 7 && j - k >= 0 && board[i+k][j-k] == board[i][j]) {
                    consecutive++;
                    k++;
                }
                k = 1;
                while (i - k >= 0 && j + k < 6 && board[i-k][j+k] == board[i][j]) {
                    consecutive++;
                    k++;
                }

                if (consecutive == 4) {
                    if (board[i][j] == 1) {
                        score = 100;
                    }
                    else {
                        score = -100;
                    }
                }
                else if (consecutive == 3) {
                    if (board[i][j] == 1) {
                        score += 10;
                    }
                    else {
                        score -= 10;
                    }
                }
                else if (consecutive == 2) {
                    if (board[i][j] == 1) {
                        score += 1;
                    }
                    else {
                        score -= 1;
                    }
                }
            }
        }

        return score;
    }
    function columnFull(uint256[7][6] memory board, uint256 column) private returns (bool) {
        logs.push("Inside columnfull");
        return board[column][5] != 0;
    }
    function makeMove(uint256[7][6] memory board, uint256 column, bool isMaximizingPlayer) private returns (uint256[7][6] memory) {
        uint256 row = 0;
        logs.push("inside makemove");
        while (row < rows && board[column][row] != 0) {
            row++;
        }
        logs.push("Found row");
        if (isMaximizingPlayer) {
            board[column][row] = 1;
        }
        else {
            board[column][row] = 2;
        }

        return board;
    }
    function _max(int256 a, int256 b) private returns (int256) {
        logs.push("Inside max");
        return a >= b ? a : b;
    }
    function _min(int256 a, int256 b) private returns (int256) {
        logs.push("Inside min");
        return a <= b ? a : b;
    }
    function minimax(uint256[7][6] memory board, bool isMaximizingPlayer, uint256 depth, int256 alpha, int256 beta) private returns (int256 bestColumn) {
        if (_gameOver(board) || depth <= 0) {
            logs.push("Inside minimax if");
            return evaluateBoard(board);
        }

        if (isMaximizingPlayer) {
            logs.push("inside minimax first if maxplayer");
            int256 bestScore = -100;
            for (uint256 i = 0; i < 7; i++) {
                if (!columnFull(board, i)) {
                    logs.push("col not full - minimax");
                    uint256[7][6] memory newBoard = board;
                    newBoard = makeMove(newBoard, i, true);
                    logs.push("before alpha assignment");
                    errorLog memory eLg = errorLog(0, newBoard, alpha, beta, depth - 1);
                    el.push(eLg);
                    int256 score = minimax(newBoard, false, depth - 1, alpha, beta);
                    logs.push("Called recursion inside if");
                    // return 4;
                    nums memory n = nums(score, bestScore, bestColumn);
                    nm.push(n);
                    // return 3;
                    if (score > bestScore) {
                        bestScore = score;
                        bestColumn = int256(i);
                    }
                    alpha = _max(alpha, bestScore);
                    if (beta <= alpha) {
                        break;
                    }
                }
            }

            return bestColumn;
        }
        else {
            logs.push("Inside minmax else maxplayer");
            int256 bestScore = 100;
            for (uint256 i = 0; i < 7; i++) {
                if (!columnFull(board, i)) {
                    logs.push("col not full else -minmax");
                    uint256[7][6] memory newBoard = board;
                    newBoard = makeMove(newBoard, i, false);
                    logs.push("Got score inside else");
                    errorLog memory eLg = errorLog(0, newBoard, alpha, beta, depth - 1);
                    el.push(eLg);
                    // return 4;
                    int256 score = minimax(newBoard, true, depth - 1, alpha, beta);
                    logs.push("Called recursion inside else");
                    // return 2;
                    nums memory n = nums(score, bestScore, bestColumn);
                    nm.push(n);
                    // return 2;
                    if (score < bestScore) {
                        bestScore = score;
                        bestColumn = int256(i);
                    }
                    beta = _min(beta, bestScore);

                    if (beta <= alpha) {
                        break;
                    }
                }
            }
            logs.push("Col found");
            return bestColumn;
        }
    }
    function _checkWinningMove(uint256 playerIndex, address player) private view returns (bool){
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
    function aiMove(address player) private{
        uint256 availableRow;
        uint256 availableCol = uint256(minimax(gameState[player].boardState, true, 5, -1000, 1000));
        for(uint256 i = 0; i < rows; i++){
            if(gameState[player].boardState[i][availableCol] == 0){
                availableRow = i;
                break;
            }
        }
        logs.push("AI move found");
        recordMove(availableRow, availableCol, 2, msg.sender);
    }
}