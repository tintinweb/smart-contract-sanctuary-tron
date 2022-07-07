//SourceUnit: JTUToken_single.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SafeMath {

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

contract DateTime {

    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        }
        else if (isLeapYear(year)) {
            return 29;
        }
        else {
            return 28;
        }
    }

    function nextYearMonth(uint8 month, uint16 year) public pure returns(uint8, uint16) {
        uint8 nextMonth = month + 1;
        uint16 nextYear = year;
        if(nextMonth > 12) {
            nextYear += 1;
            nextMonth = 1;
        }
        return (nextMonth, nextYear);
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }

        // Hour
        dt.hour = getHour(timestamp);

        // Minute
        dt.minute = getMinute(timestamp);

        // Second
        dt.second = getSecond(timestamp);

        // Day of week.
        dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
        return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
        return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
        return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
        uint16 i;

        // Year
        for (i = ORIGIN_YEAR; i < year; i++) {
            if (isLeapYear(i)) {
                timestamp += LEAP_YEAR_IN_SECONDS;
            }
            else {
                timestamp += YEAR_IN_SECONDS;
            }
        }

        // Month
        uint8[12] memory monthDayCounts;
        monthDayCounts[0] = 31;
        if (isLeapYear(year)) {
            monthDayCounts[1] = 29;
        }
        else {
            monthDayCounts[1] = 28;
        }
        monthDayCounts[2] = 31;
        monthDayCounts[3] = 30;
        monthDayCounts[4] = 31;
        monthDayCounts[5] = 30;
        monthDayCounts[6] = 31;
        monthDayCounts[7] = 31;
        monthDayCounts[8] = 30;
        monthDayCounts[9] = 31;
        monthDayCounts[10] = 30;
        monthDayCounts[11] = 31;

        for (i = 1; i < month; i++) {
            timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
        }

        // Day
        timestamp += DAY_IN_SECONDS * (day - 1);

        // Hour
        timestamp += HOUR_IN_SECONDS * (hour);

        // Minute
        timestamp += MINUTE_IN_SECONDS * (minute);

        // Second
        timestamp += second;

        return timestamp;
    }

    function monthDiff(uint16 startYear, uint8 startMonth, uint16 endYear, uint8 endMonth) public pure returns (bool res, uint16 diff) {
        if(startYear == 0 || startMonth == 0 || endYear == 0 || endMonth == 0) {
            res = false;
            diff = 0;
        }else {
            if(endYear > startYear) {
                res = true;
                if(endMonth >= startMonth) {
                    diff = (endMonth - startMonth) + 12 * (endYear - startYear);
                } else {
                    diff = 12 * (endYear - startYear) - (startMonth - endMonth);
                }
            }else if(endYear == startYear) {
                if(endMonth >= startMonth) {
                    res = true;
                    diff = (endMonth - startMonth);
                } else {
                    res = false;
                    diff = 0;
                }
            } else {
                res = false;
                diff = 0;
            }
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract JTUTokenBase is Context, IERC20, IERC20Metadata, SafeMath, DateTime {

    address ownership;
    address airdropper;
    bool bVest = false;
    uint beginVestTime;
    uint createdTime;
    uint8 constant VEST_CLIPS = 12;

    mapping(address => uint256) private _normalBalances;
    mapping(address => uint256) private _vestAmounts;
    mapping(address => uint256) private _vestBalances;
    mapping(address => mapping(uint16 => bool)) _vestHistory;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _blackListSpender;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    event vested(address to, uint256 amount);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        ownership = _msgSender();
        createdTime = block.timestamp;
    }

    function transferOwnership(address to) external {
        require(msg.sender == ownership, "Only owner can transfer ownership");
        require(to != ownership, "Target account have been owner already");
        ownership = to;
    }

    function ownershipOfToken() external view returns (address) {
        return ownership;
    }

    function approveAirdropper(address to) external {
        require(_msgSender() == ownership, "Only owner can approve airdropper");
        require(to != airdropper, "Target account have been airdropper");
        airdropper = to;
    }

    function airdropperOfToken() external view returns (address) {
        return airdropper;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _normalBalances[account] + _vestBalances[account];
    }

    function withdrawableAmount(address account) public view returns (uint256) {
        return _normalBalances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        require(!_blackListSpender[spender], "Spender have been banned");

        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        (bool result, uint256 approveAmount) = tryAdd(allowance(owner, spender), addedValue);
        if(!result) {
            return false;
        }
        _approve(owner, spender, approveAmount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            (bool result, uint256 approveAmount) = trySub(currentAllowance, subtractedValue);
            if(!result) {
                return false;
            }
            _approve(owner, spender, approveAmount);
        }

        return true;
    }

    function setVestStatus(bool status) external {
        require(msg.sender == ownership, "Only owner can set vesting status");
        require(bVest != status, "set the same status error");
        bVest = status;
    }

    function setVestTime(uint timestamp) external {
        require(msg.sender == ownership, "Only owner can set vesting status");
        require(timestamp >= createdTime, "Vest time set error, can not be less then the contract created time");
        beginVestTime = timestamp;
    }

    function vest() external {
        require(_msgSender() != address(0), "ERC20: transfer from the zero address");
        require(_msgSender() != ownership, "Owner should not vest token");
        require(_msgSender() != airdropper, "Airdropper should not vest token");

        uint nowTimestamp = block.timestamp;

        require(bVest, "Token not vested yet");
        require(nowTimestamp > beginVestTime, "Vest time set error");

        require(_vestBalances[_msgSender()] > 0, "Have no token balance to vest");

        uint16 beginYear = beginVestTime > 0 ? getYear(beginVestTime) : 0;
        uint8 beginMonth = beginVestTime > 0 ? getMonth(beginVestTime) : 0;
        uint16 nowYear = getYear(nowTimestamp);
        uint8 nowMonth = getMonth(nowTimestamp);

        (bool mRes, uint16 diffMonth) = monthDiff(beginYear, beginMonth, nowYear, nowMonth);
        require(mRes, "Token not vested yet due to date");

        require(!_vestHistory[_msgSender()][diffMonth], "You have vested amounts this month");

        (bool ok, uint256 vestAmount) = _vest(diffMonth);

        if(!ok) {
            revert("vest error");
        }

        for(uint8 i = 0; i <= diffMonth; i ++){
            if(!_vestHistory[_msgSender()][i]){
                _vestHistory[_msgSender()][i] = true;
            }
        }

        emit vested(_msgSender(), vestAmount);
    }

    function vestableAmount(address account) external view returns (uint256) {
        return _vestBalances[account];
    } 

    function getVestNode(address account, uint8 monthIndex) external view returns (bool status, uint256 amount, uint256 percent, uint timestamp) {
        if(monthIndex > 11) {
            return (false, 0, 0, 0);
        } else {
            status = _vestHistory[account][monthIndex];
            amount = _getVestAmountOfMonth(account, monthIndex);
            percent = vestPercent(monthIndex);

            uint8 beginMonth = getMonth(beginVestTime);
            uint16 beginYear = getYear(beginVestTime);
            uint8 nextMonth = beginMonth;
            uint16 nextYear = beginYear;
            for(uint8 i = 0; i < monthIndex; i ++) {
                (nextMonth, nextYear) = nextYearMonth(nextMonth, nextYear);
            }

            timestamp = toTimestamp(nextYear, nextMonth, 1);  
        }  
    }

    function vestPercent(uint16 monthIndex) internal pure returns (uint256 percent) {
        if(monthIndex == 0) {
            return 1000;
        } else if (monthIndex == 1) {
            return 1500;
        } else if (monthIndex == 2) {
            return 2000;
        } else if (monthIndex == 3) {
            return 3000;
        } else if (monthIndex == 4) {
            return 4000;
        } else if (monthIndex == 5) {
            return 5500;
        } else if (monthIndex == 6) {
            return 7000;
        } else if (monthIndex == 7) {
            return 9000;
        } else if (monthIndex == 8) {
            return 11000;
        } else if (monthIndex == 9) {
            return 13500;
        } else if (monthIndex == 10) {
            return 17000;
        } else {
            return 100000;
        }
    }

    function vestStatus() external view returns (bool status, uint beginTime) {
        status = bVest;
        beginTime = beginVestTime;
    }

    function _vest(uint16 monthIndex) internal returns(bool res, uint256 vestAmount){

        uint256 releaseAmount = 0;

        for(uint16 i = 0; i <= monthIndex; i ++ ){
            if(!_vestHistory[_msgSender()][i]) {
                releaseAmount += _getVestAmountOfMonth(_msgSender(), i);
            }
        }
        
        if(releaseAmount > _vestBalances[_msgSender()]) {
            releaseAmount = _vestBalances[_msgSender()];
        }
        (bool resultV, uint256 vLeftBalance) = trySub(_vestBalances[_msgSender()], releaseAmount);
        if(resultV) {
            _vestBalances[_msgSender()] = vLeftBalance;
            (bool resultN, uint256 nLeftBalance) = tryAdd(_normalBalances[_msgSender()], releaseAmount);
            if(resultN) {
                _normalBalances[_msgSender()] = nLeftBalance;
                res = true;
                vestAmount = releaseAmount;
            }
        }
    }

    function _getVestAmountOfMonth(address account, uint16 monthIndex) internal view returns (uint256 vestAmount) {
        uint256 percent = vestPercent(monthIndex);
        vestAmount = _vestAmounts[account] * percent / 100000;
        if(vestAmount > _vestBalances[account]) {
            vestAmount = _vestBalances[account];
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint nowTimestamp = block.timestamp;
        uint16 beginYear = beginVestTime > 0 ? getYear(beginVestTime) : 0;
        uint8 beginMonth = beginVestTime > 0 ? getMonth(beginVestTime) : 0;
        uint16 nowYear = getYear(nowTimestamp);
        uint8 nowMonth = getMonth(nowTimestamp);
        
        (bool mRes, uint16 diffMonth) = monthDiff(beginYear, beginMonth, nowYear, nowMonth);
        
        if(!bVest && !mRes && diffMonth >= 0 && airdropper == from) {
            _transferToVest(from, to, amount);
        } else {
            _transferToNormal(from, to, amount);
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _transferToVest(
        address from, 
        address to,
        uint256 amount
    ) internal {
        require(from == airdropper, "Only owner can transfer token to vest account");
        uint256 airdropperBalance = _normalBalances[airdropper];
        require(airdropperBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            (bool resultFrom, uint256 leftBalance) = trySub(airdropperBalance, amount);
            if(resultFrom) {
                _normalBalances[airdropper] = leftBalance;
            }
        }

        (bool resultTo, uint256 toBalance) = tryAdd(_vestBalances[to], amount);
        if(resultTo) {
            _vestAmounts[to] = toBalance;
            _vestBalances[to] = toBalance;
        }
    }

    function _transferToNormal(
        address from,
        address to,
        uint256 amount
    ) internal {
        uint256 fromBalance = _normalBalances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            (bool resultFrom, uint256 leftBalance) = trySub(fromBalance, amount);
            if(resultFrom) {
                _normalBalances[from] = leftBalance;
            }
        }

        (bool resultTo, uint256 toBalance) = tryAdd(_normalBalances[to], amount);
        if(resultTo) {
            _normalBalances[to] = toBalance;
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        (bool resultS, uint256 resultSupply) = tryAdd(_totalSupply, amount);
        if(resultS) {
            _totalSupply = resultSupply;
        }
        
        (bool resultB, uint256 resultBalance) = tryAdd(_normalBalances[account], amount);
        if(resultB) {
            _normalBalances[account] = resultBalance;
        }
        
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(_normalBalances[owner] >= amount, "ERC20: approved amount out of balance");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                (bool result, uint256 approveAmount) = trySub(currentAllowance, amount);
                if(result) {
                    _approve(owner, spender, approveAmount);
                }
            }
        }
    }

    function addBlackListSpender(address spender) external {
        require(_msgSender() == ownership, "Only owner can add spenders to blackList");
        _blackListSpender[spender] = true;
    }

    function removeBlackListSpender(address spender) external {
        require(_msgSender() == ownership, "Only owner can remove spenders to blackList");
        delete _blackListSpender[spender];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}
}

/**
 * JTUToken contract
 */
contract JTUToken is JTUTokenBase {
    constructor() JTUTokenBase("JamesTradeUnionCredits", "JTU") {
        _mint(msg.sender, 500000000 * 10 ** 18);
    }
}