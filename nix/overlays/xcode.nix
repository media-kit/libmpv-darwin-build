final: prev: {
  darwin = prev.darwin.overrideScope (
    final: prev: {
      xcode_16_1 = prev.xcode.overrideAttrs (prev: {
        outputHash = "sha256-1jyRJVyOmGA7fxRwBnxSJatnOFDu01RJ9aAQXJNuWBw=";
      });
      xcode = final.xcode_16_1;
    }
  );
}
