// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import {TokenStorage, LibAppStorage} from "./LibAppStorage.sol";

library LibERC721 {
  function addToOwner(
     address _to,
    uint256 _id
  ) internal{
    TokenStorage storage ts = LibAppStorage.tokenStorage();

    unchecked{

    ts.balances[_to] += 1;
    }

     ts.tokenOwner[_id] = _to;

  }

  function removeFromOwner(
    address _from ,
    uint256 _id
  )internal {
    TokenStorage storage ts = LibAppStorage.tokenStorage();

    delete ts.allowance[_id];

    unchecked{
      ts.balances[_from] -= 1;
    }
    delete ts.tokenOwner[_id];
  }
}

