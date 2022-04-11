//SourceUnit: Msale.sol

pragma solidity >=0.5.0;
// SPDX-License-Identifier: Unlicensed
pragma experimental ABIEncoderV2;

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

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



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


library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }


    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }


    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    string private _baseUrl;

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _owners;

    // Mapping owner address to token count
    mapping(address => uint256) internal _balances;

    // Mapping from token ID to approved address
    //mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    constructor(string memory name_, string memory symbol_) public{
        _name = name_;
        _symbol = symbol_;
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }


    function _baseURI() internal view virtual returns (string memory) {
        return _baseUrl;
    }

    function _setBaseURI(string memory url)internal {
        _baseUrl = url;
    }


    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        //_approve(to, tokenId);
    }


    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        // require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        // return _tokenApprovals[tokenId];
    }


    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId);
    }


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId);//_data
    }


    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId
        //bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        //require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFromBatch(address from,address to,uint256[] memory tokenIds)public {
        uint len = tokenIds.length;
        for( uint i = 0; i < len; i ++ ){
            safeTransferFrom(from, to, tokenIds[i], "");
        }
    }


    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: operator query for nonexistent token");
         // ERC721.ownerOf(tokenId);
        return spender == owner || isApprovedForAll(owner, spender);
        //spender == owner || getApproved(tokenId) == spender ||
    }


    // function _safeMint(address to, uint256 tokenId) internal virtual {
    //     _safeMint(to, tokenId);
    // }


    function _safeMint(
        address to,
        uint256 tokenId
    ) internal virtual {
        _mint(to, tokenId);
        // require(
        //     _checkOnERC721Received(address(0), to, tokenId, _data),
        //     "ERC721: transfer to non ERC721Receiver implementer"
        // );
    }


    function _mint(address to, uint256 tokenId) internal virtual {
        //require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }


    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
       // _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        //_approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }


    // function _approve(address to, uint256 tokenId) internal virtual {
    //     _tokenApprovals[tokenId] = to;
    //     emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    // }


    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    // function _checkOnERC721Received(
    //     address from,
    //     address to,
    //     uint256 tokenId,
    //     bytes memory _data
    // ) private returns (bool) {
    //     if (isContract(to)) {
    //         try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
    //             return retval == IERC721Receiver.onERC721Received.selector;
    //         } catch (bytes memory reason) {
    //             if (reason.length == 0) {
    //                 revert("ERC721: transfer to non ERC721Receiver implementer");
    //             } else {
    //                 assembly {
    //                     revert(add(32, reason), mload(reason))
    //                 }
    //             }
    //         }
    //     } else {
    //         return true;
    //     }
    // }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}


abstract contract ERC721Standard is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    //uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    //mapping(uint256 => uint256) private _allTokensIndex;
    //uint256 internal supply;
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }


    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }


    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        // require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        // return _allTokens[index];
    }

    function getUserTokenIds(address user,uint start,uint end)public view returns(uint256[] memory ids){

         uint len = _balances[user];

         if( len > 0 ){
             if( end >= len ){
                 end = len - 1;
             }

             if( end >= start ){
                 uint size = end - start + 1;

                 ids = new uint[](size);

                 uint index = 0;
                 for( uint i = start; i <= end; i++ ){
                     ids[index] = _ownedTokens[user][i];
                     index ++;
                 }
             }
         }
    }


    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        //super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            //supply++;
            //_addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            //supply--;
            //_removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }


    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = _balances[to]; // ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }


    // function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
    //     _allTokensIndex[tokenId] = _allTokens.length;
    //     _allTokens.push(tokenId);
    // }


    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = _balances[from] - 1; // ERC721.balanceOf(from) - 1;
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


    // function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {

    //     uint256 lastTokenIndex = _allTokens.length - 1;
    //     uint256 tokenIndex = _allTokensIndex[tokenId];

    //     uint256 lastTokenId = _allTokens[lastTokenIndex];

    //     _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
    //     _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

    //     // This also deletes the contents at the last position of the array
    //     delete _allTokensIndex[tokenId];
    //     _allTokens.pop();
    // }
}


library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }


    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }


    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }


    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }


    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }


    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }


    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }


    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }


    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }


    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }


    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }


    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }


    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }


    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }


    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }


    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }


    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

contract NtokenStandard is ERC721Standard,Ownable{

    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => bool) public isMiner;

    address[] miners;

    uint256 internal _tokenId = 1;

    uint[] nftTypes;

    uint[] nftLevels;

    mapping(uint => uint) public level2Powers;


    struct Nft{
        //uint id;
        uint8 types;
        uint8 level;
    }
    //id => Nft
    mapping(uint => Nft) internal nfts;


    modifier onlyMiner() {
        require(isMiner[msg.sender] || msg.sender == _owner, 'Ownable: caller is not the miner');
        _;
    }

    constructor(
        string memory uri,
        string memory _name,
        string memory _symbol,
        address _ownerAddress) ERC721(_name, _symbol) public {
        _setBaseURI(uri);
        _owner = _ownerAddress;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _tokenId - 1;
    }

    function mint(
        address to,
        uint8 types,
        uint8 level
    ) public virtual onlyMiner returns(uint id){
        id = _tokenId;
        _tokenId ++;

        nfts[id] = Nft(
            types,
            level);

  		_safeMint(to, id);
    }

    function burn(address _from, uint256 _tId) external {
  	  require((msg.sender == _from) || isApprovedForAll(_from, msg.sender), "nft: illegal request");
      require(ownerOf(_tId) == _from, "from is not owner");
      _burn(_tId);
  	}

    function addMiner(address miner)external onlyOwner{
        if( !isMiner[miner]){
            isMiner[miner] = true;
            miners.push(miner);
        }
    }


    function addConfig(
            uint[] memory typeList,
            uint[] memory levelList,
            uint[] memory levelPowers)external onlyOwner{

       nftTypes = typeList;
       nftLevels = levelList;

       uint len = levelList.length;

       for( uint i = 0; i < len; i++){
            level2Powers[levelList[i]] = levelPowers[i];
       }
    }

   function setLevelPower(uint level,uint power)external onlyOwner{
        level2Powers[level] = power;
    }


    struct TokenInfo{
        uint id;
        uint8 types;
        uint8 level;
        uint power;
    }

    function getTokensInfo(address user)external view returns(TokenInfo[] memory infos){

        uint bal = balanceOf(user);
        uint[] memory ids = getUserTokenIds(user,0,bal - 1);

        uint len = ids.length;
        infos = new TokenInfo[](len);

        for( uint i = 0; i < len; i++){
             Nft storage nft = nfts[ids[i]];
             infos[i].id = ids[i];
             infos[i].types = nft.types;
             infos[i].level = nft.level;
             infos[i].power = level2Powers[nft.level];
        }
    }

    function getNftInfo(uint id)external view returns(TokenInfo memory info){
         Nft storage nft = nfts[id];
         info.id = id;
         info.types = nft.types;
         info.level = nft.level;
         info.power = level2Powers[nft.level];
    }

    function getTokenInfo(uint id)external view returns(uint types,uint level,uint power){
        Nft storage nft = nfts[id];
        types = nft.types;
        level = nft.level;
        power = level2Powers[level];
    }

    function getTokenInfos(uint[] memory ids)external view returns(uint product,uint sum,uint level){

        uint len = ids.length;

        uint levelSum = 0;
        product = 1;

        for( uint i = 0; i < len; i ++ ){

            Nft storage nft = nfts[ids[i]];
            uint types = nft.types;
            uint l = nft.level;

            levelSum += l;
            require( levelSum / l == i + 1 ,"level different");

            product *= types;
            sum += types;
        }

        level = levelSum / len;
    }

    function getNftInfos(uint[] memory ids)external view returns(TokenInfo[] memory infos){
         uint len = ids.length;
         infos = new TokenInfo[](len);
         for( uint i = 0; i < len; i++ ){
            Nft storage nft = nfts[ids[i]];
             infos[i].id = ids[i];
             infos[i].types = nft.types;
             infos[i].level = nft.level;
             infos[i].power = level2Powers[nft.level];
         }
    }

    function getMaxLevel()external view returns(uint){
        return nftLevels[nftLevels.length -1];
    }

    function getTypesAndLevels()external view returns(uint[] memory ,uint[] memory){
        return (nftTypes,nftLevels);
    }
}


interface IJustswapExchange {

  function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);

  function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);

}

contract Msale is Ownable{

    IERC20 public payToken;
    NtokenStandard public nft;

    address public usdtExchange;
    address public tokenExchange;

    uint256 public payWorth;

    uint256 public surplusNftAmount;

    mapping(bytes32 => uint) public resultMap;

    uint acce = 100;

    address public receiver;

    event Buy(address indexed owner,uint time,uint id);

    constructor(
        address _receiver,
        address _payToken,
        address _nft,
        address _usdtExchange,
        address _tokenExchange,
        address _ownerAddress
        )public{
            receiver = _receiver;
            usdtExchange = _usdtExchange;
            tokenExchange = _tokenExchange;
            payToken = IERC20(_payToken);
            nft = NtokenStandard(_nft);
            _owner = _ownerAddress;
            acce = 100;
            payWorth = 813e5;
            surplusNftAmount = 8130;
        }


    struct MarketInfo{
        uint total;
        uint payWorth;
        uint payAmount;
        address payToken;
    }

    ///////////////////////////////VIEW///////////////////////////////////
    function getMarketInfo()external view returns(MarketInfo memory info) {
        info.total = surplusNftAmount;
        info.payWorth = payWorth;
        info.payToken = address(payToken);
        info.payAmount = _worthConvert(payWorth);
    }

    ///////////////////////////////WRITE///////////////////////////////

    function _getRandomValue(address sender)internal view returns(uint){
        return uint256(keccak256(abi.encodePacked(sender,block.timestamp,acce)));
    }

    function _worthConvert(uint usdtAmount)internal view returns(uint){

        uint256 trxAmount = IJustswapExchange(usdtExchange).getTokenToTrxInputPrice(usdtAmount);

        return IJustswapExchange(tokenExchange).getTrxToTokenInputPrice(trxAmount);
    }

    function buy(bytes32 flag) external  {

        require( !_isContract(msg.sender),"not allow");

        require( surplusNftAmount >= 1,"value lock" );

        surplusNftAmount -= 1;

        uint256 tokenAmount = _worthConvert(payWorth);

        payToken.transferFrom(msg.sender, receiver, tokenAmount);

        uint256 seed = _getRandomValue(msg.sender);

        acce += seed % 1000;

        uint types = seed % 12 + 1;
        uint level = _getRandomLevel(seed);

        uint id = nft.mint(msg.sender, uint8(types), uint8(level));

        resultMap[flag] = id;

        emit Buy(msg.sender,block.timestamp,id);
    }

    function _getRandomLevel(uint seed)internal pure returns(uint){
        uint v = seed % 100;
        if( v < 76 ) return 1;
        if( v < 88 ) return 2;
        if( v < 94 ) return 3;
        if( v < 98 ) return 4;
        if( v < 100) return 5;
    }


    function _isContract(address a) internal view returns(bool){
        uint256 size;
        assembly {size := extcodesize(a)}
        return size > 0;
    }

    ///////////////////////////////MANAGE///////////////////////////////
    function setReceiver(address _receiver)external onlyOwner{
        receiver = _receiver;
    }

    function updateMarketPrice(uint price)external onlyOwner{
        payWorth = price;
    }

    function updateMarket(uint amount)external onlyOwner{
        surplusNftAmount += amount;
    }

}