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
         sh 'echo {\"id\": \"check-${VERSION}\",\"name\": \"check-${VERSION}\",\"http\": \"http://dimaxe3c.mylabserver.com:${PORT}\",\"method\": \"GET\",\"serviceID\": \"back-${VERSION}\",\"interval\": \"10s\",\"tls_skip_verify\": true} > payload.json' 
        }
   }
   

   }
}
