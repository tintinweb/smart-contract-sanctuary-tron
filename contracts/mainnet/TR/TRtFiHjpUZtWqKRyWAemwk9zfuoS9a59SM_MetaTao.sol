//SourceUnit: MetaTao.sol

pragma solidity ^0.5.8;

contract Context {
    constructor () internal {}

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


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract MetaTao is Ownable{
    
    // 用户
    struct User {
        uint256 id; // 用户ID
        address referrer; // 推荐人地址
        uint256 partnersCount; // 直推总人数
        uint256 tPrice; // 投入金额  
        uint256 tReward; // 投资收益
        uint256 recReward; // 直推收益  
        uint256 dirReward; // 间推收益
    }

    
    uint256 public rec = 2;                    //直推比例
    uint256 public dir = 1;                    //间推比例

     mapping(uint256 => address) public idToAddress; // 所有ID数据：ID——>地址

    uint256 public lastUserId = 2; // 最新的ID，目前为2
    

    mapping(address => User) public users; // 所有用户数据：地址——>用户数据
    
    mapping(uint256 => uint256) public levelPrice; // 投资价格

    address private founder; // 合约拥有者地址

    address public usdtToken;
    address public bdtToken;
    

    uint256 public total;                    //总投资
    uint256 public fate = 310559;                    //价格
    uint256 public lastFate = 0;    

    uint256 public fateX = 10000;                  
    
    // 构造函数：合约刚开始部署到以太坊上需要首先输入的内容——>传入创始人地址，之后无法修改
    // 创始人就是合约拥有者，这里为了方便大家观看，以下我就说创始人
    constructor(address foun,address usdt,address bdt) public {

        founder=foun;
        usdtToken=usdt;
        bdtToken=bdt;
       
        levelPrice[1] = 100000000;
        levelPrice[2] = 300000000;
        levelPrice[3] = 500000000;
       

        // 把创始人定义为ID为1的用户
        User memory user = User({
            id: 1, // ID为1
            referrer: address(0), // 推荐人为空
            partnersCount: 0, // 团队成员目前为0
            tPrice: 0,
            tReward: 0,
            recReward: 0,
            dirReward: 0
            });

        // 把创始人记到用户总册里
        users[founder] = user;

        // 把创始人记到ID总册里
        idToAddress[1] = founder;

    }

     modifier changeFate() {
        if (total/(100*1e18) > lastFate){
            uint256 _n = total/(100*1e18)-lastFate;
                for (uint256 i = 1; i <= _n; i++) {
                    fate = fate - (fate*fateX/1000000);
                }
            lastFate+=_n;
        }
        _;
    }
    
    // 新用户注册：新用户地址、推荐人地址
    function registration(address referrerAddress,uint256 val) external changeFate {
        bool flag = false;
        for (uint8 i = 1; i <= 3; i++) {
            if (levelPrice[i] == val){
                flag = true;
                break;
            }
        }
        IERC20 USDT = IERC20(usdtToken);
        require(flag, "price error");
        require(USDT.transferFrom(msg.sender,address(this),val), "invalid price");
        // 注册用户必须为新用户，如果是老用户，出错
        //require(!isUserExists(msg.sender), "user exists");
        // 推荐人必须是老用户，如果不是老用户，出错
        require(referrerAddress != msg.sender, "referrer error");

        // 创建新用户对象
        User memory user = User({
            id: lastUserId, // 新用户的ID为最新ID
            referrer: referrerAddress, // 推荐人地址为传入的推荐人地址
            partnersCount: 0, // 邀请人数
            tPrice: 0,
            tReward: 0,
            recReward: 0,
            dirReward: 0
            });

        users[msg.sender] = user; // 保存新用户数据：新用户地址——>新用户数据
        idToAddress[lastUserId] = msg.sender; // 新用户ID——>新用户地址

        // 再记录一次新用户的推荐人地址
        users[msg.sender].referrer = referrerAddress;

        lastUserId++;

        // 推荐人的团队人数+1
        users[referrerAddress].partnersCount++;
        users[msg.sender].tPrice+=val;

        uint256 tr = val * fate *1e6;
        users[msg.sender].tReward+=tr;

        total+=tr;

        IERC20 BDT = IERC20(bdtToken);
        
        uint256 bdtbalance = BDT.balanceOf(address(this));

        if (bdtbalance < tr) {
            return;
        }

        BDT.transfer(msg.sender, tr);

        
        uint256 usdtbalance = USDT.balanceOf(address(this));

        uint256 recr = val * rec / 1000;

        if (usdtbalance < recr) {
            return;
        }

        if (referrerAddress != address(0)){
            users[referrerAddress].recReward+=recr;
            USDT.transfer(referrerAddress, recr);
        }
       

        uint256 dirr = val * dir / 1000;

        if (users[referrerAddress].referrer != address(0)){
            users[users[referrerAddress].referrer].dirReward+=dirr;
            USDT.transfer(users[referrerAddress].referrer, dirr);
        }
        
    }
    
    function buyNext(uint256 val) external changeFate {
       // 调用者必须是激活用户
        //require(isUserExists(msg.sender), "user is not exists. Register first.");
        bool flag = false;
        for (uint8 i = 1; i <= 3; i++) {
            if (levelPrice[i] == val){
                flag = true;
                break;
            }
        }
        IERC20 USDT = IERC20(usdtToken);
        require(flag, "price error");
        require(USDT.transferFrom(msg.sender,address(this),val), "invalid price");

        uint256 tr = val * fate *1e6;
        users[msg.sender].tReward+=tr;

        total+=tr;

        IERC20 BDT = IERC20(bdtToken);
        
        uint256 bdtbalance = BDT.balanceOf(address(this));

        if (bdtbalance < tr) {
            return;
        }

        BDT.transfer(msg.sender, tr);

        uint256 usdtbalance = USDT.balanceOf(address(this));

        uint256 recr = val * rec / 1000;

        if (usdtbalance < recr) {
            return;
        }

        if (users[msg.sender].referrer != address(0)){
            users[users[msg.sender].referrer ].recReward+=recr;
            USDT.transfer(users[msg.sender].referrer , recr);
        }
       

        uint256 dirr = val * dir / 1000;

        if (users[users[msg.sender].referrer].referrer != address(0)){
            users[users[users[msg.sender].referrer].referrer].dirReward+=dirr;
            USDT.transfer(users[users[msg.sender].referrer].referrer, dirr);
        }
    }
    
    
    // 外用查询接口【查询用户是否注册】：输入用户地址；输出该用户是否存在
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    
    function isRef(address addr) public view returns(bool){
        if(users[addr].referrer == msg.sender){
            return true;
        }else{
            return false;
        }
    }

    function setRefFate(uint256 _rec,uint256 _dir) external onlyOwner {
        rec=_rec;
        dir=_dir;
    }

    function setFateX(uint256 _fateX) external onlyOwner {
        fateX=_fateX;
    }

    function setFate(uint256 _fate) external onlyOwner {
        fate=_fate;
    }
    
    function withdrawUsdt(uint256 amount) external onlyOwner {
        IERC20 USDT = IERC20(usdtToken);
        
        uint256 usdtbalance = USDT.balanceOf(address(this));
        require(usdtbalance >= amount, "Error Amount");
        
        USDT.transfer(msg.sender, amount);   //转帐
    }

    function withdrawBdt(uint256 amount) external onlyOwner {
        IERC20 BDT = IERC20(bdtToken);
        
        uint256 bdtbalance = BDT.balanceOf(address(this));
        require(bdtbalance >= amount, "Error Amount");
        
        BDT.transfer(msg.sender, amount);   //转帐
    }
    
}