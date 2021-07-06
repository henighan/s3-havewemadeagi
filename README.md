# [havewemadeagiyet.com](https://havewemadeagiyet.com)
This repos holds the resources for making website [havewemadeagiyet.com](https://havewemadeagiyet.com). I shamelessly stole the idea from the creators of [hasthelargehadroncolliderdestroyedtheworldyet.com](http://hasthelargehadroncolliderdestroyedtheworldyet.com).
This was a fun project for me to learn terraform, cloud infra stuff, and about how websites work.
Previous version can be found [here](https://github.com/henighan/havewemadeagiyet).

## Install Stuff
[Install Aws Cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

[Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)


## Managed Certificate
### Create Certificate
First create a managed aws certificate on amazon with the following:
```bash
aws --region us-east-1 acm request-certificate --domain-name havewemadeagiyet.com --validation-method DNS --subject-alternative-names www.havewemadeagiyet.com test.havewemadeagiyet.com
```
Note that this _has_ to be in us-east-1 for some reason (blame amazon).

### Validating Certificate
After creating this certificate, navigate to the amazon certificate manager in the console. You'll see this newly created certificate says "validation pending" or something similar. You need to add some CNAME records to the domain name (in this case, havewemadeagiyet.com) to validate it. The required CNAME records can be found in the console by expanding the dropdown for the certificate of interest, then expanding the dropdowns for each of the domains.

I'm using google as the domain registrar. Note that in google domains, you should exclude the `havewemadeagiyet.com` postfix in the name, as its added automatically (this caused me some confusion).

Once you've added the new CNAMES, you can make sure they work with:
```bash
> dig +short _abcdefg1232.havewemadeagiyet.com.
_xyzefg.blabla.acm-validations.aws.
```

Then you just have to wait a few minutes, and the certificate status should change to "issued".

## S3 and Cloudfront Resources
Copy the arn of the certificate and add it to a file called `terraform.tfvars` in this directory like so:
```terraform
SSL_ARN="arn:aws:acm:us-east-1:...."
```

Then from this directory run:
```bash
> terraform init
> terraform apply
```

Terraform will then ask you to type "yes" to verify that you want to create the resources.

This will create a cloudfront distribution and s3 bucket containing our `index.html`.

Once compete, you should see an output like this:
```bash
bucket_endpoint = "havewemadeagiyet.s3-website.us-east-2.amazonaws.com"
cloudfront_endpoint = "d1xmhddohfhtrw.cloudfront.net"
```

At this point, you should be able to see the website hosted at either of these locations. The first will only support http, while the second should be https (and forward http requests to https).


## Update Apex DNS Record
We now want to point our domain name (havewemadeagiyet.com) to the cloudfront endpoint (d1xmhddohfhtrw.cloudfront.net). The natural way to do this would be to add an ALIAS dns record.
However.... google domains [does not support ALIAS records](https://serverfault.com/questions/617248/does-google-domains-support-cname-like-functionality-at-the-zone-apex) 😢. I am considering switching DNS registrars for this reason.
To get around this, I used [this dirty hack](https://serverfault.com/a/714357). I added a CNAME record which points wwww.havewemadeagiyet.com to d1xmhddohfhtrw.cloudfront.net. Then I added a "subdomain forward" synthetic record, which points the apex domain to www.havewemadeagiyet.com.
Not pretty, but seems to work.
