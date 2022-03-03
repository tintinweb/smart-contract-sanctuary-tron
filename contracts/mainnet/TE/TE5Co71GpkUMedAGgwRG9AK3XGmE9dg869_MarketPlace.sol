//SourceUnit: MarketPlace.sol

/*
    SPDX-License-Identifier: Apache-2.0
    Website: https://www.libertyland.finance
    Twitter: https://twitter.com/LibertyLand_LL
    Email: business@libertyland.finance
    
    DeployOn: Tron-Network
*/

pragma solidity ^0.8.1;

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(
            _initializing ? _isConstructor() : !_initialized,
            "Initializable: contract is already initialized"
        );
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
        return !AddressUpgradeable.isContract(address(this));
    }
}
pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {}

    function __Context_init_unchained() internal onlyInitializing {}

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}
pragma solidity ^0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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
pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
pragma solidity ^0.8.0;

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
pragma solidity ^0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
pragma solidity ^0.8.0;

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}
pragma solidity ^0.8.0;

interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
pragma solidity ^0.8.0;

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
pragma solidity ^0.8.0;

contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
pragma solidity ^0.8.0;

interface IERC1155 is IERC165 {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
pragma solidity ^0.8.0;

interface IERC721 is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }
}

contract MarketPlace is OwnableUpgradeable, ERC721Holder, ERC1155Holder {
    enum Status {
        Available,
        Swapped,
        Canceled
    }

    bytes4 constant ERC1155ID = 0xd9b67a26;
    bytes32 public constant CONTROL_TYPE = keccak256("DEXTHER_IMPL");

    struct Offer {
        address creator;
        uint256 estimateAmount;
        address estimateTokenAddress;
        address[] offerTokensAddresses;
        uint256[] offerTokensIds;
        uint256[] offerTokensValues;
        address restrictedTo;
        address swapper;
        uint256 swappedAt;
        Status status;
    }

    Offer[] public offers;
    uint256 public currentFee;
    address public feeTo;

    // offer id has been created
    event Created(
        address indexed creator,
        uint256 indexed offerId,
        uint256 estimateAmount,
        address indexed estimateTokenAddress,
        address[] offerTokensAddresses,
        uint256[] offersTokensIds,
        uint256[] offerTokensValues,
        address restrictedTo
    );

    // offer id has been updated by creator
    event Updated(
        address indexed creator,
        uint256 indexed offerId,
        uint256 estimateAmount,
        address indexed estimateTokenAddress,
        uint256[] offerTokensValues,
        address restrictedTo
    );

    // offer id has been cancle by creator
    event Canceled(uint256 indexed offerId);
    // offer id has been done by swapper
    event Swapped(address indexed swapper, uint256 indexed offerId);

    function initialize(uint256 _fee, address _feeTo) external initializer {
        __Ownable_init();
        currentFee = _fee;
        feeTo = _feeTo;
    }

    function createOffer(
        uint256 estimateAmount,
        address estimateTokenAddress,
        address[] memory offerTokensAddresses,
        uint256[] memory offerTokensIds,
        uint256[] memory offerTokensValues,
        address restrictedTo
    ) external {
        require(offerTokensAddresses.length > 0, "No assets");
        require(
            offerTokensAddresses.length == offerTokensIds.length,
            "Tokens addresses or ids error"
        );
        require(
            offerTokensAddresses.length == offerTokensValues.length,
            "Tokens addresses or values error"
        );

        _transferAssets(
            msg.sender,
            address(this),
            offerTokensAddresses,
            offerTokensIds,
            offerTokensValues
        );

        offers.push(
            Offer(
                msg.sender,
                estimateAmount,
                estimateTokenAddress,
                offerTokensAddresses,
                offerTokensIds,
                offerTokensValues,
                restrictedTo,
                address(0),
                0,
                Status.Available
            )
        );

        emit Created(
            msg.sender,
            offers.length - 1,
            estimateAmount,
            estimateTokenAddress,
            offerTokensAddresses,
            offerTokensIds,
            offerTokensValues,
            restrictedTo
        );
    }

    function cancelOffer(uint256 offerId) external {
        require(offers[offerId].creator == msg.sender, "Not creator");
        require(offers[offerId].status == Status.Available, "Already used");

        offers[offerId].status = Status.Canceled;

        emit Canceled(offerId);

        _transferAssets(
            address(this),
            msg.sender,
            offers[offerId].offerTokensAddresses,
            offers[offerId].offerTokensIds,
            offers[offerId].offerTokensValues
        );
    }

    function updateOffer(
        uint256 offerId,
        uint256 _estimateAmount,
        address _estimateTokenAddress,
        uint256[] memory _offerTokensValues,
        address _restrictedTo
    ) external {
        require(offers[offerId].creator == msg.sender, "Not creator");
        require(
            offers[offerId].offerTokensValues.length ==
                _offerTokensValues.length,
            "Not creator"
        );
        require(
            offers[offerId].status == Status.Available,
            "Offer not available"
        );

        bool isReduce;
        bool isAdd;
        uint256[] memory reduce = new uint256[](_offerTokensValues.length);
        uint256[] memory addmore = new uint256[](_offerTokensValues.length);
        for (uint256 i = 0; i < _offerTokensValues.length; i++) {
            if (offers[offerId].offerTokensValues[i] > _offerTokensValues[i]) {
                if (!isReduce) isReduce = true;
                reduce[i] = SafeMath.sub(
                    offers[offerId].offerTokensValues[i],
                    _offerTokensValues[i]
                );
            }
            if (offers[offerId].offerTokensValues[i] < _offerTokensValues[i]) {
                if (!isAdd) isAdd = true;
                addmore[i] = SafeMath.sub(
                    _offerTokensValues[i],
                    offers[offerId].offerTokensValues[i]
                );
            }
        }

        if (isReduce) {
            _transferAssets(
                address(this),
                msg.sender,
                offers[offerId].offerTokensAddresses,
                offers[offerId].offerTokensIds,
                reduce
            );
        }

        if (isAdd) {
            _transferAssets(
                msg.sender,
                address(this),
                offers[offerId].offerTokensAddresses,
                offers[offerId].offerTokensIds,
                addmore
            );
        }

        offers[offerId].estimateAmount = _estimateAmount;
        offers[offerId].estimateTokenAddress = _estimateTokenAddress;
        offers[offerId].offerTokensValues = _offerTokensValues;
        offers[offerId].restrictedTo = _restrictedTo;

        emit Updated(
            msg.sender,
            offerId,
            _estimateAmount,
            _estimateTokenAddress,
            _offerTokensValues,
            _restrictedTo
        );
    }

    function swap(uint256 offerId) external payable {
        require(
            offers[offerId].status == Status.Available,
            "Offer not available"
        );

        if (offers[offerId].restrictedTo != address(0)) {
            require(
                offers[offerId].restrictedTo == msg.sender,
                "Not authorized"
            );
        }

        offers[offerId].swapper = msg.sender;
        offers[offerId].swappedAt = block.timestamp;
        offers[offerId].status = Status.Swapped;

        uint256 fee = SafeMath.mul(
            SafeMath.div(offers[offerId].estimateAmount, 10000),
            currentFee
        );
        uint256 estimateAmountMinusFee = SafeMath.sub(
            offers[offerId].estimateAmount,
            fee
        );

        if (offers[offerId].estimateTokenAddress == address(0x0)) {
            require(
                msg.value >= offers[offerId].estimateAmount,
                "invalid amount"
            );
            TransferHelper.safeTransferETH(feeTo, fee);
            TransferHelper.safeTransferETH(
                offers[offerId].creator,
                estimateAmountMinusFee
            );
        } else {
            TransferHelper.safeTransferFrom(
                offers[offerId].estimateTokenAddress,
                msg.sender,
                feeTo,
                fee
            );
            TransferHelper.safeTransferFrom(
                offers[offerId].estimateTokenAddress,
                msg.sender,
                offers[offerId].creator,
                estimateAmountMinusFee
            );
        }

        _transferAssets(
            address(this),
            msg.sender,
            offers[offerId].offerTokensAddresses,
            offers[offerId].offerTokensIds,
            offers[offerId].offerTokensValues
        );

        emit Swapped(msg.sender, offerId);
    }

    function getOffer(uint256 offerId) external view returns (Offer memory) {
        return offers[offerId];
    }

    function _transferAssets(
        address from,
        address to,
        address[] memory tokensAddresses,
        uint256[] memory tokensIds,
        uint256[] memory tokensValues
    ) private {
        for (uint256 i = 0; i < tokensAddresses.length; i++) {
            IERC165 tokenWithoutInterface = IERC165(tokensAddresses[i]);

            if (tokenWithoutInterface.supportsInterface(ERC1155ID)) {
                IERC1155 token = IERC1155(tokensAddresses[i]);
                bytes memory data;
                token.safeTransferFrom(
                    from,
                    to,
                    tokensIds[i],
                    tokensValues[i],
                    data
                );
            } else {
                IERC721 token = IERC721(tokensAddresses[i]);
                token.transferFrom(from, to, tokensIds[i]);
            }
        }
    }

    function updateFee(uint256 newCurrentFee) external onlyOwner {
        require(newCurrentFee < 1000, "Fee too high");
        currentFee = newCurrentFee;
    }

    function updateFeeTo(address _feeTo) external onlyOwner {
        feeTo = _feeTo;
    }

    function withdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }
}