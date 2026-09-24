/*
  KnScript notify (kn_timer / kn_doctor / kn_policearmor 共通)
  3 リソースで同じ内容。直すときは 3 つとも直すこと。

  受信: SendNUIMessage({ action = 'kn:notify', title, description, type, duration, position })
  文字列は textContent で入れる(HTML として解釈しない)。
*/
(function () {
    var MAX = 3;
    var ICON = { success: '✓', error: '✕', warning: '!', info: 'i' };
    var POS = { 'top-right': 1, 'top-left': 1, 'top-center': 1, 'bottom-right': 1, 'bottom-left': 1 };
    var root = null;

    function getRoot(pos) {
        if (!root) {
            root = document.createElement('div');
            root.id = 'kn-notify';
            document.body.appendChild(root);
        }
        root.setAttribute('data-pos', POS[pos] ? pos : 'top-right');
        return root;
    }

    function dismiss(n) {
        if (n.knGone) return;
        n.knGone = true;
        n.classList.add('out');
        setTimeout(function () { if (n.parentNode) n.parentNode.removeChild(n); }, 220);
    }

    function show(m) {
        var type = m.type === 'inform' ? 'info' : m.type;
        if (!ICON[type]) type = 'info';
        var ms = Math.max(1000, Math.min(15000, Number(m.duration) || 4000));

        var n = document.createElement('div');
        n.className = 'kn-n ' + type;

        var icon = document.createElement('div');
        icon.className = 'kn-n-icon';
        icon.textContent = ICON[type];

        var text = document.createElement('div');
        text.className = 'kn-n-text';
        if (m.title) {
            var t = document.createElement('div');
            t.className = 'kn-n-title';
            t.textContent = String(m.title);
            text.appendChild(t);
        }
        if (m.description) {
            var d = document.createElement('div');
            d.className = 'kn-n-desc';
            d.textContent = String(m.description);
            text.appendChild(d);
        }

        var bar = document.createElement('i');
        bar.className = 'kn-n-bar';
        bar.style.animationDuration = ms + 'ms';

        n.appendChild(icon);
        n.appendChild(text);
        n.appendChild(bar);

        var r = getRoot(m.position);
        r.appendChild(n);

        // 上限を超えたら古いものから消す(消えかけのものは数えない)
        var live = [];
        for (var i = 0; i < r.children.length; i++) {
            if (!r.children[i].knGone) live.push(r.children[i]);
        }
        for (var j = 0; j < live.length - MAX; j++) dismiss(live[j]);

        setTimeout(function () { dismiss(n); }, ms);
    }

    window.addEventListener('message', function (e) {
        var m = e.data || {};
        if (m.action === 'kn:notify') show(m);
    });
})();
