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

GATEWAY=$(docker network inspect compose_default | awk '$1 == "\"Gateway\":" {print $2}')
PYTHON_COMMONS_SCHEME=${PYTHON_COMMONS_SCHEME:-$(prompt "Python commons server scheme ( for local PyPI server)" "http://")}
PYTHON_COMMONS_HOST=${PYTHON_COMMONS_HOST:-$(prompt "Python commons host ( for local PyPI server )" "$GATEWAY")}
PYTHON_COMMONS_PORT=${PYTHON_COMMONS_PORT:-$(prompt "Python commons scheme ( for local PyPI server)" "8080")}

GITHUB_APP_CLIENT_ID=${GITHUB_APP_CLIENT_ID:-$(prompt 'GitHub App Client ID ( choose from https://github.com/organizations/rebase-inc/settings/applications )')}
GITHUB_APP_CLIENT_SECRET=${GITHUB_APP_CLIENT_SECRET:-$(prompt 'GitHub App Client Secret ( choose from https://github.com/organizations/rebase-inc/settings/applications )')}

GITHUB_CRAWLER_USERNAME=${GITHUB_CRAWLER_USERNAME:-$(prompt 'GitHub Crawler Username ( create a new GitHub account for this )')}
GITHUB_CRAWLER_PASSWORD=${GITHUB_CRAWLER_PASSWORD:-$(prompt 'GitHub Crawler Password ( create a new GitHub account for this )')}

S3_KNOWLEDGE_BUCKET=${S3_KNOWLEDGE_BUCKET:-$(prompt 'S3 Bucket ( for storing population skill data )')}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-$(prompt 'AWS Access Key ID ( for storing population skill data )')}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-$(prompt 'AWS Secret Access Key ( for storing population skill data )')}
AWS_REGION=${AWS_REGION:-$(prompt 'AWS Region' 'us-east-1')}

FLASK_SECRET_KEY=${FLASK_SECRET_KEY:-$(prompt 'Flask Secret Key ( if not in production, this can be any string )' 'SOME_FAKE_KEY')}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-$(prompt 'Docker registry (for push to production)' ip-172-31-50-186.ec2.internal:5000)}

REPETITION_PENALTY=${REPETITION_PENALTY:-$(prompt 'Repetition Penalty for knowledge calculation (usually on [1,inf))' '8')}

make_file=$(prompt "Make a sourceable environment variable with these values?" "yes")

if [[ $make_file =~ ^([yY][eE][sS]|[yY])$ ]]
then
  env_file_location=$(prompt "Location for file?" "~/.env")
  env_file_location="${env_file_location/#\~/$HOME}"
  echo "PYTHON_COMMONS_SCHEME=\"$PYTHON_COMMONS_SCHEME\"" > $env_file_location
  echo "PYTHON_COMMONS_HOST=\"$PYTHON_COMMONS_HOST\"" >> $env_file_location
  echo "PYTHON_COMMONS_PORT=\"$PYTHON_COMMONS_PORT\"" >> $env_file_location
  echo "GITHUB_APP_CLIENT_ID=\"$GITHUB_APP_CLIENT_ID\"" >> $env_file_location
  echo "GITHUB_APP_CLIENT_SECRET=\"$GITHUB_APP_CLIENT_SECRET\"" >> $env_file_location
  echo "GITHUB_CRAWLER_USERNAME=\"$GITHUB_CRAWLER_USERNAME\"" >> $env_file_location
  echo "GITHUB_CRAWLER_PASSWORD=\"$GITHUB_CRAWLER_PASSWORD\"" >> $env_file_location
  echo "S3_KNOWLEDGE_BUCKET=\"$S3_KNOWLEDGE_BUCKET\"" >> $env_file_location
  echo "AWS_REGION=\"$AWS_REGION\"" >> $env_file_location
  echo "AWS_ACCESS_KEY_ID=\"$AWS_ACCESS_KEY_ID\"" >> $env_file_location
  echo "AWS_SECRET_ACCESS_KEY=\"$AWS_SECRET_ACCESS_KEY\"" >> $env_file_location
  echo "FLASK_SECRET_KEY=\"$FLASK_SECRET_KEY\"" >> $env_file_location
  echo "DOCKER_REGISTRY=\"$DOCKER_REGISTRY\"" >> $env_file_location
  echo "REPETITION_PENALTY=\"$REPETITION_PENALTY\"" >> $env_file_location
fi
