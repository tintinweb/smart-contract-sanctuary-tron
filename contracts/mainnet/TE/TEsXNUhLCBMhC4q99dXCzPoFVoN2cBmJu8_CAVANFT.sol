//SourceUnit: cavanft.sol

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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

contract Ownable {
    address public _owner;
    address public _composer;

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }   

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
    
    function composer() public view returns (address) {
        return _composer;
    }

    modifier onlyComposer() {
        require(_composer == msg.sender, "Ownable: caller is not the composer");
        _;
    }   

    function changeComposer(address newComposer) public onlyOwner {
        _composer = newComposer;
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

contract CAVANFT is IERC20, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address => uint256) private _rOwned;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isBlackList;
    
    mapping(address => uint256) public _primary;
    mapping(address => uint256) public _intermediate;
    mapping(address => uint256) public _senior;
    mapping(address => uint256) public _super;
    
    uint256 public _primaryTotal;
    uint256 public _intermediateTotal;
    uint256 public _seniorTotal;
    uint256 public _superTotal;
    uint256 public _superTemp;
    
    mapping(address => uint256) private _numSynthesisList;
    mapping(address => mapping(uint256 => uint256)) private _synthesisListNum;
    mapping(address => mapping(uint256 => uint256)) private _synthesisListTime;
    mapping(address => mapping(uint256 => uint256)) private _synthesisListStatus;
    mapping(address => mapping(uint256 => uint256)) private _synthesisListType;

    uint256 private _totalSupply;
    uint256 public _mintTotal;
    uint256 public _outTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals; 
    
    event UserSynthesis(address account, string types);
    event AdminSynthesis(address account, string types);
    event Recovery(address account, string types, uint256 amount);
    event Distribution(address account, uint256 amount);             
    
    constructor() {
        _name = "CAVANFT";
        _symbol = "CAVANFT";
        _decimals = 8;

        _totalSupply = 11000000 * 10**_decimals;
        _mintTotal = 10650000 * 10**_decimals;
        _outTotal = 350000 * 10**_decimals;
        
        _superTotal = 50;
        _superTemp = 50;

        _owner = msg.sender;


        _rOwned[address(0)] = _outTotal;
        _rOwned[address(this)] = _mintTotal;

        emit Transfer(address(0), address(0), _outTotal);
        emit Transfer(address(0), address(this), _mintTotal);
        
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }          
    
    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function allowance(
        address owner,
        address spender
    )
    public view override  returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public override  returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }


    function approve(address spender, uint256 value) public override  returns (bool) {
        require(spender != address(0));

        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
    public override 
    returns (bool)
    {
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }


    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowances[msg.sender][spender] = (
        _allowances[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }


    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
    public
    returns (bool)
    {
        require(spender != address(0));

        _allowances[msg.sender][spender] = (
        _allowances[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }


    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(!_isBlackList[from] && !_isBlackList[to]);

        _rOwned[from] = _rOwned[from].sub(value);
        _rOwned[to] = _rOwned[to].add(value);
        emit Transfer(from, to, value);
    }


    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _rOwned[account] = _rOwned[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function changeBlackList(bool value, address account) external onlyComposer returns(bool) {
        _isBlackList[account] = value;
        return true; 
    }
    
    function userSynthesis(address account, uint256 types) external onlyComposer returns(bool) {
        require(!_isBlackList[account]);
        uint256 burnNum = 0;
        string memory typename;
        if(types == 1){
            require(_primaryTotal <= 1000);
            burnNum = 1000 * 10**_decimals;
            _burn(account, burnNum);
            _primaryTotal += 1;
            _primary[account] += 1;
            _updateSynthesisList(account, 1, 1, 1);
            typename = "primary";
        }
        if(types == 2){
            require(_intermediateTotal <= 500);
            burnNum = 2000 * 10**_decimals;
            _burn(account, burnNum);
            _intermediateTotal += 1;
            _intermediate[account] += 1;
            _updateSynthesisList(account, 1, 1, 2);
            typename = "intermediate";
        }
        if(types == 3){
            require(_seniorTotal <= 500);
            burnNum = 4000 * 10**_decimals;
            _burn(account, burnNum);
            _seniorTotal += 1;
            _senior[account] += 1;
            _updateSynthesisList(account, 1, 1, 3);
            typename = "senior";
        }
        if(types == 4){
            require(_superTotal <= 1000);
            _primaryTotal -= 1;
            _intermediateTotal -= 1;
            _seniorTotal -= 1;
            _primary[account] -= 1;
            _intermediate[account] -= 1;
            _senior[account] -= 1;
            _superTotal += 1;
            _super[account] += 1;
            _updateSynthesisList(account, 1, 1, 4);
            typename = "super";
        }
        emit UserSynthesis(account, typename);
        return true; 
    }
    
    function adminSynthesis(address account, uint256 types) external onlyComposer returns(bool) {
        require(!_isBlackList[account]);
        uint256 burnNum = 0;
        string memory typename;
        if(types == 1){
            require(_primaryTotal <= 1000);
            burnNum = 1000 * 10**_decimals;
            _burn(address(this), burnNum);
            _primaryTotal += 1;
            _primary[account] += 1;
            _updateSynthesisList(account, 1, 1, 1);
            typename = "primary";
        }
        if(types == 2){
            require(_intermediateTotal <= 500);
            burnNum = 2000 * 10**_decimals;
            _burn(address(this), burnNum);
            _intermediateTotal += 1;
            _intermediate[account] += 1;
            _updateSynthesisList(account, 1, 1, 2);
            typename = "intermediate";
        }
        if(types == 3){
            require(_seniorTotal <= 500);
            burnNum = 4000 * 10**_decimals;
            _burn(address(this), burnNum);
            _seniorTotal += 1;
            _senior[account] += 1;
            _updateSynthesisList(account, 1, 1, 3);
            typename = "senior";
        }
        if(types == 4){
            require(_superTotal <= 1000);
            burnNum = 7000 * 10**_decimals;
            _burn(address(this), burnNum);
            _superTotal += 1;
            _super[account] += 1;
            _updateSynthesisList(account, 1, 1, 4);
            typename = "super";
        }
        emit AdminSynthesis(account, typename);
        return true; 
    }
    
    function recovery(address account, uint256 types, uint256 amount) external onlyOwner returns(bool) {
        uint256 burnNum = 0;
        uint256 total = 0;
        string memory typename;
        if(types == 1){
            require(_primaryTotal >= amount);
            require(_primary[account] >= amount);
            burnNum = 1000 * 10**_decimals;
            total = amount.mul(burnNum);
            _rOwned[address(0)] = _rOwned[address(0)].sub(total);
            _rOwned[address(this)] = _rOwned[address(this)].add(total);
            _primaryTotal -= amount;
            _primary[account] -= amount;
            _updateSynthesisList(account, amount, 2, 1);
            typename = "primary";
        }
        if(types == 2){
            require(_intermediateTotal >= amount);
            require(_intermediate[account] >= amount);
            burnNum = 2000 * 10**_decimals;
            total = amount.mul(burnNum);
            _rOwned[address(0)] = _rOwned[address(0)].sub(total);
            _rOwned[address(this)] = _rOwned[address(this)].add(total);
            _intermediateTotal -= amount;
            _intermediate[account] -= amount;
            _updateSynthesisList(account, amount, 2, 2);
            typename = "intermediate";
        }
        if(types == 3){
            require(_seniorTotal >= amount);
            require(_senior[account] >= amount);
            burnNum = 4000 * 10**_decimals;
            total = amount.mul(burnNum);
            _rOwned[address(0)] = _rOwned[address(0)].sub(total);
            _rOwned[address(this)] = _rOwned[address(this)].add(total);
            _seniorTotal -= amount;
            _senior[account] -= amount;
            _updateSynthesisList(account, amount, 2, 3);
            typename = "senior";
        }
        if(types == 4){
            require(_superTotal >= amount);
            require(_super[account] >= amount);
            burnNum = 7000 * 10**_decimals;
            total = amount.mul(burnNum);
            _rOwned[address(0)] = _rOwned[address(0)].sub(total);
            _rOwned[address(this)] = _rOwned[address(this)].add(total);
            _superTotal -= amount;
            _super[account] -= amount;
            _updateSynthesisList(account, amount, 2, 4);
            typename = "super";
        }
        emit Recovery(account, typename, amount);
        return true; 
    }
    
    function _updateSynthesisList(address account, uint256 amount, uint256 status, uint256 typeNum) private {
        _numSynthesisList[account] += 1;
        _synthesisListNum[account][_numSynthesisList[account]] = amount;
        _synthesisListTime[account][_numSynthesisList[account]] = block.timestamp;
        _synthesisListStatus[account][_numSynthesisList[account]] = status; 
        _synthesisListType[account][_numSynthesisList[account]] = typeNum;
    }
    
    function synthesisList(address owner)
        public
        view
        returns(
            uint256[] memory synthesis_List_Num, 
            uint256[] memory synthesis_List_Time, 
            uint256[] memory synthesis_List_Status, 
            uint256[] memory synthesis_List_Type
        )
    {
        uint256 num = _numSynthesisList[owner];

        synthesis_List_Num = new uint256[](num);
        synthesis_List_Time = new uint256[](num);
        synthesis_List_Status = new uint256[](num);
        synthesis_List_Type = new uint256[](num);
        
		for(uint256 i =1; i<=num; i++){
            synthesis_List_Num[i-1] = _synthesisListNum[owner][i];
            synthesis_List_Time[i-1] =  _synthesisListTime[owner][i];
            synthesis_List_Status[i-1] = _synthesisListStatus[owner][i];
            synthesis_List_Type[i-1] = _synthesisListType[owner][i];
        }

        return (synthesis_List_Num, synthesis_List_Time, synthesis_List_Status, synthesis_List_Type);
    }
    
    function distribution(address account) external onlyOwner returns(bool) {
        require(_superTemp > 0);
        _superTemp -= 1;
        _super[account] += 1;
        _updateSynthesisList(account, 1, 0, 4);
        emit Distribution(account, 1);
        return true;
    }

    function withdrawToken(IERC20 token, address to, uint256 value)external onlyOwner returns(bool) {
        token.safeTransfer(to, value);
        return true;
    }  
}