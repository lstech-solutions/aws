# TLÁO Mailbox Access

This deployment uses `xn--tlo-fla.com` as the transport-safe TLÁO domain and `mail.xn--tlo-fla.com` as the mail host.

## Primary Admin Mailbox

- Display address: `<mailbox>@<domain>`
- Transport-safe address: `<mailbox>@<domain>`
- IMAP/SMTP login username: `<mailbox>@<domain>`
- Incoming mail server: `mail.xn--tlo-fla.com`
- Outgoing mail server: `mail.xn--tlo-fla.com`

The live mailbox roster uses full email addresses as login names. The public docs only keep the canonical TLÁO mailbox visible. The complete live list lives in [`packages/email/deployment/ovh/private/domains.local.json`](/home/ed/Documents/LSTS/aws/packages/email/deployment/ovh/private/domains.local.json), which is gitignored.

Before creating or using a mailbox on a new domain, complete [`DOMAIN-ONBOARDING.md`](./DOMAIN-ONBOARDING.md). A mailbox can exist before the DNS and DKIM work is done, but Gmail, Outlook, and other external systems will distrust it until SPF, DKIM, DMARC, and the hosted-zone records are in sync.

## Standard Client Settings

- IMAP server: `mail.xn--tlo-fla.com`
- IMAP port: `993`
- IMAP security: `SSL/TLS`
- IMAP auth: normal password
- SMTP server: `mail.xn--tlo-fla.com`
- SMTP port: `587`
- SMTP security: `STARTTLS`
- SMTP auth: normal password
- SMTP username: the full mailbox login address

Port `465` with implicit TLS also works for SMTP submission, but `587` with STARTTLS is the preferred default for desktop and mobile clients.

## Webmail

The OVH bundle supports a fallback SnappyMail webmail UI.

- Webmail URL: `https://webmail.xn--tlo-fla.com`
- SnappyMail admin URL: `https://webmail.xn--tlo-fla.com/?admin`
- SnappyMail bootstrap admin password file: `/opt/tlao-mail/snappymail/_data_/_default_/admin_password.txt`
- The branded fallback theme source is [`packages/email-ui/snappymail/image`](/home/ed/Documents/LSTS/aws/packages/email-ui/snappymail/image)

SnappyMail uses full email address logins in this deployment. That keeps the login contract consistent across domains and matches the Stalwart principals created by the provisioning flow.

## Thunderbird

Mozilla Thunderbird supports manual IMAP account setup directly.

This deployment also serves Thunderbird autoconfig from `https://autoconfig.xn--tlo-fla.com/mail/config-v1.1.xml`. Additional autoconfig hostnames are enabled when their domains are listed in the private inventory and published in DNS.

1. Open Thunderbird and choose `Account Settings` or `Set up an existing email account`.
2. Enter:
   - Your name: any display name you want
   - Email address: the exact mailbox address from the private inventory, for example `<mailbox>@<domain>`
   - Password: the mailbox password issued for that mailbox
3. Choose `Configure manually`.
4. Set the incoming server:
   - Protocol: `IMAP`
   - Hostname: `mail.xn--tlo-fla.com`
   - Port: `993`
   - Connection security: `SSL/TLS`
   - Authentication method: `Normal password`
   - Username: the full mailbox address
5. Set the outgoing server:
   - Hostname: `mail.xn--tlo-fla.com`
   - Port: `587`
   - Connection security: `STARTTLS`
   - Authentication method: `Normal password`
   - Username: the full mailbox address
6. Save the account and send a test message to that same mailbox address.

## Gmail App

The Gmail mobile app supports adding external IMAP accounts manually. Use the Gmail app on Android or iPhone/iPad, not Gmail on the web, if you want Gmail to act as the IMAP client for this mailbox.

### Android

1. Open the Gmail app.
2. Tap your profile picture.
3. Tap `Add another account`.
4. Tap `Other`.
5. Enter the exact mailbox address from the private inventory.
6. Select `Personal (IMAP)`.
7. Enter the mailbox password.
8. For incoming mail, enter:
   - Server: `mail.xn--tlo-fla.com`
   - Port: `993`
   - Security type: `SSL/TLS`
   - Username: the same full mailbox address
9. For outgoing mail, enter:
   - SMTP server: `mail.xn--tlo-fla.com`
   - Port: `587`
   - Security type: `STARTTLS`
   - Require sign-in: `Yes`
   - Username: the same full mailbox address
   - Password: same mailbox password

### iPhone and iPad

1. Open the Gmail app.
2. Tap your profile picture.
3. Tap `Add another account`.
4. Tap `Other (IMAP)`.
5. Enter the exact mailbox address from the private inventory.
6. Enter the same IMAP and SMTP settings listed above.

## Gmail Web Caveat

Gmail on the web is not the right client for this mailbox if you need direct IMAP access. Google’s current official client guidance is for the Gmail mobile app when adding non-Gmail IMAP accounts. If you need desktop access, use Thunderbird, Apple Mail, Outlook, or another full IMAP client.

## Troubleshooting

- If an external sender still gets `550 5.1.2 Relay not allowed` for the canonical TLÁO mailbox, retry after the server config reload completes or use `<mailbox>@<domain>` as the transport-safe fallback.
- If login fails, verify the username is the full mailbox address from the private inventory.
- If IMAP authenticates the password but Thunderbird still rejects the account, make sure the mailbox principal has the built-in `user` role.
- If Thunderbird shows a legacy username, replace it with the full mailbox address before retrying.
- If the client warns about the certificate, confirm the server name is exactly `mail.xn--tlo-fla.com`.
- If sending fails, verify the client is using SMTP `587` with `STARTTLS` and authentication enabled.
- If receiving fails, verify the client is using IMAP `993` with `SSL/TLS`.

## References

- Stalwart individual principals: <https://stalw.art/docs/auth/principals/individual/>
- Thunderbird account configuration: <https://support.mozilla.org/en-US/kb/configuration-options-accounts>
- Gmail app on Android: <https://support.google.com/mail/answer/6078445?co=GENIE.Platform%3DAndroid&hl=en>
- Gmail app on iPhone and iPad: <https://support.google.com/mail/answer/6078445?co=GENIE.Platform%3DiOS&hl=en>
