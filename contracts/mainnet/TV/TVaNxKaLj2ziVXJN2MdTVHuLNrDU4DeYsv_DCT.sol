//SourceUnit: DCT.sol

pragma solidity ^0.8.4;

interface IERC20 {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        _;
    }

    constructor() {
    }

    function initilizeOwner() internal {
      _owner = msg.sender;
      emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns(address) {
        return _owner;

    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Stakeable {

    constructor() {
    }

    function initilizeStakeable() internal {
        stageOneReward = 1825;    
        stagetwoReward = 2281;    
        stagethreeReward = 3041;  
        stagefourReward = 3650;   
        lastStageReward = 4562; 
        
        stakeholders.push();
        stageOnetime = block.timestamp + 365 days;
        stageTwotime = stageOnetime + 365 days;
        stageThreetime = stageTwotime + 365 days;
        stageFourtime = stageThreetime + 365 days;
    }

    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
        uint256 claimable;
    }

    struct Stakeholder{
        address user;
        Stake[] address_stakes;
        
    }

    struct StakingSummary{
        uint256 total_amount;
        Stake[] stakes;
    }

    Stakeholder[] internal stakeholders;

    mapping(address => uint256) internal stakes;

    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timestamp);


    uint256 private stageOneReward;
    uint256 private stagetwoReward;
    uint256 private stagethreeReward;
    uint256 private stagefourReward;
    uint256 private lastStageReward;

    uint256 private stageOnetime;
    uint256 private stageTwotime;
    uint256 private stageThreetime;
    uint256 private stageFourtime;


    function checkIFStakedInPhaseOne(uint stakedTime) internal view returns(bool) {
        if (stakedTime <= stageOnetime) {
            return true;
        }
        return false;
    }

    function checkIFStakedInPhaseTwo(uint stakedTime) internal view returns(bool) {
        if (stakedTime > stageOnetime && stakedTime <= stageTwotime) {
            return true;
        }
        return false;
    }

    function checkIFStakedInPhaseThree(uint stakedTime) internal view returns(bool) {
        if (stakedTime > stageTwotime && stakedTime <= stageThreetime) {
            return true;
        }
        return false;
    }

    function checkIFStakedInPhaseFour(uint stakedTime) internal view returns(bool) {
        if (stakedTime > stageThreetime && stakedTime <= stageFourtime) {
            return true;
        }
        return false;
    }
    
    function getReward(uint256 stakedTime, uint256 amount,uint256 ratio) private pure returns(uint256) {
      if(stakedTime < 24 hours) {
        return 0;
      }
        return ((stakedTime / 24 hours) * amount) / ratio;
    }

    function getStageEndTime() public view returns(uint256, uint256, uint256, uint256) {
      return (stageOnetime, stageTwotime, stageThreetime, stageFourtime);
    }

    function calculateDiffrentStakePhaseReward(Stake memory _current_stake) view internal returns(uint256) {
        if (block.timestamp <= stageOnetime) { 
            return getReward(
                block.timestamp - _current_stake.since, 
                _current_stake.amount, 
                stageOneReward
            );
        }

        else if (block.timestamp <= stageTwotime) {
            uint256 phaseOneReward;
            uint256 phaseTwoReward;

            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                
                phaseOneReward = getReward(
                    stageOnetime - _current_stake.since,
                    _current_stake.amount, 
                    stageOneReward);

                phaseTwoReward = getReward(
                    block.timestamp - stageOnetime, 
                    _current_stake.amount, 
                    stagetwoReward);
            }
            else {              
                phaseTwoReward = getReward(
                    block.timestamp - _current_stake.since, 
                    _current_stake.amount, 
                    stagetwoReward); 

            }
            return phaseOneReward + phaseTwoReward;
        } 

        else if (block.timestamp <= stageThreetime) {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;

            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                
                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since, 
                    _current_stake.amount, 
                    stageOneReward); 

                phaseTwoRe = getReward(
                        stageTwotime - stageOnetime, 
                        _current_stake.amount, 
                        stagetwoReward);

                phaseThreeRe = getReward(
                    block.timestamp - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);
            }

            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since, 
                    _current_stake.amount, 
                    stagetwoReward);

                phaseThreeRe = getReward(
                    block.timestamp - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);
            }

            else {
                phaseThreeRe = getReward(
                    block.timestamp - _current_stake.since, 
                    _current_stake.amount, 
                    stagethreeReward);
            }

            return phaseOneRe + phaseTwoRe + phaseThreeRe;
        }

        else if (block.timestamp <= stageFourtime) {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;
            uint256 phaseFourRe;

            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                
                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since, 
                    _current_stake.amount, 
                    stageOneReward); 

                phaseTwoRe = getReward(
                        stageTwotime - stageOnetime, 
                        _current_stake.amount, 
                        stagetwoReward);

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);
                
                phaseFourRe = getReward(
                    block.timestamp - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
            }

            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since, 
                    _current_stake.amount, 
                    stagetwoReward);

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);

                phaseFourRe = getReward(
                    block.timestamp - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
            }

            else if (checkIFStakedInPhaseThree(_current_stake.since)) {
                phaseThreeRe = getReward(
                    stageThreetime - _current_stake.since, 
                    _current_stake.amount, 
                    stagethreeReward);
                
                phaseFourRe = getReward(
                    block.timestamp - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
            }

            else {
                phaseFourRe = getReward(
                    block.timestamp - _current_stake.since, 
                    _current_stake.amount, 
                    stagefourReward);
            }

            return phaseOneRe + phaseTwoRe + phaseThreeRe + phaseFourRe;
        }

        else {
            uint256 phaseOneRe;
            uint256 phaseTwoRe;
            uint256 phaseThreeRe;
            uint256 phaseFourRe;
            uint256 lastPhaseRe;

            if (checkIFStakedInPhaseOne(_current_stake.since)) {
                
                phaseOneRe = getReward(
                    stageOnetime - _current_stake.since, 
                    _current_stake.amount, 
                    stageOneReward); 

                phaseTwoRe = getReward(
                    stageTwotime - stageOnetime, 
                    _current_stake.amount, 
                    stagetwoReward);

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);
                
                phaseFourRe = getReward(
                    stageFourtime - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
                
                lastPhaseRe = getReward(
                    block.timestamp - stageFourtime, 
                    _current_stake.amount, 
                    lastStageReward);
            }

            else if (checkIFStakedInPhaseTwo(_current_stake.since)) {
                phaseTwoRe = getReward(
                    stageTwotime - _current_stake.since, 
                    _current_stake.amount, 
                    stagetwoReward);

                phaseThreeRe = getReward(
                    stageThreetime - stageTwotime, 
                    _current_stake.amount, 
                    stagethreeReward);
                
                phaseFourRe = getReward(
                    stageFourtime - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
                
                lastPhaseRe = getReward(
                    block.timestamp - stageFourtime, 
                    _current_stake.amount, 
                    lastStageReward);
            }

            else if (checkIFStakedInPhaseThree(_current_stake.since)) {
                phaseThreeRe = getReward(
                    stageThreetime - _current_stake.since, 
                    _current_stake.amount, 
                    stagethreeReward);
                
                phaseFourRe = getReward(
                    stageFourtime - stageThreetime, 
                    _current_stake.amount, 
                    stagefourReward);
                
                lastPhaseRe = getReward(
                    block.timestamp - stageFourtime, 
                    _current_stake.amount, 
                    lastStageReward);
            }

            else if (checkIFStakedInPhaseFour(_current_stake.since)) {
                phaseFourRe = getReward(
                    stageFourtime - _current_stake.since, 
                    _current_stake.amount, 
                    stagefourReward);
                
                lastPhaseRe = getReward(
                    block.timestamp - stageFourtime, 
                    _current_stake.amount, 
                    lastStageReward);
            }

            else {
                lastPhaseRe = getReward(
                    block.timestamp - _current_stake.since, 
                    _current_stake.amount, 
                    lastStageReward);
            }

            return phaseOneRe + phaseTwoRe + phaseThreeRe + phaseFourRe + lastPhaseRe;
        }
    }

    function calculateStakeReward(Stake memory _current_stake) internal view returns(uint256){
        return calculateDiffrentStakePhaseReward(_current_stake);
    }


    function _addStakeholder(address staker) internal returns (uint256){
        stakeholders.push();
        uint256 userIndex = stakeholders.length - 1;
        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;
        return userIndex; 
    }

    function _stake(uint256 _amount) internal {
        require(_amount > 0, "Cannot stake nothing");
        
        uint256 index = stakes[msg.sender];
        uint256 timestamp = block.timestamp;
        if(index == 0){
           index = _addStakeholder(msg.sender);
        }
        stakeholders[index].address_stakes.push(Stake(msg.sender, _amount, timestamp,0));
        emit Staked(msg.sender, _amount, index,timestamp);
    }

    event restaked(uint256 _amount, uint256 reward);
  
    function _withdrawStake(uint256 amount, uint256 index) internal returns(uint256, uint256, uint256){
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");
        uint256 reward = calculateStakeReward(current_stake);
        current_stake.amount = current_stake.amount - amount;
        if(current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
        }
        uint256 devReward = ( reward * 5 ) / 100; 
        reward -= devReward;
        return (amount, reward, devReward);
    }

    function restakeReward(uint256 reward, uint256 index) internal {
      uint256 user_index = stakes[msg.sender];
      Stake memory current_stake = stakeholders[user_index].address_stakes[index];
      stakeholders[user_index].address_stakes[index].amount = current_stake.amount + reward;
      stakeholders[user_index].address_stakes[index].since = block.timestamp;
      emit restaked(current_stake.amount, reward);
    }


    function _withdrawStakeWithZeroReward(uint256 amount, uint256 index) internal returns(uint256){
        uint256 user_index = stakes[msg.sender];
        Stake memory current_stake = stakeholders[user_index].address_stakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");
        current_stake.amount = current_stake.amount - amount;
        if(current_stake.amount == 0) {
            delete stakeholders[user_index].address_stakes[index];
        } else {
            stakeholders[user_index].address_stakes[index].amount = current_stake.amount;
            stakeholders[user_index].address_stakes[index].since = block.timestamp;    
        }
        return (amount);
    }

    function hasStake(address _staker) public view returns(StakingSummary memory){
        uint256 totalStakeAmount; 
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        for (uint256 s = 0; s < summary.stakes.length; s += 1){
           uint256 availableReward = calculateStakeReward(summary.stakes[s]);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        summary.total_amount = totalStakeAmount;
        return summary;
    }

    function hasStakeIndex(address _staker) public view returns(uint256[] memory){
        uint256 totalStakeAmount; 
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        uint256[] memory indexArray = new uint256[]((summary.stakes.length * 4) + 1);
        uint256 arr;
        for (uint256 s = 0; s < summary.stakes.length; s += 1){

           indexArray[arr] = s;
           arr++;
           indexArray[arr] = summary.stakes[s].amount;
           arr++;
           indexArray[arr] = summary.stakes[s].since;
           arr++;
           indexArray[arr] = calculateStakeReward(summary.stakes[s]);
           arr++;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
        }
        indexArray[arr] = totalStakeAmount;
        return indexArray;
    }

    function getTotalStakeIndex(address _staker) view public returns(uint256) {
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        return summary.stakes.length;
    }

    function getStakeAmount(address _staker, uint index) view public returns(uint256) {
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].address_stakes);
        return summary.stakes[index].amount;
    }

}

contract DCT is Ownable, Stakeable {

  uint private _totalSupply;
  uint8 private _decimals;
  string private _symbol;
  string private _name;
  address private devAddress;
  address private signer;
  address private LOCKED_ACCOUNT;
  uint private MAX_SUPPLY;
  uint private rewardSupply;
  uint private LOCKEDAMOUNT;
  uint private LOCKEDDURATION;
  uint256 totalStaked;	
  uint256 totalRewardGenrated;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  event singerChanged(address indexed from, address indexed to);

  event devChange(address indexed from, address indexed to);

  constructor() {
  }

  bool isInitilize;

  modifier isInitilized {
    require(!isInitilize, "You can not initilize contract again! ");
    _;
  }

  modifier isLOCKEDACCOUNT {
    if(msg.sender == LOCKED_ACCOUNT) {
      require(block.timestamp >= LOCKEDDURATION, "YOUR ACCOUNT IS LOCKED");
    }
    _;
  }

  function initialize() public  isInitilized{

    initilizeOwner();
    initilizeStakeable();

    _name = "IDCHAIN TOKEN";
    _symbol = "DCT";
    _decimals = 8;
    _balances[msg.sender] = _totalSupply;
    

    MAX_SUPPLY = 500_000_000 * (10 ** _decimals);
    uint256 devAmount = 100_000_000 * (10 ** _decimals);
    LOCKEDAMOUNT = 200_000_000 * (10 ** _decimals);
    rewardSupply = MAX_SUPPLY - (LOCKEDAMOUNT + devAmount);
    LOCKEDDURATION = block.timestamp + 1095 days; // 3 years


    signer = 0xae1F5Dd5C53bf50fe5d8334174F8b77d5fc98fb5;
    devAddress = 0x17b259Cc0989fc20F4010c733e8B2A9fD5C39c69;
    LOCKED_ACCOUNT = 0xf0E02Fb38aA34DC28511A3835527F66c53AC585f;

    _mint(devAddress, devAmount);
    _mint(LOCKED_ACCOUNT, LOCKEDAMOUNT);

    isInitilize = true;

    emit Transfer(address(0), msg.sender, _totalSupply);
    emit singerChanged(address(0), signer);
    emit devChange(address(0), devAddress);
  }

  function getTotalReward() public view returns(uint256) {	
    return totalRewardGenrated;	
  }	

  function getTotalStakedAmount() public view returns(uint256) {	
    return totalStaked;	
  }	

  function totalStakeHolder() public view returns(uint256) {	
      return stakeholders.length;	
  }

  function changeSigner(address _signer) public onlyOwner {
    address temp = signer;
    signer = _signer;
    emit singerChanged(temp, _signer);
  }

  function getSigner() view public returns(address) {
    return signer;
  }

  function getDevAddress() view public returns(address) {
    return devAddress;
  }

  function getRemainingReward() view public returns(uint256) {
    return rewardSupply;
  }

  function changeDevaddress(address _devAddress) public onlyOwner {
    address temp = devAddress;
    devAddress = _devAddress;
    emit singerChanged(temp, _devAddress);
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory){
    return _symbol;
  }

  function name() external view returns (string memory){
    return _name;
  }

  function totalSupply() external view returns (uint256){
    return _totalSupply;
  }

  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  function totalMaxSupply() public view returns(uint256) {
    return MAX_SUPPLY;
  }

  function isContract(address _addr) private view returns (bool){
    uint32 size;
    assembly {
      size := extcodesize(_addr)
    }
    return (size > 0);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "IDCHAIN TOKEN: cannot mint to zero address");
    _totalSupply = _totalSupply + (amount);
    _balances[account] = _balances[account] + amount;
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "IDCHAIN TOKEN: cannot burn from zero address");
    require(_balances[account] >= amount, "IDCHAIN TOKEN: Cannot burn more than the account owns");
    _balances[account] = _balances[account] - amount;
    _totalSupply = _totalSupply - amount;
    emit Transfer(account, address(0), amount);
  }

  function burn(address account, uint256 amount)  public onlyOwner returns(bool) {
    require(account != address(this), "You can not burn token from this account");
    if (account == LOCKED_ACCOUNT) {
      require(block.timestamp >= LOCKEDDURATION, "ACCOUNT IS LOCKED");
    }
    _burn(account, amount);
    return true;
  }

  function mint(address account, uint256 amount) public onlyOwner returns(bool){
    if (account == LOCKED_ACCOUNT) {
      require(block.timestamp >= LOCKEDDURATION, "ACCOUNT IS LOCKED");
    }
    _mint(account, amount);
    return true;
  }

  function transfer(address recipient, uint256 amount) isLOCKEDACCOUNT external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "IDCHAIN TOKEN: transfer from zero address");
    require(recipient != address(0), "IDCHAIN TOKEN: transfer to zero address");
    require(_balances[sender] >= amount, "IDCHAIN TOKEN: cant transfer more than your account holds");

    _balances[sender] = _balances[sender] - amount;
    _balances[recipient] = _balances[recipient] + amount;

    emit Transfer(sender, recipient, amount);
  }

  function allowance(address owner, address spender) external view returns(uint256){
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) isLOCKEDACCOUNT external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "IDCHAIN TOKEN: approve cannot be done from zero address");
    require(spender != address(0), "IDCHAIN TOKEN: approve cannot be to zero address");
    _allowances[owner][spender] = amount;

    emit Approval(owner,spender,amount);
  }

  function transferFrom(address spender, address recipient, uint256 amount) isLOCKEDACCOUNT external returns(bool){
    require(_allowances[spender][msg.sender] >= amount, "IDCHAIN TOKEN: You cannot spend that much on this account");
    _transfer(spender, recipient, amount);
    _approve(spender, msg.sender, _allowances[spender][msg.sender] - amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 amount) isLOCKEDACCOUNT public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender]+amount);
    return true;
  }

  function decreaseAllowance(address spender, uint256 amount) isLOCKEDACCOUNT public returns (bool) {
    _approve(msg.sender, spender, _allowances[msg.sender][spender]-amount);
    return true;
  }

  //////////////////////////////////////////////////////////////////////////

  function getHash(uint256 time, uint256 amnt) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(time, amnt));
  }

  function getTrxSignedHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19TRON Signed Message:\n32", _messageHash));
    }

  function validate(bytes32 hash, bytes memory signature) public pure returns (address){
    bytes32  r;
    bytes32  s;
    uint8 v;
    assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
    }
    return ecrecover(hash, v, r, s);
  }

  //////////////////////////////////////////////////////////////////////////

  function mintReward(uint256 amountStaked, uint256 userReward, uint256 devReward) private {
      _mint(msg.sender, userReward);
      _mint(devAddress, devReward);
      _transfer(address(this), msg.sender, amountStaked);
      totalStaked -= amountStaked;
  }

  function mintDevReward(uint256 devReward) private {
    _mint(devAddress, devReward);
  }

  function stake (
    uint256 blockTime, 
    uint256 _amount, 
    bytes memory _adminSignature,
    bytes memory _userSignature
  ) isLOCKEDACCOUNT public {
    require(!isContract(msg.sender), "Caller must not be Smart Contract");
    bytes32 hashOf = getHash(blockTime, _amount);
    require(_amount <= _balances[msg.sender], "IDCHAIN TOKEN: Cannot stake more than you own");
    require(_amount >= 1000 * (10 ** _decimals),  "IDCHAIN TOKEN: Cannot stake less then 1000");
    require(blockTime > block.timestamp && blockTime < block.timestamp + 5 minutes, "IDCHAIN TOKEN: blocktime does not match required time");
    
    require(signer == validate(getTrxSignedHash(hashOf), _adminSignature), "IDCHAIN TOKEN: Signer is not admin");
    require(msg.sender == validate(getTrxSignedHash(hashOf), _userSignature), "IDCHAIN TOKEN: User is not User");

    _stake(_amount);
    _transfer(msg.sender, address(this), _amount);
    totalStaked += _amount;
  }

  event RewardAmountReduced(uint256 _from, uint256 _to);
  event CanNotGetReward(uint256 userRewardAmount, uint256 contractRewardAmountHold);

  function reduceRewardSupply(uint amount) private {
    uint256 temp = rewardSupply;
    rewardSupply -= amount;
    emit RewardAmountReduced(temp, rewardSupply);
  }

  event LastAmountMinted(uint256 stakedAmount, uint256 remaningAmount, uint256 rewardAmount, uint totalAmount);

  function withdrawStake(
    uint256 amount, 
    uint256 stake_index, 
    bool restake
  )  
    public 
  {
    require(!isContract(msg.sender), "Caller must not be Smart Contract");
    uint256 amountStaked;
    uint256  devReward;
    uint256 userReward;

    if (getRemainingReward() > 0) {

      (amountStaked, userReward, devReward) = _withdrawStake(amount, stake_index);
      
      if((userReward + devReward) > 0) {

        if ((userReward + devReward) < getRemainingReward()) {
          reduceRewardSupply(devReward + userReward);
        }
        else
        {
          userReward = getRemainingReward();
          devReward = ( userReward * 5 ) / 100;
          userReward -= devReward;
          rewardSupply = 0;
          emit LastAmountMinted(amountStaked, getRemainingReward(), userReward, amountStaked + getRemainingReward());
        }
        if(restake) {
          require(amount == 0 , "In restake amount must be 0");
          restakeReward(userReward, stake_index);
          mintDevReward(devReward);
          _mint(address(this), userReward);
          totalStaked += userReward;
        }
        else{
          mintReward(amountStaked, userReward, devReward);
        }
      }
      else {
        require(!restake , "You can not restake this index before you get your reward");
        _transfer(address(this), msg.sender, amountStaked);
        totalStaked -= amountStaked;
        emit CanNotGetReward(userReward + devReward, getRemainingReward());
      }  
    }
    else {
      require(!restake, "You can not restake your reward now because reward is empty now");
      amountStaked = _withdrawStakeWithZeroReward(amount, stake_index);
      _transfer(address(this), msg.sender, amountStaked);
      totalStaked -= amountStaked;
      emit CanNotGetReward(userReward + devReward, getRemainingReward());
    }
  }


  function withdrawBNB() public onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  fallback() external payable {}

  receive() external payable {
    payable(owner()).transfer(address(this).balance);
  }

  function withdrawToken(address _token) public onlyOwner {
    require(!isContract(msg.sender), "Caller must not br Smart Contract");
    IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
  }

}