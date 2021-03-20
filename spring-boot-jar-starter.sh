#!/bin/bash

set -e



# 堆设置
JAVA_OPTS="-Xms2g -Xmx4g -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=512m"

# New Relic
JAVA_OPTS="$JAVA_OPTS -javaagent:./newrelic/newrelic.jar"

# GC 设置
JAVA_OPTS="$JAVA_OPTS -XX:+UseParNewGC  -XX:MaxTenuringThreshold=9 -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:+ScavengeBeforeFullGC -XX:+UseCMSCompactAtFullCollection -XX:+CMSParallelRemarkEnabled -XX:CMSFullGCsBeforeCompaction=9 -XX:CMSInitiatingOccupancyFraction=60 -XX:+CMSClassUnloadingEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSPermGenSweepingEnabled -XX:CMSInitiatingPermOccupancyFraction=70 -XX:+ExplicitGCInvokesConcurrent -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationConcurrentTime -XX:+PrintHeapAtGC -XX:+HeapDumpOnOutOfMemoryError -XX:-OmitStackTraceInFastThrow -Dclient.encoding.override=UTF-8 -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom"

# GC 额外设置
JAVA_OPTS="$JAVA_OPTS -Xloggc:./gc/gc_%p.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./gc/heap_%p.hprof"


# 用户设置
APP_NAME="plat-core"
SERVER_PORT=9528
PROFILE_NAME=pro
APOLLO_PARAM="-Denv=pro -Dapp.id=plat_server -Dpro_meta=https://proconfcenter.democorp.com -Dsentry.dsn=https://f9b2f6cb5b464d5b9f7bdf4d6f7b7fa5@sentry.democorp.com/15 -Dsentry.environment=prod -Dexecutor.msg=true"


# 使用说明
usage() {
	echo "usage: spring-boot-jar-starter.sh start|stop|restart"
}


# 启动
start() {
	echo start $APP_NAME
	startup
	echo $APP_NAME started
}

# 启动
startup() {
	cd /home/demo/server/boot
	export confserver_seckey_plat_server=123456789
	nohup /home/demo/java/jdk1.8.0_161/bin/java $APOLLO_PARAM -jar $JAVA_OPTS  "${APP_NAME}.jar" --server.port=$SERVER_PORT --spring.profiles.active=$PROFILE_NAME  >/dev/null 2>&1 &
	 #/home/demo/java/jdk1.8.0_161/bin/java $APOLLO_PARAM -jar $JAVA_OPTS  "${APP_NAME}.jar" --server.port=$SERVER_PORT --spring.profiles.active=$PROFILE_NAME
}


# 停止
stop() {
	PID=$(ps -ef | grep $APP_NAME.jar | grep -v grep | awk '{ print $2 }')
	if [ -z "$PID" ]
	then
	    echo $APP_NAME is already stopped
	else
	    echo kill $PID
	    kill -9  $PID
	fi
}


# 重新启动
restart() {
	echo stopping $APP_NAME
	stop
	echo $APP_NAME stopped
	echo start $APP_NAME
	startup
	echo $APP_NAME started
}


## 下面是主流程

if [ $# -ne 1 ]
then
	usage
	exit 0
fi


case $1 in
	'start')
		start
	;;
	'stop')
		stop
	;;
	'restart')
		restart
	;;
	*)
		usage
	;;
esac



# tail -f ./nohup.out
