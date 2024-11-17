if (navigator.serviceWorker) {
  navigator.serviceWorker
    .register('/service-worker.js', { scope: '/' })
    .then(() => navigator.serviceWorker.ready)
    .then((registration) => {
      // Check if SyncManager is supported in the browser
      if ('SyncManager' in window) {
        registration.sync
          .register('sync-forms')
          .then(() => console.log('[Companion]', 'Background sync registered!'))
          .catch((err) => console.log('[Companion]', 'Sync registration failed:', err));
      } else {
        console.log('[Companion]', 'Background sync is not supported in this browser.');
      }
    })
    .catch((err) => console.log('[Companion]', 'Service worker registration failed:', err));
}
