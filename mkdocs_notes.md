# mkdocs notes

## links

- https://www.mkdocs.org/

- https://github.com/mkdocs-material

- Solliance PostgreSQL Solution Accelerator
  - [Repo](https://github.com/solliancenet/microsoft-postgresql-solution-accelerator-build-your-own-ai-copilot)
  - [Workshop](https://github.com/solliancenet/microsoft-postgresql-solution-accelerator-build-your-own-ai-copilot/tree/main/docs/workshop)
  - [mkdocs.yml](https://github.com/solliancenet/microsoft-postgresql-solution-accelerator-build-your-own-ai-copilot/blob/main/docs/workshop/mkdocs.yml)
- James Willett Video and GitHub
  - [How To Create STUNNING Code Documentation With MkDocs Material Theme](https://www.bing.com/videos/riverview/relatedvideo?q=mkdocs+tutorial+&mid=3759D0CDB79060AAF66A3759D0CDB79060AAF66A&FORM=VIRE)
  - https://github.com/james-willett
  - https://github.com/james-willett/mkdocs-material-youtube-tutorial


## help info

```
(venv) PS ...\docs> mkdocs
Usage: mkdocs [OPTIONS] COMMAND [ARGS]...

  MkDocs - Project documentation with Markdown.

Options:
  -V, --version         Show the version and exit.
  -q, --quiet           Silence warnings
  -v, --verbose         Enable verbose output
  --color / --no-color  Force enable or disable color and wrapping for the output. Default is auto-detect.
  -h, --help            Show this message and exit.

Commands:
  build      Build the MkDocs documentation.
  get-deps   Show required PyPI packages inferred from plugins in mkdocs.yml.
  gh-deploy  Deploy your documentation to GitHub Pages.
  new        Create a new MkDocs project.
  serve      Run the builtin development server.
(venv) PS ...\docs>
```

```
(venv) PS ...\docs> mkdocs new --help
Usage: mkdocs new [OPTIONS] PROJECT_DIRECTORY

  Create a new MkDocs project.

Options:
  -q, --quiet    Silence warnings
  -v, --verbose  Enable verbose output
  -h, --help     Show this message and exit.
(venv) PS ...\docs>
```

## bootstrapping this project

### Create the Python Virtual environment and install mkdocs-material

```
docs> .\venv.ps1

- or -

docs> python -m venv .\venv\
docs> .\venv\Scripts\Activate.ps1
docs> pip install mkdocs-material
docs> pip list
```

### Create the mkdocs project 

```
(venv) PS ...\docs> mkdocs new .
INFO    -  Writing config file: .\mkdocs.yml
INFO    -  Writing initial docs: .\docs\index.md
(venv) PS ...\docs>
```

### James Willett Video and GitHub

See the above video and GitHub project.

- https://www.youtube.com/watch?v=Q-YA_dA8C20&t=281s
