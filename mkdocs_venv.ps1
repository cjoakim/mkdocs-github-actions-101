# Create a minimal python virtual environment for the purpose of running mkdocs.
# Chris Joakim, Microsoft

$dirs = ".\venv\", ".\pyvenv.cfg"
foreach ($d in $dirs) {
    if (Test-Path $d) {
        Write-Host "deleting $d"
        del $d -Force -Recurse
    } 
}

Write-Host 'creating new venv ...'
python -m venv .\venv\

Write-Host 'activating new venv ...'
.\venv\Scripts\Activate.ps1

Write-Host 'pip install mkdocs ...'
# https://pypi.org/project/mkdocs-material/
pip install mkdocs-material
pip install mkdocs-material[imaging]

pip list
