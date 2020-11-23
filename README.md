# Terraform Module for Dokku Environments on Digitalocean

As the name implies this is a Terraform module to create [Dokku](http://dokku.viewdocs.io/dokku/) instances on Digitalocean - without using the web UI. See the `examples/main.tf` for an example usage, see `var.tf` for the parameter description of the module. `examples/create_spring_app` also contains an automation to create a demo Spring Boot App and configure it with the dokku instance.


## I'm new to Cloud and/or Terraform, please hold my hand 🤝.

Requirements:

* [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* Optional: Install the [Dokku CLI](http://dokku.viewdocs.io/dokku/deployment/remote-commands/#official-client) for making working with repositories a little easier.

Create a Token [in the Digitalocean web UI](https://cloud.digitalocean.com/account/api/tokens) and expose it to your current shell:
```shell
export DIGITALOCEAN_TOKEN=10fcaf...
```

Now copy the `examples/main.tf` to an empty folder, make sure that `public_key` is pointing to an SSH public key that you want to use and is registered in your agent (`ssh-add <private-key-file>`). Now run:
```shell
terraform init
terraform apply
```

Confirm with `yes` when prompted to apply the plan.

Once the Terraform execution is finished go and drink a coffee. Cloud-init works asynchrounsly and will take around five minutes. If you want you can run the `wait_until_up` command that is printed after executing terraform by calling:

```shell
eval $(terraform output wait_until_up)
```

That's it you can now use Dokku to deploy your applications. A simple demo to get you started can be created by running the following script in an empty folder:
```shell
./examples/create-demo-app.sh <hostname/IP of droplet>
```

It will:
1. Initialize a Spring Boot Repo including creating a `system.properties` for Dokkus Java 11 support.
2. Create a Postgres and Dokku app and link them together.
3. Deploy the application to the Dokku instance.

Run the printed `curl` command to test the installation. Change code and push to the dokku branch to deploy changes.

Next Steps:

* Check the script and understand how it works.
* Play with the CLI. e.g. from the Git repo folder of the demo app run `dokku logs demo`.
* [Read the docs] for more advanced usage and how to manage apps.


Done with testing? Clean up everything with:
```shell
terraform destroy
```

## FAQ

**Q:** Isn't there a Dokku image [on the Digitalocean Marketplace](https://marketplace.digitalocean.com/apps/dokku) that does exactly this?  
**A:** Yes, but the droplet creation and first configuration requires manual configuration through a browser. The module provides an unattended installation and makes it trivial to repeat this step a hundred times. Additionally having this in Terraform makes it easy to create more environments and to configure other resources together with the instance e.g. combine the droplet IP with your DNS config.
