---
title: Conectar con SMTP e IMAP
description: Configura la recepción por IMAP y el envío autenticado por SMTP en TLÁO Mail.
---

# Conecta tu aplicación de correo

Elige **Otra cuenta**, **Configuración manual** o **IMAP** en tu aplicación.
Usa la configuración verificada de TLÁO que aparece a continuación y el usuario
que te proporcionó quien administra el buzón.

## 1. Prepara los datos de tu buzón

Ten a mano tu usuario y contraseña. El usuario suele ser la dirección de correo
completa; utiliza un usuario antiguo si te asignaron uno. Si tienes la
autenticación de dos factores activada, obtén una contraseña de aplicación antes de empezar.

## 2. Introduce la configuración de conexión

| Dato                     | Correo entrante                               | Correo saliente                       |
| ------------------------ | --------------------------------------------- | ------------------------------------- |
| Protocolo                | IMAP                                          | SMTP                                  |
| Nombre del servidor      | `mail.xn--tlo-fla.com`                        | `mail.xn--tlo-fla.com`                |
| Puerto recomendado       | **993**                                       | **587**                               |
| Seguridad de la conexión | **SSL/TLS**                                   | **STARTTLS**                          |
| Autenticación            | Contraseña                                    | Contraseña; autenticación obligatoria |
| Usuario                  | Tu usuario de buzón completo                  | El mismo usuario                      |
| Contraseña               | Contraseña principal o de aplicación asignada | La misma credencial correspondiente   |

**SMTP alternativo:** el puerto **465** utiliza **SSL/TLS** desde el inicio de
la conexión. Úsalo si tu aplicación admite TLS implícito en lugar de STARTTLS.
No combines el puerto 587 con SSL/TLS implícito ni el 465 con STARTTLS.

:::tip ¿Qué nombre de servidor debo usar?
Introduce `mail.xn--tlo-fla.com` en el campo del servidor, sin `https://` ni una
ruta. Usa el servidor de correo, no la dirección de webmail. Esta escritura en
ASCII funciona también en clientes que no admiten dominios con tildes.
:::

## 3. Añade la cuenta en tu aplicación

1. Añade una cuenta de correo e introduce tu nombre para mostrar y tu dirección de correo.
2. Selecciona la configuración manual de IMAP si la detección automática no completa los datos.
3. Configura el servidor entrante **mail.xn--tlo-fla.com**, puerto **993**, con **SSL/TLS**.
4. Configura el servidor saliente **mail.xn--tlo-fla.com**, puerto **587**, con **STARTTLS**, y activa la autenticación.
5. Introduce el usuario por separado para ambos servidores; algunas aplicaciones dejan vacío el usuario de SMTP.
6. Guarda la cuenta. Envía un mensaje de prueba a otra dirección que controles y responde para comprobar la recepción.

Estos datos sirven para clientes como Thunderbird, Apple Mail y Outlook.
Los nombres de los campos pueden variar según la aplicación.

### Si tu aplicación pide una URL de conexión

Usa estas direcciones únicamente en programas que acepten URI de correo:

| Servicio         | URI de conexión                    | Seguridad obligatoria               |
| ---------------- | ---------------------------------- | ----------------------------------- |
| IMAP entrante    | `imaps://mail.xn--tlo-fla.com:993` | SSL/TLS                             |
| SMTP saliente    | `smtp://mail.xn--tlo-fla.com:587`  | Exigir STARTTLS antes de autenticar |
| SMTP alternativo | `smtps://mail.xn--tlo-fla.com:465` | SSL/TLS                             |

Son puntos de conexión de correo, no páginas para abrir en el navegador.
Una URI `smtp://` por sí sola no exige cifrado en todas las bibliotecas:
configura STARTTLS como obligatorio. Guarda el usuario y la contraseña en
campos separados o en un almacén de secretos.

## 4. Comprueba el envío y la recepción

1. Espera a que se sincronice la bandeja de entrada. Si el buzón ya tiene mensajes, deberían aparecer.
2. Envía un mensaje breve a otro buzón que controles.
3. Comprueba que llegue y responde desde ese otro buzón.
4. Verifica que la respuesta aparezca en tu bandeja de entrada de TLÁO.
5. Si recibes pero no puedes enviar, abre de nuevo la configuración del servidor
   saliente y revisa por separado la autenticación SMTP, el usuario, el puerto y el cifrado.

No aceptes una advertencia inesperada de certificado. Revisa el nombre del
servidor y el reloj de tu dispositivo; si persiste, consulta con quien administra
el servicio. Continúa con la [guía de solución de problemas](troubleshooting.md).

## Autenticación de dos factores

Si tu cuenta usa dos factores, un cliente que solo admite usuario y contraseña
puede necesitar una **contraseña de aplicación**. Obtén o administra esa
contraseña con el método que te indique tu administrador. Conserva la
contraseña principal y el código del autenticador para el acceso por navegador
y los cambios de contraseña.

No añadas un código temporal del autenticador a la contraseña guardada en una
aplicación de correo. Usa el procedimiento admitido para contraseñas de aplicación.

## Enviar desde una aplicación

Configura estos valores en el entorno privado o almacén de secretos de la aplicación:

```text
SMTP_HOST=mail.xn--tlo-fla.com
SMTP_PORT=587
SMTP_SECURITY=starttls
SMTP_AUTH=true
SMTP_USERNAME=user@<domain>
SMTP_PASSWORD=<app-password>
SMTP_FROM=user@<domain>
```

Los nombres de estas variables son ilustrativos, no una API universal. Con el
puerto 587, activa STARTTLS y exige completar el cambio a TLS antes de autenticar.
Con el 465, elige TLS implícito. Mantén activada la verificación del certificado.

Usa un buzón de envío dedicado y aprobado para el correo automático. Mantén la
dirección del remitente alineada con la cuenta autenticada y consulta los límites
de envío necesarios. El puerto **25** se usa para el transporte entre servidores,
no para el envío autenticado habitual desde aplicaciones.

## Después de cambiar una contraseña

Actualiza las aplicaciones que guardan la contraseña principal, tanto para
**IMAP como para SMTP**. El portal actual no cambia las contraseñas de aplicación
existentes. Consulta [la gestión de contraseñas](passwords.md) y
[los problemas de conexión](troubleshooting.md).
