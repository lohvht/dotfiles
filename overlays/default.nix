# Your overlays go here (see https://nixos.wiki/wiki/Overlays)
final: prev:
let
in
{
# This line adds our custom packages into the overlay.
} // import ../pkgs { pkgs = final; }
