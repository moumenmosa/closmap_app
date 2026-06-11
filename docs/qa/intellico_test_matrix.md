# CloseMap Intellico Test Matrix

**Project:** CloseMap (`55a4a1aa-78c4-0c8a-b9f5-3a1b3565af1e`)  
**Source:** Intellico MCP `GetAllProjectUserStoriesWithFeature` + `GetProjectTestCases`  
**Prioritization:** P0 = main happy path, P1 = critical negative, P2 = edge (deferred)

| # | Feature | User Story | Route | P0 Test Case (Intellico) | P1 Test Cases |
|---|---------|------------|-------|---------------------------|---------------|
| 1 | Registration & Login | register a new account as a job seeker | `/register` | Submit registration form with valid data → email verification → profile wizard | Empty fields rejected; invalid email format |
| 2 | Registration & Login | login to the app using credentials | `/login` | Successful login with valid credentials → seeker/employer home | Wrong password error; 5-attempt lockout |
| 3 | Registration & Login | Register a new account (employer) | `/register` | Employer segment → valid data → OTP → employer profile | Empty company name; password mismatch |
| 4 | Job Seeker Profile | complete the user profile (job seeker) | `/seeker/profile-wizard` | Complete all wizard steps → `profileCompleted: true` | Required fields validation per step |
| 5 | Job Seeker Profile | View Job Seeker Profile | `/seeker/profile` | View profile from drawer; edit opens wizard | Empty profile sections show placeholders |
| 6 | Employer Profile | Complete the employer profile | `/employer/profile` | Complete 5-step wizard → employer home | Logo/location optional fields |
| 7 | Home Page | navigate to the home page (seeker) | `/seeker/home` | Login as sarah → map home with Jobs/HQ/People chips | Burger menu opens drawer |
| 8 | Home Page | navigate to home page (employer) | `/employer/home` | Login as techcorp → map + FAB | Bottom nav to posted jobs |
| 9 | Home Page | Display the job postings as list view | `/seeker/home` | Toggle List view → job cards visible | Map ↔ list toggle preserves category |
| 10 | Home Page | View a company profile | `/company/:id` | HQ tab → tap company → company profile | Company name and details display |
| 11 | Jobs application | apply for a job | `/job/:id` | Open job → Apply → success dialog; points deducted | Insufficient points blocked |
| 12 | Jobs application | View applied jobs | `/applications` (Applied) | Applied tab shows seeded applications | Swipe to remove |
| 13 | Jobs application | View saved jobs | `/applications` (Saved) | Saved tab shows saved job | Save/unsave from job details |
| 14 | Jobs application | Approve / Reject a profile view request | `/applications` (Requests) | Pending request → Approve/Reject | Employer notified |
| 15 | Jobs application | View matched Jobs | `/applications` (Matched) | Matched tab shows seeded match for sarah | Empty if no spots (omar) |
| 16 | Notifications | View the notifications list | `/notifications` | List grouped by date; tap navigates | Mark as read |
| 17 | Search & Filter | use the search functionality | `/search`, `/filter` | Keyword search returns jobs; filters apply | Empty query handling |
| 18 | Exploring Spots | Define an exploring spot | `/spots`, `/spots/add` | Add spot with radius → appears in list | Tier max spots limit |
| 19 | Subscriptions | View subscriptions | `/subscriptions` | Tier, points, expiry, transaction history | Low points warning banner |
| 20 | Subscriptions | subscribe to a monthly plan | `/plans` → `/payment` | Select plan → mock pay → tier updated | Plans from Firestore seed |
| 21 | Subscriptions | buy points | `/subscriptions` → `/payment` | Select points package → mock pay → points increase | Package picker (not hardcoded) |
| 22 | Jobs Management | Add new job post | `/employer/job/add` | Fill form + map → publish → visible in list | Draft save |
| 23 | Jobs Management | view al list of posted jobs | `/employer/jobs` | Filter active/draft/expired; tap → applicants | Status chips work |
| 24 | Jobs Management | View a list of applicants on a job post | `/employer/job/:id/applicants` | Applicants tabs + matching candidates | Status update on applicant |

## Demo Test Data

| Account | Password | Use for |
|---------|----------|---------|
| sarah.seeker@closemap.demo | Demo1234! | Seeker flows, apply, applications, spots |
| omar.seeker@closemap.demo | Demo1234! | Secondary seeker |
| techcorp@closemap.demo | Demo1234! | Employer jobs, applicants, headhunting |
| healthco@closemap.demo | Demo1234! | Second employer, company profile |
| admin@closemap.demo | Demo1234! | Admin home |

## Extra Screens (not in Intellico)

| Screen | Route | P0 |
|--------|-------|-----|
| Settings | `/settings` | Language + notification prefs persist |
| Leaderboard | `/leaderboard` | Seeded companies list |
| About | `/about` | Static content loads |
| Headhunting | `/employer/headhunting` | Nearby seekers map |
| Forgot password | `/forgot-password` | Reset email sent |
| Admin home | `/admin/home` | Admin login routing |
