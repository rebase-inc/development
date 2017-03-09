from base64 import encodebytes
from io import BytesIO
from os import environ as env
from os.path import expanduser
from tarfile import open as open_tarfile


def main():
    compose_archive = None
    with BytesIO() as buffer:
        with open_tarfile(fileobj=buffer, mode='w:gz') as tar_gz:
            tar_gz.add('compose')
            tar_gz.add(expanduser('~/.rebase.pro.env'), arcname='.rebase.pro.env')
        buffer.flush()
        compose_archive = encodebytes(buffer.getvalue()).decode().replace('\n', '')

    with open(env['HOME']+'/.ssh/id_rsa.pub') as public_key_file:
        build_machine_public_key = public_key_file.read()

    cloud_config_template = f'''
#cloud-config

ssh_authorized_keys:
    - {build_machine_public_key}

rancher:
  docker:
    insecure_registry:
      - {env['DOCKER_REGISTRY']}

write_files:
    -   path: /etc/rc.local
        permissions: "0755"
        owner: root
        content: |
            #!/bin/bash
            wait-for-docker
            sudo -i -u rancher
            cd /home/rancher
            rm -rf compose
            echo "{compose_archive}" | base64 -d | tar -xz
            declare -a containers=$(docker ps -q)
            for container in ${{containers[@]}}
            do
                docker stop $container
                docker rm $container
            done
            . .rebase.pro.env
            docker-compose -f compose/common.yml -f compose/pro.yml pull
            docker-compose -f compose/common.yml -f compose/pro.yml up -d

    '''
    print(cloud_config_template)


if __name__ == '__main__':
    main()


