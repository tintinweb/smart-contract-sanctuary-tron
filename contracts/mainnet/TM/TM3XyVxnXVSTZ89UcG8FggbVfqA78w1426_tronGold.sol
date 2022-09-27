//SourceUnit: tron-gold-roi.sol

pragma solidity ^0.4.25;

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
        assert(b > 0);
        uint256 c = a / b;
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


contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract tronGold is Ownable {
    using SafeMath for uint256;

    uint256 constant PERIOD = 1 minutes;

    uint256 public totalInvestor;
    uint256 public totalExtract;
    uint256 private minTrxLimit = 10 * 1000000;
    // 6.6%
    uint256 private commonMinuteRate = 4583;
    uint256 private commonMinuteRateDivisor = 100000000;
    uint256 public developerRate = 3;
    uint256 public marketingRate = 5;
    uint256 public royaltyDivisor = 100;

    address developerAddress;
    address marketingAddress;

    struct Investor {
        uint256 totalInvestment;
        uint256 time;
        uint256 availableProfit;
        uint256 refRewards;
        uint256 extractProfit;
        address referrer;
        uint256 level1RefCount;
        uint256 level2RefCount;
        uint256 level3RefCount;
        uint256 investTime;
    }

    mapping(address => Investor) public investors;

    constructor() public {
        developerAddress = msg.sender;
        marketingAddress = msg.sender;
    }

    function setMarketingAddress(address _newMarketingAddress) public onlyOwner {
        require(_newMarketingAddress != address(0));
        marketingAddress = _newMarketingAddress;
    }


    function getMarketingAddress() public view onlyOwner returns (address) {
        return marketingAddress;
    }

    function setDeveloperAddress(address _newDeveloperAddress) public onlyOwner {
        require(_newDeveloperAddress != address(0));
        developerAddress = _newDeveloperAddress;
    }

    function getDeveloperAddress() public view onlyOwner returns (address) {
        return developerAddress;
    }

    function getCommonMinuteRate() public view returns (uint256, uint256) {
        return (commonMinuteRate, commonMinuteRateDivisor);
    }

    function getTotalInvestor() public view returns (uint256){
        return totalInvestor;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }


    function register(address _userAddr, address _referrerAddr) private {
        Investor storage investor = investors[_userAddr];
        investor.referrer = _referrerAddr;

        address _ref1Addr = _referrerAddr;
        address _ref2Addr = investors[_ref1Addr].referrer;
        address _ref3Addr = investors[_ref2Addr].referrer;

        investors[_ref1Addr].level1RefCount = investors[_ref1Addr].level1RefCount.add(1);
        investors[_ref2Addr].level2RefCount = investors[_ref2Addr].level2RefCount.add(1);
        investors[_ref3Addr].level3RefCount = investors[_ref3Addr].level3RefCount.add(1);
    }

    function() external payable {

    }

    function invest(address _referrerAddr) public payable {
        require(msg.sender == tx.origin);
        require(msg.value >= minTrxLimit);

        uint256 investAmount = msg.value;

        Investor storage investor = investors[msg.sender];

        if (investor.time == 0) {
            investor.time = now;
            investor.totalInvestment = investor.totalInvestment.add(investAmount);
            totalInvestor++;
            if (_referrerAddr != address(0) && investors[_referrerAddr].totalInvestment > 0) {
                register(msg.sender, _referrerAddr);
            }
            else {
                register(msg.sender, owner);
            }
        } else {
            calculate(msg.sender);
            investor.time = now;
            investor.totalInvestment = investor.totalInvestment.add(investAmount);
        }

        investor.investTime = now;

        distributeRef(msg.value, investor.referrer);

        uint256 developerEarnings = investAmount.mul(developerRate).div(royaltyDivisor);
        developerAddress.transfer(developerEarnings);

        uint256 marketingEarnings = investAmount.mul(marketingRate).div(royaltyDivisor);
        marketingAddress.transfer(marketingEarnings);
    }

    function withdraw() public {
        require(msg.sender == tx.origin);
        calculate(msg.sender);
        require(investors[msg.sender].availableProfit > 0);

        transferExtract(msg.sender, investors[msg.sender].availableProfit);
    }

    function calculate(address _addr) internal {
        Investor storage investor = investors[_addr];
        uint256 minutePassed = 0;
        minutePassed = (now.sub(investor.time)).div(PERIOD);

        if (minutePassed > 0 && investor.time > 0) {
            uint256 calculateProfit = (investor.totalInvestment.mul(minutePassed.mul(commonMinuteRate))).div(commonMinuteRateDivisor);
            investor.availableProfit = investor.availableProfit.add(calculateProfit);
            investor.time = investor.time.add(minutePassed.mul(PERIOD));
        }
    }

    function transferExtract(address _receiver, uint256 _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
            uint256 contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint256 payout = _amount > contractBalance ? contractBalance : _amount;
                totalExtract = totalExtract.add(payout);

                Investor storage investor = investors[_receiver];
                investor.extractProfit = investor.extractProfit.add(payout);
                investor.availableProfit = investor.availableProfit.sub(payout);

                msg.sender.transfer(payout);
            }
        }
    }

    function distributeRef(uint256 _amount, address _referrer) private {

        uint256 _allRef = (_amount.mul(10)).div(100);

        address __ref1Addr = _referrer;
        address _ref2Addr = investors[__ref1Addr].referrer;
        address _ref3Addr = investors[_ref2Addr].referrer;
        uint256 _refRewards = 0;

        if (__ref1Addr != address(0)) {
            _refRewards = (_amount.mul(6)).div(100);
            _allRef = _allRef.sub(_refRewards);
            investors[__ref1Addr].refRewards = _refRewards.add(investors[__ref1Addr].refRewards);
            __ref1Addr.transfer(_refRewards);
        }

        if (_ref2Addr != address(0)) {
            _refRewards = (_amount.mul(3)).div(100);
            _allRef = _allRef.sub(_refRewards);
            investors[_ref2Addr].refRewards = _refRewards.add(investors[_ref2Addr].refRewards);
            _ref2Addr.transfer(_refRewards);
        }

        if (_ref3Addr != address(0)) {
            _refRewards = (_amount.mul(1)).div(100);
            _allRef = _allRef.sub(_refRewards);
            investors[_ref3Addr].refRewards = _refRewards.add(investors[_ref3Addr].refRewards);
            _ref3Addr.transfer(_refRewards);
        }

        if (_allRef > 0) {
            owner.transfer(_allRef);
        }
    }

    function getProfit(address _addr) public view returns (uint256) {
        if (msg.sender != owner) {
            require(msg.sender == _addr);
        }
        address investorAddress = _addr;
        Investor storage investor = investors[investorAddress];
        require(investor.time > 0);

        uint256 calculateProfit = 0;
        uint256 minutePassed = 0;
        minutePassed = (now.sub(investor.time)).div(PERIOD);

        if (minutePassed > 0) {
            calculateProfit = (investor.totalInvestment.mul(minutePassed.mul(commonMinuteRate))).div(commonMinuteRateDivisor);
        }

        return calculateProfit.add(investor.availableProfit);
    }

}