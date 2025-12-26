# weblocker

Small CLI that extracts the URL from `.webloc` (plist XML) files and opens them in the default browser.

## Build a Windows standalone executable

Requirements: Node.js, npm

1. Install dev dependency:
   ```bash
   npm install --save-dev pkg
   ```

2. Build (Windows x64):
   ```bash
   npm run build
   # output: dist/weblocker.exe
   ```

3. Run the executable:
   ```bash
   dist\weblocker.exe path\to\file.webloc
   ```

Notes:
- The build embeds a Node runtime; executable size is larger (tens of MB).
- The `pkg` config includes `examples/**` so sample files are bundled if needed.
- For installers or file associations on Windows, consider creating an installer (Inno Setup / NSIS) and registering the `.webloc` association.
