//SourceUnit: AceIEO.sol

pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        _assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        _assert(b > 0);
        uint256 c = a / b;
        _assert(a == b * c + a % b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        _assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        _assert(c >= a && c >= b);
        return c;
    }

    function _assert(bool assertion) internal pure {
        if (!assertion) {
            revert();
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Token {
    function decimals() view public returns (uint256 _decimals);

    function totalSupply() view public returns (uint256 supply);

    function balanceOf(address _owner) view public returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) view public returns (uint256 remaining);

    event  Transfer(address  indexed _from, address  indexed _to, uint256 _value);
    event  Approval(address  indexed _owner, address  indexed _spender, uint256 _value);
}

contract Ownable  {
    address  public  _owner;
    address  public  _coo;
    address  public  _cfo;
    bool  public  paused  =  false;
    event  OwnershipTransferred(address  indexed  previousOwner,  address  indexed  newOwner);

    constructor  ()  internal  {
        _owner  =  msg.sender;
    }

    function  owner()  public  view  returns  (address)  {
        return  _owner;
    }

    modifier  onlyOwner()  {
        require(msg.sender  ==  _owner);
        _;
    }

    modifier  onlyCOO()  {
        require(msg.sender  ==  _coo);
        _;
    }

    modifier  onlyCFO(){
        require(msg.sender  ==  _cfo);
        _;
    }

    function  setCoo(address  cooAddress)  public  onlyOwner  {
        _coo  =  cooAddress;
    }

    function  setCfo(address  cfoAddress)  public  onlyOwner{
        _cfo  =  cfoAddress;
    }

    function  transferOwnership(address  newOwner)  public  onlyOwner  {
        require(newOwner  !=  address(0));
        emit  OwnershipTransferred(_owner,  newOwner);
        _owner  =  newOwner;
    }

    modifier  whenNotPaused()  {
        require(!paused);
        _;
    }

    modifier  whenPaused  {
        require(paused);
        _;
    }

    function  pause()  external  onlyCOO  whenNotPaused  {
        paused  =  true;
    }

    function  unPause()  public  onlyCOO  whenPaused  {
        paused  =  false;
    }


}

contract AceIEO is Ownable{
   using SafeMath for uint256;
   
   Token public aceToken;
   mapping (address => info) public order;
   struct info{
       uint8 status;
       uint256 balance;
       uint256 ACEAmount;
       uint256 TRXAmount;
       
   }
   
    mapping(uint256 => address) public IDAddress;
   
    uint256 public joinNumber = 0;
    uint256 constant public precision = 1000000;
   
    uint256 public maxLimit = 30000 * precision;
    uint256 public minLimit = 5000 * precision;
   
    event Deposit(address user, uint256 amount, uint256 balance);
    event Withdraw(address user, uint256 amount);
   
    constructor(address _aceToken) public payable {
        aceToken = Token(_aceToken);
    }
   
    function deposit() public whenNotPaused payable returns(bool){
        require( msg.value <= maxLimit);
        require(order[msg.sender].status != 2);
        
        uint256 balance_temp = order[msg.sender].balance;
        uint256 sum = balance_temp.add(msg.value);
        
        require(sum <= maxLimit && sum >= minLimit);
       
        if(order[msg.sender].status == 0){
            joinNumber += 1;
            IDAddress[joinNumber] = msg.sender;
        }

        order[msg.sender].status = 1;
        order[msg.sender].balance = sum;
        emit Deposit( msg.sender, msg.value, order[msg.sender].balance);
        return true;
   }
   
    function withdraw() public whenNotPaused returns (bool success) {
        require(order[msg.sender].balance > 0);
        require(order[msg.sender].status != 2);
        
        order[msg.sender].status = 3;
        msg.sender.transfer(order[msg.sender].balance);
        order[msg.sender].balance = 0;
      return true;
   }
   
    function setIEOLimit(uint256 _minLimit, uint256 _maxLimit) public onlyCOO returns(bool){
        require(_minLimit > 0 && _maxLimit >0);
        require(_maxLimit > _minLimit);
        minLimit = _minLimit * precision;
        maxLimit = _maxLimit * precision;
        return true;
    }
   
    function getOrderInfo(uint256 _id) public view returns(uint256,address,uint256,uint256,uint256,uint256){
       address _addr = IDAddress[_id];
       return(_id,_addr,order[_addr].status,order[_addr].balance,order[_addr].ACEAmount,order[_addr].TRXAmount);
   }
   
    function transferAce(address _addr, uint256 _amountACE, uint256 _amountTRX) public onlyCOO{
        require(order[_addr].status == 1);
        require(order[_addr].TRXAmount == 0 && order[_addr].ACEAmount == 0);
        require(_amountACE > 0 || _amountTRX > 0);
        require(_amountTRX <= order[_addr].balance);
        
        if(_amountACE > 0){
            aceToken.transfer(_addr , _amountACE);
            order[_addr].ACEAmount = _amountACE;
        }
        if(_amountTRX > 0){
             _addr.transfer(_amountTRX);
             order[_addr].TRXAmount = _amountTRX;
        }
        order[_addr].status = 2;
        
   }
   
    function withdrawAdmin(uint256 _amount) public onlyOwner returns(bool success){
        _cfo.transfer(_amount);
        return true;
    }

    function withDrawToken(address token , address addr, uint256 amount) public onlyOwner{
        require(Token(token).transfer(addr, amount));
    }
    
    function withDrawAce(uint256 amount) public onlyOwner{
        require(aceToken.transfer(_cfo, amount));
    }
    
}