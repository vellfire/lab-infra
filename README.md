# lab-infra

## Spinning up environment

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
cd ansible
ansible-galaxy collection install -r requirements.yml && ansible-galaxy role install -r requirements.yml
```
