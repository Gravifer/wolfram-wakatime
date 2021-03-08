(* ::Package:: *)

(* ::Title:: *)
(*Mathematica WakaTime Plugin*)


(* ::Author:: *)
(*Author: Gravifer*)
(*Date: 2021-03-08*)
(*Version: 0.0.4*)


BeginPackage["WakaTime`"]
ClearAll[Evaluate[Context[] <> "*"]]


Begin["`Private`"]
Unprotect[GetWakaEXE,$WakaTimePluginVersion,
UpdateHeartbeat,GetGitFolder,GetCurrentProject,GetCurrentFile,
ManageEvaluationNotebookChange,SendHeartbeat]
ClearAll[Evaluate[Context[] <> "*"]]


GetWakaEXE[]:=If[#[["ExitCode"]]==0,Identity[$wakaEXE=Last@StringReplace[StringSplit[#[["StandardOutput"]],"\r"|"\n"],{"\\"->"/","\r"->"","\n"->""}]],Print["wakatime.exe is not found"];$Failed]&@RunProcess[{"where.exe", "wakatime.exe"}]
Evaluate[GetWakaEXE[]]
$WakaTimePluginVersion="v0.0.4"
WakaTime::unsaved="The current file is not on the disk, and the heartbeat cannot be sent. (This message only issue once for the current file)";
Once[If[ValueQ[$PrePrint],$WakaTimePreReadBackUp=$PreRead]]


UpdateHeartbeat[]:=(Once[$LastHeartbeat=AbsoluteTime[]];
  If[Not[ValueQ[$LastHeartbeat]]&&(AbsoluteTime[]-$LastHeartbeat>0),
  Quiet@Unset@Once[$LastHeartbeat=AbsoluteTime[]];Once[$LastHeartbeat=AbsoluteTime[]];True,
  False])


GetGitFolder[]:=(If[#[["ExitCode"]]==0,
  Set[$gitFolder,Last[FileNameSplit@StringReplace[#[["StandardOutput"]],{"\\"->"/","\r"->"","\n"->""}]]],
  Unset[$gitFolder]]&@Evaluate[RunProcess[{"git","rev-parse","--show-toplevel"}]];)


GetGitBranch[]:=(If[#[["ExitCode"]]==0,
  Set[$gitBranch,Last[FileNameSplit@StringReplace[#[["StandardOutput"]],{"\\"->"/","\r"->"","\n"->""}]]],
  Unset[$gitBranch]]&@Evaluate[RunProcess[{"git","branch","--show-current"}]];)


GetCurrentProject[]:=($CurrentProject=If[ValueQ[$gitFolder],
      StringTemplate["\"`gitFolder`\""][<|"gitFolder"->$gitFolder|>],"\"wolfram-wakatime\""])


GetCurrentFile[]:=If[Not[Enclose[StringReplace[Quiet@Confirm@NotebookFileName[],"\\"->"/"],Null&]===Null],
  Set[$CurrentFile,StringReplace[Quiet@NotebookFileName[],"\\"->"/"]],
  Unset[$CurrentFile]];


ManageEvaluationNotebookChange[]:=(#;If[Not[$CurrentNotebook===EvaluationNotebook[]],
  Quiet@Unset@Once[Message[WakaTime::unsaved]];GetGitFolder[];GetCurrentProject[];GetCurrentFile[];Unset@#];#;)&@
  Unevaluated[Once[$CurrentNotebook=Quiet@EvaluationNotebook[]]];


SendHeartbeat[]:=If[ValueQ[$CurrentFile],StartProcess[{$wakaEXE, "--write",
  "--plugin"  ,
    StringTemplate["\"Mathematica-wakatime-gravifer-plugin/`PlugInVersion`\""][<|"PlugInVersion"->$WakaTimePluginVersion|>],
  "--entity"  ,
    StringTemplate["\"`CurrentFile`\""][<|"CurrentFile"->$CurrentFile|>],
  "--lineno", $Line,
  "--language", "Wolfram",
  "--alternate-project", 
    StringTemplate["\"`CurrentProject`\""][<|"CurrentProject"->$CurrentProject|>],
  "--hostname", ToUpperCase[$MachineName]}],
 Once[Message[WakaTime::unsaved]]]


$PreRead=(ManageEvaluationNotebookChange[];If[UpdateHeartbeat[],SendHeartbeat[]];
If[ValueQ[$WakaTimePreReadBackUp],$WakaTimePreReadBackUp[#],#])&;


Protect[GetWakaEXE,$WakaTimePluginVersion,
UpdateHeartbeat,GetGitFolder,GetCurrentProject,GetCurrentFile,
ManageEvaluationNotebookChange,SendHeartbeat]


End[]


EndPackage[]
