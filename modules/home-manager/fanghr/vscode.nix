{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.vscode-server.homeModules.default
  ];

  services.vscode-server.enable = true;

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.cpptools
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      streetsidesoftware.code-spell-checker
      vadimcn.vscode-lldb
      dhall.vscode-dhall-lsp-server
      mkhl.direnv
      tamasfe.even-better-toml
      vscjava.vscode-java-pack
      waderyan.gitblame
      mhutchie.git-graph
      donjayamanne.githistory
      codezombiech.gitignore
      golang.go
      haskell.haskell
      justusadam.language-haskell
      oderwat.indent-rainbow
      ms-toolsai.jupyter
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      james-yu.latex-workshop
      ms-vsliveshare.vsliveshare
      sumneko.lua
      davidanson.vscode-markdownlint
      jnoortheen.nix-ide
      ocamllabs.ocaml-platform
      ryu1kn.partial-diff
      mechatroner.rainbow-csv
      jock.svg
      gruntfuggly.todo-tree
      zxh404.vscode-proto3
      wakatime.vscode-wakatime
      redhat.vscode-yaml
      aaron-bond.better-comments
      dhall.dhall-lang
      usernamehw.errorlens
      tailscale.vscode-tailscale
      rust-lang.rust-analyzer
    ];

    userSettings = {
      "editor.accessibilitySupport" = "off";
      "editor.fontFamily" = "FiraCode Nerd Font, JetBrains Mono, Menlo, Monaco, 'Courier New', monospace";
      "terminal.integrated.fontFamily" = "CaskaydiaCove Nerd Font Mono, MesloLGS NF";
      "workbench.startupEditor" = "none";
      "editor.inlineSuggest.enabled" = true;
      "editor.tabSize" = 2;
      "git.confirmSync" = false;
      "[haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
      };
      "haskell.formattingProvider" = "fourmolu";
      "git.enableCommitSigning" = true;
      "cSpell.userWords" = [
        "arity"
        "cardano"
        "chfanghr"
        "frps"
        "Funde"
        "Merkle"
        "Mintings"
        "Monoid"
        "newtype"
        "offchain"
        "ogmios"
        "peekable"
        "Plutip"
        "Preimage"
        "proto"
        "pubkey"
        "reedemer"
        "Semigroup"
        "skey"
        "uasse"
        "ucoin"
        "ucoins"
        "UTXO"
        "utxo"
        "uvaule"
      ];
      "haskell.manageHLS" = "PATH";
      "security.workspace.trust.untrustedFiles" = "open";
      "workbench.iconTheme" = "vscode-icons";
      "rust-client.disableRustup" = true;
      "rust-client.engine" = "rust-analyzer";
      "redhat.telemetry.enabled" = false;
      "editor.rulers" = [80 120];
      "haskell.plugin.eval.config.exception" = true;
      "cmake.configureOnOpen" = true;
      "explorer.confirmDelete" = false;
      "clangd.onConfigChanged" = "restart";
      "editor.codeLensFontFamily" = "FiraCode Nerd Font, JetBrains Mono";
      "vsicons.dontShowNewVersionMessage" = true;
      "[purescript]" = {
        "editor.defaultFormatter" = "nwolverson.ide-purescript";
      };
      "markdownlint.customRules" = [];
      "markdownlint.config" = {
        "MD004" = false;
      };
      "telemetry.telemetryLevel" = "off";
      "editor.lineNumbers" = "relative";
      "editor.minimap.renderCharacters" = false;
      "debug.allowBreakpointsEverywhere" = true;
      "files.hotExit" = "off";
      "window.restoreWindows" = "none";
      "git.openRepositoryInParentFolders" = "always";
      "rust-analyzer.semanticHighlighting.punctuation.separate.macro.bang" = true;
      "rust-analyzer.server.extraEnv" = {
        "RA_LOG" = "info";
      };
      "rust-analyzer.workspace.symbol.search.kind" = "all_symbols";
      "rust-analyzer.workspace.symbol.search.scope" = "workspace_and_dependencies";
      "rust-analyzer.completion.privateEditable.enable" = true;
      "git-graph.repository.commits.showSignatureStatus" = true;
      "git-graph.repository.sign.commits" = true;
      "RainbowBrackets.depreciation-notice" = false;
      "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
      "update.mode" = "manual";
      "workbench.colorTheme" = "Vim Dark Hard";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
