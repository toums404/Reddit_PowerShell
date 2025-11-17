# Récupère les 10 posts les plus populaires sur Reddit
$redditUrl = "https://www.reddit.com/r/all/top/.json?limit=10"

# Requête HTTP avec user-agent obligatoire
$response = Invoke-RestMethod -Uri $redditUrl -Headers @{ "User-Agent" = "Mozilla/5.0" }

# Extraction des posts
$posts = $response.data.children

# En-tête
Write-Output "`n========================================`n  TOP 10 REDDIT POSTS`n========================================`n"

# Affiche les informations détaillées de chaque post
$counter = 1
foreach ($post in $posts) {
    $title = $post.data.title
    $subreddit = $post.data.subreddit
    $score = $post.data.score
    $url = "https://www.reddit.com" + $post.data.permalink
    
    Write-Output "[$counter] $title"
    Write-Output "    Subreddit: r/$subreddit"
    Write-Output "    Score: $score upvotes"
    Write-Output "    URL: $url"
    Write-Output ""
    
    $counter++
}

Write-Output "========================================"