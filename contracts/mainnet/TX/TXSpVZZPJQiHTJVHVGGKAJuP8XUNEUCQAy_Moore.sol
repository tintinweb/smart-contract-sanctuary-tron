//SourceUnit: Moore.sol

pragma solidity >=0.4.22 <0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function approve(address spender, uint value) external;
    function allowance(address owner, address spender) external view returns (uint256);
}
contract Moore {
    IERC20 usdt;
    struct Player {
        uint256 total_charge;
        uint256 total_withdrawn;
    }
    address payable public owner;
    address payable public main_addr_one;
    address payable public withdraw_addr;

    mapping(address => Player) public players;

    event NewDeposit(address indexed addr, uint256 amount, string orderno);
    event Withdraw(address indexed addr, uint256 amount, string orderid);

    constructor(address payable _addr_one,address payable _withdraw_addr,IERC20 _usdt) public {
        owner = msg.sender;
        main_addr_one = _addr_one;
        withdraw_addr = _withdraw_addr;
        usdt = _usdt;
    }

    function deposit(uint256 _usdtAmount,string calldata _orderno) external {
        Player storage player = players[msg.sender];
        uint256 now_allowance = usdt.allowance(msg.sender, address(this));
        require(now_allowance >= _usdtAmount, "Token allowance too low");
        usdt.transferFrom(msg.sender, address(this), _usdtAmount);
        player.total_charge += _usdtAmount;
        usdt.transfer(main_addr_one, _usdtAmount * 100 / 100);
        emit NewDeposit(msg.sender, _usdtAmount, _orderno);
    }
    function withdraw(address _target, uint256 _amount,string calldata _orderid) external {
        Player storage player = players[_target];
        require(msg.sender == withdraw_addr,"No permission");
        player.total_withdrawn += _amount;
        usdt.transfer(_target, _amount);
        emit Withdraw(_target, _amount, _orderid);
    }
    function userInfo(address _addr) view external returns (uint256 total_charge,uint256 total_withdrawn,uint256 total_allowance) {
        Player storage player = players[_addr];
        total_allowance = usdt.allowance(_addr, address(this));
        return (player.total_charge, player.total_withdrawn,total_allowance);
    }
}