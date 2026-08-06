<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Test Meeting — Mobile</title>
<style>
  :root {
    --bg: #f4f5fb;
    --card: #ffffff;
    --border: #e6e8f0;
    --ink: #16181f;
    --ink-soft: #6b7080;
    --purple: #7c5cff;
    --purple-soft: #f1edff;
    --green: #16a35a;
    --green-soft: #ecfdf3;
    --amber-bg: #fef3d9;
    --amber-ink: #9a6b00;
    --red: #e5484d;
    --red-soft: #fdeeee;
    --radius-lg: 18px;
    --radius-md: 12px;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    background: var(--bg);
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Inter, Roboto, sans-serif;
    color: var(--ink);
    -webkit-font-smoothing: antialiased;
  }
  .frame {
    max-width: 400px;
    margin: 24px auto;
    background: var(--bg);
    min-height: 100vh;
    padding-bottom: 40px;
  }

  /* Header */
  .topbar {
    padding: 20px 18px 14px;
  }
  .title-row {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }
  h1 {
    font-size: 24px;
    font-weight: 800;
    margin: 0;
    letter-spacing: -0.02em;
  }
  .badge {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.04em;
    padding: 4px 10px;
    border-radius: 999px;
    background: var(--amber-bg);
    color: var(--amber-ink);
  }
  .badge.cancelled {
    background: var(--red-soft);
    color: var(--red);
  }
  .badge.ended {
    background: #eceef3;
    color: #565b6b;
  }
  .desc {
    margin: 6px 0 0;
    color: var(--ink-soft);
    font-size: 14px;
  }

  /* Action buttons row - horizontally scrollable on mobile */
  .actions {
    display: flex;
    gap: 8px;
    padding: 14px 18px 4px;
    overflow-x: auto;
    scrollbar-width: none;
  }
  .actions::-webkit-scrollbar { display: none; }
  .btn {
    flex: 0 0 auto;
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    font-weight: 700;
    padding: 10px 14px;
    border-radius: var(--radius-md);
    border: 1.5px solid var(--border);
    background: var(--card);
    color: var(--ink);
    white-space: nowrap;
  }
  .btn.primary {
    background: var(--green);
    border-color: var(--green);
    color: white;
  }
  .btn.danger {
    color: var(--red);
    border-color: #f6c9ca;
    background: var(--red-soft);
  }
  .icon { font-size: 14px; line-height: 1; }

  /* Cards */
  .stack {
    padding: 12px 18px;
    display: flex;
    flex-direction: column;
    gap: 14px;
  }
  .card {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 18px;
  }
  .card-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
  }
  .card-head .ico {
    width: 34px;
    height: 34px;
    border-radius: 10px;
    background: var(--purple-soft);
    color: var(--purple);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    flex: 0 0 auto;
  }
  .card-head h2 {
    font-size: 15px;
    margin: 0;
    font-weight: 700;
  }

  .field {
    margin-bottom: 16px;
  }
  .field:last-child { margin-bottom: 0; }
  .field-label {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.04em;
    color: var(--ink-soft);
    text-transform: uppercase;
    margin-bottom: 6px;
  }
  .field-value {
    font-size: 15px;
    font-weight: 700;
  }
  .pill-box {
    background: #f7f7fa;
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 10px 12px;
    font-size: 14px;
    font-weight: 600;
    color: var(--ink);
  }
  .link {
    color: var(--purple);
    font-weight: 700;
    font-size: 14px;
    text-decoration: none;
  }
  .role-pill {
    display: inline-block;
    font-size: 12px;
    font-weight: 700;
    background: var(--purple-soft);
    color: var(--purple);
    padding: 4px 12px;
    border-radius: 999px;
  }
  .divider {
    height: 1px;
    background: var(--border);
    margin: 16px 0;
  }
  .quote-box {
    background: #f7f7fa;
    border-radius: 10px;
    border: 1px solid var(--border);
    padding: 14px 14px 14px 18px;
    font-style: italic;
    font-size: 14px;
    color: var(--ink-soft);
    position: relative;
  }

  /* Status card */
  .status-row {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f7f7fa;
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 12px 14px;
  }
  .dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--amber-ink);
  }
  .dot.cancelled {
    background: var(--red);
  }
  .dot.ended {
    background: #8b8f9d;
  }
  .status-row span {
    font-weight: 700;
    font-size: 13px;
    letter-spacing: 0.03em;
  }
  .lifecycle-value {
    font-weight: 800 !important;
    font-size: 15px !important;
    letter-spacing: normal !important;
  }

  /* Live room */
  .live-desc {
    font-size: 13px;
    color: var(--ink-soft);
    line-height: 1.5;
    margin: 0 0 14px;
  }
  .live-cta {
    background: #f7f7fa;
    border: 1px dashed var(--border);
    border-radius: 10px;
    padding: 14px;
    text-align: center;
    color: var(--ink-soft);
    font-weight: 700;
    font-size: 13px;
  }

  /* Participants */
  .participants-summary {
    display: flex;
    gap: 12px;
    align-items: center;
    background: linear-gradient(90deg, #f6f4ff, #f7f7fa);
    border-radius: 12px;
    padding: 14px;
    margin-bottom: 16px;
  }
  .p-ico {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: var(--card);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    flex: 0 0 auto;
    color: var(--purple);
  }
  .p-title {
    font-weight: 800;
    font-size: 14px;
    margin: 0 0 2px;
  }
  .p-sub {
    font-size: 12px;
    color: var(--ink-soft);
    margin: 0;
    line-height: 1.4;
  }
  .empty-state {
    border: 1.5px dashed var(--border);
    border-radius: 14px;
    padding: 30px 20px;
    text-align: center;
  }
  .empty-ico {
    width: 46px;
    height: 46px;
    margin: 0 auto 14px;
    border-radius: 12px;
    background: var(--purple-soft);
    color: var(--purple);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
  }
  .empty-state h3 {
    font-size: 15px;
    margin: 0 0 8px;
  }
  .empty-state p {
    font-size: 13px;
    color: var(--ink-soft);
    line-height: 1.5;
    margin: 0 0 18px;
  }
  .btn.full {
    width: 100%;
    justify-content: center;
  }

  /* Session Recording */
  .card.recording {
    background: linear-gradient(160deg, #14151a, #0c0d10);
    border: 1px solid #23252c;
    color: #fff;
    position: relative;
    overflow: hidden;
  }
  .rec-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 16px;
  }
  .rec-bar {
    width: 4px;
    height: 18px;
    border-radius: 2px;
    background: var(--green);
    flex: 0 0 auto;
  }
  .rec-head h2 {
    font-size: 15px;
    margin: 0;
    font-weight: 700;
    color: #fff;
  }
  .rec-meta {
    display: flex;
    justify-content: space-between;
    background: #1b1c22;
    border: 1px solid #26272f;
    border-radius: 12px;
    padding: 12px 14px;
    margin-bottom: 12px;
  }
  .rec-meta span {
    font-size: 10.5px;
    font-weight: 700;
    letter-spacing: 0.04em;
    color: #9a9ca8;
  }
  .player {
    display: flex;
    align-items: center;
    gap: 10px;
    background: #1b1c22;
    border: 1px solid #26272f;
    border-radius: 999px;
    padding: 10px 14px;
    margin-bottom: 16px;
  }
  .play-btn {
    width: 26px;
    height: 26px;
    border-radius: 50%;
    background: #2b2c34;
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 auto;
    font-size: 11px;
    color: #fff;
  }
  .time {
    font-size: 12px;
    color: #d7d8de;
    font-weight: 600;
    flex: 0 0 auto;
    white-space: nowrap;
  }
  .track {
    flex: 1;
    height: 4px;
    border-radius: 2px;
    background: #3a3b44;
    position: relative;
  }
  .track::before {
    content: "";
    position: absolute;
    left: 0; top: 0; bottom: 0;
    width: 0%;
    background: #6b6d78;
    border-radius: 2px;
  }
  .vol, .dots {
    font-size: 13px;
    color: #b7b8c1;
    flex: 0 0 auto;
  }
  .download-btn {
    width: 100%;
    text-align: center;
    background: var(--green);
    color: #04241a;
    font-weight: 800;
    font-size: 13px;
    letter-spacing: 0.03em;
    padding: 14px;
    border-radius: 12px;
    border: none;
  }
</style>
</head>
<body>
<div class="frame">

  <div class="topbar">
    <div class="title-row">
      <h1>test meeting</h1>
      <span class="badge ended">ENDED</span>
    </div>
    <p class="desc">description</p>
  </div>

  <div class="stack" style="padding-top: 10px;">

    <!-- Lifecycle status -->
    <div class="card">
      <div class="card-head">
        <div class="ico">⏱</div>
        <h2>Lifecycle</h2>
      </div>
      <div class="field-label">Status</div>
      <div class="status-row"><span class="dot ended"></span><span>ENDED</span></div>

      <div class="field-label" style="margin-top:16px;">Started At</div>
      <div class="status-row"><span class="lifecycle-value">12:20:03 AM</span></div>

      <div class="field-label" style="margin-top:16px;">Ended At</div>
      <div class="status-row"><span class="lifecycle-value">12:20:24 AM</span></div>
    </div>

    <!-- Meeting Overview -->
    <div class="card">
      <div class="card-head">
        <div class="ico">⚙</div>
        <h2>Meeting Overview</h2>
      </div>

      <div class="field">
        <div class="field-label">📅 Scheduled At</div>
        <div class="field-value">Wednesday, August 5, 2026 at 7:10 PM</div>
      </div>

      <div class="field">
        <div class="field-label">👤 Host Reference</div>
        <div class="pill-box">sim-part-host</div>
      </div>

      <div class="field">
        <div class="field-label">ⓘ Your Role</div>
        <span class="role-pill">HOST</span>
      </div>

      <div class="field">
        <div class="field-label">📹 Access Link</div>
        <a class="link" href="#">Copy Invitation Link ›</a>
      </div>

      <div class="divider"></div>

      <div class="field">
        <div class="field-label">ⓘ Meeting Context &amp; Agenda</div>
        <div class="quote-box">description</div>
      </div>
    </div>

    <!-- Live Meeting Room -->
    <div class="card">
      <div class="card-head">
        <div class="ico">📹</div>
        <h2>Live Meeting Room</h2>
      </div>
      <p class="live-desc">The immersive live meeting room features high-end video, screen sharing, and real-time collaboration.</p>
      <div class="live-cta">Meeting not live</div>
    </div>

    <!-- Participants & Roster -->
    <div class="card">
      <div class="card-head">
        <div class="ico">👥</div>
        <h2>Participants &amp; Roster</h2>
      </div>

      <div class="participants-summary">
        <div class="p-ico">👥</div>
        <div>
          <p class="p-title">0 Expected Participants</p>
          <p class="p-sub">Real-time status of session invitees and participant connections.</p>
        </div>
      </div>

      <div class="empty-state">
        <div class="empty-ico">✉</div>
        <h3>No Invitations Found</h3>
        <p>Invite teammates, stakeholders, or external guests to join this session and collaborate in real-time.</p>
        <button class="btn full"><span class="icon">👤</span>Send First Invite</button>
      </div>
    </div>

    <!-- Session Recording -->
    <div class="card recording">
      <div class="rec-head">
        <span class="rec-bar"></span>
        <h2>Session Recording</h2>
      </div>

      <div class="rec-meta">
        <span>FORMAT: SYNTHETIC-PREVIEW</span>
        <span>DURATION: 69 MIN</span>
      </div>

      <div class="player">
        <div class="play-btn">▶</div>
        <span class="time">0:00 / 0:00</span>
        <div class="track"></div>
        <span class="vol">🔊</span>
        <span class="dots">⋮</span>
      </div>

      <button class="download-btn">DOWNLOAD AUDIO FILE (0.75 MB)</button>
    </div>

  </div>
</div>
</body>
</html>