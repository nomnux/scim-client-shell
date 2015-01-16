#!/bin/sh

set -e

cd "`dirname "$0"`" || exit 1

PATH="$PATH:${PWD}"

atoken="xxxxx"
base_uri="http://scim-sv.example.jp"
user_uri="${base_uri}/Users"

## functions
## -------------------------------------------------------------------

print_usage() {
cat << __USAGE 1>&2
Usage
  ${0##*/} subcommand [-f json file] [username]

Sub Command
  add -f json_file   : add user.
  mod-put -f json_file username : mod user (Full update).
  mod-patch -f json_file username  : mod user (Partial update).
  getid username     : get user id.
  search username    : search user.
  list               : get all user list.
  del username       : delete user.

Options
   -f json_file : specify json file.

Arguments
   username : specify username.

__USAGE

exit 1
}

check_file() {
    if [ ! -f "$json_file" ]; then
        echo "No such file: $json_file"
        exit 1
    fi
}

my_curl() {
    curl \
      -D - \
      -sS \
      -H "Authorization: Bearer $atoken" \
      -H "Content-Type: application/scim+json" \
      -H "Accept: application/scim+json" \
      "$@"
}

my_curl_withoutheaders() {
    curl \
      -sS \
      -H "Authorization: Bearer $atoken" \
      -H "Content-Type: application/scim+json" \
      -H "Accept: application/scim+json" \
      "$@"
}

user_add() {
    check_file
    uri="$user_uri"
    my_curl \
      -X "POST" \
      -d "@$json_file" \
      "$uri"
}

user_search() {
    query="filter=userName%20eq%20$username"
    uri="$user_uri?$query"
    my_curl_withoutheaders "$uri" \
      -X "GET"
}

get_user_id() {
    user_search | ./parsrj.sh | ./unescj.sh \
    | grep '^\$.Resources\[0\].id ' | sed 's/^[^ ]* //'
}

user_del() {
    id=`get_user_id`
    uri="$user_uri/$id"
    my_curl  \
      -X "DELETE" \
      "$uri"
}

user_list() {
    uri="$user_uri"
    my_curl -X "GET" "$uri"
}

user_list_q() {
    query="attributes=userName"
    uri="$user_uri?$query"
    my_curl -X "GET" "$uri"
}

user_mod_patch() {
    # partial update
    check_file
    id=`get_user_id`
    uri="$user_uri/$id"
    my_curl \
      -X "PATCH" \
      -d "@$json_file" \
      "$uri"
}

user_mod_put() {
    # full update
    check_file
    id=`get_user_id`
    uri="$user_uri/$id"
    my_curl \
      -X "PUT" \
      -d "@$json_file" \
      "$uri"
}


## main
## -------------------------------------------------------------------


if [ $# = 0 ]; then
    print_usage
fi

subcmd="$1"
shift

while getopts f: opt
do
    case $opt in
        f)  json_file="$OPTARG"
            ;;
        \?) print_usage
            ;;
    esac
done
shift `expr $OPTIND - 1`

username="$1"

case "$subcmd" in
    add) user_add
         ;;
    mod-patch) user_mod_patch
         ;;
    mod-put) user_mod_put
         ;;
    search) user_search
         ;;
    getid) get_user_id
         ;;
    list) user_list
         ;;
    del) user_del
         ;;
    *)   print_usage
         ;;
esac

exit 0
