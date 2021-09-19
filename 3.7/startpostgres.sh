#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-13-main.log
