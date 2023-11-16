// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";


import "../../src/interfaces/IDiamondCut.sol";
import "../../src/ERC721/facets/ERC721DiamondCutFacet.sol";
import "../../src/ERC721/facets/ERC721DiamondLoupeFacet.sol";
import "../../src/ERC721/facets/ERC721OwnershipFacet.sol";
import "../../src/ERC721/facets/ERC721DiamondTokenFacet.sol";
import "../../src/ERC721/facets/ERC721NameFacet.sol";
import "../../src/ERC721/ERC721DiamondInit.sol";
import "../../src/ERC721/ERC721Diamond.sol";

import "forge-std/console.sol";

contract MintScript is Script {

    function setUp() public {}
 function parseAddress(string memory _a) internal pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}

    function run() public {
    ERC721Diamond _diamond = ERC721Diamond(payable( parseAddress(vm.envString("CONTRACT_ADDRESS"))));
        vm.startBroadcast(vm.envUint("TEST_PRIVATE_KEY")); // msg.sender is not changed
        address _owner = parseAddress(vm.envString("OWNER_ADDRESS"));


      //mint
      uint256 newTokenId = ERC721DiamondTokenFacet(address(_diamond)).mint(_owner, "aaa");
      console.log(newTokenId);
       vm.stopBroadcast();
      
    }
  }