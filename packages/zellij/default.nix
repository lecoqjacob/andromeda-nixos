{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  installShellFiles,
  perl,
  pkg-config,
  libiconv,
  openssl,
  mandown,
  zellij,
  testers,
  pkgs,
}:
rustPlatform.buildRustPackage {
  pname = "zellij";

  src = fetchFromGitHub {
    owner = "zellij-org";
    repo = "zellij";
    rev = "9a38ad2e152b914c75f0156e5a9985fe22013346";
    hash = "sha256-ZKtYXUNuBwQtEHTaPlptiRncFWattkkcAGGzbKalJZE=";
  };

  cargoHash = "sha256-4XRCXQYJaYvnIfEK2b0VuLy/HIFrafLrK9BvZMnCKpY=";

  nativeBuildInputs = [
    mandown
    installShellFiles
    perl
    pkg-config
  ];

  buildInputs = with pkgs;
    [
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      libiconv
      DiskArbitration
      Foundation
    ];

  preCheck = ''
    HOME=$TMPDIR
  '';

  postInstall = ''
    mandown docs/MANPAGE.md > zellij.1
    installManPage zellij.1
    installShellCompletion --cmd $pname \
      --bash <($out/bin/zellij setup --generate-completion bash) \
      --fish <($out/bin/zellij setup --generate-completion fish) \
      --zsh <($out/bin/zellij setup --generate-completion zsh)
  '';

  passthru.tests.version = testers.testVersion {package = zellij;};

  meta = with lib; {
    description = "A terminal workspace with batteries included";
    homepage = "https://zellij.dev/";
    changelog = "https://github.com/zellij-org/zellij/blob/v${version}/CHANGELOG.md";
    license = with licenses; [mit];
    maintainers = with maintainers; [therealansh _0x4A6F abbe thehedgeh0g];
    mainProgram = "zellij";
  };
}
