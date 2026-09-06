---
title: Cambiar y recuperar contraseñas
description: Cambia la contraseña de tu buzón o recupera el acceso con un enlace de un solo uso emitido por tu administrador.
---

# Administra la contraseña de tu buzón

El portal de la cuenta está en el mismo servidor que webmail:

[Abre el portal de contraseñas](https://webmail.xn--tlo-fla.com/account/).

## Cambia una contraseña que conoces

![Formulario de cambio de contraseña con usuario del buzón, contraseña actual, código opcional del autenticador y campos de contraseña nueva](/img/mail/change-password.png)

_Formulario completo con todos los campos vacíos. La captura muestra la interfaz en inglés; los pasos incluyen su significado en español._

1. Elige **Change password** («Cambiar contraseña») en la página de acceso a webmail o en Configuración.
2. Introduce tu usuario exacto en **Mailbox login** y tu contraseña principal actual en **Current password**.
3. Si usas dos factores, introduce el código actual de seis dígitos en **Authenticator code**. Si no, deja ese campo vacío.
4. Introduce la nueva contraseña en **New password** y repítela exactamente en **Confirm new password**.
5. Pulsa **Update password** («Actualizar contraseña») una vez y espera el resultado. Corrige cualquier error de validación antes de volver a intentarlo.
6. Inicia sesión en webmail con la nueva contraseña. Actualiza las aplicaciones que guardan la contraseña principal.

Usa **entre 15 y 128 caracteres**. Una frase de contraseña larga y única es una
buena opción. Las contraseñas de aplicación no sirven para cambiar la contraseña principal.

El portal conserva la autenticación de dos factores y las contraseñas de
aplicación existentes. Cambiar la contraseña no cierra todas las sesiones ya
autenticadas. Si sospechas un acceso no autorizado, pide que también se revisen
las sesiones y las contraseñas de aplicación.

## Recupera una contraseña olvidada {#recover-a-forgotten-password}

Elige **Forgot password?** («¿Olvidaste tu contraseña?») en la página de acceso.

![Pantalla de recuperación que explica la verificación por el administrador y el enlace privado válido durante 30 minutos](/img/mail/forgot-password.png)

_La recuperación empieza con quien administra tu buzón; esta pantalla no envía un correo._

1. Contacta con quien administra tu buzón por tu canal habitual de soporte de confianza.
2. Esa persona verifica que eres titular del buzón.
3. Te proporciona un enlace privado de restablecimiento de un solo uso.
4. Abre el enlace, introduce dos veces la nueva contraseña y pulsa **Update password** («Actualizar contraseña»).
5. Vuelve a webmail e inicia sesión.

No necesitas acceso al buzón bloqueado. Actualmente la recuperación es
**asistida por el administrador**: la página no envía automáticamente un correo
de recuperación. No compartas tu contraseña principal ni el código del autenticador con soporte.

## Reglas del enlace de restablecimiento

- El enlace caduca **30 minutos** después de emitirse.
- Solo se puede usar una vez.
- Un enlace nuevo sustituye a los anteriores de ese buzón.
- Si recargas la página de contraseña, vuelve a abrir el enlace original completo.
- Si el enlace caduca o se rechaza, solicita uno nuevo.

Si la actualización se interrumpe, intenta primero iniciar sesión con la nueva
contraseña. Si no funciona, pide que revisen la cuenta y emitan otro enlace.
El enlace puede haberse consumido aunque el navegador no confirme el resultado.

## ¿También perdiste tu autenticador?

Restablecer la contraseña **no** desactiva los dos factores. Informa a tu
administrador si también perdiste el autenticador. Las cuentas privilegiadas y
las de uso especial requieren un procedimiento de administración independiente.
