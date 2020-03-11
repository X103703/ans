pipeline {
   agent any

   stages {
       stage('Build') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/canary-release.git')
           sh '$MVN/mvn package'
           sh 'nohup java -Dthorntail.http.port=8181 -jar ./target/demo-thorntail.jar &'
        }
   }
      
      stage('Deploy') {
        steps {
         git (credentialsId: 'desboisdimitri', url: 'https://github.com/X103703/ans.git')
          ansiblePlaybook (become: true, credentialsId: 'Key', inventory: './hosts', playbook: './main.yml')
        }
   }
   
   stage('End') {
     steps {
       echo 'Ending...'
     }
   }
   }
}
