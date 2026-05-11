if (Test-Path ../gh-pages-worktree) { Remove-Item -Recurse -Force ../gh-pages-worktree }
git worktree add ../gh-pages-worktree gh-pages
Remove-Item -Path ../gh-pages-worktree/* -Recurse -Force -Exclude .git
Copy-Item -Path build\web\* -Destination ../gh-pages-worktree -Recurse -Force
Set-Location ../gh-pages-worktree
git add .
git commit -m "Deploy to GitHub Pages (Automated)"
git push origin gh-pages
Set-Location ../oil_cfd_signals
git worktree remove ../gh-pages-worktree --force
