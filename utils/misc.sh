#######################################
# Returns flag indicating wheter a value is numerical or not.
# Arguments:
#   Argument value.
#######################################
function get_is_numeric()
{
    local ARG_VAL=${1}

    case $ARG_VAL in
        ''|*[!0-9]*) echo false ;;
        *) echo true ;;
    esac
}
