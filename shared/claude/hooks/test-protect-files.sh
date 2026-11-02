#!/usr/bin/env bash
# Tests for protect-files.sh: feeds sample tool calls in and checks block / allow.
#   bash ~/.claude/hooks/test-protect-files.sh        (or from the repo: shared/claude/hooks/)
# Run after every change to the hook, and once on each new machine.
set -u
HOOK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/protect-files.sh"
pass=0; failn=0

# expect <block|allow> <description> <json payload>
expect() {
  local want="$1" desc="$2" payload="$3" out code got
  out="$(printf '%s' "$payload" | bash "$HOOK" 2>/dev/null)"; code=$?
  if [ $code -eq 2 ] || printf '%s' "$out" | grep -q '"permissionDecision": *"deny"'; then got=block; else got=allow; fi
  if [ "$got" = "$want" ]; then pass=$((pass+1)); printf "  ok    %-6s %s\n" "$want" "$desc"
  else failn=$((failn+1)); printf "  FAIL  want %-6s got %-6s %s\n" "$want" "$got" "$desc"; fi
}
read_()  { printf '{"tool_name":"Read","tool_input":{"file_path":"%s"}}' "$1"; }
write_() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$1"; }
bash_()  { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }

echo "protect-files.sh"
expect block "read .env"                       "$(read_ /p/app/.env)"
expect block "read .env.local"                 "$(read_ /p/app/.env.local)"
expect allow "read .env.example"               "$(read_ /p/app/.env.example)"
expect allow "read .env.tpl (references only)"  "$(read_ /p/app/.env.tpl)"
expect allow "read .envrc"                     "$(read_ /p/app/.envrc)"
expect block "read file in _secrets/"          "$(read_ /w/20_Private/00_Shared/_secrets/github.env)"
expect block "read file in secrets/"           "$(read_ /p/app/secrets/token.txt)"
expect block "read private key"                "$(read_ /home/me/.ssh/id_ed25519)"
expect block "read *.pem"                      "$(read_ /p/app/cert.pem)"
expect block "read credentials.md"             "$(read_ /p/notes/credentials.md)"
expect allow "write credentials.md"            "$(write_ /p/notes/credentials.md)"
expect block "write inside .git/"              "$(write_ /p/app/.git/config)"
expect allow "read inside .git/"               "$(read_ /p/app/.git/config)"
expect allow "read normal source file"         "$(read_ /p/app/src/index.ts)"
expect block "bash: redirect into .env"        "$(bash_ 'printf x > .env')"
expect block "bash: cat credentials.md"        "$(bash_ 'cat notes/credentials.md')"
expect allow "bash: ls credentials.md"         "$(bash_ 'ls notes/credentials.md')"
expect allow "bash: append to credentials.md"  "$(bash_ 'echo entry >> notes/credentials.md')"
expect allow "bash: heredoc mentioning .env"   "$(bash_ 'cat > .gitignore <<EOF\n.env\nEOF')"
expect allow "bash: normal command"            "$(bash_ 'npm test')"
expect block "unknown tool fails closed"       '{"tool_name":"Mystery","tool_input":{}}'
expect block "empty payload fails closed"      ''

echo "passed: $pass  failed: $failn"
[ $failn -eq 0 ]
