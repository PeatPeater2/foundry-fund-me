//  SPDX-License-Identifier: MIT

// 1. Deploy Mocks when we are on local Anvil chain
// 2. Keep track of contract address accross different chains
// Sepolia ETH/USD
// Ethereum Mainnet ETH/USD
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MocksV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    //
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia price feed address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getEthMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory EthMainnetConfig = NetworkConfig({priceFeed: 0x5147eA642CAEF7BD9c1265AadcA78f997AbB9649});
        return EthMainnetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // Anvil price feed address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // If 'priceFeed' is NOT 0x000, it means we already ran this function and built a Mock!
            // So, just return the one we already have instead of wasting time building a new one.
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
