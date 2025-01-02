local lspconfig = require('lspconfig')
lspconfig.intelephense.setup {
  settings = {
    intelephense = {
      stubs = {
        "bcmath", "bz2", "Core", "curl", "date", "dom", "fileinfo", "filter", "gd", "gettext", "hash", "iconv", "imap", "intl", "json", "libxml", "mbstring", "mcrypt", "mysql", "mysqli", "password", "pcntl", "pdo", "pgsql", "Phar", "readline", "recode", "Reflection", "session", "SimpleXML", "soap", "sockets", "sodium", "SPL", "standard", "superglobals", "tidy", "tokenizer", "xml", "xdebug", "xmlreader", "xmlwriter", "yaml", "zip", "zlib",
        "pest"
      },
    },
  },
}
