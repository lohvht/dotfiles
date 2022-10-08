# SSH Agent

Usually when an SSH agent is required, the easiest way is to run the following command

```bash
eval $(ssh-agent) > /dev/null
```

Which will go ahead and start an SSH agent such that `ssh-add` etc will store your passphrase for
your keys for every session.

Usually developers will just add the above command into their shell configuration.

However, with every new shell created, the above command will spawn a new agent, which is not ideal. Thankfully the
following tool written by `wwalker` can help us ensure that only 1 agent is spawned. The link is at https://github.com/wwalker/ssh-find-agent

The current script is taken using the following command

```bash
wget https://raw.githubusercontent.com/wwalker/ssh-find-agent/18805c9c331fb71c55456298a4a3906d1b098ff8/ssh-find-agent.sh
```
