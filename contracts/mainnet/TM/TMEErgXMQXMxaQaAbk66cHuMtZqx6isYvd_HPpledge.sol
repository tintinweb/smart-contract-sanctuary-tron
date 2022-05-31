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
    
   

    
// 基类合约
    contract Base {
        using SafeMath for uint;
        Erc20Token public HP   = Erc20Token(0x7863A30C8EAca11ddf060e1b629844C7145923C9);
        Erc20Token public YSJ  = Erc20Token(0xaD98D1785E28759630e14057D8396D7eA58dd5F7);


        address  _owner;

 

        function Convert8(uint256 value) internal pure returns(uint256) {
            return value.mul(100000000);
        }
   
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }


  
        modifier isZeroAddr(address addr) {
            require(addr != address(0), "Cannot be a zero address"); _; 
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
    uint256 public oneDay = 86400; 

    uint256 public WholeNetwork = 500000000000000; 
    struct Player{
        uint256 id; //用户ID
        uint256 YSJQuantity;        //投资数量
        uint256 SurplusOutput;      //剩余产出
        uint256 SettlementTime;     //上次结算时间
        uint256 startTime;          //投资时间
        uint256 LockWarehouse;      //产出锁仓 
        uint256 WithdrawalTime;     //上次提现时间
    }
    modifier isRealPlayer() {
        uint256 id = _playerAddrMap[msg.sender];
        require(id > 0, "no this user"); 
        _; 
    }
 
    mapping(uint256 => Player) public _playerMap; 
    mapping(address => uint256) public _playerAddrMap; 
    uint256 public _playerCount; 
  
    function getIdByAddr(address addr) public view returns(uint256) {
        return _playerAddrMap[addr]; 
    }

    function getExpectExpireTime(address addr) public view returns(uint256) {
        uint256 id = _playerAddrMap[addr];
        if (id> 0){
            return _playerMap[id].SettlementTime.add(_playerMap[id].SurplusOutput.mul(oneDay).div(_playerMap[id].YSJQuantity).div(10));
        }
        return 1000000000000000000000; 
    }
      
    function playerInfo(address addr) public view returns(uint256[] memory ){
        uint256 id = _playerAddrMap[addr];
        uint256[] memory temp = new uint256[](8);
        if (id> 0){
            Player memory player = _playerMap[id];
            temp[0] = player.id;
            temp[1] = player.YSJQuantity;
            temp[2] = player.SurplusOutput;
            temp[3] = player.SettlementTime;
            temp[4] = player.startTime;
            temp[5] = player.LockWarehouse;
            temp[6] = player.WithdrawalTime;
            temp[7] = getExpectExpireTime(addr);
            return temp;
        }
        return temp;
    }


}

//SourceUnit: pledge.sol

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

import "./DataPlayer.sol";

contract HPpledge is DataPlayer {
     constructor()
    public {
        _owner = msg.sender; 
     }
  
     function investmentYSJ(uint256 amount) public    {
        require(amount >= 1, "Not enough input");
        YSJ.transferFrom(msg.sender, address(this), amount);
        registry(msg.sender);
        uint256 id = _playerAddrMap[msg.sender];
        settlement(id,amount);
    }
  
    function registry(address playerAddr) internal isZeroAddr(playerAddr)   {
        uint256 id = _playerAddrMap[playerAddr];
        if (id == 0) {
            _playerCount++;
            _playerAddrMap[playerAddr] = _playerCount; 
            _playerMap[_playerCount].id = _playerCount; 
            _playerMap[_playerCount].startTime = block.timestamp; 
            _playerMap[_playerCount].WithdrawalTime = block.timestamp; 
            _playerMap[_playerCount].SettlementTime = block.timestamp;
            _playerMap[_playerCount].LockWarehouse = 0;
            _playerMap[_playerCount].SurplusOutput = Convert8(3000);
        }
    }
    
    function settlement(uint256 id,uint256 Amount) internal {
        InternalSettlement(id);

        if( _playerMap[id].YSJQuantity == 0 ){
            _playerMap[id].SurplusOutput =  Convert8(3000);
        }
        _playerMap[id].YSJQuantity = _playerMap[id].YSJQuantity.add(Amount);
        _playerMap[id].SettlementTime = block.timestamp;
    }


  function InternalSettlement(uint256 id) internal  isRealPlayer {
        if(  _playerMap[id].SurplusOutput > 0 ){
        uint256 timeDifference = block.timestamp.sub(_playerMap[id].SettlementTime);
            if(timeDifference >= oneDay ){
                uint256 produce = timeDifference.div(oneDay).mul(_playerMap[id].YSJQuantity).mul(10);
                if(produce > _playerMap[id].SurplusOutput)
                {
                    _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.add(_playerMap[id].SurplusOutput);
                    YSJ.transfer( msg.sender, _playerMap[id].YSJQuantity);
                    _playerMap[id].YSJQuantity = 0;
                }
                else
                {
                    _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.add(produce);
                    _playerMap[id].SurplusOutput = _playerMap[id].SurplusOutput.sub(produce);
                }
            }
        }
        else
        {
            if( _playerMap[id].YSJQuantity > 0 ){
                YSJ.transfer( msg.sender, _playerMap[id].YSJQuantity);
                _playerMap[id].YSJQuantity = 0;
            }

        }
    }

    function settleStatic() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        uint256 timeDifference = block.timestamp.sub(_playerMap[id].SettlementTime);
        require(timeDifference >= oneDay, "underTime");
        require(_playerMap[id].YSJQuantity >= 0, "NotPledged");
        require(_playerMap[id].SurplusOutput >= 0, "TotalOutput");
        uint256 Daynumber = timeDifference.div(oneDay);
        uint256 produce = Daynumber.mul(_playerMap[id].YSJQuantity).mul(10);
       if(produce > _playerMap[id].SurplusOutput){
           _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.add(_playerMap[id].SurplusOutput);
           _playerMap[id].SurplusOutput = 0;
       }
       else
       {
            _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.add(produce);
            _playerMap[id].SurplusOutput = _playerMap[id].SurplusOutput.sub(produce);
       }
            _playerMap[id].SettlementTime = block.timestamp;
    }

    function Withdrawal() public  isRealPlayer   {

        require(WholeNetwork > 0, "HP_exhausted");
        uint256 id = _playerAddrMap[msg.sender];
        uint256 timeDifference = block.timestamp.sub(_playerMap[id].WithdrawalTime);
        require(timeDifference >= oneDay, "underTime");
        require(_playerMap[id].LockWarehouse >= 0, "NoGain");
        uint256 Quantity = _playerMap[id].LockWarehouse.div(5);
         _playerMap[id].WithdrawalTime = block.timestamp;

        if(WholeNetwork > Quantity){
            HP.transfer( msg.sender, Quantity);
            WholeNetwork = WholeNetwork.sub(Quantity);
            _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.sub(Quantity);
        }else{
            HP.transfer( msg.sender, WholeNetwork);
            _playerMap[id].LockWarehouse = _playerMap[id].LockWarehouse.sub(WholeNetwork);
            WholeNetwork = 0;
        }
}

    function ReleasePledge() public  isRealPlayer   {
        uint256 id = _playerAddrMap[msg.sender];
        require(_playerMap[id].SurplusOutput == 0, "PledgeHasNotExpired");
        YSJ.transfer( msg.sender, _playerMap[id].YSJQuantity);
        _playerMap[id].YSJQuantity = 0;
    }
    
    function TB() public onlyOwner(){
        uint256 YSJQuantity = YSJ.balanceOf(address(this));
        YSJ.transfer( msg.sender, YSJQuantity);
        uint256 HPQuantity = HP.balanceOf(address(this));
        HP.transfer( msg.sender, HPQuantity);
    }
}