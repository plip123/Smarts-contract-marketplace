const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { assertion } = require('@openzeppelin/test-helpers/src/expectRevert');
const Marketplace = artifacts.require("Marketplace");
const MyTestToken20 = artifacts.require("MyToken20");
const MyTestToken721 = artifacts.require("MyToken721");

// Traditional Truffle test
contract("Marketplace", async([admin, alice, bob, random]) => {
    let market;
    let token20;
    let token721;

    before(async() => {
        token20 = await MyTestToken20.new();
        token721 = await MyTestToken721.new();
        market = await Marketplace.new(token20.address, token721.address);
    });

    it("Should increase amount", async() => {
        await token20.mint(alice, web3.utils.toWei(String(10)), { from: admin });
        assert.equal(await token20.balanceOf(alice), web3.utils.toWei(String(10)));
    });

    it("Should not increase amount if not owner", async() => {
        await expectRevert(
            token20.mint(alice, web3.utils.toWei(String(10)), { from: alice }),
            'ERC20PresetMinterPauser: must have minter role to mint'
        );
    });

    it("Should create an item", async() => {
        await token721.createItem(alice, 1);
        assert.equal(await token721.ownerOf(1), alice);
    });

    it("Should fail to create the same item", async() => {
        await expectRevert(
            token721.createItem(bob, 1),
            "Item already exists"
        );
    });

    it("Should post an item", async() => {
        await token721.approve(market.address, 1, { from: alice });
        await market.sellItems(1, web3.utils.toWei(String(5)), { from: alice });
        const item = await market.items(1, { from: alice });
        assert.equal(item.vendor, alice);
    });

    it("You should publish an item with a positive price greater than 0", async() => {
        await token721.createItem(alice, 2);
        await token721.approve(market.address, 2, { from: alice });
        await expectRevert(
            market.sellItems(2, web3.utils.toWei(String(0)), { from: alice }),
            "Price must be greater than 0."
        );
    });

    it("Should not post an item without approval", async() => {
        await token721.createItem(alice, 3);
        await expectRevert(
            market.sellItems(3, web3.utils.toWei(String(5)), { from: alice }),
            "This item has not yet been approved."
        );
    });

    it("Should not post an other persons item", async() => {
        await token721.createItem(alice, 4);
        await expectRevert(
            market.sellItems(4, web3.utils.toWei(String(5)), { from: bob }),
            "You are not the owner of this item."
        );
    });

    it("Should not buy an item with not enough balance", async() => {
        await token20.mint(bob, web3.utils.toWei(String(1)), { from: admin });
        await expectRevert(
            market.buyItem(1, { from: bob }),
            "revert ERC20: transfer amount exceeds balance"
        );
    });

    it("Should not buy an item without approval", async() => {
        await expectRevert(
            market.buyItem(3, { from: bob }),
            "This item has not yet been approved."
        );
    });

    it("Should buy an item", async() => {
        await token20.mint(bob, web3.utils.toWei(String(20)), { from: admin });
        await token20.approve(market.address, web3.utils.toWei(String(20)), { from: bob })
        await market.buyItem(1, { from: bob });
        assert.equal(await token721.ownerOf(1), bob);
    });

    it("Should not buy an item already yours", async() => {
        await token721.approve(market.address, 1, { from: bob });
        await expectRevert(
            market.buyItem(1, { from: bob }),
            "You are the owner of this item."
        );
    });

    it("Should not buy an item already sold to other", async() => {
        await token721.approve(market.address, 1, { from: bob });
        await expectRevert(
            market.buyItem(1, { from: alice }),
            "This item was sold."
        );
    });

});