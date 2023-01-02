<# The purpose of this script is to remove all special characters from saved .mp4 files, 
rename that file accordingly, so that way ffmpeg can parse it properly and convert the file
to .mp3 without errors. #>

# Get all .mp4 files in the current directory
Set-Location -Path "C:\My\mp3"
$files = Get-ChildItem C:\my\mp3 -Filter "*.mp4"

# Loop through each file
foreach ($file in $files) {
  # Remove all non-alphanumeric characters (including spaces) from the filename
  # before the .mp4 extension
  $newName = $file.BaseName -replace '[^0-9a-zA-Z]',''
  
  # Rename the file with the new name and the original extension
  Rename-Item -Path $file.FullName -NewName "$newName$($file.Extension)"

  # Use ffmpeg to convert the .mp4 file to .mp3
  ffmpeg -i "$newName$($file.Extension)" -vn -ar 44100 -ac 2 -ab 128k -f mp3 "$newName.mp3"

  # Delete the original .mp4 file
  Remove-Item "$newName$($file.Extension)"
}
