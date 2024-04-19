// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
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

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

/**
 * @title A Sample Raffle Contract
 * @author Ayoub Bioussoufa
 * @notice This contract is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */

contract Raffle is VRFConsumerBaseV2 {

    error Raffle__notEnoughEthSent();
    error Raffle__transferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle__UpKeepNotNeeded(uint256 balance, uint256 numPlayers, uint256 raffleState);

    /*Type declaration*/
    enum RaffleState {
        OPEN, // 0
        CALCULATING // 1 indexed
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUMWORDS = 1;

    uint256 private immutable i_entranceFee;
    // @dev Duration of the lottery in seconds
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    VRFCoordinatorV2Interface private immutable i_coordinator;

    address payable[] private s_players;
    address private recentWinner;
    RaffleState private s_raffleState;

    /*Events: */
    event enteredRaffle(address indexed player);
    event winnerPicked(address indexed winner);
    event forRequestId(uint256 indexed requestId);

    constructor(uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_coordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        // require(msg.value >= i_entranceFee, "Not Enough Eth sent"); // or custom errors
        if (msg.value < i_entranceFee)
            revert Raffle__notEnoughEthSent();
        if (s_raffleState != RaffleState.OPEN)
            revert Raffle__RaffleNotOpen();
        s_players.push(payable(msg.sender));
        emit enteredRaffle(msg.sender);
    }

    // when the winner should be picked ?
    /**
     * @dev This is the function that the Chainlink Automation nodes call to see if its time to perform an upkeep.
     * 1. the Time intervan has passed between raffle runs.
     * 2. The raffle is in OPEN state
     * 3. The contract has eth aka players
     * 4. the subscription is funded with Link
     */
    function checkUpkeep(
        bytes memory /*checkData*/
    ) public view returns(bool upkeepNeeded, bytes memory /* performData */) {
        bool timeHasPassed = block.timestamp - s_lastTimeStamp >= i_interval;
        bool isOpen = RaffleState.OPEN == s_raffleState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = (timeHasPassed && isOpen && hasBalance && hasPlayers);
        return (upkeepNeeded, "0x0");
    }
    
    // get a random player, pick with it a player and be automatically called
    function perfomUpkeep(bytes calldata /* perfomeData  */) external {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded)
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_raffleState)
            );
        // 1. Request the RNG
        // 2. Get the random number
        s_raffleState = RaffleState.CALCULATING;
        uint256 requestId = i_coordinator.requestRandomWords(
            i_gasLane, //gas lane
            i_subscriptionId, // id that you have funded with link
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUMWORDS // number of number words
        );
        emit forRequestId(requestId);
    }
    // CEI : CHECKS, EFFECTS, INTERACTIONS
    function fulfillRandomWords(
        uint256 /*requestId*/,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        recentWinner = winner;
        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit winnerPicked(winner);
        (bool success,) = winner.call{value: address(this).balance}("");
        if (!success)
            revert Raffle__transferFailed();
    }

    /*Getter functions : */

    function getEntranceFee() external view returns(uint256) {
        return i_entranceFee;
    }

    function getRaffleState() external view returns(RaffleState) {
        return s_raffleState;
    }

    function getPlayer(uint256 indexOfPlayer) external view returns(address){
        return s_players[indexOfPlayer];
    }

    function getrecentWinner() external view returns(address) {
        return recentWinner;
    }

    function getPlayersLength() external view returns(uint256){
        return s_players.length;
    }

    function getLastTimeStamp() external view returns (uint256) {
        return s_lastTimeStamp;
    }
}
