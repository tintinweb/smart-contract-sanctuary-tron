//SourceUnit: SFX.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract SFX {

    using SafeMath for uint256;
    IERC20 Token;

    address payable public owner;
    address payable public compAcc;
    address payable public acc;
    address payable public acc1;
    address payable public acc2;

    struct Admin {
        uint256 active;
    }

    struct Records {
        uint256 sale_id;
        uint256 amount;
        uint256 adm_acc;
        uint256 level1;
        uint256 level2;
        uint256 level3;
        uint256 manager;
        uint256 district;
        uint256 director;
        uint40 time;
    }

    mapping(address => Admin) public admins;
    mapping(address => mapping(uint256 => Records)) public records;

    event makeSale(address user_wallet, uint256 amount, uint256 sale_id, uint40 time);

    constructor(address payable companyAccount, address payable member000, address payable member001, address payable member002, IERC20 _token)  {
        compAcc = companyAccount;
        acc = member000;
        acc1 = member001;
        acc2 = member002;
        owner = payable(msg.sender);
        Token = _token;

        records[acc][100].time = uint40(block.timestamp);
        emit makeSale(acc, 0, 100, uint40(block.timestamp));

        records[acc1][101].time = uint40(block.timestamp);
        emit makeSale(acc1, 0, 101, uint40(block.timestamp));

        records[acc2][102].time = uint40(block.timestamp);
        emit makeSale(acc2, 0, 102, uint40(block.timestamp));
    }

    function addSale(uint256 _amt, uint256 sale_id) external {
        Token.transferFrom(msg.sender, address(this), _amt);
        records[msg.sender][sale_id].amount = _amt;
        records[msg.sender][sale_id].adm_acc = 0;
        records[msg.sender][sale_id].level1 = 0;
        records[msg.sender][sale_id].level2 = 0;
        records[msg.sender][sale_id].level3 = 0;
        records[msg.sender][sale_id].manager = 0;
        records[msg.sender][sale_id].district = 0;
        records[msg.sender][sale_id].director = 0;
        records[msg.sender][sale_id].time = uint40(block.timestamp);
		Token.transfer(compAcc, (_amt/2));
		emit makeSale(msg.sender, _amt, sale_id, uint40(block.timestamp));
    }

    function addCommission(uint256 _amt, uint256 sale_id, address wallet, uint256 ctype) external {
        if (msg.sender == owner) {
            Token.transfer(wallet, _amt);
            if (ctype == 0) {records[wallet][sale_id].adm_acc = _amt;}
            if (ctype == 1) {records[wallet][sale_id].level1 = _amt;}
            if (ctype == 2) {records[wallet][sale_id].level2 = _amt;}
            if (ctype == 3) {records[wallet][sale_id].level3 = _amt;}
            if (ctype == 4) {records[wallet][sale_id].manager = _amt;}
            if (ctype == 5) {records[wallet][sale_id].district = _amt;}
            if (ctype == 6) {records[wallet][sale_id].director = _amt;}
        } else {
            revert("permission denied");
        }
    }

    function orderHistory(uint256 sale_id) view external returns (
        uint256 amount,
        uint256 level1,
        uint256 level2,
        uint256 level3,
        uint256 manager,
        uint256 district,
        uint256 director,
        uint40 time
    ) {
        amount = records[msg.sender][sale_id].amount;
        level1 = records[msg.sender][sale_id].level1;
        level2 = records[msg.sender][sale_id].level2;
        level3 = records[msg.sender][sale_id].level3;
        manager = records[msg.sender][sale_id].manager;
        district = records[msg.sender][sale_id].district;
        director = records[msg.sender][sale_id].director;
        time = records[msg.sender][sale_id].time;
    }

    function setNewOwner(address payable new_owner) external {
        if (msg.sender == owner) {
            owner = new_owner;
        }
        else {
            revert("permission denied");
        }
    }

    function setNewCompanyAccount(address payable new_master) external {
        if (msg.sender == owner) {
            acc = new_master;
        }
        else {
            revert("permission denied");
        }
    }

    function setNewCompanyAccount1(address payable new_master) external {
        if (msg.sender == owner) {
            acc1 = new_master;
        }
        else {
            revert("permission denied");
        }
    }

    function setNewCompanyAccount2(address payable new_master) external {
        if (msg.sender == owner) {
            acc2 = new_master;
        }
        else {
            revert("permission denied");
        }
    }

}