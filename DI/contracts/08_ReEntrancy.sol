// // SPDX-License-Identifier: MIT
// pragma solidity ^0.6.12;

// import "openzeppelin-contracts-06/math/SafeMath.sol";

// contract Reentrance {
//     using SafeMath for uint256;

//     mapping(address => uint256) public balances;

//     function donate(address _to) public payable {
//         balances[_to] = balances[_to].add(msg.value);
//     }

//     function balanceOf(address _who) public view returns (uint256 balance) {
//         return balances[_who];
//     }

//     function withdraw(uint256 _amount) public {
//         if (balances[msg.sender] >= _amount) { // 3. attack 의 balance 수량 조건 체크
//             (bool result,) = msg.sender.call{value: _amount}(""); // 4. attack 으로 전송
//             if (result) {
//                 _amount;
//             }
//             balances[msg.sender] -= _amount;
//         }
//     }

//     receive() external payable {}
// }