[![Build Status](https://travis-ci.org/SimonBaeumer/sync-monorepo.svg?branch=master)](https://travis-ci.org/SimonBaeumer/sync-monorepo)

# Syncing monorepo into subtree repositories

Sync a monolithic repository into multiple standalone subtree repositories.

## Dependencies

- bash
- git
- [splitsh-lite](https://github.com/splitsh/lite)

## Usage

```bash
./sync.sh [branch] [origin] [path-to-repos]
```

## Example

`$ ./sync.sh master git@github.com:SimonBaeumer/sync-monorepo.git repos`

### Terminal

```bash
./sync.sh master git@github.com:SimonBaeumer repos/
```

**Note:** `git rev-parse --abbrev-ref HEAD` returns the current branch

### Travis

### Create ssh-keys

1. `ssh-keygen -t rsa -b 4096 -C "<your_email>" -f github_deploy_key -N ''`
2. Add the `github_deploy_key.pub` with `write_access` as a deploy key to your synced repo
3. Add the `github_deploy_key` as an encrypted environment variable to your monorepo ([tutorial](https://github.com/alrra/travis-scripts/blob/master/docs/github-deploy-keys.md))

However, there is an "issue" with travis that you need a new deploy key for every repository you want to sync.

### GitLab

to be done