# 1st Assignment

## Main Concerns

### Authentication

Since this might be run in production, permissions should be assigned
to the script, and not necessarily to the user executing the script.

The first step in developing the script, is to make sure authentication
is configured properly.

I'm using Microsoft Graph API in PowerShell, and so I've followed [MS's
guide](https://learn.microsoft.com/en-us/graph/tutorials/powershell-app-only?tabs=linux-macos&tutorial-step=1)
on setting up Application authentication.

### Logging

Logging seems to be an imperative aspect of the task, so I started by
thinking about how do I track the operations.

I came up with 2 clasess:

- LogEntry - containing the relevant details for each action. This
   includes:

   ```PowerShell
   [DateTime]Timestamp
   [String]Operation
   [String]OperationDescription
   [TimeSpan]Duration
   [String]FinalStatus
   ```

- LogTrail - A class to manage the `logs` typed list within it.

These classes allow me to easily manage logs in a consistent pattern.

## Script logic

1. The first thing the script will do is test a connection has already
   been established.
2. Create the group if it does not already exist.
3. Iterate through the list of users, for each
   + If the user doesn't exist, it will create the user.
   + If the user isn't a member of the above mentioned group, add it to it.
4. Display the report.
