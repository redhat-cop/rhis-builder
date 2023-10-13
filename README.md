# labbuilder2
Be sure to check out the [Wiki](https://github.com/parmstro/labbuilder2/wiki)

Welcome to version2 of lab builder. We have changed the project to focus on building virtual environments instead of physical environments. In its current iteration, labbuilder2 requires a VMware environment to start off. If you want to build some physical systems in place of the IdM and Satellite nodes, that shouldn't be a problem, however, it is left as an exercise for the user.

## Lab builder goals

The goal of this project is to build a Red Hat based lab environment suitable for demostrating the a Red Hat infrastructure that implements several  Standard Operating Environments for Red Hat Enterprise Linux. There will be more documentation and presentation material made available later, but for now, please check out the [Wiki](https://github.com/parmstro/labbuilder2/wiki)

When completed Lab builder should be able to deploy all parts of the standard infrastructure on any hypervisor or cloud (or combinations thereof). The basic deployment builds a lab on VMware, sets up the the hosting VMware cluster as a compute resource in Satellite and deploys the rest of the hosts on that cluster. The build is controlled by a provisioning node (usually your laptop) that kicks off the main ansible playbook, site.yml.

The lab build includes:
  - creating and downloading a base image from Red Hat image builder on console.redhat.com
  - Red Hat Identity Management primary server with "POC" users, groups, HBAC and sudo, etc..
  - Red Hat Satellite with all the bells and whistles turned on
  - Red Hat Ansible Automation Platform controllers, an execution environment and sample workflows for managing Satellite content
  - Red Hat Ansible Automation Hub
  - 2 x Container hosts that run tang servers in containers to manage NBDE for some of the sample hostgroups
  
## Lab builder non-goals

It is not currently a goal of lab builder to create a production environment, although it could do that for small environments. The flexibility to build a completely custom production environment is not there yet.


## High Level Flow

- collect the credentials and config elements needed
- plan your deployment
- configure the appropriate variable files and inventory
- run ansible-playbook -i inventory site.yml
- make coffee, pull out your favourite game console

## Preparation

We can break lab builder flow into a number of phases. 
- create the image and load it to our target
- bootstrap our idm system and configure it
- bootstrap our satellite system and configure it
- bootstrap ansible and our other hosts

Each of these phases requires configuration. We are going to keep it simple for this overview. 1 Idm server, 1 satellite, 1 automation controller, 1 hub, and 2 container hosts (we want redundancy for our tang servers). To even get started, we need to gather some credentials. 

You need a login to access.redhat.com and need to create an offline API token. The information on this process is located [here](https://access.redhat.com/articles/3626371). If you are familiar with the process, you can jump right to your [API Token management page](https://access.redhat.com/management/api). You will also need the organization number of your red hat account and the name of an activation key that will enable your IdM server and Satellite server. Attach the proper subscriptions to the activation key to enable the deployment of the two servers. These servers will start out registered directly to the CDN, once the Satellite server is built, the IdM server will unregister from the portal and re-register to the Satellite server that you build. You can plan accordingly.

You also need access to the target VMware instance that you are going to build your lab on. For now Labbuilder uses only VMware, however, we are working diligently to add other providers and will eventually support other hypervisors and the hyperscalers. For VMware, you need a service account that allows you to upload images to storage and create virtual machines. You should be able to use any account that meets the criteria for a [Satellite compute resource](https://access.redhat.com/solutions/1339483). In short in needs the following:

  - All Privileges -> Datastore -> Allocate Space, Browse datastore, Update Virtual Machine files, Low level file operations, Update virtual machine metadata
  - All Privileges -> Network -> Assign Network 
  - All Privileges -> Resource -> Apply recommendation, Assign virtual machine to resource pool 
  - All Privileges -> Virtual Machine -> Change Configuration (All) 
  - All Privileges -> Virtual Machine -> Interaction (All) 
  - All Privileges -> Virtual Machine -> Edit Inventory (All) 
  - All Privileges -> Virtual Machine -> Provisioning (All)
  
As a general note, we are using ansible vault for storing our credentials and follow a standard pattern. For each variable file that stores encrypted variables, we also have a corresponding file _vault.yml. For example:
- builder_vars.yml
- builder_vault.yml

When we have a variable secret that we are vaulting we reference a vaulted variable using variablename_vault, like this:
- offline_token: "{{ offline_token_vault }}"

To see a list of the variables used in each of the phases see the appropriate wiki page as outlined below. 

## Phase 1 - build the image and load it to the target

This phase uses a variety of information to:
- define and build a base image from current rpms on the Red Hat CDN using imagebuilder.
- download the image to the provisioning system
- upload the image to your vmware datastore
- initialize an IdM primary server
- initialize a Satellite primary server
- ensure proper storage layout for the Satellite

At the end of the phase, we will be ready to deploy the IdM server.

There are numerous variable files for this phase as we are dealing with multiple systems. 
See the Wiki page for [configuring the buildimage variables](https://github.com/parmstro/labbuilder2/wiki/Configuring-the-buildimage-variables).

## Phase 2 - bootstrap the Identity Management server

In this phase we deploy the IdM primary including:
- configure the IdM prerequisites
- deploy and configuring the base IdM deployment - IdM + CA + DNS
- create the POC user groups
- create the POC users
- create and assign the HBAC rules
- create and assign the sudo rules
- ensure that foreman-proxy configuration exists for DNS zone update.
- configure any DNS zone forwarding

At the end of this phase we have a fully functional IdM Realm with integrated certificate authority and DNS.
Please note, we don't support the generation of a CSR yet for external signing. This will come in a future iteration.

See the Wiki page for [configuring the idm variables](https://github.com/parmstro/labbuilder2/wiki/Configuring-the-IdM-variables).

## Phase 3 - bootstrap the Satellite server

This is a truly massive section. This phase installs and fully configures a Satellite server. The configuration of Satellite has two components - those configuration components that are considered mandatory for the functionality of our demonstrations and those components that are optional. The optional configuration components are those that you want to add to customize the environment for your builds or that perhaps you are working on for a new example/demonstration/deployment. By setting up mandatory and optional components it allows you to generate a build that you know works and then slowly add to it without mucking up stuff that you know works. The configuration covers almost every aspect of Satellite including:
- configure the Satellite prerequisites
- registering the satellite to Identity Manager
- creating certificates for the Satellite instance
- preparing the IdM realm to support Satellite integration
- (generate a user for kerberos integrated remote execution)
- defining and running the Satellite installation

### Content Configuration
  - configure hammer
  - download and install a Red Hat manifest to access content.
  - configure Red Hat repositories.
  - configure content credentials
  - configure any custom products and repos e.g. MSSQL Server for Linux
  - synchronize the content (warning can take a loooonnnng time depending on your link)
  - create the sync plans
  - attach the sync plans to content
  - create the life cycle environments
  - create the content views including filters, rules and target lifecycle environments
  - create the composite content views
  - publish and promote initial versions of content views and composite content views
  
### Provisioning Configuration
  - configure installation media
  - configure partition table templates
  - configure job templates
  - configure provisioning templates
  - configure template synchronization
  - configure operating systems
  - configure activation keys and content restrictions
  - configure network domains
  - configure kerberos realms
  - configure subnets
  - configure PXE provisioning defaults
  - configure compute resources
  - configure compute profiles
  - configure virt-who
  - attach subscriptions to virt-who hypervisors
  - configure git repos for ansible modules
  - download ansible roles for SCAP
  - load roles
  - configure OSCAP content
  - configure OSCAP tailoring files
  - configure OSCAP policy
  - configure discovery rules
  - configure global parameters
  - configure hostgroups
  
  There are a couple of items missing, notably the configuration of users and the configuration of cloud connector for Red Hat Insights. These are works in progress.
  
  See the Wiki page for [configuring the satellite variables](https://github.com/parmstro/labbuilder2/wiki/Configuring-the-Satellite-variables).

## Phase 4 - Provisioning other hosts

In this phase we deploy the remaining hosts in our configuration. With Satellite deployed and configured with a compute resource and bare metal discover, this section can be as large as we want. 

In our sample configuration, this phase deploys 4 additional servers. These servers can be deployed on bare metal or vmware. If using bare metal pxe provisioning must be allowed and your configuration must point next-server to the Satellite. VMware deployments are also pxe based. 

Aside: We are adding code to register VMware images - a work in progress. We will provide 3 methods. 
 1. Register an existing template image with Satellite
 2. Build a system with Satellite via PXE, save as a template and register the image with Satellite
 3. Build an image with imagebuilder, upload to the compute resource and register with Satellite (this will eventually work for cloud providers as well).
 
We build the AAP controller node - currently 1, but trivial to make a cluster, including:
  - build the server instance using Satellite, includes configuring the hosts as IdM clients
  - download and extract the installer
  - template our setup configuration
  - launch ansible controller installer
  - create and configure IdM certificates for the controller
  - build an exection environment with the proper certs for Satellite
  - register the execution environment
  - import the sample AAP configuration - inventories, projects, credentials, templates, workflows, etc.
  - configure AAP for integrated authentication with IdM
  - test the configuration
  
We build the AAP hub node - currently 1, including:
  - build the server instance using Satellite, includes configuring the host as IdM client
  - download and extract the installer
  - template our setup configuration
  - launch the ansible hub installer
  - create and configure IdM certificates for the hub
  - configure the remote repositories - automation hub, ansible galaxy
  - configure synchronization
  
We build 2 container hosts to support our [tang servers](https://github.com/latchset/tang) for [Network Bound Disk Encryption (NBDE)](https://access.redhat.com/articles/6987053)
  - build the server instance using Satellite, includes configuring the host as IdM client
  - download the tang container to each host
  - configure and test the container deployment
  - register the tang server urls with Satellite for encrypted deployments

See the Wiki pages for [configuring Ansible hosts](https://github.com/parmstro/labbuilder2/wiki/Configuring-the-Ansible-hosts) and [configuring the NBDE hosts](https://github.com/parmstro/labbuilder2/wiki/Configuring-Container-hosts-for-NBDE-tang-servers).


## Phase 5 

Finally, we test the entire configuration by launching a content promotion pipeline from ansible. This section is based on the [Automating Content Management project](https://github.com/parmstro/AutomatingContentManagement) and the Automating Content Management blog series on redhat.com.


