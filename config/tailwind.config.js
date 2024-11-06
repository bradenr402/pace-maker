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
  theme: {
    extend: {
      fontFamily: {
        sans: ['InterVariable', 'sans-serif'],
      },
      spacing: {
        4.5: '1.125rem',
        5.5: '1.375rem',
      },
      animation: {
        'ping-slow': 'ping 3s cubic-bezier(0, 0, 0.2, 1) infinite',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ],
  future: {
    hoverOnlyWhenSupported: true,
  },
};
