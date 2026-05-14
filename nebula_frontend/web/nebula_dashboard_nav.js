(function () {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker
      .getRegistrations()
      .then((registrations) => registrations.forEach((registration) => registration.unregister()))
      .catch(() => {});
  }

  if ("caches" in window) {
    caches
      .keys()
      .then((keys) => keys.forEach((key) => caches.delete(key)))
      .catch(() => {});
  }

  const pages = {
    Dashboard: {
      title: "Nebula Core Online",
      subtitle: "Operations feed",
      lines: [
        "Welcome to the OMNICOM main console.",
        "Backend link: localhost:4400",
        "Frontend link: localhost:5400",
      ],
    },
    Messages: {
      title: "Messages",
      subtitle: "Local message center",
      lines: [
        "Inbox ready.",
        "Channel message routes exist in the backend source.",
        "Database tables still need to be added for persistent chat.",
      ],
    },
    Contacts: {
      title: "Contacts",
      subtitle: "Presence roster",
      lines: [
        "User_42A - Online",
        "Nebula relay - Online",
        "Contacts service - Ready for backend wiring",
      ],
    },
    Channels: {
      title: "Channels",
      subtitle: "Directory",
      lines: ["# general - Open", "# watch-party - Open", "# system - Operators only"],
    },
    Servers: {
      title: "Servers",
      subtitle: "Runtime map",
      lines: [
        "API server: http://localhost:4400",
        "Web server: http://localhost:5400",
        "Database: local memory mode for this run",
      ],
    },
    Settings: {
      title: "Settings",
      subtitle: "Session controls",
      lines: [
        "Theme toggle is available in the top bar.",
        "Logout is available in the top bar.",
        "Watch Party is available in source and will appear after a full Flutter rebuild.",
      ],
    },
    "System Log": {
      title: "System Log",
      subtitle: "Latest checks",
      lines: [
        "Backend health endpoint responded OK.",
        "Login/register are pointed at localhost:4400.",
        "Dashboard buttons are now wired in the live bundle.",
      ],
    },
  };

  function ensureOverlay() {
    let overlay = document.getElementById("nebula-dashboard-panel");
    if (overlay) return overlay;

    overlay = document.createElement("section");
    overlay.id = "nebula-dashboard-panel";
    overlay.style.cssText = [
      "position:fixed",
      "left:220px",
      "top:60px",
      "right:0",
      "bottom:0",
      "z-index:20",
      "box-sizing:border-box",
      "padding:48px",
      "background:linear-gradient(180deg,#0b0e15,#080b14)",
      "color:rgba(255,255,255,.82)",
      "font-family:system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif",
      "overflow:auto",
    ].join(";");
    document.body.appendChild(overlay);
    return overlay;
  }

  window.__nebulaDashboardNav = function (label) {
    const page = pages[label] || pages.Dashboard;
    const overlay = ensureOverlay();
    overlay.innerHTML = `
      <div style="max-width:760px;margin:0 auto;">
        <div style="display:flex;align-items:center;justify-content:space-between;gap:24px;">
          <div>
            <h1 style="margin:0;color:#fff;font-size:32px;letter-spacing:.04em;">${page.title}</h1>
            <div style="margin-top:6px;color:#ffea00;font-size:13px;letter-spacing:.12em;text-transform:uppercase;">${page.subtitle}</div>
          </div>
          <button type="button" id="nebula-dashboard-close" style="border:1px solid rgba(255,234,0,.6);background:rgba(255,234,0,.1);color:#ffea00;border-radius:6px;padding:8px 12px;cursor:pointer;">Close</button>
        </div>
        <div style="margin-top:34px;display:grid;gap:12px;">
          ${page.lines
            .map(
              (line) =>
                `<div style="border:1px solid rgba(255,234,0,.18);background:rgba(255,255,255,.04);border-radius:8px;padding:14px 16px;font-family:ui-monospace,SFMono-Regular,Menlo,monospace;">${line}</div>`
            )
            .join("")}
        </div>
      </div>
    `;
    overlay.querySelector("#nebula-dashboard-close").onclick = function () {
      overlay.remove();
    };
  };
})();
