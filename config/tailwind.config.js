module.exports = {
  darkMode: 'class',
  mode: 'jit',
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.html.erb',
    './app/assets/stylesheets/**/*.css',
  ],
  safelist: [{ pattern: /form-.+/ }, { pattern: /btn-.+/ }],
  theme: {},
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ],
};
