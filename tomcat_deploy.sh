#!/bin/bash
# deploy tomcat with a web app
if [[ $# -lt 2 ]]; then
   echo "usage: $(basename $0) request_port redir_port shutdown_port" >&2
   exit 1;
fi


TOMCAT_HOME=/root/avgd/soft/tomcat/apache-tomcat-7.0.61
DEPLOY_PATH=`pwd`

cp -r $TOMCAT_HOME/conf $TOMCAT_HOME/work $DEPLOY_PATH
mkdir -p $DEPLOY_PATH/webapps/ROOT $DEPLOY_PATH/bin $DEPLOY_PATH/temp $DEPLOY_PATH/logs

# modify conf
# request port
sed -i -- "s/8080/$1/g" $DEPLOY_PATH/conf/server.xml
# redir port
sed -i -- "s/8009/$2/g" $DEPLOY_PATH/conf/server.xml
# shutdown port
sed -i -- "s/8005/$3/g" $DEPLOY_PATH/conf/server.xml

# create execute
echo "export CATALINA_HOME=$TOMCAT_HOME
export CATALINA_BASE=$DEPLOY_PATH
export CATALINA_PID=$DEPLOY_PATH/bin/RUNNING_PID
\$CATALINA_HOME/bin/startup.sh -Dcatalina.base" > $DEPLOY_PATH/bin/startup.sh

cat $DEPLOY_PATH/bin/startup.sh > $DEPLOY_PATH/bin/start.sh
echo 'tail -f \$CATALINA_BASE/logs/catalina.out' >> $DEPLOY_PATH/bin/start.sh

echo "export CATALINA_HOME=$TOMCAT_HOME
export CATALINA_BASE=$DEPLOY_PATH
export CATALINA_PID=$DEPLOY_PATH/bin/RUNNING_PID
\$CATALINA_HOME/bin/shutdown.sh -Dcatalina.base" > $DEPLOY_PATH/bin/stop.sh

chmod 750 $DEPLOY_PATH/bin/*

echo "1. put web app files in to $DEPLOY_PATH/webapps/ROOT
2. execute $DEPLOY_PATH/bin/start.sh to start
3. execute $DEPLOY_PATH/bin/stop.sh to strop"
exit 0
