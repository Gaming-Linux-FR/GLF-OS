{
  lib,
  fetchpatch,
  fetchurl,
}:

{
freeze = {
    name = "freeze";
    patch = ./patch/freeze.patch;
  };
}
