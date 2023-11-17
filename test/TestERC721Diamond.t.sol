// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/interfaces/IDiamondCut.sol";
import "../src/ERC721/facets/ERC721DiamondCutFacet.sol";
import "../src/ERC721/facets/ERC721DiamondLoupeFacet.sol";
import "../src/ERC721/facets/ERC721OwnershipFacet.sol";
import "../src/ERC721/facets/ERC721DiamondTokenFacet.sol";
import "../src/ERC721/facets/ERC721NameFacet.sol";
import "../src/ERC721/ERC721DiamondInit.sol";
import "../src/ERC721/ERC721Diamond.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";

import {TokenStorage, LibAppStorage} from "../src/ERC721/libraries/LibAppStorage.sol";
import {LibDiamond} from "../src/ERC721/libraries/LibDiamond.sol";

contract TestERC721Diamond is Test, IDiamondCut {
  ERC721Diamond _diamond;
  ERC721DiamondCutFacet _dCutFacet;
  ERC721DiamondLoupeFacet _dLoupe;
  ERC721OwnershipFacet _ownerFacet;
  ERC721DiamondTokenFacet _dTokenFacet;
  ERC721DiamondInit _dInit;
  ERC721NameFacet _nameFacet;

  address _alice;
  address _bob;

  function setUp() public {
    _alice = makeAddr("alice");
    _bob = makeAddr("bob");
    vm.startPrank(_alice);
    _dCutFacet = new ERC721DiamondCutFacet();
      _ownerFacet = new ERC721OwnershipFacet();
      _dLoupe = new ERC721DiamondLoupeFacet();
      _diamond = new ERC721Diamond(_alice, address(_dCutFacet), address(_dLoupe), address(_ownerFacet));
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
      vm.stopPrank();
  

  }


  function testName() public {
    vm.startPrank(_alice);
    string memory name = ERC721DiamondTokenFacet(address(_diamond)).name();
      assertEq(name, "NFT V1");

      string memory symbol = ERC721DiamondTokenFacet(address(_diamond)).symbol();
      assertEq(symbol, "NFTV1");
    vm.stopPrank();
  }

   function testNameFacetUpgrade() public {
    vm.startPrank(_alice);
        address __diamond = address(_diamond);
        _nameFacet= new ERC721NameFacet();

        FacetCut[] memory cut = new FacetCut[](1);
        cut[0] = (
            FacetCut({
                facetAddress: address(_nameFacet),
                action: FacetCutAction.Replace,
                functionSelectors: _generateSelectors("ERC721NameFacet")
            })
        );
        // replace function selectors
        IDiamondCut(__diamond).diamondCut(cut, address(0), "");
        string memory name = ERC721NameFacet(__diamond).name();
        string memory symbol = ERC721NameFacet(__diamond).symbol();

        assertEq(name, "NFT V2");
        assertEq(symbol, "NFTV2");
        vm.stopPrank();
    }


     // multiple initialization should fail
    function testMultipleInitialize() public {
        vm.expectRevert(AlreadyInitialized.selector);
        ERC721DiamondInit(address(_diamond)).init();
    }


  function testNotOwnerMint() public {
      vm.expectRevert(LibDiamond.NotDiamondOwner.selector);
   ERC721DiamondTokenFacet(address(_diamond)).mint(_alice, "aaa");
    
  }

  function testOwnerMint() public {
    vm.startPrank(_alice);
     ERC721DiamondTokenFacet(address(_diamond)).mint(_bob, "aaa");
    vm.stopPrank();
    vm.startPrank(_bob);
     vm.expectRevert(ERC721DiamondTokenFacet.SBT.selector);
     ERC721DiamondTokenFacet(address(_diamond)).safeTransferFrom(_bob, _alice, 0);
     vm.stopPrank();

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