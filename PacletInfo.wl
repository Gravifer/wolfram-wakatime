(* ::Package:: *)

(* :Date: 21.03.08 *)

Paclet[
  Name -> "WakaTime",
  Version -> "0.0.4",
  MathematicaVersion -> "9+",
  Description -> "Plugin to use WakaTime API in the Mathematica Front End",
  SystemID -> "Windows-x-86-64",
  Loading->"Startup",
  Creator -> "Gravifer",
  Thumbnail -> "Assets/Logo-340.svg",
  URL -> "https://github.com/Gravifer/wolfram-wakatime",
  Extensions ->
      {
        {"Kernel", Root -> ".", Context -> "WakaTime`"},
        {"PacletServer",
          "Tags" -> {"plug-in", "activity tracking"},
          "Categories" -> {"Utility"},
          "Description" -> "WakaTime is a plugin to use WakaTime API in the Mathematica Front End.",
          "License" -> "MIT"
        }
      }
]


