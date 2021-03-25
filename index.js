const fs = require("fs");
const util = require("@mdi/util");

const meta = util.getMeta();

process.stdout.write("Generating Dart Code... ");
processTemplate('mdi.dart', {
  'VERSION': util.getVersion(),
});

processTemplate('icon_map.dart', {
  'ICON_MAP': meta.map((icon) => {
    return `  '${processName(icon.name)}': 0x${icon.codepoint},`;
  }).join('\n'),
});
console.log("OK")

process.stdout.write("Updating Font... ")
fs.copyFile('node_modules/@mdi/font/fonts/materialdesignicons-webfont.ttf', 'mdi/fonts/materialdesignicons-webfont.ttf', (err) => {
  if (err) {
    console.log("Error\n" + err)
  } else {
    console.log("OK")
  }
});


function processTemplate(path, params) {
  const template = util.read('templates/' + path + '.template');
  const output = template.split('\n').map((line) => {
    return line.replace(/<%\w+%>/g, (param) => {
      const name = param.replace(/\W/g, '');
      return params[name];
    });
  }).join('\n');

  util.write('mdi/lib/' + path, output);
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