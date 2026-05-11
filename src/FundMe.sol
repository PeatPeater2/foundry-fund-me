// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeedAddress) {
        i_owner = msg.sender; // whoever deploys the contract is the OWNER(ME) not the depositor
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // Accepts ETH from a funder, ensures it meets the minimum USD value,
    // records the amount funded against their address, and adds them to the funders list
    function fund() public payable {
        // 1. Reverts if the sent ETH value is less than the minimum USD amount
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        //2. adding amount to the address of person
        s_addressToAmountFunded[msg.sender] += msg.value;
        //3. Adds the funder's address to the funders list
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _; // This _; makes the function(s) tied to this MODIFIER to run. Without it, the fuunctions wont work.
    }

    // 1. Allows only the owner to withdraw all funds, resets all funder balances and clears the funders list
    function withdraw() public onlyOwner {
        //2. Loop through all funders in the funders list
        for (
            uint256 funderIndex = 0; // start from position 0 (first funder)
            funderIndex < s_funders.length;

            // keep going until you reach the last funder
            funderIndex++
        )  // move to the next funder each time
        {
            //3. Get the funder address at the current index
            address funder = s_funders[funderIndex];
            //4. Reset the funder's funded balance back to zero
            s_addressToAmountFunded[funder] = 0;
        }
        //5. Clear the funders list by replacing it with a new empty array
        s_funders = new address[](0);

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    // Returns the total amount funded by a specific address from the mapping
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    // Returns the funder address stored at a given index in the funders array
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
