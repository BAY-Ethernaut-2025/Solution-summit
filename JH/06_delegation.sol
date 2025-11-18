// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Delegate {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public {
        owner = msg.sender; // 이거 호출하면 owner가 바뀜
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
        (bool result,) = address(delegate).delegatecall(msg.data); // delegatecall에서 pwn()을 호출해야한다
        if (result) {
            this;
        }
    }
}

/*
풀이
fallback에서 delegatecall을 통해 Delegate의 pwn()함수를 호출해야 한다
remix의 compile details에서 pwn()함수의 4byte signature를 확인한다. (0xdd365b8b)
calldata에 0xdd365b8b를 넣어 Delegation 컨트랙트에 전송한다.
contract.owner()를 호출해보면 owner가 내 주소로 변경된 것을 확인할 수 있다.
끝
*/