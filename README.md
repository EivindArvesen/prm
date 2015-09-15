# prm
A minimal project manager for the terminal.

## What?
This program basically lets you CRUD projects. Upon activation, each projects runs its associated start-script; on deactivation, it runs the project stop-script.

These bash-scripts can be used for e.g. changing directories, setting environment variables, cleanup, etc.

### Example
One of my project start-script might for instance look something like this:

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
source deactivate

# clean up
rm *.log *.tmp
```

The program automatically stops any active projects when you activate a new one.
When you deactivate your project, the program cd-s to the path you were originally on before starting your first project.

## Why?
I found myself missing project management features (like those seen in text editors and IDEs) on the terminal.

## Usage
From help option:

```bash
Usage: prm.sh [options] ...
Options:
  add <project name>       Add project
  edit <project name>      Edit project
  list                     List all projects
  remove <project name>    Remove project
  start <project name>     Start project
  stop                     Stop active project
  -h --help                Display this information.
  -v --version             Display version info.
```

## License
This software is released under the terms of the 3-clause New BSD License. See the [license](LICENSE.txt) file for details.
