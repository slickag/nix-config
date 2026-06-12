{ pkgs }:

with pkgs; [
  # General packages for development and system management
  # act
  # alacritty
  # aspell
  # aspellDicts.en
  bash-completion
  bat
  # btop
  # coreutils
  difftastic
  # dust
  eza
  # gcc
  # git-filter-repo
  # killall
  lsd
  nano
  nanorc
  # neofetch
  # openssh
  # pandoc
  # sqlite
  utm
  # uv
  wget
  zip

  # Encryption and security tools
  # _1password
  # age
  # age-plugin-yubikey
  # gnupg
  # libfido2

  # Cloud-related tools and SDKs
  # docker
  # docker-compose
  # awscli2 - marked broken Mar 22
  # flyctl
  # google-cloud-sdk
  # gopls
  # ngrok
  # ssm-session-manager-plugin
  # terraform
  # terraform-ls
  # tflint

  # Media-related packages
  # emacs-all-the-icons-fonts
  # imagemagick
  dejavu_fonts
  # ffmpeg
  fd
  font-awesome
  # glow
  hack-font
  # jpegoptim
  meslo-lgs-nf
  noto-fonts
  noto-fonts-color-emoji
  # pngquant

  # Node.js development tools
  # nodejs_24

  # Text and terminal utilities
  # htop
  # hunspell
  # iftop
  # jetbrains-mono
  # jq
  ripgrep
  tree
  tmux
  unzip
  zsh-powerlevel10k
  
  # Development tools
  curl
  gh
  # kubectl
  lazygit
  fzf
  direnv
  
  # Programming languages and runtimes
  go
  rustc
  cargo
  openjdk

  # Python packages
  # black
  python3
  virtualenv
]
