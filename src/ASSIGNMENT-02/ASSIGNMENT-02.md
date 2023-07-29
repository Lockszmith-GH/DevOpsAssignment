# 2nd Assignment

## Main Challanges

Azure is a new envionrment for me, but my experience within GCP has been
helpful in navigating my needs.

I've never deployed function apps before (not even in GCP), but the
concept was rather clear to me.

I learned how to creat a System Assigned Managed Role to the azure func.
I also learned how to assign it to the Key Valult's Secret-User roles.
(I did this manually on each vault, as the free account does not allow
creation of custom roles, which is probably what I would use in a
production envrionment)

I learned how to allow Visual Studio to create the function app and
deploy the code. Something I had to troubleshoot at first, as my first
setup failed to deploy multiple times.
Seems that newbies to this realm, based on my searching for solutions,
face similar issues - but I eventually overcame those hurdles by
correctly deploying a fresh Funciton App.

## Script logic

The script itself is rather simple, I based it on the template HTTP
trigger function from the VS Code template.

I added authentication and the KeyVault logic, and added error handling
and reporting code.

After a successful local run, I created a requirements.txt file and 
deploeyd the function app to Azure.

### Notes about current implementation

In a production public (without authentication of any sorts) facing page
I would not leave the error reporting code as it is, and rely more on
logging, but since I'm unfamiliar with the logging constructs preferred
I ommitted this at this time.

## How to use:

The App's URL is:

> <https://anysecrets.azurewebsites.net/api/getsecret>

It takes a single argument `name` which is the Vault's name to pull the
secret from (GSzVaronisAssignmentKv1, GSzVaronisAssignmentKv2 or
GSzVaronisAssignmentKv3)

For example:

> <https://anysecrets.azurewebsites.net/api/getsecret?name=GSzVaronisAssignmentKv2>

When name is not supplied, some identifying details are presented for
troubleshooting purposes.

When an exception occured, the error message will be printed.
