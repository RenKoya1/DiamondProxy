// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibUtils}from "../libraries/LibUtils.sol";
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


    function run() public {
    ERC721Diamond _diamond = ERC721Diamond(payable( LibUtils.parseAddress(vm.envString("CONTRACT_ADDRESS"))));
    vm.startBroadcast(vm.envUint("TEST_PRIVATE_KEY")); // msg.sender is not changed
    address _owner = LibUtils.parseAddress(vm.envString("OWNER_ADDRESS"));


      //mint
      uint256 newTokenId = ERC721DiamondTokenFacet(address(_diamond)).mint(_owner, "aaa");

      console.log(newTokenId);
       vm.stopBroadcast();
      
    }
  }