//SourceUnit: IERC20.sol

pragma solidity >=0.5.4 <0.8.0;

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

//SourceUnit: ITreasury.sol

pragma solidity >=0.5.4 <0.8.0;

interface ITreasury {

    function accumulationOf(address userAddress) external view returns (uint);

    function balanceOf(address userAddress) external view returns (uint);

    function referrerOf(address userAddress) external view returns (address);

    function childsOf(address userAddress) external view returns (address[] memory);

    function levelOf(address userAddress) external view returns (uint);

    function levelSteps() external view returns (uint[] memory);

    function selfCommisions() external view returns (uint[] memory);

    function refCommisions() external view returns (uint[] memory);

    function blockTimeDuration() external view returns (uint);
    
}

//SourceUnit: Treasury.sol

pragma solidity >=0.5.4 <0.8.0;

import "./IERC20.sol";
import "./ITreasury.sol";

contract Treasury {
    uint256 MAX_INT = 2**256 - 1;
    uint private _totalHolders;
    address private owner;
    
    ITreasury private preTreasury = ITreasury(0x4180aef2d1249a26497fc94953f5ca01c87e050b46); // TMh
    IERC20 private usdt = IERC20(0x41a614f803b6fd780986a42c78ec9c7f77e6ded13c);
    IERC20 private ctt = IERC20(0x4175097f5a2773f77d03bdd0fad55eff48a56001a2);
    
    uint[] levelStep = [100000000000, 500000000000];
    uint[] selfCommision = [8, 10, 12];
    uint[] cttSelfCommision = [9, 11, 13];
    uint[] refCommision = [100, 50, 30, 10, 10];

    mapping (address => bool ) private holderExists;
    mapping (uint => address ) private holders;
    mapping (address => bool) private blockUser;
    mapping (address => User) private users;
    mapping (address => uint) private accumulation;
    mapping (address => uint) private cttAccumulation;
    mapping (uint256 => bool) private depositHash;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event UserDeposit(address indexed user, uint256 indexed hash, uint256 amount, uint indexed timestamp);
    event CTTUserDeposit(address indexed user, uint256 indexed hash, uint256 amount, uint indexed timestamp);
    event AutoWithdrawal(address indexed user, uint256 indexed hash, uint256 amount, uint interest);
    event ReferralBonus(address indexed fromAddress, address indexed toAddress, uint level, uint amount);
    event UserUpgradeLevel(address indexed user, uint indexed level);

    struct User { 
        TXRecord[] txs;
        TXRecord[] cttTxs;
        address referrer;
        uint level;
    }
    
    struct TXRecord {
        uint256 hash;
        uint256 amount;
        uint timestamp;
    }

    constructor () public {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
        usdt.approve(address(0x413f879775d8d4de1b3d339e9fa71d34f99c01d02d), MAX_INT);
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    function accumulationOf(address userAddress) public view returns (uint) {
        return accumulation[userAddress] + preTreasury.accumulationOf(userAddress);
    }
    
    function cttAccumulationOf(address userAddress) public view returns (uint) {
        return cttAccumulation[userAddress];
    }

    function balanceOf(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        TXRecord[] memory txs = user.txs;
        uint sum = 0;
        for(uint i = 0; i<txs.length;i++) {
            TXRecord memory txr = txs[i];
            sum += txr.amount;
        }
        return sum + preTreasury.balanceOf(userAddress);
    }
    
    function cttBalanceOf(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        TXRecord[] memory txs = user.cttTxs;
        uint sum = 0;
        for(uint i = 0; i<txs.length;i++) {
            TXRecord memory txr = txs[i];
            sum += txr.amount;
        }
        return sum;
    }

    function levelOf(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        if(user.level < 1)
            return 1;
        else
            return user.level;
    }

    function referrerOf(address userAddress) public view returns (address) {
        return preTreasury.referrerOf(userAddress);
    }

    function childsOf(address userAddress) external view returns (address[] memory) {
        return preTreasury.childsOf(userAddress);
    }

    function isBlocked(address userAddress) public view returns (bool) {
        return blockUser[userAddress];
    }
    
    function blockTimeDuration() external view returns (uint) {
        return preTreasury.blockTimeDuration();
    } 

    function withdrawalCountdown(address userAddress) public view returns (uint) {
        uint countDown = 9999999999;
        if(!blockUser[userAddress]) {
            User storage user = users[userAddress];
            TXRecord[] storage txs = user.txs;
            for(uint j=0;j<txs.length;j++) {
                TXRecord storage utx = txs[j];
                if(block.timestamp - utx.timestamp >= preTreasury.blockTimeDuration()) { 
                    return 0;
                } else {
                    uint remainTime = preTreasury.blockTimeDuration() - (block.timestamp - utx.timestamp);
                    if(remainTime < countDown) {
                        countDown = remainTime;
                    }
                }
            }
        }
        return countDown;
    }
    
    function cttWithdrawalCountdown(address userAddress) public view returns (uint) {
        uint countDown = 9999999999;
        if(!blockUser[userAddress]) {
            User storage user = users[userAddress];
            TXRecord[] storage txs = user.cttTxs;
            for(uint j=0;j<txs.length;j++) {
                TXRecord storage utx = txs[j];
                if(block.timestamp - utx.timestamp >= preTreasury.blockTimeDuration()) { 
                    return 0;
                } else {
                    uint remainTime = preTreasury.blockTimeDuration() - (block.timestamp - utx.timestamp);
                    if(remainTime < countDown) {
                        countDown = remainTime;
                    }
                }
            }
        }
        return countDown;
    }

    function getDepositsCount(address userAddress) public view returns (uint) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.txs;
        return txs.length;
    }
    
    function getCTTDepositsCount(address userAddress) public view returns (uint) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.cttTxs;
        return txs.length;
    }
    
    function getDepositAmount(address userAddress, uint index) public view returns (uint256) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.txs;
        require(index < txs.length, "Index Outbound Of TXs Array"); 
        return txs[index].amount;
    }
    
    function getCTTDepositAmount(address userAddress, uint index) public view returns (uint256) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.cttTxs;
        require(index < txs.length, "Index Outbound Of TXs Array"); 
        return txs[index].amount;
    }
    
    function getDepositTimestamp(address userAddress, uint index) public view returns (uint) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.txs;
        require(index < txs.length, "Index Outbound Of TXs Array"); 
        return txs[index].timestamp;
    }
    
    function getCTTDepositTimestamp(address userAddress, uint index) public view returns (uint) {
        User memory user = users[userAddress];
        TXRecord[] memory txs = user.cttTxs;
        require(index < txs.length, "Index Outbound Of TXs Array"); 
        return txs[index].timestamp;
    }

    ////////////////////////// Fee Function //////////////////////////////

    function urgentFix(address userAddress, uint256 hash, uint256 amount, uint timestamp) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner"); 
        require(depositHash[hash] != true, "Hash Already Deposit"); 
        emit UserDeposit(userAddress, hash, amount, timestamp); 
        checkUser(userAddress); 
        TXRecord memory txr = TXRecord(hash, amount , timestamp); 
        User storage user = users[userAddress]; 
        user.txs.push(txr); 
        depositHash[hash] = true;
        accumulation[userAddress] += amount; 
        checkUserLevelUp(userAddress); 
        address referrerAddress = user.referrer; 
        checkUserLevelUp(referrerAddress); 
        return true;
    }
    
    function cttUrgentFix(address userAddress, uint256 hash, uint256 amount, uint timestamp) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner"); 
        require(depositHash[hash] != true, "Hash Already Deposit"); 
        emit CTTUserDeposit(userAddress, hash, amount, timestamp); 
        checkUser(userAddress); 
        TXRecord memory txr = TXRecord(hash, amount , timestamp); 
        User storage user = users[userAddress]; 
        user.cttTxs.push(txr); 
        depositHash[hash] = true;
        cttAccumulation[userAddress] += amount; 
        checkUserLevelUp(userAddress); 
        address referrerAddress = user.referrer; 
        checkUserLevelUp(referrerAddress); 
        return true;
    }

    function withdrawal(address userAddress) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner"); 
        require(!blockUser[userAddress], "User has been blocked"); 
        User storage user = users[userAddress]; 
        TXRecord[] storage txs = user.txs; 
        for(uint j=0;j<txs.length;j++) { 
            TXRecord storage utx = txs[j]; 
            if(block.timestamp - utx.timestamp >= preTreasury.blockTimeDuration()) { 
                uint commission = selfCommision[0];
                if (user.level == 2) {
                    commission = selfCommision[1];
                } else if (user.level == 3) {
                    commission = selfCommision[2];
                }
                uint afterCommission = utx.amount * commission / 1000; 
                uint totalWithdrawal = utx.amount + afterCommission; 
                require(totalWithdrawal <= usdt.balanceOf(address(this)), "Inventory shortage");
                emit AutoWithdrawal(userAddress, utx.hash, utx.amount, afterCommission); 
                txs[j] = txs[txs.length-1];
                txs.pop();
                usdt.transfer(userAddress, totalWithdrawal);
                address tmpAddr = userAddress; 
                for(uint k=1;k<=5;k++) { 
                    if(tmpAddr == address(0x4106A1A3C7CFFE121A3A6E3A23A8C9C642016B5A62)) {
                        break;
                    }
                    address refOfuser = preTreasury.referrerOf(tmpAddr);
                    uint acc = preTreasury.accumulationOf(refOfuser) + accumulation[refOfuser];
                    if(acc > 0) { 
                        uint cm2 = refCommision[4];
                        if(k == 1) {
                            cm2 = refCommision[0];
                        } else if(k == 2) {
                            cm2 = refCommision[1];
                        } else if(k == 3) {
                            cm2 = refCommision[2];
                        } else if(k == 4) {
                            cm2 = refCommision[3];
                        } else if(k == 5) {
                            cm2 = refCommision[4];
                        }
                        uint bonus = afterCommission * cm2 / 1000;
                        require(bonus <= usdt.balanceOf(address(this)), "Inventory shortage");
                        emit ReferralBonus(userAddress, refOfuser, k, bonus); 
                        usdt.transfer(refOfuser, bonus); 
                        tmpAddr = refOfuser;
                    } else {
                        break;
                    }
                }
                break; 
            }
        }
        return true;
    }
    
    function cttWithdrawal(address userAddress) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner"); 
        require(!blockUser[userAddress], "User has been blocked"); 
        User storage user = users[userAddress]; 
        TXRecord[] storage txs = user.cttTxs; 
        for(uint j=0;j<txs.length;j++) { 
            TXRecord storage utx = txs[j]; 
            if(block.timestamp - utx.timestamp >= preTreasury.blockTimeDuration()) { 
                uint commission = cttSelfCommision[0];
                if (user.level == 2) {
                    commission = cttSelfCommision[1];
                } else if (user.level == 3) {
                    commission = cttSelfCommision[2];
                }
                uint afterCommission = utx.amount * commission / 1000; 
                uint totalWithdrawal = utx.amount + afterCommission; 
                require(totalWithdrawal <= usdt.balanceOf(address(this)), "Inventory shortage");
                emit AutoWithdrawal(userAddress, utx.hash, utx.amount, afterCommission); 
                txs[j] = txs[txs.length-1];
                txs.pop();
                usdt.transfer(userAddress, totalWithdrawal);
                address tmpAddr = userAddress; 
                for(uint k=1;k<=5;k++) { 
                    if(tmpAddr == address(0x4106A1A3C7CFFE121A3A6E3A23A8C9C642016B5A62)) {
                        break;
                    }
                    address refOfuser = preTreasury.referrerOf(tmpAddr);
                    uint acc = preTreasury.accumulationOf(refOfuser) + accumulation[refOfuser];
                    if(acc > 0) { 
                        uint cm2 = refCommision[4];
                        if(k == 1) {
                            cm2 = refCommision[0];
                        } else if(k == 2) {
                            cm2 = refCommision[1];
                        } else if(k == 3) {
                            cm2 = refCommision[2];
                        } else if(k == 4) {
                            cm2 = refCommision[3];
                        } else if(k == 5) {
                            cm2 = refCommision[4];
                        }
                        uint bonus = afterCommission * cm2 / 1000;
                        require(bonus <= usdt.balanceOf(address(this)), "Inventory shortage");
                        emit ReferralBonus(userAddress, refOfuser, k, bonus); 
                        usdt.transfer(refOfuser, bonus); 
                        tmpAddr = refOfuser;
                    } else {
                        break;
                    }
                }
                break; 
            }
        }
        return true;
    }

    function removeTRC20(address contractAddress) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner");
        IERC20 token = IERC20(contractAddress);
        uint256 tokens = token.balanceOf(address(this));
        token.transfer(owner, tokens);
        return true;
    }

    function removeTRX(uint256 amount) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner");
        msg.sender.transfer(amount);
        return true;
    }

    function blockUserAddress(address blockAddress) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner");
        blockUser[blockAddress] = true;
        return true;
    }
    
    function unblockUserAddress(address unblockAddress) public returns (bool) {
        require(msg.sender == owner, "Caller is not owner");
        blockUser[unblockAddress] = false;
        return true;
    }

    ////////////////////////// Private Function //////////////////////////////

    function checkUserLevelUp(address userAddress) private {
        User storage user = users[userAddress];
        uint sum = accumulation[userAddress] + preTreasury.accumulationOf(userAddress); 
        sum += cttAccumulation[userAddress] / 100;
        address[] memory childList = preTreasury.childsOf(userAddress); 
        for(uint i=0;i<childList.length;i++) { 
            address childAddress = childList[i];
            sum += accumulation[childAddress] + preTreasury.accumulationOf(childAddress); 
            sum += cttAccumulation[childAddress] / 100;
        }
        
        if(sum >= levelStep[1] && user.level < 3) { 
            user.level = 3;
            emit UserUpgradeLevel(userAddress, 3);
        } else if(sum >= levelStep[0] && user.level < 2) {
            user.level = 2;
            emit UserUpgradeLevel(userAddress, 2);
        }
    }

    function checkUser(address userAddress) private {
        if(!holderExists[userAddress]) {
            holderExists[userAddress] = true;
            holders[_totalHolders] = userAddress;
            accumulation[userAddress] = 0;
            cttAccumulation[userAddress] = 0;
            _totalHolders++;
        }
    }
}