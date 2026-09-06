{ config, pkgs, ... }:

let
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
    "fs.file-max" = 2097152;
    "vm.swappiness" = 10;
  };

  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  systemd.services.dell-g15-max-fans = {
    description = "Forçar Ventoinhas no Máximo (Dell G-Mode)";
    after = [ "systemd-modules-load.service" ];
    wantedBy = [ "multi-user.target" ];
    
    script = ''
      if [ -e /proc/acpi/call ]; then
        echo "\\_SB.AMWW.WMAX 0 0x25 {1, 0x01, 0x00, 0x00}" > /proc/acpi/call
        echo "\\_SB.AMWW.WMAX 0 0x15 {1, 0xab, 0x00, 0x00}" > /proc/acpi/call
      fi
      exit 0
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.thermald.enable = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  services.flatpak.enable = true;
  services.xserver.enable = true;

  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";

    extraPackages = with pkgs; [
      kdePackages.qtmultimedia
    ];
  };

  services.desktopManager.plasma6.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;

    powerManagement.enable = true;
    powerManagement.finegrained = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest; 

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # CORRIGIDO: Removido o formato '0@0' que causava erros de sintaxe no NixOS
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.scsiLinkPolicy = "max_performance";

  programs.fish.enable = true;

  programs.gamemode = {
    enable = true;

    settings = {
      general = {
        renice = 10;
      };

      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode Ativado' 'Otimizações de performance aplicadas.'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode Desativado' 'Perfil padrão restaurado.'";
      };
    };
  };

  programs.steam.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  users.users."et" = {
    isNormalUser = true;
    description = "1155doET";
    shell = pkgs.fish;

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = (with pkgs; [
    neovim
    vim
    wget
    curl
    git
    tree
    ffmpeg
    fuzzel
    drawing
    pinta
    tree-sitter
    kitty
    rofi
    kdePackages.qt5compat
    vscode
    flatpak
    pamixer
    playerctl
    btop
    libnotify
    montserrat
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    librewolf
    firefox
    spotify
    discord
    swaybg
    imagemagick
    matugen
    hyprpaper
    hyprshot
    pavucontrol
    networkmanagerapplet
    waypaper
    pywal
    quickshell
    qt6.qtdeclarative
    waybar
    brightnessctl
    grimblast
    papirus-icon-theme
    lavat
    cava
    cmatrix
    zip
    unzip
    cpufetch
    macchina
    starfetch
    ufetch
    nerdfetch
    disfetch
    hyfetch
    onefetch
    fastfetch
    p7zip
    nyancat
    gcc
    nasm
    libc
  ]) ++ [
    sddm-astronaut
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    NIXOS_OZONE_WL = "1";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05";
}
