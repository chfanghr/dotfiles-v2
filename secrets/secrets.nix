let
  master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmGxwcswrJNNjgKYV8WxhFKDIUtrUSM/JwC4HT8sDjX fanghr@Demeter";
  athena = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyVzMHW3wrVYygLvd2S6QfhrDYMNuzALQaJAGPzEoYm root@Athena";
  persephone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe9Z3dt2JFIbqE13NCv7q6ELCh6zfxd8jBl7US8kb9e root@Persephone";
  oizys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxg7xOUiwUYgizuVkUm9nogD5dpLAqiwkz9X8pYkb8z root@Oizys";
  demeter = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6nS/4X/8gD4nAVR1aQqbyxZXt2j22NQc4FkHq2aB2Z root@Demeter";
  eros = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK//i91fqmujtuzzRG7VrL3Hx+MsPWwSyNpbHdVYIRUH root@Eros";
  hestia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbRbsi/M17Abse+SY5LVXAH9hoL5Z7GClbxNv44No8q root@Hestia";
  artemis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILa7DkensLy34eSaK3tBtaYNxxbkF6KBAnEEiwnEiBX4 root@Artemis";
in {
  "athena-sing-box-default-out.age".publicKeys = [master athena];
  "oizys-sing-box-default-out.age".publicKeys = [master eros artemis];
  "artemis-cifs-credential.age".publicKeys = [master persephone];
  "yotsuba.key.age".publicKeys = [master persephone];
  "oizys-pap-password.age".publicKeys = [master oizys eros];
  "github-runner-token-chfanghr-dotfiles-v2.age".publicKeys = [master persephone];
  "demeter-hci-token.age".publicKeys = [master demeter];
  "demeter-hci-binary-caches.age".publicKeys = [master demeter];
  "demeter-hci-secrets-json.age".publicKeys = [master demeter];
  "demeter-default.keytab.age".publicKeys = [master demeter];
  "persephone-default.keytab.age".publicKeys = [master persephone];
  "minecraft.keytab.age".publicKeys = [master demeter];
  "persephone-nix-cache-key.age".publicKeys = [master persephone];
  "zrepl-hestia.snow-dace.ts.net.key.age".publicKeys = [master hestia];
  "zrepl-persephone.snow-dace.ts.net.key.age".publicKeys = [master persephone];
  "hestia-nix-cache-key.age".publicKeys = [master hestia];
  "demeter-nix-cache-key.age".publicKeys = [master demeter];
}
