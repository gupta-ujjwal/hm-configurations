{ pkgs, system, ... }:
let
  # neovim-nightly = inputs.neovim-nightly-overlay.packages.${system}.neovim;
in
{
  programs.neovim = {
    enable = true;
    # package = neovim-nightl;
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
