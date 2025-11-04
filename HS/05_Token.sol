// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {
    mapping(address => uint256) balances;
    uint256 public totalSupply;

    constructor(uint256 _initialSupply) public {
        balances[msg.sender] = totalSupply = _initialSupply; //생성자 - totalSupply를 설정
    }

    function transfer(address _to, uint256 _value) public returns (bool) { 
        require(balances[msg.sender] - _value >= 0); //sender(나)의 밸런스가 충분해야됨 -- 그러나 여기서 언더플로우 가능
        balances[msg.sender] -= _value; //뺴고 -- 여기서도 언더플로우
        balances[_to] += _value; //보냄 -- 여기서는 오버플로우 발생하지 않음 왜? 2^256을 안넘기 때문
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

//풀이과정
// await contract.transfer("0x446e5FA20E5250fCc8cD262317afe27cA606C0A1",21);