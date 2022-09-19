//SourceUnit: IRCBC.sol

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

interface IRCBC {
    function balanceOf(address _address) external returns(uint);

    function transfer(address _to, uint _value) external;
}


//SourceUnit: IRCFactory.sol

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

interface IRCFactory {
    function contracts(address _contract) external returns(address);

    function calcStakeScore() external;
}


//SourceUnit: IRCService.sol

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

interface IRCService {
    function calcStakeScore() external;
}


//SourceUnit: RCStaking.sol

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

import "./IRCFactory.sol";
import "./IRCBC.sol";
import "./IRCService.sol";

contract RCStaking {
    struct Weight {
        address service;
        uint weights;
    }

    IRCBC public constant RCBC = IRCBC(0x0ce717CD62D2aEcBfbFBe76fB1eDEb5bb0fcEd50);
    IRCFactory public constant RC_FACTORY = IRCFactory(0xe2Ee8cC54e1e7F43D3F5aF64ba56ABaa652Ce402);
    uint public stakedAt;
    uint public lastCalcAt;
    uint public stakeAggregatedWeights;
    uint public partialAggregatedWeights;
    uint public partialAmount;
    bool public partialWithdrawal;
    Weight[] public stakeWeights;
    Weight[] public partialWeights;

    modifier onlyPartialMode() {
        require(partialWithdrawal, "not partial mode");
        _;
    }

    modifier onlyRCFactory() {
        require(msg.sender == address(RC_FACTORY), "not factory");
        _;
    }

    function setLastStakeUpdate() external onlyRCFactory {
        stakedAt = block.number;
    }

    function areWeightsActual() public view returns (bool) {
        return stakedAt != 0 && stakedAt + 100 < lastCalcAt;
    }

    function calcStakeWeights(address _address) public {
        if (!areWeightsActual()) {
            stakeAggregatedWeights = 0;
            delete stakeWeights;
            IRCService(_address).calcStakeScore();
            lastCalcAt = block.number;
        }
    }

    function setStakeWeight(address _address, uint _weight) external onlyRCFactory {
        bool _isExist;
        for (uint i; i < stakeWeights.length; i++) {
            if (stakeWeights[i].service == _address) {
                stakeWeights[i].weights += _weight;
                _isExist = true;
                break;
            }
        }
        if (!_isExist) stakeWeights.push(Weight(_address, _weight));

        stakeAggregatedWeights += _weight;
    }

    function togglePartialMode() external {
        require(!partialWithdrawal, "not full mode");
        require(RC_FACTORY.contracts(msg.sender) != address(0), "invalid address");
        delete partialWeights;
        for (uint i; i < stakeWeights.length; i++) {
            if (stakeWeights[i].weights > 0) partialWeights.push(stakeWeights[i]);
        }
        partialAggregatedWeights = stakeAggregatedWeights;
        partialAmount = RCBC.balanceOf(address(this));
        partialWithdrawal = true;
    }

    function cascadeStake() external {
        _stakeDistributor(false, address(RC_FACTORY));
    }

    function getStake() external {
        getStakeFor(msg.sender);
    }

    function getStakeFor(address _address) public onlyPartialMode {
        address _service = RC_FACTORY.contracts(_address);
        require(_service != address(0), "invalid address");
        _stakeDistributor(true, _service);
    }

    function getStakeWeight(bool _isPartialMode, address _address) external view returns (uint) {
        if (_isPartialMode) {
            for (uint i; i < partialWeights.length; i++) {
                if (partialWeights[i].service == _address) return partialWeights[i].weights;
            }
        } else {
            for (uint i; i < stakeWeights.length; i++) {
                if (stakeWeights[i].service == _address) return stakeWeights[i].weights;
            }
        }
        return 0;
    }

    function _stakeDistributor(bool _isPartial, address _targetAddr) internal {
        if (!_isPartial) {
            if (partialWithdrawal) _stakeDistributor(true, _targetAddr);
            calcStakeWeights(_targetAddr);
        }

        if (_targetAddr == address(RC_FACTORY)) {
            if (_isPartial) {
                for (uint i; i < partialWeights.length; i++) {
                    if (partialWeights[i].weights > 0) {
                        uint _profit = partialAmount * (partialWeights[i].weights * 100 / partialAggregatedWeights) / 100;
                        partialWeights[i].weights = 0;
                        RCBC.transfer(partialWeights[i].service, _profit);
                    }
                }
                partialAmount = 0;
                if (partialWithdrawal) partialWithdrawal = false;
            } else {
                uint _stakeBalance = RCBC.balanceOf(address(this));
                for (uint i; i < stakeWeights.length; i++) {
                    if (stakeWeights[i].weights > 0) {
                        uint _profit = _stakeBalance * (stakeWeights[i].weights * 100 / stakeAggregatedWeights) / 100;
                        RCBC.transfer(stakeWeights[i].service, _profit);
                    }
                }
            }
        }

        if (_targetAddr != address(RC_FACTORY) && partialWithdrawal) {
            for (uint i; i < partialWeights.length; i++) {
                if (partialWeights[i].service == _targetAddr) {
                    if (partialWeights[i].weights > 0) {
                        uint _profit = partialAmount * (partialWeights[i].weights * 100 / partialAggregatedWeights) / 100;
                        partialWeights[i].weights = 0;
                        RCBC.transfer(_targetAddr, _profit);
                    }
                    break;
                }
            }
        }
    }
}