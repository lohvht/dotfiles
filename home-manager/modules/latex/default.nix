{ config, lib, pkgs, ... }:
let
  isGUIEnable = config.customHomeProfile.GUI.enable;
  cfg = config.customHomeProfile.latex;
in
{
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      programs.texlive = {
        enable = true;
        extraPackages = tpkgs: {
          # Lazy to actually check through, lets just assume that this works
          # TODO: May wanna choose smaller scheme + add extra packages when needed
          # especially on places where space is a concern
          # We'll leave it to future Victor to handle though
          inherit (tpkgs) scheme-full;
        };
      };
    }
    (lib.mkIf isGUIEnable {
      programs.vscode = {
        userSettings = {
          "latex-workshop.latex.autoBuild.run" = "onFileChange";
          "latex-workshop.view.pdf.viewer" = "browser";
          "latex-workshop.latex.outDir" = "%DIR%/out";
          "latex-workshop.latex.tools" = [
              {
                  "name" = "latexmk"; "command" = "latexmk"; "env" = {};
                  "args" = ["-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-pdf" "-pdflatex=lualatex" "-outdir=%DIR%/out" "%DOC%"];
              }
              {   "name" = "lualatexmk"; "command" = "latexmk"; "env" = {};
                  "args" = ["-synctex=1" "-interaction=nonstopmode" "-file-line-error" "-lualatex" "-outdir=%OUTDIR%" "%DOC%"];
              }
              {   "name" = "latexmk_rconly"; "command" = "latexmk"; "env" = {};
                  "args" = ["%DOC%"];
              }
              {   "name" = "pdflatex"; "command" = "pdflatex"; "env" = {};
                  "args" = ["-synctex=1" "-interaction=nonstopmode" "-file-line-error" "%DOC%"];
              }
              {   "name" = "bibtex"; "command" = "bibtex"; "env" = {};
                  "args" = ["%DOCFILE%"];
              }
              {   "name" = "rnw2tex"; "command" = "Rscript"; "env" = {};
                  "args" = ["-e" "knitr::opts_knit$set(concordance = TRUE); knitr::knit('%DOCFILE_EXT%')"];
              }
              {   "name" = "jnw2tex"; "command" = "julia"; "env" = {};
                  "args" = ["-e" "using Weave; weave(\"%DOC_EXT%\", doctype=\"tex\")"];
              }
              {   "name" = "jnw2texmintex"; "command" = "julia"; "env" = {};
                  "args" = ["-e" "using Weave; weave(\"%DOC_EXT%\", doctype=\"texminted\")"];
              }
              {   "name" = "tectonic"; "command" = "tectonic"; "env" = {};
                  "args" = ["--synctex" "--keep-logs" "%DOC%.tex"];
              }
          ];
        };
        extensions = [
          pkgs.vscode-extensions.james-yu.latex-workshop
        ];
      };
    })
  ]);
}
