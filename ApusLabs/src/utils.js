require('colors');

function displayHeader() {
  process.stdout.write('\x1Bc');
  console.log('========================================'.cyan);
  console.log('=      🌟 Apus Labs Airdrop Bot🌟      ='.cyan);
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

module.exports = { displayHeader, replacePlaceholders, delay };
