#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const { parseWeBloc } = require('./lib/parse-webloc');
const { exec } = require('child_process');

function openUrl(url) {
  return new Promise((resolve, reject) => {
    const safe = String(url).replace(/"/g, '\\"');
    if (process.platform === 'win32') {
      // Use cmd.exe start to open default browser on Windows
      exec(`start "" "${safe}"`, { shell: 'cmd.exe' }, (err) => err ? reject(err) : resolve());
    } else if (process.platform === 'darwin') {
      exec(`open "${safe}"`, (err) => err ? reject(err) : resolve());
    } else {
      exec(`xdg-open "${safe}"`, (err) => err ? reject(err) : resolve());
    }
  });
}

function printUsage() {
  console.log('Usage: node index.js [--no-open] path/to/file.webloc [other.webloc ...]');
  console.log('  --no-open    Do not open found URLs in the default browser');
}

if (require.main === module) {
  (async () => {
    const args = process.argv.slice(2);
    if (args.length === 0) {
      printUsage();
      process.exit(1);
    }

    const openEnabled = !args.includes('--no-open');
    const fileArgs = args.filter(a => !a.startsWith('-'));
    if (fileArgs.length === 0) {
      printUsage();
      process.exit(1);
    }

    for (const arg of fileArgs) {
      const fp = path.resolve(arg);
      if (!fs.existsSync(fp)) {
        console.error('File not found:', fp);
        continue;
      }

      try {
        const urlRaw = parseWeBloc(fp);
        if (urlRaw) {
          // Normalize and trim the URL to avoid issues with whitespace or encoding
          const trimmed = String(urlRaw).trim();
          let urlToOpen = trimmed;
          try {
            urlToOpen = new URL(urlToOpen).toString();
          } catch (e) {
            try {
              urlToOpen = new URL(encodeURI(urlToOpen)).toString();
            } catch (e2) {
              // leave as-is; best-effort
            }
          }

          console.log(`Target URL: ${urlToOpen}`);

          if (openEnabled) {
            try {
              console.log('Opening URL...');
              const p = openUrl(urlToOpen);
              await Promise.race([p, new Promise(res => setTimeout(res, 2000))]);
              console.log('Open request sent.');
            } catch (err) {
              console.error('Failed to open URL:', err && err.message ? err.message : err);
            }
          }
        } else {
          console.log(`${arg}: URL not found`);
        }
      } catch (err) {
        console.error(`${arg}: parse error:`, err.message);
      }
    }
  })();
}

module.exports = { parseWeBloc: (p) => parseWeBloc(p) };
