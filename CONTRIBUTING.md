# Contributing 101

## Quick start

### 1. Clone the repo

```bash
git clone https://github.com/studyappreco/reco.git
cd reco
```

If you already cloned it earlier, update before starting work:

```bash
git pull
```

### 2. Create new branch

```bash
git checkout -b feat/<short-description>
```
Let's try to follow the convention below:
- `feat` for new features
- `docs` for docs
- `fix` for bugfixes
- `exp` for anything experimental

E.g., `feat/14-architecture`

### 3. Make changes and commit

```bash
git add .
git commit  --signoff -m "A good description of the commit"
```
If you don't like signing off, just do:

```bash
git commit -m "A good description of the commit"
```

### 4. Push your branch
```
git push feat/<short-description>
```

### 5. Open a PR

- Open a PR from your branch into `main`
- Assign yourself
- Link the related issue
- Add a good PR description 
- Ensure CI passes


### 6. Closing a PR

- Never delete branches
