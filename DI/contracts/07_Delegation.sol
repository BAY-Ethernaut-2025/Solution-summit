// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        owner = msg.sender;
    }
}

contract Delegation {
    address public owner;
    Delegate delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result,) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}

// 호출자 (Delegation) 의 데이터를 이용
// 호출되는 대상 (Delegate) 의 데이터는 변경 없음,

// Delegation -> delegate call -> Delegate

// delegateCall 할 때
// msg.sender == 트랜잭션을 실행한 EOA
// msg.value == 트랜잭션을 실행할 때 전송한 금액
// msg.data == 호출하려는 함수와 인자값의 바이트 문자열

// ==========================================

// 번외) 만약 Delegate 에 또다른 slot 1 이 있다면?
// 같은 순서에 있는 slot 끼리 덮어씌워짐
// 결론: 호출자와 호출 대상의 스토리지 레이아웃(순서와 타입)이 정확히 맞아야 함
// contract Delegate {
//     address public owner;    // slot 0
//     uint256 public num;      // slot 1

//     function pwn() public {
//         owner = msg.sender;  // storage slot 0에 기록 (caller의 slot 0)
//         num = 2;             // storage slot 1에 기록 (caller의 slot 1)
//     }
// }

// contract Delegation {
//     address public owner;    // slot 0
//     Delegate public delegate; // slot 1
//     // ...
//     fallback() external {
//         address(delegate).delegatecall(msg.data);
//     }
// }