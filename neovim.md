# Neovim

Get a nerd-font
```
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/IBMPlexMono.zip
unzip IBMPlexMono.zip -d IBMPlexMono
mkdir ~/.fonts
mv IBMPlexMono ~/.fonts/
fc-cache -fv
```

Set the terminal font to the nerd font, and install Lazyvim
```
sudo dnf install ripgrep
git clone https://github.com/LazyVim/starter ~/.config/nvim
cp nvim_lua/mathews_lazyvim_plugins.lua ~/.config/nvim/lua/plugins/
```

Then edit the file ```~/.config/nvim/lua/config/options.lua``` to disable relative line numbers
and hiding of things like backticks in this markdown file.

```
vim.opt.relativenumber = false
vim.opt.conceallevel = 0
```

To disable automatic updates edit the file ```~/.config/nvim/lua/config/lazy.lua``` to disable lazy's checker

```
checker = { enabled = false }, -- automatically check for plugin updates
```

Updates can still be performed from inside neovim.
