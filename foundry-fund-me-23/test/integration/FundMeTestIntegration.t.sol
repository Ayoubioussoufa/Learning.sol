//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interaction.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundme;

    address USER = makeAddr("user");
    uint256 constant SENDVALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GASPRICE = 1;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMes(address(fundme));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMes(address(fundme));
        // vm.prank(USER);
        // vm.deal(USER, 1e18);

        // address funder = fundme.getFunders(0);
        // assertEq(funder, msg.sender);
        assertEq(address(fundme).balance, 0);
    }
}