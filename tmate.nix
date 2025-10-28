{ config, pkgs, ... }:

{
  # Tmate configuration
  home.file.".tmate.conf".text = ''
    # Basic tmate configuration
    set -g default-terminal "screen-256color"
    
    # Set prefix key to Ctrl-a (like screen)
    set -g prefix C-a
    unbind C-b
    bind C-a send-prefix
    
    # Enable mouse support
    set -g mouse on
    
    # Set history limit
    set -g history-limit 10000
    
    # Start windows and panes at 1, not 0
    set -g base-index 1
    setw -g pane-base-index 1
    
    # Renumber windows when one is closed
    set -g renumber-windows on
    
    # Enable activity alerts
    setw -g monitor-activity on
    set -g visual-activity on
    
    # Pane navigation
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R
    
    # Window navigation
    bind -n M-Left previous-window
    bind -n M-Right next-window
    
    # Split panes using | and -
    bind | split-window -h
    bind - split-window -v
    unbind '"'
    unbind %
    
    # Reload config file
    bind r source-file ~/.tmate.conf \; display-message "Config reloaded!"
    
    # Status bar configuration
    set -g status-bg black
    set -g status-fg white
    set -g status-left-length 40
    set -g status-left "#[fg=green]Session: #S #[fg=yellow]#I #[fg=cyan]#P"
    set -g status-right "#[fg=cyan]%d %b %R"
    set -g status-justify centre
    
    # Highlight active window
    setw -g window-status-current-style fg=white,bg=red,bright
  '';
}