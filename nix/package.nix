{
  lib,
  buildDotnetModule,
  dotnetCorePackages,
  jdk17,
  maven,
  src,
}:

let
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
in
buildDotnetModule (finalAttrs: {
  pname = "p";
  version = "3.1.0";

  inherit src;

  # P targets .NET 8.
  dotnet-sdk = dotnet-sdk;
  dotnet-runtime = dotnet-sdk.runtime;

  projectFile = "Src/PCompiler/PCommandLine/PCommandLine.csproj";
  nugetDeps = ./deps.json;

  executables = [ "p" ];

  nativeBuildInputs = [ jdk17 ];

  # The ANTLR grammar is processed by the Java-based ANTLR tool. The compiler
  # project hard-codes /usr/bin/java for non-Windows hosts, which does not exist
  # inside the Nix build sandbox.
  postPatch = ''
    substituteInPlace Src/PCompiler/CompilerCore/CompilerCore.csproj \
      --replace-fail "/usr/bin/java" "${jdk17}/bin/java"
  '';

  # The P CLI shells out to the .NET SDK to build the C# code it generates and
  # to Java (and Maven for the PEx target) to run/compile the generated backend.
  makeWrapperArgs = [
    "--set JAVA_HOME ${jdk17}"
    "--prefix PATH : ${
      lib.makeBinPath [
        jdk17
        dotnet-sdk
        maven
      ]
    }"
  ];

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/p --help > /dev/null
  '';

  meta = {
    description = "Compiler and model checker for the P programming language";
    homepage = "https://github.com/p-org/P";
    changelog = "https://github.com/p-org/P/blob/master/ChangeList.md";
    license = lib.licenses.mit;
    mainProgram = "p";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
