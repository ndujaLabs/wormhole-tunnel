// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IWormhole.sol";
import "./libraries/BytesLib.sol";
import "./WormholeCommon.sol";
import "./interfaces/IWormholeTunnel.sol";

contract WormholeTunnelUpgradeable is
  IWormholeTunnel,
  WormholeCommon,
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

  function wormholeTransfer(
    uint256 tokenID,
    uint16 recipientChain,
    bytes32 recipient,
    uint32 nonce
  ) public payable override whenNotPaused returns (uint64 sequence) {
    // do something here, before launching the transfer
    // For example, for an ERC721, where payload is the tokenId, you can burn the token on the starting chain:
    //    require(owner(payload) == _msgSender(), "ERC721: transfer caller is not the owner");
    //    _burn(payload);
    return _wormholeTransferWithValue(tokenID, recipientChain, recipient, nonce, msg.value);
  }

  // Complete a transfer from Wormhole
  function wormholeCompleteTransfer(bytes memory encodedVm) public override {
    // solhint-disable-next-line
    (address to, uint256 payload) = _wormholeCompleteTransfer(encodedVm);
    // TODO Override and do something here
    // do something here, after receiving the transfer
    // For example, with an ERC721, where payload is the tokenId,
    // you mint a token on the receiving chain
    //    _safeMint(to, payload);
  }
}
