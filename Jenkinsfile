#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library@v2.6.1') _

// Initialize global config
cfg = jplConfig('api-status', 'node', '', [email:'redpandaci+nod@gmail.com'])

pipeline {
    agent none

    stages {
        stage ('Initialize') {
            agent { label 'master' }
            steps  {
                deleteDir()
                jplStart(cfg)
            }
        }
        stage ('Test') {
            agent { label 'master' }
            steps  {
                sh "bin/test.sh"
            }
            post {
                always {
                    publishHTML (target: [
                            allowMissing: false,
                            alwaysLinkToLastBuild: false,
                            keepAll: true,
                            reportDir: 'coverage/lcov-report',
                            reportFiles: 'index.html',
                            reportName: "Coverage-Report"
                    ])
                }
            }
        }
        stage ('Build') {
            agent { label 'master' }
            when { expression { cfg.BRANCH_NAME.startsWith('release/v') || cfg.BRANCH_NAME.startsWith('hotfix/v') } }
            steps {
                script {
                    docker.build('redpandaci/api-status:test', '--no-cache .')
                    jplDockerPush (cfg, "redpandaci/api-status", "test", "", "https://registry.hub.docker.com", "redpandaci-docker-credentials")
                }
            }
        }
        stage ('Release confirm') {
            when { expression { cfg.BRANCH_NAME.startsWith('release/v') || cfg.BRANCH_NAME.startsWith('hotfix/v') } }
            steps {
                jplPromoteBuild(cfg)
            }
        }
        stage ('Production deploy') {
            agent { label 'master' }
            when { expression { cfg.BRANCH_NAME.startsWith('release/v') || cfg.BRANCH_NAME.startsWith('hotfix/v') } }
            steps {
                script {
                    docker.build('redpandaci/api-status:latest')
                    jplDockerPush (cfg, "redpandaci/api-status", "latest", "", "https://registry.hub.docker.com", "redpandaci-docker-credentials")
                }
                sh "bin/deploy.sh"
            }
        }
        stage ('Release finish') {
            agent { label 'master' }
            when { expression { (cfg.BRANCH_NAME.startsWith('release/v') || cfg.BRANCH_NAME.startsWith('hotfix/v')) && cfg.promoteBuild.enabled } }
            steps {
                jplCloseRelease(cfg)
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        skipDefaultCheckout()
        timeout(time: 1, unit: 'DAYS')
    }
}