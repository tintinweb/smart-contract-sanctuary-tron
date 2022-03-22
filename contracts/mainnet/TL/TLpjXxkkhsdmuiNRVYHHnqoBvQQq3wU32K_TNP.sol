//SourceUnit: tnp.sol

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
}

contract TNP is EIP20Interface,Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    address[] whiteAddress;
    
    address burnAddress = 0x0000000000000000000000000000000000000000;
    address public address1 = address(0);
    address public address2 = address(0);
    address public address3 = address(0);
    address public address4 = address(0);
    
    uint256 public fee1 = 0;
    uint256 public fee2 = 0;
    uint256 public fee3 = 0;
    uint256 public fee4 = 0;
    uint256 public feeBurn = 0;
    uint256 public totalFee = 0;
    
    address private pairAddress = address(0);
    uint256 public stopBurn = 0;
    uint256 public burnTotal = 0;
    bool public burnSwitch = true;

    string public name ;
    uint8 public decimals;
    string public symbol;

    constructor() public {
        decimals = 6;
        totalSupply = 4_800_000e6;
        balances[msg.sender] = totalSupply;
        whiteAddress.push(msg.sender);
        name = 'Trading Network Protocol';
        symbol = 'TNP';
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
         _transfer(msg.sender, _to, _value);
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
        bool stopFlag = true;
        if(pairAddress == _from || pairAddress == _to){
            stopFlag = false;
        }
        for(uint i = 0; i < whiteAddress.length; i++) {
            if(_from == whiteAddress[i] || _to == whiteAddress[i]){
                stopFlag = true;
                break;
            }
        }
        if(burnTotal >= stopBurn){
            stopFlag = true;
        }
        if(burnSwitch == false){
            stopFlag = true;
        }
        if(_to == address(0)){
            stopFlag = true;
        }
        if(totalFee == 0){
            stopFlag = true;
        }
        if(stopFlag){
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            if(_to == address(0)){
                totalSupply = totalSupply.sub(_value);
            }
            emit Transfer(_from, _to, _value);
        }else{
            //deduction fee
            uint256 _fee = _value.mul(totalFee).div(1000);
            uint256 _toValue = _value.sub(_fee);
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_toValue);
            emit Transfer(_from, _to, _toValue);
            //fee1
            if(fee1 > 0 && address1 != address(0)){
                uint256 tmpFee1 = _fee.mul(fee1).div(totalFee);
                balances[address1] = balances[address1].add(tmpFee1);
                emit Transfer(_from, address1, tmpFee1);
            }
            if(fee2 > 0 && address2 != address(0)){
                uint256 tmpFee2 = _fee.mul(fee2).div(totalFee);
                balances[address2] = balances[address2].add(tmpFee2);
                emit Transfer(_from, address2, tmpFee2);
            }
            if(fee3 > 0 && address3 != address(0)){
                uint256 tmpFee3 = _fee.mul(fee3).div(totalFee);
                balances[address3] = balances[address3].add(tmpFee3);
                emit Transfer(_from, address3, tmpFee3);
            }
            if(fee4 > 0 && address4 != address(0)){
                uint256 tmpFee4 = _fee.mul(fee4).div(totalFee);
                balances[address4] = balances[address4].add(tmpFee4);
                emit Transfer(_from, address4, tmpFee4);
            }
            if(feeBurn > 0){
                uint256 tmpFeeBurn = _fee.mul(feeBurn).div(totalFee);
                burnTotal = burnTotal.add(tmpFeeBurn);
                if(burnTotal > stopBurn){
                    uint256 diff = burnTotal.sub(stopBurn);
                    tmpFeeBurn = tmpFeeBurn.sub(diff);
                    burnTotal = stopBurn;
                    burnSwitch = false;
                }
                balances[burnAddress] = balances[burnAddress].add(tmpFeeBurn);
                totalSupply = totalSupply.sub(tmpFeeBurn);
                emit Transfer(_from, burnAddress, tmpFeeBurn);
            }
        }
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
    function setBurnSwitch(bool _switch) public onlyOwner returns (bool success) {
        burnSwitch = _switch;
        return true;
    }
    
    function setStopBurn(uint256 number) public onlyOwner {
        stopBurn = number;
    }
    function setAddress(address _addr1,address _addr2,address _addr3,address _addr4) public onlyOwner {
        address1 = _addr1;
        address2 = _addr2;
        address3 = _addr3;
        address4 = _addr4;
    }
    function setFee(uint256 _fee1,uint256 _fee2,uint256 _fee3,uint256 _fee4,uint256 _feeBurn) public onlyOwner {
        fee1 = _fee1;
        fee2 = _fee2;
        fee3 = _fee3;
        fee4 = _fee4;
        feeBurn = _feeBurn;
        totalFee = fee1.add(fee2).add(fee3).add(fee4).add(feeBurn);
    }
    function setPairAddress(address _address) public onlyOwner returns (bool success) {
        pairAddress = _address;
        return true;
    }
    function setWhiteAddress(address[] memory _addressList) public onlyOwner returns (bool success) {
        for(uint i = 0; i < _addressList.length; i++) {
            whiteAddress.push(_addressList[i]);
        }
        return true;
    }
    function removeWhiteAddress(address _address) public onlyOwner returns (bool success) {
        for(uint i = 0; i < whiteAddress.length; i++) {
            if(_address == whiteAddress[i]){
                delete whiteAddress[i];
                break;
            }
        }
        return true;
    }
    function getWhiteAddress() public onlyOwner view returns (address[] memory) {
        address[] memory list = new address[](whiteAddress.length);
        for(uint i = 0; i < whiteAddress.length; i++) {
            list[i] = whiteAddress[i];
        }
        return list;
    }
    
}