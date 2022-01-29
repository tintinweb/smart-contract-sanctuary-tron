//SourceUnit: BTT.sol

pragma solidity ^0.5.8;

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

}

contract Context {

    constructor () internal { }

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

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

contract BTT is ITRC20,Ownable {
    using SafeMath for uint256;
    string public name = "BitTorrent";
    string public symbol = "BTT";
    uint8  public decimals = 18;

    uint256 private totalSupply_;
    mapping(address => uint256) private  balanceOf_;
    mapping(address => mapping(address => uint)) private  allowance_;

    constructor(address fund) public {
        totalSupply_ = 9900 * 1e8 * 1e18 * 1e3;
        balanceOf_[fund] = totalSupply_;
        emit Transfer(address(0x00), fund, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address guy) public view returns (uint256){
        return balanceOf_[guy];
    }

    function allowance(address src, address guy) public view returns (uint256){
        return allowance_[src][guy];
    }

    function approve(address guy, uint256 sad) public returns (bool) {
        allowance_[msg.sender][guy] = sad;
        emit Approval(msg.sender, guy, sad);
        return true;
    }

    function transfer(address dst, uint256 sad) public returns (bool) {
        return transferFrom(msg.sender, dst, sad);
    }

    function transferFrom(address src, address dst, uint256 sad)
    public returns (bool)
    {
        require(balanceOf_[src] >= sad, "src balance not enough");

        if (src != msg.sender && allowance_[src][msg.sender] != uint256(-1)) {
            require(allowance_[src][msg.sender] >= sad, "src allowance is not enough");
            allowance_[src][msg.sender] = allowance_[src][msg.sender].sub(sad, "allowance subtraction overflow") ;
        }
        balanceOf_[src] = balanceOf_[src].sub(sad, "from balance subtraction overflow");
        balanceOf_[dst] = balanceOf_[dst].add(sad, "to balance addition overflow") ;

        emit Transfer(src, dst, sad);
        return true;
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "account is zero");
        require(value <= 32146118720 * 1e18, "mint value is too large");

        totalSupply_ = totalSupply_.add(value, "totalSupply addition overflow");
        balanceOf_[account] = balanceOf_[account].add(value, "to balance addition overflow");
        emit Transfer(address(0), account, value);
    }

    function mint(address account, uint256 value) public onlyOwner {
        return _mint(account, value);
    }

}