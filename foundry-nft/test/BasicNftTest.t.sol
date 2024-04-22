// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DeployBasicNft} from "../script/BasicNftDeploy.s.sol";

contract TestBasicNft is Test {
    DeployBasicNft public deployBasicNft;
    BasicNft public basicNft;
    address public player = makeAddr("bob");

    string public constant PUG = "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() public {
        deployBasicNft = new DeployBasicNft();
        basicNft = deployBasicNft.run();
    }

    function testMintFunction() public { 
        assert(basicNft.getTokenCounter() == 0);
        vm.prank(player);
        basicNft.mintNft(PUG);
        console.log(basicNft.getTokenCounter());
        assert(basicNft.getTokenCounter() == 1);
    }

    function testTokenUri() public {
        vm.prank(player);
        basicNft.mintNft(PUG);
        console.log(basicNft.getTokenMappingsUri(0));
        assertEq(basicNft.getTokenMappingsUri(0), PUG);
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "Dogie";
        string memory expectedSymbol = "DOG";
        assertEq(basicNft.name(), expectedName);
        assertEq(basicNft.symbol(), expectedSymbol);
        assert(
            keccak256(abi.encodePacked(basicNft.name())) == 
                keccak256(abi.encodePacked(expectedName)));
    }
}