{
  description = "Flutter development environment for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          buildToolsVersions = [ "34.0.0" "35.0.0" "36.0.0" ];
          platformVersions = [ "34" "35" "36" ];
          abiVersions = [ "x86_64" "arm64-v8a" ];

          includeNDK = true;

          includeSystemImages = false;
          includeEmulator = false;
          useGoogleAPIs = false;
        };

        androidSdk = androidComposition.androidsdk;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.flutter
            pkgs.jdk17
            androidSdk
          ];

          shellHook = ''
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
            export JAVA_HOME="${pkgs.jdk17}"

            flutter config --android-sdk "$ANDROID_HOME" > /dev/null 2>&1
          '';
        };
      }
    );
}
