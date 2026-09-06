---
title: Password changes and recovery
description: Change a mailbox password or recover access with an administrator-issued one-time link.
---

# Manage your mailbox password

The account portal is on the same host as webmail:

```text
https://<webmail-host>/account/
```

## Change a password you know

1. Choose **Change password** on the webmail login page or in Settings.
2. Enter your exact mailbox login and **current main password**.
3. If you use two-factor authentication, enter your current six-digit authenticator code.
4. Enter the new password twice and choose **Update password**.
5. Sign in to webmail with the new password. Update mail apps that store the main password.

Use **15–128 characters**. A long, unique passphrase is a good choice.
App passwords cannot be used to change the main password.

The portal preserves two-factor authentication and existing app passwords.
A password change is not a global sign-out from every already authenticated
session. If you suspect unauthorized access, ask your administrator to review
sessions and app passwords as well.

## Recover a forgotten password

Choose **Forgot password?** on the login page.

1. Contact your mailbox administrator through your usual trusted support channel.
2. The administrator verifies that you own the mailbox.
3. They share a private, one-time reset link.
4. Open that link, enter your new password twice, and choose **Update password**.
5. Return to webmail and sign in.

You do not need access to the locked mailbox. Recovery is currently
**administrator assisted**: the page does not automatically send a recovery
email. Do not share your main password or authenticator code with support.

## Reset-link rules

- A link expires **30 minutes** after it is issued.
- Each link can be used only once.
- A newly issued link replaces earlier links for that mailbox.
- Reopen the original complete link if you reload the password page.
- If a link expires or is rejected, ask for a new one.

If an update is interrupted, first try signing in with the new password. If
that does not work, ask the administrator to check the account and issue a
replacement link. A link may be consumed even if the browser cannot confirm
the result.

## Lost your authenticator too?

A password reset does **not** disable two-factor authentication. Tell your
administrator if you also lost access to your authenticator. Privileged and
special-purpose accounts require separate administrator handling.
