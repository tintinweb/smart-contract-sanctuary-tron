//SourceUnit: Lottery.sol

//PDX-License-Identifier: MIT
pragma solidity ^0.5.10;

contract Lottery {
    
    address private owner;
    uint256 private prizePool;
    uint256 private percentOfOwner;
    address[] private players;
    uint256 private winnercount = 0;
    //we track all winner form all Lottery for show
    mapping(uint256=>winnerDetails) private winnermember;
    //we need to a map for withdrawWinners function 
    mapping(address=>uint256) private winmember;
    //struct save all details of winner
    struct winnerDetails {
        address addr;
        bool withdraw;
        uint256 totalprice;
    }
    
    
    event member(address addr, uint256 tokens);
    event winners(address addr, uint256 tokens);
    event quantity(uint256 tokens);
    
    //take the owner
    constructor() public {
        owner = msg.sender;
    }
    
    //create a new member 
    function enter() public payable {
        require(msg.value == 1000000 sun, "You must send exactly 1 trx.");
        players.push(msg.sender);
        prizePool += (msg.value*90)/100;
        percentOfOwner +=(msg.value*10)/100;
        emit member(msg.sender, msg.value);
        emit quantity(prizePool);
    }
    
    //do lottery and pick the winner
    function pickWinner() public {
        require(msg.sender == owner, "Only the owner can pick a winner.");
        require(players.length > 0, "no body registered.");
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, players))) % players.length;
        
        winmember[players[randomIndex]] = winnercount;
        winnermember[winnercount].withdraw = false;
        winnermember[winnercount].totalprice = prizePool;
        winnermember[winnercount].addr = players[randomIndex];
        
        emit winners(players[randomIndex], prizePool);
        emit quantity(winnercount);
        delete players;
        
        winnercount++;
    }
    //withdraw for the owner to make empty contract
    function withdraw() public {
        require(msg.sender == owner, "Only the owner can made empty the balance.");
        msg.sender.transfer(percentOfOwner);
        percentOfOwner = 0;
    }
    //withdraw for the people who win in this contract
    function withdrawWinners() public {
        require(winnermember[winmember[msg.sender]].withdraw == false, "you are paid before");
        winnermember[winmember[msg.sender]].withdraw = true;
        prizePool = 0;
        msg.sender.transfer(winnermember[winmember[msg.sender]].totalprice);
    }
    //getting all address and prize to show on site
    function getAllAddressWinner() public view returns (address[] memory,uint256[] memory,bool[] memory){
    address[] memory ret = new address[](winnercount);
    uint256[] memory prize = new uint256[](winnercount);
    bool[] memory active = new bool[](winnercount);
    for (uint i = 0; i < winnercount; i++) {
        ret[i] = winnermember[i].addr;
        prize[i] = winnermember[i].totalprice;
        active[i] = winnermember[i].withdraw;
    }
    
    return (ret,prize,active);
   }
}