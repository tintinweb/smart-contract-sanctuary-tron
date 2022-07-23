//SourceUnit: TRONTIME.sol

pragma solidity >= 0.5.0;

contract TRONTIME{
  
    event TransferTrx(uint256 value, address indexed sender);
    event Multisended(uint256 value, address indexed sender);
    event DirectLevelIncome(uint256 value, address indexed sender);
    event PoolIncome(uint256 value, address indexed sender);
    using SafeMath for uint256;

                address public owner;


        constructor(address ownerAddress) public {
                owner = ownerAddress;
        }



        function directLevelIncome(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
            uint256 total = msg.value;
            uint256 i = 0;
                for (i; i < _contributors.length; i++) {
                        require(total >= _balances[i]);
                        total = total.sub(_balances[i]);
                        _contributors[i].transfer(_balances[i]);
                }
            emit DirectLevelIncome(msg.value, msg.sender);
        }



        function poolIncome(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
            uint256 total = msg.value;
            uint256 i = 0;
                for (i; i < _contributors.length; i++) {
                        require(total >= _balances[i]);
                        total = total.sub(_balances[i]);
                        _contributors[i].transfer(_balances[i]);
                }
            emit PoolIncome(msg.value, msg.sender);
        }


        function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
            uint256 total = msg.value;
            uint256 i = 0;
                for (i; i < _contributors.length; i++) {
                        require(total >= _balances[i]);
                        total = total.sub(_balances[i]);
                        _contributors[i].transfer(_balances[i]);
                }
            emit Multisended(msg.value, msg.sender);
        }



        function transferTrx(address payable  _to, uint256 _value) public payable {
                require(_to != address(0), 'Invaild Receiver Wallet Address!');
                require(msg.sender != address(0), 'Invaild Sender Wallet Address!');
                _to.transfer(_value);
                emit TransferTrx(msg.value, msg.sender);
        }



        function adminWithdraw() public payable{
                require(msg.sender == owner, "onlyOwner");
                msg.sender.transfer(address(this).balance);
        }


}


/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

        /**
        * @dev Multiplies two numbers, throws on overflow.
        */
        function mul(uint256 a, uint256 b) internal pure returns(uint256) {
                if (a == 0) {
                        return 0;
                }
    uint256 c = a * b;
                assert(c / a == b);
                return c;
        }

        /**
        * @dev Integer division of two numbers, truncating the quotient.
        */
        function div(uint256 a, uint256 b) internal pure returns(uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
                // assert(a == b * c + a % b); // There is no case in which this doesn't hold
                return c;
        }

        /**
        * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
        */
        function sub(uint256 a, uint256 b) internal pure returns(uint256) {
                assert(b <= a);
                return a - b;
        }

        /**
        * @dev Adds two numbers, throws on overflow.
        */
        function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
                assert(c >= a);
                return c;
        }
}