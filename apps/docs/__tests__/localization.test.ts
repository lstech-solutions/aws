import * as fs from 'fs'
import * as path from 'path'

const root = path.join(__dirname, '..')
const source = path.join(root, 'docs')
const spanish = path.join(root, 'i18n/es/docusaurus-plugin-content-docs/current')

function documents(directory: string, prefix = ''): string[] {
  return fs
    .readdirSync(directory, { withFileTypes: true })
    .flatMap((entry) => {
      const relative = path.join(prefix, entry.name)
      return entry.isDirectory()
        ? documents(path.join(directory, entry.name), relative)
        : /\.mdx?$/.test(entry.name)
          ? [relative]
          : []
    })
    .sort()
}

describe('Spanish documentation coverage', () => {
  it('provides a translation for every published English document without orphan pages', () => {
    expect(documents(spanish)).toEqual(documents(source))
  })

  it.each(documents(source))(
    'translates %s rather than silently falling back to English',
    (file) => {
      const original = fs.readFileSync(path.join(source, file), 'utf8')
      const translation = fs.readFileSync(path.join(spanish, file), 'utf8')
      expect(translation.trim()).not.toBe(original.trim())
      expect(translation).not.toMatch(/@@CODE\d+@@/)
      expect(translation.match(/^#{1,2} .+/gm)?.length).toBeGreaterThan(1)
      for (const field of ['id', 'slug']) {
        const pattern = new RegExp(`^${field}: .+$`, 'm')
        expect(translation.match(pattern)?.[0]).toBe(original.match(pattern)?.[0])
      }
    }
  )

  it('translates every custom footer message including its accessible name', () => {
    const component = fs.readFileSync(path.join(root, 'src/theme/Footer/index.tsx'), 'utf8')
    const messages = JSON.parse(fs.readFileSync(path.join(root, 'i18n/es/code.json'), 'utf8'))
    const ids = [...component.matchAll(/docs\.footer\.[a-z]+/g)].map((match) => match[0])
    expect(ids.length).toBeGreaterThan(0)
    for (const id of ids) expect(messages[id]?.message?.length).toBeGreaterThan(0)
  })
})
