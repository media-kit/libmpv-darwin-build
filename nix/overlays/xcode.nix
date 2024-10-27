final: prev: {
  darwin = prev.darwin.overrideScope (
    final: prev: {
      xcode_16_0 = prev.xcode.overrideAttrs (prev: {
        outputHash = "sha256-4+v7xPRUiNao3ZUNA9otI6I2WfSQtED19Z+MKNvlKC4=";
      });
      xcode = final.xcode_16_0;
    }
  );
}
