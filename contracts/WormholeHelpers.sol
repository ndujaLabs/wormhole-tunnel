// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "./interfaces/IWormhole.sol";

contract WormholeHelpers {
  struct Transfer {
    // PayloadID uint8 = 1
    // TokenID of the token, if an NFT; amount if a transfer, etc.
    uint256 payload;
    // Address of the recipient. Left-zero-padded if shorter than 32 bytes
    bytes32 to;
    // Chain ID of the recipient
    uint16 toChain;
  }

  struct State {
    // Wormhole bridge contract address and chainId
    address payable wormhole;
    uint16 chainId;
    // Mapping of consumed token transfers
    mapping(bytes32 => bool) completedTransfers;
    // Mapping of contracts on other chains
    mapping(uint16 => bytes32) contractsByChainId;
  }

  State _wormholeState;

  function isTransferCompleted(bytes32 hash) public view returns (bool) {
    return _wormholeState.completedTransfers[hash];
  }

  function contractByChainId(uint16 chainId_) public view returns (bytes32) {
    return _wormholeState.contractsByChainId[chainId_];
  }

  function wormhole() public view returns (IWormhole) {
    return IWormhole(_wormholeState.wormhole);
  }

  function chainId() public view returns (uint16) {
    return _wormholeState.chainId;
  }

  function _setWormhole(address wh) internal {
    _wormholeState.wormhole = payable(wh);
  }

  function _setChainId(uint16 chainId_) internal {
    _wormholeState.chainId = chainId_;
  }

  function _setTransferCompleted(bytes32 hash) internal {
    _wormholeState.completedTransfers[hash] = true;
  }

  function _setContract(uint16 chainId_, bytes32 contractExtendedAddress) internal {
    _wormholeState.contractsByChainId[chainId_] = contractExtendedAddress;
  }
}
