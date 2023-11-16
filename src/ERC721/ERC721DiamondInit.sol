// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibDiamond} from "./libraries/LibDiamond.sol";
import {IDiamondLoupe} from "../interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../interfaces/IDiamondCut.sol";
import {IERC173} from "../interfaces/IERC173.sol";
import {TokenStorage} from "./libraries/LibAppStorage.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC165.sol";
error AlreadyInitialized();

contract ERC721DiamondInit {
    TokenStorage _storage;

    function init() external {
        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // initialize the token contract
        if (_storage.initialized == 1) revert AlreadyInitialized();
        _storage.tokenId = 0;
        _storage.initialized = 1;
    }
}
