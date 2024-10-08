{ lib
, rustPlatform
, makeWrapper
, pkg-config
, udev
, killall
, rfkillFeature ? false
}:

rustPlatform.buildRustPackage rec {

  pname = "swhkd";
  version = "1.3.0-git";

  src = lib.cleanSource ../.;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "sweet-0.3.0" = "sha256-swSE1CE39cGojp8HAziw0Bzjr+s4XaVU+4OqQDO60fE=";
    };
  };

  buildFeatures = [ ] ++ lib.optional rfkillFeature "rfkill";

  nativeBuildInputs = [ 
    pkg-config
    makeWrapper
  ];

  buildInputs = [ 
    udev
    killall
  ];

  postInstall = ''
    mkdir -p $out/share/polkit-1/actions
    cat > $out/share/polkit-1/actions/com.github.swhkd.pkexec.policy <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN" "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <action id="com.github.swhkd.pkexec">
    <message>Authentication is required to run Simple Wayland Hotkey Daemon</message>
    <defaults>
      <allow_any>no</allow_any>
      <allow_inactive>no</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">$out/bin/swhkd</annotate>
  </action>
</policyconfig>
EOF
  '';
}