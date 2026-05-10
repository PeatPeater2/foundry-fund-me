// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
// FundMe/Foundry-FundMe-26/script/DeployFundMe.s.sol
// FundMe/Foundry-FundMe-26/script/HelperConfig.s.sol
// FundMe/Foundry-FundMe-26/test/Mocks/MocksV3Aggregator.sol
// FundMe/Foundry-FundMe-26/test/FundmeTest.t.sol
// FundMe/Foundry-FundMe-26/src/FundMe.sol
// FundMe/Foundry-FundMe-26/script/DeployFundMe.s.sol
