// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";

import "./libraries/BytesLib.sol";
import "./interfaces/IWormhole.sol";
import "./interfaces/IWormholeTunnel.sol";
import "./WormholeCommon.sol";

abstract contract WormholeTunnelUpgradeable is
  IWormholeTunnel,
  WormholeCommon,
  ERC165Upgradeable
{
  using BytesLib for bytes;

  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    return interfaceId == type(IWormholeTunnel).interfaceId || super.supportsInterface(interfaceId);
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

  uint256[50] private __gap;
}
