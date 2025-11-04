// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] - _value >= 0);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

/* 
취약점
uint256인 balances가 언더플로우를 일으키면 require문도 통과되고, balances[msg.sender]가 엄청나게 커진다.

풀이
1. transfer()함수를 호출한다. 주소는 내 주소를 제외하고 아무거나 넣고, value는 21을 넣어주면 balances가 가장 큰 값이 된다.
끝
*/