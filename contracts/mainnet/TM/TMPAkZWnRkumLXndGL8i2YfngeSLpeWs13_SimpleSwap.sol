//SourceUnit: SimpleSwap.sol

pragma solidity 0.6.12;

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

contract Ownable {
    address private _owner;

    constructor() internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract SimpleSwap is Ownable {

    IERC20 public c_old_lgt;
    IERC20 public c_new_lgt;

    constructor(IERC20 c_old, IERC20 c_new) public {
        c_old_lgt = c_old;
        c_new_lgt = c_new;
    }

    function swap(uint256 amount) external {
        c_old_lgt.transferFrom(msg.sender, address(c_old_lgt), amount);
        c_new_lgt.transfer(msg.sender, amount);
    }

    function getBack(IERC20 c, uint256 amount) external onlyOwner {
        c.transfer(msg.sender, amount);
    }
}