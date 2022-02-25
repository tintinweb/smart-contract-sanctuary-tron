//SourceUnit: Base.sol

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

    library SafeMath {//konwnsec//IERC20 接口
        function mul(uint256 a, uint256 b) internal pure returns (uint256) {
            if (a == 0) {
                return 0; 
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c; 
        }
        function div(uint256 a, uint256 b) internal pure returns (uint256) {
// assert(b > 0); // Solidity automatically throws when dividing by 0
            uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold
            return c; 
        }
        function sub(uint256 a, uint256 b) internal pure returns (uint256) {
            assert(b <= a);
            return a - b; 
        }

        function add(uint256 a, uint256 b) internal pure returns (uint256) {
            uint256 c = a + b;
            assert(c >= a);
            return c; 
        }
    }

    interface Erc20Token {//konwnsec//ERC20 接口
        function totalSupply() external view returns (uint256);
        function balanceOf(address _who) external view returns (uint256);
        function transfer(address _to, uint256 _value) external;
        function allowance(address _owner, address _spender) external view returns (uint256);
        function transferFrom(address _from, address _to, uint256 _value) external;
        function approve(address _spender, uint256 _value) external; 
        function burnFrom(address _from, uint256 _value) external; 
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        

    }
    
    
    interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

    
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token constant  internal TPAddr = Erc20Token(0xC3C15d77fC4287F3c6EF61aC2Af8a739E743C3Fd);
        address  _owner;

        modifier onlyOwner() {
            require(msg.sender == _owner, "Permissiondenied"); _;
        }
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "CannotBeAZeroAddress"); _; 
        }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
}

//SourceUnit: DataPlayer.sol

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./Base.sol";

  
contract DataPlayer is Base{
      
        struct Player{
            uint256 id; 
            address addr; 
            uint256 LP_Amount; 
            uint256 endTime;

        }
 
    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 

    function getPlayerByAddr(address playerAddr) public view returns(uint256[] memory) { 
        uint256 id = _playerAddrMap[playerAddr];
        Player memory player = _playerMap[id];
         uint256[] memory temp = new uint256[](11);
        temp[1] = player.LP_Amount;
        return temp; 
    }



    function getAddrById(uint256 id) public view returns(address) {//konwnsec//通过 id 获取玩家地址
        return _playerMap[id].addr; 
    }
    function getIdByAddr(address addr) public view returns(uint256) {//konwnsec//通过地址获取玩家 id
        return _playerAddrMap[addr]; 
    }
 

}

//SourceUnit: Dividends.sol

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";


contract Dividends is DataPlayer {
    uint256 private constant  four_Month = 10368000;
    constructor(address owner)
    isZeroAddr(owner) public {
        _owner = owner;  
    }

     function investTermLP(uint256 amount) public payable   {
        require(amount >= 1, "Not enough input");
        TPAddr.transferFrom(msg.sender, address(this), amount);
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        uint256 endTime =block.timestamp.add(four_Month);
        _playerMap[id].LP_Amount = _playerMap[id].LP_Amount.add(amount);
        _playerMap[id].endTime = endTime;
    }

    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "noThisUser"); // 用户不存在
        _; 
    }

    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].addr = playerAddr;
        }
    }
    
    function extractTermLP() public  isRealPlayer  {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].endTime != 0, "timeout");
        require(block.timestamp>_playerMap[id].endTime, "timeout");
        TPAddr.transfer(msg.sender, _playerMap[id].LP_Amount);
        _playerMap[id].endTime = 0;
        _playerMap[id].LP_Amount = 0;
    }

    function extractLP() public isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        uint256 LPamount = _playerMap[id].LP_Amount;
        if(LPamount > 0){
                require(_playerMap[id].endTime == 0, "timeout");
                TPAddr.transfer(msg.sender, LPamount);
                _playerMap[id].LP_Amount = 0;        
        }
    }

function investLP(uint256 amount) public   {
        require(amount >= 1, "NotEnoughInput");
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        TPAddr.transferFrom(msg.sender, address(this), amount);
        settlementLP(id,amount);
    }

function settlementLP(uint256 id,uint256 Amount) internal {
        uint256 LPamount = _playerMap[id].LP_Amount;
        if(LPamount > 0){
            _playerMap[id].LP_Amount = _playerMap[id].LP_Amount.add(Amount);
        }else{
            _playerMap[id].LP_Amount = Amount;
        }
        if(_playerMap[id].endTime != 0){
            uint256 endTime =block.timestamp.add(four_Month);
            _playerMap[id].endTime = endTime;
         } 
    }
}