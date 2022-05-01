//SourceUnit: USDD.sol

pragma solidity 0.5.8;

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

/**
 * @title TRC20 interface
 */
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

contract ITokenDeposit is ITRC20 {
    function deposit() public payable;
    function withdraw(uint256) public;
    event  Deposit(address indexed dst, uint256 sad);
    event  Withdrawal(address indexed src, uint256 sad);
}

contract USDD is ITokenDeposit {

    using SafeMath for uint256;
    string public name = "Decentralized USD";
    string public symbol = "USDD";
    uint8  public decimals = 18;
    trcToken  public usddTokenId = trcToken(1004776);
    uint256 public constant MUL = 1e12;

    uint256 private totalSupply_;
    mapping(address => uint256) private  balanceOf_;
    mapping(address => mapping(address => uint256)) private  allowance_;


    function() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.tokenid == usddTokenId, "deposit tokenId not USDD");
        require(msg.value == 0, "deposit TRX is not allowed");
        // tokenvalue is long value
        uint256 scaledAmount = msg.tokenvalue.mul(MUL);
        balanceOf_[msg.sender] += scaledAmount;
        totalSupply_ += scaledAmount;
        // TRC20 USDD mint
        emit Transfer(address(0x00), msg.sender, scaledAmount);
        // TRC10 USDD deposit
        emit Deposit(msg.sender, msg.tokenvalue);
    }

    function withdraw(uint256 underlyingAmount) public {
        uint256 scaledAmount = underlyingAmount.mul(MUL);
        require(balanceOf_[msg.sender] >= scaledAmount, "not enough USDD balance");
        require(totalSupply_ >= scaledAmount, "not enough USDD totalSupply");
        balanceOf_[msg.sender] -= scaledAmount;
        totalSupply_ -= scaledAmount;
        msg.sender.transferToken(underlyingAmount, usddTokenId);

        // TRC20 USDD burn
        emit Transfer(msg.sender, address(0x00), scaledAmount);
        // TRC10 USDD withdraw
        emit Withdrawal(msg.sender, underlyingAmount);
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

    function approve(address guy) public returns (bool) {
        return approve(guy, uint256(- 1));
    }

    function transfer(address dst, uint256 sad) public returns (bool) {
        return transferFrom(msg.sender, dst, sad);
    }

    function transferFrom(address src, address dst, uint256 sad)
    public returns (bool)
    {
        require(balanceOf_[src] >= sad, "src balance not enough");

        if (src != msg.sender && allowance_[src][msg.sender] != uint256(- 1)) {
            require(allowance_[src][msg.sender] >= sad, "src allowance is not enough");
            allowance_[src][msg.sender] -= sad;
        }
        balanceOf_[src] -= sad;
        balanceOf_[dst] += sad;

        emit Transfer(src, dst, sad);
        return true;
    }
}