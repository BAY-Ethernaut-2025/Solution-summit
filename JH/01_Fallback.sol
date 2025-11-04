// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}

/* 
취약점
receive() 함수는 contributions과 보낸 이더가 0보다 크면 owner를 변경할수있다

풀이
1. remix에서 컴파일 후 0.001 이더 이하로 contribute() 함수 호출
2. 컨트랙트에 0이 아닌값을 넣어 이더를 전송하면 receive()가 호출되어 owner가 나로 변경
3. withdraw() 함수 호출로 잔액을 0으로 만들기
끝
*/