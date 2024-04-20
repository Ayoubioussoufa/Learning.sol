// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import { DeployOurToken } from "../script/DeployOurToken.s.sol";
import { OurToken } from "../src/OurToken.sol";
import { Test, console } from "forge-std/Test.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is StdCheats, Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY(), "Incorrect initial supply");
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testTransfers() public {
        address recipient = address(0x1);
        uint256 amount = 100;
        vm.prank(msg.sender);
        ourToken.transfer(recipient, amount);

        assertEq(ourToken.balanceOf(recipient), amount, "Recipient balance incorrect");
        assertEq(ourToken.balanceOf(msg.sender), deployer.INITIAL_SUPPLY() - amount, "Sender balance incorrect");
    }

    function testApproveAndAllowance() public {
        address spender = address(0x1);
        uint256 amount = 100;

        ourToken.approve(spender, amount);

        assertEq(ourToken.allowance(address(this), spender), amount, "Allowance incorrect");
    }

    function testTransferFrom() public {
        // address spender = address(0x1);
        address recipient = address(0x2);
        uint256 amount = 1000;
        vm.prank(msg.sender);
        ourToken.approve(address(this), amount);
        console.log(ourToken.balanceOf(msg.sender));
        console.log(ourToken.balanceOf(address(this)));
        ourToken.transferFrom(msg.sender, recipient, amount);
        assertEq(ourToken.balanceOf(recipient), amount);
        assertEq(ourToken.balanceOf(msg.sender), deployer.INITIAL_SUPPLY() - amount, "Sender balance incorrect");
        // assertEq(ourToken.allowance(address(this), spender), 0, "Allowance not reset");
    }

    // Additional tests can be added for functionalities like increasing/decreasing allowances, burning tokens, etc.
}