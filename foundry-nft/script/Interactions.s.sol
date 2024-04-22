// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";


contract MintBasicNft is Script {

    string public constant PUG = "http://bafybeibv2mb2nhrr5f6mk3yenapjgbfn63vst74o6foj6wlkdoxx4za6vy.ipfs.localhost:8080/";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "BasicNft", block.chainid);
        mintNftOnContract(mostRecentlyDeployed);
    }

    function mintNftOnContract(address contractAddress) public {
        vm.startBroadcast();
        BasicNft(contractAddress).mintNft(PUG);
        vm.stopBroadcast();
    }
}