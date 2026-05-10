// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user"); // prank USER Who acts
    uint256 constant SEND_VALUE = 10 ether; // what PRANK USER spend
    uint256 constant STARTING_BALANCE = 100 ether; // what the prank user have
    uint256 constant GAS_PRICE = 1 wei;

    function setUp() external {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIOwnerisMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIs6() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    modifier fundingModifier() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundsFailsWithoutEnoughEth() public {
        vm.expectRevert(); // hey, the next line should revert because it is not up to expection according to my contract eg testing less than the amount users must pass
        // assert(this tx should fail/revert)
        fundMe.fund{value: 1e8}();
    }

    function testFundUpdatesFundedDataStructure() public fundingModifier {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testonlyTheOwnerCanWithdraw() public fundingModifier {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testAddsFunderToArrayOfFunders() public fundingModifier {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdrawWithASingleFunder() public fundingModifier {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromContractToOwnerBalance() public fundingModifier {
        // ARRANGE
        // Save the starting state”
        // Storing or Checking balances before anything happens
        // So you can compare later
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // ACT
        uint256 gasStart = gasleft(); // HAD 1000 GAS   BEFORE
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //Pretend to be owner
        fundMe.withdraw(); // Call withdraw() // spent gas now eg 200

        uint256 gasEnd = gasleft(); // had 800 gas now
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    // function testWithdrawFromMultipleFunders() public fundingModifier {
    //     // ----------- Arrange -----------
    //     uint160 numberOfFunders = 10;
    //     uint160 startingFunderIndex = 1;

    //     for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
    //         hoax(address(i), SEND_VALUE);
    //         fundMe.fund{value: SEND_VALUE}();
    //     }
    //     uint256 startingFundMeBalance = address(fundMe).balance;
    //     uint256 startingOwnerBalance = fundMe.getOwner().balance;

    //     // ----------- Act -----------
    //     vm.startPrank(fundMe.getOwner());
    //     fundMe.withdraw();
    //     vm.stopPrank();

    //     // ----------- Assert -----------
    //     uint256 endingOwnerBalance = fundMe.getOwner().balance;
    //     uint256 endingFundMeBalance = address(fundMe).balance;

    //     assertEq(endingFundMeBalance, 0);

    //     assertEq(
    //         endingOwnerBalance,
    //         startingOwnerBalance + startingFundMeBalance
    //     );
    // }

    function testWithdrawFromMultipleFunders() public fundingModifier {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // hoax = prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        assert((numberOfFunders + 1) * SEND_VALUE == fundMe.getOwner().balance - startingOwnerBalance);
    }

    // THESE LAST TESTS no clear yet
    function testReceiveTriggersFund() public {
        vm.prank(USER);
        vm.deal(USER, SEND_VALUE);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}("");
        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testFallbackTriggersFund() public {
        vm.prank(USER);
        vm.deal(USER, SEND_VALUE);
        (bool success,) = address(fundMe).call{value: SEND_VALUE}(abi.encodeWithSignature("nonExistentFunction()"));
        assertTrue(success);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testMappingResetsAfterWithdraw() public fundingModifier {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(fundMe.getAddressToAmountFunded(USER), 0);
    }
}

// pranking  pattern
// address ALICE = makeAddr("alice");
// vm.prank(ALICE);
// fundMe.fund{value: 1 ether}();

// Let me break every line down.

// ---

// ## Line 1 — At the top of the contract

// ```solidity
// contract FundMeTest is Test {
//     FundMe fundMe; // ← declared here
// ```

// This declares `fundMe` as a **state variable** of the test contract. It's empty right now — just a box with nothing in it yet.

// Why here and not inside `setUp`? Because **every test function needs access to it.** If you declared it inside `setUp`, only `setUp` could see it. Declaring it at the top means ALL functions can see it.

// ```
// FundMe fundMe;  ← empty box, visible to everyone in this contract
// ```

// ---

// ## Line 2 — Inside `setUp()`

// ```solidity
// DeployFundMe deployFundMe = new DeployFundMe();
// ```

// Creates a fresh `DeployFundMe` script. Just like how you'd run it on the command line — but here Forge runs it for you inside the test.

// ```
// new DeployFundMe() → fires DeployFundMe's constructor → ready to use
// ```

// ---

// ## Line 3 — The hand-off

// ```solidity
// fundMe = deployFundMe.run();
// ```

// Calls `run()` which triggers the entire deployment chain:

// ```
// run() fires
//   → HelperConfig constructor fires
//   → Mock deploys (Anvil) or real address returned (Sepolia)
//   → FundMe deploys with that address
//   → returns the deployed FundMe
//         ↓
// fundMe = that returned FundMe ← now the box has something in it
// ```

// ---

// ## Why `setUp()` specifically?

// Forge runs `setUp()` **automatically before every single test.** So every test starts with a fresh, clean FundMe.

// ```
// setUp() runs → fresh FundMe
// testMinimumUsdIsFive() runs
// setUp() runs → fresh FundMe again
// testFundFailsWithoutEnoughETH() runs
// setUp() runs → fresh FundMe again
// testIOwnerisMsgSender() runs
// ```

// ---

// ## Now why your assert lines construct the way they do

// ```solidity
// function testMinimumUsdIsFive() public view {
//     assertEq(fundMe.MINIMUM_USD(), 5e18);
// //           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
// //           fundMe exists because setUp() already ran and filled that box
// }
// ```

// If `fundMe` was never filled in `setUp()`, calling `fundMe.MINIMUM_USD()` would crash — you'd be calling a function on an empty box.

// **`setUp()` fills the box. Your tests use the box.** That's the entire relationship.

// ---

// ## Full picture

// ```
// state variable → empty box declared, visible to all tests
//      ↓
// setUp()        → fills the box with a real deployed FundMe
//      ↓
// test functions → use fundMe.anything() confidently knowing it exists
// ```
