//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "./base/UniversalChanIbcApp.sol";

interface IERC20Token {
    function mint(address to, uint256 amount) external;
    function burn(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract DstChainTokenBridge is UniversalChanIbcApp {
    constructor(address _middleware) UniversalChanIbcApp(_middleware) {}

    event ReceiveSenderAndAmount(address sender, uint256 amount);
    event ConfirmSenderAndAmount(address sender, uint256 amount);

    /**
     * @dev Sends a packet with the caller's address over the universal channel.
     * @param destPortAddr The address of the destination application.
     * @param channelId The ID of the channel to send the packet to.
     * @param amount The amount that user wants to bridge to the destination chain.
     */
    function bridgeToSrcChain(
        address destPortAddr,
        bytes32 channelId,
        uint256 amount
    ) external {
        IERC20Token token = IERC20Token(
            0x7F9C7F1Dc2D0Ac49C9728Bc4A3Ba4654c2D76a5D
        );
        require(token.balanceOf(msg.sender) >= amount, "balance not enough");

        bytes memory payload = abi.encode(msg.sender, amount);
        uint64 timeoutTimestamp = uint64(
            (block.timestamp + 36000) * 1000000000
        );
        // Burn the token on the source chain
        token.burn(msg.sender, amount);

        IbcUniversalPacketSender(mw).sendUniversalPacket(
            channelId,
            IbcUtils.toBytes32(destPortAddr),
            payload,
            timeoutTimestamp
        );
    }

    /**
     * @dev Packet lifecycle callback that implements packet receipt logic and returns and acknowledgement packet.
     *      MUST be overriden by the inheriting contract.
     *
     * @param channelId the ID of the channel (locally) the packet was received on.
     * @param packet the Universal packet encoded by the source and relayed by the relayer.
     */
    function onRecvUniversalPacket(
        bytes32 channelId,
        UniversalPacket calldata packet
    ) external override onlyIbcMw returns (AckPacket memory ackPacket) {
        recvedPackets.push(UcPacketWithChannel(channelId, packet));

        (address payload, uint256 amount) = abi.decode(
            packet.appData,
            (address, uint256)
        );

        emit ReceiveSenderAndAmount(payload, amount);

        // Mint the token on the source chain
        IERC20Token token = IERC20Token(
            0x7F9C7F1Dc2D0Ac49C9728Bc4A3Ba4654c2D76a5D
        );
        token.mint(payload, amount);

        return AckPacket(true, abi.encode(amount));
    }

    /**
     * @dev Packet lifecycle callback that implements packet acknowledgment logic.
     *      MUST be overriden by the inheriting contract.
     *
     * @param channelId the ID of the channel (locally) the ack was received on.
     * @param packet the Universal packet encoded by the source and relayed by the relayer.
     * @param ack the acknowledgment packet encoded by the destination and relayed by the relayer.
     */
    function onUniversalAcknowledgement(
        bytes32 channelId,
        UniversalPacket memory packet,
        AckPacket calldata ack
    ) external override onlyIbcMw {
        ackPackets.push(UcAckWithChannel(channelId, packet, ack));

        (address payload, uint256 amount) = abi.decode(
            packet.appData,
            (address, uint256)
        );

        emit ConfirmSenderAndAmount(payload, amount);

    }

    /**
     * @dev Packet lifecycle callback that implements packet receipt logic and return and acknowledgement packet.
     *      MUST be overriden by the inheriting contract.
     *      NOT SUPPORTED YET
     *
     * @param channelId the ID of the channel (locally) the timeout was submitted on.
     * @param packet the Universal packet encoded by the counterparty and relayed by the relayer
     */
    function onTimeoutUniversalPacket(
        bytes32 channelId,
        UniversalPacket calldata packet
    ) external override onlyIbcMw {
        timeoutPackets.push(UcPacketWithChannel(channelId, packet));
        // do logic
    }
}
