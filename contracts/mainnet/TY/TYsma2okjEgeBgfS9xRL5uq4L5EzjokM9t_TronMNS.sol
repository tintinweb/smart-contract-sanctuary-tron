//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContractTron(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContractTron(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContractTron(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContractTron(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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

//SourceUnit: Badge.sol

/**
 *Submitted for verification at Etherscan.io on 2021-09-03
*/

/**
 *Submitted for verification at Etherscan.io on 2021-08-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}






/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}




/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}







/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}





/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContractTron(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContractTron(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContractTron(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContractTron(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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









/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContractTron()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
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

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}







/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


interface IRule {
    function validateName(string memory str) external view returns (bool);
}

contract MNSBadge is ERC721Enumerable, Ownable {
   // using SafeMath for uint256;
    using Strings for uint256;
    
    struct badgeDetail {
        uint256 tokenId;
        string name;
        bool canMint;
    }

    string public baseURI;
    address public _ruleContract;
    mapping (uint256 => string) private _tokenName;
    mapping (string => uint256) private _repeatName;
    mapping (string => uint256) private _nameReserved;
    mapping (address => uint256) private _adminMap;
    bool public _nameOpen = false;
    
    event mintBadge(uint256 time, address owner, uint256 nftId);
    event wishName(uint256 nftId, string name, address owner, uint256 time);
    
    constructor(address ruleContract)
        ERC721("MNS Genesis Badge", "MGB")
    {
        baseURI = "";
        _ruleContract = ruleContract;
    }
    
    function setNameState() public onlyOwner {
        _nameOpen = !_nameOpen;
    }
    
    function checkAdmin(address user) public view returns(uint256) {
        return _adminMap[user];
    }
    
    function addAdmin(address user, uint256 point) public onlyOwner {
        _adminMap[user] = point;
    }
    
    function getUserBadges(address user) public view returns(badgeDetail[] memory) {
        uint256 count = balanceOf(user);
        require(count > 0, "user don't have any badges.");
        badgeDetail[] memory blist = new badgeDetail[](count); 
        for(uint256 i = 0; i < count; ++i) {
            uint256 tokenId = tokenOfOwnerByIndex(user, i);
            string memory wishName = _tokenName[tokenId];
            bool canMint = _repeatName[toLower(wishName)]>0?false:true;
            blist[i] = badgeDetail({
                tokenId: tokenId, 
                name: wishName, 
                canMint: canMint
            });
        }
        return blist;
    }
    
    function getDetailOfToken(uint256 nftId) public view returns(badgeDetail memory) {
        string memory wishName = _tokenName[nftId];
        bool canMint = _repeatName[toLower(wishName)]>0?false:true;
        return badgeDetail({
            tokenId: nftId, 
            name: wishName, 
            canMint: canMint
        });
    }
    
    function getWishName(uint256 nftId) public view returns(string memory) {
        return _tokenName[nftId];
    }
    
    function setRuleContract(address ruleContract) public onlyOwner {
        _ruleContract = ruleContract;
    }
    
    function setBaseUri(string memory url) public onlyOwner {
        baseURI = url;
    }
    
    function mintFor(address[] memory whiteList) public {
        require(_adminMap[msg.sender]>0, "do not have permssion.");
        require(whiteList.length >0, "data can not ne empty");
        for (uint256 i = 0; i < whiteList.length; i++) {
            address whiteUser = whiteList[i];
            uint256 nftId = totalSupply();
            _safeMint(whiteUser, nftId);
            emit mintBadge(block.timestamp, whiteUser, nftId);
        }
    }
    
    function makeWish(uint256 nftId,string memory name) public {
        require(_msgSender() == ownerOf(nftId), "ERC721: caller is not the owner");
        require(IRule(_ruleContract).validateName(name), "Not a valid new name");
        require(bytes(_tokenName[nftId]).length == 0, "already setted!");
        require(_nameOpen, "can not make wish.");
        
        _tokenName[nftId] = name;
        string memory lowName = toLower(name);
        if (_nameReserved[lowName] > 0) {
            _repeatName[lowName] = 1;
        }
        _nameReserved[lowName] += 1;
        emit wishName(nftId, name, _msgSender(), block.timestamp);
    }
    
    function toLower(string memory str) private pure returns (string memory){
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
    
    function canMint(uint256 nftId) public view returns(bool) {
        string memory lowName = toLower(_tokenName[nftId]);
        if (_repeatName[lowName] > 0) {
            return false;
        }else {
            return true;
        }
    }
    
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        string memory currentBaseURI = baseURI;
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, _tokenId.toString()))
                : "";
    }

}

//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

//SourceUnit: ERC165.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

//SourceUnit: ERC721A.sol

// SPDX-License-Identifier: MIT
// Creator: Chiru Labs

pragma solidity ^0.8.4;

import './IERC721.sol';
import './IERC721Receiver.sol';
import './IERC721Metadata.sol';
import './Address.sol';
import './Context.sol';
import './Strings.sol';
import './ERC165.sol';

// error ApprovalCallerNotOwnerNorApproved();
// error ApprovalQueryForNonexistentToken();
// error ApproveToCaller();
// error ApprovalToCurrentOwner();
// error BalanceQueryForZeroAddress();
// error MintToZeroAddress();
// error MintZeroQuantity();
// error OwnerQueryForNonexistentToken();
// error TransferCallerNotOwnerNorApproved();
// error TransferFromIncorrectOwner();
// error TransferToNonERC721ReceiverImplementer();
// error TransferToZeroAddress();
// error URIQueryForNonexistentToken();

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension. Built to optimize for lower gas during batch mints.
 *
 * Assumes serials are sequentially minted starting at _startTokenId() (defaults to 0, e.g. 0, 1, 2, 3..).
 *
 * Assumes that an owner cannot have more than 2**64 - 1 (max value of uint64) of supply.
 *
 * Assumes that the maximum token id cannot exceed 2**256 - 1 (max value of uint256).
 */
contract ERC721A is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Compiler will pack this into a single 256bit word.
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Keeps track of the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct AddressData {
        // Realistically, 2**64-1 is more than enough.
        uint64 balance;
        // Keeps track of mint count with minimal overhead for tokenomics.
        uint64 numberMinted;
        // Keeps track of burn count with minimal overhead for tokenomics.
        uint64 numberBurned;
        // For miscellaneous variable(s) pertaining to the address
        // (e.g. number of whitelist mint slots used).
        // If there are multiple variables, please pack them into a uint64.
        uint64 aux;
    }

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenOwnership) internal _ownerships;

    // Mapping owner address to address data
    mapping(address => AddressData) private _addressData;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * To change the starting tokenId, please override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than _currentIndex - _startTokenId() times
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        // and it is initialized to _startTokenId()
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "owner cannot be zero.");
       // if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return uint256(_addressData[owner].balance);
    }

    /**
     * Returns the number of tokens minted by `owner`.
     */
    function _numberMinted(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberMinted);
    }

    /**
     * Returns the number of tokens burned by or on behalf of `owner`.
     */
    function _numberBurned(address owner) internal view returns (uint256) {
        return uint256(_addressData[owner].numberBurned);
    }

    /**
     * Returns the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     */
    function _getAux(address owner) internal view returns (uint64) {
        return _addressData[owner].aux;
    }

    /**
     * Sets the auxillary data for `owner`. (e.g. number of whitelist mint slots used).
     * If there are multiple variables, please pack them into a uint64.
     */
    function _setAux(address owner, uint64 aux) internal {
        _addressData[owner].aux = aux;
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory) {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenOwnership memory ownership = _ownerships[curr];
                if (!ownership.burned) {
                    if (ownership.addr != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _ownerships[curr];
                        if (ownership.addr != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
       // revert OwnerQueryForNonexistentToken();
       revert();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).addr;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "tokenId existed.");
       // if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return '';
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721A.ownerOf(tokenId);
        require(owner != to, "owner same to.");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "approve error.");
        //if (to == owner) revert ApprovalToCurrentOwner();
        
        // if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
        //     revert ApprovalCallerNotOwnerNorApproved();
        // }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "tokenId not existed.");
        //if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "operator same to msgsender.");
       // if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (to.isContractTron() && !_checkContractOnERC721Received(from, to, tokenId, _data)) {
            //revert TransferToNonERC721ReceiverImplementer();
            revert();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _startTokenId() <= tokenId && tokenId < _currentIndex &&
            !_ownerships[tokenId].burned;
    }

    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, '');
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        _mint(to, quantity, _data, true);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(
        address to,
        uint256 quantity,
        bytes memory _data,
        bool safe
    ) internal {
        uint256 startTokenId = _currentIndex;
        require(to != address(0), "mint to cannot be zero.");
        require(quantity != 0, "mint quantity cannot be zero.");
        // if (to == address(0)) revert MintToZeroAddress();
        // if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _addressData[to].balance += uint64(quantity);
            _addressData[to].numberMinted += uint64(quantity);

            _ownerships[startTokenId].addr = to;
            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (safe && to.isContractTron()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (!_checkContractOnERC721Received(address(0), to, updatedIndex++, _data)) {
                        //revert TransferToNonERC721ReceiverImplementer();
                        revert();
                    }
                } while (updatedIndex != end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        require(prevOwnership.addr == from, "_transfer address differ.");
       // if (prevOwnership.addr != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        require(isApprovedOrOwner, "not approve or not owner.");
        require(to != address(0), "to cannot be zero.");
        // if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        // if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _addressData[from].balance -= 1;
            _addressData[to].balance += 1;

            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = to;
            currSlot.startTimestamp = uint64(block.timestamp);

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev This is equivalent to _burn(tokenId, false)
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenOwnership memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.addr;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());
            require(isApprovedOrOwner, "_burn approve not or not owner.");
            //if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            AddressData storage addressData = _addressData[from];
            addressData.balance -= 1;
            addressData.numberBurned += 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenOwnership storage currSlot = _ownerships[tokenId];
            currSlot.addr = from;
            currSlot.startTimestamp = uint64(block.timestamp);
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenOwnership storage nextSlot = _ownerships[nextTokenId];
            if (nextSlot.addr == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.addr = from;
                    nextSlot.startTimestamp = prevOwnership.startTimestamp;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                //revert TransferToNonERC721ReceiverImplementer();
                revert();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}

//SourceUnit: IERC165.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SourceUnit: IERC721.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

//SourceUnit: IERC721Metadata.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

//SourceUnit: IERC721Receiver.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

//SourceUnit: MNS.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";
import "./ERC721A.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

interface IBadge {
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function canMint(uint256 nftId) external view returns(bool);
    function getWishName(uint256 nftId) external view returns(string memory);
}

interface IRule {
    function validateName(string memory str) external view returns (bool);
   // function toLower(string memory str) external view returns (string memory);
}

interface IMasks {
    function ownerOf(uint256 index) external view returns (address);
    function getNftName(uint256 nftId) external view returns(string memory);
    function getNftByName(string memory name) external view returns (uint256);
}

interface ITNS {
    function ownerOf(uint256 tokenId) external view returns (address);
    function balanceOf(address owner) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
   // function approve(address to, uint256 tokenId) external;
}

interface IRelationShipStore {
    function addUserFirstItem(uint256 invitorId, address user, uint256 nftId) external returns (bool);
    function addUserSecItem(uint256 firstInvitor, address user, uint256 nftId) external returns (bool);
    function setFirstInvitor(uint256 nftId, uint256 invitorId) external returns(bool);
    function setSecInvitor(uint256 nftId, uint256 invitorId) external returns(bool);
    function getFirstInvitor(uint256 nftId) external view returns(uint256);
    function getSecInvitor(uint256 nftId) external view returns(uint256);
}

interface AggregatorInterface {
    function latestAnswer() external view returns (int256);
    function latestTimestamp() external view returns (uint256);
    function latestRound() external view returns (uint256);
    function getAnswer(uint256 roundId) external view returns (int256);
    function getTimestamp(uint256 roundId) external view returns (uint256);
}

pragma experimental ABIEncoderV2;

contract TronMNS is ERC721A, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    string public baseURI;
    
    address public _relationAddress;
    address public _ruleContract;
    address public _badgeAddress;
    address public _nctAddress;
    address public _tnsAddress;
    
    mapping (uint256 => uint256) private _nft2UriId;
    uint256 public _saleCount = 0;
    uint256 public _supplyCount = 10000;
    uint256 public _raleCount = 0;
    uint256 public _raleSupply = 302;
    mapping (string => uint256) private _lockName;
    mapping (string => address) private _lockOwner;
    mapping (uint256 => string) private _tokenName;
    mapping (string => uint256) private _nameToken;
    mapping (string => uint256) private _nameReserved;
    mapping (address => uint256) private _adminMap;
    mapping (uint256 => uint256) public NAME_CHANGE_PRICE;
    bool public nameEnable = false;
    uint256 public _firstRate = 25;
    uint256 public _secRate = 10;
    uint256 public _whiteRate = 30;
    bool public _openTns = true;
    bool public _preSale = false;

    mapping (address => uint256) private _bnbReword; 
    AggregatorInterface internal priceFeed;

    event BuyNftWithTrx(uint256 time, address owner, uint256 nftId, uint256 price, uint256 invitorId, uint256 secId);
    event NameChange(uint256 nftId, string newName, address owner, uint256 time);
    event Transfer(uint256 nftId, address from, address to, uint256 time);

    constructor(address relationAddress, address tnsAddress, address ruleAddress, address badgeAddress)
        ERC721A("Metaverse Name Service", "MNS")

    {
         _relationAddress = relationAddress;
         _ruleContract = ruleAddress;
         _badgeAddress = badgeAddress;
         _tnsAddress = tnsAddress;  //TQs6pqT88fr5q2oMoXRQTbfifHuaMmayUy
         
         _adminMap[msg.sender] = 1;
         NAME_CHANGE_PRICE[1] = 35000*1000000;
         NAME_CHANGE_PRICE[2] = 10000*1000000;
         NAME_CHANGE_PRICE[3] = 3000*1000000;
         NAME_CHANGE_PRICE[4] = 1000*1000000;
         
        //TXwZqjjw4HtphG4tAm5i1j1fGHuXmYKeeP mainNet
        //0xf10354c1be7a8b015aa9152132cfd4b620c67775
        priceFeed = AggregatorInterface(0xf10354C1BE7A8b015aA9152132cfD4B620c67775); //主网
        setBaseURI("https://api.mns.network/mns/metadata/");
    }
    
    function checkAdmin(address user) public view returns(uint256) {
        return _adminMap[user];
    }
    
    function addAdmin(address user, uint256 point) public onlyOwner {
        _adminMap[user] = point;
    }
    
    function getUriId(uint256 nftId) public view returns(uint256) {
        return _nft2UriId[nftId];
    }
    
    function getTnsOpen() public view returns(bool) {
        return _openTns;
    }
    
    function setTnsOpen() public onlyOwner {
        _openTns = !_openTns;
    }
    
    function setPreSale() public onlyOwner {
        _preSale = !_preSale;
    }
    
    function setFirstRate(uint256 rate) public onlyOwner {
        _firstRate = rate;
    }
    
    function setSecondRate(uint256 rate) public onlyOwner {
        _secRate = rate;
    }
    
    function setBadgeContract(address badgeAddress) public onlyOwner {
        _badgeAddress = badgeAddress;
    }
    
    function setRelationContract(address relationAddress) public onlyOwner {
        _relationAddress = relationAddress;
    }
    
    function setTnsContract(address tnsAddress) public onlyOwner {
        _tnsAddress = tnsAddress;
    }
    
    function setRuleContract(address ruleAddress) public onlyOwner {
        _ruleContract = ruleAddress;
    }
    
    function nameReserved(string memory name) public view returns(uint256) {
        return _nameReserved[name];
    }
    
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    // FACTORY
    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721A)
        returns (string memory)
    {
        string memory currentBaseURI = baseURI;
       // uint256 uriId = _nft2UriId[_tokenId];
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, _tokenId.toString()))
                : "";
    }

    function lockNameOwner(string memory name) public view returns(address) {
        return _lockOwner[toLower(name)];
    }
    
    function isNameLocked(string memory name) public view returns(uint256) {
        return _lockName[toLower(name)];
    }

    function getLatestPrice() public view returns (int) {
         require(priceFeed.latestTimestamp() > 0, "Round not complete");
         return priceFeed.latestAnswer();
       // return 65950;
    }
    
    function changeName(uint256 nftId, string memory newName) public {
        require(nameEnable, "not open");   
    
        string memory lowName = toLower(newName);
        require(_msgSender() == ownerOf(nftId), "ERC721: caller is not the owner");
        require(IRule(_ruleContract).validateName(newName) == true, "Not a valid new name");
        require(_nameReserved[lowName] <= 0, "Name already reserved");
        bool isLock = block.timestamp-_lockName[lowName]>24*3600?false:true;
        require(!isLock || msg.sender== _lockOwner[lowName], "name is locked.");
        
        uint256 changePrice = getChangePrice(bytes(newName).length);
        IERC20(_nctAddress).transferFrom(msg.sender, address(this), changePrice);
        
        string memory oldName = _tokenName[nftId];
        
       if (bytes(oldName).length > 0) {
            string memory lowOld = toLower(oldName);
            _lockName[lowOld] = block.timestamp;
            _lockOwner[lowOld] = ownerOf(nftId);
            _nameReserved[lowOld] = 0;

        }
        _nameToken[oldName] = 0;
        _nameReserved[lowName] = nftId;
        _tokenName[nftId] = newName;
        _nameToken[newName] = nftId;
        if (!isLock) {
            _lockOwner[lowName] = address(0);
        }
        emit NameChange(nftId, newName, msg.sender, block.timestamp);
    }

    function setNameChangePrice(uint256 pos, uint256 price) public onlyOwner {
        NAME_CHANGE_PRICE[pos] = price;
    }
    
    function getChangePrice(uint256 nameLength) public view returns(uint256) {
        if (3 == nameLength) {
            //return 35000*1000000;
            return NAME_CHANGE_PRICE[1];
        }else if (4 == nameLength) {
            //return 10000*1000000;
            return NAME_CHANGE_PRICE[2];
        }else if (nameLength>=5 && nameLength <= 8) {
            //return 3000*100000;
            return NAME_CHANGE_PRICE[3];
        }else if (nameLength>=9 && nameLength <= 21) {
            //return 1000*100000;
            return NAME_CHANGE_PRICE[4];
        }else {
            return 0;
        }
    }

    function getNFTPrice(uint256 nameLength) public view returns (uint256) {
        if (3 == nameLength) {
            return 699*1000000;
        }else if (4 == nameLength) {
            return 199*1000000;
        }else if (nameLength>=5 && nameLength <= 8) {
            return 299*100000;
        }else if (nameLength>=9 && nameLength <= 21) {
            return 159*100000;
        }else {
            return 0;
        }
    }

    function getReword(address user) public view returns(uint256) {
        return _bnbReword[user];
    }

    function claim() public returns(bool) {
        require(_bnbReword[msg.sender]>0, "balance empty");

        uint256 amount = _bnbReword[msg.sender];
        payable(msg.sender).transfer(amount);
        _bnbReword[msg.sender] = 0;
        return true;
    }

    function getBuyPrice( uint256 nameLength) public view returns(uint256) {
        uint256 price = getNFTPrice(nameLength);
        return price.mul(10**6).div(uint256(getLatestPrice()));
    }
    
    function checkPriceList(string[] memory newNameList) private returns(uint256) {
        uint256 price = getNFTPrice(bytes(newNameList[0]).length);
        string memory name = newNameList[0];
        string memory lowName = toLower(name);
        if (!IRule(_ruleContract).validateName(name) || _nameReserved[lowName] > 0) {return 0;}
        if(block.timestamp-_lockName[lowName]<=24*3600 && msg.sender != _lockOwner[lowName]){return 0;}
        if (newNameList.length > 1) {
            for (uint256 i = 0; i < newNameList.length; ++i) {
                name = newNameList[i];
                if (!IRule(_ruleContract).validateName(name) || _nameReserved[lowName] > 0) {return 0;}
                if(block.timestamp-_lockName[lowName]<=24*3600 && msg.sender!= _lockOwner[lowName]){return 0;}
                uint256 curPrice = getNFTPrice(bytes(name).length);
                if (curPrice != price) {return 0;}
            }
        }
        return price.mul(newNameList.length).mul(10**6).div(uint256(getLatestPrice()));
    }
    
    function setSaleCount(uint256 totalCount) public onlyOwner {
        _supplyCount = totalCount;
    }
  
    function buyWithName(uint256 invitorId, string[] memory newNameList) public payable returns(uint256) {
        uint256 amount = newNameList.length;
        require(amount>0&&amount<21, "nameList must have something.");
        require(_saleCount.add(amount) < _supplyCount, "coin not enough to sell");
       
        uint256 buyPrice = checkPriceList(newNameList);
        require(buyPrice > 0 && buyPrice <= msg.value, "TRX value sent is not correct or name not correct.");
   
        uint256 supply = totalSupply();
        _safeMint(msg.sender, amount);

        uint256 firstId = IRelationShipStore(_relationAddress).getFirstInvitor(invitorId);
        for (uint i = 0; i < amount; i++) {
            uint256 nftId = supply.add(i);
            //ownerOf(nftId) = msg.sender;
            _nft2UriId[nftId] = _saleCount.add(302).add(i);
            if (invitorId > 0) {
                IRelationShipStore(_relationAddress).setFirstInvitor(nftId, invitorId);
                IRelationShipStore(_relationAddress).addUserFirstItem(invitorId, msg.sender, nftId);

                uint256 firstInvitorId = IRelationShipStore(_relationAddress).getFirstInvitor(invitorId);
                if (firstInvitorId > 0) {
                    IRelationShipStore(_relationAddress).setSecInvitor(nftId, firstInvitorId);
                    IRelationShipStore(_relationAddress).addUserSecItem(firstInvitorId, msg.sender, nftId);
                }
            }

            uint256 nftInvitor = IRelationShipStore(_relationAddress).getFirstInvitor(nftId);
            if (nftInvitor > 0) {
                _bnbReword[ownerOf(nftInvitor)] = _bnbReword[ownerOf(nftInvitor)].add(msg.value.mul(_firstRate).div(100));
                uint256 secInvitor = IRelationShipStore(_relationAddress).getSecInvitor(nftId);
                if (secInvitor > 0) {
                    _bnbReword[ownerOf(secInvitor)] = _bnbReword[ownerOf(secInvitor)].add(msg.value.mul(_secRate).div(100));
                }
            }
            
            string memory newName = newNameList[i];
            _nameReserved[toLower(newName)] = nftId;
            _tokenName[nftId] = newName;
            _nameToken[newName] = nftId;
            emit NameChange(nftId, newName, msg.sender, block.timestamp);
            emit BuyNftWithTrx(block.timestamp, msg.sender, nftId, msg.value.div(amount), invitorId, firstId);
        }
        _saleCount = _saleCount.add(amount);

        return _saleCount;
    }
    
    function useBadgeToMint(uint256 tokenId) public payable returns(uint256) {
        require(_preSale, "preSale mns is close.");
        require(IBadge(_badgeAddress).ownerOf(tokenId) == msg.sender, "do not have any tns.");
        require(_saleCount.add(1) < _supplyCount, "coin not enough to sell");
        
       // uint256 tokenId = IBadge(_badgeAddress).tokenOfOwnerByIndex(msg.sender, 0);
        require(IBadge(_badgeAddress).canMint(tokenId), "this badge can not mint.");
        string memory newName = IBadge(_badgeAddress).getWishName(tokenId);
        string memory lowName = toLower(newName);
        require(IRule(_ruleContract).validateName(newName) == true, "Not a valid new name");
        require(_nameReserved[lowName] <= 0, "Name already reserved");
        
        uint256 price = getNFTPrice(bytes(newName).length);
        uint256 needPay = price.mul(10**6).mul(_whiteRate).div(100).div(uint256(getLatestPrice()));
        require(needPay<=msg.value, "pay not enough.");
        
       // require(bytes(newName).length>=5 && bytes(newName).length<=8, "name length error.");
        require(block.timestamp-_lockName[lowName]>24*3600 || msg.sender== _lockOwner[lowName], "name is locked.");
        
        
        // ITNS(_tnsAddress).approve(address(this), tokenId);
        IBadge(_badgeAddress).transferFrom(msg.sender, address(this), tokenId);
        
        uint256 nftId = totalSupply();
        _safeMint(msg.sender, 1);
        _nft2UriId[nftId] = _saleCount.add(302);
        _saleCount = _saleCount.add(1);
        
        _nameReserved[lowName] = nftId;
        _tokenName[nftId] = newName;
        _nameToken[newName] = nftId;
        
        if (block.timestamp-_lockName[lowName]>24*3600) {
            _lockOwner[lowName] = address(0);
        }
        
        emit NameChange(nftId, newName, msg.sender, block.timestamp);
        emit BuyNftWithTrx(block.timestamp, msg.sender, nftId, 0, 0, 0);
        
        return nftId;
    }
    
    function mintForSpecial(address user, string memory newName) public returns(uint256) {
        require(_adminMap[msg.sender]>0, "do not have permssion.");
        require(_raleCount.add(1) < _raleSupply, "coin not enough to sell");
        require(IRule(_ruleContract).validateName(newName), "Not a valid new name");
        string memory lowName = toLower(newName);
        require(_nameReserved[lowName] <= 0, "Name already reserved");
        require(bytes(newName).length>=4 && bytes(newName).length<=8, "name length error");
       require(block.timestamp-_lockName[lowName]>24*3600 || msg.sender== _lockOwner[lowName], "name is locked.");
        
        uint256 nftId = totalSupply();
        _safeMint(user, 1);
        
        _nft2UriId[nftId] = _raleCount;
        _raleCount = _raleCount.add(1);

        _nameReserved[lowName] = nftId;
        _tokenName[nftId] = newName;
        _nameToken[newName] = nftId;
        
        if (block.timestamp-_lockName[lowName]>24*3600) {
            _lockOwner[lowName] = address(0);
        }
        
        emit NameChange(nftId, newName, user, block.timestamp);
        emit BuyNftWithTrx(block.timestamp, user, nftId, 0, 0, 0);
        
        return nftId;
    }
    
    function mintForOwn(address user, string[] memory newNameList) public returns(bool) {
        require(_adminMap[msg.sender]>0, "do not have permssion.");
        uint256 amount = newNameList.length;
        require(amount > 0, "name list cannot be empty.");
        require(_saleCount.add(amount) < _supplyCount, "coin not enough to sell");
        
        for (uint256 i = 0; i < amount; i++) {
            string memory newName = newNameList[i];
            string memory lowName = toLower(newName);
            require(IRule(_ruleContract).validateName(newName) == true, "Not a valid new name");
            require(_nameReserved[lowName] <= 0, "Name already reserved");
            // require(bytes(newName).length>=5 && bytes(newName).length<=8, "name length error.");
            require(block.timestamp-_lockName[lowName]>24*3600 || msg.sender== _lockOwner[lowName], "name is locked.");
        
            uint256 nftId = totalSupply();
            _safeMint(user, 1);
            _nft2UriId[nftId] = _saleCount.add(302);
            _saleCount = _saleCount.add(1);
        
            _nameReserved[lowName] = nftId;
            _tokenName[nftId] = newName;
            _nameToken[newName] = nftId;
            
            if (block.timestamp-_lockName[lowName]>24*3600) {
                _lockOwner[lowName] = address(0);
            }
            emit NameChange(nftId, newName, user, block.timestamp);
            emit BuyNftWithTrx(block.timestamp, user, nftId, 0, 0, 0);
        }
       
        
        return true;
    } 
    
    function useTnsToMint(string memory newName) public returns(uint256) {
        require(_openTns, "tns transfer mns is close.");
        require(ITNS(_tnsAddress).balanceOf(msg.sender)>0, "do not have any tns.");
        require(_saleCount.add(1) < _supplyCount, "coin not enough to sell");
        require(IRule(_ruleContract).validateName(newName) == true, "Not a valid new name");
        string memory lowName = toLower(newName);
        require(_nameReserved[lowName] <= 0, "Name already reserved");
        require(bytes(newName).length>=5 && bytes(newName).length<=8, "name length error.");
        require(block.timestamp-_lockName[lowName]>24*3600 || msg.sender== _lockOwner[lowName], "name is locked.");
        
        uint256 tokenId = ITNS(_tnsAddress).tokenOfOwnerByIndex(msg.sender, 0);
        // ITNS(_tnsAddress).approve(address(this), tokenId);
        ITNS(_tnsAddress).transferFrom(msg.sender, address(this), tokenId);
        
        uint256 nftId = totalSupply();
        _safeMint(msg.sender, 1);
        _nft2UriId[nftId] = _saleCount.add(302);
        _saleCount = _saleCount.add(1);
        
        _nameReserved[lowName] = nftId;
        _tokenName[nftId] = newName;
        _nameToken[newName] = nftId;
        
        emit NameChange(nftId, newName, msg.sender, block.timestamp);
        emit BuyNftWithTrx(block.timestamp, msg.sender, nftId, 0, 0, 0);
        
        return nftId;
    }
    
    function setRaleName(uint256 nftId, string memory name) public {
        require(_adminMap[msg.sender]>0, "not have permssion.");
        string memory lowName = toLower(name);
        require(_nameReserved[lowName] <= 0, "Name already reserved");
        require(block.timestamp-_lockName[lowName]>24*3600 || msg.sender== _lockOwner[lowName], "name is locked.");
        
        if (bytes(_tokenName[nftId]).length > 0) {
            //toggleReserveName(_tokenName[nftId], 0);
            _nameReserved[toLower(_tokenName[nftId])] = 0;

        }
        //toggleReserveName(newName, nftId);
        _nameToken[_tokenName[nftId]] = 0;
        _nameReserved[lowName] = nftId;
        _tokenName[nftId] = name;
        _nameToken[name] = nftId;
        
        if (block.timestamp-_lockName[lowName]>24*3600) {
            _lockOwner[lowName] = address(0);
        }
        emit NameChange(nftId, name, msg.sender, block.timestamp);
    }
    
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;

        (bool r1, ) = payable(msg.sender).call{value: balance}("");
        require(r1);
    }

    function getNftName(uint256 nftId) public view returns(string memory) {
        return string(abi.encodePacked(_tokenName[nftId], ".trx"));
       // return _tokenName[nftId];
    }

    function getNftByName(string memory name) public view returns (uint256) {
        return _nameToken[name];
    }

    function setNameEnable(bool state) public onlyOwner {
        nameEnable = state;
    }

    function setNameChangeContract(address nctAddress) public onlyOwner {
        _nctAddress = nctAddress;
    }

    function toLower(string memory str) private pure returns (string memory){
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
    
       /* 
        @dev override transferOwnership from Ownable
         transfer ownership with multisig
    */
    function transferOwnership(address newOwner) public virtual override(Ownable) onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

}


//SourceUnit: NameRule.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./SafeMath.sol";
import "./Strings.sol";

interface IRule {
    function validateName(string memory str) external view returns (bool);
    function toLower(string memory str) external view returns (string memory);
}

contract NameRule {
    using SafeMath for uint256;
    using Strings for uint256;
    
    function validateName(string memory str) public view returns (bool){
        bytes memory b = bytes(str);
       // if(b.length < _nftMinLength[coinType]) return false;
        //if(b.length > _nftMaxLength[coinType]) return false; // Cannot be longer than 25 characters
        if (b.length > 21) return false;
        if(b[0] == 0x20) return false; // Leading space
        if (b[b.length - 1] == 0x20) return false; // Trailing space
        if(b[0] == 0x2d) return false; // Leading space
        if (b[b.length - 1] == 0x2d) return false; // Trailing space

        bytes1 lastChar = b[0];

        if (3 == b.length) {
            for(uint i; i<b.length; i++){
                bytes1 char = b[i];
                if(
                    !(char >= 0x30 && char <= 0x39) && //9-0
                    !(char >= 0x41 && char <= 0x5A) && //A-Z
                    !(char >= 0x61 && char <= 0x7A) //a-z
                )
                return false;
            }
        }else {
            for(uint i; i<b.length; i++){
                bytes1 char = b[i];
                //if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces
                if (char == 0x2d && lastChar == 0x2d) return false;
                if(
                    !(char >= 0x30 && char <= 0x39) && //9-0
                    !(char >= 0x41 && char <= 0x5A) && //A-Z
                    !(char >= 0x61 && char <= 0x7A) && //a-z
                    //!(char == 0x20) && //space
                    !(char == 0x2d)    //-号
                )
                return false;

                lastChar = char;
            }
        }
        
        return true;
    }
    
    function toLower(string memory str) private pure returns (string memory){
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functionas to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SourceUnit: Parse.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./Ownable.sol";

interface IMasks {
    function ownerOf(uint256 index) external view returns (address);
    function getNftName(uint256 nftId) external view returns(string memory);
    function getNftByName(string memory name) external view returns (uint256);
}

contract Parse is Ownable {
    struct Single {
        string key;
        string text;
        string wallet;
        uint256 itype;
    }

    struct DeleteTag {
        string key;
        uint256 itype;
    }

    struct BnsInfo {
        mapping(string=>uint256) chainMap;
        string[] chainList;
        string[] walletList;
        mapping(string=>uint256) textMap;
        string[] nameList;
        string[] textList;
    }
    mapping(uint256 => BnsInfo) private infoMap;
    address public _punkAddress = 0xE1A19A88e0bE0AbBfafa3CaE699Ad349717CA7F2;
    mapping(string => string) private _addToName;
    mapping(string => string) private _nameToAdd;
    mapping(string => mapping(string => uint256)) private _addPList;
    mapping(string => string[]) private _addKeyMap;
    
    event SetSingle(uint256 nftId, string key, string value, uint256 itype);
   // event SetBatch(uint256 nftId, Single[] list);
    event SetBatch(uint256 nftId, string[] keys, string[] infos, uint256[] types);
    event DeleteSingle(uint256 nftId, string key, uint256 itype);
   // event DeleteBatch(uint256 nftId, DeleteTag[] list);
    event DeleteBatch(uint256 nftId, string[] keys, uint256[] types);

    function setPunkContract(address punk) public onlyOwner {
        _punkAddress = punk;
    }
    
    function getAddressNameList(string memory user) public view returns(string[] memory) {
        string[] memory keyList = _addKeyMap[user];
        require(keyList.length > 0, "do not have info.");
        //if (keyList.length < 1) {return [];}
        string[] memory nameList = new string[](keyList.length);
        for (uint256 i = 0; i < keyList.length; i++) {
            uint256 res = _addPList[user][keyList[i]];
            if (res > 1) {
                nameList[i] = keyList[i];
            }else {
                nameList[i] = "";
            }
        }
        return nameList;
    }

    function getOwner(uint256 nftId) public view returns(address) {
        return IMasks(_punkAddress).ownerOf(nftId);
    }
    
    function addressToHost(string memory user) public view returns(string memory) {
        return _addToName[user];
    }

    function named(uint256 nftId) public view returns(bool) {
        string memory nftName = IMasks(_punkAddress).getNftName(nftId);
        return bytes(nftName).length>0;
    }
    
    function setHostAddress(string memory name, string memory user) public {
        string memory trxName = getSlice(1, bytes(name).length-4, name);
        uint256 nftId = IMasks(_punkAddress).getNftByName(trxName);
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        
        require(keccak256(abi.encodePacked(_nameToAdd[name])) == keccak256(abi.encodePacked(user)), "name not parse to address.");
        
        _addToName[user] = name;
    }
    
    function getSlice(uint256 begin, uint256 end, string memory text) public pure returns(string memory) {
         bytes memory a = new bytes(end-begin + 1);
         for(uint256 i = 0; i <= end-begin; i++) {
             a [i] = bytes(text)[i + begin-1];
         }
         return string(a);
     }
    
    function setBatchInfos(uint256 nftId, string[] memory keys, string[] memory infos, uint256[] memory types) public {
        require(keys.length > 0, "list can not be empty");
        require(keys.length == infos.length && infos.length == types.length, "params error");
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        require(named(nftId), "not set host name.");
        
         for (uint i = 0; i < keys.length; i++) {
            //Single memory item = Single("", "", "", 0);
            string memory key = toLower(keys[i]);
            uint256 itype = types[i];
            if (itype == 1) {
                BnsInfo storage itemInfo = infoMap[nftId];
                if (itemInfo.chainMap[key] > 0) {
                    uint256 pos = itemInfo.chainMap[key]-1;
                    itemInfo.walletList[pos] = infos[i];
                }else {
                    itemInfo.chainMap[key] = itemInfo.walletList.length+1;
                    itemInfo.walletList.push(infos[i]);
                    itemInfo.chainList.push(key);
                }
                if (keccak256(abi.encodePacked(key)) == keccak256(abi.encodePacked("tron"))) {
                    string memory name = IMasks(_punkAddress).getNftName(nftId);
                    string memory oldAdd = _nameToAdd[name];
                    _nameToAdd[name] = infos[i];
                    if (_addPList[infos[i]][name] < 1) {
                        _addKeyMap[infos[i]].push(name);
                    }
                    _addPList[infos[i]][name] = 6;
                    if (bytes(oldAdd).length > 1) {
                        _addPList[oldAdd][name] = 1;
                    }
                }
               // emit SetSingle(nftId, key, item.wallet, 1);
            }else {
                BnsInfo storage itemInfo = infoMap[nftId];
                if (itemInfo.textMap[key] > 0) {
                    uint256 pos = itemInfo.textMap[key]-1;
                    itemInfo.textList[pos] = infos[i];
                }else {
                    itemInfo.textMap[key] = itemInfo.textList.length+1;
                    itemInfo.textList.push(infos[i]);
                    itemInfo.nameList.push(key);
                }
                //emit SetSingle(nftId, key, item.text, 2);
            }
        }
        emit SetBatch(nftId, keys, infos, types);
    }

   
    function deleteBatch(uint256 nftId, string[] memory keys, uint256[] memory types) public {
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        require(keys.length > 0, "list can not be empty");
        require(keys.length == types.length, "length not same.");

        for (uint i = 0; i < keys.length; i++) {
            string memory key = toLower(keys[i]);
            uint256 itype = types[i];
            if (itype == 1) {
                BnsInfo storage itemInfo = infoMap[nftId];
                uint256 pos = itemInfo.chainMap[key]-1;
                itemInfo.walletList[pos] = "";
                itemInfo.chainMap[key] = 0;
               // emit DeleteSingle(nftId, key, 1);
               
                if (keccak256(abi.encodePacked(key)) == keccak256(abi.encodePacked("tron"))) {
                    string memory name = IMasks(_punkAddress).getNftName(nftId);
                    string memory oldAdd = _nameToAdd[name];
                    if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(_addToName[oldAdd]))) {
                        _addToName[oldAdd] = "";
                    }
                    _nameToAdd[name] = "";
                    _addPList[oldAdd][name] = 1;
                }
            }else {
                BnsInfo storage itemInfo = infoMap[nftId];
                uint256 pos = itemInfo.textMap[key]-1;
                itemInfo.textList[pos] = "";
                itemInfo.textMap[key] = 0;
              //  emit DeleteSingle(nftId, key, 2);
            }
        }

       emit DeleteBatch(nftId, keys, types);
    }

    function deleteText(uint256 nftId, string memory keyName) public {
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        
        keyName = toLower(keyName);
        BnsInfo storage itemInfo = infoMap[nftId];
        uint256 pos = itemInfo.textMap[keyName]-1;
        itemInfo.textList[pos] = "";
        itemInfo.textMap[keyName] = 0;

        emit DeleteSingle(nftId, keyName, 2);
    }

    function deleteWallet(uint256 nftId, string memory chainName) public {
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");

        chainName = toLower(chainName);
        BnsInfo storage itemInfo = infoMap[nftId];
        uint256 pos = itemInfo.chainMap[chainName]-1;
        itemInfo.walletList[pos] = "";
        itemInfo.chainMap[chainName] = 0;
        
        if (keccak256(abi.encodePacked(chainName)) == keccak256(abi.encodePacked("tron"))) {
            string memory name = IMasks(_punkAddress).getNftName(nftId);
            string memory oldAdd = _nameToAdd[name];
            if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(_addToName[oldAdd]))) {
                _addToName[oldAdd] = "";
            }
            _nameToAdd[name] = "";
            _addPList[oldAdd][name] = 1;
        }

        emit DeleteSingle(nftId, chainName, 1);
    }

    function setWallet(uint256 nftId, string memory chainName, string memory wallet) public returns(uint256) {
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        require(named(nftId), "not set host name.");

        BnsInfo storage itemInfo = infoMap[nftId];
        chainName = toLower(chainName);
        if (itemInfo.chainMap[chainName] > 0) {
            uint256 pos = itemInfo.chainMap[chainName]-1;
            itemInfo.walletList[pos] = wallet;
        }else {
            itemInfo.chainMap[chainName] = itemInfo.walletList.length+1;
            itemInfo.walletList.push(wallet);
            itemInfo.chainList.push(chainName);
        }
        if (keccak256(abi.encodePacked(chainName)) == keccak256(abi.encodePacked("tron"))) {
            string memory name = IMasks(_punkAddress).getNftName(nftId);
            string memory oldAdd = _nameToAdd[name];
            _nameToAdd[name] = wallet;
            //_addPList[wallet][name] = 6;
            //_addKeyMap[wallet].push(name);
            if (_addPList[wallet][name] < 1) {
                _addKeyMap[wallet].push(name);
            }
            _addPList[wallet][name] = 6;
            if (bytes(oldAdd).length > 1) {
                _addPList[oldAdd][name] = 1;
            }
        }

        emit SetSingle(nftId, chainName, wallet, 1);
        return itemInfo.chainMap[chainName];
    }

    function setTextItem(uint256 nftId, string memory keyName, string memory textInfo) public {
        require(IMasks(_punkAddress).ownerOf(nftId) == msg.sender, "not the Owner");
        require(named(nftId), "not set host name.");

        BnsInfo storage itemInfo = infoMap[nftId];
        keyName = toLower(keyName);
        if (itemInfo.textMap[keyName] > 0) {
            uint256 pos = itemInfo.textMap[keyName]-1;
            itemInfo.textList[pos] = textInfo;
        }else {
            itemInfo.textMap[keyName] = itemInfo.textList.length+1;
            itemInfo.textList.push(textInfo);
            itemInfo.nameList.push(keyName);
        }

        emit SetSingle(nftId, keyName, textInfo, 2);
    }

    function toLower(string memory str) private pure returns (string memory){
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function getNftTextInfo(uint256 nftId) public view returns(string[] memory nameList, string[] memory textList) {
        return (infoMap[nftId].nameList, infoMap[nftId].textList);
    }

    function getNftWallet(uint256 nftId) public view returns(string[] memory chainList, 
        string[] memory walletList) {
        return (infoMap[nftId].chainList, infoMap[nftId].walletList);
    }
}

//SourceUnit: ReentrancyGuard.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

//SourceUnit: RelationShip.sol

pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./Ownable.sol";

interface IRelationShipStore {
    function addUserFirstItem(uint256 invitorId, address user, uint256 nftId) external returns (bool);
    function addUserSecItem(uint256 firstInvitor, address user, uint256 nftId) external returns (bool);
    function setFirstInvitor(uint256 nftId, uint256 invitorId) external returns(bool);
    function setSecInvitor(uint256 nftId) external returns(bool);
    function getFirstInvitor(uint256 nftId) external view returns(uint256);
    function getSecInvitor(uint256 nftId) external view returns(uint256);
}

contract RelationShip is Ownable {
    struct UserInfo {
        uint256 time;
        address user;
        uint256 nftId;
    }
    
    address private _contractAddress;
    mapping (uint256 => uint256) private _firstInvitors;  //一级邀请
    mapping (uint256 => uint256) private _secInvitors;    //二级邀请
    //mapping (address => uint256) private _reword;         //奖励
    mapping (uint256 => UserInfo[]) public _userFirst;  //用户的直推列表
    mapping (uint256 => UserInfo[]) public _userSec;    //用户的间推列表
    
    function setContract(address newAddress) public onlyOwner {
        _contractAddress = newAddress;
    }
    
    function addUserFirstItem(uint256 invitorId, address user, uint256 nftId) public returns (bool) {
        require(msg.sender == _contractAddress, "only owner can use");
        _userFirst[invitorId].push(UserInfo({
            time: block.timestamp,
            user: user,
            nftId: nftId
        }));
        return true;
    }
    
    function addUserSecItem(uint256 firstInvitor, address user, uint256 nftId) public returns (bool) {
        require(msg.sender == _contractAddress, "only owner can use");
        _userSec[firstInvitor].push(UserInfo(block.timestamp, user, nftId));
        return true;
    }
    
    function setFirstInvitor(uint256 nftId, uint256 invitorId) public returns(bool) {
        require(msg.sender == _contractAddress, "only owner can use");
        _firstInvitors[nftId] = invitorId;
        return true;
    }
    
    function setSecInvitor(uint256 nftId, uint256 invitorId) public returns(bool) {
        require(msg.sender == _contractAddress, "only owner can use");
        _secInvitors[nftId] = invitorId;
        return true;
    }
    
    function getFirstInvitor(uint256 nftId) public view returns(uint256) {
        return _firstInvitors[nftId];
    }
    
    function getSecInvitor(uint256 nftId) public view returns(uint256){
        return _secInvitors[nftId];
    }
    
    function userFirstList(uint256 nftId) public view returns(UserInfo[] memory) {
        return _userFirst[nftId];
    }

    function userSecondList(uint256 nftId) public view returns(UserInfo[] memory) {
        return _userSec[nftId];
    }
    
    function nftInvitor(uint256 nftId) public view returns(uint256) {
        return _firstInvitors[nftId];
    }
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

//SourceUnit: Strings.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}