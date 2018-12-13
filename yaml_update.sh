#!/bin/bash


work_path="/opt/k8s-yaml"
image_name="$1"
yaml_name="$2"

cd $work_path

if [ "W${yaml_name}" == "W" ] ; then
	echo "未携带yaml文件"
	exit 1
fi

if [ -f "./${yaml_name}" ]; then
	sou_image_name=$(cat ${yaml_name}|grep "image" |awk '{print $2}')
else
	echo "未找到yaml文件"
	exit 1
fi

sed -i "s#${sou_image_name}#${image_name}#g" ${yaml_name}

if [ $? -eq 0 ]; then
	echo "yaml文件更新完成"
	exit 0
fi
