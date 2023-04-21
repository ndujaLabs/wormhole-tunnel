// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./interfaces/IWormhole.sol";
import "./libraries/BytesLib.sol";
import "./WormholeCommon.sol";
import "./interfaces/IWormholeTunnel.sol";

import "hardhat/console.sol";

abstract contract WormholeTunnel is IWormholeTunnel, WormholeCommon, ERC165 {
  using BytesLib for bytes;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    //    console.log(bytes32(type(IWormholeTunnel).interfaceId));
    return interfaceId == type(IWormholeTunnel).interfaceId || super.supportsInterface(interfaceId);
  }

  function getInterfaceId() public view virtual returns (bytes4) {
    return type(IWormholeTunnel).interfaceId;
  }

  function _wormholeInit(uint16 chainId, address wormhole) internal {
    _setChainId(chainId);
    _setWormhole(wormhole);
  }

  function _wormholeRegisterContract(uint16 chainId_, bytes32 contractExtendedAddress) internal {
    _setContract(chainId_, contractExtendedAddress);
  }

  function wormholeGetContract(uint16 chainId) public view override returns (bytes32) {
    return contractByChainId(chainId);
  }

  /** @dev Example of implementation for an ERC721, using Ownable to
           handle ownership and Pausable to handle pausing. The
           following four functions MUST be implemented.

  function wormholeInit(uint16 chainId, address wormhole) external override onlyOwner {
    _wormholeInit(chainId, wormhole);
  }

  function wormholeRegisterContract(uint16 chainId_, bytes32 contractExtendedAddress) public override onlyOwner {
    _wormholeRegisterContract(chainId_, contractExtendedAddress);
  }

  function wormholeTransfer(
    uint256 payload,
    uint16 recipientChain,
    bytes32 recipient,
    uint32 nonce
  ) public payable virtual override whenNotPaused returns (uint64 sequence) {
    require(owner(payload) == _msgSender(), "ERC721: transfer caller is not the owner");
    _burn(payload);
    return _wormholeTransferWithValue(payload, recipientChain, recipient, nonce, msg.value);
  }

  // Complete a transfer from Wormhole
  function wormholeCompleteTransfer(bytes memory encodedVm) public virtual override {
    (address to, uint256 payload) = _wormholeCompleteTransfer(encodedVm);
    _safeMint(to, payload);
  }

  */
}
