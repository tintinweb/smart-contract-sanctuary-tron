//SourceUnit: RCListContract.sol

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

contract RCListContract {
    address governor;
    address owner = msg.sender;
    mapping(address => bool) list;

    modifier onlyOwner(address _address) {
        require(_address == msg.sender, "not owner");
        _;
    }

    function setGovernor(address _governor) external onlyOwner(owner) {
        require(governor == address(0), "already exist");
        governor = _governor;
    }

    function addService(address _address) external onlyOwner(governor) {
        list[_address] = true;
    }

    function removeService(address _address) external onlyOwner(governor) {
        list[_address] = false;
    }

    function isPermittedService(address _address) external view returns (bool) {
        return list[_address];
    }
}