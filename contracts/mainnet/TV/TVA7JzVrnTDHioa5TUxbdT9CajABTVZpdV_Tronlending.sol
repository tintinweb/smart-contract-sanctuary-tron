//SourceUnit: Tron.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Tronlending {
    uint public contract_user;
    uint public trx_amount;
    address public owner;
    address[] public accounts;
    uint public rate_bandwidth;
    uint public rate_energy;
    uint public min_energy;
    uint public min_bandwidth;
    enum TYPE { ENERGY, BANDWIDTH }
    event Notification(uint256 indexed lock_period, TYPE indexed types, uint256 amount, address from, address destination);

    constructor(){
        owner = msg.sender;
        rate_bandwidth = 80;
        rate_energy = 80;
        min_energy = 100000;
        min_bandwidth = 1000;
    }

    function depositNative(TYPE _type, uint256 _lock_period, address _destination) payable external {
        uint price_bandwidth = chain.totalNetLimit * 1000000 / chain.totalNetWeight;
        uint price_energy = chain.totalEnergyCurrentLimit * 1000000 / chain.totalEnergyWeight; 
        uint _rate = (_type == TYPE.ENERGY ? rate_energy : rate_bandwidth);
        uint _price = _type == TYPE.ENERGY ? price_energy : price_bandwidth;
        uint _resourceType = _type == TYPE.ENERGY ? 1 : 0;
        uint _min = _type == TYPE.ENERGY ? min_energy : min_bandwidth;
        uint avail = getTotalDelegatableResource(_resourceType);
        require(_lock_period >= 28800, "Lock period too short!");
        require(_lock_period <= 864000, "Lock period too long!");
        require(
            avail >= (msg.value * _min * 10 * 1000000) / _rate / _price, "No money");
        contract_user ++;
        trx_amount += msg.value;
        emit Notification(_lock_period, _type, msg.value, msg.sender, _destination);
    }

    function withdraw(uint amount) payable external {
        require(msg.sender == owner, "Unauthorized!");
        require(trx_amount >= amount, "Not Enough TRX!");
        trx_amount -= amount;
        payable(owner).transfer(amount);
    }
    
    function getTotalDelegatableResource(uint resourceType) internal returns(uint available) {
        require(accounts.length != 0, "No staking address!");
        uint total_avail = 0;

        for (uint i = 0; i < accounts.length; i ++ ) {
            total_avail += accounts[i].delegatableResource(resourceType);
        }
        return total_avail;
    }
    
    function getAllTotalDelegatableResource() view public returns(uint availableEnergy, uint totalEnergy, uint availableBandwidth, uint totalBandwidth) {
        require(accounts.length != 0, "No staking address!");
        uint avail_energy = 0;
        uint total_energy = 0;
        uint avail_bandwidth = 0;
        uint total_bandwidth = 0;
        for (uint i = 0; i < accounts.length; i ++ ) {
            avail_energy += accounts[i].delegatableResource(1);
            total_energy += accounts[i].totalResource(1) + accounts[i].totalDelegatedResource(1);
            avail_bandwidth += accounts[i].delegatableResource(0);
            total_bandwidth += accounts[i].totalResource(0) + accounts[i].totalDelegatedResource(0);
        }
        return (avail_energy, total_energy, avail_bandwidth, total_bandwidth);
    }
    
    
    function getDelegatableResource(address target) view public returns(uint availableEnergy, uint availableBandwidth) {
        return (target.delegatableResource(1), target.delegatableResource(0));
    }

    
    function addAccounts(address _account) external {
        require(owner == msg.sender, "Unauthorized");
        bool found = false;
        for (uint i = 0; i < accounts.length; i ++) {
            if (accounts[i] == _account) {
                found = true;
                break;
            }
        }
        require(found == false, "Duplicated accounts!");
        accounts.push(_account);
        
    }
    
    function removeAccounts(address _account) external {
        require(owner == msg.sender, "Unauthorized");
        require(accounts.length != 0, "No staking address!");
        bool found = false;
        for (uint i = 0; i < accounts.length; i ++ ) {
            if (accounts[i] == _account) {
                address temp = accounts[i];
                accounts[i] = accounts[accounts.length - 1];
                accounts[accounts.length - 1] = temp;
                accounts.pop();
                found = true;
                break;
            }
        }
        require(found == true, "No such address!");
    }
    
    function updateEnergyRate(uint _rate_energy) external {
        require(msg.sender == owner, "Unauthorized!");
        rate_energy = _rate_energy;
    }
    
    function updateBandwidthRate(uint _rate_bandwidth) external {
        require(msg.sender == owner, "Unauthorized!");
        rate_bandwidth = _rate_bandwidth;
    }
    
    function getPriceAndRate() public view returns(uint freezePriceEnergy, uint freezePriceBandwidth, uint burnPriceEnergy, uint burnPriceBandwidth, uint rateEnergy, uint rateBandwidth, uint minEnergy, uint minBandwidth){
        uint price_bandwidth = chain.totalNetLimit * 1000000 / chain.totalNetWeight;
        uint price_energy = chain.totalEnergyCurrentLimit * 1000000 / chain.totalEnergyWeight;
        return (price_energy, price_bandwidth, block.basefee, 1000, rate_energy, rate_bandwidth, min_energy, min_bandwidth);
    }
    
    function updateMinEnergy(uint _min_energy) external {
        require(msg.sender == owner, "Unauthorized");
        min_energy = _min_energy;
    }
    
    function updateMinBandwidth(uint _min_bandwidth) external {
        require(msg.sender == owner, "Unauthorized");
        min_bandwidth = _min_bandwidth;
    }
}