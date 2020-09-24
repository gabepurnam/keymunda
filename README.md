KEYMUNDA = KEYCLOAK + CAMUNDA
=============================

This project is a basic way of putting the pieces together. After working
and trying to run [Camunda](https://github.com/camunda/camunda-bpm-platform)
with [Keycloak](https://github.com/keycloak/keycloak), I found some refs.

* https://github.com/camunda/camunda-bpm-identity-keycloak
* https://github.com/iceman91176/camunda-bpm-auth-keycloak-sso
* https://github.com/hmcts/chart-camunda
* https://github.com/codecentric/helm-charts/tree/master/charts/keycloak

The main work was on Dockerfile, where downloads of needed jars are made
and some configs and adjusts made in the base image to configure keycloak
server certificate, for example.

This project are not finished yet. Work in progress.

Thanks!

## Using Docker-Compose

First, you need to start Keycloak and configure it like [this](https://github.com/camunda/camunda-bpm-identity-keycloak#prerequisites-in-your-keycloak-realm)
So, run ``docker-compose -f docker-compose-keycloak.yml up -d``

After that, you need to download keycloak.json config file of your client
and save it at folder 'config/'.

Then you need to adjust docker-compose-camunda.yaml file with your config.
Finally, run ``docker-compose -f docker-compose-camunda.yaml up --build``

## Using Minikube or Helm Charts or Helmfile

To generate keycloak.json as a secret you need to run this command:
```
kubectl create secret generic camunda-config -n keymunda --from-file=conf/keycloak.json --dry-run -o yaml >
charts/camunda/camunda-config.yaml
```

To bring up your environment run ``helmfile sync``

