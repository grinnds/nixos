{
  inputs,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    validateSopsFiles = false;

    # TODO: support any user
    age.keyFile = "/home/baris/.config/sops/age/keys.txt";

    secrets = {
      openrouter_api_key = { };
    };
  };
}
