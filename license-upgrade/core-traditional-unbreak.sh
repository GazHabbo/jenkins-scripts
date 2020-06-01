#!/bin/bash

## Script to automatically determine what version of plugin needs to be downloaded
## and installs it

hinit() {
    rm -f /tmp/hashmap.$1
}

hput() {
    echo "$2 $3" >> /tmp/hashmap.$1
}

hget() {
    PLUGIN_URL=$(grep "^$2 " /tmp/hashmap.$1 | awk '{ print $2 };' )
}

hinit versions
hput versions "9.33" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.33.1/cloudbees-license.hpi"
hput versions "9.32" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.32.1/cloudbees-license.hpi"
hput versions "9.31" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.31.1/cloudbees-license.hpi"
hput versions "9.30" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.30.1/cloudbees-license.hpi"
hput versions "9.28" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.28.1/cloudbees-license.hpi"
hput versions "9.27" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.27.1/cloudbees-license.hpi"
hput versions "9.26" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.26.1/cloudbees-license.hpi"
hput versions "9.24" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.24.1/cloudbees-license.hpi"
hput versions "9.20" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.20.1/cloudbees-license.hpi"
hput versions "9.18.1" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.18.1.1/cloudbees-license.hpi"
#TODO: verify this is not a mistake - 9.18.1 is not a valid backport for the new licenses....
hput versions "9.18" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.18.0.1/cloudbees-license.hpi"
hput versions "9.17" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.17.1/cloudbees-license.hpi"
#TODO: verify this is not a mistake
hput versions "9.24" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.24.1/cloudbees-license.hpi"
hput versions "9.13" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.13.1/cloudbees-license.hpi"
hput versions "9.11" "https://jenkins-updates.cloudbees.com/download/plugins/cloudbees-license/9.11.1/cloudbees-license.hpi"

hinit backports
hput backports "9.33.1" "backport"
hput backports "9.32.1" "backport"
hput backports "9.31.1" "backport"
hput backports "9.30.1" "backport"
hput backports "9.28.1" "backport"
hput backports "9.27.1" "backport"
hput backports "9.26.1" "backport"
hput backports "9.24.1" "backport"
hput backports "9.20.1" "backport"
hput backports "9.18.1.1" "backport"
hput backports "9.13.1" "backport"
hput backports "9.11.1" "backport"

hput backports "9.34" "ok"
hput backports "9.34.1" "ok"
hput backports "9.35" "ok"
hput backports "9.35.1" "ok"
hput backports "9.36" "ok"
hput backports "9.36.1" "ok"
hput backports "9.37" "ok"
hput backports "9.38" "ok"
hput backports "9.39" "ok"
hput backports "9.39.1" "ok"
hput backports "9.40" "ok"
hput backports "9.41" "ok"
hput backports "9.42" "ok"

# is JENKINS_HOME set?
 if [[ -z "$JENKINS_HOME" ]]; then
    echo "JENKINS_HOME not set, exiting..."
    exit
else
    echo "Using JENKINS_HOME defined as $JENKINS_HOME"
fi

# find the currently installed version of the cloudbees-license plugin
#echo "$JENKINS_HOME/plugins/cloudbees-license/META-INF/MANIFEST.MF"
#strip out any odd control chars!
CURRENT_PLUGIN_VERSION=$(grep Plugin-Version $JENKINS_HOME/plugins/cloudbees-license/META-INF/MANIFEST.MF | awk '{ print $2 };' | tr -d '\000-\031')
echo "CURRENT_PLUGIN_VERSION = $CURRENT_PLUGIN_VERSION"


# Check if the user does not need to upgrade (ie. 9.34 or newer already)
hget backports $CURRENT_PLUGIN_VERSION

if [ "$PLUGIN_URL" == "ok" ] ; then
    echo "Currently installed plugin version $CURRENT_PLUGIN_VERSION already supports the new license.  No upgrade nescecary"
    exit 0
fi

# Check if the  user has already upgraded
hget backports $CURRENT_PLUGIN_VERSION
if [ "$PLUGIN_URL" == "backport" ] ; then
    echo "Currently installed plugin version $CURRENT_PLUGIN_VERSION already supports the new license.  No upgrade nescecary"
    exit 0
fi

# lookup the updated plugin download url
hget versions $CURRENT_PLUGIN_VERSION

 if [[ -z "$PLUGIN_URL" ]]; then
    echo "No updated plugin exists for $CURRENT_PLUGIN_VERSION"
    echo "Please contact support"
    exit 1
fi

# backup the currently installed plugin
echo "Backing up the currently installed license plugin"
mv $JENKINS_HOME/plugins/cloudbees-license.jpi $JENKINS_HOME/plugins/cloudbees-license.bak

# now download the plugin

echo "Downloading updated plugin from $PLUGIN_URL"
if [ -x "$(which wget)" ] ; then
    wget -o $JENKINS_HOME/plugins/cloudbees-license.jpi $PLUGIN_URL
elif [ -x "$(which curl)" ]; then
    curl -o $JENKINS_HOME/plugins/cloudbees-license.jpi $PLUGIN_URL
else
    echo "Could not find curl or wget, please install one." >&2
    exit 1
fi

echo "Plugin updated successfully, please restart your Jenkins instance to complete the installation"
