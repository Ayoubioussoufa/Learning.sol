// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract CaughtWithTest {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        // Whoops, this isn't right!
        number = newNumber + 1;
    }
}