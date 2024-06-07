/**
 * Add listener for theme mode toggle
 */
const toggleTop = document.getElementById('mode-toggle');
const toggleSide = document.getElementById('mode-toggle-side');

export function modeWatcher() {
  if (toggleTop) {
    toggleTop.addEventListener('click', () => {
      modeToggle.flipMode();
    });
  }
  if (toggleSide) {
    toggleSide.addEventListener('click', () => {
      modeToggle.flipMode();
    });
  }
}
