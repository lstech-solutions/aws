---
title: Connect with SMTP and IMAP
description: Configure incoming IMAP and authenticated outgoing SMTP for TLÁO Mail.
---

# Connect your email application

Choose **Other account**, **Manual setup**, or **IMAP** in your mail app.
Enter the server details issued by your administrator.

## Connection settings

| Setting             | Incoming mail                           | Outgoing mail                     |
| ------------------- | --------------------------------------- | --------------------------------- |
| Protocol            | IMAP                                    | SMTP                              |
| Server hostname     | `<mail-host>`                           | `<mail-host>`                     |
| Recommended port    | **993**                                 | **587**                           |
| Connection security | **SSL/TLS**                             | **STARTTLS**                      |
| Authentication      | Password                                | Password; authentication required |
| Username            | Your full mailbox login                 | The same mailbox login            |
| Password            | Main password or an issued app password | The same applicable credential    |

**Alternative SMTP:** port **465** uses **SSL/TLS** from the start of the
connection. Use it when your app supports implicit TLS instead of STARTTLS.
Do not pair port 587 with implicit SSL/TLS, or port 465 with STARTTLS.

:::tip Which hostname?
Use `<mail-host>`, not the webmail URL. Enter only the hostname in the server
field, without `https://` or a path. Use the exact issued hostname so it matches
the server certificate.
:::

## Set up a desktop or mobile client

1. Add a new mail account and enter your display name and email address.
2. Select manual IMAP configuration if automatic discovery does not fill in the issued settings.
3. Set incoming mail to port **993**, with **SSL/TLS**.
4. Set outgoing mail to port **587**, with **STARTTLS**, and enable authentication.
5. Enter the mailbox login separately for both servers; some apps leave the SMTP username empty.
6. Save the account. Send a test message to an address you control and reply to confirm incoming mail.

These settings apply to clients such as Thunderbird, Apple Mail, and Outlook.
The names of the setup fields vary by application.

## Two-factor authentication

If your account uses two-factor authentication, a client that only accepts a
username and password may need an **app password**. Obtain or manage it through
the account-management method provided by your administrator. Keep your main
password and authenticator code for browser access and password changes.

Do not append a changing authenticator code to the saved password in a mail
client. Use the supported app-password setup instead.

## Sending from an application

Configure these values in the application's private environment or secret store:

```text
SMTP_HOST=<mail-host>
SMTP_PORT=587
SMTP_SECURITY=starttls
SMTP_AUTH=true
SMTP_USERNAME=user@<domain>
SMTP_PASSWORD=<app-password>
SMTP_FROM=user@<domain>
```

These are illustrative setting names, not a universal library API. With port
587, enable STARTTLS and require the TLS upgrade before authenticating. With
port 465, choose implicit TLS. Keep certificate verification enabled.

Use a dedicated, approved sender mailbox for automated mail. Keep its sender
address aligned with the authenticated account, and request any required
sending limits from your administrator. Port **25** is for mail-server
transport, not normal authenticated application submission.

## After changing a password

Update any client that stores the main password, for **both** IMAP and SMTP.
Existing app passwords remain unchanged by the current password portal.
See [password management](passwords.md) and [connection troubleshooting](troubleshooting.md).
