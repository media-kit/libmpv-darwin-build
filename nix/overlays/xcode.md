# Override Xcode package to link to a custom version

## How to download a specific Xcode version

See https://github.com/NixOS/nixpkgs/blob/24.05/pkgs/os-specific/darwin/xcode/default.nix

## How to get Xcode version

```shell
$ /path/to/Xcode.app/Contents/Developer/usr/bin/xcodebuild -version
Xcode 16.0
Build version 16A242d
```

## How to store Xcode and prevent to be garbage collected

```shell
$ nix-store --add-fixed --recursive sha256 /path/to/Xcode.app
/nix/store/9irb2b36sn0693q7x2l554inm81vb2g6-Xcode.app
$ sudo mkdir -m 0755 /nix/var/nix/gcroots/per-user/$USER
$ sudo chown -R $USER /nix/var/nix/gcroots/per-user/$USER
$ ln -s /nix/store/9irb2b36sn0693q7x2l554inm81vb2g6-Xcode.app /nix/var/nix/gcroots/per-user/$USER/xcode-16-0
```

## How to get base64 hash of Xcode object

```shell
$ nix-store --query --hash /nix/store/9irb2b36sn0693q7x2l554inm81vb2g6-Xcode.app
sha256:0bi8wpdji34zypsl1d4hyickd8i35pd063cmvnldd22lyk2gpsz3
$ nix hash convert --to base64 sha256:0bi8wpdji34zypsl1d4hyickd8i35pd063cmvnldd22lyk2gpsz3
4+v7xPRUiNao3ZUNA9otI6I2WfSQtED19Z+MKNvlKC4=
```

## How to realize Xcode to be garbage collected

```shell
$ rm /nix/var/nix/gcroots/per-user/$USER/xcode-16-0
```
