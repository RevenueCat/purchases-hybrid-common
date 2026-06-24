### Releasing a version:

1. Create a `fastlane/.env` file with your GitHub API token (see `fastlane/.env.SAMPLE`). This will be used to create the PR, so you should use your own token so the PR gets assigned to you.
2. Run `bundle exec fastlane bump`
    1. Confirm base branch is correct
    2. Input new version number
    3. Update CHANGELOG.latest.md to include the latest changes. Call out API changes (if any). You can use the existing CHANGELOG.md as a base for formatting. To compile the changelog, you can compare the changes between the base branch for the release (usually main) against the latest release, by checking https://github.com/revenuecat/purchases-hybrid-common/compare/<latest_release>...<base_branch>. For example, https://github.com/revenuecat/purchases-hybrid-common/compare/3.3.0...main.
    4. A new branch and PR will automatically be created
3. Merge PR when approved
4. Make a tag and push, the rest will be performed automatically by CircleCI. If the automation fails, you can revert to manually calling `bundle exec fastlane deploy`.

Hotfix Releases
=========
Sometimes you might need to release a patch on a version that's not the latest. Or sometimes there might have been commits on main that shouldn't be released, but the latest version has a big bug. For example, let's say the last version is 4.0.0, but there's a bug on 3.9.0 that needs to be released as a 3.9.1:

1. Open a PR with the fix, merge it to main.
1. Jump to the version you're patching (3.9.0) and create a **base branch** from it, then push it. This branch is only used as the base for the release PR.
    - **Do not name the base branch `release/...`.** CircleCI runs the release workflow — including the deploy `hold` approval job — on any branch matching `release/*` (see the `release-branches` filter in `.circleci/config.yml`). Pushing the base branch as `release/3.9.0` would spin up that workflow on a branch that's just a clean copy of an already-released version. Use a name outside that pattern, e.g. `hotfix-base`.
1. Run `bundle exec fastlane bump` as you would do with any release. This will create a new PR with a `release/3.9.1` branch. The `release/` prefix here is required — it's what lets CircleCI tag and deploy the branch once the hold job is approved. Make sure the base branch of the PR is pointing to the base branch you created in the previous step (`hotfix-base`).
1. Locally, while on the release branch (`release/3.9.1` in this case), cherry pick the changes with your fix that you just merged to `main` using `git cherry-pick <sha_of_the_squashed_commit_in_main>`. Fix any conflicts if there are any. Push the cherry picked commit to the remote branch `release/3.9.1`.
    - **Put the fix on the release branch, not the base branch.** The release PR diff is `release/3.9.1` vs the base branch, so a fix committed to the base branch won't show up in the PR — reviewers would only see the version bump, and the fix ships unreviewed. Keep the base branch as a clean copy of the released version and land every change you're backporting on the release branch.
1. When the PR is approved, approve the hold job in CircleCI as you would do for any other release. If there is no hold job because the release is older than when we introduced that job, manually tag the last commit in `release/3.9.1` with `3.9.1`.
1. CircleCI will start the deployment process
1. Merge the PR after the release has been completed and delete both the base branch (`hotfix-base`) and the release branch (`release/3.9.1`).
1. **After every backport hotfix, restore the npm `latest` tag.** Publishing the hotfix to npm moves `latest` onto the hotfix version, so you must point it back at the newest published version. Run, replacing `x.x.x` with the **newest** released version of `purchases-typescript-internal` (the one on `main`, e.g. 4.0.0 — **not** the hotfix you just shipped):
    ```
    npm dist-tag add @revenuecat/purchases-typescript-internal-esm@x.x.x latest
    npm dist-tag add @revenuecat/purchases-typescript-internal@x.x.x latest
    ```
    This step is only needed when the hotfix is older than the current `latest`. If you're patching the newest version, npm's `latest` is already correct and you can skip it.
1. Remember to edit the CHANGELOG.md in `main` to include the version that has been just released
