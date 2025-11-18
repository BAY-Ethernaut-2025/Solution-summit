// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    bool public locked;
    bytes32 private password;

    constructor(bytes32 _password) {
        locked = true;
        password = _password;
    }

    function unlock(bytes32 _password) public {
        if (password == _password) {
            locked = false;
        }
    }
}
/*
취약점
체인상에 password가 저장되어있다.

풀이
await web3.eth.getStorageAt(contract.address,1)를 통해 password를 알아낸다
unlock함수에 알아낸 password를 넣어 호출한다
contract.unlock("0x412076657279207374726f6e67207365637265742070617373776f7264203a29")
끝
*/