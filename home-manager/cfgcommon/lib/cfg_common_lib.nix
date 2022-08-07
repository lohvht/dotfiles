let

# recursiveUpdateUntilMerge is similar to lib.recursiveUpdateUntil, but accepts an additional function `predMerge`
# with similar signature to pred
# Except that predMerge should return how to merge lhs and rhs if the pred call is true,  
recursiveUpdateMergeUntil = pred: predMerge: lhs: rhs:
  let f = attrPath:
    builtins.zipAttrsWith (n: values:
      let here = attrPath ++ [n]; in
      if builtins.length values == 1 then # Only one value for this attr
        builtins.head values
      else if pred here (builtins.elemAt values 1) (builtins.head values) then # If predicate is true, first attr value will be replaced by second attr value
        predMerge here (builtins.elemAt values 1) (builtins.head values)
      else # predicate is false, therefore both values are attr sets, we recurse downwards
        f here values
    );
  in f [] [rhs lhs];

# recursiveUpdateMerge merges 2 attrs sets lhs and rhs recursively. It concats lists together
# if hoth lhs and rhs are lists, otherwise, rhs be chosen
recursiveUpdateMerge = recursiveUpdateMergeUntil (
  path: lhs: rhs: !(builtins.isAttrs lhs && builtins.isAttrs rhs)
) (
  path: lhs: rhs: if (builtins.isList lhs && builtins.isList rhs) then lhs ++ rhs else rhs
);

mkCfgCommon = {
  # env variables to set, e.g.
  #   {EDITOR = "vim";}
  shell_variables ? {},
  # list of paths to append to $PATH, e.g.
  #   ["${config.home.homeDirectory}/.local/bin"]
  shell_paths ? [],
  # basic aliases to set, e.g.
  #   {gcom = "git commit ";}
  shell_aliases ? {},
  # list of shell functions to set, e,g,
  #   [
  #     ''
  #     function gf() {
  #       branch=$1;
  #       shift;
  #       git fetch origin -f "$branch":"$branch"
  #     }
  #     ''
  #   ]
  shell_functions ? [],
  # extra shell info to be added in chunks
  #   [
  #     ''
  #     if [ -x /usr/bin/dircolors ]; then
  #       test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  #     fi
  #     ''
  #   ]
  shell_extracommoninit ? [],
  shell_extracommon ? [],
  # home_packages to be added via home.packages in home.nix
  home_packages ? [],
  # home_programs to be added via programs in home.nix
  home_programs ? {},
  # home_files are files that are supposed to be written to home
  home_files ? {},
}: {
  inherit shell_variables;
  inherit shell_paths;
  inherit shell_aliases;
  inherit shell_functions;
  inherit shell_extracommoninit;
  inherit shell_extracommon;
  inherit home_packages;
  inherit home_programs;
  inherit home_files;
};

mergeCfgCommonsOp = x: y: let
  nx = mkCfgCommon x;
  ny = mkCfgCommon y;
in
recursiveUpdateMerge nx ny;
# mkCfgCommon{
#   shell_variables = recursiveUpdateMerge nx.shell_variables y.shell_variables;
#   shell_paths = nx.shell_paths ++ y.shell_paths;
#   shell_aliases = recursiveUpdateMerge nx.shell_aliases y.shell_aliases;
#   shell_functions = nx.shell_functions ++ y.shell_functions;
#   shell_extracommon = nx.shell_extracommon ++ y.shell_extracommon;
#   home_packages = nx.home_packages ++ y.home_packages;
#   home_programs = recursiveUpdateMerge nx.home_programs y.home_programs;
# };
in
{
  inherit mkCfgCommon;
  recursiveUpdateMergeAttrs = attrsets: (builtins.foldl' recursiveUpdateMerge {} attrsets);
  mergeCfgCommons = ccs: (builtins.foldl' mergeCfgCommonsOp {} ccs);
}