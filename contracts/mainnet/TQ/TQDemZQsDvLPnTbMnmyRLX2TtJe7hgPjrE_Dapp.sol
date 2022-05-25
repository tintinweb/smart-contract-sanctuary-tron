//SourceUnit: Basic.sol

pragma solidity 0.5.10;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    constructor() public {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner, 'erronlyOwnererr');
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    uint public _totalSupply;
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is Ownable, ERC20Basic {
    using SafeMath for uint;
    mapping(address => uint) public balances;

    // additional variables for use if transaction fees ever became necessary
    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(!(msg.data.length < size + 4));
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(msg.sender, owner, fee);
        }
        emit Transfer(msg.sender, _to, sendAmount);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based oncode by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint the amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
        uint _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // if (_value > _allowance) throw;

        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            emit Transfer(_from, owner, fee);
        }
        emit Transfer(_from, _to, sendAmount);
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    /**
    * @dev Function to check the amount of tokens than an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        return allowed[_owner][_spender];
    }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

contract BlackList is Ownable, BasicToken {

    /////// Getters to allow the same blacklist to be used also by other contracts (including upgraded Tether) ///////
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

contract UpgradedStandardToken is StandardToken{
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    function transferByLegacy(address from, address to, uint value) public;
    function transferFromByLegacy(address sender, address from, address spender, uint value) public;
    function approveByLegacy(address from, address spender, uint value) public;
}

contract addrTool {
    function addressToString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '4';
        str[1] = '1';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }
}

contract burnAble {
    event Burn(address indexed from, uint256 value);
}


//SourceUnit: Dapp.sol

pragma solidity 0.5.10;

// pragma experimental ABIEncoderV2;

import "./Basic.sol";
import "./DataStorage.sol";
import "./DataStorageOp.sol";
import "./TetherToken.sol";

contract Dapp is DataStorageOp {
    using SafeMath for uint;

    constructor() public {
        // init();
    }

    function init() public {
        if(sysUint['init'] == 1) {
            return;
        }
        //初始化标记
        sysUint['init'] = 1;
        //初始化时间
        sysUint['init_time'] = now;

        sysUint['minInvest'] = 100 * 1e6;
        sysUint['firstMax'] = 2000 * 1e6;
        sysUint['maxInvest'] = 2000 * 1e6;
      
        sysUint['platformFee0'] = 40;
        sysUint['platformFee1'] = 30;
       
        sysUint['feeBase'] = 1000;
        
        sysUint['fee'] = 0;

        sysAddress['fee0'] = address(0x4147a24cb5c2021faaafae580c1162b17248ffb81d);

        sysAddress['fee1'] = address(0x417555f6201346f0bf61922240576fed2d8c45548b);
        //prod
        sysAddress['usdt'] = address(0x41a614f803b6fd780986a42c78ec9c7f77e6ded13c);
        //shasta
        // sysAddress['usdt'] = address(0x417f770ab42a5d2f5967b6795883d7f6c17bf8a232);

        sysUint['maxDep'] = 6;
        
        //dev
        // sysUintUint['roundMain'][0] = 15 * 60;
        // sysUintUint['roundMain'][1] = 7 * 60;

        //prod
        sysUintUint['roundMain'][0] = 15 days;
        sysUintUint['roundMain'][1] = 7 days;

        sysUintUint['roundRate'][0] = 12 * 15;
        sysUintUint['roundRate'][1] = 8 * 7;
    
        sysUintArray['rate'] = [50,30,10,10,10,10];

        sysUint['maxId'] = 1;

        sysUint['mainSum'] = 0;
    }

    function pendingAward(address addr) view public returns (uint) {
        uint last_type = userStringUint[addr]['type'];
        uint time_now = now;
        if(now - userStringUint[msg.sender]['start'] > sysUintUint['roundMain'][last_type] ) {
            time_now = userStringUint[msg.sender]['start'] + sysUintUint['roundMain'][last_type];
        }
        uint income = userStringUint[addr]['invest'] * sysUintUint['roundRate'][last_type] / sysUint['feeBase'] * ( time_now - userStringUint[msg.sender]['start'] ) / sysUintUint['roundMain'][last_type];
        return income;
    }

    function invest(address payable referrer, uint _value, uint _type) public payable {
        //帮助类型限制
        require(_type <= 1, 'errtypeerr');
        //最低投资额限制
        require(_value >= sysUint['minInvest'], 'errmin value 100err');
        //最大投资限制
        require(_value <= sysUint['maxInvest'], 'errmax valueerr');
        //10的整数倍
        require(_value / 10000000 * 10000000 == _value, 'errvalue10err');

        TetherToken usdt = TetherToken(sysAddress['usdt']);
        //usdt授权
        require(usdt.allowance(msg.sender, address(this)) >= _value , 'errusdtallowerr');
        //usdt余额充足
        require(usdt.balanceOf(msg.sender) >= _value, 'errusdtInsufficienterr');
       
        //接受usdt
        usdt.transferFrom(msg.sender, address(this), _value);
        //平台费
        usdt.transfer(sysAddress['fee0'], _value * sysUint['platformFee0'] / sysUint['feeBase']);
        sysUint['fee0'] += _value * sysUint['platformFee0'] / sysUint['feeBase'];
        usdt.transfer(sysAddress['fee1'], _value * sysUint['platformFee1'] / sysUint['feeBase']);
        sysUint['fee1'] += _value * sysUint['platformFee1'] / sysUint['feeBase'];
        
        //初次投入
        if( userStringUint[msg.sender]['invest'] == 0 ) {
            require(referrer != msg.sender, 'erruplineerr');
            //推荐人投入必须大于 0
            require(userStringUint[referrer]['invest'] > 0 || referrer == owner, 'errupline not existerr');

            userStringAddress[msg.sender]['referrer'] = referrer;
            userStringUint[msg.sender]['investCount'] = 1;
            userStringUint[msg.sender]['id'] = sysUint['maxId'];
            userStringUint[msg.sender]['joinTime'] = now;

            sysUintAddress['idToAddress'][sysUint['maxId']] = msg.sender;

            sysUint['maxId']++;

            //推荐人数
            userStringUint[referrer]['count'] += 1;
            userStringUint[msg.sender]['count'] = 0;

            //推荐关系
            userStringAddressArray[referrer]['childs'].push(msg.sender);
        }else{
            uint last_type = userStringUint[msg.sender]['type'];
            // 到期复投
            require(userStringUint[msg.sender]['start'] + sysUintUint['roundMain'][last_type] <= now, 'errtimelimiterr');
            //复投限制
            require(_value >= userStringUint[msg.sender]['invest'], 'errmust big then lasterr');
            //复投 结算上期进可提现
            uint income = userStringUint[msg.sender]['invest'] * sysUintUint['roundRate'][last_type] / sysUint['feeBase'];
            
            userStringUint[msg.sender]['canwithdraw'] += userStringUint[msg.sender]['invest'] + income;
            
            // 总静态收益
            userStringUint[msg.sender]['staticsum'] += income;
            //投入总数
            userStringUint[msg.sender]['investCount']++; 
        }
        userStringUint[msg.sender]['invest'] = _value;
        // 总投入
        userStringUint[msg.sender]['investsum'] += userStringUint[msg.sender]['invest'];
        //推荐奖
        doAward(msg.sender, userStringAddress[msg.sender]['referrer'], 0, _type);
        userStringUint[msg.sender]['start'] = now;
        userStringUint[msg.sender]['type'] = _type;
                
        userStringUintArray[msg.sender]['his_time'].push(now);
        userStringUintArray[msg.sender]['his_type'].push(_type);
        userStringUintArray[msg.sender]['his_invest'].push(_value);
        sysUint['mainSum'] += _value;
    }

    function doAward(address addr, address referrer, uint dep, uint _type) private {
        //最大深度限制
        if(dep < sysUint['maxDep']) {
            //推广几人拿几代
            if(userStringUint[referrer]['count'] > dep) {
                uint invest_tmp = userStringUint[addr]['invest'];
                //烧伤
                if(userStringUint[addr]['invest'] > userStringUint[referrer]['invest']) {
                    invest_tmp = userStringUint[referrer]['invest'];
                }

                uint award_tmp = invest_tmp * sysUintArray['rate'][dep] / sysUint['feeBase'];

                TetherToken usdt = TetherToken(sysAddress['usdt']);
                usdt.transfer(referrer, award_tmp);

                userStringUint[referrer]['awardsum'] += award_tmp;
                userStringUint[referrer]['dynamic'] += award_tmp;
            }

            if(userStringAddress[referrer]['referrer'] != address(0) && userStringAddress[referrer]['referrer'] != owner) {
                doAward(addr, userStringAddress[referrer]['referrer'], dep + 1, _type);
            }
        }
    }
    
    function withdraw() public {
        TetherToken usdt = TetherToken(sysAddress['usdt']);
        uint can_tmp = 0;

        //普通提现
        require(userStringUint[msg.sender]['canwithdraw'] > 0, 'errcanwithdraw must > 0err');
        require(usdt.balanceOf(address(this)) > 0, 'errdappUsdtInsufficienterr');
        can_tmp = userStringUint[msg.sender]['canwithdraw'];
        if(can_tmp > usdt.balanceOf(address(this)) ) {
            can_tmp = usdt.balanceOf(address(this));
            userStringUint[msg.sender]['canwithdraw'] = userStringUint[msg.sender]['canwithdraw'] - can_tmp;
        }else{
            userStringUint[msg.sender]['canwithdraw'] = 0;
        }

        //已提总数
        userStringUint[msg.sender]['take'] += can_tmp;

        usdt.transfer(msg.sender, can_tmp);
    }
}


//SourceUnit: DataStorage.sol

 
pragma solidity 0.5.10;

import "./Basic.sol";

contract DataStorage is Ownable {
    //被代理的业务合约地址
    address internal proxied;

    mapping(string => uint) public sysUint;
    mapping(string => bool) public sysBool;
    mapping(string => address payable) public sysAddress;
    mapping(string => uint[]) public sysUintArray;
    mapping(string => address payable []) public sysAddressArray;
    mapping(string => mapping(uint => address payable)) public sysUintAddress;
    mapping(string => mapping(uint => uint)) public sysUintUint;
    mapping(string => mapping(address => uint)) public sysAddressUint;

    mapping(address => mapping(string => uint)) public userStringUint;
    mapping(address => mapping(string => uint[])) public userStringUintArray;
    mapping(address => mapping(string => address payable)) public userStringAddress;
    mapping(address => mapping(string => address payable [])) public userStringAddressArray;
}

//SourceUnit: DataStorageOp.sol

 
pragma solidity 0.5.10;

import "./Basic.sol";
import "./DataStorage.sol";

contract DataStorageOp is DataStorage {

    modifier onlyOwner() {
        require(msg.sender == owner, "errOwnable: caller is not the ownererr");
        _;
    }

    modifier onlyKeeper() {
        require(sysAddressUint['keeper'][msg.sender] == 1, "errOwnable: caller is not keeper.err");
        _;
    }

    modifier onlyOwnerOrKeeper() {
        require(msg.sender == owner || sysAddressUint['keeper'][msg.sender] == 1, "errOwnable: caller is not the owner or keeper.err");
        _;
    }
}

//SourceUnit: Events.sol


pragma solidity 0.5.10;


contract Events {
  event Registration(address member, uint memberId, address sponsor, uint orderId);
  event Upgrade(address member, address sponsor, uint system, uint level, uint orderId);
}

//SourceUnit: Migrations.sol

pragma solidity ^0.5.10;

contract Migrations {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
}



//SourceUnit: Proxy.sol


pragma solidity 0.5.10;

import './DataStorage.sol';
import './Events.sol';

contract Proxy is DataStorage, Events {

  address private proxied = address(0);
  string public name;
  
  constructor(string memory _name) public {
    name = _name;
  }

  function () external payable {
    address proxy = proxied;
    assembly {
      calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), proxy, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 { revert(0, returndatasize()) }
        default { return(0, returndatasize()) }
    }
  }

  function setProxy(address _addr) external onlyOwner {
    proxied = _addr;
  }
}

//SourceUnit: TetherToken.sol

pragma solidity ^0.5.10;


contract TetherToken {
    function transfer(address _to, uint _value) public returns (bool);
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint);
    function balanceOf(address who) public view returns (uint);
}