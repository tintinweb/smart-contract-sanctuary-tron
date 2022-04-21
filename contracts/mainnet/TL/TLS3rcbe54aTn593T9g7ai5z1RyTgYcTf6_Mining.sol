//SourceUnit: Mining.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TRC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Mining {
    mapping(address => uint256) starRewards;
    mapping(address => uint256) lsRewards;
    mapping (address => uint256) userLastUpdateTime;

    mapping(address => uint256) public balanceOf;

    mapping(address => address) public referralRelationships;

    mapping(address => uint256) userAcquiredStar;
    mapping(address => uint256) userAcquiredLs;

    mapping (address => uint256) teamNumber;
    mapping (address => uint256) teamAmount;
    mapping (address => uint256) directNumber;

    mapping (address => uint256) public starTeamReward;
    mapping (address => uint256) public lsTeamReward;

    mapping (address => uint256) public userLastGetStar;
    mapping (address => uint256) public userLastGetLs;

    uint256[] starRewardList = [8,8,10];
    uint256[] lsRewardList = [8,8,10,10,10,10,10,10];

    uint256 public starRewardRate;
    uint256 public lsRewardRate;
    address public savageBox;

    address owner;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event StarRewardPaid(address indexed user, uint256 reward);
    event LsRewardPaid(address indexed user, uint256 reward);

    modifier updateReward(address _user) {
        if(userLastUpdateTime[_user] == 0) {
            userLastUpdateTime[_user] = block.timestamp;
        } else {
            uint256 balance = balanceOf[_user];
            starRewards[_user] = starRewards[_user] + (block.timestamp - userLastUpdateTime[_user]) * starRewardRate * balance;
            lsRewards[_user] = lsRewards[_user] + (block.timestamp - userLastUpdateTime[_user]) * lsRewardRate * balance;
            userLastUpdateTime[_user] = block.timestamp;
        }
        _;
    }

    constructor(uint256 _dailyStarProduction,uint256 _dailyLsProduction,address _savageBox) {
        starRewardRate = _dailyStarProduction / 1 days;
        lsRewardRate = _dailyLsProduction / 1 days;
        savageBox = _savageBox;
        owner = msg.sender;
    }

    function _updateReferralRelationship(address _user, address _referrer) internal {
        if (_referrer == _user) { // referrer cannot be user himself/herself
          return;
        }

        if (_referrer == address(0)) { // Cannot be address 0
          return;
        }

        if(referralRelationships[_user] == address(0)) {
            referralRelationships[_user] = _referrer;
        }
    }

    function earned(address _user) public view returns(uint256 starEarned,uint256 lsEarned) {
        if(userLastUpdateTime[_user] == 0) {
            return (0,0);
        }
        uint256 balance = balanceOf[_user];
        starEarned = starRewards[_user] + (block.timestamp - userLastUpdateTime[_user]) * starRewardRate * balance;
        lsEarned = lsRewards[_user] + (block.timestamp - userLastUpdateTime[_user]) * lsRewardRate * balance;
    }

    function deposit(uint256 _amount,address _referrer) public updateReward(msg.sender) {
        require(_amount > 0,"Cannot stake zero");
        require(balanceOf[_referrer] > 0 || msg.sender == owner);
        TRC20(savageBox).transferFrom(msg.sender, address(this), _amount);
        _updateReferralRelationship(msg.sender, _referrer);

        address ref = referralRelationships[msg.sender];

        if(balanceOf[msg.sender] == 0 && ref != address(0)) {
            directNumber[ref] += 1;
            addTeamNumber(ref);
        }
        
        balanceOf[msg.sender] = balanceOf[msg.sender] + _amount;

        afterDeposit(msg.sender,_amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) public updateReward(msg.sender) {
        require(_amount > 0,"Cannot withdraw zero");
        balanceOf[msg.sender] = balanceOf[msg.sender] - _amount;
        TRC20(savageBox).transfer(msg.sender, _amount);
        afterWithdraw(msg.sender,_amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function getStarReward() public updateReward(msg.sender) {
        // uint256 n = block.timestamp % 604800;
        // require(n > 144000 && n < 230400);
        // require(block.timestamp - userLastGetStar[msg.sender] > 1 days);
        (uint256 _starReward,) = earned(msg.sender);
        uint256 userStarTeamReward = starTeamReward[msg.sender];
        require(_starReward+userStarTeamReward > 0);
        starRewards[msg.sender] = 0;
        starTeamReward[msg.sender] = 0;

        userAcquiredStar[msg.sender] += _starReward;

        userLastGetStar[msg.sender] = block.timestamp;

        afterGetStarReward(msg.sender,_starReward);
        emit StarRewardPaid(msg.sender, _starReward+userStarTeamReward);
    }

    function getLsReward() public updateReward(msg.sender) {
        // require(block.timestamp > 1663300800);
        // require(block.timestamp - userLastGetLs[msg.sender] > 1 days);
        (,uint256 _lsReward) = earned(msg.sender);
        uint256 userLsTeamReward = lsTeamReward[msg.sender];
        require(_lsReward+userLsTeamReward > 0);
        lsRewards[msg.sender] = 0;
        lsTeamReward[msg.sender] = 0;
        userAcquiredLs[msg.sender] += _lsReward;
        userLastGetLs[msg.sender] = block.timestamp;
        afterGetLsReward(msg.sender,_lsReward);
        emit LsRewardPaid(msg.sender, _lsReward+userLsTeamReward);
    }

    function getTotalReward(address _address) public view returns(uint256 starReward,uint256 lsReward) {
        (uint256 earnedStar,uint256 earnedLs) =  earned(_address);
        uint256 acquiredStar = userAcquiredStar[_address];
        uint256 acquiredLs = userAcquiredLs[_address];
        starReward = earnedStar + acquiredStar;
        lsReward = earnedLs + acquiredLs;
    }

    function afterWithdraw(address _user,uint256 _amount) internal {
        uint256 balance = balanceOf[_user];
        address ref = referralRelationships[_user];
        if(balance == 0) {
            if(ref != address(0) && directNumber[ref] >= 1) {
                directNumber[ref] -= 1;
            }
            subTeamNumber(ref);
        }
        subTeamAmount(_user,_amount);
    }

    function addTeamNumber(address _referrer) internal {
        for (uint256 i = 0; i < 8; i++) {
            if(_referrer != address(0)) {
                teamNumber[_referrer] += 1;
                _referrer = referralRelationships[_referrer];
            } else {
                break;
            }
        }
    }

    function subTeamNumber(address _referrer) internal {
        for (uint256 i = 0; i < 8; i++) {
            if(_referrer != address(0) && teamNumber[_referrer] >= 1) {
                teamNumber[_referrer] -= 1;
                _referrer = referralRelationships[_referrer];
            } else {
                break;
            }
        }
    }

    function afterDeposit(address _user,uint256 _amount) internal {
        teamAmount[_user] += _amount;
        address ref = referralRelationships[_user];
        for (uint256 i = 0; i < 8; i++) {
            if(ref != address(0)) {
                teamAmount[ref] += _amount;
                ref = referralRelationships[ref];
            } else {
                break;
            }
        }
    }

    function subTeamAmount(address _user,uint256 _amount) internal {
        if(teamAmount[_user] >= _amount) {
            teamAmount[_user] -= _amount;
        }
        address ref = referralRelationships[_user];
        for (uint256 i = 0; i < 8; i++) {
            if(ref != address(0)) {
                teamAmount[ref] -= _amount;
                ref = referralRelationships[ref];
            } else {
                break;
            }
        }
    }

    function afterGetStarReward(address _user,uint256 _reward) internal {
        address ref = referralRelationships[_user];
        for(uint256 i = 0; i < 3; i++) {
            if(ref != address(0)) {
                if(balanceOf[ref] > 0 && directNumber[ref] > i) {
                    starTeamReward[ref] = starTeamReward[ref] += (_reward * starRewardList[i] / 100);
                }
                ref = referralRelationships[ref];
            } else {
                break;
            }
        }
    }

    function afterGetLsReward(address _user,uint256 _reward) internal {
        address ref = referralRelationships[_user];
        for(uint256 i = 0; i < 8; i++) {
            if(ref != address(0)) {
                if(balanceOf[ref] > 0 && directNumber[ref] > i) {
                    lsTeamReward[ref] = lsTeamReward[ref] += (_reward * lsRewardList[i] / 100);
                }
                ref = referralRelationships[ref];
            } else {
                break;
            }
        }
    }

    function getData(address _user) public view 
        returns(uint256 userTeamAmount,uint256 userDirectNum,uint256 userTeamNum,uint256 earnedStar,uint256 earnedLs,uint256 userLsTeamReward,uint256 userStarTeamReward,uint256 balance) {

        userTeamAmount = teamAmount[_user];
        userDirectNum = directNumber[_user];
        userTeamNum = teamNumber[_user];

        (earnedStar, earnedLs) = earned(_user);
        userLsTeamReward = lsTeamReward[_user];
        userStarTeamReward = starTeamReward[_user];
        balance = balanceOf[_user];
    }

}