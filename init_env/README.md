## buildimage

This folder contains the ansible code to call the imagebuilder service on console.redhat.com to build a RHEL image. The image gets used for the first two systems in our Red Hat Infrastructure Standard Adoption Model - the primary IdM server and the Satellite server. 

The code accomplishes the following tasks:
- connect to and test access to the imagebuilder API
- template an image definition
- initiate an image compose
- download the finished compose to our build orchestration machine
- upload the image to a target vcenter environment
- create a vm for idm and customize it
- create a vm for satellite and customize it

Once these tasks are complete the next phase of our build takes over - initializing the Identity Management environment.

### What you need to do

Check out the vars directory. There are a bunch of settings to configure the image and its file system layout. Our default is designed so the resulting image can meet most compliance standards from a file system layout perspective. 
You need a valid offline token from console.redhat.com to generate access tokens for the API. Store it in builder_vault.yml and encrypt it with ansible-vault.
You need to provide a bunch of other sensitive data - we use a model of <varsfile>_vault.yml and <variable_name>_vault to map sensitive data into our variables.

The userdata and metadata files are used to generate our cloud_init configuration to work with the RHEL image. Unfortunately there are some bugs in vmware that prevent some of the static configuration from sticking when using cloud init. We work around this by stuffing the configuration into our runcmd. It only needs to work once. :-)

Once you have configured your builder, idm, sat and vmware variables, you can run main.yml on from you build orchestration machine and wait for 20 minutes (or less if you are running something more powerful than a gen5 NUC) to check things out. If you are confident, the site.yml file in the root labbuilder directory will invoke buildimage/main.yml as part of building the whole environment.

### What to do next. 

If you have buildimage configuration all sorted out, the next step is to jump over to the idm folder and set up your idm users, groups, sudo, hbac, and other configuration for the environment. 



