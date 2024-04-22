// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    
    uint256 private s_tokenCounter;
    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function tokenURI(uint256 _tokenId)
        public view override returns(string memory) {
            return s_tokenIdToUri[_tokenId];
    }

    function getTokenCounter() public view returns(uint256) {
        return s_tokenCounter;
    }

    function getTokenMappingsUri(uint256 tokenCounter) public view returns(string memory) {
        return s_tokenIdToUri[tokenCounter];
    }
}
//"ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json"