// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IWormhole.sol";
import "./libraries/BytesLib.sol";
import "./WormholeHelpers.sol";
import "./interfaces/IWormholeTunnel.sol";

contract WormholeTunnelUpgradeable is
  IWormholeTunnel,
  WormholeHelpers,
  PausableUpgradeable,
  OwnableUpgradeable,
  UUPSUpgradeable,
  ERC165Upgradeable
{
  using BytesLib for bytes;

  // solhint-disable-next-line func-name-mixedcase
  function __WormholeTunnel_init() internal virtual initializer {
    __Ownable_init();
    __Pausable_init();
    __UUPSUpgradeable_init();
  }

  function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IWormholeTunnel).interfaceId || super.supportsInterface(interfaceId);
  }

  function wormholeInit(uint16 chainId, address wormhole) public override onlyOwner {
    _setChainId(chainId);
    _setWormhole(wormhole);
  }

  function wormholeRegisterContract(uint16 chainId_, bytes32 contractExtendedAddress) public override onlyOwner {
    _setContract(chainId_, contractExtendedAddress);
  }

  function wormholeGetContract(uint16 chainId) public view override returns (bytes32) {
    return contractByChainId(chainId);
  }

  function _wormholeCompleteTransfer(bytes memory encodedVm) internal returns (address to, uint256 payload) {
    (IWormhole.VM memory vm, bool valid, string memory reason) = wormhole().parseAndVerifyVM(encodedVm);

    require(valid, reason);
    require(_verifyContractVM(vm), "invalid emitter");

    Transfer memory transfer = _parseTransfer(vm.payload);

    require(!isTransferCompleted(vm.hash), "transfer already completed");
    _setTransferCompleted(vm.hash);

    require(transfer.toChain == chainId(), "invalid target chain");

    // transfer bridged NFT to recipient
    address transferRecipient = address(uint160(uint256(transfer.to)));

    return (transferRecipient, transfer.payload);
  }

  //  function _wormholeTransfer(
  //    uint256 payload,
  //    uint16 recipientChain,
  //    bytes32 recipient,
  //    uint32 nonce
  //  ) internal returns (uint64 sequence) {
  //    // TODO msg.value - Wormhole fees
  //    return _wormholeTransferWithValue(payload, recipientChain, recipient, nonce, msg.value);
  //  }

  function _wormholeTransferWithValue(
    uint256 payload,
    uint16 recipientChain,
    bytes32 recipient,
    uint32 nonce,
    uint256 value
  ) internal returns (uint64 sequence) {
    require(contractByChainId(recipientChain) != 0, "ERC721: recipientChain not allowed");
    sequence = _logTransfer(Transfer({payload: payload, to: recipient, toChain: recipientChain}), value, nonce);
    return sequence;
  }

  function _logTransfer(
    Transfer memory transfer,
    uint256 callValue,
    uint32 nonce
  ) internal returns (uint64 sequence) {
    bytes memory encoded = _encodeTransfer(transfer);
    sequence = wormhole().publishMessage{value: callValue}(nonce, encoded, 15);
  }

  function _verifyContractVM(IWormhole.VM memory vm) internal view returns (bool) {
    if (contractByChainId(vm.emitterChainId) == vm.emitterAddress) {
      return true;
    }
    return false;
  }

  function _encodeTransfer(Transfer memory transfer) internal pure returns (bytes memory encoded) {
    encoded = abi.encodePacked(uint8(1), transfer.payload, transfer.to, transfer.toChain);
  }

  function _parseTransfer(bytes memory encoded) internal pure returns (Transfer memory transfer) {
    uint256 index = 0;

    uint8 payloadId = encoded.toUint8(index);
    index += 1;

    require(payloadId == 1, "invalid Transfer");

    transfer.payload = encoded.toUint256(index);
    index += 32;

    transfer.to = encoded.toBytes32(index);
    index += 32;

    transfer.toChain = encoded.toUint16(index);
    index += 2;

    require(encoded.length == index, "invalid Transfer");
    return transfer;
  }

  function wormholeTransfer(
    uint256 tokenID,
    uint16 recipientChain,
    bytes32 recipient,
    uint32 nonce
  ) public payable override returns (uint64 sequence) {
    // TODO Override and do something here before complete
//    require(_isApprovedOrOwner(_msgSender(), tokenID), "ERC721: transfer caller is not owner nor approved");
//    _burn(tokenID);
    return _wormholeTransferWithValue(tokenID, recipientChain, recipient, nonce, msg.value);
  }

  // Complete a transfer from Wormhole
  function wormholeCompleteTransfer(bytes memory encodedVm) public override {
    (address to, uint256 payload) = _wormholeCompleteTransfer(encodedVm);
    // TODO Override and do something here
//    _safeMint(to, payload);
  }

  // convenience helper

  //  function getIWormholeTunnelInterfaceId() external pure returns(bytes4) {
  //    return type(IWormholeTunnel).interfaceId;
  //  }
}
