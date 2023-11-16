// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";

import {TokenStorage} from "../libraries/LibAppStorage.sol";
import {LibERC20} from "../libraries/LibERC20.sol";

error InsufficientAllowance();

contract DiamondERC20Facet is  IERC20Metadata {
    TokenStorage _storage;

    // IERC20metadata
    /// @notice returns the name of the token.
    function name() external pure override returns (string memory) {
        return "Test Token";
    }

    /// @notice returns the symbol of the token.
    function symbol() external pure override returns (string memory) {
        return "TTKN";
    }

    function totalSupply() external view override returns (uint256) {
        return _storage.totalSupply;
    }

    /// @notice returns the token decimals.
    function decimals() external pure override returns (uint8) {
        return 18;
    }

    /// @notice returns the balance of an address.
    function balanceOf(
        address _owner
    ) external view override returns (uint256 balance) {
        balance = _storage.balances[_owner];
    }

    /// @notice transfers `_value` token from `caller` to `_to`.
    function transfer(
        address _to,
        uint256 _value
    ) external override returns (bool success) {
        LibERC20.transfer(_storage, msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        success = true;
    }

    /// @notice transfers `_value` token_storage, from `_from` to `_to`.
    /// @dev   `caller` must be initially approved.
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external override returns (bool success) {
        uint256 _allowance = _storage.allowances[_from][msg.sender];
        if (_allowance < _value) revert InsufficientAllowance();

        LibERC20.transfer(_storage, _from, _to, _value);
        unchecked {
            _storage.allowances[_from][msg.sender] -= _value;
        }

        success = true;
    }



    /// @notice approves `_spender` for `_value` token_storage, owned by caller.
    function approve(
        address _spender,
        uint256 _value
    ) external override returns (bool success) {
        LibERC20.approve(_storage, msg.sender, _spender, _value);
         emit Approval(msg.sender, _spender, _value);
        success = true;
    }

    /// @notice gets the allowance for spender `_spender` by the owner `_owner`
    function allowance(
        address _owner,
        address _spender
    ) external view override returns (uint256 remaining) {
        remaining = _storage.allowances[_owner][_spender];
    }
}
