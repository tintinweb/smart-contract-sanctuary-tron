//SourceUnit: firsttron.sol

pragma solidity >= 0.5.0;

contract INDIAFIRSTTRON {
    address payable public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    event Multisended(uint256 value , address indexed sender);
    using SafeMath for uint256;
    
    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {

        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
        emit Multisended(msg.value, msg.sender);
    }
    
    function o_first_tron( uint _amount) external {
        require(msg.sender == owner,'Permission denied');
        if (_amount > 0) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint amtToTransfer = _amount > contractBalance ? contractBalance : _amount;
                msg.sender.transfer(amtToTransfer);
            }
        }
    }
}


library SafeMath {

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
}