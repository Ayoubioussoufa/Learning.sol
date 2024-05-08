// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

import {CaughtWithFuzz} from "../src/CaughtWithFuzz.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract CaughtWithFuzzTest is Test {
    CaughtWithFuzz public caughtWithFuzz;
    function setUp() external {
        caughtWithFuzz = new CaughtWithFuzz();
    }

    function testFuzz(uint256 randomNumber) public {
        uint256 returnedNumber = caughtWithFuzz.doMoreMath(randomNumber);
        assert(returnedNumber != 0);
    }
}