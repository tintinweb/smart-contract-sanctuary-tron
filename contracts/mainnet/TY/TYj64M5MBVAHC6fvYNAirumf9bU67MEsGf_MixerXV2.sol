//SourceUnit: minerXV2.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.5.0;


contract Proxy {

    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }


    function _implementation() internal  view returns (address);

    function _fallback() internal {
        _delegate(_implementation());
    }


    function () payable external {
        _fallback();
    }
    
}


contract UpgradeableProxy is Proxy {

    event Upgraded(address indexed implementation);


    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal  view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            impl := sload(slot)
        }
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        require(isContract(newImplementation), "UpgradeableProxy: new implementation is not a contract");

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
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

    /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter = 1;


    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and make it call a
    * `private` function that does the actual work.
    */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


contract MixerXV2 is UpgradeableProxy  , ReentrancyGuard {
    using SafeMath for uint256;
    address public pendingAdmin;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    bytes32 private constant _TOKEN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.token")) - 1);
    bool public paused = false;
    uint256 public feeRatio;
    uint256 public scalingFactor; // used when decimals of TRC20 token is too large.
    uint256 public leafCount;
    uint256 constant INT64_MAX = 2 ** 63 - 1;
    bytes32 public latestRoot;
    mapping(bytes32 => bytes32) public nullifiers; // store nullifiers of spent commitments
    mapping(bytes32 => bytes32) public roots; // store history root
    mapping(uint256 => bytes32) public tree;
    mapping(bytes32 => bytes32) public noteCommitment;
    bytes32[33] frontier;
    bytes32[32] zeroes = [bytes32(0x0100000000000000000000000000000000000000000000000000000000000000), bytes32(0x817de36ab2d57feb077634bca77819c8e0bd298c04f6fed0e6a83cc1356ca155), bytes32(0xffe9fc03f18b176c998806439ff0bb8ad193afdb27b2ccbc88856916dd804e34), bytes32(0xd8283386ef2ef07ebdbb4383c12a739a953a4d6e0d6fb1139a4036d693bfbb6c), bytes32(0xe110de65c907b9dea4ae0bd83a4b0a51bea175646a64c12b4c9f931b2cb31b49), bytes32(0x912d82b2c2bca231f71efcf61737fbf0a08befa0416215aeef53e8bb6d23390a), bytes32(0x8ac9cf9c391e3fd42891d27238a81a8a5c1d3a72b1bcbea8cf44a58ce7389613), bytes32(0xd6c639ac24b46bd19341c91b13fdcab31581ddaf7f1411336a271f3d0aa52813), bytes32(0x7b99abdc3730991cc9274727d7d82d28cb794edbc7034b4f0053ff7c4b680444), bytes32(0x43ff5457f13b926b61df552d4e402ee6dc1463f99a535f9a713439264d5b616b), bytes32(0xba49b659fbd0b7334211ea6a9d9df185c757e70aa81da562fb912b84f49bce72), bytes32(0x4777c8776a3b1e69b73a62fa701fa4f7a6282d9aee2c7a6b82e7937d7081c23c), bytes32(0xec677114c27206f5debc1c1ed66f95e2b1885da5b7be3d736b1de98579473048), bytes32(0x1b77dac4d24fb7258c3c528704c59430b630718bec486421837021cf75dab651), bytes32(0xbd74b25aacb92378a871bf27d225cfc26baca344a1ea35fdd94510f3d157082c), bytes32(0xd6acdedf95f608e09fa53fb43dcd0990475726c5131210c9e5caeab97f0e642f), bytes32(0x1ea6675f9551eeb9dfaaa9247bc9858270d3d3a4c5afa7177a984d5ed1be2451), bytes32(0x6edb16d01907b759977d7650dad7e3ec049af1a3d875380b697c862c9ec5d51c), bytes32(0xcd1c8dbf6e3acc7a80439bc4962cf25b9dce7c896f3a5bd70803fc5a0e33cf00), bytes32(0x6aca8448d8263e547d5ff2950e2ed3839e998d31cbc6ac9fd57bc6002b159216), bytes32(0x8d5fa43e5a10d11605ac7430ba1f5d81fb1b68d29a640405767749e841527673), bytes32(0x08eeab0c13abd6069e6310197bf80f9c1ea6de78fd19cbae24d4a520e6cf3023), bytes32(0x0769557bc682b1bf308646fd0b22e648e8b9e98f57e29f5af40f6edb833e2c49), bytes32(0x4c6937d78f42685f84b43ad3b7b00f81285662f85c6a68ef11d62ad1a3ee0850), bytes32(0xfee0e52802cb0c46b1eb4d376c62697f4759f6c8917fa352571202fd778fd712), bytes32(0x16d6252968971a83da8521d65382e61f0176646d771c91528e3276ee45383e4a), bytes32(0xd2e1642c9a462229289e5b0e3b7f9008e0301cbb93385ee0e21da2545073cb58), bytes32(0xa5122c08ff9c161d9ca6fc462073396c7d7d38e8ee48cdb3bea7e2230134ed6a), bytes32(0x28e7b841dcbc47cceb69d7cb8d94245fb7cb2ba3a7a6bc18f13f945f7dbd6e2a), bytes32(0xe1f34b034d4a3cd28557e2907ebf990c918f64ecb50a94f01d6fda5ca5c7ef72), bytes32(0x12935f14b676509b81eb49ef25f39269ed72309238b4c145803544b646dca62d), bytes32(0xb2eed031d4d6a4f02a097f80b54cc1541d4163c6b6f5971f88b6e41d35c53814)];
    //    uint256 private maxOperableBalance;
    constructor(address _usdtAddress, uint256 _scalingFactorExponent,address _admin) public  {
        _setAdmin(_admin);
        require(_scalingFactorExponent < 77, "The scalingFactorExponent is out of range!");
        scalingFactor = 10 ** _scalingFactorExponent;
        feeRatio = 200;
        _setToken(_usdtAddress);
    }
   

    function implementation() external view onlyAdmin returns (address) {
        return _implementation();
    }

    function admin() public view returns(address){
        return _admin();
    }
    function upgradeTo(address newImplementation) external onlyAdmin  {
  
        _upgradeTo(newImplementation);
    }



    modifier onlyAdmin {
        require(msg.sender == admin(), "Only admin can call this function.");
        _;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }


   
    event Deposit(address indexed account, uint256 amount);

    event AdminWithdraw(address indexed account, address operator, uint256 amount);
    event NewAdmin(address  indexed oldAdmin, address indexed newAdmin);
    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);
    event NewFeeRatio(uint256 feeRation);

    event WithdrawTRX(address account, uint256 amount);
    event WithdrawToken(address token_address, address account, uint256 amount);


    event MintNewLeaf(uint256 position, bytes32 cm, bytes32 cv, bytes32 epk, bytes32[21] c);
    event DepositMixer(address from, uint256 value);
    event WithdrawMixer(address to, uint256 value, bytes32[3] ciphertext);
    event NoteSpent(bytes32 nf);


    event Pause();
    event Unpause();


    function deposit(uint256 amount) external {
        //        maxOperableBalance = maxOperableBalance.add(amount);
        _processDeposit(amount);
        //        _storageBalance[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

 
    function depositMixer(uint256 rawValue, bytes32[9] calldata output, bytes32[2] calldata bindingSignature, bytes32[21] calldata c) external nonReentrant {
        require(noteCommitment[output[0]] == 0, "Duplicate noteCommitments!");
        uint64 value = rawValueToValue(rawValue);
        bytes32 signHash = sha256(abi.encodePacked(address(this), value, output, c));
        (bytes32[] memory ret) = verifyMintProof(output, bindingSignature, value, signHash, frontier, leafCount);
        uint256 result = uint256(ret[0]);
        require(result == 1, "The proof and signature have not been verified by the contract!");

        uint256 slot = uint256(ret[1]);
        uint256 nodeIndex = leafCount + 2 ** 32 - 1;
        tree[nodeIndex] = output[0];
        if (slot == 0) {
            frontier[0] = output[0];
        }
        for (uint256 i = 1; i < slot + 1; i++) {
            nodeIndex = (nodeIndex - 1) / 2;
            tree[nodeIndex] = ret[i + 1];
            if (i == slot) {
                frontier[slot] = tree[nodeIndex];
            }
        }
        latestRoot = ret[slot + 2];
        roots[latestRoot] = latestRoot;
        noteCommitment[output[0]] = output[0];
        leafCount ++;

        // maxOperableBalance = maxOperableBalance.add(computeFee(rawValue));
        _processDeposit(rawValue);

        emit MintNewLeaf(leafCount - 1, output[0], output[1], output[2], c);
        emit DepositMixer(msg.sender, rawValue);
    }


    function adminWithdraw(address account, uint256 amount) external onlyAdmin {
        // require(amount <= maxOperableBalance, "Withdraw excess");
        // maxOperableBalance = maxOperableBalance.sub(amount);
        _processWithdrawUSDT(account, amount);
        emit AdminWithdraw(account, _admin(), amount);
    }


    function adminWithdrawTRX(address payable account, uint256 amount) external onlyAdmin {
        account.transfer(amount);
        emit WithdrawTRX(account, amount);
    }


    function adminWithdrawToken(address token_address, address account, uint256 amount) external onlyAdmin {
        _processWithdraw(token_address, account, amount);
    }


    function withdrawMixer(bytes32[10] calldata input, bytes32[2] calldata spendAuthoritySignature, uint256 rawValue, bytes32[2] calldata bindingSignature, address payTo, bytes32[3] calldata burnCipher) whenNotPaused external {
        uint64 value = rawValueToValue(rawValue);
        bytes32 signHash = sha256(abi.encodePacked(address(this), input, payTo, value));

        bytes32 nf = input[0];
        bytes32 anchor = input[1];
        require(nullifiers[nf] == 0, "The note has already been spent!");
        require(roots[anchor] != 0, "The anchor must exist!");
   
        (bool result) = verifyBurnProof(input, spendAuthoritySignature, value, bindingSignature, signHash);
        require(result, "The proof and signature have not been verified by the contract!");

        nullifiers[nf] = nf;
        emit NoteSpent(nf);

        uint256 fee = computeFee(rawValue);
        _processWithdrawUSDT(payTo, rawValue.sub(fee));

        emit WithdrawMixer(payTo, rawValue, burnCipher);
    }

    //position: index of leafnode, start from 0
    function getPath(uint256 position) public view returns (bytes32, bytes32[32] memory) {
        require(position >= 0, "Position should be non-negative!");
        require(position < leafCount, "Position should be smaller than leafCount!");
        uint256 index = position + 2 ** 32 - 1;
        bytes32[32] memory path;
        uint32 level = ancestorLevel(position);
        bytes32 targetNodeValue = getTargetNodeValue(position, level);
        for (uint32 i = 0; i < 32; i++) {
            if (i == level) {
                path[31 - i] = targetNodeValue;
            } else {
                if (index % 2 == 0) {
                    path[31 - i] = tree[index - 1];
                } else {
                    path[31 - i] = tree[index + 1] == 0 ? zeroes[i] : tree[index + 1];
                }
            }
            index = (index - 1) / 2;
        }
        return (latestRoot, path);
    }

    function ancestorLevel(uint256 leafIndex) private view returns (uint32) {
        uint256 nodeIndex1 = leafIndex + 2 ** 32 - 1;
        uint256 nodeIndex2 = leafCount + 2 ** 32 - 2;
        uint32 level = 0;
        while (((nodeIndex1 - 1) / 2) != ((nodeIndex2 - 1) / 2)) {
            nodeIndex1 = (nodeIndex1 - 1) / 2;
            nodeIndex2 = (nodeIndex2 - 1) / 2;
            level = level + 1;
        }
        return level;
    }

    function getTargetNodeValue(uint256 leafIndex, uint32 level) private view returns (bytes32) {
        bytes32 left;
        bytes32 right;
        uint256 index = leafIndex + 2 ** 32 - 1;
        uint256 nodeIndex = leafCount + 2 ** 32 - 2;
        bytes32 nodeValue = tree[nodeIndex];
        if (level == 0) {
            if (index < nodeIndex) {
                return nodeValue;
            }
            if (index == nodeIndex) {
                if (index % 2 == 0) {
                    return tree[index - 1];
                } else {
                    return zeroes[0];
                }
            }
        }
        for (uint32 i = 0; i < level; i++) {
            if (nodeIndex % 2 == 0) {
                left = tree[nodeIndex - 1];
                right = nodeValue;
            } else {
                left = nodeValue;
                right = zeroes[i];
            }
            nodeValue = pedersenHash(i, left, right);
            nodeIndex = (nodeIndex - 1) / 2;
        }
        return nodeValue;
    }

    function computeFee(uint256 amount) private view returns (uint256){
        return amount.mul(feeRatio).div(1000);
    }

    /*function getMaxOperableBalance() view external onlyAdmin returns(uint256){
        return maxOperableBalance;
    }*/
    function pause() external onlyAdmin {
        paused = true;
        emit Pause();
    }
    function unpause() external onlyAdmin {
        paused = false;
        emit Unpause();
    }
    function destroyNullifiers(bytes32 _nullifiers ) external onlyAdmin{
        nullifiers[_nullifiers] = _nullifiers;
        emit NoteSpent(_nullifiers);
    }

    function updateFeeRatio(uint32 _feeRatio) external onlyAdmin {
        feeRatio = _feeRatio;
        emit NewFeeRatio(_feeRatio);
    }

    function _admin() internal view returns (address adm) {
        bytes32 slot = _ADMIN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            adm := sload(slot)
        }
    }
    function _token() internal view returns (address tok) {
        bytes32 slot = _TOKEN_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            tok := sload(slot)
        }
    }
    function usdtAddres() external view returns(address){
        return _token();
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        bytes32 slot = _ADMIN_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newAdmin)
        }
    }

        /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setToken(address token) private {
        bytes32 slot = _TOKEN_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, token)
        }
    }
    function acceptAdmin() public {
        require(msg.sender == pendingAdmin , " Pending admin You are not ");
        emit NewAdmin(_admin(), msg.sender );
        _setAdmin(pendingAdmin);
        pendingAdmin = address(0);
        emit NewPendingAdmin(msg.sender, pendingAdmin);
       
    }

    function setPendingAdmin(address _newAdmin) external onlyAdmin {
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = _newAdmin;
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function rawValueToValue(uint256 rawValue) private view returns (uint64) {
        require(rawValue > 0, "Value must be positive!");
        require(rawValue.mod(scalingFactor) == 0, "Value must be integer multiples of scalingFactor!");
        uint256 value = rawValue.div(scalingFactor);
        require(value < INT64_MAX);
        return uint64(value);
    }

    function _processDeposit(uint256 amount) internal {
        require(msg.value == 0, "TRX value is supposed to be 0");
        bool result = _safeTrc20TransferFrom(msg.sender, address(this), amount);
        require(result, "Deposit failed!");
    }

    function _processWithdrawUSDT(address _recipient, uint256 amount) internal {
        bool result = _safeTrc20TransferUSDT(_recipient, amount);
        require(result, "Withdraw failed!");
    }


    function _processWithdraw(address token_address, address _recipient, uint256 amount) internal {
        bool result = _safeTrc20Transfer(token_address, _recipient, amount);
        require(result, "Withdraw failed!");
        emit WithdrawToken(token_address, _recipient, amount);
    }

    function _safeTrc20TransferUSDT(address _to, uint256 _amount) internal returns (bool){
        (bool success, bytes memory data) = _token().call(abi.encodeWithSelector(0xa9059cbb /* transfer */, _to, _amount));
        return (success && (data.length == 0 || !abi.decode(data, (bool))));
    }

    function _safeTrc20Transfer(address token_address, address to, uint value) internal returns (bool){
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token_address.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _safeTrc20TransferFrom(address from, address to, uint value) internal returns (bool){
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = _token().call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }
}