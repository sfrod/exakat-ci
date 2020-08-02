# Exakat Docker Container - SAST stage for Gitlab CI/CD Pipeline
[Exakat](https://www.exakat.io/) is a static analysis engine a tool for analyzing, reporting and assessing PHP code source efficiently and systematically. Exakat processes PHP 5.6 to 7.4 code, as well as reporting on security, performance, code quality, migration.
Common best practices and recommendations for specific plat-forms such as Laravel, Wordpress, CakePHP or Drupal Framework are covered. Check all supported [Frameworks here.](https://exakat.readthedocs.io/en/latest/Extensions.html)

We propose a [Docker](https://www.docker.com) container to install and run [Exakat](https://www.exakat.io/) 2.0.6 locally or as a part of a Static Application Security Testing (SAST) stage for Gitlab CI/CD Pipeline Integration. The resulted analysis reports can be retrieved as artefacts. See [Gitlab CI/CD Pipeline Integration](#gitlab-ci/cd-pipeline-intergration) section.

## Built With

* [Exakat](https://www.exakat.io/) [`2.0.6`](https://github.com/exakat/exakat.git)
* [PHP](https://php.net) 7.4 binary for exakat execution
* [PHPBrew 1.26.0]( http://phpbrew.github.io/phpbrew) PHP 7.3, 7.2, 7.1, 7.0, 5.6 (PHP with tokenizer and mbstring) for exakat analysis
* [Gremlin Server](http://tinkerpop.apache.org/) 3.4.6
* [Neo4j Gremlin](http://tinkerpop.apache.org/) 3.4.6
* [Git](https://git-scm.com/), [Mercurial](https://www.mercurial-scm.org/), [Composer](https://getcomposer.org/)

## 1) Run Local Code Analysis

1. Install the sfrod/exakat-ci container:

    ``` sh
	$ docker pull sfrod/exakat-ci:latest
	```
### Use Cases

1. Run Exakat PHP analysis and mounting an existing directory to fetch the reports:

    ``` sh
    $ mkdir reports
	$ docker run -v <path/to/project/folder>:/src/ -v \ $(pwd)/reports:/report/ sfrod/exakat-ci:latest
    ```

2. Run Exakat PHP analysis and creating a volume called 'reports' to fetch the reports:  
    ``` sh
    $ docker run -v <path/to/project/folder>:/src/ -v reports:/report/ sfrod/exakat-ci:latest
    ```

3. Run Exakat PHP analysis based on a framework. Check all supported [Frameworks here.](https://exakat.readthedocs.io/en/latest/Extensions.html) : 

    ``` sh
    $ docker run -v <path/to/project/folder>:/src/ -v $(pwd)/reports:/report/ sfrod/exakat-ci:latest Laravel
    ```

## 2) Gitlab CI/CD Pipeline Intergration

1. Add this stage in your .gitlab-ci.yml file. Or take a look at our template-gitlab-ci.yml file. Reports can be retrieved as artifacts at the end of the job. Analysis using Frameworks are in Text format named as Ext_'used Framework'_report.txt.

    ``` yaml
    stages:
       - sast
  
    sast:
        stage: sast
        image: docker:latest
        services: 
        - docker:18-dind
        variables:
        DOCKER_DRIVER: overlay2
        SHARED_PATH: /builds/$CI_PROJECT_PATH/shared
        script:
        - mkdir -p ${SHARED_PATH}
        - docker run -v $CI_PROJECT_DIR:/src -v ${SHARED_PATH}:/report sfrod/exakat-ci:latest Laravel
        artifacts:
        when: always
        paths:
            - /builds/$CI_PROJECT_PATH/shared/*
	```

## Disclamer

This is an unofficial build and my try to build an exakat container to integrate it as a Static Application Security Testing (SAST) stage at Gitlab CI/CD Pipeline workflow.
