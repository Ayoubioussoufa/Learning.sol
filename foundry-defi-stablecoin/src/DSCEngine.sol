//SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.20;

import { ERC20Burnable, ERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DSCEngine
 * @author Aybiouss
 * The system is designed to be as minimal as possible, and have the tokens to maintain a 1 token == 1$ peg.
 * This stablecoin has the properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algorithmically Stable
 * 
 * It is similar to DAI is DAI had no governance, no fees, and was only backed by WETH and WBTC.
 * 
 * Our Dsc system should always  be "overcollateralized". At no point, should the value of all collateral <= the $ backed value of all the DSC.
 * 
 * @notice This contract is the core of the DSC System. It handles all the logic for minting and redeeming DSC, as well as depositing & withdrawing collateral.
 * @notice This contract is VERY loosely based on the MakeDao DSS (DAI) system.
 */

contract DSCEngine {
    function depositCollateralAndMintDsc() external {
        
    }

    function depositCollateral() external {

    }

    function redeemCollateralForDsc() external {

    }

    function redeemCollateral() external {

    }

    function mintDsc() external {

    }

    function burnDsc() external {

    }

    function liquidate() external {

    }

    function gethealthFactor() external view {

    }
}