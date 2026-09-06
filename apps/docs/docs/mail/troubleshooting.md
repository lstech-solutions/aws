---
title: Troubleshoot mail access
description: Resolve common mailbox login, SMTP, TLS, and delivery problems.
---

# Troubleshoot mail access

## Can't sign in to webmail

Check the issued login, password, and—if enabled—the current authenticator
code. New mailboxes usually use a full email address; legacy logins can differ.
Make sure your device clock is correct when using an authenticator.

Use [Forgot password?](passwords.md#recover-a-forgotten-password) if you no
longer know the main password. A SnappyMail administrator password is not a
mailbox credential.

## Reading works, but sending fails

Check the outgoing server independently of the incoming server:

- SMTP authentication must be enabled.
- Enter the full issued login and password in the SMTP fields.
- Use **587 + STARTTLS**, or **465 + SSL/TLS**.
- Use an approved sender address for that mailbox.

A **Relay not allowed** error often means outgoing authentication did not
complete. Do not disable authentication or certificate verification to bypass it.

## Certificate or TLS error

Use the exact issued mail hostname, without a URL prefix. Verify that the
port matches the selected encryption mode. If the certificate still does
not match, report it to your administrator instead of accepting an exception.

## Too many password attempts

The account portal limits repeated requests. Wait **15 minutes** before trying
again. Check the details before retrying; repeatedly refreshing does not
clear the limit.

## Password changed, but a client keeps failing

Update saved credentials for both IMAP and SMTP. If two-factor authentication
is enabled, use an app password where the client requires one. Existing app
passwords are preserved by the password portal.

## A sent message did not arrive

Check for a delivery-status message and the recipient's spam folder. Confirm
the destination address. For administrator investigation, provide the time,
recipient through a private channel, and the error text with passwords and
tokens removed. Sending successfully is different from final delivery.

## Text or controls are hard to read

Reload webmail to receive the current theme. The updated interface improves
login and settings contrast and allows the login page to scroll on smaller
screens. If a problem remains, tell your administrator which page, browser,
zoom level, and device size you used.
