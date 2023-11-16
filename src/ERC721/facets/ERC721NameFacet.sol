// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721NameFacet {
    function name() external pure returns (string memory) {
        return "NFT V2";
    }
    function symbol() external pure returns (string memory) {
        return "NFTV2";
    }
}
