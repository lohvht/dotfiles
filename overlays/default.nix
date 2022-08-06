# Your overlays go here (see https://nixos.wiki/wiki/Overlays)
final: prev:
let
  # mypython3 = prev.python3.override {
  #   packageOverrides = pyfinal: pyprev: {
  #     virtualenvwrapper = pyprev.virtualenvwrapper.overrideAttrs(oldAttrs: {
  #       src = final.fetchPyPi {
  #         pname = "virtualenvwrapper";
  #       };
  #     });
  #   };
  # };
in
{
  # TODO: Additional customisation of our desired can be done here
  # more info:
  # NixOS Wiki for Python: https://nixos.wiki/wiki/Python
  # Nix Python User Guide: https://github.com/NixOS/nixpkgs/blob/22.05/doc/languages-frameworks/python.section.md
  custom_python310_with_defaults = prev.python310.withPackages(ps: [
    ps.pip
    ps.virtualenv
    ps.venvShellHook
  ]);
# This line adds our custom packages into the overlay.
} // import ../pkgs { pkgs = final; }
