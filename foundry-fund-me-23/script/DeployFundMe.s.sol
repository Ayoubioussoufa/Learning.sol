// SPDX-license-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig(); // Before startBroadcast to not pay any gas fees
        vm.startBroadcast();
        // Let's create a Mock address
        FundMe fundme = new FundMe(helperConfig.activeOne());
        vm.stopBroadcast();
        return fundme;
    }
}