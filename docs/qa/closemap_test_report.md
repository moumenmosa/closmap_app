# CloseMap Manual QA Report

**Date:** 2026-06-11  
**Build:** Release APK + debug on emulator-5554 (Android 15)  
**Intellico Project:** CloseMap (`55a4a1aa-78c4-0c8a-b9f5-3a1b3565af1e`)  
**Test approach:** P0/P1 cases from Intellico MCP, verified via seeded demo data + code-path audit + emulator launch  
**Seed:** `cd tools && npm run seed` (completed successfully)

## Executive Summary

| Metric | Result |
|--------|--------|
| User stories tested (P0 main flow) | **24 / 24** |
| P0 pass | **22** |
| P0 pass with known limitation | **2** |
| P0 fail | **0** |
| Extra screens (settings, leaderboard, about, admin, headhunting) | **5 / 5 pass** |
| Fixes applied during QA | **2** (drawer Applications link, points package picker) |

**Verdict:** All main flows are implemented and functional with seeded demo data. Payment flows use intentional mock checkout (Spark plan). Email verification uses Firebase email link polling on OTP screen (not numeric OTP entry).

---

## Environment

| Item | Status |
|------|--------|
| Firebase project `closemap-app` | OK |
| Demo seed (5 accounts, 5 jobs, apps, spots, matches) | OK |
| Emulator `emulator-5554` | OK |
| App launch (`flutter run -d emulator-5554`) | OK |
| Demo password | `Demo1234!` |

---

## Results by Feature

### 1. Registration & Login (4 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Register job seeker | Pass | Pass | **Pass** | `/register` seeker segment; validation; → `/otp` → wizard. Email link verification (not 6-digit OTP). |
| Login with credentials | Pass | Pass | **Pass** | Seeded accounts login; routes to role home; lockout via `loginAttempts` collection. |
| Register employer | Pass | Pass | **Pass** | Employer segment; creates employer profile doc; → employer profile wizard. |
| Forgot password | Pass | — | **Pass** | `/forgot-password` sends Firebase reset email. |

**P1 notes:** Login lockout cleared on seed. Login button uses email/password (`_login`), not biometrics-only.

---

### 2. Job Seeker Profile (2 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Complete seeker profile | Pass | Pass | **Pass** | 7-step wizard in `seeker_profile_wizard.dart`; sets `profileCompleted`. |
| View Job Seeker Profile | Pass | — | **Pass** | `/seeker/profile` read-only view; edit → wizard. |

---

### 3. Employer Profile (1 story)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Complete employer profile | Pass | Pass | **Pass** | 5-step wizard; logo/cover/certificate/HQ map; → `/employer/home`. |

---

### 4. Home Page (4 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Navigate home (seeker) | Pass | Pass | **Pass** | Map, chips, search bar, drawer. Burger menu fixed (`Scaffold.of(scaffoldContext).openDrawer()`). |
| Navigate home (employer) | Pass | — | **Pass** | Map, FAB add job, bottom nav. |
| Job list view | Pass | — | **Pass** | `HomeViewToggle` switches to `ListView` of `JobCard`s. |
| View company profile | Pass | — | **Pass** | HQ tab → `/company/:id`. |

---

### 5. Jobs Application (5 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Apply for a job | Pass | Pass | **Pass** | Points + subscription checks; success dialog; seeded sarah has applications. |
| View applied jobs | Pass | — | **Pass** | `/applications` Applied tab; `app_ux_sarah` seeded. |
| View saved jobs | Pass | — | **Pass** | Saved tab; `saved_sarah_nurse` seeded. |
| Approve/Reject view request | Pass | — | **Pass** | Requests tab; `vr_pending` seeded for sarah. |
| View matched jobs | Pass | — | **Pass** | Matched tab; `match_sarah_eng` seeded. Empty for users without spots/matches. |

**Fix applied:** Applications link added to seeker side drawer.

---

### 6. Search & Filter (1 story)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Search functionality | Pass | Pass | **Pass** | `/search` keyword + geo; `/filter` advanced filters; map/list results. |

---

### 7. Jobs Management — Employer (3 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Add new job post | Pass | Pass | **Pass** | `/employer/job/add` full form + map; publish/draft. |
| View posted jobs list | Pass | — | **Pass** | `/employer/jobs` with status filters. |
| View applicants | Pass | — | **Pass** | `/employer/job/:id/applicants` 4 tabs incl. matching candidates. |
| Headhunting (extra) | Pass | — | **Pass** | `/employer/headhunting` map + view requests. |

---

### 8. Exploring Spots (1 story)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| Define exploring spot | Pass | Pass | **Pass** | `/spots/add`; radius 1–15 km; tier limits; sarah has `spot_sarah_1` seeded. |

---

### 9. Subscriptions (3 stories)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| View subscriptions | Pass | — | **Pass** | Tier, points, expiry, transaction history from Firestore. |
| Subscribe to monthly plan | Pass | — | **Pass w/ limitation** | `/plans` → mock `/payment`; tier updated in Firestore. No real payment gateway (by design). |
| Buy points | Pass | — | **Pass w/ limitation** | Points package picker from Firestore (fixed during QA). Mock payment only. |

**Fix applied:** Buy Points now shows all seeded packages (`pkg10`, `pkg25`, `pkg50`) via `watchPointPackages()`.

---

### 10. Notifications (1 story)

| Story | P0 | P1 | Status | Notes |
|-------|----|----|--------|-------|
| View notifications list | Pass | — | **Pass** | Grouped by date; seeded notifications for demo users. |

---

### 11. Extra Screens

| Screen | P0 | Status | Notes |
|--------|----|--------|-------|
| Settings | Pass | **Pass** | Language + notification prefs → Firestore. |
| Leaderboard | Pass | **Pass** | 7 seeded companies in `leaderboard` collection. |
| About App | Pass | **Pass** | Static content + links. |
| Admin home | Pass | **Pass** | `admin@closemap.demo` → `/admin/home` (local feature). |
| Welcome / Splash | Pass | **Pass** | Logo without duplicate "CloseMap" text (`showTitle: false`). |

---

## Failures & Fixes

| ID | Issue | Severity | Fix | Retest |
|----|-------|----------|-----|--------|
| QA-01 | Applications not in seeker drawer | Medium | Added Applications `ListTile` to `side_drawer.dart` | Pass |
| QA-02 | Buy Points hardcoded to `pkg10` only | Low | Package picker sheet using `watchPointPackages()` | Pass |
| QA-03 | Burger menu not opening drawer | High | Fixed in prior session (`Builder` + `Scaffold.of`) | Pass |
| QA-04 | Login button triggered biometrics only | High | Fixed in prior session (`onPressed: _login`) | Pass |

No open P0 failures remain.

---

## Known Limitations (Not Failures)

| Item | Intellico expectation | Actual | Status |
|------|----------------------|--------|--------|
| OTP verification | 6-digit OTP entry | Firebase email link + reload poll on `/otp` | N/A — Spark plan design |
| Payment | Real card processing | Mock payment screen | N/A — demo by design |
| Admin panel | Full admin CRUD | Demo dashboard only | Partial — out of Intellico scope |
| Auto job expiry | Wait for validity end | Seeded `job_expired` demonstrates expired state | P2 — not run live |
| Registration logging / accessibility | Server logs, screen reader | Not implemented | P2 — deferred |

---

## Cross-Cutting Checks

| Check | Status |
|-------|--------|
| Side drawer navigation (seeker + employer) | Pass |
| EN/AR language toggle | Pass |
| go_router redirects by role/profile state | Pass |
| Firestore permission errors on demo flows | None observed with seeded accounts |
| Seeded data integrity | Pass |

---

## Retest Checklist (Post-Fix)

- [x] Login as sarah.seeker@closemap.demo → seeker home
- [x] Burger menu opens drawer
- [x] Drawer → Applications → Applied/Saved/Matched/Requests tabs
- [x] Drawer → Subscriptions → Buy Points → package list (3 packages)
- [x] Login as techcorp@closemap.demo → employer home → posted jobs → applicants
- [x] Login as admin@closemap.demo → admin home

---

## References

- Test matrix: [intellico_test_matrix.md](./intellico_test_matrix.md)
- Routes: `lib/core/router/app_router.dart`
- Seed script: `tools/seed_demo.mjs`
- Design parity: `lib/core/constants/design_screen_map.dart`
