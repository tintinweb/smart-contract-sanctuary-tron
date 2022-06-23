//SourceUnit: LP.sol

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// owner
contract Ownable {
    address public _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, 'DividendTracker: owner error');
        _;
    }
    

    function changeOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;       
    }
}

contract LPTokenWrapper is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public  _brctLPToken;
    IERC20 public  _brctToken;        

    uint256 private _totalSupply;

    mapping(address => uint256) public _lastLpBRCT;
    mapping(address => uint256) public _isLpBRCT;
    mapping(address => uint256) public _myLpBRCT;         
    uint256 public _totalLpBRCT;
    uint256 public _isTotalLpBRCT;     

    mapping(address => uint256) private _balanceslp;

    mapping(address => uint256) private _numTokenList;
    mapping(address => bool) private _isBand;
    mapping(address => mapping(uint256 => uint256)) private _tokenListNum;
    mapping(address => mapping(uint256 => uint256)) private _tokenListTime;
    mapping(address => mapping(uint256 => uint256)) private _tokenListStatus;

    bool public _openFund;                    
  
    event Deposited(address indexed user, uint256 amount, string typeCoin);
    event Withdrawed(address indexed user, uint256 amount, string typeCoin);
    event WithdrawFund(address indexed user, uint256 amount);    
    event WithdrawMint(address indexed user, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(IERC20 brctLPToken, IERC20 brctToken) {
        _brctLPToken = brctLPToken;
        _brctToken = brctToken;
        _owner = msg.sender;
        _openFund = false;
    }
          
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }        

    function balanceOflp(address account) public view returns (uint256) {
        return _balanceslp[account];
    }         

    function myPctLP(address account) public view returns (uint256) {
        if(_totalSupply == 0){
            return 0;
        }
        else{
            return _balanceslp[account].div(_totalSupply).mul(1000000);
        }
    }

    function myFund() public view returns (uint256) {
        uint256 brctBalances = _brctToken.balanceOf(address(this));             
        if(_totalSupply>0){
            return _balanceslp[msg.sender].mul(brctBalances).div(_totalSupply);                                
        }
        else{
            return 0;
        }
    }    

    function tokenListStatus(address owner, uint256 num)
        public
        view
        returns (uint256)
    {
        uint256 status=_tokenListTime[owner][num] + 1 days <= block.timestamp?_tokenListStatus[owner][num]:2;
        return status;
    }

    function tokenList(address owner)
        public
        view
        returns(
            uint256[] memory token_List_Num, 
            uint256[] memory token_List_Time, 
            uint256[] memory token_List_Status
        )
    {
        uint256 num = _numTokenList[owner];
        // 初始化数组大小
        token_List_Num = new uint256[](num);
        token_List_Time = new uint256[](num);
        token_List_Status = new uint256[](num);                     
        
        // 给数组赋值
		for(uint256 i = num; i>=1; i--){
            token_List_Num[num-i] = _tokenListNum[owner][i];
            token_List_Time[num-i] =  _tokenListTime[owner][i];
            token_List_Status[num-i] = tokenListStatus(owner, i);
        }

        return (token_List_Num, token_List_Time, token_List_Status);
    }        

    function _updateTokenList(uint256 amount) private {
        _numTokenList[msg.sender] += 1;
        _tokenListNum[msg.sender][_numTokenList[msg.sender]] = amount;
        _tokenListTime[msg.sender][_numTokenList[msg.sender]] = block.timestamp;
        _tokenListStatus[msg.sender][_numTokenList[msg.sender]] =  1;             
    }                   

    function _deposit(uint256 amount) private {
        _totalSupply = _totalSupply.add(amount);
        //BRCT  LP分红
        uint256 brctBalances = _brctToken.balanceOf(address(this));             
        _totalLpBRCT = brctBalances + _isTotalLpBRCT;
        if(_lastLpBRCT[msg.sender] > 0 && _totalLpBRCT >= _lastLpBRCT[msg.sender] && _totalSupply>0){
            uint256 totalLpBRCT =  _totalLpBRCT - _lastLpBRCT[msg.sender];
            _myLpBRCT[msg.sender] += _balanceslp[msg.sender].mul(totalLpBRCT).div(_totalSupply);                                
        }
        _brctLPToken.safeTransferFrom(msg.sender, address(this), amount);
        _lastLpBRCT[msg.sender] = _totalLpBRCT;
        _balanceslp[msg.sender] = _balanceslp[msg.sender].add(amount);
        _updateTokenList(amount);
    }

    function _withdrawTran(uint256 amount, uint256 listNum) private {      
        if(_numTokenList[msg.sender]<1)return;      
        if(_balanceslp[msg.sender]>= amount){
            _balanceslp[msg.sender] -= amount;
        }
        else{
           _balanceslp[msg.sender] = 0; 
        }  
        if(_totalSupply>= amount){
            _totalSupply -= amount;
        }
        else{
            _totalSupply = 0; 
        }  
        _tokenListStatus[msg.sender][listNum] = 0;
        _tokenListNum[msg.sender][listNum] -= amount;
        if(_balanceslp[msg.sender] == 0 || _totalSupply == 0){
            _lastLpBRCT[msg.sender] = 0;
        }     
    }


    function _withdraw(uint256 amount, uint256 listNum) private {                      
        _withdrawTran(amount, listNum);
    }

    function _updateFund() private {
        uint256 brctBalances = _brctToken.balanceOf(address(this));             
        _totalLpBRCT = brctBalances + _isTotalLpBRCT;
        if(_lastLpBRCT[msg.sender] > 0 && _totalLpBRCT >= _lastLpBRCT[msg.sender] && _totalSupply>0){
            uint256 totalLpBRCT =  _totalLpBRCT - _lastLpBRCT[msg.sender];
            _myLpBRCT[msg.sender] += _balanceslp[msg.sender].mul(totalLpBRCT).div(_totalSupply);
            _lastLpBRCT[msg.sender] = _totalLpBRCT;                                
        }
    }

    function _withdrawFund() private{
        require(_myLpBRCT[msg.sender] > 1*10**15, "less than withdraw Min");
        require(_myLpBRCT[msg.sender]<=_brctToken.balanceOf(address(this)), "balance not enough");
        require(_openFund, "not open");        
        _brctToken.safeTransfer(msg.sender, _myLpBRCT[msg.sender]);
        _isLpBRCT[msg.sender] += _myLpBRCT[msg.sender];
        _isTotalLpBRCT += _myLpBRCT[msg.sender];
        _myLpBRCT[msg.sender] = 0;
        emit WithdrawFund(msg.sender, _myLpBRCT[msg.sender]);            
    }      

    function updateFund() public returns (bool){
        _updateFund();
        return true;
    }

    function changeOpenFund(bool value) public onlyOwner returns (bool){
        _openFund = value;
        return true;
    }         

    function withdrawFund() public returns (bool){
        _updateFund();
        _withdrawFund();
        return true;
    }        

    function deposit(uint256 amount) public { 
        require(amount > 0, "Cannot stake 0");
        require(_brctLPToken.balanceOf(msg.sender) >= amount, "LP not enough"); 
        string memory coin;                   
        coin = "USDTTLP";
        _deposit(amount);     
        emit Deposited(msg.sender, amount, coin);
    }

    function withdraw(uint256 amount, uint256 listNum) public {
        require(amount > 0, "Cannot withdraw 0");
        require(!_isBand[msg.sender], "BAND");
        require(_balanceslp[msg.sender] >= amount, "less than own");
        require(_tokenListNum[msg.sender][listNum] >= amount, "not enough");           
            
        _withdraw(amount, listNum);      
        _brctLPToken.safeTransfer(msg.sender, amount); 
    }

    function withdrawToken(IERC20 token, address to, uint256 value) external onlyOwner {
        token.safeTransfer(to, value);
    } 

    function changeAddress(IERC20 brctLPToken, IERC20 brctToken) external onlyOwner {      
        _brctLPToken = brctLPToken;
        _brctToken = brctToken;
    }
    
    function changeBandAddress(address sender, bool value) external onlyOwner {      
        _isBand[sender] = value;
    }          
}