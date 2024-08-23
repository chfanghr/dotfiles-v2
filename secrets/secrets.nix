let
  master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmGxwcswrJNNjgKYV8WxhFKDIUtrUSM/JwC4HT8sDjX fanghr@Demeter";
  athena = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyVzMHW3wrVYygLvd2S6QfhrDYMNuzALQaJAGPzEoYm root@Athena";
  persephone = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEe9Z3dt2JFIbqE13NCv7q6ELCh6zfxd8jBl7US8kb9e root@Persephone";
  oizys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxg7xOUiwUYgizuVkUm9nogD5dpLAqiwkz9X8pYkb8z root@Oizys";
in {
  "athena-sing-box-default-out.age".publicKeys = [master athena];
  "artemis-cifs-credential.age".publicKeys = [master persephone];
  "yotsuba.key.age".publicKeys = [master persephone];
  "oizys-pap-password.age".publicKeys = [master oizys];
}
