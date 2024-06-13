const fs = require('fs/promises');

module.exports = async function main(fileNameWithExt) {
  const file = await fs.readFile(fileNameWithExt, 'utf8');
  return file;
};
