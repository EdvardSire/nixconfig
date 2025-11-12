{
  octavePackages,
  fetchFromGitHub
}:

octavePackages.buildOctavePackage rec {
  pname = "mss";
  version = "0.1.0";

  src = fetchFromGitHub {
      owner = "cybergalactic";
      repo = "MSS";
      rev = "ab9d5c264f571927914bcaa36f6f24ee601a731a";
      hash = "sha256-Uwr2foDyEP0g0zrJCXf+xzdqOtBkgo/d/q/ZQ+pe/Wk=";
  };
    
    # reference layout: https://github.com/gnu-octave/pkg-control
    postPatch = ''
      cat > DESCRIPTION <<EOF
Name: mss
Version: 0.1.0
Date: 1970-01-01
Author: Thor I. Fossen <thor.fossen@ntnu.no>
Maintainer: Thor I. Fossen <thor.fossen@ntnu.no>
Title: MSS (Marine Systems Simulator)
Description: The Marine Systems Simulator (MSS) is software that supplements the
 textbook "Handbook of Marine Craft Hydrodynamics and Motion Control"
Depends: octave (>= 10.0.0)
Autoload: no
License: MIT
Url: https://github.com/cybergalactic/MSS
Tracker: https://github.com/cybergalactic/MSS/issues
EOF
      cat > INDEX <<EOF
upstream empty
EOF
      cat > COPYING <<EOF
upstream empty
EOF

    # duplicates can be found with
    # find FDI GNC HYDRO INS LIBRARY VESSELS -type f -name '*.m' \
    #   -exec basename {} \; | sort | uniq -d
    # at the moment its only config_parameters.m and fit_siso_fresp.m
    mkdir -p inst
    find FDI GNC HYDRO INS LIBRARY VESSELS -type f -name '*.m' -exec cp {} inst/ \;
  '';

}
