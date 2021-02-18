const Marketplace = artifacts.require("Marketplace");
const MyTestToken20 = artifacts.require("MyTestToken20");
const MyTestToken721 = artifacts.require("MyTestToken721");

async function main() {
  const token20 = await MyTestToken20.new();
  MyTestToken20.setAsDeployed(token20);
  const token721 = await MyTestToken721.new();
  MyTestToken721.setAsDeployed(token721);

  const market = await Marketplace.new(token20.address, token721.address);
  Marketplace.setAsDeployed(market);

  console.log("MyTestToken20 deployed to:", token20.address);
  console.log("MyTestToken721 deployed to:", token721.address);
  console.log("Marketplace deployed to:", market.address);
}

main().then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
