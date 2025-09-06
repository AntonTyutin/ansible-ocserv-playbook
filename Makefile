container = docker compose run --rm ansible
galaxy = $(container) ansible-galaxy
play = $(container) ansible-playbook

.shell_history:
	touch .shell_history

vendor: .shell_history
	$(galaxy) install -r requirements.yml
.PHONY: vendor

shell: .shell_history
	$(container) bash
.PHONY: shell

play: vendor
	$(play) playbook.yml --vault-pass-file=get-vault-pass-env.sh
.PHONY: play

dry-run: vendor
	$(play) playbook.yml --vault-pass-file=get-vault-pass-env.sh --check
.PHONY: dry-run
