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

### Terminal

```bash
./sync.sh master git@github.com:SimonBaeumer repos/
```

**Note:** `git rev-parse --abbrev-ref HEAD` returns the current branch

### Travis

See [.travis.yml](.travis.yaml)


### GitLab

to be done