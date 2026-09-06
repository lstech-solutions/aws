---
title: Resolver problemas de correo
description: Resuelve problemas habituales de acceso al buzón, SMTP, TLS y entrega de mensajes.
---

# Resuelve problemas de acceso al correo

## No puedes iniciar sesión en webmail

Revisa el usuario asignado, la contraseña y, si corresponde, el código actual
del autenticador. Los buzones nuevos suelen usar la dirección de correo completa;
los usuarios antiguos pueden ser diferentes. Comprueba que el reloj de tu
dispositivo sea correcto si utilizas un autenticador.

Consulta [¿Olvidaste tu contraseña?](passwords.md#recover-a-forgotten-password)
si ya no conoces la contraseña principal. Una contraseña de administración de
SnappyMail no es una credencial de buzón.

## Puedes leer, pero no enviar

Revisa el servidor saliente por separado del entrante:

- La autenticación SMTP debe estar activada.
- Introduce el usuario completo asignado y la contraseña en los campos de SMTP.
- Usa **587 + STARTTLS** o **465 + SSL/TLS**.
- Usa una dirección de remitente aprobada para ese buzón.

Un error **Relay not allowed** suele indicar que no se completó la autenticación
saliente. No desactives la autenticación ni la verificación de certificados para evitarlo.

## Error de certificado o TLS

Usa el nombre exacto del servidor de correo, sin prefijo de URL. Comprueba que
el puerto corresponda al cifrado seleccionado. Si el certificado sigue sin
coincidir, informa al administrador en lugar de aceptar una excepción.

## Demasiados intentos de contraseña

El portal de la cuenta limita las solicitudes repetidas. Espera **15 minutos**
antes de intentarlo de nuevo. Revisa los datos antes de reintentar; recargar
repetidamente la página no elimina el límite.

## Cambiaste la contraseña, pero una aplicación sigue fallando

Actualiza las credenciales guardadas para IMAP y SMTP. Si tienes dos factores
activados, usa una contraseña de aplicación donde el cliente lo requiera.
El portal conserva las contraseñas de aplicación existentes.

## Un mensaje enviado no llegó

Busca un aviso de entrega y revisa la carpeta de spam del destinatario.
Confirma la dirección de destino. Para que el administrador investigue,
proporciona la hora, el destinatario por un canal privado y el texto del error
sin contraseñas ni tokens. Enviar correctamente no equivale a la entrega final.

## El texto o los controles son difíciles de leer

Recarga webmail para recibir el tema actual. La interfaz actualizada mejora el
contraste del acceso y de la configuración y permite desplazar la página de
acceso en pantallas pequeñas. Si persiste el problema, indica qué página,
navegador, nivel de zoom y tamaño de dispositivo usaste.
