//SourceUnit: nfa.sol

pragma solidity ^0.5.8;

library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        require(b > 0);
        uint c = a / b;
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a);
        return c;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint amount) internal {
        require(address(this).balance >= amount);

        (bool success, ) = recipient.call.value(amount)("");
        require(success);
    }
}

contract Ownable {
    using Address for address;
    address payable public Owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(Owner, _newOwner);
        Owner = _newOwner.toPayable();
    }
}

interface ITRC20 {
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // function mint(address owner, uint value) external returns(bool);
    // function burn(uint value) external returns(bool);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint amount, address token, bytes calldata extraData) external;
}

contract TRC20 is ITRC20, Ownable {
    using SafeMath for uint;
    using Address for address;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;

    uint internal _totalSupply;

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "insufficient allowance!");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function burn(uint amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    // approveAndCall
    function approveAndCall(address spender, uint amount, bytes memory extraData) public returns (bool) {
        require(approve(spender, amount));

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, amount, address(this), extraData);

        return true;
    }

    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0));
        require(recipient != address(0));
        require(_balances[sender] >= amount, "insufficient balance");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint amount) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0));
        require(_balances[account] >= amount, "insufficient balance");

        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0));
        require(spender != address(0));

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

contract TRC20Detailed is ITRC20 {
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeTRC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(ITRC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(ITRC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(ITRC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(ITRC20 token, address spender, uint value) internal {
        uint newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(ITRC20 token, address spender, uint value) internal {
        uint newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(ITRC20 token, bytes memory data) private {
        require(address(token).isContract());

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)));
        }
    }
}

interface IPlayerBook {
    function settleReward( address from,uint256 amount ) external returns (uint256);
    function bindRefer( address from,string calldata  affCode )  external returns (bool);
    function hasRefer(address from) external returns(bool);
}

contract Nfa is TRC20Detailed, TRC20 {
    using SafeTRC20 for ITRC20;
    using Address for address;
    using SafeMath for uint;

    uint internal BURN_PERCENT = 3;//���ٱ���

    uint public decimalVal = 1e6;
    uint256 public _burnRate = 3;

  
    uint public FOMO_MAX_LIMIT = 10000 * decimalVal;

   
    uint public FomoRewardPool;
  
    bool public burnFlag;//�Ƿ��л��� 
   
    
    address public holdRewardAddr;//��ȡnfa��ַ 
    
   address[] public specialAddress;

    function setMaxLimit(uint val) public onlyOwner {
        FOMO_MAX_LIMIT = val;
    }

    constructor (address addr_) public TRC20Detailed("NFA", "NFA", 6) {//*decimalVal
        _mint(msg.sender, 100000*decimalVal); 
        holdRewardAddr = addr_;
    }
    function setSpecialAddress(address addr) public onlyOwner{
        require(address(0) != addr);
        specialAddress.push(addr);
    }
    function setHoldRewardAddr(address addr) public onlyOwner {
        require(address(0) != addr);
        holdRewardAddr = addr;
    }
    function getSpecialAddress(address addr) public view returns(bool) {
         for(uint256 i=0;i<specialAddress.length;i++){
             if(specialAddress[i] == addr){
                   return true;
             }
        }
        return false;
    }
    
    function getBurnRate() public view returns(uint) {
        return _burnRate;
    }

    function _transferBurn(address from, uint amount,uint amountTo) internal {
        require(from != address(0));

        // burn
        
        _burn(from, amount);

        // fomo reward pool
        super._transfer(from, holdRewardAddr, amountTo);
        FomoRewardPool = FomoRewardPool.add(amountTo);
    }


    function burn(uint amount) public returns (bool)  {
        super._burn(msg.sender, amount);
    }

    

    function transfer(address to, uint value) public  returns (bool) {
        uint transferAmount = value;
       uint burnRate = getBurnRate();
       uint burnAmount = value.mul(burnRate).div(100);//���ٱ��� 
       uint totalSupply = totalSupply();
      
          
        if (!getSpecialAddress(msg.sender) && !getSpecialAddress(to) && burnRate > 0 && totalSupply>FOMO_MAX_LIMIT) {
            uint burnAmountNext = value.mul(BURN_PERCENT).div(100);//ת���Լ  
            transferAmount = value.sub(burnAmount.add(burnAmountNext));
            _transferBurn(msg.sender, burnAmount,burnAmountNext);
        }
        super.transfer(to, transferAmount);

        return true;
    }

    function transferFrom(address from, address to, uint value) public returns (bool) {
        uint burnRate = getBurnRate();
        uint transferAmount = value;
        uint burnAmount = value.mul(burnRate).div(100);//���ٱ��� 
        uint totalSupply = totalSupply();
      
        if (!getSpecialAddress(from)&&burnRate > 0 && totalSupply>FOMO_MAX_LIMIT) {
            uint burnAmountNext = value.mul(BURN_PERCENT).div(100);//ת���Լ  
            transferAmount = value.sub(burnAmount.add(burnAmountNext));
            _transferBurn(from, burnAmount,burnAmountNext);
        }

        super._transfer(from, to, transferAmount);
        super._approve(from, msg.sender, _allowances[from][msg.sender].sub(value));

        return true;
    }

    function rescue(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "must not 0");
        require(amount > 0, "must gt 0");
        require(address(this).balance >= amount, "insufficient balance");

        to.transfer(amount);
    }

    function rescue(address to, ITRC20 token, uint256 amount) external onlyOwner {
        require(to != address(0), "must not 0");
        require(amount > 0, "must gt 0");
        require(token.balanceOf(address(this)) >= amount, "insufficent token balance");

        token.transfer(to, amount);
    }
    
}

contract Purcase is Ownable{
     using SafeMath for uint256;
     using SafeTRC20 for ITRC20;
   
    ITRC20 public naft;
    ITRC20 public usdt;
    
    uint256 public price = 2 * 1e6;
    mapping (address => uint256) public userNumber;//���뽱��   
    //ITRC20 public PlayerManager;
    uint256 public maxTokenCount = 41004 * 1e6;//���ȶ�
    uint256 public hasTokenCount = 0;//��������
    uint256 public minAmount = 10 * 1e6;
    uint256 public maxAmount = 200 * 1e6;
    uint256 public freed = 5; //5%
    uint256 public freedBase = 100;
     struct Order{
        uint256 amount;
        uint256 number;
        uint256 time;
    }
    address public player;
    
    struct  Player {
        uint256 amount;
        uint256 amountPayed;
        uint256 number; //Ͷ��
        uint256 ordersIndex;
        mapping (uint256 => Order) orders;
    }
    address public walletAddress;
    
     mapping(address => Player) public _plyr;//����ĳһ��token

    constructor(address nfa_,address usdt_,address player_,address walletAddress_) public {
        naft = ITRC20(nfa_);
        usdt = ITRC20(usdt_);
        player = player_;
        walletAddress = walletAddress_;
    }
    
     modifier checkEnd() {
        require(hasTokenCount <= maxTokenCount,'is no');
        _;
    }
    //��Ŀ
    function setWalletAddress(address _walletAddress) public onlyOwner{
        walletAddress = _walletAddress;
    }
    function setFreede(uint256 _freed) public onlyOwner{
        freed = _freed;
    }
    function setPrice(uint256 _price) public onlyOwner{
        price = _price;
    }
    function setMaxAmount(uint256 _maxAmount) public onlyOwner{
        maxAmount = _maxAmount;
    }
    function setMinAmount(uint256 _minAmount) public onlyOwner{
        minAmount = _minAmount;
    }
    function setMaxTokenCount(uint256 _maxTokenCount) public onlyOwner{
        maxTokenCount = _maxTokenCount;
    }
    
     //ÿһ����Լ�ҵ�����
    function calcUsdtToToken(uint256 amount) public view returns (uint256){
        return amount.mul(1e6).div(price);
    }

    function calcTokenToUsdt(uint256 amount) public view returns (uint256){
        return amount.mul(price).div(1e6);
    }
    
    //Ͷ��
    function stake(uint256 amount)  public checkEnd{
        require(amount >0,"amount > 0");
        
        uint256 receivedToken = calcUsdtToToken(amount);//ÿһ����Լ�ҵļ۸�

        //require(receivedToken >= minAmount,"is not minAmount");
        
        uint256 newAmount  = receivedToken.add(_plyr[msg.sender].amount);//��ǰ��Լ�ҵļ۸����� + ��ǰ��ַ�Ѿ����������
        //uint256 usdtMaxAmount = calcTokenToUsdt(newAmount);//���µ����� * �۸�
        require(newAmount <= maxAmount,"is not maxAmount");
        
         _plyr[msg.sender].amount = newAmount;
         _plyr[msg.sender].number = (_plyr[msg.sender].number).add(amount);
         //ĳһ��token�еĵ�ַ���򶩵���¼
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].number = amount;
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].amount = receivedToken;
         _plyr[msg.sender].orders[_plyr[msg.sender].ordersIndex].time = block.timestamp;
         _plyr[msg.sender].ordersIndex++;
        hasTokenCount = hasTokenCount.add(amount);
       usdt.safeTransferFrom(msg.sender, walletAddress, amount);
       naft.safeTransfer(msg.sender, receivedToken);
       address lastAddress = PlayerManager(player).lastUserAddress(msg.sender);
      if(lastAddress != address(0)){
          amount = receivedToken.mul(freed).div(freedBase);//�ٷ�֮5���
          if(PlayerManager(player).balanceAnf() >= amount){
              userNumber[lastAddress] = userNumber[lastAddress].add(amount);
              PlayerManager(player).transferAddress(lastAddress,amount);
          }
      }
    }
   //ת�� TKAMsnU654mcJQgie6MGWge6G6GrFZrTzn
    // function transfer_contract() public  onlyOwner{
    //     usdt.safeTransfer(msg.sender, usdt.balanceOf(address(this)));
    // }
    
    function getUserOrder(address addr) public view returns(uint256[] memory,uint256[] memory){
        uint256[] memory amount = new uint256[](_plyr[addr].ordersIndex);
        uint256[] memory time = new uint256[](_plyr[addr].ordersIndex);
        for(uint256 i=0;i<_plyr[addr].ordersIndex;i++){
            amount[i] = _plyr[addr].orders[i].amount;
            time[i] = _plyr[addr].orders[i].time;
        }
        return(amount,time);
    }

}

contract PlayerManager{
    using SafeMath for uint256;
    using SafeTRC20 for ITRC20;
    ITRC20 public token;
    constructor (address token_) public {
        token = ITRC20(token_);
    }
    struct Player{
        address lastUser;
        uint256 amount;
        bool isRegister;
        uint256 invitsIndex;
        mapping (uint256 => Invitation) invits;
    }

    struct Invitation{
         uint256 time;
         address  addr;
    }

    mapping (address => Player) public _plyr;

    
    modifier isRegistered(address user){
        require(!_plyr[user].isRegister,"Address registered");
        _;
    }
//
     function lastUserAddress(address addr) public view returns (address){
        return  _plyr[addr].lastUser;
    }
     function register(address user,address lastUser) public isRegistered(user) {
        require(user != lastUser,"Address repeat");
        require(_plyr[lastUser].lastUser != user,"Address Invited");
         _plyr[user].isRegister = true;
         _plyr[user].lastUser = lastUser;
         _plyr[lastUser].invits[_plyr[lastUser].invitsIndex].addr = user;
         _plyr[lastUser].invits[_plyr[lastUser].invitsIndex].time = block.timestamp;
         _plyr[lastUser].invitsIndex++;
         
    }
    function getUserInvit(address addr_) public view returns(address[] memory,uint256[] memory){
        address[] memory addr = new address[](_plyr[addr_].invitsIndex);
        uint256[] memory time = new uint256[](_plyr[addr_].invitsIndex);
        for(uint256 i=0;i<_plyr[addr_].invitsIndex;i++){
            addr[i] = _plyr[addr_].invits[i].addr;
            time[i] = _plyr[addr_].invits[i].time;
        }
        return (addr,time);
    }
    function balanceAnf() public view returns(uint256){
       return token.balanceOf(address(this));
    }
    function transferAddress(address lastAddress,uint256 amount) public{
        token.safeTransfer(lastAddress, amount);
    }
}