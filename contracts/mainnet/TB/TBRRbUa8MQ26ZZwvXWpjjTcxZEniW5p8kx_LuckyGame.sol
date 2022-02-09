//SourceUnit: 游戏20220129.sol

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint256);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "e3");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ow1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ow2");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "e4");
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}

contract LuckyGame is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    IERC20 public luckyToken;
    address public feeAddress;
    uint256 feeRate = 25;
    uint256 burnRate = 25;
    uint256 public totalAmount;
    uint256 public rewardAmount;
    bool public canLuckyAction = false;
    bool public canSlot = false;
    uint256 public bestRate = 5;
    uint256[5] public numList = [66667, 86667, 96667, 98889, 100000];

    event RandResult(uint256 rand_num, uint256 reward_num);
    event SlotResult(uint256 rand_num, uint256 reward_num);

    function depositIntegerAmount(uint256 _amount) external onlyOwner {
        luckyToken.safeTransferFrom(msg.sender, address(this), _amount.mul(10 ** luckyToken.decimals()));
        totalAmount = luckyToken.balanceOf(address(this));
    }

    function withDrawIntegerAmount(uint256 _amount) external onlyOwner {
        luckyToken.safeTransfer(msg.sender, _amount.mul(10 ** luckyToken.decimals()));
        totalAmount = luckyToken.balanceOf(address(this));
    }

    function setNumListFour(uint256[] memory _numList) external onlyOwner {
        require(_numList.length == 4, "k0");
        require(_numList[0] > 10000 && _numList[3] < 100000 && _numList[1] > _numList[0] && _numList[2] > _numList[1] && _numList[3] > _numList[2], "k2");
        numList[0] = _numList[0];
        numList[1] = _numList[1];
        numList[2] = _numList[2];
        numList[3] = _numList[3];
    }

    function setFeeRate(uint256 _feeRate, uint256 _burnRate) external onlyOwner {
        feeRate = _feeRate;
        burnRate = _burnRate;
    }

    function setBestRate(uint256 _bestRate) external onlyOwner {
        bestRate = _bestRate;
    }

    function enableLuckyAction() external onlyOwner {
        canLuckyAction = true;
    }

    function disableLuckyAction() external onlyOwner {
        canLuckyAction = false;
    }

    function enableSlot() external onlyOwner {
        canSlot = true;
    }

    function disableSlot() external onlyOwner {
        canSlot = false;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setToken(IERC20 _token) external onlyOwner {
        luckyToken = _token;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        feeAddress = _feeAddress;
    }

    function takeErc20Token(IERC20 _token, uint256 _amount) external onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0 && _amount <= amount);
        if (_amount == 0) {
            _token.safeTransfer(msg.sender, amount);
        } else {
            _token.safeTransfer(msg.sender, _amount);
        }
    }

    function rand(uint256 _length, address _address, string memory _string) public view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now, _address, _string)));
        if (random % _length == 0) {
            return 1;
        } else {
            return random % _length;
        }
    }

    function ifOK(uint256 _rewardAmount, uint256 _rewardAmountForUser, uint256 _totalAmount) internal view returns (bool) {
        return _rewardAmount.add(_rewardAmountForUser) < _totalAmount.mul(bestRate).div(10);
    }

    function luckyAction(uint256 luckyPrice) public nonReentrant returns (uint256 rand_num, uint256 reward_num)  {
        require(canLuckyAction, "disabled");
        uint256 luckPriceBigNum = luckyPrice.mul(10 ** luckyToken.decimals());
        uint256 fee = luckPriceBigNum.mul(feeRate).div(100);
        uint256 burn = luckPriceBigNum.mul(burnRate).div(100);
        uint256 left = luckPriceBigNum.sub(fee).sub(burn);
        require(luckyPrice == 10 || luckyPrice == 20 || luckyPrice == 30, "e10");
        require(!isContract(msg.sender));
        luckyToken.safeTransferFrom(msg.sender, feeAddress, fee);
        luckyToken.safeTransferFrom(msg.sender, address(1), burn);
        luckyToken.safeTransferFrom(msg.sender, address(this), left);
        totalAmount = luckyToken.balanceOf(address(this));
        rand_num = rand(1e5, msg.sender, 'rand_num');
        uint256 rewardAmountForUser;
        if (rand_num < numList[0]) {
            reward_num = 0;
        } else if (rand_num >= numList[0] && rand_num < numList[1]) {
            reward_num = 1;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
            } else {
                reward_num = 0;
            }
        } else if (rand_num >= numList[1] && rand_num < numList[2]) {
            reward_num = 2;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
            } else {
                reward_num = 0;
            }
        } else if (rand_num >= numList[2] && rand_num < numList[3]) {
            reward_num = 3;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
            } else {
                reward_num = 0;
            }
        } else if (rand_num >= numList[3] && rand_num <= numList[4]) {
            reward_num = 5;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
            } else {
                reward_num = 0;
            }
        }
        emit RandResult(rand_num, reward_num);
    }

    function slot(uint256 luckyPrice) public nonReentrant returns (uint256 rand_num, uint256 reward_num)  {
        require(canSlot, "disabled");
        uint256 luckPriceBigNum = luckyPrice.mul(10 ** luckyToken.decimals());
        uint256 fee = luckPriceBigNum.mul(feeRate).div(100);
        uint256 burn = luckPriceBigNum.mul(burnRate).div(100);
        uint256 left = luckPriceBigNum.sub(fee).sub(burn);
        require(luckyPrice == 20 || luckyPrice == 40 || luckyPrice == 60, "e10");
        require(!isContract(msg.sender));
        luckyToken.safeTransferFrom(msg.sender, feeAddress, fee);
        luckyToken.safeTransferFrom(msg.sender, address(1), burn);
        luckyToken.safeTransferFrom(msg.sender, address(this), left);
        totalAmount = luckyToken.balanceOf(address(this));
        uint256 rand_num1 = rand(10, msg.sender, 'rand_num1');
        uint256 rand_num2 = rand(10, msg.sender, 'rand_num2');
        uint256 rand_num3 = rand(10, msg.sender, 'rand_num3');
        uint256 rewardAmountForUser;
        if (rand_num1 == rand_num2 && rand_num2 == rand_num3) {
            reward_num = 6;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
                rand_num = (rand_num1.mul(100)).add(rand_num2.mul(10)).add(rand_num3.mul(1));
            } else {
                reward_num = 0;
                rand_num = 642;
            }

        } else if (rand_num2 == rand_num1.add(1) && rand_num3 == rand_num2.add(1)) {
            reward_num = 3;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
                rand_num = (rand_num1.mul(100)).add(rand_num2.mul(10)).add(rand_num3.mul(1));
            } else {
                reward_num = 0;
                rand_num = 753;
            }
        } else if (rand_num1 == rand_num2.add(1) && rand_num2 == rand_num3.add(1)) {
            reward_num = 3;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
                rand_num = (rand_num1.mul(100)).add(rand_num2.mul(10)).add(rand_num3.mul(1));
            } else {
                reward_num = 0;
                rand_num = 864;
            }
        } else if ((rand_num1 == rand_num2 && rand_num2 != rand_num3) || (rand_num2 == rand_num3 && rand_num1 != rand_num2) || (rand_num1 == rand_num3 && rand_num1 != rand_num2)) {
            reward_num = 2;
            rewardAmountForUser = luckPriceBigNum.mul(reward_num);
            if (ifOK(rewardAmount, rewardAmountForUser, totalAmount)) {
                rewardAmount = rewardAmount.add(rewardAmountForUser);
                luckyToken.safeTransfer(msg.sender, rewardAmountForUser);
                totalAmount = totalAmount.sub(rewardAmountForUser);
                rand_num = (rand_num1.mul(100)).add(rand_num2.mul(10)).add(rand_num3.mul(1));
            } else {
                reward_num = 0;
                rand_num = 975;
            }
        } else {
            reward_num = 0;
            rand_num = (rand_num1.mul(100)).add(rand_num2.mul(10)).add(rand_num3.mul(1));
        }
        emit SlotResult(rand_num, reward_num);
    }
}