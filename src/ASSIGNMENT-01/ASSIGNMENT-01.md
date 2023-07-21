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

## Explaining my decisions/code structure

I really dislike retyping commands again and again, so I create
"templates" within the code that I can reuse.

In this instance, each operation/action is stored in a hash table along
with it's identifying Log details.

This way, I can focus on creating sequences of these Actions, and have
my script just load each action until something either fails, or the
run completes.

That's the purpose of `$Automation`.

### Why not `$Automation` all the way?

I had an option here to populate the $Automation list, and then just
run the sequence. I decided against it.

The sequence is supposed to be a success-only sequence. If something
breaks, exit. Adding users might fail, it should continue to the next
user.

Becasue there is a non zero time action involved in testing whether the
user already exists, or is already a member of the group, I decided to
run each user action, including evaluating it's state individually.
This reduces the risk of caching an incorrect state, as well as the time
involved to reach an error state, should one arise.
