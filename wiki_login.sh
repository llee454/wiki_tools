# This is a simple script that logs into remote
# MediaWiki sites using cURL and returns both a
# cookie containing a valid session ID and a valid
# login token.

# I. Parse commandline arguments - get the URL,
#    username, password, and cookie jar file.

getopt --quiet-output --options 'h,v,f:,l:,u:,p:' --longoptions 'help,verbose,file:,url:,username:,password:' -- "$@" 
if [ $? != 0 ]
then
  echo 'Error: Invalid commandline.'
  exit 1
fi

verbose=false

while true
do
  case "$1" in
    -h | --help )
      cat <<EOF
Usage: wiki_login.sh [OPTIONS] --file COOKIEJARFILE --url URL
         --user USER --password PASSWORD

wiki_login.sh uses cURL to log into MediaWiki sites and returns a
valid session cookie and login token for other cURL-based scripts
to use.

The command requires four arguments: file, a path to a cURL cookie
jar file; url, a MediaWiki API endpoint URL (../api.php); user,
the username of an account on the MediaWiki site that has read
privileges; and password, the account password.

The command will log into the MediaWiki site at url using user and
password, store the session cookie in file, and return the login
token via STDOUT.

Options:

  -h | --help              Displays this message.
  -f | --file              A cURL cookie jar file path.
  -u | --user USER         The account username.
  -p | --password PASSWORD The account password.
  -v | --verbose           Enables verbose output.

Examples:

  wiki_login.sh --file cookies.txt --url http://wikipedia.org/api.php \\
    --user example_user --password example_password

  Will log into Wikipedia as example_user, store the session cookie
  in cookies.txt, and print the login token to STDOUT.

Author:

* Larry D. Lee jr. <llee454@gmail.com>
EOF
      exit 0 ;;
    -v | --verbose ) verbose=true; shift ;;
    -f | --file ) file=$2; shift 2 ;;
    -l | --url ) url=$2; shift 2 ;;
    -u | --user ) username=$2; shift 2 ;;
    -p | --password ) password=$2; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ -z "$file" ]
then
  echo 'Error: Invalid commandline. The --file parameter is required.'
  exit 1
fi
if [ -z "$url" ]
then
  echo 'Error: Invalid commandline. The --url parameter is required.'
  exit 1
fi
if [ -z "$username" ]
then
  echo 'Error: Invalid commandline. The --user parameter is required.'
  exit 1
fi
if [ -z "$password" ]
then
  echo 'Error: Invalid commandline. The --password parameter is required.'
  exit 1
fi

if $verbose
then
  echo 'cookie jar file: "'$file'"'
  echo 'url: "'$url'"'
  echo 'username: "'$username'"'
  echo 'password: "'$password'"'
fi

# II. Get Token
token=$(curl --silent --cookie $file --cookie-jar $file -X POST --data 'action=login' --data "lgname=$username" --data "lgpassword=$password" --data 'format=xml' $url | sed -E 's/.*token="([^"]*)".*/\1/')

# III. Login with Token and store session ID in cookie jar.
curl --silent --cookie $file --cookie-jar $file -X POST --data 'action=login' --data "lgname=$username" --data "lgpassword=$password" --data 'format=xml' --data "lgtoken=$token" $url 1> /dev/null

# IV. Output Login Token
if $verbose
then
  echo 'token: "'$token'"'
else
  echo $token
fi
