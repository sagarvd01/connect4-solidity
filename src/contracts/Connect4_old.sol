// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Connect4{
    uint256 rows = 6;
    uint256 cols = 7;
    struct playerStates{
        uint256[6][7] boardState;
        uint256 playerWins;
        uint256 computerWins;
        uint256 tiedGames;
    }
    mapping(address => playerStates) gameState;
    constructor(){
        
    }
    function newGame() public{
        for(uint256 i = 0; i < rows; i++){
            for(uint256 j = 0; j < cols; j++){
                gameState[msg.sender].boardState[i][j] = 0;
            }
        }
    }
    function recordMove(uint256 rowIndex, uint256 colIndex, uint256 value, address player) private{
        gameState[player].boardState[rowIndex][colIndex] = value;
    }
    function playerMove(uint256 colId) external returns(playerStates memory){
        uint256 availableRow;
        for(uint256 i = 0; i < rows; i++){
            if(gameState[msg.sender].boardState[i][colId] == 0){
                availableRow = i;
                break;
            }
        }
        recordMove(availableRow, colId, 1, msg.sender);
        bool win = _checkWinningMove(1, msg.sender);
        if(win){
            gameState[msg.sender].playerWins++;
        }
        return gameState[msg.sender];
        // gameState[msg.sender].boardState[availableRow][colId] = 1;
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
    function _checkIfAllFilled(address player) private view returns (bool){
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