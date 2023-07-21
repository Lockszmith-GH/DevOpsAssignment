# Starting from scratch on Windows 11

1. Signed up for Azure Free account at <https://portal.azure.com>  

   ~~2. Installed Az PowerShell Module ...~~  
   ~~3. Install AzureAD PowerShell Module ...~~
   ~~3. Install Microsoft Graph Module ...~~

2. Working with **mcr.microsoft.com/microsoftgraph/powershell** docker
   container.  
   Chose this path after failing to setup my personal local
   Windows 11 machine with the above libraries, realizing this should
   have been my first choice.

   NOTE: All console actions described below are from within the docker
   container.  
   All Web UI action were done on my personal machine. I do not describe
   the process of copying over the file from the container / remote
   machine into my local-browser machine.

   ```console
   # bash command line:
   docker run --rm -it -v "$PWD/data:/data" \
      -v "$PWD/data/.dotnet:/root/.dotnet" \
      -v "$PWD/src:/data/src" \
      -w "/data" \
      mcr.microsoft.com/microsoftgraph/powershell
   ```

3. Following [this tutorial page](https://learn.microsoft.com/en-us/graph/tutorials/powershell-app-only?tabs=linux-macos&tutorial-step=1#register-application-for-app-only-authentication)
   I've created the following utility scripts to help with this process:

   1. [`Create-Cert`](Create-Cert.ps1) -  
      Create a self-signed certificate and load it into the .NET
      cert-store (see Load-Cert next).
   2. [`Load-Cert`](Load-Cert.ps1) -  
      Load certificate files into the local .NET cert-store.
   3. [`Connect-AppCert`](Connect-AppCert.ps1) -  
      This will be used to establish a new app connection.
