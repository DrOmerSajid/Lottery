//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {

    event Winner(address winner, uint amount);
    address payable[] public players;
    address payable manager;
    uint count = 0;
    uint duration = 0;
    uint amount = 0;
    uint startAt = 0;
    bool statusOfLottery = false;
    

    constructor() {
        manager = payable(msg.sender);
    }


    receive() external payable {
        require(msg.value == amount*1000000000000000000, "Please pay the required amount of ether only"); //change
        require(block.timestamp < startAt + duration);
        players.push(payable(msg.sender));
    }

    function startLottery(uint _duration,uint _amount) external {
        require(msg.sender == manager);
        require(statusOfLottery == false, "Lottery is already started");
        statusOfLottery = true;
        duration = _duration;
        amount = _amount;
        startAt = block.timestamp;
    }

    function WinningAmount() public view returns (uint256) {
        return players.length*amount;
    }

    function timeLeft() public view returns(uint){
        require(statusOfLottery == true);
        uint timeleft;
        if(block.timestamp > (startAt+duration)){
            timeleft = 0;
        }
        else 
        timeleft =  (startAt+duration) - block.timestamp;

        return timeleft;
    }

    function random() internal view returns (uint256) {
        count+1;
        return uint256(keccak256(abi.encodePacked(block.difficulty,block.timestamp,players.length,count)));
    }

    function pickWinner() public payable {
        require(msg.sender == manager, "You are not the manager");
        require(players.length >= 2, "Players are less than 2");
        require(block.timestamp > startAt + duration, "Lottery has not ended yet");
        players[random() % players.length].transfer(uint((players.length-1)*amount)*1000000000000000000);
        statusOfLottery = false;
        emit Winner(players[random() % players.length], ((players.length-1)*amount)*1000000000000000000);
        delete players;
    }

    function allPlayers() external view returns(address payable[] memory){
        return players;
    }
}



