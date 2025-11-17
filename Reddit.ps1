Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================
# FETCH REDDIT POSTS
# ============================================
function Get-RedditPosts {
    try {
        $redditUrl = "https://www.reddit.com/r/all/top/.json?limit=10"
        $response = Invoke-RestMethod -Uri $redditUrl -Headers @{ "User-Agent" = "Mozilla/5.0" }
        return $response.data.children
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to fetch Reddit posts.",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return @()
    }
}

# ============================================
# UPDATE LISTVIEW AND EXPORT TEXT FILE
# ============================================
function Update-PostsList {
    param($listView)

    $listView.Items.Clear()
    $posts = Get-RedditPosts

    # Define output file path
    $outputDir = "C:\Users\Tom\Desktop\_\Rapport-Reddit"
    if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
    $outputPath = Join-Path $outputDir "RedditTop10.txt"

    $fileContent = ""

    foreach ($post in $posts) {
        $title = $post.data.title
        $url = "https://www.reddit.com" + $post.data.permalink

        $item = New-Object System.Windows.Forms.ListViewItem($title)
        $item.Tag = $post.data.permalink
        $listView.Items.Add($item)

        # Add to file content
        $fileContent += "Titre : $title`r`nURL   : $url`r`n`r`n"
    }

    # Write to file
    try {
        $fileContent | Out-File -FilePath $outputPath -Encoding UTF8
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Failed to write summary file: $outputPath")
    }
}

# ============================================
# OPEN SELECTED POST
# ============================================
function Open-SelectedPost {
    param($listView)
    if ($listView.SelectedItems.Count -eq 0) { return }
    $url = "https://www.reddit.com" + $listView.SelectedItems[0].Tag
    Start-Process $url
}

# ============================================
# FORM
# ============================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Top 10 des meilleurs post reddit aujourd'hui :"
$form.Size = New-Object System.Drawing.Size(850, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# LISTVIEW
$listView = New-Object System.Windows.Forms.ListView
$listView.Location = New-Object System.Drawing.Point(10, 10)
$listView.Size = New-Object System.Drawing.Size(820, 380)
$listView.View = "Details"
$listView.FullRowSelect = $true
$listView.GridLines = $true
$listView.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$listView.Columns.Add("Titre", 800) | Out-Null
$form.Controls.Add($listView)

# BUTTON Refresh
$refreshBtn = New-Object System.Windows.Forms.Button
$refreshBtn.Text = "Refresh"
$refreshBtn.Location = New-Object System.Drawing.Point(10, 410)
$refreshBtn.Size = New-Object System.Drawing.Size(100, 35)
$refreshBtn.Add_Click({ Update-PostsList -listView $listView })
$form.Controls.Add($refreshBtn)

# BUTTON Open Post
$openBtn = New-Object System.Windows.Forms.Button
$openBtn.Text = "Open Post"
$openBtn.Location = New-Object System.Drawing.Point(120, 410)
$openBtn.Size = New-Object System.Drawing.Size(100, 35)
$openBtn.Add_Click({ Open-SelectedPost -listView $listView })
$form.Controls.Add($openBtn)

# ============================================
# INITIAL LOAD
# ============================================
$form.Add_Shown({ Update-PostsList -listView $listView })

# SHOW FORM
[void]$form.ShowDialog()
