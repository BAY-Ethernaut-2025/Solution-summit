// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts-08/access/Ownable.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

interface DelegateERC20 {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function setDetectionBot(address detectionBotAddress) external;
    function notify(address user, bytes calldata msgData) external;
    function raiseAlert(address user) external;
}

contract Forta is IForta { //Forta 봇
    mapping(address => IDetectionBot) public usersDetectionBots; //유저별 디텍션봇주소
    mapping(address => uint256) public botRaisedAlerts; //유저별 alert 횟수

    function setDetectionBot(address detectionBotAddress) external override { //
        usersDetectionBots[msg.sender] = IDetectionBot(detectionBotAddress);
    } // 유저가 자신의 디텍션봇 등록

    function notify(address user, bytes calldata msgData) external override {
        if (address(usersDetectionBots[user]) == address(0)) return; //봇 없으면 종료
        try usersDetectionBots[user].handleTransaction(user, msgData) {//handleTransaction 호출
            return; 
        } catch {}
    }

    function raiseAlert(address user) external override { //alert횟수 세기
        if (address(usersDetectionBots[user]) != msg.sender) return;
        botRaisedAlerts[msg.sender] += 1;
    }
}

contract CryptoVault {
    address public sweptTokensRecipient;
    IERC20 public underlying; // 금고가 보호하는 토큰

    constructor(address recipient) {
        sweptTokensRecipient = recipient;
    }

    function setUnderlying(address latestToken) public {
        require(address(underlying) == address(0), "Already set"); // 주소가 0일때 한번만 설정가능
        underlying = IERC20(latestToken);
    }

    /*
    ...
    */

    function sweepToken(IERC20 token) public {
        require(token != underlying, "Can't transfer underlying token");
        token.transfer(sweptTokensRecipient, token.balanceOf(address(this))); // 금고에 있는 토큰을 전부를 수신자에게 전송
    }
}

contract LegacyToken is ERC20("LegacyToken", "LGT"), Ownable {
    DelegateERC20 public delegate; // delegate 컨트랙트 주소

    function mint(address to, uint256 amount) public onlyOwner { //owner만 발행가능
        _mint(to, amount);
    }

    function delegateToNewContract(DelegateERC20 newContract) public onlyOwner {
        delegate = newContract; // 새 컨트랙트
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        if (address(delegate) == address(0)) {
            return super.transfer(to, value); // 기존 transfer실행
        } else {
            return delegate.delegateTransfer(to, value, msg.sender);
        }
    }
}

contract DoubleEntryPoint is ERC20("DoubleEntryPointToken", "DET"), DelegateERC20, Ownable {
    address public cryptoVault;
    address public player;
    address public delegatedFrom;
    Forta public forta;

    constructor(address legacyToken, address vaultAddress, address fortaAddress, address playerAddress) {
        delegatedFrom = legacyToken;
        forta = Forta(fortaAddress);
        player = playerAddress;
        cryptoVault = vaultAddress;
        _mint(cryptoVault, 100 ether);
    }

    modifier onlyDelegateFrom() {
        require(msg.sender == delegatedFrom, "Not legacy contract");
        _;
    }

    modifier fortaNotify() {
        address detectionBot = address(forta.usersDetectionBots(player));

        // Cache old number of bot alerts
        uint256 previousValue = forta.botRaisedAlerts(detectionBot);

        // Notify Forta
        forta.notify(player, msg.data);

        // Continue execution
        _;

        // Check if alarms have been raised
        if (forta.botRaisedAlerts(detectionBot) > previousValue) revert("Alert has been triggered, reverting");
    }

    function delegateTransfer(address to, uint256 value, address origSender)
        public
        override
        onlyDelegateFrom
        fortaNotify
        returns (bool)
    {
        _transfer(origSender, to, value);
        return true;
    }
}

/*
취약점: 
CtrptoVault의 sweepToken함수는 금고에 있는 토큰을 수신자에게 전부 전송한다.
LegacyToken의 transfer함수는 delegate가 설정되어 있으면 delegate의 delegateTransfer함수를 호출한다.
CtrptoVault -> LegacyToken.transfer -> DoubleEntryPoint.delegateTransfer의 방식으로 호출하면 sweepToken함수를 우회하여 금고의 토큰을 탈취할 수 있다.

해결방법:
vault에서 lgt transfer를 감지하는 forta 봇을 만들어서 alert를 발생시키면 된다.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDetectionBot {
    function handleTransaction(address user, bytes calldata msgData) external;
}

interface IForta {
    function raiseAlert(address user) external;
}

interface IDoubleEntryPoint {
    function delegateTransfer(address to, uint256 value, address origSender) external returns (bool);
}


contract VaultDetectionBot is IDetectionBot {
    address public immutable vault;        // CryptoVault 주소
    IForta public immutable forta;         // Forta 컨트랙트

    constructor(address _vault, address _forta) {
        vault = _vault;
        forta = IForta(_forta);
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        // selector(4바이트)를 건너뛰고, 나머지를 (address, uint256, address)로 디코딩
        (, , address origSender) =
            abi.decode(msgData[4:], (address, uint256, address));

        // origSender가 vault이고, user가 legacyToken이면 취약점 공격이므로 revert
        if (origSender == vault) {
            forta.raiseAlert(user);
        }
    }
}

/*
풀이: 
1. VaultDetectionBot 컨트랙트를 배포한다. 생성자에 CryptoVault 주소와 Forta 컨트랙트 주소를 넣어준다.
2. Forta 컨트랙트에서 setDetectionBot함수를 호출하여 방금 배포한 VaultDetectionBot 주소를 등록한다.
이제 CryptoVault에서 LegacyToken의 transfer함수를 호출하여 DoubleEntryPoint의 delegateTransfer함수를 호출하면,
VaultDetectionBot의 handleTransaction함수가 실행되고, alert가 발생하여 공격이 차단된다.
끝
*/