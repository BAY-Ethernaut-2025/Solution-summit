// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts-08/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts-08/security/ReentrancyGuard.sol";

contract BetHouse {
    address public pool;
    uint256 private constant BET_PRICE = 20;
    mapping(address => bool) private bettors;

    error InsufficientFunds();
    error FundsNotLocked();

    constructor(address pool_) {
        pool = pool_;
    }

    function makeBet(address bettor_) external {
        if (Pool(pool).balanceOf(msg.sender) < BET_PRICE) {
            revert InsufficientFunds();
        }
        if (!Pool(pool).depositsLocked(msg.sender)) revert FundsNotLocked();
        bettors[bettor_] = true;
    }

    function isBettor(address bettor_) external view returns (bool) {
        return bettors[bettor_];
    }
}

contract Pool is ReentrancyGuard {
    address public wrappedToken;
    address public depositToken;

    mapping(address => uint256) private depositedEther;
    mapping(address => uint256) private depositedPDT;
    mapping(address => bool) private depositsLockedMap;
    bool private alreadyDeposited;

    error DepositsAreLocked();
    error InvalidDeposit();
    error AlreadyDeposited();
    error InsufficientAllowance();

    constructor(address wrappedToken_, address depositToken_) {
        wrappedToken = wrappedToken_;
        depositToken = depositToken_;
    }

    /**
     * @dev Provide 10 wrapped tokens for 0.001 ether deposited and
     *      1 wrapped token for 1 pool deposit token (PDT) deposited.
     *  The ether can only be deposited once per account.
     */
    function deposit(uint256 value_) external payable {
        // check if deposits are locked
        if (depositsLockedMap[msg.sender]) revert DepositsAreLocked();

        uint256 _valueToMint;
        // check to deposit ether
        if (msg.value == 0.001 ether) {
            if (alreadyDeposited) revert AlreadyDeposited();
            depositedEther[msg.sender] += msg.value;
            alreadyDeposited = true;
            _valueToMint += 10;
        }
        // check to deposit PDT
        if (value_ > 0) {
            if (PoolToken(depositToken).allowance(msg.sender, address(this)) < value_) revert InsufficientAllowance();
            depositedPDT[msg.sender] += value_;
            PoolToken(depositToken).transferFrom(msg.sender, address(this), value_);
            _valueToMint += value_;
        }
        if (_valueToMint == 0) revert InvalidDeposit();
        PoolToken(wrappedToken).mint(msg.sender, _valueToMint);
    }

    function withdrawAll() external nonReentrant {
        // send the PDT to the user
        uint256 _depositedValue = depositedPDT[msg.sender];
        if (_depositedValue > 0) {
            depositedPDT[msg.sender] = 0;
            PoolToken(depositToken).transfer(msg.sender, _depositedValue);
        }

        // send the ether to the user
        _depositedValue = depositedEther[msg.sender];
        if (_depositedValue > 0) {
            depositedEther[msg.sender] = 0;
            payable(msg.sender).call{value: _depositedValue}("");
        }

        PoolToken(wrappedToken).burn(msg.sender, balanceOf(msg.sender));
    }

    function lockDeposits() external {
        depositsLockedMap[msg.sender] = true;
    }

    function depositsLocked(address account_) external view returns (bool) {
        return depositsLockedMap[account_];
    }

    function balanceOf(address account_) public view returns (uint256) {
        return PoolToken(wrappedToken).balanceOf(account_);
    }
}

contract PoolToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }
}

/* 풀이
우리의 최종 목표: 나의 주소를 인자로 isBettor 함수를 호출해서 true를 반환받는 것.
이를 만족하기 위해서는 `makeBet` 함수의 호출자(msg.sender)가 wrappedToken을 20만큼 들고 있어야 하며, 풀 컨트랙트에 예치된 사용자의 자금에 락이 걸려있어야 함을 의미한다.

문제는 이더 0.001은 단 한번밖에 예치할 수 없고 이걸로 10개의 wrappedToken을 얻을 수 있지만, 처음 받은 5개의 PDT를 통한 wrappdeToken을 합쳐도 15개가밖에 되지 않는다.

**해결 방법**
makeBet 함수의 구조를 살펴보면 

Pool(pool).balanceOf(msg.sender)
Pool(pool).depositsLocked(msg.sender)

bettor로 기록되는 주소는 bettor_ 인자

즉, 토큰 20개 + lock 조건을 만족하는 주소랑 bettor로 표시되는 주소가 완전히 분리되어 있음.

핵심:
조건을 만족하는 주소 = 내가 만든 공격 컨트랙트 주소 (Attacker)
bettor로 찍힐 주소 = 내 EOA(플레이어) 주소

=> 공격 컨트랙트가 Pool에 예치를 해서 토큰을 최대한 모으고(ETH+PDT) 자기 예치를 lock시키고 
그 상태에서 BetHouse에 makeBet(내EOA주소)를 호출 → bettors[내EOA] = true

이 때 Pool 토큰은 기본 단위가 10*18로 설정되기에 20을 초과함  << ?
*/