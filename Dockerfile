FROM centos/postgresql-95-centos7

USER root

ENV PATRONIVERSION=1.2.4
ENV WALE_VERSION=1.0.3
ENV PGHOME=/var/lib/pgsql/
ENV PGROOT=$PGHOME/pgdata/pgroot
ENV PGDATA=$PGROOT/data
ENV PGLOG=$PGROOT/pg_log
ENV WALE_ENV_DIR=$PGHOME/etc/wal-e.d/env
ENV USER_NAME=${PGUSER}
ENV USER_UID=26

RUN yum install -y epel-release && \
    yum install -y etcd gcc make ansible python-pip iproute && \
    pip install pip --upgrade && \
    pip install --upgrade patroni==$PATRONIVERSION && \
    curl -Lo /tmp/origin.tar.gz 'https://github.com/openshift/origin/releases/download/v1.5.0-rc.0/openshift-origin-client-tools-v1.5.0-rc.0-49a4a7a-linux-64bit.tar.gz' && \
    tar -C /usr/bin/ -xf /tmp/origin.tar.gz --wildcards --no-anchored 'oc' --strip 1 && \
    mv /opt/rh/rh-postgresql95/root/usr/bin/postgres{,-real} && \
    echo '#!/usr/bin/bash' > /opt/rh/rh-postgresql95/root/usr/bin/postgres && \
    cat /opt/rh/rh-postgresql95/enable >> /opt/rh/rh-postgresql95/root/usr/bin/postgres && \
    echo 'exec postgres-real "$@"' >> /opt/rh/rh-postgresql95/root/usr/bin/postgres && \
    chmod 755 /opt/rh/rh-postgresql95/root/usr/bin/postgres

ADD root /

RUN chmod -R ug+x /usr/bin/user_setup /usr/bin/callback.py /usr/bin/init.py && \
    /usr/bin/user_setup


USER ${USER_UID}
RUN sed "s@${USER_NAME}:x:${USER_UID}:@${USER_NAME}:x:\${USER_ID}:@g" /etc/passwd > ${HOME}/passwd.template
WORKDIR $PGHOME
EXPOSE 5432 8008




