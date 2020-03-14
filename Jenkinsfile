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
        }
   }
   

   }
}
