#!groovy
@Library(['my-shared-library','jenkins-pipeline-shared-lib-sample'])_


properties([
    properties([disableConcurrentBuilds()])
    buildDiscarder(logRotator(daysToKeepStr: '7', numToKeepStr: '10'))
    disableConcurrentBuilds(),
    parameters([ 
        choice( name: 'config_set', choices: ['api-dev'], description: 'Name of the Configuration set to use')
        text(name: 'PYTHON_IMAGE', defaultValue: 'gwsu2008/jenkins-python3:3.8.1-boto3', description: 'Python3 docker image')
    ])
])

def python_image = params.PYTHON_IMAGE


node( 'docker-host' ) {
    step([$class: 'WsCleanup'])

    timestamps {
        try {
            println ("Python Image:" + python_image)
            dir(${WORKSPACE}) {
                docker.image('localstack/localstack').withRun(
                    '-p 33567-33583:4567-4583  -e SERVICES=sqs:4576 -e DEFAULT_REGION=us-west-2 -e HOSTNAME_EXTERNAL=localstack -v /var/run/docker.sock:/var/run/docker.sock')
                    { 
                        l -> docker.image('gwsu2008/jenkins-python3:3.8.1-boto3').inside("--link ${l.id}:localstack  -v /home/gsu/workspace/jenkins-python3:/usr/src/app") 
                        {
                            sh("ls -ltrh;pwd")
                        }
                    }
            }
        
            stage('Push to Intdev ECR') {
                println("dpDockerizeService.pushImage(configParams, newImage, true)")
            }
            
            stage('Run INT-DEV Smoke Test') {
                build job: smokeTestJob,
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
            error = catchException exception: e
            println("Caught exception: " + e)
        } finally {
            println("CurrentBuild result: " + currentBuild.result)
        }
    }
}

def isBackToNormal() {
    return currentBuild?.previousBuild?.result != 'SUCCESS' && env.BUILD_NUMBER != 1
}


