# dotfiles

Various dotfiles I use that I can just clone to wherever I need them.

## Neovim

The config file is in [.config/nvim/init.lua](.config/nvim/init.lua). On first startup it will bootstrap the package manager [Paq](https://github.com/savq/paq-nvim), install packages, and then reload `init.lua`. Things should just work™️. To update packages afterwards run the `PaqSync` command (see the [Paq](https://github.com/savq/paq-nvim) README for more information).

