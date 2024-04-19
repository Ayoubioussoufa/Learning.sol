//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "../../lib/forge-std/src/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {

    event enteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;

    address public player = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            
        ) = helperConfig.activeNetworkConfig();
        vm.deal(player, STARTING_USER_BALANCE);
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); // means on any raffle contract check if RaffleState is open
    }

    // enter raffle

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(player);
        // Act
        vm.expectRevert(Raffle.Raffle__notEnoughEthSent.selector);
        // Assert
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == player);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(player);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit enteredRaffle(player);
        raffle.enterRaffle{value: entranceFee}();
    }
    
    function testCantEnterWhenRaffleIsCalculating() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.perfomUpkeep("");
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
    }

    ////////////////////////////
    ////checkUpkeep/////////////
    ////////////////////////////

    function testCheckUpKeepIfItHasNoBalance() public {
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        //act 
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        //assert
        assertEq(upkeepNeeded, false);
    }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() public {
        // arrange
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.perfomUpkeep("");
        // act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(upkeepNeeded == false);
    }

    function testCheckUpKeepReverts() public {
        // arrange
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        // vm.warp(block.timestamp + interval + 1);
        // vm.roll(block.number + 1);
        vm.expectRevert();
        raffle.perfomUpkeep("");
        // act
        // (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        // assert(upkeepNeeded == false);
    }

    function testCheckUpKeepReturnsTrueWhenParametersAreGood() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        // raffle.perfomUpkeep("");
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(upkeepNeeded == true);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasntPassed() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    ////////////////////////////
    ////perfomUpkeep////////////
    ////////////////////////////

    function testPerformUpKeepCanOnlyRunIfCheckUpKeepIsTrue() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.perfomUpkeep("");
    }

    function testPerfomUpKeepRevertsIfCheckUpKeepIsFalse() public {
        // vm.prank(player);
        // raffle.enterRaffle{value: entranceFee}();
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0;
        vm.expectRevert(
            abi.encodeWithSelector(
            Raffle.Raffle__UpKeepNotNeeded.selector, 
            currentBalance,
            numPlayers,
            raffleState
            )
        );
        raffle.perfomUpkeep("");
    }

    function testPerfomUpKeepUpdatesRaffleStateAndEmitsRequestId() public {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.recordLogs();
        raffle.perfomUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[1];
        assert(uint256(requestId) > 0);
        Raffle.RaffleState rState = raffle.getRaffleState();
        assert(uint256(rState) == 1);
    }

    modifier skipFork() {
        if (block.chainid != 31337) {
            return ;
        }
        _;
    }

    function testFullfillRandomWrodsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) public skipFork {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(raffle));
    }

    function testFullfilRandomWordsPicksAWInnerResetsAndSendMoney() public skipFork {
        vm.prank(player);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);

        uint256 additionalEntrants = 5;
        uint256 startingIndex = 1;
        for (uint256 i = startingIndex; i < additionalEntrants; i++) {
            address playr = address(uint160(i));
            hoax(playr, STARTING_USER_BALANCE);
            raffle.enterRaffle{value: entranceFee}();
        }

        uint256 prize = entranceFee * (additionalEntrants);
        uint256 previousTimeStamp = raffle.getLastTimeStamp();
        
        vm.recordLogs();
        raffle.perfomUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffle));
        assert(uint256(raffle.getRaffleState()) == 0);
        assert(raffle.getrecentWinner() != address(0));
        assert(raffle.getPlayersLength() == 0);
        assert(raffle.getLastTimeStamp() > previousTimeStamp);
        assert(raffle.getrecentWinner().balance == STARTING_USER_BALANCE - entranceFee + prize);
    }
}