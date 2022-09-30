{
  description = "A flake to wrap and call an external bash script";

  inputs.nixpkgs.url = github:NixOS/nixpkgs;

  outputs = { self, nixpkgs }:

    let      
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      # The simple way to do it.
      #wrapped = pkgs.writeShellApplication {
      #  name = "script";
      #  runtimeInputs = with pkgs; [
      #    hello
      #  ];
      #  text = builtins.readFile ./count-five.sh;
      #};

      # The less simple way to do it.
      read = rec {
        name = "script";
        text  = builtins.readFile ./countdown.sh;
        script = (pkgs.writeShellScriptBin name text).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      };
      symlink = with pkgs; pkgs.symlinkJoin {
        name = "script";
        paths = [
          read.script
          pkgs.hello
        ];
      };
      wrapped = pkgs.writeShellScriptBin "script" ''
        PATH=${pkgs.hello}/bin:$PATH
        exec ${symlink}/bin/script
      '';

    in {
      
      packages.x86_64-linux = {
        default = wrapped;
      };
      
      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            wrapped
          ];
          shellHook = ''
            PATH=${pkgs.hello}/bin:$PATH
            ${symlink}/bin/script
          '';
        };
      };
      
    };
}
