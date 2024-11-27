Source-Makefile: package/feeds/packages/node-socket.io/Makefile
Build-Depends: node/host

Package: node-socket.io
Submenu: Node.js
Version: 4.7.2-1
Depends: +libc +USE_GLIBC:librt +USE_GLIBC:libpthread +node
Conflicts: 
Menu-Depends: 
Provides: 
Section: lang
Category: Languages
Repository: packages
Title: Realtime application framework
Maintainer: Hirokazu MORIKAWA <morikw2@gmail.com>
Source: socket.io-4.7.2.tgz
License: MIT
LicenseFiles: LICENSE
Type: ipkg
Description:  Real-time apps made cross-browser & easy with a WebSocket-like API
https://www.npmjs.org/package/socket.io
Hirokazu MORIKAWA <morikw2@gmail.com>
@@


