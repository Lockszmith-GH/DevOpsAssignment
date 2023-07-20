# DevSecOps Interview Assignments - PowerShell/Python

- Received the 'Home Work' from Nir Rozenblum
  + Important hint:
    - Consider that your code should be able to run multiple times and
      achieve the end goal successfully. it means that the code must be
      robust and not break (imagine that it will run several times as
      part of a production system workload).
      Please share the below assignments results by uploading it to your
      own repository (such as GitHub, GitLab, Bitbucket etc.)  
  + If you don’t have an Azure account, create a new free Azure account
    at <https://azure.microsoft.com/en-in/free/>
  + Assignment 1: PowerShell script that interacts with Azure Active
    directory.
    - Create a PowerShell script that interacts with Azure Active
      directory and does the following:
      + Creates 20 Azure Active Directory User accounts with the name of
        `Test User <Counter>`.
      + Creates an Azure Active Directory Security group with the name
        of `Varonis Assignment Group`.
      + Adds each of the user accounts created in the previous step to
        the `Varonis Assignment Group`, the accounts should be added
        separately, and not as a bulk.
      + The script should generate a customized log that includes the
        following details for each attempt to add the user account to
        the security group:
        - Username
        - Timestamp of the attempt to add the user to the group.
        - Result of the attempt (successfailure)
      + Notice: Errors must be handled properly such that in the end of
        the process all the users that were created will be added to the
        group successfully.
  + Assignment 2: Python based Azure Function App that interacts with
    Azure Key Vault.
    - Prerequisite:
      + create the following Key Vault resources (no automation required
        in this step)
        - 3 x Azure Key Vaults: `VaronisAssignmentKv1`,
          `VaronisAssignmentKv2` and `VaronisAssignmentKv3`.
        - In each Key Vault, add a secret named `VaronisAssignmentSecret`
          that contains some secret value.
      + Create a Python based Azure Function App that does the following:
        - The Function app should be triggered via simple HTTP Trigger.
        - The HTTP trigger would accept as parameter a secret name, for
          example:

          > ```plaintext
          > https://assignment-func.azurewebsites.net/api/KeyVaultSecret?name={secret_name}
          > ```

        - If the function is triggered with a secret name of an existing
          secret that was created in the previous step (for example:
          `VaronisAssignmentSecret`)
          It should read that key vault secret and print the following
          properties:
          + Name of the Key Vault.
          + Name of the Key Vault secret.
          + The Creation date of the secret.
          + The secret value.
        - If the secret does not exist, the function will not expose any
          information but will return a generic error.
        - Add a screen shot of the function execution, or better,
          provide a URL to trigger the function.
        - Try to write production level code, we want to see how you
          code in real life.
  + Assignment 3: Create Azure Infrastructure resources via Terraform
    - Use Terraform to deploy all the infrastructure resources described
      in the below diagram, note the following guidelines:
      + In two different regions, deploy
        - 2 x Azure VMs
        - 1 x Azure Load Balancer
        - \+ all the required network resources (vNet, Subnets, NICs etc.)
      + The load balancers should be connected to the VMs in each region.
      + Deploy a single Azure Traffic Manager (no matter which region)
        that will use the load balancers as endpoints.
      + Connections towards the Traffic Manager FQDN should be routed to
        the region that is closer to the end user.
      + Consider needed security controls, such as NSGs, Firewalls,
        application gateways if applicable.
      + Feel free to use whichever OS or port configuration you desire,
        the focus is on the infrastructure components, no application
        needed to be configured on the VMs.
      + In addition, create a dedicate Azure Storage account in each
        region, and ensure that only the VMs has access to it – there
        are several ways to achieve that, think about the most efficient
        one.

      ```mermaid
      flowchart BT
        atm["Azure Traffic Manager"]
        subgraph eus["East US region"]
            direction BT
            subgraph "eus-deployment" ["East us vNet"]
                alb-eus["Azure Load Balancer<br/>Public IP/FQDN"]
                vm1-eus["Azure VM 01"]
                vm2-eus["Azure VM 02"]
            end
        end
        subgraph neu["Noth Europe region"]
            direction BT
            subgraph "neu-deployment" ["Noth Europe vNet"]
                alb-neu["Azure Load Balancer<br/>Public IP/FQDN"]
                vm1-neu["Azure VM 01"]
                vm2-neu["Azure VM 02"]
            end
        end

        atm --- alb-neu & alb-eus
        alb-eus --> vm1-eus & vm2-eus
        alb-neu --> vm1-neu & vm2-neu
      ```
