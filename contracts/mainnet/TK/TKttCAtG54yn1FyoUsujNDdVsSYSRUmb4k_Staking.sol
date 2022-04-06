//SourceUnit: Staking.sol

pragma solidity 0.6.12;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Staking {

    struct Staking {
        address token;
        address user;
        uint amount;
        uint day;
        bool isUn;
        uint stime;
    }
    uint256 private constant DS = 86400;

    Staking[] private _stakings;

    mapping(uint => uint) private _indexMap;

    mapping(uint => bool) private _isStaking;

    function staking(uint id, address token, uint amount, uint day) public
    {
        require(!_existId(id), "Id is exist");
        require(amount > 0, "Amount should be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        _indexMap[id] = _stakings.length;
        _isStaking[id] = true;
        _stakings.push(Staking({
        token : token,
        user : msg.sender,
        amount : amount,
        day : day,
        isUn : false,
        stime : block.timestamp
        }));
    }

    function unStaking(uint id) public
    {
        require(_existId(id), "staking not found");
        uint index = _indexMap[id];
        Staking storage staking = _stakings[index];
        require(msg.sender == staking.user, "not owner");
        require(!staking.isUn, "is unstaking");
        uint etime = staking.stime + (staking.day * DS);
        require(block.timestamp >= etime, "staking time check fail");
        staking.isUn = true;
        IERC20(staking.token).transfer(staking.user, staking.amount);
    }

    function _existId(uint id) private view returns (bool)
    {
        return _isStaking[id] || id == 0;
    }

    function getStaking(uint id) public view returns (address, address, uint, uint, uint, bool){
        if (_existId(id)) {
            uint index = _indexMap[id];
            Staking memory staking = _stakings[index];
            return (staking.token, staking.user, staking.day, staking.amount, staking.stime, staking.isUn);
        }
        return (address(0), address(0), 0, 0, 0, false);
    }
}