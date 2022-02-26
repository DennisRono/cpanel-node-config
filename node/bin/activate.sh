#!/bin/bash

# if [[ x"${BASH_SOURCE[0]}" == x"$0" ]]; then
#     echo "'activate' script should be sourced, not run directly"
#     exit 1;
# fi

CWD=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
NEW_VIRTUAL_ENV_PATH="${CWD%/bin}"

deactivate () {
    if [[ x"${BASH_SOURCE[0]}" == x"$0" ]]; then
        echo "'deactivate' script should be sourced, not run directly"
        exit 1;
    fi

    # Only restore from backup variables if they are set
    # But include the case when they are set to be empty
    if [[ ${BKP_PATH+"is_set"} == "is_set" ]]; then
        PATH="$BKP_PATH"
        export PATH
    fi

    if [[ ${BKP_NODE_PATH+"is_set"} == "is_set" ]]; then
        NODE_PATH="$BKP_NODE_PATH"
        export NODE_PATH
    fi

    if [[ ! -z $BKP_PS1 ]]; then
        PS1="$BKP_PS1"
        export PS1
    fi

    unset -v BKP_PATH
    unset -v BKP_NODE_PATH
    unset -v BKP_PS1
    unset -v CL_VIRTUAL_ENV
    unset -v CL_APP_ROOT
    unset -v CL_NODEHOME
    unset -v CL_NODEJS_VERSION

    if [ ! "${1-}" = "nondestructive" ] ; then
    # Self destruct!
        unset -f deactivate
    fi
}

activate () {
    CL_VIRTUAL_ENV="${NEW_VIRTUAL_ENV_PATH}"
    CL_NODEJS_VERSION="$(echo "${CL_VIRTUAL_ENV}" | awk -F '/' '{print $NF}')"
    CL_APP_ROOT="${CL_VIRTUAL_ENV#$HOME/nodevenv/}" # cut $HOME/nodevenv/
    CL_APP_ROOT="${CL_APP_ROOT%/$CL_NODEJS_VERSION}" # cut nodejs version
    CL_NODEHOME="/opt/alt/alt-nodejs${CL_NODEJS_VERSION}/root"
    BKP_NODE_PATH="$NODE_PATH"
    NODE_PATH="$CL_VIRTUAL_ENV/lib/node_modules:$CL_NODEHOME/lib/node_modules:$CL_NODEHOME/lib64/node_modules:$NODE_PATH"
    BKP_PATH="$PATH"
    PATH="$CL_VIRTUAL_ENV/bin:$CL_NODEHOME/usr/bin:$CL_VIRTUAL_ENV/lib/bin/:$PATH"

    if [[ -z "$CL_VIRTUAL_ENV_DISABLE_PROMPT" ]] ; then
        BKP_PS1="$PS1"
        PS1="[${CL_APP_ROOT} ($CL_NODEJS_VERSION)] $PS1"
    fi

    export BKP_PS1
    export BKP_PATH
    export BKP_NODE_PATH
    export PS1
    export CL_VIRTUAL_ENV
    export CL_APP_ROOT
    export CL_NODEHOME
    export NODE_PATH
    export PATH
}

# compare current virtual environment (that is stored in CL_VIRTUAL_ENV) path
# to the NEW_VIRTUAL_ENV_PATH, that is the path of the new environment we may enter too
# just do nothing if paths are equal
if [ "${CL_VIRTUAL_ENV}" != "${NEW_VIRTUAL_ENV_PATH}" ]; then
    deactivate nondestructive
    activate
fi
