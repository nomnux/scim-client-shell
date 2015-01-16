# scim-client-shell

Simple Shell SCIM Client.

## Requirements
This shell script needs these shell scripts.

 * parsrj.sh
   * https://github.com/ShellShoccar-jpn/Parsrs/blob/master/parsrj.sh
 * unescj.sh
   * https://github.com/ShellShoccar-jpn/Parsrs/blob/master/unescj.sh

## Usage

add user

    user.sh add -f user.json

modify user (Full update)

    user.sh mod-put -f user.json username

modify user (Partial update)

    user.sh mod-patch -f user.json username

search user

    user.sh search username

get user id

    user.sh getid username

get all user

    user.sh list

delete user

    user.sh del username

