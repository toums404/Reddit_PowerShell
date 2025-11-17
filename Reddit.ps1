# ============================================
# CONFIGURATION
# ============================================
# Dossier où sauvegarder les rapports (modifier selon vos besoins)
$reportFolder = "C:\Users\Tom\Desktop\_\Rapport-Reddit"

# ============================================
# RÉCUPÉRATION DES DONNÉES
# ============================================
$redditUrl = "https://www.reddit.com/r/all/top/.json?limit=10"

# Requête HTTP avec user-agent obligatoire
$response = Invoke-RestMethod -Uri $redditUrl -Headers @{ "User-Agent" = "Mozilla/5.0" }

# Extraction des posts
$posts = $response.data.children

# ============================================
# PRÉPARATION DU FICHIER DE RAPPORT
# ============================================
# Créer le dossier s'il n'existe pas
if (-not (Test-Path -Path $reportFolder)) {
    New-Item -ItemType Directory -Path $reportFolder | Out-Null
    Write-Output "Folder created: $reportFolder`n"
}

# Nom du fichier avec la date du jour
$dateString = Get-Date -Format "yyyy-MM-dd"
$reportFileName = "reddit_trends_$dateString.txt"
$reportFilePath = Join-Path -Path $reportFolder -ChildPath $reportFileName

# ============================================
# AFFICHAGE CONSOLE ET ÉCRITURE FICHIER
# ============================================
# En-tête
$header = @"

========================================
  TOP 10 REDDIT POSTS
  Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
========================================

"@

Write-Output $header
$header | Out-File -FilePath $reportFilePath -Encoding UTF8

# Affiche et sauvegarde les informations détaillées de chaque post
$counter = 1
foreach ($post in $posts) {
    $title = $post.data.title
    $subreddit = $post.data.subreddit
    $score = $post.data.score
    $url = "https://www.reddit.com" + $post.data.permalink
    
    # Construction du texte pour ce post
    $postText = @"
[$counter] $title
    Subreddit: r/$subreddit
    Score: $score upvotes
    URL: $url

"@
    
    # Affichage console
    Write-Output $postText
    
    # Écriture dans le fichier
    $postText | Out-File -FilePath $reportFilePath -Append -Encoding UTF8
    
    $counter++
}

$footer = "========================================"
Write-Output $footer
$footer | Out-File -FilePath $reportFilePath -Append -Encoding UTF8

# Message de confirmation
Write-Output "`nReport saved to: $reportFilePath"