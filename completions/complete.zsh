#compdef prm

local curcontext="$curcontext" state line ret=1

project_list=($(prm list | tr "\n" " "))

_arguments -C \
  '1: :->cmds' \
  '2:: :->projects' \
  '3:: :->projects2' && ret=0

case $state in
  cmds)
    _values "prm command" \
      "active[List active project instances.]" \
      "add[Add project(s).]" \
      "copy[Copy project.]" \
      "edit[Edit project(s).]" \
      "list[List all projects.]" \
      "remove[Remove project(s).]" \
      "rename[Rename project.]" \
      "start[Start project.]" \
      "stop[Stop active project.]"
    _arguments \
      '(-h)--help[Display usage information.]' \
      '(--version)--version[Display version info.]'
    ret=0
    ;;
  projects)
    case $line[1] in
      (copy|edit|remove|rename|start)
        _values 'projects' $project_list
        ret=0
        ;;
    esac
    ;;
  projects2)
    case $line[1] in
      (copy|edit|remove|rename)
        _values 'projects' $project_list
        ret=0
        ;;
    esac
    ;;
esac

return ret
