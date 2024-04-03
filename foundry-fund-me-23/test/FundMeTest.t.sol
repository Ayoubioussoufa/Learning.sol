//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/Fundme.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant SENDVALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;
    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_VALUE);
    }
    function testMinimumDollarIsFive() view public {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() view public {
        // console.log(msg.sender);
        // console.log(fundme.i_owner());
        assertEq(fundme.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate()view public {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // next line revert == fail
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundme.fund{value: SENDVALUE}();

        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SENDVALUE);
    }

    // function TestFundFailsWithoutEnoughEth() public {
    //     vm.expectRevert(); // next line revert == fail
    //     fundme.fund();
    // }

    // function TestFundUpdatesFundedDataStructure() public {
    //     vm.prank(USER);
    //     fundme.fund{value: SENDVALUE}();

    //     uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
    //     assertEq(amountFunded, SENDVALUE);
    // } // 1:10:00 Patterns not provided galik
    
// what can we do to work with addresses outside our system
// .1  Unit:
        // Testing a specific part of our code
// .2  Integration
        // Testing our code works with other parts of our code
// .3  Forked:
        // Testing our code on a simulated real environment
// .4 Staging:
        // Testing our code in a real environment that is not prod

    
}
