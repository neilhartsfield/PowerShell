# Get all .mp4 files in the current directory
cd C:\my\mp3
$files = Get-ChildItem . -Filter "*.mp4"

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
