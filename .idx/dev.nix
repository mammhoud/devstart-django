# Firebase IDX Nix Environment Configuration
{ pkgs, ... }: {
  # Define the Nixpkgs channel
  channel = "stable-24.05";

  # Add packages here – search via https://search.nixos.org/packages
  packages = [
    # Python + essential tools
    pkgs.python312
    pkgs.python312Packages.setuptools
    pkgs.python312Packages.wheel
    pkgs.python312Packages.pipx
    pkgs.python312Packages.pip
    pkgs.uv
    pkgs.sqlite

    # pkgs.hatch # Optional: only if needed
    pkgs.docker
  ];



  services = {
    docker.enable = true;
  };

  idx = {
    extensions = [
      "ms-python.python"
      "batisteo.vscode-django"
      "monosans.djlint"
      "bfrangi.vscode-django-tex"
      "donjayamanne.python-environment-manager"
      "donjayamanne.python-extension-pack"
      "KevinRose.vsc-python-indent"
      "njpwerner.autodocstring"
      "wholroyd.jinja"
    ];


    previews = {
      enable = false;
      previews = {
        web = {
          # Replace this with the script you want to preview (e.g., Django or frontend)
          command = [ "hatch" "run" "dev-frontend" ]; # or just: "sh docs.sh"
          manager = "web";
        };
      };
    };

workspace = {
  onStart = {
    # 1. Install core Python tools
    install-dep = ''
    uv pip install pip &&
    uv pip install pipx &&
    uv pip install hatch'';

    # 2. Install project dependencies via Hatch
    install-npm-pkgs = "hatch run install-dev";

    # 3. Prepare database models
    init-migrations = ''
    hatch run dev-backend makemigrations &&
    hatch run dev-backend migrate
    '';

    # 4. Start backend and frontend in parallel
    start-servers = ''
      hatch run dev-backend runserver &   # Start backend
      hatch run dev-frontend &            # Start frontend
      wait                                # Wait for both
    '';
  };
};
  };
}
