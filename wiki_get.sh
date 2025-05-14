# This is a simple script that reads pages from
# MediaWiki sites.

# I. Get the parameters.

getopt --quiet-output --options 'h,v,l:,u:,p:,t:' --longoptions 'help,verbose,url:,username:,password:,title:' -- "$@"
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
      cat <<-EOF
Usage: wiki_get.sh [OPTIONS] --url URL --user USER
         --password PASSWORD --title TITLE'

wiki_get.sh uses cURL to read MediaWiki pages. The command
requires four arguments: url, a URL string that references the
MediaWiki site's API endpoint; user, the username of an account with
API write privileges; password, the account's password; and title,
the title of the page to create/replace. The command will prompt
the user to enter the page's content via STDIN.

Options:

  -h | --help              Displays this message.
  -l | --url URL           The API endpoint.
  -u | --user USER         The account username.
  -p | --password PASSWORD The account password.
  -t | --title TITLE       The title of the created/edited page.
  -v | --verbose           Enables verbose output.

Examples:

  cat example.txt | post_wiki.sh --url http://wikipedia.org/api.php \\
    --user example_user --pasword example_password \\
    --title 'Example Page'

  Will create a page named Example Page on Wikipedia containing
  the contents in example.txt.

Author:

* Larry D. Lee jr. <llee454@gmail.com>
EOF
      exit 0 ;;
    -v | --verbose ) verbose=true; shift ;;
    -l | --url ) url=$2; shift 2 ;;
    -u | --user ) username=$2; shift 2 ;;
    -p | --password ) password=$2; shift 2 ;;
    -t | --title ) title=$2; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

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
if [ -z "$title" ]
then
  echo 'Error: Invalid commandline. The --title parameter is required.'
  exit 1
fi

if $verbose
then
  echo 'url: "'$url'"'
  echo 'username: "'$username'"'
  echo 'password: "'$password'"'
  echo 'title: "'$title'"'
fi

# II. Create cookie jar file.
cookie=$(mktemp --tmpdir='/tmp' 'post_wiki_cookies_XXX.txt')

# III. Get token
token=$(wiki_login.sh --file $cookie --url $url --user $username --password $password)

# IV. Get the page.
curl --silent --cookie $cookie --cookie-jar $cookie -X POST --data 'action=query' --data 'prop=revisions' --data 'rvprop=content' --data "titles=$title" --data 'format=xml' $url
