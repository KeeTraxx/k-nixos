{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Multimedia and Utilities
    aria2 # better wget
    yt-dlp

    # cli tools
    htop
    p7zip
    bat
    mc
    dust # better du
    ncdu # du with tui
    dog # better dig
    rsync
    ffmpeg
    imagemagick
    nmap # ncat for gdscript language server
    sops # encryption tool for secrets
    age # key generator for sops
    unstable.claude-code
    exiftool # exiftool
    poppler-utils # pdfinfo, pdffonts
    yq # yaml query tool
    jq # json query tool
    whois # whois lookup tool
    qrencode # qr code generator

    # Development Tools
    ripgrep # fast recursive grep. run with rgrep
    just # command runner
    rustup
    jq
    sqlite
    gh # github cli
    pipenv
    uv # python package manager
    pylint # python linter

    # Infrastructure and Cloud Tools
    opentofu
    terraform
    terramate
    kubectl
    kubectx
    kubeseal
    kube-linter
    k9s
    tflint
    argocd
    summon
    awscli2
    kubernetes-helm
    talosctl

    # nix specific
    home-manager
    nixd
    nil
    nvd
    nh
    nixos-rebuild
  ];
}
