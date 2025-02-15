set -x

JENKINS_URL="https://jenkins.black.icf-comet-cc.com"
JENKINS_USER="admin"
JENKINS_TOKEN="yGvtgMREbHH59URQ56WQMD"
JOB_NAME="test-jenkins-api-job"

# Fetch Jenkins Crumb
CRUMB=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/crumbIssuer/api/xml" | grep -oP '(?<=<crumb>).*?(?=</crumb>)')

# Create Jenkins Job with Crumb
curl -X POST "$JENKINS_URL/createItem?name=$JOB_NAME" \
     --user "$JENKINS_USER:$JENKINS_TOKEN" \
     -H "Jenkins-Crumb: $CRUMB" \
     -H "Content-Type: application/xml" \
     --data-binary @- <<EOF
<flow-definition plugin="workflow-job">
  <description>Jenkins API Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps">
    <script>
      pipeline {
        agent any
        stages {
          stage('Echo') {
            steps {
              echo 'JenkinsAPI'
            }
          }
        }
      }
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
</flow-definition>
EOF


