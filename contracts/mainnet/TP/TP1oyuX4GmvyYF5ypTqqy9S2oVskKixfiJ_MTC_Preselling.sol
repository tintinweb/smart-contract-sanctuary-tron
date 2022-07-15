//SourceUnit: presellingwithbonus.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface TRC20 {
    
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
}

contract MYTRONCLUB {

    struct User {
        address referrer;
        uint256 expiration;
        uint256 cyclecount;
    }

    mapping(address => User) public users;
}

contract MTC_Preselling {
    address public MTC_CONTRACT_ADDRESS;
    address public USDT_CONTRACT_ADDRESS;
    address public MAIN_CONTRACT_ADDRESS;
    address public owner;
    
    bool public active = true;
    bool public openToPublic = false;
    bool public bonusEnabled = false;
    
    uint256 public trxToMtc;
    uint256 public usdtToMtc;
    uint256 public commissionRate;
    uint256 public tokenCommissionRate;
    uint256 public maxPurchase;
    
    mapping(address => uint256) public totalPurchase;
    
    TRC20 internal mtc20;
    MYTRONCLUB internal mtcClub;
    TRC20 internal usdt20;
    
    constructor(address _owner, address club_address, address mtc_address, address usdt_address, uint256 trxRate, uint256 usdtRate, uint256 _commissionRate, uint256 _tokenCommissionRate, uint256 _maxPurchase) {
        
        MAIN_CONTRACT_ADDRESS = club_address;
        MTC_CONTRACT_ADDRESS = mtc_address;
        USDT_CONTRACT_ADDRESS = usdt_address;
        owner = _owner;
        
        trxToMtc = trxRate;
        usdtToMtc = usdtRate;
        commissionRate = _commissionRate;
        tokenCommissionRate = _tokenCommissionRate;
        maxPurchase = _maxPurchase;
        
        mtc20 = TRC20(MTC_CONTRACT_ADDRESS);
        mtcClub = MYTRONCLUB(MAIN_CONTRACT_ADDRESS);
        usdt20 = TRC20(USDT_CONTRACT_ADDRESS);
    }
    
    function setActive(bool isActive) public returns (bool) {
        require(msg.sender == owner);
        active = isActive;
        return true;
    }

    function setBonusEnabled(bool bon) public returns (bool) {
        require(msg.sender == owner);
        bonusEnabled = bon;
        return true;
    }
    
    function setMaxPurchase(uint256 max) public returns (bool) {
        require(msg.sender == owner);
        maxPurchase = max;
        return true;
    }
    
    function setPublic(bool isActive) public returns (bool) {
        require(msg.sender == owner);
        openToPublic = isActive;
        return true;
    }
    
    function setTrxRate(uint256 rate) public returns (bool) {
        require(msg.sender == owner);
        trxToMtc = rate;
        return true;
    }
    
    function setUsdtRate(uint256 rate) public returns (bool) {
        require(msg.sender == owner);
        usdtToMtc = rate;
        return true;
    }
    
    function setTokenCommissionRate(uint256 rate) public returns (bool) {
        require(msg.sender == owner);
        tokenCommissionRate = rate;
        return true;
    }
    
    function setCommissionRate(uint256 rate) public returns (bool) {
        require(msg.sender == owner);
        require(rate <= 100);
        require(rate >= 0);
        commissionRate = rate;
        return true;
    }

    function setAddress(uint256 n, address addr) public returns (bool) {
        require(msg.sender == owner);
        if(n == 0) {
            USDT_CONTRACT_ADDRESS = addr;
            usdt20 = TRC20(USDT_CONTRACT_ADDRESS);
        }
        else if(n == 1) {
            MTC_CONTRACT_ADDRESS = addr;
            mtc20 = TRC20(MTC_CONTRACT_ADDRESS);
        }
        else if(n == 2) {
            MAIN_CONTRACT_ADDRESS = addr;
            mtcClub = MYTRONCLUB(MAIN_CONTRACT_ADDRESS);
        }
        return true;
    }
    
    function getBonus(address referrer) public view returns (uint256) {
        uint256 bonus = 0;
        if(bonusEnabled) {
            if(totalPurchase[msg.sender] > 0) {
                if(referrer == owner) {
                    bonus = 6500000;
                }
                else {
                    bonus = 9100000;
                }
            }
            else if(referrer == owner) {
                bonus = 15000000;
            }
            else {
                bonus = 17500000;
            }
        }
        return bonus;
    }
    
    function buy(address referrer) public payable returns (bool) {
        require(active, "Selling is inactive");

        uint256 mtcAmount = trxToMtc * msg.value;

        uint256 bonus = getBonus(referrer);

        mtcAmount += trxToMtc * bonus;

        require(msg.value >= 99000000 - bonus, "The minimum exchange is 100TRX.");

        require(maxPurchase >= mtcAmount + totalPurchase[msg.sender], "Amount exceeds the max purchase.");
        require(mtc20.balanceOf(address(this)) >= mtcAmount, "The contract doesn't have enough MTC Token to do this transaction.");
        
        if(openToPublic == false) {
            (address clubReferrer, uint256 expiration, ) = mtcClub.users(msg.sender);
            require(expiration > block.timestamp, "Only members can buy MTC Token for now.");
            referrer = clubReferrer;
        }
        else if(referrer != owner) {
            (, uint256 refExpiration, ) = mtcClub.users(referrer);
            if(refExpiration < block.timestamp) {
                if(tokenCommissionRate > 0) mtc20.transfer(referrer, mtcAmount / 100 * tokenCommissionRate);
                referrer = owner;
            }
        }
        
        mtc20.transfer(msg.sender, mtcAmount);
        totalPurchase[msg.sender] += mtcAmount;
        
        if(referrer != owner && commissionRate > 0) payable(address(uint160(referrer))).transfer(msg.value / 100 * commissionRate);
        
        emit Purchase(msg.sender, referrer, mtcAmount);
        
        return true;
    }
    
    function buyWithUSDT(address referrer) public returns (bool) {
        require(active, "Selling is inactive");
        
        uint256 amount = usdt20.allowance(msg.sender, address(this));
        
        uint256 bonus = getBonus(referrer);

        require(amount >= 99000000 - (bonus * trxToMtc / usdtToMtc), "The minimum exchange is 10USDT.");
        
        uint256 mtcAmount = usdtToMtc * amount;
        
        mtcAmount += trxToMtc * bonus;

        require(maxPurchase >= mtcAmount + totalPurchase[msg.sender], "Amount exceeds the max purchase.");
        
        require(usdt20.balanceOf(msg.sender) >= amount, "Insufficient Sender Balance.");
        require(mtc20.balanceOf(address(this)) >= mtcAmount, "The contract doesn't have enough MTC Token to do this transaction.");
        
        (address clubReferrer, uint256 expiration, ) = mtcClub.users(msg.sender);
        if(openToPublic == false) {
            require(expiration > block.timestamp, "Only members can buy MTC Token for now.");
            referrer = clubReferrer;
        }
        else if(referrer != owner) {
            (, uint256 refExpiration, ) = mtcClub.users(referrer);
            if(refExpiration < block.timestamp) {
                if(tokenCommissionRate > 0) mtc20.transfer(referrer, mtcAmount / 100 * tokenCommissionRate);
                referrer = owner;
            }
        }
        
        if(referrer != owner && commissionRate > 0) {
            usdt20.transferFrom(msg.sender, owner, amount / 100 * (100 - commissionRate));
            usdt20.transferFrom(msg.sender, referrer, amount / 100 * commissionRate);
        }
        else {
            usdt20.transferFrom(msg.sender, owner, amount);
        }
        
        mtc20.transfer(msg.sender, mtcAmount);
        totalPurchase[msg.sender] += mtcAmount;
        
        emit Purchase(msg.sender, referrer, mtcAmount);
        
        return true;
    }
    
    function _collectTrx() public returns (bool) {
        require(msg.sender == owner);
        payable(address(uint160(owner))).transfer(address(this).balance);
        return true;
    }
    
    function _collectUsdt() public returns (bool) {
        require(msg.sender == owner);
        usdt20.transfer(owner, usdt20.balanceOf(address(this)));
        
        return true;
    }
    
    function returnTokenFunds() public returns (bool) {
        require(owner == msg.sender);
        mtc20.transfer(msg.sender, mtc20.balanceOf(address(this)));
        return true;
    }
    
    event Purchase(address indexed buyer, address indexed seller, uint256 value);
}