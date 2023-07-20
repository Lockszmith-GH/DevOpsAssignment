# Starting from scratch on Windows 11

1. Signed up for Azure Free account at <https://portal.azure.com>
2. Installed [Az PowerShell Module](https://github.com/Azure/azure-powershell/releases/tag/v10.1.0-July2023) and connected the Azure Account for the first time.

    ```PowerShell
    Install-Module -Name Az -Repository PSGallery -Force
    Connect-AzAccount
    ```

3. Install AzureAD PowerShell Module and Connect to the default Azure AD tenant for the first time

    ```PowerShell
    Install-Module -Name AzureAD -Repository PSGallery -Force -AllowClobber
    Connect-AzureAD
    ```
