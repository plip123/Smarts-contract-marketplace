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
  
  it("Should open the market", async () => {
    assert.equal(await market.open(), "Marketplace is open");
  });

  it("Should increase amount", async () => {
    await token20.mint(alice, web3.utils.toWei(String(10)), {from: admin});
    assert.equal(await token20.balanceOf(alice), web3.utils.toWei(String(10)));
  })

  it("Should create an item", async () => {
    await token721.createItem(alice, 10);
    assert.equal(await token721.ownerOf(10),alice);
  })

  it("Should post an item", async () => {
    await token721.approve(market.address, 10,{from: alice}) //no
    await market.sellItem(10, web3.utils.toWei(String(20)),{from: alice});
    let item = await market.allItems(10);
    assert(item.isAvailable);
  })

  it("Should not buy an item", async () => {
    await market.buyItem(10, {from: bob}).catch(async ()=>{
      assert.equal(await token721.ownerOf(10), alice);
    });
  })

  it("Should buy an item", async () => {
    await token20.mint(bob, web3.utils.toWei(String(20)), {from: admin});
    await token20.approve(market.address,web3.utils.toWei(String(20)), {from: bob}); //no
    await market.buyItem(10, {from: bob});
    assert.equal(await token721.ownerOf(10), bob);
  })

});