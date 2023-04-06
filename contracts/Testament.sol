//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Testement {
    address owner;
    address[] allowedWithdrawals;
    mapping(address => uint256) withdrawalPercentages;
    uint256 inactivityPeriod;
    uint256 lastActiveTime;

    constructor(uint256 _inactivityPeriod) {
        owner = msg.sender;
        inactivityPeriod = _inactivityPeriod;
        lastActiveTime = block.timestamp;
    }

    function findAddressIndex(address[] memory arr, address val) private pure returns (int256) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == val) {
                return int256(i);
            }
        }
        return int256(-1);
    }

    function removeAddressByValue(address[] storage arr, address val) private returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == val) {
                arr[i] = arr[arr.length - 1];
                arr.pop();
                return true;
            }
        }
        return false;
    }

    function allowWithdrawal(address withdrawer, uint256 percentage) public {
        require(msg.sender == owner, "Only contract owner can allow withdrawal.");
        require(withdrawer != owner, "Contract owner cannot be added.");
        require(percentage <= 100, "Percentage must be less than or equal to 100.");

        withdrawalPercentages[withdrawer] = percentage;
        if (findAddressIndex(allowedWithdrawals, withdrawer) == -1) {
            allowedWithdrawals.push(withdrawer);
        }
    }

    function disallowWithdrawal(address withdrawer) public {
        require(msg.sender == owner, "Only contract owner can disallow withdrawal.");
        withdrawalPercentages[withdrawer] = 0;
        removeAddressByValue(allowedWithdrawals, withdrawer);
    }

    function withdraw() public {
        require(msg.sender == owner || withdrawalPercentages[msg.sender] > 0, "Not authorized to withdraw.");
        require(msg.sender == owner || block.timestamp - lastActiveTime >= inactivityPeriod, "Owner has been active recently.");
        uint256 amount = msg.sender == owner ? address(this).balance : (address(this).balance * withdrawalPercentages[msg.sender]) / 100;
        require(amount > 0, "Withdrawal amount is zero.");
        withdrawalPercentages[msg.sender] = 0;
        removeAddressByValue(allowedWithdrawals, msg.sender);
        payable(msg.sender).transfer(amount);
    }

    function ping() public {
        require(msg.sender == owner, "Only contract owner can ping.");
        lastActiveTime = block.timestamp;
    }

    function setInactivityPeriod(uint256 _inactivityPeriod) public {
        require(msg.sender == owner, "Only contract owner can set inactivity period.");
        inactivityPeriod = _inactivityPeriod;
    }

    function getInactivityPeriod() public view returns (uint256) {
        require(msg.sender == owner, "Only contract owner can view inactivity period.");
        return inactivityPeriod;
    }

    function getLastActiveTime() public view returns (uint256) {
        require(msg.sender == owner, "Only contract owner can view last active time.");
        return lastActiveTime;
    }

    function getBalance() public view returns (uint256) {
        require(msg.sender == owner, "Only contract owner can view balance.");
        return address(this).balance;
    }

    function viewAllowedWithdrawals() public view returns (address[] memory, uint256[] memory) {
        require(msg.sender == owner, "Only contract owner can view allowed withdrawers.");
        uint256[] memory percentages = new uint256[](allowedWithdrawals.length);
        for (uint256 i = 0; i < allowedWithdrawals.length; i++) {
            percentages[i] = withdrawalPercentages[allowedWithdrawals[i]];
        }
        return (allowedWithdrawals, percentages);
    }

    receive() external payable {}
}