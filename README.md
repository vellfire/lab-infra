# lab-infra

## Spinning up environment

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
cd ansible
ansible-galaxy install -r requirements.yml
```
