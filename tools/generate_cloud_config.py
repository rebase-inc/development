from base64 import encodebytes
from io import BytesIO
from os import environ as env
from os.path import expanduser
from socket import gethostname
from tarfile import open as open_tarfile


def main():
    compose_tar_gz_base64 = None
    with BytesIO() as buffer:
        with open_tarfile(fileobj=buffer, mode='w:gz') as tar_gz:
            tar_gz.add('compose')
            tar_gz.add(expanduser('~/.env'), arcname='.env')
        buffer.flush()
        compose_tar_gz_base64 = encodebytes(buffer.getvalue()).decode().replace('\n', '')

    with open(env['HOME']+'/.ssh/id_rsa.pub') as public_key_file:
        build_machine_public_key = public_key_file.read()

    cloud_config_template = f'''#cloud-config

ssh_authorized_keys:
    - {build_machine_public_key}

rancher:
  docker:
    insecure_registry:
    - {gethostname()}:5000

write_files:
    -   path: /etc/rc.local
        permissions: "0755"
        owner: root
        content: |
            #!/bin/bash
            wait-for-docker
            if [ ! -e /usr/local/bin/docker-compose ]; then
                curl -L https://github.com/docker/compose/releases/download/1.11.2/run.sh > /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
            fi
            sudo -i -u rancher
            cd /home/rancher
            for container in $(docker ps -q)
            do
                docker stop $container
                docker rm $container
            done
            rm -rf compose
            echo "{compose_tar_gz_base64}" | base64 -d | tar -xz
            export DOCKER_RUN_OPTIONS="--env-file=.env"
            docker-compose -f compose/common.yml -f compose/pro.yml pull
            docker-compose -f compose/common.yml -f compose/pro.yml up -d
            exit 0

    '''
    print(cloud_config_template)


if __name__ == '__main__':
    main()


