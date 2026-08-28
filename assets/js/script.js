(() => {
  const root = document.documentElement;
  const button = document.querySelector('.theme-button');
  const menu = document.querySelector('.menu-button');
  const nav = document.querySelector('.site-nav');
  const themes = ['system', 'dark', 'light'];
  const stored = localStorage.getItem('watchpost-theme');
  let theme = themes.includes(stored) ? stored : 'system';
  const applyTheme = () => {
    root.dataset.theme = theme;
    const label = button && button.querySelector('.theme-label');
    if (label) label.textContent = theme[0].toUpperCase() + theme.slice(1);
  };
  button?.addEventListener('click', () => {
    theme = themes[(themes.indexOf(theme) + 1) % themes.length];
    localStorage.setItem('watchpost-theme', theme);
    applyTheme();
  });
  menu?.addEventListener('click', () => {
    const open = menu.getAttribute('aria-expanded') === 'true';
    menu.setAttribute('aria-expanded', String(!open));
    nav?.classList.toggle('open', !open);
  });
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
    copy.textContent = 'Copy';
    copy.addEventListener('click', async () => {
      await navigator.clipboard.writeText(source);
      copy.textContent = 'Copied';
      setTimeout(() => { copy.textContent = 'Copy'; }, 1400);
    });
    pre.append(copy);
  });
  applyTheme();
})();
