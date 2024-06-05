#! /bin/bash
# vim: set sw=2 sts=2 ts=2 expandtab:
set -euo pipefail  # bash strict mode

function die () {
  echo "** ERROR: $*"
  exit 1
}

echo "-- run with $*"

OUTPUT_DIR="${OUTPUT_DIR:-${1:-}}"

if [ -z "${OUTPUT_DIR:-}" ]; then
  die "OUTPUT_DIR undefined or empty"
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
  mkdir "${OUTPUT_DIR}" || die "could not create ${OUTPUT_DIR}"
  echo "-- created ${OUTPUT_DIR}"
fi

cd "${OUTPUT_DIR}" || echo "couldn't access ${OUTPUT_DIR} folder"

# Run flex to generate the code for the scanner/lexer.
flex++ /work/scanner.ll \
  || die "scanner generation (flex++) failed"

# Run bison to generate the parser.
bison -Wcounterexamples /work/parser.y \
  || die "parser generation (bison) failed"

cp /usr/include/FlexLexer.h . || die "FlexLexer.h is missing"

echo "++ flex/bison files generated in ${OUTPUT_DIR}"
ls -l
