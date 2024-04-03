// SPDX-license-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script {

    NetworkConfig public activeOne;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111)
            activeOne = getSepoliaEthConfig();
        else if (block.chainid == 1)
            activeOne = getEthConfig();
        else
            activeOne = getOrCreateAnvilConfig();
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepolia = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepolia;
    }

    function getEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory eth = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return eth;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeOne.priceFeed != address(0))
            return activeOne;
        vm.startBroadcast();
        MockV3Aggregator mock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mock)});
        return anvilConfig;
    }
}