# prm
[![travis][travis-image]][travis-url]
[![license][license-image]][license-url]
[![gitter][gitter-image]][gitter-url]
[travis-image]: https://api.travis-ci.org/eivind88/prm.svg
[travis-url]: https://travis-ci.org/eivind88/prm
[license-image]: http://img.shields.io/badge/license-BSD3-brightgreen.svg
[license-url]: https://github.com/eivind88/prm/blob/master/LICENSE.txt
[gitter-image]: https://img.shields.io/badge/gitter-join%20chat-brightgreen.svg
[gitter-url]: https://gitter.im/eivind88/prm

A minimal project manager for the terminal.

![Demo](https://github.com/eivind88/prm/blob/demo/prm.gif)

This script **must** be sourced, *not* run in a subshell.
The technical reason for this is succinctly explained in [this](https://en.wikipedia.org/wiki/Source_(command)) Wikipedia article.
See [usage](#usage) for more information.

At present, prm supports `zsh`, as well as `bash`.
For more information, see the [Wiki page on Zsh support](https://github.com/eivind88/prm/wiki/Zsh-support).

Ostensibly, prm also [works](https://github.com/eivind88/prm/issues/27) under [Cygwin](https://cygwin.com).

Regrettably, `fish` is not supported, because of syntax incompatibilities.
See [this issue](https://github.com/eivind88/prm/issues/2) for some details.
However, Fred Deschenes has made a [port](https://github.com/FredDeschenes/prm-fish) for `fish` that you could check out.

## What?
This program basically lets you CRUD projects. Upon activation, each projects runs its associated start-script; on deactivation, it runs the project stop-script.

These bash-scripts can be used for things like changing directories, setting environment variables, cleanup, etc.

There is basic prompt integration in the form of `[PROJECT] <prompt>`, which can be seen in the animated .gif demo above.

You can have several projects active at once in different shells, as prm associates active instances with the shell PID.
Currently active projects can be listed (as described in [usage](#usage)).

Dead project instances (i.e. project instances that are still active on shell exit) will be automatically deactivated the next time you run prm – without running their stop-scripts.

For the motivation behind prm, please see the [Wiki page on Problem Statements and Design Goals](https://github.com/eivind88/prm/wiki/Problem-Statements-and-Design-Goals).

## How?
Adding and editing projects will open the associated start- and stop-scripts in your editor (as defined by the `$EDITOR` environment variable).

A project start-script might for instance look something like this:

```bash
# cd to project directory
cd $HOME/src/Python/hello-world

# activate conda env
source activate hello-world

# show current git status
git status
```

The same project's stop-script might look like this:

```bash
# deactivate conda env
source deactivate hello-world

# clean up
rm *.log *.tmp
```

When you activate a new project, prm automatically stops any active project in the current shell.

When a project is deactivated, prm changes the working directory back to the path you were originally on before starting your first project.

### Reusability
If you often create projects similar to one you already have, you can load custom scripts from your projects' `start.sh` and `stop.sh`.
For instance, if you'd like some python-based projects to list the number of outdated packages in their conda envs, you can save

```bash
# count outdated packages in conda env
echo "$((($(conda search --outdated --names-only | wc -l)-1))) outdated packages in env"
```

as e.g. `conda-list-outdated.sh` in `$PRM_PATH/.common/` (this environment variable is detailed in [usage](#usage)).
You can then load this script in your start- and stop-scripts like so:

```bash
prm_load conda-list-outdated
```

Additionally, if you need the name of the currently active project, this is available via the `$PRM_ACTIVE_PROJECT` environment variable.

The prm command line arguments are available in start- and stop-scripts, `$3` being the first argument after your project name.

All available environment variables are described on [this](https://github.com/eivind88/prm/wiki/Environment-variables) Wiki page.

## Usage
In order to work properly, prm **must** be sourced, *not* run in a subshell; i.e. `. ./prm`.

The easiest way to do this is probably to add an alias to prm in your `~/.bashrc` (or wherever you keep your aliases), like so:

```bash
alias prm=". path/to/prm.sh"
```

From the help option screen:

```bash
usage: prm <option> [<args>] ...

Options:
  active                   List active project instances.
  add <project name>       Add project(s).
  copy <old> <new>         Copy project.
  edit <project name>      Edit project(s).
  list                     List all projects.
  remove <project name>    Remove project(s).
  rename <old> <new>       Rename project.
  start <project name>     Start project.
  stop                     Stop active project.
  -h --help                Display this information.
  -v --version             Display version info.
```

You can set the prm data directory with the `$PRM_PATH` environment variable.
By default all prm data is written to `~/.prm`.

### Shell completions
You can install shell completions by running `bash completions/deploy_completions.sh` from the project root.
Only `bash` is supported for now, but `zsh` completions are under development.

## Contributing
Feedback is strongly encouraged. If you run into a bug or would like to see a new feature, please open a new issue. In the case of bugs, please mention what shell they occur under (i.e. `bash` or `zsh`).

Contributions in the form of code (e.g. implementing new features, bug-fixes) are also appreciated. For information about this, see the [Wiki page on Contributing](https://github.com/eivind88/prm/wiki/Contributing).

Pull requests that do not pass the CI [tests](https://github.com/eivind88/prm/wiki/Contributing/_edit#tests) will not be merged.

## License
This software is released under the terms of the 3-clause New BSD License. See the [license](LICENSE.txt) file for details.
