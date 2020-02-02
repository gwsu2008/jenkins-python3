#!groovy
@Library(['my-shared-library','jenkins-pipeline-shared-lib-sample'])_


properties([
    disableConcurrentBuilds(),
    buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '10')),
    disableConcurrentBuilds(),
    parameters([ 
        choice( name: 'CONFIG', choices: ['api-dev'], description: 'AWS Env profile'),
        string(name: 'PYTHON_IMAGE', defaultValue: 'gwsu2008/jenkins-python3:3.8.1-boto3', description: 'Python3 docker image')
    ])
])

def python_image = params.PYTHON_IMAGE


node( 'docker-host' ) {
    step([$class: 'WsCleanup'])

    timestamps {
        try {
            println ("Python Image:" + python_image)
            docker.image('gwsu2008/jenkins-python3:3.8.1-boto3').inside("-v ${WORKSPACE}:${WORKSPACE}") {
                stage('Run Python') {
                    sh 'python --version'
                }
            }
            
        
            stage('Push image to ECR') {
                println("dpDockerizeService.pushImage(configParams, newImage, true)")
            }
            
            stage('Run Smoke Test') {
                build job: 'docker-node-pipeline',
                parameters:[string(name:'FHIRAPI_ENVIRONMENT_NAME_PARAMETER', value: 'HELLO3'), string(name:'GROUP', value: 'FhirApi')],
                propagate: true,
                wait: true
            }

            if (isBackToNormal()) {
                println("Back to Normal")
            }

            currentBuild.result = 'SUCCESS'
        } catch (Exception e) {
            currentBuild.result = 'FAILURE'
            println("Caught exception: " + e)
        } finally {
            println("CurrentBuild result: " + currentBuild.result)
        }
    }
}

def isBackToNormal() {
    return currentBuild?.previousBuild?.result != 'SUCCESS' && env.BUILD_NUMBER != 1
}


