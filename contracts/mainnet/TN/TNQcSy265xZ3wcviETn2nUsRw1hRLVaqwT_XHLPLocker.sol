//SourceUnit: XH_LPLocker.sol

pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

contract XHLPLocker {
    IERC20 public _xhLp;
    uint256 public _endtime;
    address public _gov;

    constructor(
        address _lpAddr
    ) public {
        _gov = msg.sender;
        _xhLp = IERC20(_lpAddr);
    }

    function withdraw() public {
        require(msg.sender == _gov, "permission denied");
        require(_endtime > 0, "endtime no set");
        require(block.timestamp >= _endtime, "no end");

        _xhLp.transfer(msg.sender, _xhLp.balanceOf(address(this)));
    }

    function updateEndTime(uint256 _time) public {
        require(msg.sender == _gov, "permission denied");
        require(_endtime <= 0, "endtime is set");
        _endtime = _time;
    }
}