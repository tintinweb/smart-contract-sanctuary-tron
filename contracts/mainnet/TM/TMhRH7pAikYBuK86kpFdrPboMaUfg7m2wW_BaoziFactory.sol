//SourceUnit: flattened.sol

// File: contracts/interfaces/IEventEmitter.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEventEmitter {
   
    function mint(address sender, address pair, uint amount0, uint amount1) external returns(bool);
    function pairCreated(address token0, address token1, address pair, uint length) external returns(bool);
}

// File: contracts/interfaces/IBaoziFactory.sol

pragma solidity >=0.5.0;


interface IBaoziFactory {

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function eventEmitter() external view returns (IEventEmitter);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function getFeeAddress(address token) external view returns (address owner);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function setTokensDev(address[] calldata tokenAddress, address[] calldata devAddress) external;
}

// File: contracts/interfaces/IBaoziTRC20.sol

pragma solidity >=0.5.0;

interface IBaoziTRC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// File: contracts/interfaces/IBaoziPair.sol

pragma solidity >=0.5.0;


interface IBaoziPair is IBaoziTRC20 {
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function initialize(address _token0, address _token1) external;
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

// File: contracts/BaoziTRC20.sol

pragma solidity >=0.8.0;


contract BaoziTRC20 is IBaoziTRC20 {

    string public constant override name = 'Baozi LPs';
    string public constant override symbol = 'Baozi-LP';
    uint8 public constant override decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    bytes32 public immutable override DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) override public nonces;

    constructor() {
        uint chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        require(deadline >= block.timestamp, 'Baozi: EXPIRED');

        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        require(owner == ecrecover(digest, v, r, s) && owner != address(0), 'Baozi: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}

// File: contracts/libraries/Math.sol

pragma solidity >=0.8.0;
// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
            if (y > 3) {
                z = y;
                uint x = y / 2 + 1;
                while (x < z) {
                    z = x;
                    x = (y / x + x) / 2;
                }
            } else if (y != 0) {
                z = 1;
            }
    }
}

// File: contracts/libraries/UQ112x112.sol

pragma solidity >=0.8.0;
// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        unchecked {
            z = uint224(y) * Q112; // never overflows
        }
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        unchecked {
            z = x / uint224(y);
        }
    }
}

// File: contracts/interfaces/ITRC20.sol

pragma solidity >=0.5.0;

interface ITRC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// File: contracts/interfaces/IBaoziCallee.sol

pragma solidity >=0.5.0;

interface IBaoziCallee {
    function BaoziCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

// File: contracts/BaoziPair.sol

pragma solidity >=0.8.0;









contract BaoziPair is IBaoziPair, BaoziTRC20 {
    using UQ112x112 for uint224;

    uint public constant override MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public immutable override factory;
    address public override token0;
    address public override token1;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public override price0CumulativeLast;
    uint public override price1CumulativeLast;
    uint public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;
    modifier lock {
        require(unlocked != 0, 'Baozi: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function getReserves() external view override returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success, 'Baozi: TRANSFER_FAILED');
        require(data.length == 0 || abi.decode(data, (bool)), 'Baozi: TRANSFER_FAILED');
    }

    constructor() {
        factory = msg.sender;
    }

    function initialize(address _token0, address _token1) external override {
        require(msg.sender == factory, 'Baozi: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, 'Baozi: OVERFLOW');
        uint32 blockTimestamp;
        unchecked {
            blockTimestamp = uint32(block.timestamp % 2 ** 32);
        }
        uint32 timeElapsed;
        unchecked {
            timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        }
        if (timeElapsed != 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            unchecked {
                price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
                price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
            }
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(uint112(balance0), uint112(balance1));
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IBaoziFactory(factory).feeTo();
        address tokenOwner1 = IBaoziFactory(factory).getFeeAddress(token0);
        address tokenOwner2 = IBaoziFactory(factory).getFeeAddress(token1);
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0) * _reserve1);
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint liquidity = (totalSupply * (rootK - rootKLast)) / (rootK * 5 + rootKLast);
                    if (liquidity != 0) {
                        uint256 count = 1;
                        if (tokenOwner1 != address(0)) count++;
                        if (tokenOwner2 != address(0)) count++;
                        if (count == 1) {
                            _mint(feeTo, liquidity);
                        } else {
                            _mint(feeTo, liquidity * 3 / 5);
                        }
                        if (count == 3) {
                            _mint(tokenOwner1, liquidity / 5);
                            _mint(tokenOwner2, liquidity / 5);
                        }
                        if (count == 2 && tokenOwner1 != address(0)) _mint(tokenOwner1, liquidity * 2 / 5);
                        if (count == 2 && tokenOwner2 != address(0)) _mint(tokenOwner2, liquidity * 2 / 5);

                    }
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external override lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1) = (reserve0, reserve1); // gas savings
        uint balance0 = ITRC20(token0).balanceOf(address(this));
        uint balance1 = ITRC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - _reserve0;
        uint amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min((amount0 * _totalSupply) / _reserve0, (amount1 * _totalSupply) / _reserve1);
        }
        require(liquidity != 0, 'Baozi: NOT_ENOUGH_LIQ_MINTED');
        _mint(to, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        IBaoziFactory(factory).eventEmitter().mint(to, address(this), amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external override lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1) = (reserve0, reserve1); // gas savings
        (address _token0, address _token1) = (token0, token1);         // gas savings
        uint balance0 = ITRC20(_token0).balanceOf(address(this));
        uint balance1 = ITRC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 != 0 && amount1 != 0, 'Baozi: NOT_ENOUGH_LIQ_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = ITRC20(_token0).balanceOf(address(this));
        balance1 = ITRC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external override lock {
        require(amount0Out != 0 || amount1Out != 0, 'Baozi: NOT_ENOUGH_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1) = (reserve0, reserve1); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'Baozi: NOT_ENOUGH_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        (address _token0, address _token1) = (token0, token1);
        require(_token0 != to && _token1 != to, 'Baozi: INVALID_TO');
        if (amount0Out != 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out != 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length != 0) IBaoziCallee(to).BaoziCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = ITRC20(_token0).balanceOf(address(this));
        balance1 = ITRC20(_token1).balanceOf(address(this));
        }
        uint amount0In;
        uint amount1In;
        unchecked {
            uint t1 = _reserve0 - amount0Out;
            uint t2 = _reserve1 - amount1Out;
            if (balance0 > t1) amount0In = balance0 - t1;
            if (balance1 > t2) amount1In = balance1 - t2;
        }
        require(amount0In != 0 || amount1In != 0, 'Baozi: NOT_ENOUGH_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        require(
            (balance0 * 1000 - amount0In * 3) * (balance1 * 1000 - amount1In * 3) // balances adjusted
            >= 
            uint(_reserve0) * _reserve1 * 1000**2, 'Baozi: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external override lock {
        _safeTransfer(token0, to, ITRC20(token0).balanceOf(address(this)) - reserve0);
        _safeTransfer(token1, to, ITRC20(token1).balanceOf(address(this)) - reserve1);
    }

    // force reserves to match balances
    function sync() external override lock {
        _update(ITRC20(token0).balanceOf(address(this)), ITRC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}

// File: contracts/BaoziFactory.sol

pragma solidity >=0.8.0;




contract BaoziFactory is IBaoziFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(BaoziPair).creationCode));

    IEventEmitter public immutable override eventEmitter;

    address public override feeTo;
    address public override feeToSetter;

    mapping(address => address) public override getFeeAddress;
    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor(address _feeToSetter, IEventEmitter _eventEmitter) {
        feeToSetter = _feeToSetter;
        eventEmitter = _eventEmitter;
    }

    function allPairsLength() external view override returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'Baozi: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Baozi: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'Baozi: PAIR_EXISTS'); // single check is sufficient
 
        pair = address(new BaoziPair{salt: keccak256(abi.encodePacked(token0, token1))}());
        IBaoziPair(pair).initialize(token0, token1);
        
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        eventEmitter.pairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'Baozi: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setTokensDev(address[] calldata _tokenAddress, address[] calldata _devAddress) external override {
        require(msg.sender == feeToSetter, 'Baozi: FORBIDDEN');
        require(_tokenAddress.length == _devAddress.length, "Wrong count of token and devs");
        for (uint i = 0; i < _tokenAddress.length; i++) {
            if (getFeeAddress[_tokenAddress[i]] != _devAddress[i]) {
                getFeeAddress[_tokenAddress[i]] = _devAddress[i];
            }
        }
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(feeToSetter == msg.sender, 'Baozi: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }
}