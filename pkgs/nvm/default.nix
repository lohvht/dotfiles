{
  lib,
  stdenv,
  fetchFromGitHub,
  writeShellScriptBin,
  # packages needed
  coreutils,
  bash,
}:
let
  script_nvmpostinit = writeShellScriptBin "eval_nvmpostinit" ''
    export NVM_DIR="$HOME/.nix_nvm"
    [ -s "REPLACE_ME/nvm.sh" ] && \. "REPLACE_ME/nvm.sh"  # This loads nvm
    [ -s "REPLACE_ME/bash_completion" ] && \. "REPLACE_ME/bash_completion"  # This loads nvm bash_completion
  '';
in
stdenv.mkDerivation rec {
  pname = "nvm";
  version = "0.39.1";
  nativeBuildInputs = [
    coreutils
  ];
  buildInputs = [
    bash
  ];
  src = fetchFromGitHub {
    owner = "nvm-sh";
    repo = "nvm";
    rev = "v${version}";
    sha256 = "0x5w4v9hpns1p60d21q9diyq3lykpk2dlpcczcwdd24q6hmx5a4f";
  };

  dontBuild = true;
  installPhase = ''
    cp -R $PWD $out
    cd $out
    mkdir -p $out/bin

    cp ${script_nvmpostinit}/bin/eval_nvmpostinit $out/bin/nvm_postinit
    substituteInPlace $out/bin/nvm_postinit --replace "REPLACE_ME" "$out"
  '';
  dontPatchELF = true;

  meta = with lib; {
    description = "Node Version Manager - POSIX-compliant bash script to manage multiple active node.js versions ";
    homepage = "https://github.com/nvm-sh/nvm";
    license = licenses.mit;
    platforms = with platforms; linux ++ darwin;
  };
}
