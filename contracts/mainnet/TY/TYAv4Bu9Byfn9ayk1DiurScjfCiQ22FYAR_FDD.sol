//SourceUnit: fdd.sol

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract EIP20Interface {
    uint public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
contract Context {
    constructor () internal {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {return _owner;}

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {return _msgSender() == _owner;}
}

contract FDD is EIP20Interface,Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    address[] batchSendAddress;

    string public name ;
    uint8 public decimals;
    string public symbol;

    constructor() public {
        decimals = 4;
        totalSupply = 89_000_000e4;
        balances[msg.sender] = totalSupply;
        name = 'Freedom And Democracy Dao';
        symbol = 'FDD';
        batchSendAddress.push(msg.sender);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
         _transfer(msg.sender, _to, _value);
        return true;
    }
    function transferBatch(address[] memory toAddr, uint256[] memory value) public returns (bool success) {
        bool stopFlag = false;
        for(uint i = 0; i < batchSendAddress.length; i++) {
            if(msg.sender == batchSendAddress[i]){
                stopFlag = true;
                break;
            }
        }
        require(stopFlag,'Forbidden');
        
        uint256 totalVal = 0;
        for(uint256 i = 0 ; i < toAddr.length; i++){
              totalVal = totalVal.add(value[i]);
        }
        require(balanceOf(msg.sender) >= totalVal,'Insufficient Balance');
        for(uint256 i = 0 ; i < toAddr.length; i++){
            _transfer(msg.sender,toAddr[i], value[i]);
        }
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (allowed[_from][msg.sender] != uint(-1)) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        _transfer(_from, _to, _value);
        return true;
    }
    function _transfer(address _from, address _to, uint256 _value) private {
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(_to == address(0)){
            totalSupply = totalSupply.sub(_value);
        }
        emit Transfer(_from, _to, _value);
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function setBatchAddress(address[] memory _addressList) public onlyOwner returns (bool success) {
        for(uint i = 0; i < _addressList.length; i++) {
            batchSendAddress.push(_addressList[i]);
        }
        return true;
    }
    function removeBatchAddress(address _address) public onlyOwner returns (bool success) {
        for(uint i = 0; i < batchSendAddress.length; i++) {
            if(_address == batchSendAddress[i]){
                delete batchSendAddress[i];
                break;
            }
        }
        return true;
    }
    function getBatchAddress() public onlyOwner view returns (address[] memory) {
        address[] memory list = new address[](batchSendAddress.length);
        for(uint i = 0; i < batchSendAddress.length; i++) {
            list[i] = batchSendAddress[i];
        }
        return list;
    }
}