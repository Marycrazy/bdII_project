{ pkgs ? import <nixpkgs> {} }:

let
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [ pip ]);
in
pkgs.mkShell {
    buildInputs = with pkgs; [
        pythonEnv
        tree
    ];

    shellHook = ''
        export PYTHONPATH=$PYTHONPATH:$(pwd)

        python3 -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt

        alias cls='clear'

        echo "Shell is ready!"
    '';
}