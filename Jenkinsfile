pipeline {
   agent any

   stages {
       stage('Build') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/canary-release.git')
           sh '$MVN/mvn clean package'

        }
   }
      
      stage('Deploy') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/ans.git')
         ansiblePlaybook (become: true,  inventory: './hosts', playbook: './main.yml',extraVars: [port:'${PORT}'])
         sh 'consul services register -id=back-${VERSION} -address=dimaxe3c.mylabserver.com -port=${PORT} -tag=${VERSION} -name=backend -http-addr=${CONSUL_ENDPOINT}'
         sh 'echo {\""ID\"": \""check-${VERSION}\"",\""Name\"": \""check-${VERSION}\"",\""HTTP\"": \""http://172.31.29.255:${PORT}/v1/hello\"",\""Method\"": \""GET\"",\""ServiceID\"": \""back-${VERSION}\"",\""Interval\"": \""10s\"",\""TLSSkipVerify\"": true} > payload.json' 
        }
   }
   

   }
}
