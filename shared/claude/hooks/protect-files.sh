#!/bin/bash
# PreToolUse hook — path x operation protection.
#
#   path pattern                                          read     write
#   ---------------------------------------------------------------------
#   **/.env, **/.env.*   (except .env.example)            block    block
#   key material (see the classify() cases below)         block    block
#   **/credentials.md                                     block    ALLOW
#   **/.git/**                                            allow    block
#   .env.example, .env.tpl, .envrc, everything else       allow    allow
#
# DESIGN RULE, from the hooks docs: permission rules handle anything a pattern can
# express; a hook is for decisions that need logic. This hook therefore only carries
# what the deny rules provably cannot:
#
#   1. credentials.md — read-blocked, write-allowed. Verified 2026-08-17: a
#      `Read(<path>)` deny rule also blocks Write and Edit on that path ("File is
#      covered by a Read deny rule ... and cannot be written"), so a deny rule would
#      make the file unusable. Only a hook can express the asymmetry.
#   2. **/.env.* minus .env.example — deny rules have no negation, so `Read(**/.env.*)`
#      would swallow .env.example, which .gitignore whitelists via !.env.example.
#   3. .git/** — write-blocked but read-allowed; same negation problem.
#   4. Bash writes by redirection — verified 2026-08-17 that deny rules do NOT screen
#      Bash output redirection (`printf x > .env` ran), though they DO screen literal
#      paths in Bash reads (`cat <denied path>` was refused).
#
# WHAT THIS HOOK DELIBERATELY DOES NOT DO: it does not scan Bash commands for mentions
# of secret paths. The deny rules already screen those, and mention-scanning was pure
# cost — it refused `git check-ignore notes/credentials.md`, refused an `echo` whose
# text merely contained a pattern, and made it impossible to write a file whose CONTENT
# talks about protected paths. A check that duplicates a permission rule buys nothing
# and breaks honest work.
#
# HERE-DOCUMENTS: a heredoc body is content, not commands, and is skipped. Without this,
# writing this very file — or any .gitignore — from the shell is impossible, because a
# body line reading `**/credentials.md` looks like a command operating on that path.
#
# NEVER EMIT "allow": hooks run BEFORE permission rules, and a hook "allow" bypasses the
# whole permission flow, including the deny rules. This hook only ever denies or stays
# silent (exit 0, no output) so the normal flow decides.
#
# DECISION CHANNEL: policy denials print the documented JSON (permissionDecision "deny")
# and exit 0, so the reason reaches Claude verbatim. Internal failures use exit 2, which
# blocks unoverridably.
#
# FAIL CLOSED: missing jq, empty or unparsable payload, a path-carrying tool arriving
# without a path, or an unclassified tool name all exit 2. The original version exited 0
# in every one of those cases, so a missing dependency disabled protection silently.
#
# BASH LIMIT: command text is all we get, and it cannot be sealed. A glob defeats it
# (`cat notes/creden*.md` was verified to bypass both this hook and Claude Code's own
# built-in Bash screening), as does a path assembled at runtime, base64/xxd, an editor,
# or a helper script. This catches the obvious mistake, nothing more. Do not add patterns
# here believing Bash can be closed.
#
# NOT COVERED: Glob (returns names, not content). Grep is covered only when it carries an
# explicit path — a pathless Grep is allowed through rather than fail-closed, because
# failing closed there would block ordinary searching.

set -uo pipefail
set -f   # no pathname expansion — command tokens must never be glob-expanded here

fail_closed() { echo "protect-files: $1" >&2; exit 2; }

# --- dependency, fail closed -------------------------------------------------
JQ="$(command -v jq 2>/dev/null || true)"
if [ -z "$JQ" ]; then
  for c in /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq; do
    [ -x "$c" ] && JQ="$c" && break
  done
fi
[ -z "$JQ" ] && fail_closed "jq not found (PATH or known locations) — failing closed. Install it (brew install jq) or remove this hook deliberately."

deny() {
  "$JQ" -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# --- payload, fail closed ----------------------------------------------------
INPUT="$(cat)"
[ -z "$INPUT" ] && fail_closed "empty hook payload — failing closed."
printf '%s' "$INPUT" | "$JQ" -e . >/dev/null 2>&1 || fail_closed "unparsable hook payload — failing closed."

TOOL="$(printf '%s' "$INPUT" | "$JQ" -r '.tool_name // empty')"
[ -z "$TOOL" ] && fail_closed "payload carries no tool_name — failing closed."

PATH_REQUIRED=yes
case "$TOOL" in
  Read|NotebookRead)                  OP=read  ;;
  Write|Edit|MultiEdit|NotebookEdit)  OP=write ;;
  Bash)                               OP=bash  ;;
  Grep)                               OP=read; PATH_REQUIRED=no ;;
  *) fail_closed "unclassified tool '$TOOL' reached this hook — failing closed. Add it to the classifier deliberately." ;;
esac

# --- classifier: secret | credentials | git | none ---------------------------
# Whole-basename and whole-segment globs. The original substring test matched .envrc
# and .environment/ against ".env"; these cannot.
classify() {
  local p="${1//\\//}"                    # normalize Windows backslashes
  p="${p%\"}"; p="${p#\"}"; p="${p%\'}"; p="${p#\'}"
  local base="${p##*/}"

  # Checked first: must stay readable AND writable — .gitignore says so explicitly.
  [ "$base" = ".env.example" ] && { echo none; return; }
  # .env.tpl holds only password-manager references (op://...), never values - see shared/templates/env.tpl.
  [ "$base" = ".env.tpl" ] && { echo none; return; }

  case "$base" in
    .env|.env.*)                                  echo secret;      return ;;
    # Apple Keynote also uses .key, but stores presentations as directory bundles, so a
    # direct file read of one is not a normal operation. Treated as key material.
    *.pem|*.key|*.p12|*.pfx|*.jks|*.keystore|*.ppk|*.kdbx) echo secret; return ;;
    id_rsa*|id_dsa*|id_ecdsa*|id_ed25519*)        echo secret;      return ;;
    .netrc|.npmrc|.pypirc|.pgpass)                echo secret;      return ;;
    credentials.json|service-account*.json)       echo secret;      return ;;
    credentials.md)                               echo credentials; return ;;
  esac

  local IFS=/ seg
  for seg in $p; do
    case "$seg" in
      secrets|_secrets|.aws|.ssh|.gnupg|.kube) echo secret; return ;;
      .git)                           echo git;    return ;;
    esac
  done
  echo none
}

# Utilities that only name a path without revealing its contents.
names_only() {
  case "$1" in
    ls|stat|file|find|test|wc|du|basename|dirname|realpath|touch|mkdir|rmdir|echo|printf|git|chmod) return 0 ;;
    *) return 1 ;;
  esac
}

# --- Bash: only what the deny rules cannot do --------------------------------
# (a) redirection targets, because deny rules ignore Bash writes
# (b) credentials.md, because no deny rule may exist for it
if [ "$OP" = bash ]; then
  CMD="$(printf '%s' "$INPUT" | "$JQ" -r '.tool_input.command // empty')"
  [ -z "$CMD" ] && fail_closed "Bash call without a command field — failing closed."

  hd_delim=""
  while IFS= read -r line; do

    # Inside a here-document: body text, not commands.
    if [ -n "$hd_delim" ]; then
      trimmed="${line#"${line%%[![:space:]]*}"}"
      [ "$trimmed" = "$hd_delim" ] && hd_delim=""
      continue
    fi

    # Starting one: remember the delimiter, then inspect only the command part that
    # precedes it, so `cat > secret <<EOF` is still caught.
    case "$line" in
      *"<<"*)
        d="${line#*<<}"; d="${d#-}"; d="${d%%[[:space:]]*}"
        d="${d//\'/}"; d="${d//\"/}"
        hd_delim="$d"
        line="${line%%<<*}"
        ;;
    esac

    # Split so a harmless leading utility in one segment cannot excuse a read in the
    # next (`mkdir x && cat secret`).
    segs="${line//&&/$'\n'}"; segs="${segs//||/$'\n'}"
    segs="${segs//|/$'\n'}"; segs="${segs//;/$'\n'}"

    while IFS= read -r seg; do
      [ -z "$seg" ] && continue

      # Mark redirections so their operand is distinguishable from a mere mention.
      marked="${seg//>>/ __REDIR__ }"; marked="${marked//>/ __REDIR__ }"
      marked="${marked//[()\`\"\']/ }"

      lead=""; prev=""
      for tok in $marked; do
        [ -z "$lead" ] && [ "$tok" != "__REDIR__" ] && lead="${tok##*/}"
        verdict="$(classify "$tok")"

        if [ "$prev" = "__REDIR__" ]; then
          # Write target. credentials.md may be written and appended — appending is the
          # safe way to add an entry, since reading it is blocked.
          [ "$verdict" = secret ] && deny "Blocked: Bash would write to '$tok', which matches a protected secret pattern. Deny rules do not screen shell redirection, so this hook is the only layer here."
        elif [ "$verdict" = credentials ] && ! names_only "$lead"; then
          deny "Blocked: '$lead' would read '$tok'. Credentials are read-blocked by design; writing and appending are allowed. Name the path, never the contents."
        fi
        prev="$tok"
      done
    done <<< "$segs"
  done <<< "$CMD"
  exit 0
fi

# --- path-carrying tools -----------------------------------------------------
PATHS="$(printf '%s' "$INPUT" | "$JQ" -r '
  [ .tool_input.file_path?, .tool_input.notebook_path?, .tool_input.path? ]
  | map(select(type == "string" and . != "")) | .[]')"

if [ -z "$PATHS" ]; then
  [ "$PATH_REQUIRED" = yes ] && fail_closed "tool '$TOOL' reached this hook without a recognizable path parameter (file_path / notebook_path / path) — failing closed."
  exit 0
fi

while IFS= read -r p; do
  [ -z "$p" ] && continue
  case "$(classify "$p")" in
    secret)
      deny "Blocked: $p matches a protected secret pattern — read and write are both denied." ;;
    credentials)
      [ "$OP" = read ] && deny "Blocked: $p — credentials are read-blocked by design; writing is allowed. Because reading is blocked, Edit is impossible: add entries by appending from the shell, or replace the whole file with Write. Name the path, never the contents."
      ;;
    git)
      [ "$OP" = write ] && deny "Blocked: $p — writing inside .git/ is denied; use git commands instead."
      ;;
  esac
done <<< "$PATHS"

exit 0
