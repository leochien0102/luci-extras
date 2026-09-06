'use strict';
'require baseclass';

/*
 * Argon Plus - embedded theme settings.
 *
 * Mounts the bundled argon-plus-config view directly below the theme
 * selector on the System Properties -> Language and Style page, following
 * the approach of luci-theme-proton2025. The block only appears while the
 * Argon Plus design is selected; with any other theme the settings belong
 * to a theme that is not in use.
 *
 * The upstream luci-app-argon-config menu entry is deliberately not part
 * of this package: theme and configuration ship together and the settings
 * live here instead of a menu page of their own.
 */

const THEME_MEDIA_URL = '/luci-static/argon-plus';
const CONTAINER_ID = 'argon-plus-theme-settings';
const SETTINGS_PAGE = 'admin-system-system';

/* Incremented whenever the block is unmounted or the page changes, so a
 * view that was still loading can detect that it is stale and bail out. */
let mountGeneration = 0;
let debounceTimer = null;

function designFieldNode() {
	return document.querySelector('[data-name="_mediaurlbase"]');
}

function selectedDesign() {
	const select = designFieldNode()?.querySelector('select');
	return select ? select.value : null;
}

function unmountSettings() {
	mountGeneration++;

	const el = document.getElementById(CONTAINER_ID);
	if (el) el.remove();
}

function mountSettings() {
	const gen = ++mountGeneration;

	if (document.getElementById(CONTAINER_ID) || selectedDesign() !== THEME_MEDIA_URL)
		return;

	const field = designFieldNode();
	if (!field)
		return;

	const section = field.closest('.cbi-section-node');
	if (!section)
		return;

	/* Newer LuCI builds render a built-in "Table Filters" field after the
	 * design selector; keep the block below it when present. */
	const after = section.querySelector('[data-name="_tablefilters"]') || field;

	const title = E('h4', { 'style': 'margin:0 0 1rem 0; font-size:.95rem; font-weight:600' },
		_('Argon theme configuration'));

	const spinner = E('em', { 'class': 'spinning' }, _('Loading settings…'));

	const body = E('div', {
		'style': 'margin-top:1.5rem; padding-top:1.5rem; border-top:1px solid rgba(128,128,128,.25)'
	}, [ title, spinner ]);

	const wrapper = E('div', { 'id': CONTAINER_ID }, body);

	after.insertAdjacentElement('afterend', wrapper);

	/* Deliberately not a LuCI view and deliberately not under view/: a view
	 * mounts itself the moment it is constructed -- LuCI.view's __init__
	 * replaces the whole of #view with its own render() output -- and
	 * L.require() constructs what it loads. Requiring a view from here
	 * therefore wiped the System page and put the config in its place.
	 * What comes back is the instance, not the class, so it is used as-is. */
	L.require('argon-plus-config').then((config) => {
		if (gen !== mountGeneration)
			return;

		return config.load().then((data) => {
			if (gen !== mountGeneration)
				return;

			return config.render(data);
		}).then((dom) => {
			if (gen !== mountGeneration)
				return;

			spinner.remove();
			body.appendChild(dom);
		});
	}).catch((e) => {
		if (gen === mountGeneration) {
			spinner.classList.remove('spinning');
			spinner.textContent = _('Failed to load the theme settings: %s').format(e.message || e);
		}
	});
}

function scheduleSync() {
	if (debounceTimer !== null)
		clearTimeout(debounceTimer);

	debounceTimer = setTimeout(() => {
		debounceTimer = null;

		if ((document.body.dataset.page || '') !== SETTINGS_PAGE) {
			unmountSettings();
			return;
		}

		if (document.getElementById(CONTAINER_ID))
			return;

		if (designFieldNode() && selectedDesign() === THEME_MEDIA_URL)
			mountSettings();
		else
			unmountSettings();
	}, 150);
}

return baseclass.extend({
	__init__() {
		const observer = new MutationObserver(scheduleSync);
		observer.observe(document.body, { childList: true, subtree: true });

		document.addEventListener('change', (ev) => {
			if (!ev.target || ev.target.tagName !== 'SELECT')
				return;

			if (ev.target.closest('[data-name="_mediaurlbase"]'))
				scheduleSync();
		});

		scheduleSync();
	}
});
