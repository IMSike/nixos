{ ... }:
{
  home-manager.users.lanath = {
    programs.waybar = {
      enable = true;
    };

    xdg.configFile."waybar" = {
      source = ./files;
      recursive = true;
    };

  };
}