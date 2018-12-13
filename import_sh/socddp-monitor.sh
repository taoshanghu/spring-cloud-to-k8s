#!/bin/sh
#---初始化信息----
if [ "W${REPL}" == "W" ]; then
  REPL=0
fi
if [ "W${SVC_NAME}" == "W" ]; then
  SVC_NAME=""
fi
if [ ${REPL} -gt 0 ]; then
  let REPL=$REPL-1
fi
if [ "W${SERVER_PORT}" == "W" ]; then
  SERVER_PORT=8764
fi
if [ "W${REDIS_PORT}" == "W" ]; then
  REDIS_PORT=6379
fi
if [ "W${MQ_PORT}" == "W" ]; then
  MQ_PORT=5672
fi
if [ "W${MYSQL_PORT}" == "W" ]; then
  MYSQL_PORT=3306
fi
if [ "W${MODE_NAME}" == "W" ]; then
  MODE_NAME="socddp-monitor"
fi
#---end---
#--注册中心 注册信息配置-----
/bin/hostname|awk -F "-" '{for(i=1;i<=(NF-2);i++){print $i;}}' > /tmp/hostname.log
HOST_NAME=""
for I in $(cat /tmp/hostname.log); do
 HOST_NAME="${HOST_NAME}-${I}"
done
echo ${HOST_NAME} > /tmp/hostname.log
HOST_NAME="$(sed 's/^-//g' /tmp/hostname.log).default.svc.cluster.local"
rm -rf /tmp/hostname.log
INSTANCE_ID="--eureka.instance.instance-id=${HOST_NAME}:${MODE_NAME}:${SERVER_PORT}"
#---end---
#---注册中心信息配置----
for I in $(seq 0 ${REPL}); do
  eureka_domain="http://${SVC_NAME}-${I}.${SVC_NAME}.default.svc.cluster.local:8761/eureka/,"${eureka_domain}
done
echo "${eureka_domain}" > /tmp/eureka_domain.log
sed -i '$s/,$//' /tmp/eureka_domain.log
eureka_domain_new="$(cat /tmp/eureka_domain.log)"
rm -rf /tmp/eureka_domain.log
JAVA_EUREKA="--eureka.client.serviceUrl.defaultZone=${eureka_domain_new}"
#---end---
#---JAVA 内存限制
if [ "W${java_xms}" == "W" ]; then
  java_xms=1024
fi
if [ "W${java_xmx}" == "W" ]; then
  java_xmx=1024
fi
JAVA_OPT="-server -Xms${java_xms}m -Xmx${java_xmx}m -XX:CompressedClassSpaceSize=128m -XX:MetaspaceSize=200m -XX:MaxMetaspaceSize=200m"
#---end---
#---服务端口配置---
ser_port="--server.port=${SERVER_PORT}"
#---end---
#---服务依赖信息配置---
SPRING=""
#---mysql---
spring_mysql_url="--spring.datasource.url=jdbc:mysql://${DB_HOST}:${MYSQL_PORT}/${DB_NAME}?useUnicode=true&characterEncoding=UTF8&useSSL=false"
spring_mysql_user="--spring.datasource.username=${DB_USER}"
spring_mysql_pass="--spring.datasource.password=${DB_PASS}"
SPRING="${SPRING} ${spring_mysql_url} ${spring_mysql_user} ${spring_mysql_pass}"
#---spring_redis---
spring_redis_host="--spring.redis.host=${REDIS_HOST}"
spring_redis_port="--spring.redis.port=${REDIS_PORT}"
spring_redis_pass="--spring.redis.password=${REDIS_PASS}"
SPRING="${SPRING} ${spring_redis_host} ${spring_redis_port} ${spring_redis_pass}"
#---spring_rabbitMQ---
spring_mq_host="--spring.rabbitmq.host=${MQ_HOST}"
spring_mq_user="--spring.rabbitmq.username=${MQ_USER}"
spring_mq_pass="--spring.rabbitmq.password=${MQ_PASS}"
spring_mq_port="--spring.rabbitmq.port=${MQ_PORT}"
SPRING="${SPRING} ${spring_mq_host} ${spring_mq_user} ${spring_mq_pass} ${spring_mq_port}"
#---redis---
redis_host="--redis.host=${REDIS_HOST}"
redis_pass="--redis.password=${REDIS_PASS}"
redis_port="--redis.port=${REDIS_PORT}"
SPRING="${SPRING} ${redis_host} ${redis_pass} ${redis_port}"
#---rabbitMQ---
mq_host="--rabbitMQ.host=${MQ_HOST}"
mq_user="--rabbitmq.username=${MQ_USER}"
mq_pass="--rabbitmq.password=${MQ_PASS}"
mq_port="--rabbitmq.port=${MQ_PORT}"
SPRING="${SPRING} ${mq_host} ${mq_user} ${mq_pass} ${mq_port}"
#---end---
java -jar ${JAVA_OPT} ${java_path_jar} ${JAVA_EUREKA} ${ser_port} ${SPRING} ${INSTANCE_ID} >> /opt/app.log
