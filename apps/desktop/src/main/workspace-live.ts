// A side-browser tab's page while it lives. A page that closes itself (window.close(), e.g. a confirmation link such as
// Stripe's) leaves `view.webContents` undefined or destroyed; asking it `isDestroyed()` threw "Cannot read properties of
// undefined (reading 'isDestroyed')" in every list, every save and the quit (18.11.2026: the side browser dead from 12:24, an
// update that could not end the app). Owns: page liveness and observing self-close. Never: closing, saving or listing tabs.
import type { WebContents } from 'electron';

export interface TabWithPage { view?: { webContents?: WebContents } }

export function livePage(tab: TabWithPage | undefined): WebContents | undefined {
  const contents = tab?.view?.webContents;
  return contents && !contents.isDestroyed() ? contents : undefined;
}

// Electron emits close before destruction (CloseContents), but WebContents' event overloads omit it.
// Capture the address while the page still exposes it; destruction still owns removing the tab.
export function watchPageClose(
  contents: WebContents,
  isCurrent: () => boolean,
  observe: (page: WebContents | null) => void,
  remove: (url: string | undefined) => void,
): () => void {
  let url: string | undefined;
  (contents as import('node:events').EventEmitter).on('close', () => {
    if (isCurrent() && !contents.isDestroyed()) {
      const address = contents.getURL();
      if (/^https?:\/\//i.test(address)) url = address;
    }
  });
  observe(contents);
  contents.once('destroyed', () => {
    observe(null);
    if (isCurrent()) remove(url);
  });
  return () => { url = undefined; };
}
