const fallbackEmail = (localPart: string) => `${localPart}@<company-domain>`

export const CONTACT_EMAIL = process.env.NEXT_PUBLIC_CONTACT_EMAIL || fallbackEmail('contact')
export const PRIVACY_EMAIL = process.env.NEXT_PUBLIC_PRIVACY_EMAIL || fallbackEmail('privacy')
export const LEGAL_EMAIL = process.env.NEXT_PUBLIC_LEGAL_EMAIL || fallbackEmail('legal')
export const SECURITY_EMAIL = process.env.NEXT_PUBLIC_SECURITY_EMAIL || fallbackEmail('security')
