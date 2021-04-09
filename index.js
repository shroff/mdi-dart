const fs = require("fs");
const path = require("path");
const util = require("@mdi/util");

const meta = util.getMeta();

process.stdout.write("Generating Dart Code... ");
processTemplate('lib/mdi.dart', {
  'VERSION': util.getVersion(),
});

processTemplate('lib/icon_map.dart', {
  'ICON_MAP': meta.map((icon) => {
    return `  '${icon.name}': 0x${icon.codepoint},`;
  }).join('\n'),
});
console.log("OK")

process.stdout.write("Updating Font... ")
fs.copyFileSync('node_modules/@mdi/font/fonts/materialdesignicons-webfont.ttf', 'mdi/fonts/materialdesignicons-webfont.ttf');
console.log("OK")

process.stdout.write("Generating Search Terms... ");
processTemplate('assets/search_terms.json', {
  'SEARCH_TERMS': meta.map((icon) => {
    const terms = new Set();
    icon.aliases.unshift(icon.name);
    icon.aliases.forEach(alias => {
      alias.split(/\W/).forEach(term => {
        terms.add(`"${term}"`);
      });
    })
    return `"${icon.name}": [${Array.from(terms)}]`;
  }).join(',\n'),
});
console.log("OK")

function processTemplate(filePath, params) {
  const template = util.read('templates/' + filePath + '.template');
  const output = template.split('\n').map((line) => {
    return line.replace(/<%\w+%>/g, (param) => {
      const name = param.replace(/\W/g, '');
      return params[name];
    });
  }).join('\n');
  
  const outputPath = 'mdi/' + filePath;
  const dirname = path.dirname(outputPath)
  if (!fs.existsSync(dirname)) {
    fs.mkdirSync(dirname);
  }

  util.write(outputPath, output);
}

function processName(name) {
  name = name.replace(/(\-\w)/g, (matches) => {
    return matches[1].toUpperCase();
  });
  name = `${name[0].toLowerCase()}${name.slice(1)}`;

  if (["null", "switch", "sync", "factory"].includes(name)) {
    name = `${name}Icon`;
  }
  return name;
}
