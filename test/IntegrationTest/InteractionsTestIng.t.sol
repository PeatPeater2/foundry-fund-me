// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
// This TEST too works
// 👇👇👇
// contract FundMeTestIntegration is Test {
//     FundMe fundMe;

//     uint256 constant STARTING_BALANCE = 100 ether; // what the prank user have

//     function setUp() external {
//         // fundMe = new FundMe();
//         DeployFundMe deployFundMe = new DeployFundMe(); // ONE
//         fundMe = deployFundMe.run();
//     }

//     function testUserCanFundInteractions() public {
//         FundFundMe fundfundMe = new FundFundMe(); //TWO
//         vm.deal(address(fundfundMe), 1 ether);
//         fundfundMe.fundFundMe(address(fundMe));

//         WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

//         withdrawFundMe.withdrawFundMe(address(fundMe));

//         assert(address(fundMe).balance == 0);
//     }
// }
