(() => {
  // Pinned: the bridge relies on tolgee-js internals (shadow root id, dialog role, MUI classes).
  const TOLGEE_WEB =
    'https://cdn.jsdelivr.net/npm/@tolgee/web@7.3.0/dist/tolgee-web.development.umd.min.js';

  const WIDE_DIALOG_CSS = `
    @media (max-width: 760px) {
      .MuiDialog-paper {
        margin: 8px !important;
        width: calc(100% - 16px) !important;
        max-width: none !important;
        max-height: calc(100% - 16px) !important;
      }
    }
  `;

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.onload = resolve;
      script.onerror = () => reject(new Error(`Failed to load ${src}`));
      document.head.appendChild(script);
    });
  }

  function post(message) {
    window.TolgeeBridge?.postMessage(JSON.stringify(message));
  }

  const parse = (value) => (typeof value === 'string' ? JSON.parse(value) : value);

  // Flutter owns key detection, so this observer finds nothing in the DOM and only
  // hands core's click handler to Flutter, which opens the stock in-context dialog.
  let openKeys;

  // tolgee-js positions its key picker next to the clicked element, so this stands in
  // for the Flutter widget, which has no DOM element of its own.
  let anchor;
  function anchorAt(rect) {
    anchor ??= document.createElement('div');
    anchor.style.cssText =
      `position: fixed; pointer-events: none; left: ${rect.left}px; top: ${rect.top}px; ` +
      `width: ${rect.width}px; height: ${rect.height}px;`;
    if (!anchor.isConnected) document.body.appendChild(anchor);
    return anchor;
  }

  const FlutterObserver = () => (tolgee, tools) => {
    tools.setObserver(() => ({
      unwrap: (text) => ({ text, keys: [] }),
      wrap: ({ translation }) => translation,
      retranslate() {},
      stop() {},
      highlight: () => ({ unhighlight() {} }),
      outputNotFormattable: false,
      findPositions: () => [],
      run({ onClick }) {
        openKeys = ({ keys, rect }) =>
          onClick({
            keysAndDefaults: keys.map((key) => ({ key })),
            target: rect ? anchorAt(rect) : document.body,
          });
      },
    }));
    return tolgee;
  };

  // Set by tolgeeOpen; cleared once the key picker or the dialog has closed again.
  let openedAt;
  let seenOpen = false;
  let closedPolls = 0;

  function watchDialog() {
    setInterval(() => {
      const root = document.getElementById('__tolgee_dev_tools')?.shadowRoot;
      if (root && !root.getElementById('flutter-bridge-style')) {
        const style = document.createElement('style');
        style.id = 'flutter-bridge-style';
        style.textContent = WIDE_DIALOG_CSS;
        root.appendChild(style);
      }
      if (openedAt === undefined) return;
      // The key picker is a menu; it closes without opening the dialog when dismissed.
      const isOpen = !!root?.querySelector('[role="dialog"], [role="menu"]');
      if (isOpen) {
        seenOpen = true;
        closedPolls = 0;
        return;
      }
      // Two polls in a row, so the switch from the picker to the dialog doesn't count.
      closedPolls++;
      const neverOpened = !seenOpen && Date.now() - openedAt > 5000;
      if ((seenOpen && closedPolls >= 2) || neverOpened) {
        openedAt = undefined;
        seenOpen = false;
        closedPolls = 0;
        post({ type: 'closed' });
      }
    }, 200);
  }

  window.tolgeeInit = async (config) => {
    try {
      const { apiUrl, apiKey, language } = parse(config);
      await loadScript(TOLGEE_WEB);
      const { Tolgee, DevTools } = window['@tolgee/web'];
      const tolgee = Tolgee()
        .use(FlutterObserver())
        .use(DevTools())
        .init({ apiUrl, apiKey, language });
      tolgee.on('permanentChange', ({ value }) => post({ type: 'saved', key: value.key }));
      await tolgee.run();
      watchDialog();
      post({ type: 'ready' });
    } catch (e) {
      post({ type: 'error', message: String(e?.message ?? e) });
      throw e;
    }
  };

  window.tolgeeOpen = (request) => {
    openedAt = Date.now();
    seenOpen = false;
    closedPolls = 0;
    openKeys(parse(request));
  };
})();
