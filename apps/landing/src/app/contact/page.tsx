'use client'

import { useState } from 'react'
import { Mail, Phone, MapPin, Send } from 'lucide-react'
import { motion } from 'framer-motion'

export default function Contact() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  })
  const [submitted, setSubmitted] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
    setError('')
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      // Send email via mailto link with form data
      const mailtoLink = `mailto:contact@lstech.solutions?subject=${encodeURIComponent(formData.subject)}&body=${encodeURIComponent(
        `Name: ${formData.name}\nEmail: ${formData.email}\n\nMessage:\n${formData.message}`
      )}`
      
      // Open email client
      window.location.href = mailtoLink
      
      // Show success message
      setSubmitted(true)
      setFormData({ name: '', email: '', subject: '', message: '' })
      setTimeout(() => setSubmitted(false), 5000)
    } catch (err) {
      setError('Failed to send message. Please try again.')
      console.error('Error submitting form:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-white dark:bg-gray-950 text-gray-900 dark:text-gray-50">
      <div className="container-max section-padding">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl font-bold mb-4">Get in Touch</h1>
          <p className="text-xl text-gray-600 dark:text-gray-400 mb-12">
            Have questions about AI Agent Platform? We&apos;d love to hear from you. Send us a message and we&apos;ll respond as soon as possible.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
            {/* Contact Info Cards */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="p-6 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800"
            >
              <Mail className="w-8 h-8 text-blue-600 dark:text-blue-400 mb-4" />
              <h3 className="text-lg font-semibold mb-2">Email</h3>
              <p className="text-gray-600 dark:text-gray-400">
                <a href="mailto:contact@lstech.solutions" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  contact@lstech.solutions
                </a>
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="p-6 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800"
            >
              <Phone className="w-8 h-8 text-blue-600 dark:text-blue-400 mb-4" />
              <h3 className="text-lg font-semibold mb-2">Phone</h3>
              <p className="text-gray-600 dark:text-gray-400">
                <a href="tel:+1234567890" className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                  +1 (234) 567-890
                </a>
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="p-6 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800"
            >
              <MapPin className="w-8 h-8 text-blue-600 dark:text-blue-400 mb-4" />
              <h3 className="text-lg font-semibold mb-2">Location</h3>
              <p className="text-gray-600 dark:text-gray-400">
                Global Team<br />
                Available 24/7
              </p>
            </motion.div>
          </div>

          {/* Contact Form */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-8"
          >
            <h2 className="text-2xl font-semibold mb-6">Send us a Message</h2>

            {submitted && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="mb-6 p-4 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg text-green-800 dark:text-green-200"
              >
                ✓ Thank you for your message! Your email client will open to send the message to contact@lstech.solutions
              </motion.div>
            )}

            {error && (
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                className="mb-6 p-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg text-red-800 dark:text-red-200"
              >
                ✗ {error}
              </motion.div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label htmlFor="name" className="block text-sm font-medium mb-2">
                    Name
                  </label>
                  <input
                    type="text"
                    id="name"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 dark:focus:ring-blue-400 transition-colors"
                    placeholder="Your name"
                  />
                </div>
                <div>
                  <label htmlFor="email" className="block text-sm font-medium mb-2">
                    Email
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    required
                    className="w-full px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 dark:focus:ring-blue-400 transition-colors"
                    placeholder="your@email.com"
                  />
                </div>
              </div>

              <div>
                <label htmlFor="subject" className="block text-sm font-medium mb-2">
                  Subject
                </label>
                <input
                  type="text"
                  id="subject"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  required
                  className="w-full px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 dark:focus:ring-blue-400 transition-colors"
                  placeholder="What is this about?"
                />
              </div>

              <div>
                <label htmlFor="message" className="block text-sm font-medium mb-2">
                  Message
                </label>
                <textarea
                  id="message"
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  required
                  rows={6}
                  className="w-full px-4 py-2 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 dark:focus:ring-blue-400 transition-colors resize-none"
                  placeholder="Tell us more about your inquiry..."
                />
              </div>

              <motion.button
                type="submit"
                disabled={loading}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className="w-full bg-blue-600 dark:bg-blue-500 hover:bg-blue-700 dark:hover:bg-blue-600 text-white font-semibold py-3 px-6 rounded-lg transition-colors flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                <Send className="w-5 h-5" />
                {loading ? 'Sending...' : 'Send Message'}
              </motion.button>
            </form>
          </motion.div>

          {/* FAQ Section */}
          <div className="mt-16">
            <h2 className="text-2xl font-semibold mb-8">Frequently Asked Questions</h2>
            <div className="space-y-4">
              {[
                {
                  q: 'What is the response time for inquiries?',
                  a: 'We typically respond to all inquiries within 24-48 hours during business days.',
                },
                {
                  q: 'Can I schedule a demo?',
                  a: 'Yes! Please mention your interest in a demo in the contact form and we&apos;ll get back to you with available times.',
                },
                {
                  q: 'Do you offer enterprise support?',
                  a: 'Yes, we offer enterprise support plans. Please contact our sales team for more information.',
                },
                {
                  q: 'How can I report a security issue?',
                  a: 'Please email security@lstech.solutions with details about the vulnerability.',
                },
              ].map((faq, index) => (
                <motion.div
                  key={index}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.5 + index * 0.1 }}
                  className="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800"
                >
                  <h3 className="font-semibold mb-2 text-gray-900 dark:text-white">{faq.q}</h3>
                  <p className="text-gray-600 dark:text-gray-400">{faq.a}</p>
                </motion.div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </main>
  )
}
