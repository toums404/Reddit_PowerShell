# Récupère les 10 posts les plus populaires sur Reddit
$redditUrl = "https://www.reddit.com/r/all/top/.json?limit=10"

# Requête HTTP avec user-agent obligatoire
$response = Invoke-RestMethod -Uri $redditUrl -Headers @{ "User-Agent" = "Mozilla/5.0" }

# Extraction des posts
$posts = $response.data.children

# Affiche seulement les titres
foreach ($post in $posts) {
    $title = $post.data.title
    Write-Output $title
}
