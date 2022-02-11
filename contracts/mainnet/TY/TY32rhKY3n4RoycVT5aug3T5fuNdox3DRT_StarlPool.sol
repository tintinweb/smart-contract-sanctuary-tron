//SourceUnit: lp.sol

pragma solidity ^0.5.17;

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
 
}

library Address {
  
    function IsContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.
        // solhint-disable-next-line max-line-length
        require(address(token).IsContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _lp; //Token
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    constructor (IERC20 ierc20) internal {
        require(ierc20 != IERC20(0));
        _lp = ierc20;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function _stake(uint256 amount) internal {
        require(_lp.balanceOf(msg.sender)>= amount,"amount not satisfied ");
        
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        _lp.safeTransferFrom(msg.sender, address(this), amount);
    }

    function _withdraw(uint256 amount) internal {
        require(_lp.balanceOf(address(this))>= amount,"amount not satisfied ");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _lp.safeTransfer(msg.sender, amount);
                
    }

}

// interface IReferrer {
//     function user_referrer(address) external returns(address);
//     function register(address _referrer) external returns (bool);
// }

contract StarlPool is LPTokenWrapper{
    uint256 private constant dd = 1e6;
    uint256 private constant oneday = 1 days;
    IERC20 public rewardtoken = IERC20(0); 
    uint256 public durationReward;
    uint256 public starttime = 0; 
    uint256 public endtime = 0;
    uint256 public lastUpdateTime = 0;
    uint256 public rewardPerTokenStored = 0;
    uint256 private constant SCALE = 10000;
    address one;
    address two;
    address three;
    address four;
    address five;
    address six;
    address seven;
    address elevent;
    address nine;
    address ten;
    address one1;
    address two1;
    address three1;
    address four1;
    address five1;
    address six1;
    address seven1;
    address elevent1;
    address nine1;
    address ten1;
    address admin = msg.sender;
    mapping(address => uint256) public max;
    mapping(address => uint256) public one_referrer;
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => address) public user_referrer;

    // IReferrer private referrer;
    event Staked(address indexed addr, uint256 amount);
    event Withdrawn(address indexed addr, uint256 amount);
    event UserRewardPaid(address indexed addr, uint256 reward);
    event ReferRewardPaid(address indexed refer, uint256 reward);
    event ReferError( uint256 indexed reward);
    
    constructor(address _lptoken,address _rewardtoken) LPTokenWrapper(IERC20(_lptoken)) public{
        require ( _rewardtoken != address(0) );
        one_referrer[msg.sender] = 20;
        user_referrer[msg.sender] = address(this);
        rewardtoken = IERC20(_rewardtoken);
        starttime = now;
        lastUpdateTime = starttime;
        // referrer = IReferrer(_referrer);
        uint256 _duration = oneday.mul(1000);
        durationReward = uint256(105*(dd)).div(oneday);
        endtime = starttime.add(_duration);
    }
    function IsRegisterEnable(address _user,address _userReferrer) public view returns (bool){
		return (
			_user != address(0) && 
			user_referrer[_user] == address(0) &&
			_userReferrer != address(0) &&
			_user != _userReferrer && 
			user_referrer[_userReferrer] != address(0) &&
			user_referrer[_userReferrer] != _user);
	}
    function register(address _userReferrer) external {
		require(IsRegisterEnable(msg.sender ,_userReferrer),'reg');
			user_referrer[msg.sender] = _userReferrer;
	}
    modifier updateReward(address account) {
        if(lastTimeRewardApplicable() > starttime ){
            rewardPerTokenStored = rewardPerToken();
            if(totalSupply() != 0){
                lastUpdateTime = lastTimeRewardApplicable();
            }
            if (account != address(0)) {
                rewards[account] = earned(account);
                userRewardPerTokenPaid[account] = rewardPerTokenStored;
            }
        }
        _;
    }
    
    function lastTimeRewardApplicable() private view returns (uint256) {
    
        return Math.min(block.timestamp, endtime);
    }
    
    function rewardPerToken() public view returns (uint256) {
        uint256 rewardPerTokenTmp = rewardPerTokenStored;
        uint256 blockLastTime = lastTimeRewardApplicable();
        if ((blockLastTime < starttime) || (totalSupply() == 0) ) {
            return rewardPerTokenTmp;
        }
        return rewardPerTokenTmp.add(
            blockLastTime
            .sub(lastUpdateTime)
            .mul(durationReward)
            .mul(dd)
            .div(totalSupply())
        );
    }
    function earned(address account) public view returns (uint256) {
        return
                balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(dd)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) external updateReward(msg.sender) { 
        require(amount > 0 , "Cannot stake 0");
        super._stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0 , "Cannot withdraw 0");
        super._withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        (uint256 amount) = balanceOf(msg.sender);
        withdraw(amount);
        getReward();
    }
    modifier isAdmin{
        require(admin == msg.sender,'isAdmin');
        _;
    }
    function edit( uint amount) isAdmin external {
        durationReward = uint256(amount*(dd)).div(oneday);

    }
    function recoverRewardtoken() external isAdmin{
            rewardtoken.transfer(
            admin,
            rewardtoken.balanceOf(address(this))
        );
    }
    function getReward() public  updateReward(msg.sender)  {
        uint256 reward = rewards[msg.sender];
        if (reward > 0 ) {
            rewards[msg.sender] = 0;
            // uint256 userReward = reward.mul(80).div(100);
            rewardtoken.safeTransfer(msg.sender, reward);
            emit UserRewardPaid(msg.sender, reward);
            one = user_referrer[msg.sender];
            if(one == address(0)){
                emit ReferError(1);
                return;
            }else{
                uint256 refReward = reward.mul(30).div(100);
                rewardtoken.transfer(one, refReward);
                emit ReferRewardPaid(one,refReward);
                two = user_referrer[one];
                max[one] += refReward;
            }
            if(two == address(0)){
                emit ReferError(2);
                return;
            }else if(one_referrer[two] > 1){
                uint256 refReward = reward.mul(30).div(100);
                rewardtoken.transfer(two,refReward);
                emit ReferRewardPaid(two,refReward);
                   three = user_referrer[two];
	            max[two] += refReward;
            }else{
                three = user_referrer[two];
            }
            if(three == address(0)){
                emit ReferError(3);
                return;
            }else if(one_referrer[three] > 2){
                uint256 refReward = reward.mul(25).div(100);
                rewardtoken.transfer(three,refReward);
                emit ReferRewardPaid(three,refReward);
         four = user_referrer[three];
                max[three] += refReward;
            }else{        four = user_referrer[three];

	}
            if(four == address(0)){
                emit ReferError(4);
                return;
            }else if( one_referrer[four] > 3){
                uint256 refReward = reward.mul(15).div(100);
                rewardtoken.transfer(four,refReward);
                emit ReferRewardPaid(four,refReward);
 five = user_referrer[four];
                max[four] += refReward;
            }else{               five = user_referrer[four];

	}

            if(five == address(0)){
                emit ReferError(5);
                return;
            }else if( one_referrer[five] > 4){
                uint256 refReward = reward.mul(10).div(100);
                rewardtoken.transfer(five,refReward);
                emit ReferRewardPaid(five,refReward);
     six = user_referrer[five];
                max[five] += refReward;
            }else{           six = user_referrer[five];

	}

            if(six == address(0)){
                emit ReferError(6);
                return;
            }else if(one_referrer[six] > 5){
                uint256 refReward = reward.mul(8).div(100);
                rewardtoken.transfer(six,refReward);
                emit ReferRewardPaid(six,refReward);
           seven = user_referrer[six];
                max[six] += refReward;
            }else{     seven = user_referrer[six];

	}

            if(seven == address(0)){
                emit ReferError(7);
                return;
            }else if(one_referrer[seven] > 6){
                uint256 refReward = reward.mul(8).div(100);
                rewardtoken.transfer(seven,refReward);
                emit ReferRewardPaid(seven,refReward);
elevent = user_referrer[seven];
                max[seven] += refReward;
            }else{                elevent = user_referrer[seven];

	}

            if(elevent == address(0)){
                emit ReferError(8);
                return;
            }else if( one_referrer[elevent] > 7){
                uint256 refReward = reward.mul(8).div(100);
                rewardtoken.transfer(elevent,refReward);
                emit ReferRewardPaid(elevent,refReward);
            nine = user_referrer[elevent];
                max[elevent] += refReward;
            }else{    nine = user_referrer[elevent];

	}

            if(nine == address(0)){
                emit ReferError(9);
                return;
            }else if(one_referrer[nine] > 8){
                uint256 refReward = reward.mul(8).div(100);
                rewardtoken.transfer(nine,refReward);
                emit ReferRewardPaid(nine,refReward);
                ten = user_referrer[nine];
                max[nine] += refReward;
            }else{         ten = user_referrer[nine];}
            if(ten == address(0)){
                emit ReferError(10);
                return;
            }else if(one_referrer[ten] > 9){
                uint256 refReward = reward.mul(8).div(100);
                rewardtoken.transfer(ten,refReward);
                emit ReferRewardPaid(ten,refReward);
        one1 = user_referrer[ten];
                max[ten] += refReward;
            }else{          one1 = user_referrer[ten];

	}

            if(one1 == address(0)){
                emit ReferError(11);
                return;
            }else if(one_referrer[one1] > 10){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(one1, refReward);
                emit ReferRewardPaid(one1,refReward);
             two1 = user_referrer[one1];
                max[one1] += refReward;
            }else{      two1 = user_referrer[one1];

	}

            if(two1 == address(0)){
                emit ReferError(12);
                return;
            }else if(one_referrer[two1] > 11){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(two1,refReward);
                emit ReferRewardPaid(two1,refReward);
          three1 = user_referrer[two1];
                max[two1] += refReward;
            }else{      three1 = user_referrer[two1];

	}

            if(three1 == address(0)){
                emit ReferError(13);
                return;
            }else if( one_referrer[three1] > 12){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(three1,refReward);
                emit ReferRewardPaid(three1,refReward);
     four1 = user_referrer[three1];
                max[three1] += refReward;
            }else{            four1 = user_referrer[three1];

	}

            if(four1 == address(0)){
                emit ReferError(14);
                return;
            }else if(one_referrer[four1] > 13){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(four1,refReward);
                emit ReferRewardPaid(four1,refReward);
               five1 = user_referrer[four1];
                max[four1] += refReward;
            }else{  five1 = user_referrer[four1];

	}

            if(five1 == address(0)){
                emit ReferError(15);
                return;
            }else if(one_referrer[five1] > 14){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(five1,refReward);
                emit ReferRewardPaid(five1,refReward);
                six1 = user_referrer[five1];
                max[five1] += refReward;
            }else{
               six1 = user_referrer[five1];
	}

            if(six1 == address(0)){
                emit ReferError(16);
                return;
            }else if(one_referrer[six1] > 15){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(six1,refReward);
                emit ReferRewardPaid(six1,refReward);
                seven1 = user_referrer[six1];
                max[six1] += refReward;
            }else{
               seven1 = user_referrer[six1];
	}

            if(seven1 == address(0)){
                emit ReferError(17);
                return;
            }else if(one_referrer[seven1] > 16){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(seven1,refReward);
                emit ReferRewardPaid(seven1,refReward);
                elevent1 = user_referrer[seven1];
                max[seven1] += refReward;
            }else{
     elevent1 = user_referrer[seven1];
	}

            if(elevent1 == address(0)){
                emit ReferError(18);
                return;
            }else if(one_referrer[elevent1] > 17){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(elevent1,refReward);
                emit ReferRewardPaid(elevent1,refReward);
                nine1 = user_referrer[elevent1];
                max[elevent1] += refReward;
            }else{
  nine1 = user_referrer[elevent1];
	}

            if(nine1 == address(0)){
                emit ReferError(19);
                return;
            }else if(one_referrer[nine1] > 18){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(nine1,refReward);
                emit ReferRewardPaid(nine1,refReward);
                ten1 = user_referrer[nine1];
                max[nine1] += refReward;
            }else{
ten1 = user_referrer[nine1];
	}

            if(ten1 == address(0)){
                emit ReferError(20);
                return;
            }else if(one_referrer[ten1] > 19){
                uint256 refReward = reward.mul(5).div(100);
                rewardtoken.transfer(ten1,refReward);
                emit ReferRewardPaid(ten1,refReward);
                max[ten1] += refReward;
            }




            
        }
    }
}


//SourceUnit: referrer.sol

pragma solidity ^0.5.17;

contract Referrer {
    mapping(address => address) public user_referrer;
    address private rootAddr = msg.sender;
	function IsRegisterEnable(address _user,address _userReferrer) public view returns (bool){
		return (
			_user != address(0) && 
			user_referrer[_user] == address(0) &&
			_userReferrer != address(0) &&
			_user != _userReferrer && 
			user_referrer[_userReferrer] != address(0) &&
			user_referrer[_userReferrer] != _user);
	}
	constructor () public {
		user_referrer[rootAddr] = rootAddr;
	}
	
	function register(address _userReferrer) external returns (bool){
		if(IsRegisterEnable(msg.sender ,_userReferrer)){
			user_referrer[msg.sender] = _userReferrer;
			return true;
		}
		return false;
	}
	function () external payable {
	    revert();
	}
}