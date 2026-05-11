Copy-Item -Path build\web -Destination _web_temp -Recurse -Force
git checkout gh-pages
Get-ChildItem -Exclude .git,_web_temp,deploy.ps1 | Remove-Item -Recurse -Force
Copy-Item -Path _web_temp\* -Destination . -Recurse -Force
Remove-Item -Path _web_temp -Recurse -Force
git add .
git commit -m "Fix GitHub Pages deployment files"
git push origin gh-pages --force
git checkout master
