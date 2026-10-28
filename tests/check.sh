#!/usr/bin/env bash
# Checks an installed nvchad-romeo: run it on ROMEO after install.sh (from your computer: ssh romeo ~/nvchad-romeo/tests/check.sh).
# Opens C++, Python, Lua and shell files in a headless nvim with the real config and checks the theme, Treesitter,
# the LSP servers, formatting on save, the OSC 52 clipboard and the keys. Then bash -n (and shellcheck if present).
set -uo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$HERE")
CHECK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/nvchad-romeo-check.XXXXXX")
export CHECK_DIR
trap 'rm -rf "$CHECK_DIR"' EXIT

cat >"$CHECK_DIR/main.cpp" <<'CPP'
#include <vector>
int main() {
  std::vector<int> v{1, 2, 3};
  return v.size() + undefined_name;
}
CPP
printf 'int   main( ){return 0;}\n' >"$CHECK_DIR/ugly.cpp"
printf 'import os\n\n\ndef f(x: int) -> int:\n    return x + 1\n' >"$CHECK_DIR/main.py"
printf 'local t = { 1, 2 }\nreturn t\n' >"$CHECK_DIR/main.lua"
printf '#!/usr/bin/env bash\necho hello\n' >"$CHECK_DIR/main.sh"

status=0
# after VimEnter, as in a real session (vim.lsp.enable only attaches open buffers once Neovim has started)
(cd "$CHECK_DIR" && "$ROOT/bin/nvim" --headless --cmd "autocmd VimEnter * ++once lua vim.schedule(function() dofile([[$HERE/check.lua]]) end)") 2>&1 || status=1

for f in "$ROOT/install.sh" "$ROOT/bin/nvim" "$ROOT/share/tree-sitter" "$HERE/check.sh"; do
  bash -n "$f" || status=1
done
if command -v shellcheck >/dev/null; then
  shellcheck "$ROOT/install.sh" "$ROOT/bin/nvim" "$ROOT/share/tree-sitter" "$HERE/check.sh" && echo "  ok    shellcheck" || status=1
fi
exit $status
