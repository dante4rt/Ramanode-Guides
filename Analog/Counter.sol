// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGmpReceiver {
    function onGmpReceived(
        bytes32 id,
        uint128 network,
        bytes32 source,
        bytes calldata payload
    ) external payable returns (bytes32);
}

contract Counter is IGmpReceiver {
    address private immutable _gateway;
    uint256 public number;

    // example gw 0x7702eD777B5d6259483baAD0FE8b9083eF937E2A
    constructor(address gateway) {
        _gateway = gateway;
    }

    function onGmpReceived(
        bytes32,
        uint128,
        bytes32,
        bytes calldata
    ) external payable returns (bytes32) {
        require(msg.sender == _gateway, "unauthorized");
        number++;
        return bytes32(number);
    }
}
