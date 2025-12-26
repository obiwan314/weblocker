const fs = require('fs');
const { XMLParser } = require('fast-xml-parser');

/**
 * Parse a .webloc (plist XML) file and return the URL (or null if not found).
 * @param {string} filePath
 * @returns {string|null}
 */
function parseWeBloc(filePath) {
  const xml = fs.readFileSync(filePath, 'utf8');
  return parseWeBlocString(xml);
}

/**
 * Parse a .webloc XML string and return the URL (or null if not found).
 * @param {string} xml
 * @returns {string|null}
 */
function parseWeBlocString(xml) {
  const parser = new XMLParser({ ignoreAttributes: false, ignoreDeclaration: true });
  const obj = parser.parse(xml);

  function findUrl(parsed) {
    if (!parsed || !parsed.plist || !parsed.plist.dict) return null;
    const dict = parsed.plist.dict;

    if (Array.isArray(dict.key)) {
      for (let i = 0; i < dict.key.length; i++) {
        if (dict.key[i] === 'URL') {
          return (dict.string && dict.string[i]) || null;
        }
      }
    } else {
      if (dict.key === 'URL') return dict.string || null;
      if (dict.URL) return dict.URL;
    }

    // Fallback: search the serialized object for an http(s) URL
    const text = JSON.stringify(parsed);
    const match = text.match(/https?:\/\/[^\s"'\}]+/);
    return match ? match[0] : null;
  }

  return findUrl(obj);
}

module.exports = { parseWeBloc, parseWeBlocString };
