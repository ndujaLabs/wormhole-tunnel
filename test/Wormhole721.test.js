const {expect, assert} = require("chai")
const {deployContract} = require('./helpers')

describe("Wormhole721", function () {

  let wormhole721
  let erc721NotPlayableMock
  let playerMock

  let owner, holder

  before(async function () {
    [owner, holder] = await ethers.getSigners()
  })

  beforeEach(async function () {
    wormhole721 = await deployContract('Wormhole721')
  })

  it("should mint token and verify that the player is not initiated", async function () {

  })


})
