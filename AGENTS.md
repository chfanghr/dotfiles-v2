# AGENTS.md

## Repo
- Nix flake dotfiles repo.
- Root entrypoint is `flake.nix`.
- `configurations.nix` is the source of truth for `nixosConfigurations` and `deploy.nodes`.
- Host configs live under `hosts/<Name>/default.nix`.
- Disk layouts usually live beside the host as `disko.nix` or `disko-config.nix`.

## Common Commands
- `nix develop` - enter the repo dev shell with deploy, disko, agenix, nixos-anywhere, and related tools.
- `nix flake check` - run the flake checks.
- `nixos-rebuild build .#<hostname>` - build a host configuration without switching it.
- `deploy .#<host>` - deploy a host through deploy-rs. Use `-s` to skip unnecessary evaluation.

## Formatting / Lint
- `pre-commit run --all-files` - format and lint the repo with the configured hooks.
- Pre-commit only enforces `alejandra` and `deadnix`.
- `.pre-commit-config.yaml` is generated. Do not edit it directly.

## Deployment
- Deployments use `deploy-rs` through `deploy .#<host>`.
- Deploys always prompt for your sudo password.
- Deploy settings are defined in `configurations.nix`.
- Each host there maps to a deploy node with `sshUser = "fanghr"` and remote `root`.

## Disk Layouts
- Disk layout changes are host-specific and usually live in `hosts/<Host>/disko*.nix`.
- Most hosts import `inputs.disko.nixosModules.default`.
- Apollo-style ZFS hosts need `boot.zfs.extraPools` and `networking.hostId` kept consistent with the disko layout.
- Some hosts have extra initrd unlock/key-import logic on top of disko, especially for encrypted ZFS.

## Secrets
- Secrets are managed with `agenix` and live under `secrets/`.
