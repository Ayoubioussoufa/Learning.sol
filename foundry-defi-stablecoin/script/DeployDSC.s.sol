// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {DSCEngine} from "../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDSCEngine is Script {
    DSCEngine dscEngine;
    DecentralizedStableCoin decentralizedStableCoin;
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

    function run() external returns (DecentralizedStableCoin, DSCEngine) {
        HelperConfig helperConfig = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];
        vm.startBroadcast(deployerKey);
        decentralizedStableCoin = new DecentralizedStableCoin();
        dscEngine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(decentralizedStableCoin));
        decentralizedStableCoin.transferOwnership(address(dscEngine));
        vm.stopBroadcast();
        return (decentralizedStableCoin, dscEngine);
    }
}
