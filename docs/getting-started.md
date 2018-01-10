# Prerequisites

You should have these packages installed:

1. [Kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

  - Download the binary for your OS
  - Unzip it and run `chmod +x kubectl && sudo mv kubectl /usr/local/bin/kubectl`
  - Check if the kubectl is installed by running `kubectl version`

2. [Vault](https://www.vaultproject.io/docs/install/index.html)

  - Download the binary for your OS
  - Unzip it and run `chmod +x vault && sudo mv vault /usr/local/bin/vault`
  - Check if the Vault is installed by running `vault -v`

3. [Google Cloud SDK](https://cloud.google.com/sdk/downloads)

  - Enter the following at a command prompt: `curl https://sdk.cloud.google.com | bash`
  - Restart your shell: `exec -l $SHELL`
  - Run gcloud init to initialize the gcloud environment: `gcloud init`

4. [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)

  - Download the binary for your OS
  - Unzip it and run `chmod +x helm && sudo mv helm /usr/local/bin/helm`
  - Check if the Helm is installed by running `helm version`

5. [Concourse](https://github.com/concourse/fly)

  - Download the binary for your OS
  - Unzip it and run `chmod +x fly && sudo mv fly /usr/local/bin/fly`
  - Check if the fly is installed by running `fly -v`

## Usage

1. Run your Docker image locally with `make run`

2. Push the Docker image to the registry using `make push`, so that Concourse and Kubernetes can fetch the image when needed

3. Deploy the Concourse pipeline using `make ci`, this will create and unpause a new pipeline named by your service.
   To further configure your pipeline, edit the `*output_dir*/pipelines/review.yml`

4. To add/change/delete Vault secrets to use in the pipeline, run
   ```shell
   export VAULT_ADDR=https://vault.example.com
   vault write concourse/<team>/<secret> value=<value> # save secret to storage
   vault read concourse/<team>/<secret> # read value of secret
   vault delete concourse/<team>/<secret> # delete secret
   ```

5. Deploy the helm chart using `make deploy`.

   Charts are basically Kubernetes config files which can be used as templates, packaged and easily distributed.

   To deploy a Helm chart you only need the template files(`*output_dir*/charts/*service_name*/templates`)
   and the values for them(`*output_dir*/charts/*service_name*/values.yaml`).
   Values can be specified either from command line by using `helm install *chart* --set "optionFoo=bar"`
   or from a file by using `helm install *chart* -f *values-prod.yml*`

   `make deploy` command runs
      `helm install ./*output_dir*/charts/*service_name* --set "image.tag=$(VERSION)"`
   which installs this service's helm charts with current Docker image tag specified

   To list the deployed Helm charts, use `helm ls`

   To apply changes made to the chart, use `helm upgrade *deployment name* *output_dir*/charts/*service_name*`

   To access your deployment locally:
   - Get pod name `export POD_NAME=$(kubectl get pods --namespace default -l "app=<%= @name %>,release=elder-ibis" -o jsonpath="{.items[0].metadata.name}")`
   - Port-forward the pod to localhost `kubectl port-forward $POD_NAME *local_port*:*image_port*`
   - Visit http://127.0.0.1:*port* to use your application
   - See current status of deployments `kubectl get deployments`, pods `kubectl get pods`, services `kubectl get service`
