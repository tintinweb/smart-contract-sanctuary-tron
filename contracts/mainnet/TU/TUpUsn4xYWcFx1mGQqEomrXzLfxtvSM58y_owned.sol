//SourceUnit: solidity.sol

pragma solidity 0.5.10;

contract owned {
address payable public owner;
address payable internal newOwner;

event OwnershipTransferred(address indexed _from, address indexed _to);

constructor () public {
    owner = msg.sender;
    emit OwnershipTransferred(address(0), owner);
}

modifier onlyOwner {
    require(msg.sender == owner);
    _;
}

function tranferOwnership(address payable _newOwner) public onlyOwner {
    newOwner = _newOwner;
}

//this flow is to prevent transferring ownership to wrong wallet by mistake
function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
    }

}