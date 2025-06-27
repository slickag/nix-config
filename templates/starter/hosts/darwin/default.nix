{ config, pkgs, ... }:

let user = "%USER%"; in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
  ];

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    # emacs-unstable
    vim
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  # launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  # launchd.user.agents.emacs.serviceConfig = {
    # KeepAlive = true;
    # ProgramArguments = [
      # "/bin/sh"
      # "-c"
      # "/bin/wait4path ${pkgs.emacs}/bin/emacs && exec ${pkgs.emacs}/bin/emacs --fg-daemon"
    # ];
    # StandardErrorPath = "/tmp/emacs.err.log";
    # StandardOutPath = "/tmp/emacs.out.log";
  # };

  security.pam.enableSudoTouchIdAuth = true;
  system = {
    checks.verifyNixPath = false;
    primaryUser = user;
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      CustomSystemPreferences = {
        "com.apple.timemachine.HelperAgent" = {
          DoNotAskAgainToSetUpNewDisks = true;
        };
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.swipescrolldirection" = false;
      };

      dock = {
        autohide = false;
        show-recents = true;
        launchanim = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        _FXShowPosixPathInTitle = false;
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
      };

      magicmouse.MouseButtonMode = "TwoButton";

      # trackpad = {
        # Clicking = true;
        # TrackpadThreeFingerDrag = true;
      # };
    };
  };
}
