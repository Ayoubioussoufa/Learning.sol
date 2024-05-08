// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

contract SmallSol {
    function a(uint256 num) public pure returns(uint256) {
        num = num + 1;
        return num;
    }
}