/**
 * Client-side live search for list pages.
 *
 * Expected markup:
 * - form.toolbar-form with input.live-search-input
 * - optional button.live-search-reset
 * - data rows: tr.live-search-row
 * - optional empty rows: tr.live-search-empty
 * - optional sections: [data-live-section] with [data-live-count]
 * - optional global note: #live-search-no-results
 * - optional keyword echo: #live-search-keyword
 */
(function () {
    'use strict';

    function normalize(text) {
        return String(text || '')
            .toLowerCase()
            .replace(/\s+/g, ' ')
            .trim();
    }

    function compact(text) {
        return normalize(text).replace(/[\s\-]+/g, '');
    }

    function rowSearchText(row) {
        var cells = row.cells;
        var parts = [];
        var limit = Math.max(0, cells.length - 1); // skip Actions column
        for (var i = 0; i < limit; i++) {
            parts.push(cells[i].textContent || '');
        }
        return parts.join(' ');
    }

    function matches(row, query, queryCompact) {
        if (!query) {
            return true;
        }
        var hay = rowSearchText(row);
        var hayNorm = normalize(hay);
        var hayCompact = compact(hay);
        return hayNorm.indexOf(query) !== -1
            || (queryCompact && hayCompact.indexOf(queryCompact) !== -1);
    }

    function applyFilter(root, input) {
        var query = normalize(input.value);
        var queryCompact = compact(input.value);
        var totalVisible = 0;

        var sections = root.querySelectorAll('[data-live-section]');
        if (sections.length > 0) {
            sections.forEach(function (section) {
                var rows = section.querySelectorAll('tr.live-search-row');
                var visible = 0;

                rows.forEach(function (row) {
                    var show = matches(row, query, queryCompact);
                    row.hidden = !show;
                    if (show) {
                        visible++;
                    }
                });

                var emptyRow = section.querySelector('tr.live-search-empty');
                if (emptyRow) {
                    // Only show "no match" when there are rows to search but none match
                    emptyRow.hidden = !(rows.length > 0 && visible === 0);
                }

                var countEl = section.querySelector('[data-live-count]');
                if (countEl) {
                    var label = countEl.getAttribute('data-label') || 'Staff';
                    countEl.textContent = visible + ' ' + label;
                }

                totalVisible += visible;
            });
        } else {
            var rows = root.querySelectorAll('tr.live-search-row');
            rows.forEach(function (row) {
                var show = matches(row, query, queryCompact);
                row.hidden = !show;
                if (show) {
                    totalVisible++;
                }
            });

            var emptyRow = root.querySelector('tr.live-search-empty');
            if (emptyRow) {
                emptyRow.hidden = !(rows.length > 0 && totalVisible === 0);
            }
        }

        var noResults = document.getElementById('live-search-no-results');
        if (noResults) {
            var showNoResults = query && totalVisible === 0;
            noResults.hidden = !showNoResults;
            var keywordEl = document.getElementById('live-search-keyword');
            if (keywordEl) {
                keywordEl.textContent = input.value.trim();
            }
        }

        return totalVisible;
    }

    function initOne(form) {
        var input = form.querySelector('.live-search-input');
        if (!input) {
            return;
        }

        var root = document.querySelector('[data-live-root]') || document;
        var resetBtn = form.querySelector('.live-search-reset');

        form.addEventListener('submit', function (event) {
            event.preventDefault();
        });

        input.addEventListener('input', function () {
            applyFilter(root, input);
        });

        // Some browsers fire search when the clear (x) control is used
        input.addEventListener('search', function () {
            applyFilter(root, input);
        });

        if (resetBtn) {
            resetBtn.addEventListener('click', function (event) {
                event.preventDefault();
                input.value = '';
                applyFilter(root, input);
                input.focus();
            });
        }

        // Apply once in case the field is prefilled
        applyFilter(root, input);
    }

    function init() {
        document.querySelectorAll('form.toolbar-form').forEach(initOne);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
