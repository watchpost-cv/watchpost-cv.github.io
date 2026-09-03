(() => {
  const root = document.documentElement;
  const themeButtons = [...document.querySelectorAll('.theme-button')];
  const themes = ['system', 'dark', 'light'];
  const stored = localStorage.getItem('watchpost-theme');
  let theme = themes.includes(stored) ? stored : 'system';
  const applyTheme = () => {
    root.dataset.theme = theme;
    themeButtons.forEach(btn => {
      const label = btn.querySelector('.theme-label');
      if (label) label.textContent = theme[0].toUpperCase() + theme.slice(1);
    });
  };
  themeButtons.forEach(btn => btn?.addEventListener('click', () => {
    theme = themes[(themes.indexOf(theme) + 1) % themes.length];
    localStorage.setItem('watchpost-theme', theme);
    applyTheme();
  }));

  const menuToggle = document.querySelector('[data-menu-toggle]');
  const mobileMenu = document.getElementById('mobile-menu');
  const docsToggle = document.querySelector('[data-docs-menu-toggle]');
  const docsMenu = document.getElementById('docs-mobile-nav');
  const normalisePath = value => {
    let path;
    try { path = decodeURIComponent(new URL(value, location.href).pathname); }
    catch { path = String(value); }
    return path.replace(/\/index\.html$/, '').replace(/\.html$/, '').replace(/\/$/, '') || '/';
  };
  const wireDocs = root => {
    const groups = [...root.querySelectorAll('[data-docs-group]')];
    if (!groups.length) return;
    const currentPath = normalisePath(location.href);
    const setOpen = (group, open) => {
      const toggle = group.querySelector('.docs-nav-toggle');
      const links = group.querySelector('.docs-nav-links');
      toggle.setAttribute('aria-expanded', String(open));
      links.hidden = !open;
    };
    let activeGroup = null;
    root.querySelectorAll('.docs-nav-links a').forEach(link => {
      const active = normalisePath(link.href) === currentPath;
      link.classList.toggle('active', active);
      if (active) { link.setAttribute('aria-current', 'page'); activeGroup = link.closest('[data-docs-group]'); }
    });
    groups.forEach(group => {
      setOpen(group, group === activeGroup);
      group.querySelector('.docs-nav-toggle').addEventListener('click', () => {
        setOpen(group, group.querySelector('.docs-nav-toggle').getAttribute('aria-expanded') !== 'true');
      });
    });
  };
  wireDocs(document.querySelector('.docs-nav'));
  const setMenu = (panel, btn, open) => {
    panel.classList.toggle('open', open);
    panel.toggleAttribute('hidden', !open);
    btn.setAttribute('aria-expanded', String(open));
    btn.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
  };
  if (menuToggle && mobileMenu) {
    menuToggle.addEventListener('click', () => {
      const open = !mobileMenu.classList.contains('open');
      if (open && docsMenu && docsMenu.classList.contains('open')) setMenu(docsMenu, docsToggle, false);
      setMenu(mobileMenu, menuToggle, open);
      document.body.style.overflow = open ? 'hidden' : '';
    });
    mobileMenu.querySelectorAll('a').forEach(a => a.addEventListener('click', () => { setMenu(mobileMenu, menuToggle, false); document.body.style.overflow = ''; }));
    document.addEventListener('keydown', e => { if (e.key === 'Escape' && mobileMenu.classList.contains('open')) { setMenu(mobileMenu, menuToggle, false); document.body.style.overflow = ''; menuToggle.focus(); } });
  }
  if (docsToggle && docsMenu) {
    const source = document.querySelector('.docs-nav');
    if (source) { docsMenu.innerHTML = source.innerHTML; wireDocs(docsMenu); }
    docsToggle.addEventListener('click', () => {
      const open = !docsMenu.classList.contains('open');
      if (open && mobileMenu && mobileMenu.classList.contains('open')) { setMenu(mobileMenu, menuToggle, false); document.body.style.overflow = ''; }
      setMenu(docsMenu, docsToggle, open);
    });
    docsMenu.querySelectorAll('a').forEach(a => a.addEventListener('click', () => setMenu(docsMenu, docsToggle, false)));
    document.addEventListener('keydown', e => { if (e.key === 'Escape' && docsMenu.classList.contains('open')) { setMenu(docsMenu, docsToggle, false); docsToggle.focus(); } });
  }

  document.querySelectorAll('pre').forEach((pre) => {
    const code = pre.querySelector('code');
    const source = code?.textContent || pre.innerText;
    if (code) {
      const token = /("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|#.*$|\/\/.*$|\b(?:true|false|null|go|build|export|curl|POST|GET|systemctl|sudo)\b|--?[a-z][\w-]*|\b\d+(?:\.\d+)?\b)/gim;
      const fragment = document.createDocumentFragment();
      let cursor = 0;
      for (const match of source.matchAll(token)) {
        fragment.append(document.createTextNode(source.slice(cursor, match.index)));
        const span = document.createElement('span'), value = match[0];
        span.className = /^['"]/.test(value) ? 'tok-string' : /^(#|\/\/)/.test(value) ? 'tok-comment' : /^-/.test(value) ? 'tok-option' : /^\d/.test(value) ? 'tok-number' : 'tok-keyword';
        span.textContent = value;
        fragment.append(span);
        cursor = match.index + value.length;
      }
      fragment.append(document.createTextNode(source.slice(cursor)));
      code.replaceChildren(fragment);
    }
    const copy = document.createElement('button');
    copy.className = 'copy-button';
    copy.type = 'button';
    copy.setAttribute('aria-label', 'Copy code');
    copy.title = 'Copy code';
    copy.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true"><rect x="8" y="8" width="11" height="11" rx="2"></rect><path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2"></path></svg>';
    copy.addEventListener('click', async () => {
      await navigator.clipboard.writeText(source);
      copy.setAttribute('aria-label', 'Copied');
      setTimeout(() => { copy.setAttribute('aria-label', 'Copy code'); }, 1400);
    });
    pre.append(copy);
  });
  applyTheme();
})();
