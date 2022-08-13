{ config, lib, options, pkgs, ... }:
{
  options.customHomeProfile = {
    GUI.enable = lib.mkEnableOption "check if we should include GUI options for home manager profiles";
    git = {
      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The git username to use. if null, dont set any";
      };
      userEmail = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "The git email to use. if null, dont set any";
      };
    };
    golang.enable = lib.mkEnableOption "enable golang configuration";
    latex.enable = lib.mkEnableOption "enable latex configuration";
    node.enable = lib.mkEnableOption "enable node configuration";
    python.enable = lib.mkEnableOption "enable python configuration";
    rust.enable = lib.mkEnableOption "enable rust configuration";
  };
}
