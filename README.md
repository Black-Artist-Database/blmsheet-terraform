# BLMSheet Terraform

This repository was inspired by Rob Charlwood's Medium tutorial - ["Multi Region Load Balancing with GO and Google Cloud Run - Part 2"](https://medium.com/@bitniftee/multi-region-load-balancing-with-go-and-google-cloud-run-part-2-a30ac47eaaa4) and acts as the partner of and infrastructure for the Google Run application ["BLMSheet"](https://github.com/jcox-dev/blmsheet).

## Checkout and setup
To work with this codebase, you will require the below to be setup and configured on your machine.

* ``terraform`` at version ``0.12.28``
* Google Cloud SDK (``gcloud``) at version ``300.0.0`` or greater with the ``beta`` component installed.

To set this codebase up on your machine, you can run the following commands:

```bash
git clone git@github.com:jcox-dev/blmsheet-terraform.git
cd blmsheet-terraform
```

Next up, You'll need your terraform service account key from part 1 of the tutorial placed into a ``.keys`` directory in the root of
this checked out repo.

Then you need to update the ``terraform.tfvars`` with details applicable to your project e.g

```terraform
project       = "multi-region-cloud-run"
region        = "europe-west1"
image_name    = "multi-region-cloud-run"
image_version = "0.0.1"
registry      = "eu.gcr.io"
domain        = "example.com"
```

Finally, you'll need to create a new empty configuration in the ``gcloud`` SDK for terraform work with.
This configuration should be named the same as your Google cloud project since terraform will automatically switch configuration profiles for you in order to run in configuration that cannot yet be provisioned with standard terraform resources.

```bash
gcloud config configurations create my-google-project-name
```

## Running the terraform

Once all setup above is completed, you can run in the terraform with the below commands to provision all the required infrastructure.

```bash
terraform init
terraform plan
terraform apply
```

## For those interested
For people with a curious nature, the main meat of the infrastructure that makes multi region load balancing possible lies [here](https://github.com/robcharlwood/multi-region-cloud-run-terraform/blob/master/compute/main.tf#L45-L154).

## Versioning

This project uses [git](https://git-scm.com/) for versioning.

## Authors

* Jamie Cox
* Rob Charlwood - Bitniftee Limited (original)

## License

This project is licensed under the CC0-1.0 License - please see the [LICENSE.md](https://github.com/robcharlwood/multi-region-cloud-run-terraform/blob/master/LICENSE) file for details
