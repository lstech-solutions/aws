'use client'

import { useState, useEffect } from 'react'
import { Bot, Zap, Globe, ArrowRight, Play } from 'lucide-react'
import { InfiniteGrid } from './InfiniteGrid'
import { ScrollIndicator } from './ScrollControls'

export default function Hero() {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    setIsVisible(true)
  }, [])

  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-white dark:bg-gray-950">
      {/* Background gradient */}
      <div className="absolute inset-0 gradient-bg opacity-90 dark:opacity-80" />
      
      {/* Infinite Grid Animation */}
      <InfiniteGrid />

      <div className="relative z-10 container-max section-padding text-center">
        <div className={`transition-all duration-1000 ${isVisible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-10'}`}>
          {/* Competition badge */}
          <div className="inline-flex items-center gap-2 bg-white/20 dark:bg-white/20 backdrop-blur-sm rounded-full px-6 py-2 mb-8 border border-white/30 dark:border-white/30">
            <Zap className="w-4 h-4 text-yellow-300 dark:text-yellow-300" />
            <span className="text-sm font-medium text-gray-900 dark:text-white">AWS 10,000 AIdeas Competition Entry</span>
          </div>

          {/* Main heading */}
          <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight text-gray-900 dark:text-white">
            AI Agent
            <span className="block bg-gradient-to-r from-blue-600 dark:from-yellow-300 to-blue-700 dark:to-orange-300 bg-clip-text text-transparent">
              Platform
            </span>
          </h1>

          {/* Subtitle */}
          <p className="text-xl md:text-2xl mb-8 max-w-4xl mx-auto leading-relaxed text-gray-700 dark:text-white/90">
            Transform messy operational inputs into clear execution plans with <strong>Ops Copilot</strong>.
            Discover and apply for grants with <strong>Grant Navigator</strong>.
            Powered by AWS Bedrock, Lambda, and DynamoDB.
          </p>

          {/* Agent icons */}
          <div className="flex justify-center gap-8 mb-12">
            <div className="flex items-center gap-3 bg-gray-100 dark:bg-white/10 backdrop-blur-sm rounded-lg px-6 py-3 border border-gray-300 dark:border-white/20">
              <Bot className="w-6 h-6 text-blue-600 dark:text-blue-300" />
              <span className="font-semibold text-gray-900 dark:text-white">Ops Copilot</span>
            </div>
            <div className="flex items-center gap-3 bg-gray-100 dark:bg-white/10 backdrop-blur-sm rounded-lg px-6 py-3 border border-gray-300 dark:border-white/20">
              <Globe className="w-6 h-6 text-green-600 dark:text-green-300" />
              <span className="font-semibold text-gray-900 dark:text-white">Grant Navigator</span>
            </div>
          </div>

          {/* CTA buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button className="btn-primary flex items-center gap-2 text-lg">
              <Play className="w-5 h-5" />
              View Demo
            </button>
            <button className="btn-secondary flex items-center gap-2 text-lg">
              Explore Architecture
              <ArrowRight className="w-5 h-5" />
            </button>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-16 max-w-4xl mx-auto">
            <div className="text-center">
              <div className="text-3xl font-bold text-blue-600 dark:text-yellow-300 mb-2">2</div>
              <div className="text-gray-700 dark:text-white/80">Specialized AI Agents</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-blue-600 dark:text-yellow-300 mb-2">5</div>
              <div className="text-gray-700 dark:text-white/80">AWS Services Integrated</div>
            </div>
            <div className="text-center">
              <div className="text-3xl font-bold text-blue-600 dark:text-yellow-300 mb-2">3</div>
              <div className="text-gray-700 dark:text-white/80">Languages Supported</div>
            </div>
          </div>
        </div>
      </div>

      {/* Scroll indicator */}
      <ScrollIndicator />
    </section>
  )
}