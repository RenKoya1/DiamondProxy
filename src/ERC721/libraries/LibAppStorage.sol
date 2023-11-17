// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct TokenStorage {

    uint256 initialized;
    //tokend
    uint256 tokenId;
    // Mapping from token ID to approved address
    mapping(uint256 => address) allowance;
    // Mapping from tokenID to owner address
    mapping(uint256 => address)  tokenOwner;
     // Mapping from owner address to token count
    mapping(address => uint256)  balances;
    // Mapping from tokenID to tokenURI
    mapping(uint256 => string)  tokenURIs;
    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) operatorApprovals;
}

library LibAppStorage {
    function tokenStorage() internal pure returns (TokenStorage storage ts) {
        assembly {
            ts.slot := 0
        }
    }
}
