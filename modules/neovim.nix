{ pkgs, system, ... }:
let
  # neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
{
  home.file = {
    ".config/nvim/lua/opts.lua".source = ../nvim/lua/opts.lua;
    ".config/nvim/lua/vars.lua".source = ../nvim/lua/vars.lua;
    ".config/nvim/lua/keys.lua".source = ../nvim/lua/keys.lua;
    ".config/nvim/lua/plugins.lua".source = ../nvim/lua/plugins.lua;
  };

  programs.neovim = {
    enable = true;
    # package = neovim-nightl;
    withRuby = false;
    withPython3 = false;
    extraPackages = [
    ];

    plugins = with pkgs.vimPlugins; [
      vim-airline
      papercolor-theme
      nerdtree
      nvim-web-devicons
      vim-startify
      dracula-nvim
      telescope-nvim
      telescope_hoogle
      plenary-nvim
      vim-fugitive
      gv-vim
      indentLine
      vim-commentary
      markdown-preview-nvim
      (nvim-treesitter.withPlugins (p: [
        p.html
        p.markdown
        p.markdown_inline
      ]))
    ];
    
    coc = {
      enable = true;
      settings = {
        languageserver = {
          haskell = {
            command = "haskell-language-server-wrapper";
            args = [ "--lsp" ];
            rootPatterns = [
              "*.cabal"
              "cabal.project"
              "hie.yaml"
            ];
            filetypes = [ "haskell" "lhaskell" ];
          };
        };
      };
    };

    extraConfig = ''
       
       lua <<EOF
       require("opts")
       require("vars")
       require("keys")
       require("plugins")
       EOF
    
    '';
  };
}
