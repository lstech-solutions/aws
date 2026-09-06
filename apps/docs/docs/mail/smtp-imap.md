---
title: Connect with SMTP and IMAP
description: Configure incoming IMAP and authenticated outgoing SMTP for TLÁO Mail.
---

# Connect your email application

Choose **Other account**, **Manual setup**, or **IMAP** in your mail app.
Use the verified TLÁO server settings below and the mailbox login issued by your administrator.

## 1. Have your mailbox details ready

Keep your mailbox login and password available. The login is usually your full
email address; use an issued legacy login if your administrator provided one.
If two-factor authentication is enabled, obtain an app password before setup.

## 2. Enter the connection settings

| Setting             | Incoming mail                           | Outgoing mail                     |
| ------------------- | --------------------------------------- | --------------------------------- |
| Protocol            | IMAP                                    | SMTP                              |
| Server hostname     | `mail.xn--tlo-fla.com`                  | `mail.xn--tlo-fla.com`            |
| Recommended port    | **993**                                 | **587**                           |
| Connection security | **SSL/TLS**                             | **STARTTLS**                      |
| Authentication      | Password                                | Password; authentication required |
| Username            | Your full mailbox login                 | The same mailbox login            |
| Password            | Main password or an issued app password | The same applicable credential    |

**Alternative SMTP:** port **465** uses **SSL/TLS** from the start of the
connection. Use it when your app supports implicit TLS instead of STARTTLS.
Do not pair port 587 with implicit SSL/TLS, or port 465 with STARTTLS.

:::tip Which hostname?
Use `mail.xn--tlo-fla.com`, not the webmail URL. Enter only the hostname in the server
field, without `https://` or a path. The ASCII spelling above works in clients
that do not support accented domain names.
:::

## 3. Add the account in your mail app

1. Add a new mail account and enter your display name and email address.
2. Select manual IMAP configuration if automatic discovery does not fill in the issued settings.
3. Set the incoming server to **mail.xn--tlo-fla.com**, port **993**, with **SSL/TLS**.
4. Set the outgoing server to **mail.xn--tlo-fla.com**, port **587**, with **STARTTLS**, and enable authentication.
5. Enter the mailbox login separately for both servers; some apps leave the SMTP username empty.
6. Save the account. Send a test message to an address you control and reply to confirm incoming mail.

These settings apply to clients such as Thunderbird, Apple Mail, and Outlook.
The names of the setup fields vary by application.

### If your application asks for a connection URL

Use these only in software that accepts mail connection URIs:

| Service          | Connection URI                     | Required security                      |
| ---------------- | ---------------------------------- | -------------------------------------- |
| Incoming IMAP    | `imaps://mail.xn--tlo-fla.com:993` | SSL/TLS                                |
| Outgoing SMTP    | `smtp://mail.xn--tlo-fla.com:587`  | Require STARTTLS before authentication |
| Alternative SMTP | `smtps://mail.xn--tlo-fla.com:465` | SSL/TLS                                |

These are mail endpoints, not pages to open in your browser. A `smtp://` URI
alone does not require encryption in every library: explicitly require STARTTLS.
Keep usernames and passwords in separate credential fields or a secret store.

## 4. Verify sending and receiving

1. Wait for the Inbox to synchronize. Existing messages should appear if the mailbox has any.
2. Send a short test message to another mailbox you control.
3. Confirm that it arrives there, then reply from that mailbox.
4. Confirm that the reply appears in your TLÁO Inbox.
5. If receiving works but sending fails, reopen the outgoing server settings and
   check SMTP authentication, username, port, and encryption independently.

Never accept an unexpected certificate warning. Confirm the hostname and your
device clock, then ask your administrator if the warning remains.
See [connection troubleshooting](troubleshooting.md) for the next checks.

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
SMTP_HOST=mail.xn--tlo-fla.com
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
