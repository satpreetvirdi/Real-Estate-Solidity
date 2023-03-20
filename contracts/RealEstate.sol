//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";


contract RealEstate is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
     constructor() ERC721("Real Estate", "Real") {}
     function mint(string memory tokenURI)public returns(uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
     }
     function totalSupply() public view returns (uint256){
        return _tokenIds.current();
     }
}
