Requirements:
[link](https://www.vagrantup.com/downloads.html "Vagrant - >= 1.8.5")
[link](https://www.virtualbox.org/wiki/Downloads "oracle virtualbox")
  Run `vboxmanage hostonlyif ipconfig vboxnet0 --ip 33.33.33.1` - to set up internal IP networking
  (33.33.33.0/24 is a DoD never routed segment, used to avoid LAN conflicts for host-only-interfacing)
  
Run `vagrant up` in this directory


pending "puppet" node creation:
  `ssh git@33.33.33.200` - to get a list of repositories you have access to on the gitserver.

~~~

tommi@blackgronk:~/projects/vagrant/jppol-r10k$ ssh git@33.33.33.200
PTY allocation request failed on channel 0
hello admin_tlj, this is git@puppet running gitolite3 3.6.4-1 (Debian) on git 2.7.4

 R W    gitolite-admin
 R W    localpuppet
 R W    testing
Connection to 33.33.33.200 closed.

~~~


gitolite-admin is the git-server configuration - yes, the git-server is controlled via git. 
  Syntax should be fairly self-explanatory.
  See conf/gitolite.conf for general, simplistic config  
  users are defined by a public key named ${username}.pub
  *Your username is always git!* (the user mapping is done by the forced ssh script - see git->admin_tlj user mapping in the example above)

The "localpuppet" repository is the location of the puppet manifest the "puppet" node runs on.
It uses a hook trigger r10k builds for a specific branch each time it is pushed:

~~~
repo localpuppet
    RW+     =   @admin vagrant
    R       =   @rousers
    option hook.post-receive = r10k_env.sh
~~~

To get started, pending vagrant up:

Clone the localpuppet repository:
~~~
tommi@blackgronk:~/what-is-this-vagrant-thingy$ git clone git@33.33.33.200:localpuppet
Cloning into 'localpuppet'...
remote: Counting objects: 371, done.
remote: Compressing objects: 100% (241/241), done.
remote: Total 371 (delta 64), reused 371 (delta 64)
Receiving objects: 100% (371/371), 33.96 KiB | 0 bytes/s, done.
Resolving deltas: 100% (64/64), done.
Checking connectivity... done.
warning: remote HEAD refers to nonexistent ref, unable to checkout.

tommi@blackgronk:~/what-is-this-vagrant-thingy$ 
tommi@blackgronk:~/what-is-this-vagrant-thingy$ cd localpuppet/

tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ ls
<nothing>
~~~ 

How come it's empty?
It has no master branch, which is the default in git, hence the "remote HEAD refers to nonexistent ref, unable to checkout."  - warning.

seeing as we want a branch -> environment mapping, and we have no "master" environment..........

~~~
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git branch -a
  remotes/origin/testing
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git checkout testing
Branch testing set up to track remote branch testing from origin.
Switched to a new branch 'testing'
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ ls
maifests  Puppetfile  readme-testing
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ 
~~~
There we go.

To get cracking, simply make changes to any part of the repository, commit it, and push it (to the branch/environment you want to build).

Example:
~~~

tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ vim Puppetfile 
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git diff
diff --git a/Puppetfile b/Puppetfile
index 91ac692..33af04d 100644
--- a/Puppetfile
+++ b/Puppetfile
@@ -4,3 +4,4 @@ mod 'richardc-datacat', "0.6.1"
 mod 'puppetlabs-stdlib'
 mod 'puppetlabs-apt'
 mod 'puppetlabs-motd'
+mod 'puppetlabs-nginx'

tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git add Puppetfile  <----- stage "Puppetfile" to commit
tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git status <----- see status
On branch testing
Your branch is up-to-date with 'origin/testing'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        modified:   Puppetfile <----- looks good, let's commit it.

tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git commit <----- launches commit editor (yes, you can do commandline comments similar to svn, but start here)
[testing 9147e3e] Testingtestingtesting
 1 file changed, 1 insertion(+) <------- now it's committed. But as git is a distributed revisioning system, it's only committed locally. To trigger manifest rebuild, it has to be pushed:

tommi@blackgronk:~/what-is-this-vagrant-thingy/localpuppet$ git push
warning: push.default is unset; its implicit value has changed in
Git 2.0 from 'matching' to 'simple'. To squelch this message
and maintain the traditional behavior, use:

  git config --global push.default matching

To squelch this message and adopt the new behavior now, use:

  git config --global push.default simple

When push.default is set to 'matching', git will push local branches
to the remote branches that already exist with the same name.

Since Git 2.0, Git defaults to the more conservative 'simple'
behavior, which only pushes the current branch to the corresponding
remote branch that 'git pull' uses to update the current branch.

See 'git help config' and search for 'push.default' for further information.
(the 'simple' mode was introduced in Git 1.7.11. Use the similar mode
'current' instead of 'simple' if you sometimes use older versions of Git)

Counting objects: 3, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 371 bytes | 0 bytes/s, done.
Total 3 (delta 1), reused 0 (delta 0)
remote: 
remote: oldrev:7e0661fc394c346e02eff9f69455ccae3e90084d newrev:9147e3eb50b31539ff33b261855dd458e7299581 refname:refs/heads/testing
remote: r10k updating testing environment and modules 
remote: /usr/local/bin/r10k deploy environment testing -p <------- debug information for now
To git@33.33.33.200:localpuppet
   7e0661f..9147e3e  testing -> testing

~~~

Automatic triggering of puppet run is not built into this PoC, but is easily administered by:
`vagrant provision <node>`

Note that for now, the environment is defined in the Vagrantfile as a parameter (--environment testing)


Have fnu!
