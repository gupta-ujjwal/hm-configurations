{
  permissions = {
    defaultMode = "bypassPermissions";
  };
  enabledPlugins = {
    "playwright@claude-plugins-official" = true;
    "claude-md-management@claude-plugins-official" = true;
  };
  voice = {
    enabled = true;
    mode = "hold";
  };
}
