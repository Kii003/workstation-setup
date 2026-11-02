# .env template that references secrets in 1Password instead of containing them.
#
# Copy into a project as .env.tpl — it is safe to commit (references only, no values).
# Generate the real .env with:   envgen          (shell function from the zshrc)
#                       or:      op inject -i .env.tpl -o .env
#
# Reference format: op://<vault>/<item>/<field>
# Get one in 1Password: open the item → click ▾ next to a field → "Copy Secret Reference".

DATABASE_URL=op://Dev/My Project Database/connection string
API_KEY=op://Dev/Some API/credential
PUBLIC_SETTING=not-a-secret-can-stay-plain
