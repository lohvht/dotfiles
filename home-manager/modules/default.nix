# Add your home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
{ ... }:
{
  imports = [
    # List your module files here
    ./common
    ./sshagent
    ./gui
    ./golang
    ./latex
    ./node
    ./python
    ./rust
    ./ruby
    ./cloudproviders
    ./clouddevelopment
    ./passwordmanagers
    ./bluray_cd
    ./databases
  ];
}
