prompt() {
  if [ -z "$2" ]
  then
    while [ -z "$answer" ]
    do
      read -e -p "$1: " answer
    done
    echo $answer
  else
    read -e -p "$1 [$2]: " answer
    echo ${answer:-$2}
  fi
}

export VM_NAME=$(docker-machine ls --quiet)
export DOCKERHOST=$(docker-machine ip $VM_NAME)

export PYPI_SERVER_HOST=${PYPI_SERVER_HOST:-$(prompt "PyPI server host ( for local PyPI server )" "$DOCKERHOST")}
export PYPI_SERVER_SCHEME=${PYPI_SERVER_SCHEME:-$(prompt "PyPI server scheme ( for local PyPI server)" "http://")}
export PYPI_SERVER_PORT=${PYPI_SERVER_PORT:-$(prompt "PyPI server scheme ( for local PyPI server)" "8080")}

export GITHUB_APP_CLIENT_ID=${GITHUB_APP_CLIENT_ID:-$(prompt 'GitHub App Client ID ( for GitHub OAuth )')}
export GITHUB_APP_CLIENT_SECRET=${GITHUB_APP_CLIENT_SECRET:-$(prompt 'GitHub App Client Secret ( for GitHub OAuth )')}

export GITHUB_CRAWLER_USERNAME=${GITHUB_CRAWLER_USERNAME:-$(prompt 'GitHub Crawler Username ( for public crawling )')}
export GITHUB_CRAWLER_PASSWORD=${GITHUB_CRAWLER_PASSWORD:-$(prompt 'GitHub Crawler Password ( for public crawling )')}

export SKILL_DATA_S3_BUCKET=${SKILL_DATA_S3_BUCKET:-$(prompt 'S3 Bucket ( for storing population skill data )')}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-$(prompt 'AWS Access Key ID ( for storing population skill data )')}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-$(prompt 'AWS Secret Access Key ( for storing population skill data )')}

export FLASK_SECRET_KEY=${FLASK_SECRET_KEY:-$(prompt 'Flask Secret Key ( for flask security )' 'FAKE_KEY')}

make_file=$(prompt "Make a sourceable environment variable with these values?" "yes")

if [[ $make_file =~ ^([yY][eE][sS]|[yY])$ ]]
then
  env_file_location=$(prompt "Location for file?" "~/rebase.dev")
  env_file_location="${env_file_location/#\~/$HOME}"
  echo "PYPI_SERVER_HOST=$PYPI_SERVER_HOST" >> $env_file_location
  echo "PYPI_SERVER_SCHEME=$PYPI_SERVER_SCHEME" >> $env_file_location
  echo "PYPI_SERVER_PORT=$PYPI_SERVER_PORT" >> $env_file_location
  echo "GITHUB_APP_CLIENT_ID=$GITHUB_APP_CLIENT_ID" >> $env_file_location
  echo "GITHUB_APP_CLIENT_SECRET=$GITHUB_APP_CLIENT_SECRET" >> $env_file_location
  echo "GITHUB_CRAWLER_USERNAME=$GITHUB_CRAWLER_USERNAME" >> $env_file_location
  echo "GITHUB_CRAWLER_PASSWORD=$GITHUB_CRAWLER_PASSWORD" >> $env_file_location
  echo "SKILL_DATA_S3_BUCKET=$SKILL_DATA_S3_BUCKET" >> $env_file_location
  echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> $env_file_location
  echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> $env_file_location
  echo "FLASK_SECRET_KEY=$FLASK_SECRET_KEY" >> $env_file_location
fi
