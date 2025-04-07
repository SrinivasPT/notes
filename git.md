## Sets the name you want attached to your commit transactions

$ git config --global user.name "[name]"

## Sets the email you want attached to your commit transactions

$ git config --global user.email "[email address]"

## Generate SSH Keys for Both Accounts

You will need a separate SSH key for each GitHub account.

Generate the first SSH key for Account 1:
ssh-keygen -t ed25519 -C "account1@example.com"

Save the key as ~/.ssh/id_ed25519_account1 when prompted.

Generate the second SSH key for Account 2:
ssh-keygen -t ed25519 -C "account2@example.com"

Save the key as ~/.ssh/id_ed25519_account2.

## Add SSH Keys to the SSH Agent

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_ed25519_account1
ssh-add ~/.ssh/id_ed25519_account2

## Add SSH Keys to Your GitHub Accounts

Copy the public keys to your clipboard:
For Account 1
cat ~/.ssh/id_ed25519_account1.pub

For Account 2
cat ~/.ssh/id_ed25519_account2.pub

## Configure SSH Config File

Open or create the ~/.ssh/config file:

Add the following configuration:

##### Account 1

Host github-account1
HostName github.com
User git
IdentityFile ~/.ssh/id_ed25519_account1

##### Account 2

Host github-account2
HostName github.com
User git
IdentityFile ~/.ssh/id_ed25519_account2

## Clone Repositories Using the Correct Host

For Account 1, use
git clone git@github-account1:username/repository.git

For Account 2, use:
git clone git@github-account2:username/repository.git

## Configure Git User for Each Repository

For Account 1
git config user.name "Your Account 1 Name"
git config user.email "account1@example.com"
git clone git@srini:srinivaspt/underwriter.git


-----------------
git config user.name "Srinivas Peeta"
git config user.email "srinivaspt@outlook.com"
git clone git@srini:srinivaspt/horizon-scanning.git
------------------

For Account 2
git config user.name "Your Account 2 Name"
git config user.email "account2@example.com"

## Verify Everything Works

git push
git log

## Final Notes

With this setup:

You can work on repositories from both accounts without switching or logging in and out.
The SSH config automatically uses the correct key for each account.
You set the Git user details per repository, so commits are attributed correctly.

## Cloing

git clone git@github-account1:<<repo account>>/<<repo name>>
