let
  flavors = import ../constants/flavors.nix;
in
[
  flavors.default
  flavors.full
  flavors.encodersgpl
]
