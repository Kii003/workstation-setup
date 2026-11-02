# Installation guide

Step by step, from "I have a GitHub account" to a fully set-up computer. Two ways:

- **[A · Let Claude do it](#a--let-claude-do-it)** — install Claude Code, paste one prompt, Claude walks you through everything and runs the commands with your approval. Recommended if you have a Claude subscription.
- **[B · Do it yourself](#b--do-it-yourself-macos)** — the same steps by hand.

Both take 45–60 minutes, most of it unattended downloading.

**What you need**
- A GitHub account
- A Mac (Apple Silicon or Intel) or a Windows 10/11 PC, signed in as an administrator account
- ~20 GB free disk space, power cable plugged in
- Your computer password (asked once or twice)
- For anything Claude-related: a Claude subscription (Pro or higher)

**What it changes on your computer** — installs apps and command-line tools, links config files into your home folder (existing ones are moved to `~/.workstation-setup-backup/`, never deleted), creates `~/Claude`, and applies some system settings (Finder/Explorer shows file extensions and hidden files, Dock auto-hides, fast key repeat, screenshots go to a folder). Every part can be switched off in the config file.

---

## Step 1 · Make your own copy (both ways)

1. Open https://github.com/Kii003/workstation-setup
2. Click the green **Use this template** button (top right) → **Create a new repository**
3. Name it e.g. `workstation-setup`, choose **Private** (your settings and skills go in here) → **Create repository**

## Step 2 · Personalize (in the browser, both ways)

In **your** new repository:

**macOS:** open `macos/config.sh` → click the pencil icon (top right of the file) and edit:

| Setting | What to put |
|---|---|
| `GIT_NAME` | your name |
| `GIT_EMAIL` | the email of your GitHub account (or GitHub's private `…@users.noreply.github.com` address) |
| `GIT_ALT_EMAIL` | leave empty — only for a second identity (e.g. work vs. private) |
| `BREW_MODULES` | which app groups to install. See `macos/brew/*.Brewfile` — delete lines for apps you don't want |
| `APPLY_MACOS_DEFAULTS` | `false` if you don't want Finder/Dock/keyboard settings changed |
| `INSTALL_CLAUDE_CODE`, `INSTALL_WORKSPACE` | `false` if you don't use Claude Code |

**Windows:** same idea in `windows/config.ps1` and `windows/apps/*.txt`.

No password manager or not 1Password? Delete the two 1Password lines in `macos/brew/core.Brewfile` (Windows: `windows/apps/core.txt`).

Click **Commit changes**.

## Step 3 · Access token for your private repository (both ways)

A private repository needs a key to be downloaded on a fresh computer:

1. GitHub → your profile picture (top right) → **Settings** → **Developer settings** (bottom left) → **Personal access tokens** → **Fine-grained tokens** → **Generate new token**
2. Name: `workstation setup` · Expiration: 7 days · **Repository access:** *Only select repositories* → your `workstation-setup` · **Permissions → Contents:** Read-only
3. **Generate token** and copy it somewhere for the next 10 minutes — it's shown only once

Later the setup signs you in properly (`gh auth login`), so the token is only needed once.

*Shortcut without a token:* on your repository page click **Code → Download ZIP**, unzip it to `~/code/workstation-setup`, and skip the `git clone` step. Works the same, but the folder isn't connected to GitHub, so you can't push changes back later.

---

## A · Let Claude do it

**macOS:** open **Terminal** (Cmd + Space → type "Terminal" → Enter) and install Claude Code with the official installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Close Terminal, open it again, then:

```bash
mkdir -p ~/code && cd ~/code && claude
```

**Windows:** open **PowerShell** (Start → "PowerShell", *not* as administrator):

```powershell
irm https://claude.ai/install.ps1 | iex
```

Close and reopen PowerShell, then `mkdir ~\code; cd ~\code; claude`.

Sign in to Claude when asked. Then paste this prompt (replace the two placeholders):

```text
Set up this computer with my workstation-setup repository.
Follow https://github.com/Kii003/workstation-setup/blob/main/INSTALL.md exactly,
including the section "Rules for AI assistants".
My repository: https://github.com/<MY-USERNAME>/<MY-REPO>
Explain each step in one or two sentences before you run it, in German.
```

(Change "in German" to your language.) Claude will tell you when you need to click something, type your password, or paste the token from Step 3.

---

## B · Do it yourself (macOS)

**B1 · Command line tools** — in Terminal:

```bash
xcode-select --install
```

A window opens → **Install** → wait until it's done (a few minutes). This brings `git`.

**B2 · Download your repository**

```bash
mkdir -p ~/code && cd ~/code
git clone https://github.com/<MY-USERNAME>/<MY-REPO>.git workstation-setup
```

- *Username:* your GitHub username
- *Password:* paste the **token** from Step 3 (not your GitHub password). You won't see characters while pasting — that's normal. Press Enter.

**B3 · Preview, then run**

```bash
cd ~/code/workstation-setup/macos
./setup.sh --dry-run
```

This only prints what would happen. If it looks right:

```bash
./setup.sh
```

- It asks for your **Mac password** at the start (Homebrew). Stay close for the first few minutes — some apps ask again while installing.
- Then it runs on its own (20–60 minutes, mostly downloads).
- At the end you get a summary. Anything under **Failed:** → fix or skip it and run `./setup.sh` again; finished steps are skipped. Single steps: `./setup.sh brew`, `./setup.sh claude` …

**Windows (by hand):** in PowerShell (not as administrator):

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/Kii003/workstation-setup/main/windows/bootstrap.ps1))) -Repo https://github.com/<MY-USERNAME>/<MY-REPO>
```

It installs Git, clones your repository (a GitHub sign-in window opens), and starts the setup. Accept the one administrator prompt (UAC) after a few seconds. Details: [`windows/README.md`](windows/README.md).

---

## Step 4 · After the script (≈15 minutes, both ways)

1. **New terminal.** macOS: close Terminal, open **Ghostty**. Windows: open **Windows Terminal** (PowerShell 7 is now the default). The new shell config loads.
2. **Password manager.** 1Password: open the app, sign in, Settings → Developer → *Integrate with 1Password CLI*, then in the terminal: `op signin`.
3. **GitHub:** `gh auth login` → GitHub.com → HTTPS → *Login with a web browser*. From now on no token is needed; you can delete the one from Step 3.
4. **Claude Code:** `claude` → sign in → type `/plugin` and check that `mattpocock-skills` is enabled → `/doctor` for a full checkup.
5. **Secret protection test:** `bash ~/.claude/hooks/test-protect-files.sh` (Windows: in **Git Bash**). Must end with `failed: 0`.
6. **Apps:** sign in to your apps; allow permissions when macOS/Windows asks (Accessibility for Raycast/AltTab, Microphone for dictation and meeting apps).
7. **Your workspace:** open `~/Claude/CLAUDE.md` and the two world files (`10_Work/CLAUDE.md`, `20_Private/CLAUDE.md`) and fill in your accounts. Explained in [`shared/workspace/README.md`](shared/workspace/README.md).

## Step 5 · First use

```bash
p                                                   # jump to ~/Claude
new-project 20_Private/80_Labs my-first-idea "what it is"
cd ~/Claude/20_Private/80_Labs/my-first-idea
claude                                              # start working; say "wrap up" at the end
```

Handy: `ll` (list files) · `gs` (git status) · `c` / `cc` (Claude new / continue) · `Ctrl+R` (search command history) · `kb` (knowledge base, open it in Obsidian as a vault).

## Troubleshooting

| Problem | Fix |
|---|---|
| `git clone` says authentication failed | use the token, not your password; token must include your repository with Contents: Read |
| "command not found: brew / claude" right after the script | open a new terminal window |
| An app failed to install | it's listed under **Failed:** — remove it from the Brewfile/app list or install it manually, re-run the script |
| Claude Code blocks every file read | the protection hook can't run — run the test in Step 4.5 and check `jq` is installed (`brew install jq`) |
| Something else | open an issue on https://github.com/Kii003/workstation-setup/issues with the summary output |

---

## Rules for AI assistants

If you are an AI assistant (Claude Code or similar) asked to perform this installation for a user, follow these rules:

1. **Explain, then act.** Before each command, say in one or two sentences what it does. Wait for the user's confirmation before anything that installs software, changes system settings, or asks for a password.
2. **Order.** Step 1–3 happen in the user's browser — guide them, don't attempt them yourself. Then B1 → B2 → B3 (macOS) or the Windows bootstrap command, then Step 4. Always run `./setup.sh --dry-run` before `./setup.sh` and show the user the summary.
3. **Never handle secrets.** Never ask the user to paste the GitHub token, passwords or the 1Password Secret Key into the chat. Commands that need them (`git clone`, `sudo`, `op signin`) are run by the user in a **second terminal window** — tell them exactly what to type and wait until they confirm it worked. (Password prompts don't work inside the assistant's own shell.) The ZIP shortcut from Step 3 avoids the token entirely; offer it if cloning gets stuck. Do not read `.env` files or anything in `_secrets/`.
4. **Interactive prompts.** `xcode-select --install`, the Homebrew installer (password) and macOS permission dialogs need the user. Tell them what will appear and wait.
5. **Long runs.** `./setup.sh` takes 20–60 minutes. Ask the user to run it in their own terminal (or run it with a long timeout); then read the summary with them.
6. **Failures.** For each item under **Failed:**, explain the cause, propose a fix (usually: remove or correct a line in a Brewfile / app list, or retry), and re-run only the affected step (`./setup.sh <step>`).
7. **Don't improvise beyond the guide.** No extra tools, no deleting files, no changes to the user's repository unless they ask. If something in the guide doesn't match what you see, stop and tell the user.
8. **Finish with Step 4 and 5** and a short summary: what's installed, what failed, what the user still needs to do by hand.
