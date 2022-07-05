//SourceUnit: rcbc.sol

/**
 SPDX-License-Identifier: AGPL-3.0

 RealColibri Coin is backed by the RealColibri system and has multiple use
 cases: fueling transactions on Tron chain, paying for transaction
 fees on RealColibri and many more.

 Copyright (C) 2022
 Authors: Alexey Vesnin, Aram Khachatrian, Maksim Shvets

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public v3 License as published
 by the Free Software Foundation.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.8.6;

contract RCBC {
    string public name = "RealColibri Coin";
    string public symbol = "RCBC";
    uint public decimals = 18;
    uint public totalSupply = 1_000_000_000_000_000_000_000_000_000_000;
    uint public coinRate = 10_000_000;
    address internal owner = msg.sender;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    constructor() {
        balanceOf[address(this)] = totalSupply;
        emit Transfer(address(0), address(this), totalSupply);
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier correctAddress(address _address) {
        require(_address != address(0), "zero address");
        _;
    }

    function _transfer(address _from, address _to, uint _value) internal correctAddress(_to) {
        require(balanceOf[_from] >= _value, "check balance");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint _value) external {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, uint _value) external returns (bool) {
        require(_value <= allowance[_from][msg.sender], "check allowance");
        _transfer(_from, msg.sender, _value);
        allowance[_from][msg.sender] -= _value;
        return true;
    }

    function approve(address _spender, uint _value) external correctAddress(_spender) returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function buy() external payable {
        _transfer(address(this), msg.sender, msg.value / coinRate * 1_000_000_000_000_000_000);
    }

    function sell(uint _value) external {
        uint _amount = _value / (coinRate / 100 * 100_000_000);
        require(_amount <= address(this).balance, "check contract balance");
        _transfer(msg.sender, address(this), _value);
        if (_amount > 0) {
            payable(msg.sender).transfer(_amount);
        }
    }

    function claim() external onlyOwner {
        uint _amountFreeze = (totalSupply - balanceOf[address(this)]) / (coinRate / 100 * 100_000_000) + 1_000_000;
        require(_amountFreeze <= address(this).balance, "check contract balance");
        payable(owner).transfer(address(this).balance - _amountFreeze);
    }

    function setOwner(address _owner) external onlyOwner correctAddress(_owner) {
        require(_owner != owner, "check new owner");
        owner = _owner;
    }
}