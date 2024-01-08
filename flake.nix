{
  description = "nano-agenda";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nano-emacs.url = "github:rougier/nano-emacs";
    nano-agenda.url = "github:rougier/nano-agenda";
    nano-agenda.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, nano-emacs, nano-agenda }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        fonts = pkgs.makeFontsConf {
          fontDirectories =
            [ pkgs.iosevka pkgs.noto-fonts-emoji pkgs.roboto pkgs.fira-code ];
        };

        emacs = (pkgs.emacsPackagesFor pkgs.emacs-nox).emacsWithPackages (epkgs: [
          (pkgs.runCommand "nano-emacs" { } ''
            mkdir -p $out/share/emacs/site-lisp
            cp ${nano-emacs}/quick-help.org ${nano-emacs}/*.el $out/share/emacs/site-lisp/
            # remove load-path update
            sed -e '/load-path/d' -i $out/share/emacs/site-lisp/nano.el
            # apply new agenda
            cp ${nano-agenda}/*.el $out/share/emacs/site-lisp/
          '')
          epkgs.org-ql
          epkgs.magit
          epkgs.company
          epkgs.markdown-mode
          epkgs.nano-agenda
        ]);

        # for regular emacs
        emacs-wrapper = pkgs.writeScriptBin "nano-emacs" ''
          #!/bin/sh
          exec env FONTCONFIG_FILE=${fonts} ${emacs}/bin/.emacs-wrapped --load ${self}/default.el $*
        '';
        nox-wrapper = pkgs.writeScriptBin "nano-emacs" ''
          #!/bin/sh
          exec ${emacs}/bin/.emacs-wrapped --load ${self}/default.el $*
        '';
      in { defaultPackage = nox-wrapper; });
}
