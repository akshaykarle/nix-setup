{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "spacy";
  version = "3.8.5";

  src = fetchPypi {
    inherit pname version;
    hash = "c709e15a72f95b386df78330516cbd7c71d59ec92fc4342805ed69aeebb06f03";
  };

  # do not run tests
  doCheck = false;
  broken = false;

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];
}
