@Library('visenze-lib')_

pipeline {
  agent {
    label "${params.AGENT_LABEL ?: 'build-amd64'}"
  }

  stages {
    stage('Test') {
      steps {
        script {
          sh 'git config --global --add safe.directory /usr/local/bin/flutter'
          withEnv(["PATH=${tool('flutter')}:$PATH"]) {
            sh 'flutter pub get'
            sh 'flutter test'
          }     
        }
      }
    }

    stage('Publish') {
      steps {
        script {
          if (env.BRANCH_NAME == 'production') {   
            tool('gcloud')
            withCredentials([file(credentialsId: 'pub-dev-publisher-gcp-sa', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
              withEnv(["PATH=${tool('flutter')}:$PATH"]) {
                sh('flutter pub get')
                sh('gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS')
                sh('gcloud auth print-identity-token --audiences=https://pub.dev | dart pub token add https://pub.dev')
                sh('dart pub publish --force')
              }       
            }
          }
        }
      }
    }
  }
}
