const Marketplace = artifacts.require("Marketplace");

async function main() {
  const market = await Marketplace.new();
  Marketplace.setAsDeployed(market);

  console.log("Marketplace deployed to:", market.address);

  const greeting = await market.open();
  console.log(greeting);
}

main().then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
