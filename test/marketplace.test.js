const {BN, expectEvent, expectRevert} = require('@openzeppelin/test-helpers');
const Marketplace = artifacts.require("Marketplace");
const MyTestToken20 = artifacts.require("MyTestToken20");
const MyTestToken721 = artifacts.require("MyTestToken721");

// Traditional Truffle test
contract("Marketplace", async ([admin, alice, bob, random]) => {
  let market;
  let token20;
  let token721;

  before(async () => {
    token20 = await MyTestToken20.new();
    token721 = await MyTestToken721.new();
    market = await Marketplace.new(token20.address, token721.address);
  });

  it("Should increase amount", async () => {
    await token20.mint(alice, web3.utils.toWei(String(10)), {from: admin});
    assert.equal(await token20.balanceOf(alice), web3.utils.toWei(String(10)));
  })

  it("Should not increase amount if not owner", async () => {
    await expectRevert(
      token20.mint(alice, web3.utils.toWei(String(10)), {from: alice}),
      "ERC20PresetMinterPauser: must have minter role to mint"
    )
  })

  it("Should create an item", async () => {
    await token721.createItem(alice, 10);
    assert.equal(await token721.ownerOf(10),alice);
  })

  it("Should fail to create the same item", async () => {
    await expectRevert(
      token721.createItem(alice, 10),
      "Item already exists"
    )
  })

  it("Should post an item", async () => {
    await token721.approve(market.address, 10,{from: alice});
    const receipt = await market.sellItem(10, web3.utils.toWei(String(20)),{from: alice});
    expectEvent(receipt, 'SellItem', {
      seller: alice,
      id: new BN(10),
      price: web3.utils.toWei(String(20))
    });
  })

  it("Should not post an item without approval", async () => {
    await token721.createItem(alice, 20);
    await expectRevert(
      market.sellItem(20, web3.utils.toWei(String(20)),{from: alice}),
      "Not allowed to sell"
    )
  })

  it("Should not post an other persons item", async () => {
    await token721.createItem(alice, 30);
    await expectRevert(
      market.sellItem(30, web3.utils.toWei(String(20)),{from: bob}),
      "This is not your item"
    )
  })

  it("Should not buy an item with not enough balance", async () => {
    await expectRevert(
      market.buyItem(10, {from: bob}),
      "transfer amount exceeds balance"
    )
  })

  it("Should not buy an item without approval", async () => {
    await token20.mint(bob, web3.utils.toWei(String(20)), {from: admin});

    await expectRevert(
      market.buyItem(10, {from: bob}),
      "transfer amount exceeds allowance"
    )
  })

  it("Should buy an item", async () => {
    await token20.mint(bob, web3.utils.toWei(String(20)), {from: admin});
    await token20.approve(market.address,web3.utils.toWei(String(20)), {from: bob});
    const receipt = await market.buyItem(10, {from: bob});
    expectEvent(receipt, 'BuyItem', {
      buyer: bob,
      seller: alice,
      id: new BN(10),
      price: web3.utils.toWei(String(20))
    });
  })

  it("Should not buy an item already yours", async () => {
    await token20.mint(bob, web3.utils.toWei(String(20)), {from: admin});
    await token20.approve(market.address,web3.utils.toWei(String(20)), {from: bob});
    await expectRevert(
      market.buyItem(10, {from: bob}),
      "This is your own item"
    )
  })

  it("Should not buy an item already sold to other", async () => {
    await token20.mint(random, web3.utils.toWei(String(20)), {from: admin});
    await token20.approve(market.address,web3.utils.toWei(String(20)), {from: random});
    await expectRevert(
      market.buyItem(10, {from: random}),
      "Item already sold"
    )
  })

});