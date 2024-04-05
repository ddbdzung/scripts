# There are a few useful shell scripts

Platform: Ubuntu OS > 16.x

1. make-ssh.sh
<br />
Run the script, it'll make a ssh key, save it to default directory and maybe copy to clipboard
<br />

How to run:

```
bash make-ssh.sh
```

2. clone-group-gitlab.sh
<br />
Run the script, it'll clone all the projects in a group from gitlab
<br />

How to run:

```
bash clone-group-gitlab.sh
```

3. Rename all remote url in a directory to a new url (useful when you want to change the remote url of all git projects in a directory)
<br />
Run the script, it'll rename all remote urls in a directory to a new url
<br />
Example about host in config file (~/.ssh/config):
<br />

```
Host github-personal
  HostName erp.github.com
  IdentityFile ~/.ssh/id_rsa
  User "Dung Dang Duc Bao"
```
Host will be github.com
<br />
Example about directory tree:
<div>
    <div>
        /erp-group-example
    </div>
    <div>
        <div>
            &nbsp; /project1
        </div>
        <div>
            &nbsp; /project2
        </div>
        <div>
            &nbsp; /project3
        </div>
        <div>
            &nbsp; rename-all-remote-url.sh
        </div>
    </div>
</div>

```
cd /erp-group-example
bash rename-all-remote-url.sh github-personal
```

<br />
