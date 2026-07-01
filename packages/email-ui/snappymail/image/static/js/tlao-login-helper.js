;(function () {
  'use strict'

  const HELPER_CLASS = 'tlao-login-helper'
  const TOTP_SELECTOR = [
    "input[name*='totp' i]",
    "input[id*='totp' i]",
    "input[placeholder*='totp' i]",
    "input[name*='otp' i]",
    "input[id*='otp' i]",
    "input[placeholder*='otp' i]",
    "input[autocomplete='one-time-code']",
  ].join(', ')

  function bodyIsAdmin() {
    const app = document.getElementById('rl-app')
    if (!app) {
      return false
    }

    const adminValue = (app.getAttribute('data-admin') || '').toLowerCase()
    return adminValue === '1' || adminValue === 'true'
  }

  function isVisible(element) {
    return !!element && !element.hidden && element.getClientRects().length > 0
  }

  function loginForm() {
    return document.querySelector('#V-Login form')
  }

  function totpInput(form) {
    if (!form) {
      return null
    }

    const directMatch = form.querySelector(TOTP_SELECTOR)
    if (isVisible(directMatch)) {
      return directMatch
    }

    const inputs = Array.from(form.querySelectorAll('input'))
    return (
      inputs.find((input) => {
        if (!isVisible(input)) {
          return false
        }

        const signature = [
          input.name,
          input.id,
          input.placeholder,
          input.autocomplete,
          input.getAttribute('aria-label'),
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase()

        return (
          signature.includes('totp') ||
          signature.includes('otp') ||
          signature.includes('authenticator')
        )
      }) || null
    )
  }

  function submitButton(form) {
    if (!form) {
      return null
    }

    return form.querySelector('.buttonLogin, button[type="submit"], input[type="submit"]')
  }

  function sanitizeCode(value) {
    return String(value || '').replace(/[^\d]/g, '')
  }

  function syncInputValue(input) {
    const nextValue = sanitizeCode(input.value)
    if (nextValue !== input.value) {
      input.value = nextValue
    }
  }

  function updateButtonLabel(button, label) {
    if (!button) {
      return
    }

    if (!button.dataset.tlaoOriginalLabel) {
      if ('value' in button && button.value) {
        button.dataset.tlaoOriginalLabel = button.value
      } else {
        button.dataset.tlaoOriginalLabel = button.textContent.trim()
      }
    }

    if (button.tagName === 'INPUT') {
      button.value = label
      return
    }

    const labelNode = button.querySelector('.buttonText, .text, span')
    if (labelNode) {
      labelNode.textContent = label
      return
    }

    button.textContent = label
  }

  function restoreButtonLabel(button) {
    if (!button || !button.dataset.tlaoOriginalLabel) {
      return
    }

    updateButtonLabel(button, button.dataset.tlaoOriginalLabel)
  }

  function clearHelpers(form) {
    if (!form) {
      return
    }

    form.querySelectorAll('.' + HELPER_CLASS).forEach(function (helper) {
      helper.remove()
    })
  }

  function ensureHelper(input) {
    const controls = input && input.closest('.controls')
    if (!controls) {
      return null
    }

    let helper = controls.querySelector('.' + HELPER_CLASS)
    if (!helper) {
      helper = document.createElement('div')
      helper.className = HELPER_CLASS
      controls.appendChild(helper)
    }

    return helper
  }

  function patchInput(input) {
    if (!input) {
      return
    }

    input.dataset.tlaoTotp = 'true'
    input.setAttribute('inputmode', 'numeric')
    input.setAttribute('autocomplete', 'one-time-code')
    input.setAttribute('autocapitalize', 'off')
    input.setAttribute('spellcheck', 'false')
    input.setAttribute('enterkeyhint', 'go')
    input.setAttribute('pattern', '[0-9]*')
    if (!input.maxLength || input.maxLength < 6) {
      input.maxLength = 8
    }
    if (!input.placeholder || input.placeholder === 'TOTP code') {
      input.placeholder = '6-digit TOTP code'
    }

    if (input.dataset.tlaoPatched === 'true') {
      return
    }

    input.dataset.tlaoPatched = 'true'

    input.addEventListener('input', function () {
      syncInputValue(input)
      const hasValue = sanitizeCode(input.value).length > 0
      updateButtonLabel(
        submitButton(loginForm()),
        hasValue ? 'VERIFY CODE AND LOG IN' : 'ENTER CODE TO CONTINUE'
      )
    })

    input.addEventListener('paste', function (event) {
      const clipboard = event.clipboardData
      if (!clipboard) {
        return
      }

      const pasted = sanitizeCode(clipboard.getData('text'))
      if (!pasted) {
        return
      }

      event.preventDefault()
      input.value = pasted
      input.dispatchEvent(new Event('input', { bubbles: true }))
    })

    input.addEventListener('keydown', function (event) {
      if (event.key !== 'Enter') {
        return
      }

      const currentForm = loginForm()
      const currentButton = submitButton(currentForm)
      syncInputValue(input)
      event.preventDefault()
      if (currentButton) {
        currentButton.click()
      } else if (currentForm && typeof currentForm.requestSubmit === 'function') {
        currentForm.requestSubmit()
      }
    })
  }

  function syncLoginUi() {
    const form = loginForm()
    const button = submitButton(form)
    const input = totpInput(form)

    if (!bodyIsAdmin() || !form || !input || !isVisible(input)) {
      clearHelpers(form)
      restoreButtonLabel(button)
      return
    }

    patchInput(input)

    const helper = ensureHelper(input)
    if (helper) {
      helper.innerHTML =
        '<strong>TOTP required.</strong> Enter the current authenticator code, then submit again. ' +
        'Spaces and dashes are removed automatically.'
    }

    syncInputValue(input)
    updateButtonLabel(
      button,
      sanitizeCode(input.value).length > 0 ? 'VERIFY CODE AND LOG IN' : 'ENTER CODE TO CONTINUE'
    )

    const alert = form.querySelector('.alert')
    if (
      alert &&
      isVisible(alert) &&
      sanitizeCode(input.value).length === 0 &&
      document.activeElement !== input
    ) {
      input.focus()
      input.select()
    }
  }

  function start() {
    syncLoginUi()
    window.setInterval(syncLoginUi, 500)
    window.addEventListener('pageshow', syncLoginUi)
    window.addEventListener('load', syncLoginUi)
    document.addEventListener('visibilitychange', syncLoginUi)

    const observer = new MutationObserver(syncLoginUi)
    observer.observe(document.body, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ['class', 'hidden', 'style', 'value'],
    })
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true })
  } else {
    start()
  }
})()
