# manage_ssh.sh

> scripts written by ChatGPT
> Use at your own risk

## INIT SSH SERVICE

``` bash
curl -sSL "https://raw.githubusercontent.com/harshsinghvi/manage_ssh.sh/master/run.sh" | bash -
```

## Import keys only

```bash
echo "# imported keys" >> $HOME/.ssh/authorized_keys; curl -sSL "https://github.com/harshsinghvi.keys" | tee -a $HOME/.ssh/authorized_keys
```
