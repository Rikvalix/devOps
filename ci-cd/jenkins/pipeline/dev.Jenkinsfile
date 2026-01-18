pipeline {
	agent {
		label 'java_agent'
	}
	environment {
		REGISTRY = 'localhost:5050'
		BUILDER_NAME = 'ktor-builder:21-9.1'
		APP_NAME = 'ktor'
	}
	options {
		skipDefaultCheckout(true)
	}
	stages {
        stage('Init') {
            steps {
				cleanWs() // Clear le dossier courant
				dir('backend') {
				    echo "Clone de l'application"
                    git branch: 'dev', url: 'git@gitlab.univ-nantes.fr:but-info-etu/info3/e2526/sae5/equipe-1-2/back-end.git', credentialsId: 'f2e308ef-3890-4969-867a-8d362fd3a81b'
				}
				dir('ci') {
				    echo "Récupération des scripts"
				    checkout scm
				}
            }
        }
		stage('Build') {
			steps {
			    dir('backend') {
    	        	withCredentials([file(credentialsId: "ktor-source-dev", variable: 'APP_CONFIG')]) {
    					script {
    						sh "mkdir -p src/main/resources"
    						echo "Injection fichier de configuration..."
    						sh "cp \"\$APP_CONFIG\" src/main/resources/application.yaml"
    					}
    				}
    
    				sh './gradlew build -x test'
			    }
			
			}
		}
		stage('Test') {
			steps{
			    dir('backend') {
    				sh './gradlew test'
			    }
			}
		}
		stage('SonarQube Analysis') {
			steps {
		        dir('backend') {
    				withSonarQubeEnv(installationName: 'sonar') {
    					sh "./gradlew sonar"
    				}
			    }
			}
		}
		stage('Docker build & Push registry') {
			steps {
			    dir('backend') {
    				script {
    					env.APP_VERSION = sh(
    						script: "grep -E \"^\\s*version\\s*=\" build.gradle.kts | head -n1 | sed \"s/.*=//; s/[ '\\\"]//g\"",
    						returnStdout: true
    					).trim()
    
    					sh """
    					    cp ../ci/scripts/app/deploy/deploy.sh .
                            chmod +x deploy.sh
                            ./deploy.sh -r "$REGISTRY" -b "$BUILDER_NAME" -a "$APP_NAME" -n dev -v "$APP_VERSION"
                        """
    				}
			    }
			}
		}
	}
	post {
		always {
			cleanWs(cleanWhenNotBuilt: false,
				deleteDirs: true,
				disableDeferredWipeout: true,
				notFailBuild: true,
				patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
					[pattern: '.propsfile', type: 'EXCLUDE']])
		}
	}
}