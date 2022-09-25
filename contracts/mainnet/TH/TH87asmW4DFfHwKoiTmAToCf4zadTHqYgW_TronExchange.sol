//SourceUnit: TronExchange.sol




/**
 
  ████████╗██████╗░░█████╗░███╗░░██╗  ███████╗██╗░░██╗░█████╗░██╗░░██╗░█████╗░███╗░░██╗░██████╗░███████╗
  ╚══██╔══╝██╔══██╗██╔══██╗████╗░██║  ██╔════╝╚██╗██╔╝██╔══██╗██║░░██║██╔══██╗████╗░██║██╔════╝░██╔════╝
  ░░░██║░░░██████╔╝██║░░██║██╔██╗██║  █████╗░░░╚███╔╝░██║░░╚═╝███████║███████║██╔██╗██║██║░░██╗░█████╗░░
  ░░░██║░░░██╔══██╗██║░░██║██║╚████║  ██╔══╝░░░██╔██╗░██║░░██╗██╔══██║██╔══██║██║╚████║██║░░╚██╗██╔══╝░░
  ░░░██║░░░██║░░██║╚█████╔╝██║░╚███║  ███████╗██╔╝╚██╗╚█████╔╝██║░░██║██║░░██║██║░╚███║╚██████╔╝███████╗
  ░░░╚═╝░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝  ╚══════╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝╚═╝░░╚══╝░╚═════╝░╚══════╝



    * Contract Developed by Sunil Kumar (imdevsunil)
    
    * Contract Name: TRON EXCHANGE
    * ->> TRON EXCHANGE <--
    * Website: ://tronexchange.in

*/



pragma solidity >= 0.5.0;

contract TronExchange{
    event ActivateAccount(uint256 value, address indexed sender);
    event UpgradeAccount(uint256 value, address indexed sender);
    event Withdraw(uint256 value, address indexed sender);
    event MultiWithdraw(uint256 value, address indexed sender);
    using SafeMath for uint256;

    address public owner;

    constructor(address ownerAddress) public {
            owner = ownerAddress;
    }

    
    function activateAccount(address payable  _to, uint256 _value) public payable {
            require(_to != address(0), 'Invaild Receiver Wallet Address!');
            require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
            _to.transfer(_value);
            emit ActivateAccount(msg.value, msg.sender);
    }
    
    
    function upgradeAccount(address payable  _to, uint256 _value) public payable {
            require(_to != address(0), 'Invaild Receiver Wallet Address!');
            require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
            _to.transfer(_value);
            emit UpgradeAccount(msg.value, msg.sender);
    }
    
    function multiWithdraw(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
            for (i; i < _contributors.length; i++) {
                    require(total >= _balances[i]);
                    total = total.sub(_balances[i]);
                    _contributors[i].transfer(_balances[i]);
            }
        emit MultiWithdraw(msg.value, msg.sender);
    }

    function withdraw(address payable  _to, uint256 _value) public payable {
            require(_to != address(0), 'Invaild Receiver Wallet Address!');
            require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
            _to.transfer(_value);
            emit Withdraw(msg.value, msg.sender);
    }

    function adminWithdraw() public payable{
            require(msg.sender == owner, "onlyOwner");
            msg.sender.transfer(address(this).balance);
    }


}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
            if (a == 0) {
                    return 0;
            }
            uint256 c = a * b;
            assert(c / a == b);
            return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}