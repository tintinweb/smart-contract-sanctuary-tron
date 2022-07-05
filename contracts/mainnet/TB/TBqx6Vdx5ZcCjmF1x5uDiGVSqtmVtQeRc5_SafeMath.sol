//SourceUnit: SafeMath.sol

pragma solidity 0.8.6;

library SafeMath {
    /// @notice Returns x + y, reverts if sum overflows uint256
    /// @param x The augend
    /// @param y The addend
    /// @return z The sum of x and y
    function add(uint256 x, uint256 y) external returns (uint256 z) {
    unchecked {
        require((z = x + y) >= x);
    }
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @return z The difference of x and y
    function sub(uint256 x, uint256 y) external returns (uint256 z) {
    unchecked {
        require((z = x - y) <= x);
    }
    }

    /// @notice Returns x - y, reverts if underflows
    /// @param x The minuend
    /// @param y The subtrahend
    /// @param message The error msg
    /// @return z The difference of x and y
    function sub(
        uint256 x,
        uint256 y,
        string memory message
    ) external returns (uint256 z) {
    unchecked {
        require((z = x - y) <= x, message);
    }
    }

    /// @notice Returns x * y, reverts if overflows
    /// @param x The multiplicand
    /// @param y The multiplier
    /// @return z The product of x and y
    function mul(uint256 x, uint256 y) external returns (uint256 z) {
    unchecked {
        require(x == 0 || (z = x * y) / x == y);
    }
    }

    /// @notice Returns x / y, reverts if overflows - no specific check, solidity reverts on division by 0
    /// @param x The numerator
    /// @param y The denominator
    /// @return z The product of x and y
    function div(uint256 x, uint256 y) external returns (uint256 z) {
        return x / y;
    }
}