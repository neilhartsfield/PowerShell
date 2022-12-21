<#
.Synopsis
	A GUI to assist generating uninstall tokens for Agent Protection
	Author: Neil Hartsfield (nhartsfield@beyondtrust.com)
	
.Description
	This script will enable you to generate a temporary uninstall token with a specified expiry time
#>

# Load the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Set the form properties
$form.Text = "Agent Protection Token Generator"
$form.Width = 480
$form.Height = 250

# Create a label for the private variable
$privateLabel = New-Object System.Windows.Forms.Label
$privateLabel.Text = "Private key:"
$privateLabel.AutoSize = $true
$privateLabel.Location = New-Object System.Drawing.Point(10, 10)

# Create a button to browse for the private variable
$privateButton = New-Object System.Windows.Forms.Button
$privateButton.Text = "Browse"
$privateButton.AutoSize = $true
$privateButton.Location = New-Object System.Drawing.Point(10, 35)

# Create a textbox to display the private variable
$privateTextBox = New-Object System.Windows.Forms.TextBox
$privateTextBox.ReadOnly = $true
$privateTextBox.Location = New-Object System.Drawing.Point(100, 10)
$privateTextBox.Width = 350

# Create a label for the output variable
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Text = "Output file:"
$outputLabel.AutoSize = $true
$outputLabel.Location = New-Object System.Drawing.Point(10, 75)

# Create a button to browse for the output variable
$outputButton = New-Object System.Windows.Forms.Button
$outputButton.Text = "Browse"
$outputButton.AutoSize = $true
$outputButton.Location = New-Object System.Drawing.Point(10, 100)

# Create a textbox to display the output variable
$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.ReadOnly = $true
$outputTextBox.Location = New-Object System.Drawing.Point(100, 75)
$outputTextBox.Width = 350

# Create a label for the expiry variable
$expiryLabel = New-Object System.Windows.Forms.Label
$expiryLabel.Text = "Expiry variable (Time format: 0d | 00h | 0d00h (up to a maximum of 3 days)):"
$expiryLabel.AutoSize = $true
$expiryLabel.Location = New-Object System.Drawing.Point(10, 140)

# Create a textbox for the expiry variable
$expiryTextBox = New-Object System.Windows.Forms.TextBox
$expiryTextBox.Location = New-Object System.Drawing.Point(10, 165)
$expiryTextBox.Width = 150

# Create a button to generate the package
$generateButton = New-Object System.Windows.Forms.Button

# Set the properties for the generate button
$generateButton.Text = "Generate Token"
$generateButton.AutoSize = $true
$generateButton.Location = New-Object System.Drawing.Point(200, 160)

# Define the action for the private button
$privateButton.Add_Click({
    # Show the open file dialog
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "All files (*.*)|*.*"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.Title = "Select the private key file"

    if ($openFileDialog.ShowDialog() -eq "OK") {
        # Set the private text box to the selected file
        $privateTextBox.Text = $openFileDialog.FileName
    }
})

# Define the action for the output button
$outputButton.Add_Click({
    # Show the folder browse dialog
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select the output directory"
    $folderBrowserDialog.RootFolder = [System.Environment+SpecialFolder]::Desktop
    #$folderBrowserDialog.RootFolder = [Environment]::SpecialFolder.MyComputer
    #$folderBrowserDialog.RootFolder = [Environment]::GetFolderPath([Environment]::SpecialFolder.Desktop)

    if ($folderBrowserDialog.ShowDialog() -eq "OK") {
        # Set the output text box to the selected directory
        $outputTextBox.Text = Join-Path -Path $folderBrowserDialog.SelectedPath -ChildPath "token.txt"
    }
})

# Define the action for the generate button
$generateButton.Add_Click({
    # Get the values from the text boxes
    $private = $privateTextBox.Text
    $output = $outputTextBox.Text
    $expiry = $expiryTextBox.Text

    # Validate the input
    if ($private -eq "" -or $output -eq "" -or $expiry -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please enter a value for all variables.", "Error", "OK", "Error")
        return
    }

    if ($expiry -notmatch "^(?:(?:[1-2]?[0-3]d)|(?:3d))(?:(?:[0-1]?[0]|2[0-4])h)?$") {
        [System.Windows.Forms.MessageBox]::Show("Invalid expiry time format.", "Error", "OK", "Error")
        return
    }

    # Generate the package
    $executable = "C:\Program Files\Avecto\Privilege Guard Management Consoles\AgentProtectionUtility.exe"
    $arguments = "UNINSTALL /EXPIRY $expiry /PRIVATE $private /TOKEN $output"
    $result = Start-Process -FilePath $executable $arguments -Wait -PassThru
  # Check the exit code of the utility
    if ($result.ExitCode -eq 0) {
        # Display a success message
        [System.Windows.Forms.MessageBox]::Show("Token generated successfully!", "Success", "OK", "Information")

        # Close the form
        $form.Close()

        # Open the output directory in File Explorer
        explorer (Split-Path -Parent $output)

    } else {
        # Display an error message
        [System.Windows.Forms.MessageBox]::Show("Token generation failed.", "Error", "OK", "Error")
    }
})

# Add the controls to the form
$form.Controls.Add($privateLabel)
$form.Controls.Add($privateButton)
$form.Controls.Add($privateTextBox)
$form.Controls.Add($outputLabel)
$form.Controls.Add($outputButton)
$form.Controls.Add($outputTextBox)
$form.Controls.Add($expiryLabel)
$form.Controls.Add($expiryTextBox)
$form.Controls.Add($generateButton)

# Show the form
$form.ShowDialog() | Out-Null
