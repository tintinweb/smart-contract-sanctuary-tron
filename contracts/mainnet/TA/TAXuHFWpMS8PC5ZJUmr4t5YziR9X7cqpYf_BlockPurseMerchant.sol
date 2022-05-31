//SourceUnit: BlockPurseIMerchant.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BlockPurseIMerchant {

    struct MerchantInfo {
        address account;
        address payable settleAccount;
        address settleCurrency;
        bool autoSettle;
        address proxy;
        uint256 rate;
        address [] tokens;
    }

    function addMerchant(
        address payable settleAccount,
        address settleCurrency,
        bool autoSettle,
        address proxy,
        uint256 rate,
        address[] memory tokens
    ) external;

    function setMerchantRate(address _merchant, uint256 _rate) external;

    function getMerchantInfo(address _merchant) external view returns(MerchantInfo memory);

    function isMerchant(address _merchant) external view returns(bool);

    function getMerchantTokens(address _merchant) external view returns(address[] memory);

    function getAutoSettle(address _merchant) external view returns(bool);

    function getSettleCurrency(address _merchant) external view returns(address);

    function getSettleAccount(address _merchant) external view returns(address);

    function validatorCurrency(address _merchant, address _currency) external view returns (bool);

}

//SourceUnit: BlockPurseMerchant.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BlockPurseIMerchant.sol";

contract BlockPurseMerchant is BlockPurseIMerchant {

    mapping(address => MerchantInfo) public merchantMap;

    event AddMerchant(address merchant, address proxy);

    event SetMerchantRate(address merchant, address proxy, uint256 newRate);

    address public immutable SETTLE_TOKEN;

    receive() payable external {}

    constructor(address _settleToken){
        SETTLE_TOKEN = _settleToken;
    }

    function addMerchant(
        address payable _settleAccount,
        address _settleCurrency,
        bool _autoSettle,
        address _proxy,
        uint256 _rate,
        address[] memory _tokens
    ) external override {

        if(address(0) != _settleCurrency) {
            require(SETTLE_TOKEN == _settleCurrency);
        }

        merchantMap[msg.sender] = MerchantInfo (msg.sender, _settleAccount, _settleCurrency, _autoSettle, _proxy, _rate, _tokens);

        emit AddMerchant(msg.sender, _proxy);

        emit SetMerchantRate(msg.sender, _proxy, _rate);

    }

    function setMerchantRate(address _merchant, uint256 _rate) external override {

        require(_isMerchant(_merchant));

        if(msg.sender != _merchant) {
            require(msg.sender == merchantMap[_merchant].proxy);
        }

        merchantMap[_merchant].rate = _rate;

        emit SetMerchantRate(_merchant, msg.sender, _rate);

    }

    function getMerchantInfo(address _merchant) external override view returns(MerchantInfo memory){
        return merchantMap[_merchant];
    }

    function isMerchant(address _merchant) external override view returns(bool) {
        return _isMerchant(_merchant);
    }

    function _isMerchant(address _merchant) public view returns(bool) {
        return merchantMap[_merchant].account != address(0);
    }

    function getMerchantTokens(address _merchant) external override view returns(address[] memory) {
        return merchantMap[_merchant].tokens;
    }

    function getAutoSettle(address _merchant) external override view returns(bool){
        return merchantMap[_merchant].autoSettle;
    }

    function getSettleCurrency(address _merchant) external override view returns(address){
        return merchantMap[_merchant].settleCurrency;
    }

    function getSettleAccount(address _merchant) external override view returns(address){
        return merchantMap[_merchant].settleAccount;
    }

    function validatorCurrency(address _merchant, address _currency) public override view returns (bool){
        for(uint idx = 0; idx < merchantMap[_merchant].tokens.length; idx ++) {
            if (_currency == merchantMap[_merchant].tokens[idx]) {
                return true;
            }
        }
        return false;
    }

}