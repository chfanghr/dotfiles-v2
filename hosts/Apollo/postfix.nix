{
  config,
  secrets,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  saslPasswd = "postfix-sasl-passwd";
  smtpGenericMaps = "postfix-smtp-generic-maps";

  cfg = config.services.postfix;

  mkSecret = file: {
    inherit file;
    owner = cfg.user;
    inherit (cfg) group;
    mode = "0400";
  };

  instance = "main";
in {
  options.apollo.services.postfix = {
    instance = mkOption {
      type = types.str;
      default = instance;
      readOnly = true;
    };

    port = mkOption {
      type = types.port;
      default = 25;
      readOnly = true;
    };
  };

  config = {
    age.secrets = {
      ${saslPasswd} = mkSecret "${secrets}/apollo-postfix-sasl-passwd.age";
      ${smtpGenericMaps} = mkSecret "${secrets}/apollo-postfix-smtp-generic-maps.age";
    };

    services.postfix = {
      enable = true;

      settings.${instance} = {
        inet_interfaces = "all";

        mynetworks = [
          "127.0.0.0/8"
          "[::1]/128"
        ];

        relayhost = ["[smtp.gmail.com]:587"];

        smtp_sasl_auth_enable = true;
        smtp_sasl_password_maps = "texthash:${config.age.secrets.${saslPasswd}.path}";
        smtp_generic_maps = "texthash:${config.age.secrets.${smtpGenericMaps}.path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_sasl_tls_security_options = "noanonymous";
        smtp_tls_security_level = "encrypt";
      };
    };
  };
}
