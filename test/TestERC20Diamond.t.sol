// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/interfaces/IDiamondCut.sol";
import "../src/ERC20/facets/DiamondCutFacet.sol";
import "../src/ERC20/facets/DiamondLoupeFacet.sol";
import "../src/ERC20/facets/OwnershipFacet.sol";
import "../src/ERC20/facets/DiamondERC20Facet.sol";
import "../src/ERC20/facets/NameFacet.sol";
import "../src/ERC20/DiamondInit.sol";
import "../src/ERC20/Diamond.sol";

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract TestERC20Diamond is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond _diamond;
    DiamondCutFacet _dCutFacet;
    DiamondLoupeFacet _dLoupe;
    OwnershipFacet _ownerFacet;
    DiamondERC20Facet _tokenFacet;
    DiamondInit _dInit;

    // NameFacet used for upgrade.
    NameFacet _nameFacet;

    function setUp() public {
        //deploy facets
        _dCutFacet = new DiamondCutFacet();
        _diamond = new Diamond(address(this), address(_dCutFacet));
        _dLoupe = new DiamondLoupeFacet();
        _ownerFacet = new OwnershipFacet();
        _tokenFacet = new DiamondERC20Facet();
        _dInit = new DiamondInit();
        
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        // ./out/DiamondLoupeFacet.sol
        cut[0] = (
            FacetCut({
                facetAddress: address(_dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: _generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(_ownerFacet),
                action: FacetCutAction.Add,
                functionSelectors: _generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(_tokenFacet),
                action: FacetCutAction.Add,
                functionSelectors: _generateSelectors("DiamondERC20Facet")
            })
        );

        cut[3] = (
            FacetCut({
                facetAddress: address(_dInit),
                action: FacetCutAction.Add,
                functionSelectors: _generateSelectors("DiamondInit")
            })
        );

        //upgrade _diamond
        IDiamondCut(address(_diamond)).diamondCut(cut, address(0x0), "");
        //Initialization
        DiamondInit(address(_diamond)).init();
    }

    function testDiamondToken() public {
        string memory name = DiamondERC20Facet(address(_diamond)).name();
        string memory symbol = DiamondERC20Facet(address(_diamond)).symbol();
        uint256 totalSupply = DiamondERC20Facet(address(_diamond))
            .totalSupply();

        assertEq(name, "Test Token");
        assertEq(symbol, "TTKN");
        assertEq(totalSupply, 1_000_000e18);
    }

    // multiple initialization should fail
    function testMultipleInitialize() public {
        vm.expectRevert(AlreadyInitialized.selector);
        DiamondInit(address(_diamond)).init();
    }

    function testNameFacetUpgrade() public {
        address __diamond = address(_diamond);
        _nameFacet= new NameFacet();

        FacetCut[] memory cut = new FacetCut[](1);
        cut[0] = (
            FacetCut({
                facetAddress: address(_nameFacet),
                action: FacetCutAction.Replace,
                functionSelectors: _generateSelectors("NameFacet")
            })
        );
        // replace function selectors
        IDiamondCut(__diamond).diamondCut(cut, address(0), "");
        string memory name = NameFacet(__diamond).name();
        string memory symbol = NameFacet(__diamond).symbol();

        assertEq(name, "Diamond Token V2");
        assertEq(symbol, "DTKN V2");
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
