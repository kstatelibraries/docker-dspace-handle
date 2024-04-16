#!/bin/sh

HANDLE_BIN="/opt/handle/bin"
HANDLE_SVR="/var/handle/svr"

# Build and configure the server
python3 /home/handle/build.py $HANDLE_BIN $HANDLE_SVR

# Start the handle server
sed -i -e "s%net.handle.server.Main%-Dlog4j.configuration=file:///var/handle/svr/log4j-handle-plugin.properties -Ddspace.handle.plugin.configuration=/var/handle/svr/handle-dspace-plugin.cfg net.handle.server.Main%g" /opt/handle/bin/hdl

cat /opt/handle/bin/hdl | grep "net.handle.server.Main"
exec "$HANDLE_BIN/hdl-server" $HANDLE_SVR 2>&1

