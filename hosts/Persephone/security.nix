{
  age.secrets = {
    default-keytab = {
      owner = "root";
      file = ../../secrets/persephone-default.keytab.age;
      path = "/etc/krb5.keytab";
      mode = "600";
    };
  };
}
