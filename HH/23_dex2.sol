// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/token/ERC20/IERC20.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import "openzeppelin-contracts-08/access/Ownable.sol";

contract DexTwo is Ownable {
    address public token1;
    address public token2;

    constructor() {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function add_liquidity(address token_address, uint256 amount) public onlyOwner {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(address from, address to, uint256 amount) public {
        require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
        uint256 swapAmount = getSwapAmount(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapAmount(address from, address to, uint256 amount) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableTokenTwo(token1).approve(msg.sender, spender, amount);
        SwappableTokenTwo(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account) public view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableTokenTwo is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

/* 풀이

핵심이 되는 취약부분: dextwo 컨트랙트의 swap 함수에서 입력 파라미터인 from 과 to에 대한 검증이 존재하지 않는다.
from == token1 || from == token2 이런 체크 과정이 빠졌기에(to도 마찬가지) 누구든지 swap(가짜토큰, 진짜토큰, amount) 같은 호출을 할 수 있다. 
이렇게 되면 누구나 가짜토큰을 진짜토큰으로 교환할 수 있다.
스왑 과정에서의 비율 계산은 getSwapAmount 함수에서 이루어진다.

공격 과정:
1. 가짜토큰 컨트랙트를 생성.
2. 가짜토큰을 dex 컨트랙트에 추가. (transfer 함수 사용)
3. approve 함수를 호출해서 가짜토큰을 dex 컨트랙트에 승인.
4. swap 함수를 호출해서 가짜토큰을 진짜토큰으로 교환.
*/
