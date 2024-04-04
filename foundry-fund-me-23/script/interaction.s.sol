//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FundMe} from "../src/Fundme.sol";

contract FundFundMe is Script {
    uint256 constant SENDVALUE = 1 ether;
    function fundFundMes(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SENDVALUE}();
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMes(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {

    function withdrawFundMes(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMes(mostRecentlyDeployed);
    }
}