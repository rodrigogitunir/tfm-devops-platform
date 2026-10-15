pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '20'))
        skipDefaultCheckout(true)
    }

    parameters {
        string(
            name: 'APP_VERSION',
            defaultValue: '1.1.0',
            description: 'Docker image and application version'
        )

        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['dev', 'pre', 'pro'],
            description: 'Target Kubernetes environment'
        )
    }

    environment {
        APP_NAME   = 'tfm-devops-app'
        CHART_PATH = 'helm/tfm-devops-app'
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
        IMAGE_NAME = "${APP_NAME}:${APP_VERSION}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate version') {
            steps {
                sh '''
                    set -eu

                    echo "$APP_VERSION" \
                      | grep -Eq '^[0-9]+\\.[0-9]+\\.[0-9]+([.-][A-Za-z0-9]+)?$'
                '''
            }
        }

        stage('Unit tests') {
            steps {
                dir('application') {
                    sh '''
                        set -eu

                        rm -rf .venv-ci
                        python3 -m venv .venv-ci
                        . .venv-ci/bin/activate

                        pip install \
                          --disable-pip-version-check \
                          -r requirements-dev.txt

                        pytest -v \
                          --junitxml=test-results.xml
                    '''
                }
            }

            post {
                always {
                    junit(
                        testResults: 'application/test-results.xml',
                        allowEmptyResults: true
                    )
                }
            }
        }

        stage('Docker build') {
            steps {
                sh '''
                    set -eu

                    docker build \
                      --tag "$IMAGE_NAME" \
                      ./application
                '''
            }
        }

        stage('Security scan') {
            steps {
                sh '''
                    set -eu

                    mkdir -p reports

                    if command -v trivy >/dev/null 2>&1; then
                        trivy image \
                          --severity HIGH,CRITICAL \
                          --ignore-unfixed \
                          --exit-code 0 \
                          --format table \
                          --output reports/trivy-image.txt \
                          "$IMAGE_NAME"
                    else
                        echo "Trivy is not installed" \
                          | tee reports/trivy-image.txt
                    fi
                '''
            }

            post {
                always {
                    archiveArtifacts(
                        artifacts: 'reports/trivy-image.txt',
                        allowEmptyArchive: true
                    )
                }
            }
        }

        stage('Load image into Minikube') {
            steps {
                sh '''
                    set -eu

                    sudo -u devops \
                      /usr/local/bin/jenkins-minikube-load \
                      "$IMAGE_NAME"
                '''
            }
        }

        stage('Helm validation') {
            steps {
                sh '''
                    set -eu

                    helm lint "$CHART_PATH" \
                      --values "$CHART_PATH/values-${TARGET_ENVIRONMENT}.yaml"

                    helm template "$APP_NAME" "$CHART_PATH" \
                      --namespace "$TARGET_ENVIRONMENT" \
                      --values "$CHART_PATH/values-${TARGET_ENVIRONMENT}.yaml" \
                      --set-string image.tag="$APP_VERSION" \
                      --set-string application.version="$APP_VERSION" \
                      > /tmp/tfm-devops-app-rendered.yaml

                    kubectl apply \
                      --namespace "$TARGET_ENVIRONMENT" \
                      --dry-run=server \
                      --filename /tmp/tfm-devops-app-rendered.yaml
                '''
            }
        }

        stage('Approval') {
            when {
                expression {
                    params.TARGET_ENVIRONMENT != 'dev'
                }
            }

            steps {
                input(
                    message: "Deploy version ${APP_VERSION} to ${TARGET_ENVIRONMENT}?",
                    ok: 'Deploy'
                )
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh '''
                    set -eu

                    helm upgrade --install "$APP_NAME" "$CHART_PATH" \
                      --namespace "$TARGET_ENVIRONMENT" \
                      --values "$CHART_PATH/values-${TARGET_ENVIRONMENT}.yaml" \
                      --set-string image.tag="$APP_VERSION" \
                      --set-string application.version="$APP_VERSION" \
                      --wait \
                      --timeout 5m \
                      --atomic
                '''
            }
        }

        stage('Rollout validation') {
            steps {
                sh '''
                    set -eu

                    kubectl rollout status \
                      deployment/tfm-devops-app-tfm-devops-app \
                      --namespace "$TARGET_ENVIRONMENT" \
                      --timeout=180s

                    kubectl get deployment,pods,service \
                      --namespace "$TARGET_ENVIRONMENT"
                '''
            }
        }

        stage('Smoke test') {
            steps {
                sh '''
                    set -eu

                    SERVICE_NAME=tfm-devops-app-tfm-devops-app
                    LOCAL_PORT=18081

                    kubectl port-forward \
                      --namespace "$TARGET_ENVIRONMENT" \
                      "service/$SERVICE_NAME" \
                      "$LOCAL_PORT:80" \
                      > /tmp/tfm-port-forward.log 2>&1 &

                    PORT_FORWARD_PID=$!

                    cleanup() {
                        kill "$PORT_FORWARD_PID" 2>/dev/null || true
                    }

                    trap cleanup EXIT

                    sleep 5

                    curl --fail --silent \
                      "http://127.0.0.1:$LOCAL_PORT/health"

                    curl --fail --silent \
                      "http://127.0.0.1:$LOCAL_PORT/ready"

                    curl --fail --silent \
                      "http://127.0.0.1:$LOCAL_PORT/" \
                      | tee smoke-test-result.json

                    grep -q \
                      "\\"environment\\":\\"$TARGET_ENVIRONMENT\\"" \
                      smoke-test-result.json

                    grep -q \
                      "\\"version\\":\\"$APP_VERSION\\"" \
                      smoke-test-result.json
                '''
            }

            post {
                always {
                    archiveArtifacts(
                        artifacts: 'smoke-test-result.json',
                        allowEmptyArchive: true
                    )
                }
            }
        }
    }

    post {
        success {
            echo "Deployment ${APP_VERSION} to ${TARGET_ENVIRONMENT} completed successfully."
        }

        failure {
            echo "Pipeline failed. Review the stage logs and the current Helm release."
        }

        always {
            sh '''
                docker image prune --force \
                  --filter "until=168h" || true
            '''

            cleanWs(
                deleteDirs: true,
                notFailBuild: true
            )
        }
    }
}
