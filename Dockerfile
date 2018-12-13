FROM java:8-jre-alpine
MAINTAINER taoshanghu@163.com
ADD ./bill.jar /opt/bill.jar
ADD ./import_sh/bill.sh /opt/bill.sh
RUN chmod 755 /opt/bill.sh
ENV java_path_jar "/opt/bill.jar"
ENV port ${PORT}
EXPOSE ${PORT}
CMD ["/bin/sh","-c","/opt/${node_name}.sh"]
