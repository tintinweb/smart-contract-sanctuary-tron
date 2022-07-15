//SourceUnit: tronbeary.sol

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT
// developed 0xDN1N89N

library EnumerableSet {
    struct UintSet {
        uint256[] _values;
        mapping (uint256 => uint256) _indexes;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        if (contains(set, value)) {
            return false;
        }

        set._values.push(value);
        set._indexes[value] = set._values.length;
        return true;
    }


    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { 
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            uint256 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1;
            set._values.pop();
            delete set._indexes[value];

            return true;
        } 
        else {
            return false;
        }
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        require(set._values.length < index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    function values(UintSet storage set) internal view returns (uint256[] memory _vals) {
        return set._values;
    }
}



library Errors {
    string constant NOT_OWNER = 'Only owner';
    string constant INVALID_TOKEN_ID = 'Invalid token id';
    string constant MINTING_DISABLED = 'Minting disabled';
    string constant TRANSFER_NOT_APPROVED = 'Transfer not approved by owner';
    string constant OPERATION_NOT_APPROVED = 'Operations with token not approved';
    string constant ZERO_ADDRESS = 'Address can not be 0x0';
    string constant ALL_MINTED = "All tokens are minted";
    string constant NOT_ENOUGH_TRX = "Insufficient funds to purchase";
    string constant WRONG_FROM = "The 'from' address does not own the token";
    string constant MARKET_MINIMUM_PRICE = "Market price cannot be lowet then 'minimumMarketPrice'";
    string constant MARKET_ALREADY_ON_SALE = 'The token is already up for sale';
    string constant MARKET_NOT_FOR_SALE = 'The token is not for sale';
    string constant REENTRANCY_LOCKED = 'Reentrancy is locked';
    string constant MARKET_IS_LOCKED = 'Market is locked';
    string constant MARKET_DISABLED = 'Market is disabled';
    string constant MIGRATION_COMPLETE = 'Migration is already completed';
    string constant RANDOM_FAIL = 'Random generation failed';
}



library Utils {
    function uintToString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}


interface ITRC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);

}

interface ITRC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface ITRC721TokenReceiver {
    function onTRC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

interface ITRC721Metadata {
    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);
}


interface ITRC721Enumerable {
    function totalSupply() external view returns (uint256);

    function tokenByIndex(uint256 _index) external view returns (uint256);

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}


contract TronBearyClub is ITRC721, ITRC165, ITRC721Metadata, ITRC721Enumerable {
    using EnumerableSet for EnumerableSet.UintSet;

    string internal _name = "TronBearyClub";
    string internal _symbol = "TBC";

    uint256 internal totalMinted = 0;
    uint256 internal totalMigrated = 0;

    uint256 public constant MINTING_LIMIT = 10000;

    uint256 public mintingPrice = 100000000;
    uint256 public minimumMarketPrice = 100000000;

    uint256 internal devComissionNom = 1;
    uint256 internal devComissionDenom = 100;

    bool internal isReentrancyLock = false;
    bool internal isMarketLocked = false;
    address internal contractOwner;
    address internal addressZero = address(0);

    bytes4 internal constant MAGIC_ON_TRC721_RECEIVED = 0x150b7a02;


    uint256 internal nonce = 0;
    uint256[MINTING_LIMIT] internal indices;

    mapping(bytes4 => bool) internal supportedInterfaces;

    mapping (uint256 => address) internal tokenToOwner;
    mapping (address => EnumerableSet.UintSet) internal ownerToTokensSet;
    mapping (uint256 => address) internal tokenToApproval;

    mapping (address => mapping (address => bool)) internal ownerToOperators;

    bool public isMintingEnabled = false;
    bool public isMarketEnabled = false;

    bool public isMigrationFuncsEnabled = true;

    struct MarketLot {
        uint256 tokenId;
        bool isForSale;
        address owner;
        uint256 price;
    }
    
    EnumerableSet.UintSet internal tokensOnSale;
    mapping (uint256 => MarketLot) internal marketLots;


    constructor() {
        supportedInterfaces[0x01ffc9a7] = true; // TRC165
        supportedInterfaces[0x80ac58cd] = true; // TRC721
        supportedInterfaces[0x780e9d63] = true; // TRC721Enumerable
        supportedInterfaces[0x5b5e139f] = true; // TRC721Metadata

        contractOwner = msg.sender;
    }


    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 _tokenId) external view override returns (string memory) {
        return string(abi.encodePacked("https://tronbearyclub.com/metadata/json/", Utils.uintToString(_tokenId), ".json"));
    }


    function totalSupply() public view override returns(uint256) {
        return (totalMinted + totalMigrated);
    }

    function tokenByIndex(uint256 _index) external view override returns (uint256) {
        require(_index >= 0 && _index < MINTING_LIMIT);
        return _index + 1;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view override returns (uint256 _tokenId) {
        require(_index < ownerToTokensSet[_owner].values().length);
        return ownerToTokensSet[_owner].values()[_index];
    }

    function getNotMintedAmount() external view returns(uint256) {
        return MINTING_LIMIT - (totalMinted + totalMigrated);
    }

    function supportsInterface(bytes4 _interfaceID) external view override returns (bool) {
        return supportedInterfaces[_interfaceID];
    }

    function balanceOf(address _owner) external view override returns (uint256) {
        return ownerToTokensSet[_owner].values().length;
    }

    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return tokenToOwner[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) 
        external override payable 
    {
        _safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) 
        external payable override
    {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override
        transferApproved(_tokenId)
        validTokenId(_tokenId) 
        notZeroAddress(_to)
    {
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external override payable
        validTokenId(_tokenId)
        canOperate(_tokenId)
    {
        address tokenOwner = tokenToOwner[_tokenId];
        if (_approved != tokenOwner) {
            tokenToApproval[_tokenId] = _approved;
            emit Approval(tokenOwner, _approved, _tokenId);
        }
    }

    function setApprovalForAll(address _operator, bool _approved) external override {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view override validTokenId(_tokenId)
        returns (address) 
    {
        return tokenToApproval[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
        return ownerToOperators[_owner][_operator];
    }


    function getUserTokens(address _user) external view returns (uint256[] memory) {
        return ownerToTokensSet[_user].values();
    }

    function mint() external payable reentrancyGuard mintingEnabled returns (uint256) {
        require(msg.value >= mintingPrice, Errors.NOT_ENOUGH_TRX);

        if (msg.value > mintingPrice) {
            payable(msg.sender).transfer(msg.value - mintingPrice);
        }

        return _mint(msg.sender);
    }


    function buyFromMarket(uint256 _tokenId, address _to) external payable
        notZeroAddress(_to) 
        marketEnabled 
        marketLock
    {
        require(marketLots[_tokenId].isForSale, Errors.MARKET_NOT_FOR_SALE);

        uint256 _price = marketLots[_tokenId].price;
        require(msg.value >= marketLots[_tokenId].price, Errors.NOT_ENOUGH_TRX);

        if (msg.value > marketLots[_tokenId].price) {
            payable(msg.sender).transfer(msg.value - _price);
        }

        uint256 devComission = _price * devComissionNom / devComissionDenom;
        payable(contractOwner).transfer(devComission);
        payable(tokenToOwner[_tokenId]).transfer(_price - devComission);
        emit MarketTrade(_tokenId, tokenToOwner[_tokenId], _to, msg.sender, _price);
        
        _transfer(tokenToOwner[_tokenId], _to, _tokenId);
    }


    function putOnMarket(uint256 _tokenId, uint256 price) external canOperate(_tokenId) marketEnabled marketLock {
        require(!marketLots[_tokenId].isForSale, Errors.MARKET_ALREADY_ON_SALE);
        require(price >= minimumMarketPrice, Errors.MARKET_MINIMUM_PRICE);

        marketLots[_tokenId] = MarketLot(_tokenId, true, tokenToOwner[_tokenId], price);
        tokensOnSale.add(_tokenId);

        emit TokenOnSale(_tokenId, tokenToOwner[_tokenId], price);
    }

    function changeLotPrice(uint256 _tokenId, uint256 newPrice) external canOperate(_tokenId) marketEnabled marketLock {
        require(marketLots[_tokenId].isForSale, Errors.MARKET_NOT_FOR_SALE);
        require(newPrice >= minimumMarketPrice, Errors.MARKET_MINIMUM_PRICE);

        emit TokenMarketPriceChange(_tokenId, tokenToOwner[_tokenId], marketLots[_tokenId].price, newPrice);

        marketLots[_tokenId].price = newPrice;
    }

    function withdrawFromMarket(uint256 _tokenId) external canOperate(_tokenId) marketLock {
        _removeFromMarket(_tokenId);

        emit TokenNotOnSale(_tokenId, tokenToOwner[_tokenId]);
    }


    function _removeFromMarket(uint256 _tokenId) internal {
        if (marketLots[_tokenId].isForSale) {
            delete marketLots[_tokenId];
            tokensOnSale.remove(_tokenId);
        }
    }

    function getMarketLotInfo(uint256 _tokenId) external view returns(MarketLot memory) {
        require(marketLots[_tokenId].isForSale, Errors.MARKET_NOT_FOR_SALE);

        return marketLots[_tokenId];
    }

    function getTokensOnSale() external view returns(uint256[] memory) {
        return tokensOnSale.values();
    }

    function _mint(address _to) internal notZeroAddress(_to) returns (uint256 _mintedTokenId) {
        require((totalMinted + totalMigrated) < MINTING_LIMIT, Errors.ALL_MINTED);
        uint randomId = _tryGenerateRandomId();
        totalMinted++;

        if (randomId == 0) {
            randomId = _tryGenerateRandomId();
            totalMinted++;
        }

        if (randomId != 0) {
            _addToken(_to, randomId);

            emit Mint(randomId, msg.sender, _to);
            emit Transfer(addressZero, _to, randomId);
        } else {
            emit MigrationMintCollision(msg.sender);
        }

        return randomId;
    }
    

    function _addToken(address _to, uint256 _tokenId) private notZeroAddress(_to) {
        tokenToOwner[_tokenId] = _to;
        ownerToTokensSet[_to].add(_tokenId);
    }
    

    function _removeToken(address _from, uint256 _tokenId) private {
        if (tokenToOwner[_tokenId] != _from)
            return;
        
        if (tokenToApproval[_tokenId] != addressZero)
            delete tokenToApproval[_tokenId];
        
        delete tokenToOwner[_tokenId];
        ownerToTokensSet[_from].remove(_tokenId);

        isMarketLocked = true;
        _removeFromMarket(_tokenId);
        isMarketLocked = false;
    }


    function _transfer(address _from, address _to, uint256 _tokenId) private {
        require(tokenToOwner[_tokenId] == _from, Errors.WRONG_FROM);
        _removeToken(_from, _tokenId);
        _addToken(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function _safeTransferFrom(address _from,  address _to,  uint256 _tokenId,  bytes memory _data) private 
        transferApproved(_tokenId) 
        validTokenId(_tokenId) 
        notZeroAddress(_to)
    {
        _transfer(_from, _to, _tokenId);

        if (isContract(_to)) {
            bytes4 retval = ITRC721TokenReceiver(_to).onTRC721Received(msg.sender, _from, _tokenId, _data);
            require(retval == MAGIC_ON_TRC721_RECEIVED);
        }
    }

    function _enableMinting() external onlyContractOwner {
        if (!isMintingEnabled) {
            isMintingEnabled = true;
            isMigrationFuncsEnabled = false;
            emit MintingEnabled();
        }
    }

    function _disableMinting() external onlyContractOwner {
        if (isMintingEnabled) {
            isMintingEnabled = false;
            emit MintingDisabled();
        }
    }

    function _setMintingPrice(uint256 newPrice) external onlyContractOwner {
        mintingPrice = newPrice;
    }

    function _setMinimumMarketPrice(uint256 newPrice) external onlyContractOwner marketLock {
        require(newPrice <= minimumMarketPrice, "The minimum price cannot be increased");
        require(newPrice > 0, "Price must be greater than zero");
        minimumMarketPrice = newPrice;
    }

    function _claimTRX(uint256 amount) external onlyContractOwner {
        payable(contractOwner).transfer(amount);
    }

    function _setDevComission(uint256 newNom, uint256 newDenom) external onlyContractOwner {
        devComissionNom = newNom;
        devComissionDenom = newDenom;
    }

    function _enableMarket() external onlyContractOwner {
        if (!isMarketEnabled) {
            isMarketEnabled = true;
            emit MarketEnabled();
        }
    }

    function _disableMarket() external onlyContractOwner {
        if (isMarketEnabled) {
            isMarketEnabled = false;
            emit MarketDisabled();
        }
    }

    function _migrateToken(uint256 _tokenId, address _to) external isMigration onlyContractOwner notZeroAddress(_to) {
        if (tokenToOwner[_tokenId] != addressZero) {
            revert();
        }
        _addToken(_to, _tokenId);
        totalMigrated++;
        emit TokenMigration(_tokenId, msg.sender, _to);
        emit Transfer(addressZero, _to, _tokenId);
    }


    function _migrateTokens(uint256[] memory _tokenId, address[] memory _to) external isMigration onlyContractOwner {
        uint256 arrayLength = _tokenId.length;
        for (uint256 id = 0; id < arrayLength; id++) {
            if (tokenToOwner[_tokenId[id]] == addressZero) {
                _addToken(_to[id], _tokenId[id]);
                totalMigrated++;
            }
            emit TokenMigration(_tokenId[id], msg.sender, _to[id]);
            emit Transfer(addressZero, _to[id], _tokenId[id]);
        }
    }

    function withdraw() external onlyContractOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
    

    function isContract(address _addr) internal view returns (bool addressCheck) {
        uint256 size;
        assembly { size := extcodesize(_addr) }
        addressCheck = size > 0;
    }


    function _tryGenerateRandomId() private returns (uint256) {
        uint256 randId = _generateRandomId();
        
        if (tokenToOwner[randId] != address(0)) {
            totalMigrated--;
        }

        if (tokenToOwner[randId] == addressZero) {
            return randId;
        } else {
            return 0;
        }
    }


    function _generateRandomId() private returns (uint256) {
        uint256 totalSize = MINTING_LIMIT - totalMinted;
        uint256 index = uint256(keccak256(abi.encodePacked(nonce, msg.sender, block.difficulty, block.timestamp))) % totalSize;
        uint256 value = 0;

        if (indices[index] != 0) {
            value = indices[index];
        } else {
            value = index;
        }

        if (indices[totalSize - 1] == 0) {
            indices[index] = totalSize - 1; 
        } else { 
            indices[index] = indices[totalSize - 1];   
        }
        nonce++;
        return value + 1;
    }

    function getDevComission() external view returns(uint256 nominator, uint256 denominator) {
        return (devComissionNom, devComissionDenom);
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, Errors.NOT_OWNER);
        _;
    }

    modifier reentrancyGuard {
        if (isReentrancyLock) {
            require(!isReentrancyLock, Errors.REENTRANCY_LOCKED);
        }
        isReentrancyLock = true;
        _;
        isReentrancyLock = false;
    }

    modifier validTokenId(uint256 _tokenId) {
        require(tokenToOwner[_tokenId] != addressZero, Errors.INVALID_TOKEN_ID);
        _;
    }

    modifier mintingEnabled() {
        require(isMintingEnabled, Errors.MINTING_DISABLED);
        _;
    }

    modifier transferApproved(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender  || 
            tokenToApproval[_tokenId] == msg.sender || 
            (ownerToOperators[tokenOwner][msg.sender] && tokenOwner != addressZero), 
            Errors.TRANSFER_NOT_APPROVED
        );
        _;
    }

    modifier canOperate(uint256 _tokenId) {
        address tokenOwner = tokenToOwner[_tokenId];
        require(
            tokenOwner == msg.sender || 
            (ownerToOperators[tokenOwner][msg.sender] && tokenOwner != addressZero), 
            Errors.OPERATION_NOT_APPROVED
        );
        _;
    }

    modifier notZeroAddress(address _addr) {
        require(_addr != addressZero, Errors.ZERO_ADDRESS);
        _;
    }

    modifier marketLock {
        if (isMarketLocked) {
            require(!isMarketLocked, Errors.MARKET_IS_LOCKED);
        }
        isMarketLocked = true;
        _;
        isMarketLocked = false;
    }

    modifier marketEnabled {
        require(isMarketEnabled, Errors.MARKET_DISABLED);
        _;
    }

    modifier isMigration {
        require(isMigrationFuncsEnabled, Errors.MIGRATION_COMPLETE);
        _;
    }

    event MarketTrade(uint256 indexed _tokenId, address indexed _from, address indexed _to, address buyer, uint256 _price);
    event TokenMigration(uint indexed tokenId, address indexed mintedBy, address indexed mintedTo);
    event MigrationMintCollision(address indexed mintedBy);
    event Mint(uint indexed tokenId, address indexed mintedBy, address indexed mintedTo);
    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    event TokenOnSale(uint256 indexed _tokenId, address indexed _owner, uint256 _price);
    event TokenNotOnSale(uint256 indexed _tokenId, address indexed _owner);
    event TokenMarketPriceChange(uint256 indexed _tokenId, address indexed _owner, uint256 _oldPrice, uint256 _newPrice);
    event MintingEnabled();
    event MintingDisabled();
    event MarketEnabled();
    event MarketDisabled();
}