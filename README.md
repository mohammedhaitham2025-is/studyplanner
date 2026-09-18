# Recall Ledger — online setup

Your planner, now hosted on the web with one shared account across your phone and laptop.
Everything is free: GitHub Pages serves the page, Supabase stores the data.

Follow the three parts in order. It takes about 15 minutes.

---

## Part 1 — Supabase (the database)

1. Go to **supabase.com**, sign up, and create a new project. Pick any name and a strong
   database password, and choose the region closest to you (Frankfurt or Mumbai are good
   from Iraq). The project takes a minute or two to start.
2. In the left sidebar open **SQL Editor → New query**. Open `schema.sql` from this folder,
   paste the whole thing in, and press **Run**. It creates the `lectures` table and locks it
   down so only your own account can read your rows.
3. Open **Authentication → Sign in / Providers → Email**. Turn **Confirm email** off, then
   save. This lets you create your account and start using it immediately. (If you'd rather
   keep confirmation on, leave it — you'll just have to click a link in your inbox once.)
4. Open **Settings → API** (called *Project Settings → API keys* in some versions) and copy:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - the **anon / public** key — a long string
5. Open `config.js` in this folder and paste both values between the quotes:

   ```js
   window.RECALL_CONFIG = {
     SUPABASE_URL: "https://abcdefgh.supabase.co",
     SUPABASE_ANON_KEY: "eyJhbGciOi..."
   };
   ```

   Both are safe in a public repository. The anon key can only do what the security rules in
   `schema.sql` allow, and those rules tie every row to the account that created it. Never
   put the **service_role** key in this file — that one bypasses the rules.

---

## Part 2 — GitHub (the hosting)

1. Go to **github.com**, sign in, and click **New repository**. Name it `recall-ledger`,
   keep it **Public** (GitHub Pages needs a paid plan for private repos), and create it.
2. On the new repo page click **uploading an existing file**, then drag in all of these:

   ```
   index.html   config.js   sw.js   manifest.webmanifest
   icon.svg     icon-maskable.svg   schema.sql   README.md
   ```

   Click **Commit changes**.
3. Go to **Settings → Pages**. Under *Build and deployment*, set **Source: Deploy from a
   branch**, **Branch: main**, folder **/ (root)**, and Save.
4. Wait a minute, refresh the page, and GitHub shows your address:
   `https://YOUR-USERNAME.github.io/recall-ledger/`

That address is your app. It works in any browser, anywhere.

---

## Part 3 — Your devices

**On the laptop first:**

1. Open the address. The sign-in box appears — enter your email and a password (6+
   characters) and click **Create account**.
2. The bar under the title should read `your@email · synced at HH:MM` with a green dot.
3. If you already have lectures saved in the old local file: open your old
   `study-planner.html`, go to the Ledger tab, click **Export backup (.json)**, then on the
   new site click **Import backup** and pick that file. It uploads within a second or two.

**Then the phone:**

1. Open the same address, tap **Sign in**, and use the same email and password.
2. Add it to the home screen so it opens like an app:
   - **Android / Chrome:** menu ⋮ → *Add to Home screen*
   - **iPhone / Safari:** share button → *Add to Home Screen*

Now marking a rep Done on the phone updates the laptop within a second if both are open,
and on the next load otherwise.

---

## The Settings tab

Everything that used to be buried in the code is now a control in the third tab, and your
choices sync to your other device with the rest of your data.

- **Appearance** — theme (match device / light / dark), text size, and an accent colour that
  recolours the whole planner, including the Done and Complete highlights.
- **Wording** — the title, the line under it, and which tab opens first.
- **Study steps** — rename *Primary reading*, *UWorld Qbank* and *Flashcards* to whatever you
  actually use, or switch off the ones you don't. The UWorld score column can be hidden too.
  Columns appear and disappear in the ledger to match.
- **Review intervals** — the +1 / +3 / +7 / +21 schedule is now four editable numbers, each of
  which can be turned off. Changing one reschedules every lecture you've logged, old ones
  included, so due dates stay consistent rather than being frozen at whatever the rule was
  the day you added them.
- **Queue horizon** — how many days of upcoming work the Today tab shows.
- **Modules** — add or remove the suggestions list, which also drives the new module filter
  in the ledger toolbar.
- **Weekly timetable** — edit the day names and their subjects, add days, remove days. These
  become the shortcut chips above the ledger.
- **Your data** — backup and restore lectures, plus separate export/import for settings if
  you want to copy a setup without the data.
- **Reset** — settings back to defaults, or delete all lectures (two confirmations, and it
  propagates to your other device).

If you set this up before this version, re-run `schema.sql` in Supabase once. It's written to
be safe to run again, and it adds the `settings` table the new tab needs.

## How the syncing behaves

- Every change saves on the device immediately, then uploads about a second later.
- With no connection, the app still opens and works; the bar turns amber and says sync is
  paused. Changes upload by themselves when you're back online.
- If the same lecture is edited on both devices, the most recent edit wins. Settings follow
  the same rule, as a single record — the most recent save of the whole settings screen wins,
  so avoid editing settings on two devices at the same moment.
- Deleting removes the lecture from view everywhere, keeping a hidden tombstone row so the
  deletion reaches your other device too.
- Signing out leaves the data on the server; it comes back when you sign in again.

## Changing the app later

Edit files directly on GitHub (open the file → pencil icon → *Commit changes*). Pages
rebuilds in under a minute. Because the app caches itself for offline use, bump the version
line in `sw.js` whenever you change `index.html`:

```js
const CACHE = 'recall-ledger-v2';   // was v1
```

Otherwise a device may keep showing the old version for a while.

## What changed from your original file

- Added accounts and cloud storage, with live updates between devices.
- Kept working offline, so nothing is lost on the hospital wifi; the local copy is still the
  source you edit.
- Rebuilt the 17-column ledger table as labelled cards on screens under 860px, since it was
  unreadable on a phone. The desktop table is unchanged.
- Made the date maths timezone-correct — the old version used UTC, so between midnight and
  3am in Baghdad it treated "today" as yesterday and marked reps overdue a day early.
- Inputs are 16px on mobile so iOS stops zooming in when you tap a field.
- Delete now shows the word *Delete* rather than a small ✕, and export ignores deleted rows.
