#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
}
trap stopServices TERM

/app/config.sh

if id nominatim >/dev/null 2>&1; then
  echo "user nominatim already exists"
else
  useradd -m -p ${NOMINATIM_PASSWORD} nominatim
fi

IMPORT_FINISHED=/var/lib/postgresql/13/main/import-finished

if [ ! -f ${IMPORT_FINISHED} ]; then
  /app/init.sh
  touch ${IMPORT_FINISHED}
else
  chown -R nominatim:nominatim ${PROJECT_DIR}
fi

cd ${PROJECT_DIR} && nominatim refresh --website

service postgresql start
service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-13-main.log &
wait
