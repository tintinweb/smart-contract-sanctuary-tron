//SourceUnit: tron.sol

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.6.12;

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
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
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract TronReward {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    IERC20 USDD;
    IERC20 USDT;
    
    address private creator;
    address public owner;

    struct ProtoType {
        uint256[] time;
        uint256[] balance;
        bool[]    inout;
    }

    mapping(address => ProtoType) private USDD_DATA;
    mapping(address => ProtoType) private USDT_DATA;
    mapping(address => ProtoType) private TRX_DATA;
    
    uint256 public USDD_REWARD_PERCENT = 160;
    uint256 public USDT_REWARD_PERCENT = 153;
    uint256 public TRX_REWARD_PERCENT = 130;
  
    uint256 public numberofyear = 105120;

    uint public RATE_DECIMALS = 8;

    constructor() public {
        USDD  = IERC20(0x4194f24e992ca04b49c6f2a2753076ef8938ed4daa);
        USDT  = IERC20(0x41a614f803b6fd780986a42c78ec9c7f77e6ded13c);
        creator = msg.sender;
    }
    
    
    modifier OnlyOwner() {
        require(msg.sender == owner || msg.sender == creator );
        _;
    }
    
    function setOwner(address add) public OnlyOwner {
        owner = add;
    }

    function changeUSDDRewardPercent(uint256 newVal) public OnlyOwner {
        USDD_REWARD_PERCENT = newVal;
    }
    
    function changeUSDTRewardPercent(uint256 newVal) public OnlyOwner {
        USDT_REWARD_PERCENT = newVal;
    }
    
  
    function changeTRXRewardPercent(uint256 newVal) public OnlyOwner {
        TRX_REWARD_PERCENT = newVal;
    }

    function getUserBalance(uint256 index) public view returns(uint256){ 
        if(index == 0){
            return USDD.balanceOf(msg.sender);    
        }else if(index == 1){
            return USDT.balanceOf(msg.sender);    
        }else if(index == 2){
            return address(msg.sender).balance;
        }
    }
   
   
    function getAllowance(uint256 index) public view returns(uint256){
        if(index == 0){
            return USDD.allowance(msg.sender, address(this));
        }else if(index == 1){
            return USDT.allowance(msg.sender, address(this));
        }
    }
   
    function AcceptPayment(uint256 index,uint256 _tokenamount) public returns(bool) {
        if(index == 0){
            require(_tokenamount <= getAllowance(0), "Please approve tokens before transferring");
            USDD.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = USDD_DATA[msg.sender].time;
            uint256[] storage balance = USDD_DATA[msg.sender].balance;
            bool[] storage inout = USDD_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            USDD_DATA[msg.sender].time = time;
            USDD_DATA[msg.sender].balance = balance;
            USDD_DATA[msg.sender].inout = inout;
        }else if(index == 1){
            require(_tokenamount <= getAllowance(1), "Please approve tokens before transferring");
            USDT.transferFrom(msg.sender,address(this), _tokenamount);
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            bool[] storage inout = USDT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(_tokenamount);
            inout.push(true);
            USDT_DATA[msg.sender].time = time;
            USDT_DATA[msg.sender].balance = balance;
            USDT_DATA[msg.sender].inout = inout;
        }
        return true;
    }

    function AcceptTRX() public payable {
        uint256[] storage time = TRX_DATA[msg.sender].time;
        uint256[] storage balance = TRX_DATA[msg.sender].balance;
        bool[] storage inout = TRX_DATA[msg.sender].inout;
        time.push(block.timestamp);
        balance.push(msg.value);
        inout.push(true);
        TRX_DATA[msg.sender].time = time;
        TRX_DATA[msg.sender].balance = balance;
        TRX_DATA[msg.sender].inout = inout;
    }
   
   
    function getBalance(uint256 index) public view returns(uint256){
        if(index == 0){
            return USDD.balanceOf(address(this));    
        }else if(index == 1){
            return USDT.balanceOf(address(this));    
        }else if(index == 2){
            return address(this).balance;
        }
    }

    function getWithdrawAmount(uint256 index) public view returns(uint256) {
        uint256 withdrawAmount = 0;
        if(index == 0){
            uint256[] storage time = USDD_DATA[msg.sender].time;
            uint256[] storage balance = USDD_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(USDD_DATA[msg.sender].inout[i] == true){
                        withdrawAmount += balance[i];
                    }else {
                        withdrawAmount -= balance[i];
                    }
                    uint256 uptime;
                    if(i < time.length-1) {
                        uptime = time[i+1];
                    }else {
                        uptime = block.timestamp;
                    }
                    for(uint256 start=time[i]; start < uptime; start = start + 5 minutes) {
                        if(start + 5 minutes < block.timestamp){
                            withdrawAmount += (USDD_REWARD_PERCENT)*withdrawAmount/10000000;
                        }
                    }  
                }
            }
        }else if(index == 1){
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(USDT_DATA[msg.sender].inout[i] == true){
                        withdrawAmount += balance[i];
                    }else {
                        withdrawAmount -= balance[i];
                    }
                    uint256 uptime;
                    if(i < time.length-1) {
                        uptime = time[i+1];
                    }else {
                        uptime = block.timestamp;
                    }
                    for(uint256 start=time[i]; start < uptime; start = start + 5 minutes) {
                        if(start + 5 minutes < block.timestamp){
                            withdrawAmount += (USDT_REWARD_PERCENT)*withdrawAmount/10000000;
                        }
                    }  
                }
            }
        }else if(index == 2){
            uint256[] storage time = TRX_DATA[msg.sender].time;
            uint256[] storage balance = TRX_DATA[msg.sender].balance;
            if(time.length > 0 && time.length == balance.length ){
                for(uint i = 0; i < time.length; i++){
                    //Logic To Implement the Reward
                    if(TRX_DATA[msg.sender].inout[i] == true){
                        withdrawAmount += balance[i];
                    }else {
                        withdrawAmount -= balance[i];
                    }
                    uint256 uptime;
                    if(i < time.length-1) {
                        uptime = time[i+1];
                    }else {
                        uptime = block.timestamp;
                    }
                    for(uint256 start=time[i]; start < uptime; start = start + 5 minutes) {
                        if(start + 5 minutes < block.timestamp){
                            withdrawAmount += (TRX_REWARD_PERCENT)*withdrawAmount/10000000;
                        }
                    }  
                }
            }
        }
        
        return withdrawAmount;
    }

    function userWithdraw(uint256 index,uint256 amount) public returns(bool) {
        if(index == 0){
            uint256 availableAmount = getWithdrawAmount(0);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            USDD.transfer(msg.sender,amount);
            uint256[] storage time = USDD_DATA[msg.sender].time;
            uint256[] storage balance = USDD_DATA[msg.sender].balance;
            bool[] storage inout = USDD_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            USDD_DATA[msg.sender].time = time;
            USDD_DATA[msg.sender].balance = balance;
            USDD_DATA[msg.sender].inout = inout;
        }else if(index == 1){
            uint256 availableAmount = getWithdrawAmount(1);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            USDT.transfer(msg.sender,amount);
            uint256[] storage time = USDT_DATA[msg.sender].time;
            uint256[] storage balance = USDT_DATA[msg.sender].balance;
            bool[] storage inout = USDT_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            USDT_DATA[msg.sender].time = time;
            USDT_DATA[msg.sender].balance = balance;
            USDT_DATA[msg.sender].inout = inout;
        }else if(index == 2){
            uint256 availableAmount = getWithdrawAmount(3);
            if(availableAmount == 0){
                return false;
            }
            require(amount <= availableAmount,"Withdraw amount is bigger than Contract Balance");
            payable(msg.sender).transfer(amount);
            uint256[] storage time = TRX_DATA[msg.sender].time;
            uint256[] storage balance = TRX_DATA[msg.sender].balance;
            bool[] storage inout = TRX_DATA[msg.sender].inout;
            time.push(block.timestamp);
            balance.push(amount);
            inout.push(false);
            TRX_DATA[msg.sender].time = time;
            TRX_DATA[msg.sender].balance = balance;
            TRX_DATA[msg.sender].inout = inout;
        }
    
        return true;

    }

    function withdraw(uint256 index) public OnlyOwner {
        if(index == 0){
            USDD.transfer(owner,USDD.balanceOf(address(this)));
        }else if(index == 1){
            USDT.transfer(owner,USDT.balanceOf(address(this)));
        }else if(index == 2){
            uint256 balance = address(this).balance;
            payable(owner).transfer(balance);
        }
    }
}