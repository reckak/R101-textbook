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
    for (const chapterNumber of [1, 2, 3, 4, 5, 6, 7]) {
      await page.setViewportSize({ width: 1440, height: 1000 });
      const titles = { 1: 'První kroky', 2: 'Základy tvorby', 3: 'Úpravy dat', 4: 'Vektory, faktory', 5: 'Import dat', 6: 'Práce se skóry', 7: 'Základní statistické' };
      await page.locator('#quarto-sidebar a.sidebar-link').filter({ hasText: titles[chapterNumber] }).click();
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
      const tocTarget = { 1: '#sec-balicky', 2: '#sec-vztahy', 3: '#sec-upravy-souhrny', 4: '#sec-struktury-faktory', 5: '#sec-import-labelled', 6: '#sec-skory-rozdeleni', 7: '#sec-testy-ttest' }[chapterNumber];
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
      } else if (chapterNumber === 2) {
        await screenshot('html-graph', '#fig-tucnaci-final');
        await screenshot('html-solution', '#fig-reseni-samostatne');
      } else if (chapterNumber === 3) {
        await screenshot('html-table', '#sec-upravy-mesicni .cell');
        await screenshot('html-graph', '#fig-l03-hodiny');
        await screenshot('html-solution', '#fig-l03-reseni-samostatne');
      } else if (chapterNumber === 4) {
        await screenshot('html-table', '#sec-struktury-tabulky-vyber > .cell:first-of-type');
        await screenshot('html-graph', '#fig-l04-narocnost');
        await screenshot('html-solution', '#sec-struktury-samostatne .callout');
      } else if (chapterNumber === 5) {
        await screenshot('html-downloads', '#sec-import-data');
        await screenshot('html-table', '#sec-import-excel > .cell:first-of-type');
        await screenshot('html-labels', '#sec-import-labelled');
        await screenshot('html-header', '#sec-import-excel-hlavicka > .cell:first-of-type');
        await screenshot('html-encoding', '#sec-import-kodovani');
        await screenshot('html-solution', '#sec-import-samostatne .callout');
        const downloads = page.locator('main a[download]');
        check(await downloads.count() === 5, 'Lesson 05 must expose five downloadable files');
        for (const link of await downloads.all()) {
          const href = await link.getAttribute('href');
          const filename = await link.getAttribute('download');
          const response = await context.request.get(new URL(href, page.url()).href);
          const bytes = await response.body();
          const original = fs.readFileSync(path.join(__dirname, '..', '..', 'data', 'raw', filename));
          check(response.ok() && bytes.equals(original), 'Download differs from source: ' + filename);
          const [download] = await Promise.all([page.waitForEvent('download'), link.click()]);
          check(await download.failure() === null, 'Download click failed: ' + filename);
          check(download.suggestedFilename() === filename, 'Wrong download filename');
        }
        const publicFiles = fs.readdirSync(path.join(root, 'data', 'raw')).sort();
        check(JSON.stringify(publicFiles) === JSON.stringify([
          'ceske_odpovedi.csv', 'four_countries_teaching.xlsx', 'help_seeking.xlsx', 'international.sav',
          'monitoring_teaching.sav', 'students.txt'
        ]), 'Published data directory contains unexpected files');
      } else if (chapterNumber === 6) {
        await screenshot('html-downloads', '#sec-skory-data');
        await screenshot('html-table', '#sec-skory-alfa > .cell:first-of-type');
        await screenshot('html-graph', '#fig-skory-final');
        await screenshot('html-qqbands', '#fig-skory-qqplotr-pasy');
        await screenshot('html-solution', '#sec-skory-samostatne .callout');
        const downloads = page.locator('main a[download]');
        check(await downloads.count() === 2, 'Lesson 06 must expose two downloadable files');
        for (const link of await downloads.all()) {
          const href = await link.getAttribute('href');
          const filename = await link.getAttribute('download');
          const response = await context.request.get(new URL(href, page.url()).href);
          const bytes = await response.body();
          const original = fs.readFileSync(path.join(__dirname, '..', '..', 'data', 'clean', filename));
          check(response.ok() && bytes.equals(original), 'Download differs from source: ' + filename);
          const [download] = await Promise.all([page.waitForEvent('download'), link.click()]);
          check(await download.failure() === null, 'Download click failed: ' + filename);
          check(download.suggestedFilename() === filename, 'Wrong download filename');
        }
        check(JSON.stringify(fs.readdirSync(path.join(root, 'data')).sort()) === JSON.stringify(['clean', 'raw']),
          'Published data folder contains unexpected subfolders');
        const cleanFiles = fs.readdirSync(path.join(root, 'data', 'clean')).sort();
        check(JSON.stringify(cleanFiles) === JSON.stringify(['help_seeking_codebook.rds', 'help_seeking_data.rds']),
          'Published data/clean directory contains unexpected files');
      } else {
        await screenshot('html-downloads', '#sec-testy-data');
        await screenshot('html-table', '#sec-testy-ttest > .cell:first-of-type');
        await screenshot('html-graph', '#fig-testy-boxplot-pohlavi');
        await screenshot('html-chi', '#sec-testy-chi');
        await screenshot('html-solution', '#sec-testy-samostatne .callout');
        const downloads = page.locator('main a[download]');
        check(await downloads.count() === 1, 'Lesson 07 must expose one downloadable file');
        for (const link of await downloads.all()) {
          const href = await link.getAttribute('href');
          const filename = await link.getAttribute('download');
          const response = await context.request.get(new URL(href, page.url()).href);
          const bytes = await response.body();
          const original = fs.readFileSync(path.join(__dirname, '..', '..', 'data', 'raw', filename));
          check(response.ok() && bytes.equals(original), 'Download differs from source: ' + filename);
          const [download] = await Promise.all([page.waitForEvent('download'), link.click()]);
          check(await download.failure() === null, 'Download click failed: ' + filename);
          check(download.suggestedFilename() === filename, 'Wrong download filename');
        }
        for (const id of ['#sec-testy-rozhodnuti', '#sec-testy-potize']) {
          check(await page.locator(id + ' .table-responsive').getAttribute('tabindex') === '0',
            'Lesson 07 table must be keyboard focusable: ' + id);
        }
      }
      await page.setViewportSize({ width: 390, height: 844 });
      await screenshot('html-mobile');
      if (chapterNumber >= 5) {
        const downloadSection = { 5: '#sec-import-data', 6: '#sec-skory-data', 7: '#sec-testy-data' }[chapterNumber];
        await screenshot('html-mobile-downloads', downloadSection);
        const downloadTable = page.locator(downloadSection + ' .table-responsive');
        check(await downloadTable.evaluate(el => getComputedStyle(el).overflowX === 'auto'),
          'Download table must allow scrolling if wider than its mobile container');
      }
      result.mobileWidth = await page.evaluate(() => ({ page: document.documentElement.scrollWidth, viewport: innerWidth }));
      if (result.mobileWidth.page > result.mobileWidth.viewport + 1) {
        const overflowing = await page.locator('main *').evaluateAll(elements => elements
          .filter(el => {
            if (el.getBoundingClientRect().right <= innerWidth + 1) return false;
            for (let parent = el.parentElement; parent; parent = parent.parentElement) {
              if (['auto', 'scroll', 'hidden', 'clip'].includes(getComputedStyle(parent).overflowX)) return false;
            }
            return true;
          })
          .map(el => ({ tag: el.tagName, id: el.id, class: el.className,
            right: Math.round(el.getBoundingClientRect().right), text: el.textContent.trim().slice(0, 120) }))
          .slice(0, 20));
        throw new Error(`Horizontal page overflow on mobile: chapter ${chapterNumber}, ` +
          `${result.mobileWidth.page}px / ${result.mobileWidth.viewport}px; ${JSON.stringify(overflowing)}`);
      }
      result.chapters.push({ chapter: chapterNumber, solutions: result.solutions, codeBlocks: result.codeBlocks, copyChecks: result.copyChecks, images: result.images.length, localLinks: checkedLinks.size, mobileWidth: result.mobileWidth });
      if (chapterNumber === 6) {
        const problems = page.locator('#sec-skory-potize .table-responsive');
        check(await problems.getAttribute('tabindex') === '0', 'Troubleshooting table must be keyboard focusable');
        // Stress intrinsic table width independently of the platform's default fonts.
        const wideCode = await page.addStyleTag({ content: '#sec-skory-potize code { font-size: 20px; }' });
        try {
          check(await problems.evaluate(el => getComputedStyle(el).overflowX === 'auto' && el.scrollWidth > el.clientWidth),
            'Wide troubleshooting table must scroll inside its container');
          check(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1),
            'Troubleshooting table overflows the mobile page with wider code');
          await problems.focus();
          await page.keyboard.press('ArrowRight');
          await page.waitForFunction(() => document.querySelector('#sec-skory-potize .table-responsive').scrollLeft > 0);
        } finally {
          await wideCode.evaluate(el => el.remove());
          await problems.evaluate(el => { el.scrollLeft = 0; });
        }
        await screenshot('html-mobile-troubleshooting', '#sec-skory-potize');
        // A wider fallback font reproduces the unbroken DOI overflow across platforms.
        const fallbackFont = await page.addStyleTag({ content: 'main a.uri { font-family: Arial, sans-serif; }' });
        try {
          const width = await page.evaluate(() => document.documentElement.scrollWidth);
          check(width <= 391, `Chapter 6 URL overflow with fallback font: ${width}px / 390px`);
        } finally {
          await fallbackFont.evaluate(el => el.remove());
        }
      }
      if (chapterNumber >= 2) {
        const images = await page.locator('main .cell-output-display img').evaluateAll(imgs => imgs.map(img => ({src: img.src, alt: img.alt, id: img.closest('[id]')?.id})));
        const gallery = await context.newPage();
        await gallery.setViewportSize({ width: 1500, height: 1000 });
        for (let i = 0; i < images.length; i += 6) {
          const items = images.slice(i, i + 6).map(img => '<article><p>' + img.id + '</p><img src="' + img.src + '"><p>' + img.alt + '</p></article>').join('');
          await gallery.setContent('<style>body{font:14px sans-serif;margin:16px;display:grid;grid-template-columns:1fr 1fr;gap:20px}article{border:1px solid #aaa;padding:8px}img{width:100%}p{margin:4px}</style>' + items);
          await gallery.waitForFunction(() => Array.from(document.images).every(img => img.complete && img.naturalWidth > 0));
          await gallery.screenshot({ path: path.join(__dirname, 'qa-gallery-' + chapterNumber + '-' + (1 + i / 6) + '.png'), fullPage: true });
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
