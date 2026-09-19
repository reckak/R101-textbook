const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');

const root = path.resolve(__dirname, '..', '..', '_book');
const result = { errors: [], screenshots: [], chapters: [] };
function check(condition, message) { if (!condition) throw new Error(message); }

(async () => {
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(req.url.split('?')[0]);
    const requested = path.resolve(root, '.' + (urlPath.endsWith('/') ? urlPath + 'index.html' : urlPath));
    if (!requested.startsWith(root + path.sep)) { res.writeHead(403); res.end(); return; }
    fs.readFile(requested, (err, data) => {
      if (err) { res.writeHead(404); res.end(); return; }
      const types = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'application/javascript', '.json': 'application/json', '.png': 'image/png', '.svg': 'image/svg+xml' };
      res.setHeader('Content-Type', types[path.extname(requested)] || 'application/octet-stream');
      res.end(data);
    });
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  let browser;
  try {
    browser = await chromium.launch({ ...(process.env.CHROME_PATH ? { executablePath: process.env.CHROME_PATH } : {}), headless: true });
    const context = await browser.newContext({ viewport: { width: 1440, height: 1000 }, permissions: ['clipboard-read', 'clipboard-write'] });
    const page = await context.newPage();
    page.on('pageerror', error => result.errors.push(error.message));
    await page.goto(`http://127.0.0.1:${server.address().port}/index.html`, { waitUntil: 'networkidle' });
    await page.locator('main a[href$="quarto/lekce_01.html"]').click();
    await page.waitForLoadState('networkidle');
    check(new URL(page.url()).pathname === '/quarto/lekce_01.html', 'Chapter navigation failed');
    check(await page.locator('#quarto-sidebar').count() === 1, 'Book sidebar missing');
    const homeLink = page.locator('#quarto-sidebar a.sidebar-link').first();
    check(['/', '/index.html'].includes(new URL(await homeLink.getAttribute('href'), page.url()).pathname), 'Home navigation missing');
    check((await page.locator('h1 .chapter-number').innerText()).trim() === '1', 'First lesson must be chapter 1');
    for (const chapterNumber of [1, 2]) {
      await page.setViewportSize({ width: 1440, height: 1000 });
      await page.locator('#quarto-sidebar a.sidebar-link').filter({ hasText: chapterNumber === 1 ? 'První kroky' : 'Základy tvorby' }).click();
      await page.waitForLoadState('networkidle');
      check((await page.locator('h1 .chapter-number').innerText()).trim() === String(chapterNumber), 'Wrong chapter number');
      const source = fs.readFileSync(path.join(__dirname, '..', 'lekce_0' + chapterNumber + '.qmd'), 'utf8');
      const expectedSolutions = (source.match(/collapse="true" title="Ukázat řešení"/g) || []).length;
      const toc = page.locator('#TOC');
      check(await toc.isVisible(), 'Right TOC missing');
      check((await toc.innerText()).includes('Obsah kapitoly'), 'Wrong TOC title');
      const tocBox = await toc.boundingBox();
      const mainBox = await page.locator('main').boundingBox();
      check(tocBox.x >= mainBox.x + mainBox.width - 1 && tocBox.y < 180, 'TOC not at top right');
      check(await toc.locator('a[data-scroll-target]').count() > 5, 'TOC incomplete');
      const tocTarget = chapterNumber === 1 ? '#sec-balicky' : '#sec-vztahy';
      await toc.locator('a[data-scroll-target="' + tocTarget + '"]').click();
      await page.waitForFunction(id => Math.abs(document.querySelector(id).getBoundingClientRect().top) < 200, tocTarget);
      await page.evaluate(() => window.scrollTo(0, 0));
      await page.screenshot({ path: path.join(__dirname, 'html-top-' + chapterNumber + '.png') });
      const toggles = page.locator('.callout [data-bs-toggle="collapse"]');
      result.solutions = await toggles.count();
      check(result.solutions === expectedSolutions, `Expected ${expectedSolutions} solutions, got ${result.solutions}`);
      for (let i = 0; i < result.solutions; i++) {
        const toggle = toggles.nth(i);
        const target = await toggle.getAttribute('data-bs-target');
        const body = page.locator(target);
        check(!(await body.isVisible()), `Solution ${i + 1} initially visible`);
        check((await toggle.innerText()).includes('Ukázat řešení'), 'Missing Czech solution label');
        await toggle.click();
        await body.waitFor({ state: 'visible' });
        await page.waitForFunction(sel => !document.querySelector(sel).classList.contains('collapsing'), target);
        check(await body.locator('p').first().isVisible(), `Solution ${i + 1} text hidden`);
        for (const img of await body.locator('img').all()) check(await img.isVisible(), 'Solution image hidden');
      }
      const blocks = page.locator('.code-copy-outer-scaffold');
      result.codeBlocks = await blocks.count();
      check(result.codeBlocks === await page.locator('main div.sourceCode').count(), 'Some code samples lack copy scaffolds');
      result.copyChecks = 0;
      for (let i = 0; i < result.codeBlocks; i++) {
        const block = blocks.nth(i);
        const button = block.locator('button.code-copy-button');
        check(await button.count() === 1, `Code block ${i + 1} copy button missing`);
        await block.scrollIntoViewIfNeeded();
        check(await button.isVisible(), `Code block ${i + 1} button invisible`);
        const appearance = await button.evaluate(el => ({ opacity: getComputedStyle(el).opacity, text: getComputedStyle(el, '::after').content }));
        check(appearance.opacity === '1', `Button ${i + 1} not permanently visible`);
        check(appearance.text.includes('Zkopírovat'), `Button ${i + 1} missing visible Czech text`);
        const expected = await block.locator('pre code').innerText();
        await button.click();
        const actual = await page.evaluate(() => navigator.clipboard.readText());
        check(actual.replace(/\r\n/g, '\n').trim() === expected.trim(), `Clipboard mismatch in block ${i + 1}`);
        result.copyChecks++;
      }
      result.images = await page.locator('main img').evaluateAll(imgs => imgs.map(img => ({ alt: img.alt, loaded: img.complete && img.naturalWidth > 0 })));
      check(result.images.every(img => img.loaded && img.alt.length > 0), 'Broken image or missing alt text');
      const links = await page.locator('main a[href], #TOC a[href], .nav-page a[href]').evaluateAll(links => links.map(a => a.href));
      const checkedLinks = new Set();
      for (const href of links) {
        const link = new URL(href);
        if (link.origin !== new URL(page.url()).origin || checkedLinks.has(href)) continue;
        checkedLinks.add(href);
        const response = await context.request.get(link.origin + link.pathname);
        check(response.ok(), 'Missing local target ' + href);
        if (link.hash) {
          const html = await response.text();
          const exists = await page.evaluate(({html, hash}) => !!new DOMParser().parseFromString(html, 'text/html').getElementById(decodeURIComponent(hash.slice(1))), {html, hash: link.hash});
          check(exists, 'Broken cross-chapter anchor ' + href);
        }
      }
      check(await page.locator('.quarto-unresolved-ref').count() === 0, 'Unresolved cross-reference');
      async function screenshot(name, selector) {
        if (selector) await page.locator(selector).scrollIntoViewIfNeeded();
        else await page.evaluate(() => window.scrollTo(0, 0));
        const output = path.join(__dirname, name + '-' + chapterNumber + '.png');
        await page.screenshot({ path: output });
        result.screenshots.push(output);
      }
      if (chapterNumber === 1) {
        await screenshot('html-keyboard', '#specialni-znaky');
        await screenshot('html-headings', '#nadpisy-skriptu');
      } else {
        await screenshot('html-graph', '#fig-tucnaci-final');
        await screenshot('html-solution', '#fig-reseni-samostatne');
      }
      await page.setViewportSize({ width: 390, height: 844 });
      await screenshot('html-mobile');
      result.mobileWidth = await page.evaluate(() => ({ page: document.documentElement.scrollWidth, viewport: innerWidth }));
      check(result.mobileWidth.page <= result.mobileWidth.viewport + 1, 'Horizontal page overflow on mobile');
      result.chapters.push({ chapter: chapterNumber, solutions: result.solutions, codeBlocks: result.codeBlocks, copyChecks: result.copyChecks, images: result.images.length, localLinks: checkedLinks.size, mobileWidth: result.mobileWidth });
      if (chapterNumber === 2) {
        const images = await page.locator('main .cell-output-display img').evaluateAll(imgs => imgs.map(img => ({src: img.src, alt: img.alt, id: img.closest('[id]')?.id})));
        const gallery = await context.newPage();
        await gallery.setViewportSize({ width: 1500, height: 1000 });
        for (let i = 0; i < images.length; i += 6) {
          const items = images.slice(i, i + 6).map(img => '<article><p>' + img.id + '</p><img src="' + img.src + '"><p>' + img.alt + '</p></article>').join('');
          await gallery.setContent('<style>body{font:14px sans-serif;margin:16px;display:grid;grid-template-columns:1fr 1fr;gap:20px}article{border:1px solid #aaa;padding:8px}img{width:100%}p{margin:4px}</style>' + items);
          await gallery.waitForFunction(() => Array.from(document.images).every(img => img.complete && img.naturalWidth > 0));
          await gallery.screenshot({ path: path.join(__dirname, 'qa-gallery-' + (1 + i / 6) + '.png'), fullPage: true });
        }
        await gallery.close();
      }
    }
    check(result.errors.length === 0, 'Browser JavaScript errors');
    fs.writeFileSync(path.join(__dirname, 'html-check.json'), JSON.stringify(result, null, 2));
    console.log(JSON.stringify({ chapters: result.chapters, errors: result.errors }));
  } finally {
    if (browser) await browser.close();
    server.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
