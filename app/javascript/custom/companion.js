if (navigator.serviceWorker) {
  navigator.serviceWorker
    .register('/service-worker.js')
    .then((registration) => console.log('[Companion]', 'Service worker registered:', registration))
    .catch((err) => console.log('[Companion]', 'Service worker registration failed:', err));
}
