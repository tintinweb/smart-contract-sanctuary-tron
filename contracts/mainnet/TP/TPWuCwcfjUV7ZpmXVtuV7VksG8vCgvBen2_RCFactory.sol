//SourceUnit: ERC721.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./IERC721Enumerable.sol";
import "./IERC165.sol";

contract ERC721 is IERC721 {
    string _name;
    string _symbol;
    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals;
    mapping(uint => string) _tokenURIs;

    modifier isExistToken(uint tokenId) {
        require(_owners[tokenId] != address(0), "invalid token ID");
        _;
    }

    modifier correctAddress(address _address) {
        require(_address != address(0), "zero address");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return
        interfaceId == type(IERC721).interfaceId ||
        interfaceId == type(IERC721Metadata).interfaceId ||
        interfaceId == type(IERC721Enumerable).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }

    function name() external override view returns(string memory) {
        return _name;
    }

    function symbol() external override view returns(string memory) {
        return _symbol;
    }

    function tokenURI(uint tokenId) external view isExistToken(tokenId) override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function balanceOf(address owner) public view override correctAddress(owner) returns (uint) {
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view isExistToken(tokenId) override returns (address) {
        return _owners[tokenId];
    }

    function approve(address to, uint tokenId) external override {
        address owner = ownerOf(tokenId);
        require(to != owner, "approval to current owner");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "approve caller is not token owner or approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint tokenId) public view isExistToken(tokenId) override returns (address) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        require(msg.sender != operator, "approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory data
    ) public override {
        require(_checkOnERC721Received(from, to, tokenId, data), "transfer to non ERC721Receiver implementer");
        _transfer(from, to, tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint tokenId
    ) internal correctAddress(to) {
        require(isApprovedForAll(from, msg.sender) || getApproved(tokenId) == msg.sender, "not approve");
        require(ownerOf(tokenId) == from, "not token owner");

         _beforeTokenTransfer(from, to, tokenId);

        delete _tokenApprovals[tokenId];

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory data
    ) internal returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}
}


//SourceUnit: ERC721Enumerable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC721Enumerable.sol";
import "./ERC721.sol";

abstract contract ERC721Enumerable is IERC721Enumerable, ERC721 {
    mapping(address => mapping(uint => uint)) _ownedTokens;
    mapping(uint => uint) _ownedTokensIndex;
    uint[] _allTokens;
    mapping(uint => uint) _allTokensIndex;

    function tokenOfOwnerByIndex(address owner, uint index) external view override returns (uint) {
        require(index < balanceOf(owner), "owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view override returns (uint) {
        return _allTokens.length;
    }

    function tokenByIndex(uint index) external override view returns (uint) {
        require(index < _allTokens.length, "global index out of bounds");
        return _allTokens[index];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to) {
            _addTokenToOwnerEnumeration(to, tokenId);
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint tokenId) internal {
        uint length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
        uint lastTokenIndex = balanceOf(from) - 1;
        uint tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
}


//SourceUnit: IERC165.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external pure returns (bool);
}


//SourceUnit: IERC721.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC165.sol";
import "./IERC721Metadata.sol";

interface IERC721 is IERC165, IERC721Metadata {
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId, bytes calldata data) external;

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


//SourceUnit: IERC721Enumerable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC721.sol";

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint);

    function tokenOfOwnerByIndex(address owner, uint index) external view returns (uint);

    function tokenByIndex(uint index) external view returns (uint);
}


//SourceUnit: IERC721Metadata.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC721.sol";

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint tokenId) external view returns (string memory);
}


//SourceUnit: IERC721Receiver.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns (bytes4);
}


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

    function decimals() external returns(uint);

    function transfer(address _to, uint _value) external;

    function transferFrom(address _from, uint _value) external returns (bool);
}


//SourceUnit: IRCListContract.sol

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

interface IRCListContract {
    function isPermittedService(address _address) external returns (bool);
}


//SourceUnit: IRCMarket.sol

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

interface IRCMarket {
    function isAuction(address _address) external returns(bool);
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
    /// @return Флаг бана контракта
    function banned() external returns(bool);

    /// @return Количество застейканых монет RCBC
    function stakedAmount() external returns(uint);

    /// @return Номер блока, когда был сделан стейкинг
    function stakedAt() external returns(uint);

    /// @return Количество монет, доступных для снятия
    function calculatedEarnings() external returns(uint);

    /// @param _index Индекс для поиска
    /// @return Сервисный адрес контракта реферала
    function referrals(uint _index) external returns(address);

    /// @return Адрес сервисного контракта реферрера
    function referrer() external returns(address);

    /// @notice Подсчет количества токенов RCBC, которые есть на балансе, но еще не были учтены для расчетов
    /// @return Количество неучтенных токенов
    function getUncalculatedAmount() external returns(uint);

    /// @notice Расчет вознаграждения
    function calc() external;

    /// @notice Запускает расчет вознаграждения у текущего контракта и рефералов по иерархии ниже
    function calcProfit() external;

    /// @notice Выплата клиенту уже подсчитанного вознаграждения. Может вызвать только клиент
    function claimEarnings() external;

    /// @notice Вызывает поочередно методы calc и claimEarnings
    function claim() external;

    /// @notice Стейкинг токена RCBC. Перед вызовом надо в контракте токена вызвать метод approve с указанием
    /// адреса текущего контракта и суммы стейкинга. Может вызвать только клиент
    /// @param _tokenAmount Количество токенов для стейкинга
    function lockStake(uint _tokenAmount) external;

    /// @notice Переводит клиенту застейканную сумму. Может вызвать только клиент
    function unlockStake() external;

    /// @notice Подсчет веса суммы стейка клиента и рекурсивно его рефералов по иерархии ниже
    function calcStakeScore() external;
}


//SourceUnit: IRCStaking.sol

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

interface IRCStaking {
    function setStakeWeight(address _address, uint _weight) external;

    function setLastStakeUpdate() external;
}


//SourceUnit: RCFactory.sol

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

import "./RCService.sol";
import "./IRCBC.sol";
import "./IRCStaking.sol";
import "./IRCMarket.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";

contract RCFactory is ERC721Enumerable {
    IRCBC public constant RCBC = IRCBC(0x0ce717CD62D2aEcBfbFBe76fB1eDEb5bb0fcEd50);
    address owner = msg.sender;
    address governor;
    address public rcMarket;
    IRCStaking public RCStaking;
    uint public stakedAmount;
    uint public stakedAt;
    address[] public referrals;
    mapping(address => address) public contracts;

    modifier onlyGovernor() {
        require(msg.sender == governor, "not governor");
        _;
    }

    modifier onlyNotExist(address _address) {
        require(_address == address(0), "already exist");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier checkSender(address _address) {
        require(msg.sender == _address, "invalid sender");
        _;
    }

    constructor() ERC721("Real Colibri ID NFT", "RCID")  {
        contracts[address(this)] = address(this);
    }

    function mint(address _referrer) external returns (address) {
        address _refService = contracts[_referrer];
        require(_refService != address(0), "invalid address");
        return _safeMint(_refService, msg.sender);
    }

    function mintFrom(address _referral) external {
        require(IRCMarket(rcMarket).isAuction(msg.sender), "invalid sender");
        _safeMint(address(this), _referral);
    }

    function setReferrer(address _service, address _referrer) external onlyNotExist(governor) onlyOwner  {
        RCService(_service).setReferrer(_referrer);
    }

    function setMarket(address _market) external onlyNotExist(rcMarket) onlyOwner {
        rcMarket = _market;
    }

    function setGovernor(address _governor) external onlyNotExist(governor) onlyOwner {
        governor = _governor;
    }

    function setStakingContract(address _address) external onlyNotExist(address(RCStaking)) onlyOwner {
        RCStaking = IRCStaking(_address);
    }

    function setBanned(address _address, bool _banned) external onlyGovernor {
        require(contracts[_address] != address(0) && _address != address(this), "invalid address");
        RCService(contracts[_address]).setBanned(_banned);
    }

    function calcProfit() external {
        for (uint i = 0; i < referrals.length; i++) {
            RCService(referrals[i]).calcProfit();
        }
    }

    function claim() external onlyGovernor {
        RCBC.transfer(governor, RCBC.balanceOf(address(this)) - stakedAmount);
    }

    function lockStake(uint _tokenAmount) external {
        RCBC.transferFrom(msg.sender, _tokenAmount);
        if (stakedAmount == 0) {
            stakedAt = block.number;
        } else if (_tokenAmount < stakedAmount) {
            uint _delta = block.number - stakedAt;
            uint _diff = stakedAmount - _tokenAmount;
            uint _shift = ((_delta * _diff * 100) / stakedAmount) / 100;
            if (_shift == 0) {
                stakedAt += 1;
            } else {
                stakedAt += _shift;
            }
        }
        stakedAmount += _tokenAmount;
        RCStaking.setLastStakeUpdate();
    }

    function unlockStake() external onlyGovernor {
        RCBC.transfer(governor, stakedAmount);
        stakedAmount = 0;
        stakedAt = 0;
        RCStaking.setLastStakeUpdate();
    }

    function calcStakeScore() external {
        uint _stakeWeight = 10_000;
        uint _intervalsCount = (block.number - stakedAt) / 1_000_000;
        uint _addingRatio = 25;
        while (_intervalsCount > 0 && _stakeWeight < 160_000) {
            _stakeWeight += _addingRatio;
            if (_addingRatio == 25) _addingRatio = 240;
            else if (_addingRatio > 50) _addingRatio -= 10;
            _intervalsCount -= 1;
        }
        RCStaking.setStakeWeight(address(this), _stakeWeight * stakedAmount);

        for (uint i = 0; i < referrals.length; i++) {
            RCService(referrals[i]).calcStakeScore();
        }
    }

    function setStakeWeight(address _clientAddr, uint _weight) external checkSender(contracts[_clientAddr]) {
        RCStaking.setStakeWeight(contracts[_clientAddr], _weight);
    }

    function setLastStakeUpdate(address _clientAddr) external checkSender(contracts[_clientAddr]) {
        RCStaking.setLastStakeUpdate();
    }

    function setTokenURI(uint tokenId, string calldata _tokenURI) external isExistToken(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "not token owner");
        if (msg.sender != governor) RCBC.transferFrom(msg.sender, 100 * RCBC.decimals());
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _safeMint(address _refService, address _referral) internal onlyNotExist(contracts[_referral]) returns (address _service) {
        uint _tokenId = totalSupply() + 1;
        require(_checkOnERC721Received(address(this), _referral, _tokenId, bytes("")), "transfer to non ERC721Receiver implementer");

        _service = address(new RCService(_referral, _refService, address(this)));
        if (_refService == address(this)) referrals.push(_service);
        else RCService(_refService).setReferral(_service);
        contracts[_referral] = _service;

        _owners[_tokenId] = _referral;
        _balances[_referral]++;
        _addTokenToOwnerEnumeration(_referral, _tokenId);
        _allTokens.push(_tokenId);

        emit Transfer(address(0), _referral, _tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal override(ERC721Enumerable) {
        require(rcMarket == msg.sender || IRCMarket(rcMarket).isAuction(msg.sender), "invalid sender");

        super._beforeTokenTransfer(from, to, tokenId);

        address _service = contracts[from];
        delete contracts[from];
        RCService(_service).setOwner(to);
        contracts[to] = _service;
    }
}


//SourceUnit: RCService.sol

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

import "./IRCBC.sol";
import "./RCFactory.sol";
import "./IRCListContract.sol";

contract RCService {
    IRCListContract constant RCListContract = IRCListContract(0xCbCC0acDDC61Bd18b0BB2cC349BAe02ce1CF3465);
    IRCBC public constant RCBC = IRCBC(0x0ce717CD62D2aEcBfbFBe76fB1eDEb5bb0fcEd50);
    address public immutable rcFactory;
    address public referrer;
    address public owner;
    bool public banned;
    uint public stakedAmount;
    uint public stakedAt;
    uint public calculatedEarnings;
    address[] public referrals;
    uint public calcProfitAt;
    uint public calcStakeScoreAt = block.number;
    uint public lastActivity = block.number;
    uint public lastAction = block.number;
    uint[] public lastFib = [0, 1];
    uint public doubleStake;
    uint8 public inactivityWeight;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyRCFactory() {
        require(msg.sender == rcFactory, "not factory");
        _;
    }

    constructor(address _owner, address _referrer, address _factory) {
        owner = _owner;
        rcFactory = _factory;
        referrer = _referrer;
    }

    function setReferrer(address _referrer) external onlyRCFactory {
        referrer = _referrer;
    }

    function setReferral(address _referral) external onlyRCFactory {
        referrals.push(_referral);
    }

    function setLastActivity(bool _action) public {
        require(RCListContract.isPermittedService(msg.sender), "invalid address");
        _setLastActivity(_action);
    }

    function ping() external onlyOwner {
        uint _fib = lastFib[1];
        uint _coast = _fib * 1_000_000_000_000_000_000;
        RCBC.transferFrom(owner, _coast);
        RCBC.transfer(rcFactory, _coast);
        lastFib[1] = lastFib[0] + _fib;
        lastFib[0] = _fib;
        _setLastActivity(true);
    }

    function setBanned(bool _banned) external onlyRCFactory {
        banned = _banned;
    }

    function setOwner(address _owner) external onlyRCFactory {
        owner = _owner;
    }

    function getUncalculatedAmount() public returns (uint) {
        return RCBC.balanceOf(address(this)) - calculatedEarnings - stakedAmount;
    }

    function calc() public {
        uint _amount = getUncalculatedAmount();
        if (!banned) {
            uint percent = 80;
            if (inactivityWeight == 1) percent = 50;
            else if (inactivityWeight == 2) percent = 20;
            else if (inactivityWeight == 3) percent = 10;
            else if (inactivityWeight == 4) percent = 5;
            uint _earnings = _amount * percent / 100;
            calculatedEarnings += _earnings;
            _amount -= _earnings;
        }
        RCBC.transfer(referrer, _amount);
    }

    function calcProfit() external {
        if (block.number - calcProfitAt > 1000) {
            if (referrals.length == 0) {
                inactivityWeight = 0;
            } else {
                uint totalWeight;
                uint activeCount;
                for (uint i = 0; i < referrals.length; i++) {
                    RCService(referrals[i]).calcProfit();
                    uint8 weight = RCService(referrals[i]).inactivityWeight();
                    if (weight == 0) activeCount += 1;
                    else totalWeight += uint(weight);
                }
                uint _diffAction = block.number - lastAction;
                uint _diffDouble = block.number - doubleStake;
                if (_diffAction < 288000 || _diffDouble < 288000 || activeCount >= 5) {
                    inactivityWeight = 0;
                    lastFib[0] = 0;
                    lastFib[1] = 1;
                } else if (_diffAction >= 288000 || _diffAction < 1000000) {
                    inactivityWeight = 1;
                } else if (_diffAction >= 1000000 || _diffAction < 2000000) {
                    inactivityWeight = 2;
                } else if ((totalWeight / referrals.length) < 2) {
                    inactivityWeight = 3;
                } else {
                    inactivityWeight = 4;
                }
            }
            calcProfitAt = block.number;
            calc();
        }
    }

    function claimEarnings() public onlyOwner {
        RCBC.transfer(owner, calculatedEarnings);
        calculatedEarnings = 0;
    }

    function claim() external {
        calc();
        claimEarnings();
    }

    function lockStake(uint _tokenAmount) external onlyOwner {
        RCBC.transferFrom(owner, _tokenAmount);
        if (stakedAmount == 0) {
            stakedAt = block.number;
        } else if (_tokenAmount < stakedAmount) {
            uint _delta = block.number - stakedAt;
            uint _diff = stakedAmount - _tokenAmount;
            uint _shift = ((_delta * _diff * 100) / stakedAmount) / 100;
            if (_shift == 0) {
                stakedAt += 1;
            } else {
                stakedAt += _shift;
            }
        } else {
            doubleStake = block.number;
        }
        stakedAmount += _tokenAmount;
        RCFactory(rcFactory).setLastStakeUpdate(owner);
    }

    function unlockStake() external onlyOwner {
        require(!banned, "banned");
        RCBC.transfer(owner, stakedAmount);
        stakedAmount = 0;
        stakedAt = 0;
        doubleStake = 0;
        RCFactory(rcFactory).setLastStakeUpdate(owner);
    }

    function calcStakeScore() external {
        if (block.number - calcProfitAt > 1000) {
            uint _stakeWeight = 10_000;
            uint _intervalsCount = (block.number - stakedAt) / 1_000_000;
            uint _addingRatio = 25;
            while (_intervalsCount > 0 && _stakeWeight < 160_000) {
                _stakeWeight += _addingRatio;
                if (_addingRatio == 25) _addingRatio = 240;
                else if (_addingRatio > 50) _addingRatio -= 10;
                _intervalsCount -= 1;
            }
            RCFactory(rcFactory).setStakeWeight(owner, _stakeWeight * stakedAmount);

            for (uint i = 0; i < referrals.length; i++) {
                RCService(referrals[i]).calcStakeScore();
            }

            calcStakeScoreAt = block.number;
        }
    }

    function _setLastActivity(bool _action) internal {
        lastActivity = block.number;
        if (_action) lastAction = block.number;
    }
}