// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";


import "../src/interfaces/IDiamondCut.sol";
import "../src/ERC721/facets/ERC721DiamondCutFacet.sol";
import "../src/ERC721/facets/ERC721DiamondLoupeFacet.sol";
import "../src/ERC721/facets/ERC721OwnershipFacet.sol";
import "../src/ERC721/facets/ERC721DiamondTokenFacet.sol";
import "../src/ERC721/facets/ERC721NameFacet.sol";
import "../src/ERC721/ERC721DiamondInit.sol";
import "../src/ERC721/ERC721Diamond.sol";

import "forge-std/console.sol";

contract ERC721DiamondScript is Script, IDiamondCut {

    ERC721Diamond _diamond;
    ERC721DiamondCutFacet _dCutFacet;
    ERC721DiamondLoupeFacet _dLoupe;
    ERC721OwnershipFacet _ownerFacet;
    ERC721DiamondTokenFacet _dTokenFacet;
    ERC721DiamondInit _dInit;

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
       console.log(address(this));
        vm.startBroadcast(vm.envUint("TEST_PRIVATE_KEY")); // msg.sender is not changed
      address _owner = parseAddress(vm.envString("OWNER_ADDRESS"));
        _dCutFacet = new ERC721DiamondCutFacet();
        _ownerFacet = new ERC721OwnershipFacet();
        _dLoupe = new ERC721DiamondLoupeFacet();
        _diamond = new ERC721Diamond(_owner, address(_dCutFacet), address(_dLoupe), address(_ownerFacet));
        _dTokenFacet = new ERC721DiamondTokenFacet();
        _dInit = new ERC721DiamondInit();

        FacetCut[] memory cut = new FacetCut[](2);

   cut[0] = (
      FacetCut({
        facetAddress:address(_dInit),
        action:FacetCutAction.Add,
        functionSelectors:_generateSelectors("ERC721DiamondInit")
      })
    );
    cut[1] = (
      FacetCut({
        facetAddress:address(_dTokenFacet),
        action:FacetCutAction.Add,
        functionSelectors:_generateSelectors("ERC721DiamondTokenFacet")
      })
      );


     //upgrade _diamond
        IDiamondCut(address(_diamond)).diamondCut(cut, address(0x0), "");
        //Initialization
        ERC721DiamondInit(address(_diamond)).init();


      //mint
      ERC721DiamondTokenFacet(address(_diamond)).mint(_owner, "aaa");
       vm.stopBroadcast();
      
    }
      function _generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "script/generateSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }



  function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}

  }