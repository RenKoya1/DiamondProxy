// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/utils/Context.sol";
import "openzeppelin-contracts/contracts/utils/Address.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";


import {TokenStorage} from "../libraries/LibAppStorage.sol";
import {LibERC721} from "../libraries/LibERC721.sol";
import {LibDiamond} from "../libraries/LibDiamond.sol";
import "forge-std/console.sol";

contract ERC721DiamondTokenFacet is Context {
    using Address for address;
    using Strings for uint256;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event MetadataUpdate(uint256 indexed tokenId, string tokenURI);
    error SBT();
    
    TokenStorage _tokenStorage;


    /// @notice returns the name of the token.
    function name() external pure returns (string memory) {
        return "NFT V1";
    }

    /// @notice returns the symbol of the token.
    function symbol() external pure returns (string memory) {
        return "NFTV1";
    }

    function totalSupply() external view returns (uint256){
        return _tokenStorage.tokenId;
    }

    /// @notice returns the balance of an address.
    function balanceOf(
        address _owner
    ) external view returns (uint256 balance) {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        balance = _tokenStorage.balances[_owner];
    }


    /// @notice returns the owner of a token.
    function ownerOf(
        uint256 _tokenId
    ) external view returns (address owner) {
        owner = _tokenStorage.tokenOwner[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
    }

    /// @notice return tokenURI of a token.
     function tokenURI(uint256 _tokenId) public view virtual returns (string memory _tokenURI) {
        _requireMinted(_tokenId);
        _tokenURI = _tokenStorage.tokenURIs[_tokenId];
    }

    /// @notice return the 
    function _setTokenURI(uint256 _tokenId, string memory _tokenURI) internal virtual {
        require(_exists(_tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenStorage.tokenURIs[_tokenId] = _tokenURI;
        emit MetadataUpdate(_tokenId, _tokenURI);
    }
    /// @notice transfers `_tokenId` token from `caller` to `_to`.
    function transfer(
        address _to,
        uint256 _tokenId
    ) external returns (bool success) {
        _transfer(msg.sender, _to, _tokenId);
        success = true;
    }

    /// @notice transfers `_tokenId` token_tokenStorage, from `_from` to `_to`.
    /// @dev   `caller` must be initially approved.
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external virtual  {
      require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }

      /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public virtual {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public virtual {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(_from, _to, _tokenId, data);
    }
    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory data) internal virtual {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual {
        require(_tokenStorage.tokenOwner[_tokenId] == _from, "ERC721: transfer _from incorrect owner");
        require(_to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer( _from, _to, _tokenId, 1);

        // Check that _tokenId was not transferred by `_beforeTokenTransfer` hook
        require(_tokenStorage.tokenOwner[_tokenId] == _from, "ERC721: transfer _from incorrect owner");

        // Clear approvals _from the previous owner
        LibERC721.addToOwner(_to, _tokenId);
        LibERC721.removeFromOwner(_from, _tokenId);


        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId, 1);
    }


     function _beforeTokenTransfer(address _from, address _to, uint256 _firstTokenId, uint256 _batchSize) internal virtual {
      if (_from != address(0) && _to != address(0)) {
            revert SBT();
        }
     }
     function _afterTokenTransfer(address _from, address _to, uint256 _firstTokenId, uint256 _batchSize) internal virtual {}

      /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = _ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }



    
  function approve(
        address _to,
        uint256 _tokenId
    ) public virtual {
      address owner = _tokenStorage.tokenOwner[_tokenId];
      require(_to != owner, "ERC721: approval to current owner");

      require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
              "ERC721: approve caller is not owner nor approved for all"  );
        
        _tokenStorage.allowance[_tokenId] = _to;

        emit Approval(_tokenStorage.tokenOwner[_tokenId], _to, _tokenId);
    }



     function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        return _tokenStorage.operatorApprovals[owner][operator];
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        _requireMinted(tokenId);

        return _tokenStorage.allowance[tokenId];
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

     function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
     function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _tokenStorage.tokenOwner[tokenId];
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer( address(0), to, tokenId, 1);
        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");
        LibERC721.addToOwner(to, tokenId);
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId, 1);
    }


    function mint(address to, string  memory _tokenURI) public virtual returns (uint256 newTokenId) {
        LibDiamond.onlyOwner(); 
        newTokenId = _tokenStorage.tokenId;
        _safeMint(to, newTokenId);
        _setTokenURI(newTokenId , _tokenURI);
        _tokenStorage.tokenId += 1;
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function burn(uint256 tokenId)public {
        _burn(tokenId);
    }


    function _burn(uint256 tokenId) internal virtual {
        address owner = _ownerOf(tokenId);

        _beforeTokenTransfer( owner, address(0), tokenId, 1);

        owner = _ownerOf(tokenId);

        LibERC721.removeFromOwner(owner, tokenId);


        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

     function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _tokenStorage.operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    //   function supportsInterface(bytes4 _interfaceId) public view virtual( IERC165) returns (bool) {
    //      LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
    //     return ds.supportedInterfaces[_interfaceId] || _interfaceId == type(IERC721).interfaceId ||
    //   _interfaceId == type(IERC721Metadata).interfaceId   || _interfaceId == type(Context).interfaceId;
    // }
}
