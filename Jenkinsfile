def pipelineVersion='1.1.4'
println "Pipeline version: ${pipelineVersion}"
/*
 * This is a vanilla Jenkins pipeline that relies on the Jenkins kubernetes plugin to dynamically provision agents for
 * the build containers.
 *
 * The individual containers are defined in the `jenkins-pod-template.yaml` and the containers are referenced by name
 * in the `container()` blocks. The underlying pod definition expects certain kube Secrets and ConfigMap objects to
 * have been created in order for the Pod to run. See `jenkins-pod-template.yaml` for more information.
 *
 * The cloudName variable is set dynamically based on the existance/value of env.CLOUD_NAME which allows this pipeline
 * to run in both Kubernetes and OpenShift environments.
 */


def buildAgentName(String jobNameWithNamespace, String buildNumber, String namespace) {
    def jobName = removeNamespaceFromJobName(jobNameWithNamespace, namespace);

    if (jobName.length() > 52) {
        jobName = jobName.substring(0, 52);
    }

    return "a.${jobName}${buildNumber}".replace('_', '-').replace('/', '-').replace('-.', '.');
}

def removeNamespaceFromJobName(String jobName, String namespace) {
    return jobName.replaceAll(namespace + "-", "").replaceAll(jobName + "/", "");
}

def buildSecretName(String jobNameWithNamespace, String namespace) {
    return jobNameWithNamespace.replaceFirst(namespace + "/", "").replaceFirst(namespace + "-", "").replace(".", "-").toLowerCase();
}

def secretName = buildSecretName(env.JOB_NAME, env.NAMESPACE)
println "Job name: ${env.JOB_NAME}"
println "Secret name: ${secretName}"

def buildLabel = buildAgentName(env.JOB_NAME, env.BUILD_NUMBER, env.NAMESPACE);
def branch = env.BRANCH ?: "master"
def namespace = env.NAMESPACE ?: "dev"
def cloudName = env.CLOUD_NAME == "openshift" ? "openshift" : "kubernetes"
def workingDir = "/home/jenkins/agent"
podTemplate(
   label: buildLabel,
   cloud: cloudName,
   yaml: """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  volumes:
    - emptyDir: {}
      name: varlibcontainers
  containers:
    - name: node
      image: node:12-stretch
      tty: true
      command: ["/bin/bash"]
      workingDir: ${workingDir}
      envFrom:
        - configMapRef:
            name: pactbroker-config
            optional: true
      env:
        - name: HOME
          value: ${workingDir}
        - name: BRANCH
          value: ${branch}
        - name: GIT_AUTH_USER
          valueFrom:
            secretKeyRef:
              name: git-credentials
              key: username
              optional: true
        - name: GIT_AUTH_PWD
          valueFrom:
            secretKeyRef:
              name: git-credentials
              key: password
              optional: true
    - name: buildah
      image: quay.io/buildah/stable:v1.9.0
      tty: true
      command: ["/bin/bash"]
      workingDir: ${workingDir}
      securityContext:
        privileged: true
      envFrom:
        - configMapRef:
            name: ibmcloud-config
        - secretRef:
            name: ibmcloud-apikey
      env:
        - name: HOME
          value: /home/devops
        - name: ENVIRONMENT_NAME
          value: ${env.NAMESPACE}
        - name: DOCKERFILE
          value: ./Dockerfile
        - name: CONTEXT
          value: .
        - name: TLSVERIFY
          value: "false"
        - name: REGISTRY_USER
          valueFrom:
            secretKeyRef:
              key: REGISTRY_USER
              name: ibmcloud-apikey
              optional: true
        - name: REGISTRY_PASSWORD
          valueFrom:
            secretKeyRef:
              key: REGISTRY_PASSWORD
              name: ibmcloud-apikey
              optional: true
        - name: APIKEY
          valueFrom:
            secretKeyRef:
              key: APIKEY
              name: ibmcloud-apikey
              optional: true
      volumeMounts:
        - mountPath: /var/lib/containers
          name: varlibcontainers
    - name: ibmcloud
      image: docker.io/garagecatalyst/ibmcloud-dev:1.0.10
      tty: true
      command: ["/bin/bash"]
      workingDir: ${workingDir}
      envFrom:
        - configMapRef:
            name: ibmcloud-config
        - secretRef:
            name: ibmcloud-apikey
        - configMapRef:
            name: artifactory-config
            optional: true
        - secretRef:
            name: artifactory-access
            optional: true
      env:
        - name: CHART_NAME
          value: base
        - name: CHART_ROOT
          value: chart
        - name: TMP_DIR
          value: .tmp
        - name: HOME
          value: /home/devops
        - name: ENVIRONMENT_NAME
          value: ${env.NAMESPACE}
        - name: BRANCH
          value: ${branch}
    - name: trigger-cd
      image: docker.io/garagecatalyst/ibmcloud-dev:1.0.10
      tty: true
      command: ["/bin/bash"]
      workingDir: ${workingDir}
      env:
        - name: HOME
          value: /home/devops
      envFrom:
        - configMapRef:
            name: gitops-cd-secret
            optional: true
        - configMapRef:
            name: gitops-repo
            optional: true
        - secretRef:
            name: git-credentials
            optional: true
    - name: sonarqube-cli
      image: docker.io/sonarsource/sonar-scanner-cli:4.4
      tty: true
      command: ["/bin/bash"]
      workingDir: ${workingDir}
      envFrom:
        - configMapRef:
            name: sonarqube-config
            optional: true
        - secretRef:
            name: sonarqube-access
            optional: true
"""
) {
    node(buildLabel) {
        container(name: 'node', shell: '/bin/bash') {
            checkout scm
            stage('Build') {
                sh '''#!/bin/bash
                    npm install --unsafe-perm
                    npm run build --if-present
                '''
            }
            stage('Test') {
                sh '''#!/bin/bash
                    npm test
                '''
            }
            stage('Publish pacts') {
                sh '''#!/bin/bash
                    npm run pact:publish --if-present
                '''
            }
            stage('Verify pact') {
                sh '''#!/bin/bash
                    npm run pact:verify --if-present
                '''
            }
        }
        container(name: 'sonarqube-cli', shell: '/bin/bash') {
            stage('Sonar scan') {
                sh '''#!/bin/bash

                if ! command -v sonar-scanner &> /dev/null
                then
                    echo "Skipping SonarQube step, no task defined"
                    exit 0
                fi

                if [ -n "${SONARQUBE_URL}" ]; then
                  sonar-scanner \
                    -Dsonar.login=${SONARQUBE_USER} \
                    -Dsonar.password=${SONARQUBE_PASSWORD} \
                    -Dsonar.host.url=${SONARQUBE_URL} 
                else 
                    echo "Skipping Sonar Qube step"
                fi
                '''
            }
        }
        container(name: 'node', shell: '/bin/bash') {
            stage('Tag release') {
                sh '''#!/bin/bash
                    set -x
                    set -e

                    if [[ -z "$GIT_AUTH_USER" ]] || [[ -z "$GIT_AUTH_PWD" ]]; then
                      echo "Git credentials not found. The pipeline expects to find them in a secret named 'git-credentials'."
                      echo "  Update your CLI and register the pipeline again"
                      exit 1
                    fi

                    git config --local credential.helper "!f() { echo username=\\$GIT_AUTH_USER; echo password=\\$GIT_AUTH_PWD; }; f"

                    git fetch
                    git fetch --tags
                    git tag -l

                    COMMIT_HASH=$(git rev-parse HEAD)
                    git checkout -b ${BRANCH} --track origin/${BRANCH}
                    git branch --set-upstream-to=origin/${BRANCH} ${BRANCH}
                    git reset --hard ${COMMIT_HASH}

                    git config --global user.name "Jenkins Pipeline"
                    git config --global user.email "jenkins@ibmcloud.com"

                    if [[ "${BRANCH}" == "master" ]] && [[ $(git describe --tag `git rev-parse HEAD`) =~ (^[0-9]+.[0-9]+.[0-9]+$) ]] || \
                       [[ $(git describe --tag `git rev-parse HEAD`) =~ (^[0-9]+.[0-9]+.[0-9]+-${BRANCH}[.][0-9]+$) ]]
                    then
                        echo "Latest commit is already tagged"
                        echo "IMAGE_NAME=$(basename -s .git `git config --get remote.origin.url` | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')" > ./env-config
                        echo "IMAGE_VERSION=$(git describe --abbrev=0 --tags)" >> ./env-config
                        exit 0
                    fi

                    mkdir -p ~/.npm
                    npm config set prefix ~/.npm
                    export PATH=$PATH:~/.npm/bin
                    npm i -g release-it

                    if [[ "${BRANCH}" != "master" ]]; then
                        PRE_RELEASE="--preRelease=${BRANCH}"
                    fi

                    release-it patch ${PRE_RELEASE} \
                      --ci \
                      --no-npm \
                      --no-git.push \
                      --no-git.requireCleanWorkingDir \
                      --verbose \
                      -VV

                    git push --follow-tags -v

                    echo "IMAGE_VERSION=$(git describe --abbrev=0 --tags)" > ./env-config
                    echo "IMAGE_NAME=$(basename -s .git `git config --get remote.origin.url` | tr '[:upper:]' '[:lower:]' | sed 's/_/-/g')" >> ./env-config
                    echo "REPO_URL=$(git config --get remote.origin.url)" >> ./env-config

                    cat ./env-config
                '''
            }
        }
        container(name: 'buildah', shell: '/bin/bash') {
            stage('Build image') {
                sh '''#!/bin/bash
                    set -e
                    . ./env-config

		            echo TLSVERIFY=${TLSVERIFY}
		            echo CONTEXT=${CONTEXT}

		            if [[ -z "${REGISTRY_PASSWORD}" ]]; then
		              REGISTRY_PASSWORD="${APIKEY}"
		            fi

                    APP_IMAGE="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_VERSION}"

                    buildah bud --tls-verify=${TLSVERIFY} --format=docker -f ${DOCKERFILE} -t ${APP_IMAGE} ${CONTEXT}
                    if [[ -n "${REGISTRY_USER}" ]] && [[ -n "${REGISTRY_PASSWORD}" ]]; then
                        buildah login -u "${REGISTRY_USER}" -p "${REGISTRY_PASSWORD}" "${REGISTRY_URL}"
                    fi
                    buildah push --tls-verify=${TLSVERIFY} "${APP_IMAGE}" "docker://${APP_IMAGE}"
                '''
            }
        }
        container(name: 'ibmcloud', shell: '/bin/bash') {
            stage('Deploy to DEV env') {
                sh '''#!/bin/bash
                    echo "Deploying to ${ENVIRONMENT_NAME}"

                    set +x

                    . ./env-config

                    if [[ "${CHART_NAME}" != "${IMAGE_NAME}" ]]; then
                      cp -R "${CHART_ROOT}/${CHART_NAME}" "${CHART_ROOT}/${IMAGE_NAME}"
                      cat "${CHART_ROOT}/${CHART_NAME}/Chart.yaml" | \
                          yq w - name "${IMAGE_NAME}" > "${CHART_ROOT}/${IMAGE_NAME}/Chart.yaml"
                    fi

                    CHART_PATH="${CHART_ROOT}/${IMAGE_NAME}"

                    echo "KUBECONFIG=${KUBECONFIG}"

                    RELEASE_NAME="${IMAGE_NAME}"
                    echo "RELEASE_NAME: $RELEASE_NAME"

                    echo "INITIALIZING helm with client-only (no Tiller)"
                    helm init --client-only 1> /dev/null 2> /dev/null

                    echo "CHECKING CHART (lint)"
                    helm lint ${CHART_PATH}

                    IMAGE_REPOSITORY="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}"
                    PIPELINE_IMAGE_URL="${REGISTRY_URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}:${IMAGE_VERSION}"

                    INGRESS_ENABLED="true"
                    ROUTE_ENABLED="false"
                    if [[ "${CLUSTER_TYPE}" == "openshift" ]]; then
                        INGRESS_ENABLED="false"
                        ROUTE_ENABLED="true"
                    fi

                    # Update helm chart with repository and tag values
                    cat ${CHART_PATH}/values.yaml | \
                        yq w - nameOverride "${IMAGE_NAME}" | \
                        yq w - fullnameOverride "${IMAGE_NAME}" | \
                        yq w - vcsInfo.repoUrl "${REPO_URL}" | \
                        yq w - vcsInfo.branch "${BRANCH}" | \
                        yq w - image.repository "${IMAGE_REPOSITORY}" | \
                        yq w - image.tag "${IMAGE_VERSION}" | \
                        yq w - ingress.enabled "${INGRESS_ENABLED}" | \
                        yq w - route.enabled "${ROUTE_ENABLED}" > ./values.yaml.tmp
                    cp ./values.yaml.tmp ${CHART_PATH}/values.yaml
                    cat ${CHART_PATH}/values.yaml

                    # Using 'upgrade --install" for rolling updates. Note that subsequent updates will occur in the same namespace the release is currently deployed in, ignoring the explicit--namespace argument".
                    helm template ${CHART_PATH} \
                        --name ${RELEASE_NAME} \
                        --namespace ${ENVIRONMENT_NAME} \
                        --set ingress.tlsSecretName="${TLS_SECRET_NAME}" \
                        --set ingress.subdomain="${INGRESS_SUBDOMAIN}" > ./release.yaml

                    echo -e "Generated release yaml for: ${CLUSTER_NAME}/${ENVIRONMENT_NAME}."
                    cat ./release.yaml

                    echo -e "Deploying into: ${CLUSTER_NAME}/${ENVIRONMENT_NAME}."
                    kubectl apply -n ${ENVIRONMENT_NAME} -f ./release.yaml --validate=false
                '''
            }
            stage('Health Check') {
                sh '''#!/bin/bash
                    . ./env-config

                    if [[ "${CLUSTER_TYPE}" == "openshift" ]]; then
                        ROUTE_HOST=$(kubectl get route/${IMAGE_NAME} --namespace ${ENVIRONMENT_NAME} --output=jsonpath='{ .spec.host }')
                        URL="https://${ROUTE_HOST}"
                    else
                        INGRESS_HOST=$(kubectl get ingress.networking.k8s.io/${IMAGE_NAME} --namespace ${ENVIRONMENT_NAME} --output=jsonpath='{ .spec.rules[0].host }')
                        URL="http://${INGRESS_HOST}"
                    fi

                    sleep_countdown=5

                    # sleep for 10 seconds to allow enough time for the server to start
                    sleep 10
                    echo "Health check start"
                    while [[ $(curl -sL -w "%{http_code}\\n" "${URL}/health" -o /dev/null --connect-timeout 3 --max-time 5 --retry 3 --retry-max-time 30) != "200" ]]; do
                        sleep 30
                        echo "Health check failure. Remaining retries: $sleep_countdown"
                        sleep_countdown=$((sleep_countdown-1))
                        if [[ $sleep_countdown -eq 0 ]]; then
                                echo "Could not reach health endpoint: ${URL}/health"
                                exit 1;
                        fi
                    done

                    echo "Successfully reached health endpoint: ${URL}/health"
                    echo "====================================================================="
                '''
            }
            stage('Package Helm Chart') {
                sh '''#!/bin/bash

                if [[ -z "${ARTIFACTORY_URL}" ]]; then
                  echo "Skipping Artifactory step as Artifactory is not installed or configured"
                  exit 0
                fi

                . ./env-config

                if [[ -z "${ARTIFACTORY_ENCRYPT}" ]]; then
                    echo "It looks like your Artifactory installation is not complete. Please complete the steps found here - http://ibm.biz/complete-setup"
                    exit 1
                fi

                # Check if a Generic Local Repo has been created and retrieve the URL for it
                export URL=$(curl -u${ARTIFACTORY_USER}:${ARTIFACTORY_PASSWORD} -X GET "${ARTIFACTORY_URL}/artifactory/api/repositories?type=LOCAL" | jq '.[0].url' | tr -d \\")
                echo ${URL}

                # Check if the URL is valid and we can continue
                if [ -n "${URL}" ]; then
                    echo "Successfully read Repo ${URL}"
                else
                    echo "No Repository Created"
                    exit 1;
                fi;

                # Package Helm Chart
                helm package --version ${IMAGE_VERSION} ${CHART_ROOT}/${IMAGE_NAME}

                # Get the index and re index it with current Helm Chart
                curl -u${ARTIFACTORY_USER}:${ARTIFACTORY_ENCRYPT} -O "${URL}/${REGISTRY_NAMESPACE}/index.yaml"

                if [[ $(cat index.yaml | jq '.errors[0].status') != "404" ]]; then
                    # Merge the chart index with the current index.yaml held in Artifactory
                    echo "Merging Chart into index.yaml for Chart Repository"
                    helm repo index . --url ${URL}/${REGISTRY_NAMESPACE} --merge index.yaml
                else
                    # Dont Merge this is first time one is being created
                    echo "Creating a new index.yaml for Chart Repository"
                    rm index.yaml
                    helm repo index . --url ${URL}/${REGISTRY_NAMESPACE}
                fi;

                # Persist the Helm Chart in Artifactory for us by ArgoCD
                curl -u${ARTIFACTORY_USER}:${ARTIFACTORY_ENCRYPT} -i -vvv -T ${IMAGE_NAME}-${IMAGE_VERSION}.tgz "${URL}/${REGISTRY_NAMESPACE}/${IMAGE_NAME}-${IMAGE_VERSION}.tgz"

                # Persist the Helm Chart in Artifactory for us by ArgoCD
                curl -u${ARTIFACTORY_USER}:${ARTIFACTORY_ENCRYPT} -i -vvv -T index.yaml "${URL}/${REGISTRY_NAMESPACE}/index.yaml"

            '''
            }
        }
        container(name: 'trigger-cd', shell: '/bin/bash') {
            stage('Trigger CD Pipeline') {
                sh '''#!/bin/bash
                    if [[ -z "${url}" ]]; then
                        echo "'url' not set. Not triggering CD pipeline"
                        exit 0
                    fi
                    if [[ -z "${host}" ]]; then
                        echo "'host' not set. Not triggering CD pipeline"
                        exit 0
                    fi

                    if [[ -z "${branch}" ]]; then
                        branch="master"
                    fi

                    . ./env-config

                    # This email is not used and is not valid, you can ignore but git requires it
                    git config --global user.email "jenkins@ibmcloud.com"
                    git config --global user.name "Jenkins Pipeline"

                    GIT_URL="https://${username}:${password}@${host}/${org}/${repo}"

                    git clone -b ${branch} ${GIT_URL} gitops_cd
                    cd gitops_cd

                    echo "Requirements before update"
                    cat "./${IMAGE_NAME}/requirements.yaml"

                    npm i -g @garage-catalyst/ibm-garage-cloud-cli
                    igc yq w ./${IMAGE_NAME}/requirements.yaml "dependencies[?(@.name == '${IMAGE_NAME}')].version" ${IMAGE_VERSION} -i

                    echo "Requirements after update"
                    cat "./${IMAGE_NAME}/requirements.yaml"

                    git add -u
                    git commit -m "Updates ${IMAGE_NAME} to ${IMAGE_VERSION}"
                    git push -v
                '''
            }
        }
    }
}
