{ pkgs, system, ... }:

{
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    prefix = "C-a";
    clock24 = true;
    disableConfirmationPrompt = true;
    keyMode = "vi";
    mouse = true;
    reverseSplit = true;
    customPaneNavigationAndResize = true;
    shell = "${pkgs.zsh}/bin/zsh";
  };
}
