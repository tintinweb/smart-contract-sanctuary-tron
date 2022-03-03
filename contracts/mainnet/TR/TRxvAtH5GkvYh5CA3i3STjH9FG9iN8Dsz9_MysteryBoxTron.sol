//SourceUnit: MysteryBoxTron.sol

/*
    Copyright 2022 libertyland
    SPDX-License-Identifier: Apache-2.0
    Website: https://www.libertyland.finance/
    TLT: https://www.thelostthrone.net/
    CertikReport: https://www.certik.com/projects/the-lost-throne
*/
pragma solidity ^0.8.0;

interface ITheLostThroneCard {
    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external;
    function bacthMint(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) external;
    }

interface IRandomGenerator {
    function random(uint256 seed) external view returns (uint256);
    }

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() {
        _paused = false;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity ^0.8.1;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract MysteryBoxTron is Ownable, Initializable, Pausable, ERC721Holder {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    // ============ Storage ============
    bytes32 public constant CONTROL_TYPE = keccak256("GAME_BOX");
    address public _FEECOLLECTOR_;
    uint256 public _MINTED_;
    uint256 public _TRX_MINTED_;
    uint256 public _TOKEN_MINTED_;
    uint256 public _TRX_PRCIE_ = 1300 trx;
    uint256 public constant _TRX_MINTED_LIMIT_ = 2510;
    uint256 public _TOKEN_MINTED_LIMIT_ = 0;
    uint256 public _TOKEN_PRCIE_;
    IRandomGenerator private _RANDOM_;
    ITheLostThroneCard public _CARD_;
    IERC20 public _PAID_TOKEN_;
    bool public _SELL_START_ = false;
    mapping(IERC721 => bool) public white_tickets;
    // user rarity query for alloc
    mapping(uint256 => uint256[]) public rarity_alloc;
    // use rarity query for total alloc by rarity group
    mapping(uint256 => uint256) public rarity_alloc_total;
    // use rarity query for alloc, then get cid
    mapping(uint256 => mapping(uint256 => uint256[])) public rarity_alloc_cid;
    // ============ Event =============
    event UpdateWhiteTicekt(address ticket, bool state);
    event UpdateRandom(address randomGenerator);
    event UpdateCollector(address newCollector);
    event UpdatePaidToken(address paidToken, uint256 tokenPrice);
    event UpdateBucketNum(uint256 originNum, uint256 num);
    modifier whenSellStart() {
        require(_SELL_START_, "Not yet start");
        _;
    }
    fallback() external payable {}
    receive() external payable {}
    function init(
        IRandomGenerator randomGen,
        ITheLostThroneCard card,
        address owner,
        address fee
    ) external initializer {
        require(owner != address(0));
        transferOwnership(owner);
        _FEECOLLECTOR_ = fee;
        _RANDOM_ = randomGen;
        _CARD_ = card;
    }
    // =========== External =============
    // unlimited mysterybox pay by trx
    function mintByTRX(uint256 amount)
        external
        payable
        whenNotPaused
        whenSellStart
    {
        require(_TRX_PRCIE_ > 0,"Invalid trx price");
        require(
            _TRX_MINTED_ + amount <= _TRX_MINTED_LIMIT_,
            "TRX mint finished."
        );
        require(amount > 0 && amount <= 10, "Invalid mint amount");
        require(amount * _TRX_PRCIE_ <= msg.value, "Invalid payment amount");
        (bool success, ) = payable(_FEECOLLECTOR_).call{
            value: address(this).balance
        }(new bytes(0));
        require(success, "Transfer eth failed");
        _TRX_MINTED_ += amount;
        _mintCharacter(amount);
    }
    // unlimited mysterybox pay by token
    function mintByERC20(uint256 amount) external whenNotPaused {
        require(address(_PAID_TOKEN_) != address(0), "Paidtoken not yet");
        require(amount > 0 && amount <= 10, "Invalid mint amount");
        if (_TOKEN_MINTED_LIMIT_ > 0) {
            require(
                _TOKEN_MINTED_ + amount <= _TOKEN_MINTED_LIMIT_,
                "Token mint finished"
            );
        }
        uint256 cost = _TOKEN_PRCIE_ * amount;
        _PAID_TOKEN_.safeTransferFrom(msg.sender, _FEECOLLECTOR_, cost);
        _TOKEN_MINTED_ += amount;
        _mintCharacter(amount);
    }
    // unlimited mysterybox pay by white ticket
    function mintByTicket(uint256[] calldata tokenIds, IERC721 ticket)
        external
        whenNotPaused
    {
        require(address(ticket) != address(0), "not allowed");
        require(white_tickets[ticket], "only white ticket");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ticket.safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                "0x"
            );
        }
        _mintCharacter(tokenIds.length);
    }
    // ================= View ===================
    function _getOneRarity(uint256 num)
        internal
        view
        returns (uint256 rarity, uint256 seed)
    {
        seed = _RANDOM_.random(num + (gasleft()));
        rarity = _caculateRarity(seed % 100);
    }
    // =============== Internal  ================
    function _mintCharacter(uint256 num) internal {
        uint256[] memory cids = new uint256[](num);
        uint256[] memory amounts = new uint256[](num);
        for (uint256 i = 0; i < num; i++) {
            _MINTED_++;
            (uint256 rarity, uint256 seed) = _getOneRarity(_MINTED_);
            cids[i] = _pickUpCid(rarity, seed);
            amounts[i] = 1;
        }
        _CARD_.bacthMint(msg.sender, cids, amounts);
    }
    function _pickUpCid(uint256 rarity, uint256 seed)
        internal
        view
        returns (uint256)
    {
        uint256[] memory allocs = rarity_alloc[rarity];
        uint256 totalalloc = rarity_alloc_total[rarity];
        // caculate total rarity_alloc
        uint256 bucket = (seed & 0xFFFFFFFF) % totalalloc;
        uint256 cumulative = totalalloc;
        seed >>= 32;
        uint256[] memory cids;
        // get alloc order by decs
        for (uint256 i = (allocs.length - 1); i > 0; i--) {
            cumulative -= allocs[i];
            if (bucket > cumulative) {
                cids = rarity_alloc_cid[rarity][allocs[i]];
                return cids[seed % cids.length];
            }
        }
        cids = rarity_alloc_cid[rarity][allocs[0]];
        return cids[seed % cids.length];
    }
    // rarity: 1 Diamond %, 2 Gold 13%, 3 Silver 89%
    function _caculateRarity(uint256 random)
        internal
        pure
        returns (uint256 rarity)
    {
        if (random < 10) {
            return 2;
        } else if (random < 99) {
            return 3;
        } else {
            return 1;
        }
    }
    // ================= OnlyOwner ===================
    function updateRandomGenerator(address newRandomGenerator)
        external
        onlyOwner
    {
        require(newRandomGenerator != address(0));
        _RANDOM_ = IRandomGenerator(newRandomGenerator);
        emit UpdateRandom(newRandomGenerator);
    }
    function setPaidToken(IERC20 _token, uint256 _tokenPrice)
        external
        onlyOwner
    {
        _PAID_TOKEN_ = _token;
        _TOKEN_PRCIE_ = _tokenPrice;
        emit UpdatePaidToken(address(_token), _tokenPrice);
    }
    function setTokenMintLimit(uint256 limit) external onlyOwner {
        _TOKEN_MINTED_LIMIT_ = limit;
    }
    function setWhiteTicket(IERC721 ticket, bool state) external onlyOwner {
        white_tickets[ticket] = state;
        emit UpdateWhiteTicekt(address(ticket), state);
    }
    function sellStart(bool _state) external onlyOwner {
        _SELL_START_ = _state;
    }
    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }
    function updateFeeCollector(address _collector) external onlyOwner {
        _FEECOLLECTOR_ = _collector;
        emit UpdateCollector(_collector);
    }
    function withdraw(address _token) external {
        require(msg.sender == _FEECOLLECTOR_, "not collector");
        if (_token == address(0)) {
            payable(_FEECOLLECTOR_).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_FEECOLLECTOR_, token.balanceOf(address(this)));
    }
    // set or add cid, only Owner execute after init
    function setCid(
        uint256[] calldata cids,
        uint256[] calldata allocs,
        uint256[] calldata raritys
    ) external onlyOwner {
        require(cids.length == allocs.length, "Array length must equals!");
        require(cids.length == raritys.length, "Array length must equals!");
        for (uint256 i = 0; i < cids.length; i++) {
            bool flag = false;
            rarity_alloc_cid[raritys[i]][allocs[i]].push(cids[i]);
            if (rarity_alloc[raritys[i]].length == 0) {
                rarity_alloc[raritys[i]].push(allocs[i]);
                rarity_alloc_total[raritys[i]] += allocs[i];
            }
            for (uint256 m = 0; m < rarity_alloc[raritys[i]].length; m++) {
                if (rarity_alloc[raritys[i]][m] == allocs[i]) flag = true;
            }
            if (!flag) {
                rarity_alloc[raritys[i]].push(allocs[i]);
                rarity_alloc_total[raritys[i]] += allocs[i];
            }
        }
    }
}