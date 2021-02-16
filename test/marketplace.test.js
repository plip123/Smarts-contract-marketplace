const Marketplace = artifacts.require("Marketplace");


// Traditional Truffle test
contract("Marketplace", async ([admin, alice, bob, random]) => {
  let market;

  before(async () => {
    market = await Marketplace.new();
  });
  
  it("Should open the market", async () => {
    assert.equal(await market.open(), "Marketplace is open");
  });

  it("Should increase amount", async () => {
    await market.assignCredit(alice, 1000, {from: admin});
    assert.equal(await market.getBalance({from: alice}),1000);
  })

  it("Should post an item", async () => {
    await market.publishItem("carro", 1500, {from: alice});
    assert.equal(await market.getItemOwner721(0),alice);
  })

  it("Should not buy an item", async () => {
    await market.assignCredit(alice, 2000, {from: admin});
    await market.assignCredit(bob, 1000, {from: admin});
    await market.publishItem("carro", 1500, {from: alice});
    market.buyItem(0, {from: bob}).catch(async ()=>{
      assert.equal(await market.getItemOwner721(0), alice);
    });
  })

  it("Should buy an item", async () => {
    await market.assignCredit(alice, 2000, {from: admin});
    await market.assignCredit(bob, 2000, {from: admin});
    await market.publishItem("carro", 1500, {from: alice});
    await market.buyItem(0, {from: bob});
    assert.equal(await market.getItemOwner721(0), bob);
  })

});