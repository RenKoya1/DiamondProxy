// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TokenStorage} from "./LibAppStorage.sol";

library LibERC20 {
    error InvalidAddress();
    error InsufficientBalance();

    function transfer(
        TokenStorage storage ts,
        address _from,
        address _to,
        uint256 _value
    ) internal {
        if (_from == address(0)) revert InvalidAddress();
        if (_to == address(0)) revert InvalidAddress();
        if (ts.balances[_from] < _value) revert InsufficientBalance();

        unchecked {
            ts.balances[_from] -= _value;
            ts.balances[_to] += _value;
        }

    }

    function approve(
        TokenStorage storage ts,
        address _owner,
        address _spender,
        uint256 _value
    ) internal {
        if (_owner == address(0)) revert InvalidAddress();
        if (_spender == address(0)) revert InvalidAddress();

        ts.allowances[_owner][_spender] += _value;

    }
}
