{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  writeShellScriptBin,
  makeWrapper,
  # packages needed
  git,
  bash,
  python3,
  zlib,
  readline,
  libffi,
  bzip2,
  openssl,
  ncurses,
  sqlite,
  xz,
}:
let
  # TODO: This pyenv package installation still has a few issues
  #       However installation for python>=3.7.8 in general should be safe
  #       Pyenv has a list of common build problems, need to check why
  #       https://github.com/pyenv/pyenv/wiki/Common-build-problems
  #
  #       We may also need to study how Cpython is actually compiled on nix's end
  #       So that we can emulate it when doing the pyenv installs
  #       https://github.com/NixOS/nixpkgs/blob/2270b66d759f0a9c022576ce42fa5a770a754250/pkgs/development/interpreters/python/default.nix
  buildFlags = {
    CPPFLAGS = builtins.concatStringsSep " " [
      "-I${zlib.dev}/include"
      "-I${libffi.dev}/include"
      "-I${readline.dev}/include"
      "-I${bzip2.dev}/include"
      "-I${openssl.dev}/include"
      "-I${ncurses.dev}/include"
      "-I${sqlite.dev}/include"
      "-I${xz.dev}/include"
    ];
    CFLAGS = builtins.concatStringsSep " " [
      "-I${zlib.dev}/include"
      "-I${libffi.dev}/include"
      "-I${readline.dev}/include"
      "-I${bzip2.dev}/include"
      "-I${openssl.dev}/include"
      "-I${ncurses.dev}/include"
      "-I${sqlite.dev}/include"
      "-I${xz.dev}/include"
    ];
    LDFLAGS = builtins.concatStringsSep " " [
    "-L${zlib.out}/lib"
    "-L${libffi.out}/lib"
    "-L${readline.out}/lib"
    "-L${bzip2.out}/lib"
    "-Wl,-rpath,${openssl.out}/lib"
    "-L${ncurses.out}/lib"
    "-L${sqlite.out}/lib"
    "-L${xz.out}/lib"
    ];
    CONFIGURE_OPTS = builtins.concatStringsSep " " [
      "--with-openssl=${openssl.dev}"
    ];
  };

  script_pyenvpostinit = writeShellScriptBin "eval_pyenv" ''
    export PYENV_BUILDFLAG_CPPFLAGS="${buildFlags.CPPFLAGS}"
    export PYENV_BUILDFLAG_CFLAGS="${buildFlags.CFLAGS}"
    export PYENV_BUILDFLAG_LDFLAGS="${buildFlags.LDFLAGS}"
    export PYENV_BUILDFLAG_CONFIGURE_OPTS="${buildFlags.CONFIGURE_OPTS}"
    export PYENV_ROOT="$HOME/.nix_pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then
      eval "$(pyenv init -)"
    fi

    echo "[pyenv] post init completed"
    echo "[pyenv] pyenv requires build environment dependencies that arent easily replicated via nix to be installed"
    echo "[pyenv] the following are build flag env vars set so that you can attempt to set the CPPFLAGS, CFLAGS, LDFLAGS installed via nix using this pyenv installation when running \`pyenv install\`"
    echo "        - PYENV_BUILDFLAG_CPPFLAGS"
    echo "        - PYENV_BUILDFLAG_CFLAGS"
    echo "        - PYENV_BUILDFLAG_LDFLAGS"
    echo "        - PYENV_BUILDFLAG_CONFIGURE_OPTS"
    echo "[pyenv] Otherwise, checkout the following links to install the dependencies required in your system via your system's package manager"
    echo "        - CPython setup and build env: https://devguide.python.org/getting-started/setup-building/index.html"
    echo "        - pyenv suggested build env: https://github.com/pyenv/pyenv/wiki#suggested-build-environment"
    echo "        - pyenv common build problems: https://github.com/pyenv/pyenv/wiki/Common-build-problems"
  '';
in
stdenv.mkDerivation rec {
  pname = "pyenv";
  version = "2.3.3";
  nativeBuildInputs = [
    bash
    makeWrapper
  ];
  buildInputs = [
    git
    pkg-config
    python3
    zlib
    readline
    libffi
    bzip2
    openssl
    sqlite
  ];
  src = fetchFromGitHub {
    owner = "pyenv";
    repo = "pyenv";
    rev = "v2.3.3";
    sha256 = "0a50nk6nmn19yxf5qxmc332wfbsvyn1yxhvn4imqy181fkwq2wlg";
  };

  prePatch = ''
    substituteInPlace src/configure --replace "#!/usr/bin/env bash" "#!${bash}/bin/bash"
  '';

  dontBuild = true;
  installPhase = ''
    cp -R $PWD $out
    cd $out
    src/configure
    make -C src

    cp ${script_pyenvpostinit}/bin/eval_pyenv $out/bin/pyenv_postinit

    # We need to call makeWrapper instead of the higher level wrapProgram as
    # pyenv is just a symlink to another executable
    # This way we can ensure that the build flags are set
    mv $out/bin/pyenv $out/bin/.pyenv-wrapped
    makeWrapper $out/bin/.pyenv-wrapped $out/bin/pyenv --set CPPFLAGS \
    "${buildFlags.CPPFLAGS}" \
    --set CFLAGS \
    "${buildFlags.CFLAGS}" \
    --set LDFLAGS \
    "${buildFlags.LDFLAGS}" \
    --set CONFIGURE_OPTS \
    "${buildFlags.CONFIGURE_OPTS}"
  '';
  dontPatchELF = true;

  meta = with lib; {
    description = "Simple Python Version Management: pyenv";
    homepage = "https://github.com/pyenv/pyenv";
    license = licenses.mit;
    platforms = with platforms; linux ++ darwin;
  };
}
