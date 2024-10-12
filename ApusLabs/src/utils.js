require('colors');

function displayHeader() {
  process.stdout.write('\x1Bc');
  console.log('========================================'.cyan);
  console.log('=      Apus Labs Airdrop Bot – V2      ='.cyan);
  console.log('=     Created by HappyCuanAirdrop      ='.cyan);
  console.log('=    https://t.me/HappyCuanAirdrop     ='.cyan);
  console.log('========================================'.cyan);
  console.log();
}

function replacePlaceholders(template, replacements) {
  return template.replace(/{(\w+)}/g, (_, key) => replacements[key]);
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function randomDateIn2024() {
  const start = new Date(2024, 0, 1);
  const end = new Date();
  const randomTime =
    start.getTime() + Math.random() * (end.getTime() - start.getTime());
  return new Date(randomTime);
}

module.exports = {
  displayHeader,
  replacePlaceholders,
  delay,
  randomDateIn2024,
};
