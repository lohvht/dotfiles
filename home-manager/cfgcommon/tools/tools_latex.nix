config: lib: pkgs: extraArgs:
let
  cfgcommonlib = import ../lib/cfg_common_lib.nix;
  inherit (extraArgs) tools_latex is_GUI;
in
lib.optionals (tools_latex != null) [
  (cfgcommonlib.mkCfgCommon {
    home_programs = {
      texlive = {
        enable = true;
        extraPackages = tpkgs: {
          # Lazy to actually check through, lets just assume that this works
          # TODO: May wanna choose smaller scheme + add extra packages when needed
          # especially on places where space is a concern
          # We'll leave it to future Victor to handle though
          inherit (tpkgs) scheme-full;
        };
      };
    } // lib.optionalAttrs is_GUI {
      vscode = {
        userSettings = {
          "latex-workshop.latex.autoBuild.run" = "onFileChange";
          "latex-workshop.view.pdf.viewer" = "browser";
          "latex-workshop.latex.outDir" = "%DIR%/out";
          "latex-workshop.latex.tools" = [
              {
                  "name" = "latexmk";
                  "command" = "latexmk";
                  "args" = [
                      "-synctex=1"
                      "-interaction=nonstopmode"
                      "-file-line-error"
                      "-pdf"
                      "-pdflatex=lualatex"
                      "-outdir=%DIR%/out"
                      "%DOC%"
                  ];
                  "env" = {};
              }
              {
                  "name" = "lualatexmk";
                  "command" = "latexmk";
                  "args" = [
                      "-synctex=1"
                      "-interaction=nonstopmode"
                      "-file-line-error"
                      "-lualatex"
                      "-outdir=%OUTDIR%"
                      "%DOC%"
                  ];
                  "env" = {};
              }
              {
                  "name" = "latexmk_rconly";
                  "command" = "latexmk";
                  "args" = [
                      "%DOC%"
                  ];
                  "env" = {};
              }
              {
                  "name" = "pdflatex";
                  "command" = "pdflatex";
                  "args" = [
                      "-synctex=1"
                      "-interaction=nonstopmode"
                      "-file-line-error"
                      "%DOC%"
                  ];
                  "env" = {};
              }
              {
                  "name" = "bibtex";
                  "command" = "bibtex";
                  "args" = [
                      "%DOCFILE%"
                  ];
                  "env" = {};
              }
              {
                  "name" = "rnw2tex";
                  "command" = "Rscript";
                  "args" = [
                      "-e"
                      "knitr::opts_knit$set(concordance = TRUE); knitr::knit('%DOCFILE_EXT%')"
                  ];
                  "env" = {};
              }
              {
                  "name" = "jnw2tex";
                  "command" = "julia";
                  "args" = [
                      "-e"
                      "using Weave; weave(\"%DOC_EXT%\", doctype=\"tex\")"
                  ];
                  "env" = {};
              }
              {
                  "name" = "jnw2texmintex";
                  "command" = "julia";
                  "args" = [
                      "-e"
                      "using Weave; weave(\"%DOC_EXT%\", doctype=\"texminted\")"
                  ];
                  "env" = {};
              }
              {
                  "name" = "tectonic";
                  "command" = "tectonic";
                  "args" = [
                      "--synctex"
                      "--keep-logs"
                      "%DOC%.tex"
                  ];
                  "env" = {};
              }
          ];
        };
        extensions = [
          pkgs.vscode-extensions.james-yu.latex-workshop
        ];
      };
    };
  })
]
