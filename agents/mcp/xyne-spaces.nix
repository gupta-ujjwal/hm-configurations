{
  command = "npx";
  args = [ "-y" "@xyne/spaces-mcp" ];
  env = {
    XYNE_SPACES_BASE_URL = "https://spaces.xyne.juspay.net";
  };
}
