# Clone and run project
```bash
git clone https://github.com/it21846/djangoapp-docker.git
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
cd djangoapp
cp djangoapp/.env.example djangoapp/.env
```
edit djangoapp/.env file to define
```vim
SECRET_KEY='test123'
DATABASE_URL=sqlite:///../db.sqlite3
```
# run development server
```bash
python manage.py runserver
```
# K8S

## microk8s enable storage and dns ingress
```bash
microk8s enable storage dns
```

## Persistense Volume
```bash
kubectl apply -f k8s/db/postgres-pvc.yaml
```
## secrets
* pg secret

```bash
kubectl create secret generic pg-user \
--from-literal=PGUSER=<put user name here> \
--from-literal=PGPASSWORD=<put password here>
```

## configmaps
```bash
kubectl create configmap django-config --from-env-file=djangoapp/djangoapp/.env
```
## Deployments
* Postgres
```bash
kubectl apply -f k8s/db/postgres-deployment.yaml
```
* django
```bash
kubectl apply -f k8s/django/django-deployment.yaml
```

## Services
* Postgres
```bash
kubectl apply -f k8s/db/postgres-clip.yaml
```

* django
```bash
kubectl apply -f k8s/django/django-clip.yaml
```

## Ingress


check README.md in k8s/certs directory to create valid certificates



### Migrations?
### Static files? [whitenoise](http://whitenoise.evans.io/en/stable/)


## required apt  packages

```bash
sudo apt install python3-setuptools
```

## healthcheks
[django-helath-cheks](https://github.com/KristianOellegaard/django-health-check)


## Container registry

# docker registry
## Github Packages
* create personal access token (settings --> Developer settings -- > Persnola Access Tokens)
* tag an image
```bash
docker build -t ghcr.io/tsadimas/pms8-fastapi:latest -f fastapi.Dockerfile .
```
* login to docker registry
```bash
cat ~/github-image-repo.txt | docker login ghcr.io -u tsadimas --password-stdin
```
* push image
```bash
docker push ghcr.io/tsadimas/pms8-fastapi:latest
```

## create docker login secret

* create a .dockerconfigjson file, like this
```json
{
    "auths": {
        "https://ghcr.io":{
            "username":"REGISTRY_USERNAME",
            "password":"REGISTRY_TOKEN",
            "email":"REGISTRY_EMAIL",
            "auth":"BASE_64_BASIC_AUTH_CREDENTIALS"
    	}
    }
}
```


* create <BASE_64_BASIC_AUTH_CREDENTIALS> from the command
```bash
echo -n <USER>:<TOKEN> | base64
```
* create kubernetes secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dockerconfigjson-github-com
  namespace: default
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: BASE_64_ENCODED_DOCKER_FILE
```
where BASE_64_ENCODED_DOCKER_FILE is
```bash
cat .dockerconfigjson | base64 -w 0
```


Then pull an imgae from a private container registry add this to deployment (at the containers volumes)

```yaml
imagePullSecrets:
  - name: dockerconfigjson-github-com
```


##  Cert Manager

```bash
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml

helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.12.0
```

Links
* [pre-commit: A framework for managing and maintaining multi-language pre-commit hooks.](https://pre-commit.com/)
* [Github: Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
* [Personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
