pipeline {
   agent any

   stages {
       stage('Build') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/canary-release.git')
           sh '$MVN/mvn package'

        }
   }
      
      stage('Deploy') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/ans.git')
         ansiblePlaybook (become: true,  inventory: './hosts', playbook: './main.yml',extraVars: [port:'${PORT}'])
           sh 'consul services register -id=${VERSION} -address=dimaxe2c.mylabserver.com -port=${PORT} -tag=${VERSION} -name=backend -http-addr=${CONSUL_ENDPOINT}'
          
        }
   }
   

   }
}
