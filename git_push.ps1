$message = Read-Host -Prompt "Input push message"
git branch -M main
git add .
git push -u origin main
git commit -m $message