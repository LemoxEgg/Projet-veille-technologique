{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in
    rec {
      configuration =
        { pkgs, ... }@inputs:
        {

          ####configuration de base####

          # on active systemd-boot (on pourrai aussi utiliser grub)
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;

          # le nom d'hôte
          networking.hostName = "nixos";

          # on installe networkmanager pour faciliter la config réseau
          networking.networkmanager.enable = true;

          # information de timezone
          time.timeZone = "America/Toronto";

          # localisation
          i18n.defaultLocale = "en_CA.UTF-8";

          # on utilise le serveur x pour gérer le layout du clavier
          services.xserver.xkb = {
            layout = "ca";
            variant = "multix";
          };

          # option pour la console
          console.keyMap = "cf";

          ####configuration de l'utilisateur prinicpal####

          users.users = {
            emile = {
              isNormalUser = true;
              description = "utilisateur prinicipal pour le projet de veille";
              # d'autre options sont possible bien sûr. mais elle ne sont pas
              # nécéssaires ici, on les laisse par défaut.

              packages = with pkgs; [
                # c'est ici que l'on spécifie les programme que l'on
                # veut installer pour notre utilisateur. il est le
                # seul qui aura accès à ces programmes.
                # par exemple:
                helix # un éditeur de texte que j'aime beaucoup
                fastfetch # un classique
                yazi # un explorateur de fichier dans le terminal
              ];
            };
          };


          ####configuration des services####
          
          services = {
            # c'est ici qu'on configure les services de notre serveur

            # un serveur ssh plus ou moins sécurisé
            openssh = {
              enable = true;
              settings = {
                PermitRootLogin = "no";
                AllowUsers = [ "emile" ];
                PasswordAuthentication = true;
              };
            };

            # petit serveur nginx pour tester
            nginx = {
              enable = true;
              virtualHosts.localhost = {
                locations."/" = {
                  return = "200 '<html><body>hello world!</body></html>'";
                  extraConfig = ''
                    default_type text/html;
                  '';
                };
              };
            };
          };

          # on ouvre les ports du serveur ssh et http
          networking.firewall.allowedTCPPorts = [ 22 80 ];

          # version initiale du système NE PAS TOUCHER
          system.stateVersion = "25.05";
        };

      nixosConfigurations = {
        nixos = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            /etc/nixos/hardware-configuration.nix

            configuration
          ];
        };
      };
    };
}
