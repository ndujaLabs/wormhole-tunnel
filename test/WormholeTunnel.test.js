const {expect, assert} = require("chai");

const {addr0, assertThrowsMessage, getTimestamp, increaseBlockTimestampBy, bytes32Address} = require("./helpers");

// tests to be fixed

function normalize(val, n = 18) {
  return "" + val + "0".repeat(n);
}

// test unit coming soon

describe("#WormholeTunner", function () {
  let WormholeMock, wormhole;
  let BridgeableERC721Mock, bridgeableOnChain1, bridgeableOnChain2;

  let deployer, user1, user2, user3;

  before(async function () {
    [deployer, user1, user2, user3] = await ethers.getSigners();
    BridgeableERC721Mock = await ethers.getContractFactory("BridgeableERC721Mock");
    WormholeMock = await ethers.getContractFactory("WormholeMock");
  });

  async function initAndDeploy() {
    wormhole = await WormholeMock.deploy();
    await wormhole.deployed();

    bridgeableOnChain1 = await BridgeableERC721Mock.deploy(true);
    await bridgeableOnChain1.deployed();

    // we do it on the same chain, but this is supposed
    // to be deployed on a different chain
    bridgeableOnChain2 = await BridgeableERC721Mock.deploy(false);
    await bridgeableOnChain2.deployed();

    await bridgeableOnChain1.wormholeInit(2, wormhole.address);
    await bridgeableOnChain1.wormholeRegisterContract(4, bytes32Address(bridgeableOnChain2.address));

    await bridgeableOnChain2.wormholeInit(4, wormhole.address);
    await bridgeableOnChain2.wormholeRegisterContract(2, bytes32Address(bridgeableOnChain1.address));
  }

  describe("integration test", async function () {
    beforeEach(async function () {
      await initAndDeploy();
    });

    it("should manage the entire flow", async function () {
      const tokenId = ethers.BigNumber.from("1");
      await bridgeableOnChain1.mintNft(user1.address);
      expect(await bridgeableOnChain1.ownerOf(1)).equal(user1.address);
      await bridgeableOnChain1.connect(user1).wormholeTransfer(tokenId, 4, bytes32Address(user1.address), 1);
      await assertThrowsMessage(bridgeableOnChain1.ownerOf(1), "ERC721: invalid token ID");

      const fakeEvm = await bridgeableOnChain1.getFakeEvm(user1.address, tokenId);

      await bridgeableOnChain2.wormholeCompleteTransfer(fakeEvm);
      expect(await bridgeableOnChain2.ownerOf(1)).equal(user1.address);
    });
  });
});
