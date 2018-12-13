#!/bin/sh
HOST_NAME="$(/bin/hostname)"
if [ "W${REPL}" == "W" ]; then
  REPL=0
fi
if [ "W${SVC_NAME}" == "W" ]; then
  SVC_NAME=""
fi
if [ ${REPL} -gt 0 ]; then
  let REPL=$REPL-1
fi
if [ "P${SERVER_PORT}" == "W" ]; then
 SERVER_PORT=8761
fi

for I in $(seq 0 ${REPL}); do
  if [ "W$(echo ${HOST_NAME}|grep ${I})" == "W" ]; then
    eureka_domain="http://${SVC_NAME}-${I}.${SVC_NAME}.default.svc.cluster.local:${SERVER_PORT}/eureka/,"${eureka_domain}
  fi
done

echo "${eureka_domain}" > /tmp/eureka_domain.log
sed -i '$s/,$//' /tmp/eureka_domain.log
eureka_domain_new="$(cat /tmp/eureka_domain.log)"
rm -rf /tmp/eureka_domain.log

#JAVA_OPT="-Dlogback.console=false -Dlogback.file=true -Dlogback.path=/opt/logs -Dlogback.file.error=true -Dlogback.file.no-error=true"
JAVA_EUREKA="--eureka.client.serviceUrl.defaultZone=${eureka_domain_new}"
HOST_NAME="--eureka.instance.hostname=${HOST_NAME}.${SVC_NAME}.default.svc.cluster.local"
#eureka_instance_appname="--eureka.instance.appname=socddp-center"
ser_port="--server.port=${SERVER_PORT}"
java -jar  ${java_path_jar} ${JAVA_EUREKA} ${HOST_NAME} ${ser_port}
