import logging
import sys

# Code based on VSCode template for Python Azure Function Apps and 
# https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-python?tabs=azure-cli#create-the-sample-code

import os
import azure.functions as func
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    credential = None
    Err = None
    msg = ""
    status_code = 200
    if not name:
        status_code = 201
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    try:
        credential = DefaultAzureCredential()
    except:
        the_type, Err, the_traceback = sys.exc_info()
        status_code = 500
        credential = None
        pass

    # except BaseException as e:
    #     return func.HttpResponse( e, status_code=200 )

    #     credentialErr = e
        

    if name and credential:
        keyVaultName = name
        KVUri = f"https://{keyVaultName}.vault.azure.net"

        try:
            client = SecretClient(vault_url=KVUri, credential=credential)

            secretName = "VaronisAssignmentSecret"
            
            print(f"Retrieving your secret from {keyVaultName}.")

            retrieved_secret = client.get_secret(secretName)

            print(f"Your secret is '{retrieved_secret.value}'.")
            
            msg = f"{retrieved_secret.value}"
        except:
            status_code = 500
            the_type, Err, the_traceback = sys.exc_info()
            pass
    else:
        msg = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

    if status_code != 200:
        if credential:
            msg += f"\nCredentials { credential }."

        if Err:
            msg += f"\nErr: { Err }"

    return func.HttpResponse( msg, status_code=status_code )
