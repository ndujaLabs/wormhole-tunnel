const {expect, assert} = require("chai")
const {deployContract} = require('./helpers')

describe("WormholeTunnel", function () {

  let WormholeTunnel
  let tunnel

  let owner, holder

  before(async function () {
    [owner, holder] = await ethers.getSigners()
  })

  beforeEach(async function () {
    tunnel = await deployContract('WormholeTunnel')
    await tunnel.deployed()
  })

  it("should return the correct interfaceId", async function () {
    expect (await tunnel.getInterfaceId()).equal("0x647bffff")
  })


})
