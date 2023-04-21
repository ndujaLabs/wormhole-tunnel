# Wormhole Tunnel
An implementation of Wormhole native protocol for generic messages

## Usage

Install with
```
npm install @ndujalabs/wormhole-tunnel
```

Most likely, you also have to explicit install the peer dependencies, like:
``` 
npm install @openzeppelin/contracts
```
or 
``` 
npm install @openzeppelin/contracts-upgradeable
```

## History

**0.4.1**
- remove compilation warning in a mock contract.

**0.4.0**
- make the contracts abstract to force the implementation of the two required functions.

## API

## Usage

An example of implementation of this protocol in an ERC721:

```solidity
// SPDX-License-Identifier: Apache2
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../WormholeTunnel.sol";

contract BridgeableERC721 is ERC721, WormholeTunnel, Ownable, Pausable {
  uint256 public nextTokenId = 1;
  bool public isOnPrimaryChain;

  constructor(bool isOnPrimaryChain_) ERC721("Cross-chain NFT", "xNFT") {
    // this must be launched only for the token on the primary chain
    isOnPrimaryChain = isOnPrimaryChain_;
  }

  function wormholeInit(uint16 chainId, address wormhole) external override onlyOwner {
    _wormholeInit(chainId, wormhole);
  }
  
  function supportsInterface(bytes4 interfaceId) public view override(WormholeTunnel, ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function mintNft(address to) external onlyOwner {
    require(isOnPrimaryChain, "Can mint only on primary chain");
    _safeMint(to, nextTokenId++);
  }

  function wormholeTransfer(
    uint256 payload,
    uint16 recipientChain,
    bytes32 recipient,
    uint32 nonce
  ) public payable virtual override whenNotPaused returns (uint64 sequence) {
    require(ownerOf(payload) == _msgSender(), "ERC721: transfer caller is not the owner");
    _burn(payload);
    return _wormholeTransferWithValue(payload, recipientChain, recipient, nonce, msg.value);
  }

  // Complete a transfer from Wormhole. 
  // Notice that everyone who knows the encodedVm can call this function
  function wormholeCompleteTransfer(bytes memory encodedVm) public virtual override {
    // solhint-disable-next-line
    // here we mock
    (address to, uint256 payload) = _wormholeCompleteTransfer(encodedVm);
    _safeMint(to, payload);
  }

  function getFakeEvm(address to, uint256 payload) public view returns (bytes memory) {
    return abi.encode(to, payload);
  }

  function wormholeRegisterContract(uint16 chainId_, bytes32 contractExtendedAddress) public override onlyOwner {
    _wormholeRegisterContract(chainId_, contractExtendedAddress);
  }
}

```

## History

**1.0.0**
- Breaking change with previous version because it does not extend Ownable and Pausable, but expect that whoever implement is, fix issues with ownership and pausability 

## License

Apache2

## Authors

* Evan Gray <egray@jumptrading.com>
* Emanuele Cesena <ec@ndujalabs.com>
* Francesco Sullo <francesco@superpower.io>

Package managed by Francesco Sullo

## Copyright

Wormhole Tunnel comes from a collaboration between 
* [Wormhole Network](https://wormholenetwork.com/)
* [Nduja Labs](https://ndujalabs.com)
* [Superpower Labs](https://superpower.io) 
