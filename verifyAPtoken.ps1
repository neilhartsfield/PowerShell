<#
.Synopsis
	A GUI to assist verifying uninstall tokens for Agent Protection
	Author: Neil Hartsfield (nhartsfield@beyondtrust.com)
	
.Description
	This script will enable you to quickly verify a temporary uninstall token with a specified public key
#>

# Load the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Set the form properties
$form.Text = "Agent Protection Token Verifier"
$form.Width = 375
$form.Height = 225

# Create a label for the public key
$publicLabel = New-Object System.Windows.Forms.Label
$publicLabel.Text = "Public key:"
$publicLabel.AutoSize = $true
$publicLabel.Location = New-Object System.Drawing.Point(10, 10)

# Create a button to browse for the public variable
$publicButton = New-Object System.Windows.Forms.Button
$publicButton.Text = "Browse"
$publicButton.AutoSize = $true
$publicButton.Location = New-Object System.Drawing.Point(10, 35)

# Create a textbox to display the public variable
$publicTextBox = New-Object System.Windows.Forms.TextBox
$publicTextBox.ReadOnly = $true
$publicTextBox.Location = New-Object System.Drawing.Point(100, 10)
$publicTextBox.Width = 250

# Create a label for the token
$tokenLabel = New-Object System.Windows.Forms.Label
$tokenLabel.Text = "Token file:"
$tokenLabel.AutoSize = $true
$tokenLabel.Location = New-Object System.Drawing.Point(10, 75)

# Create a button to browse for the token variable
$tokenButton = New-Object System.Windows.Forms.Button
$tokenButton.Text = "Browse"
$tokenButton.AutoSize = $true
$tokenButton.Location = New-Object System.Drawing.Point(10, 100)

# Create a textbox to display the token variable
$tokenTextBox = New-Object System.Windows.Forms.TextBox
$tokenTextBox.ReadOnly = $true
$tokenTextBox.Location = New-Object System.Drawing.Point(100, 75)
$tokenTextBox.Width = 250

# Create a button to generate the package
$generateButton = New-Object System.Windows.Forms.Button

# Set the properties for the verify button
$generateButton.Text = "Verify Token"
$generateButton.AutoSize = $true
$generateButton.Location = New-Object System.Drawing.Point(150, 130)

# Define the action for the public button
$publicButton.Add_Click({
    # Show the open file dialog
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Public key files (*.pem)|*.pem|All files (*.*)|*.*"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.Title = "Select the public key file"

    if ($openFileDialog.ShowDialog() -eq "OK") {
        # Set the public text box to the selected file
        $publicTextBox.Text = $openFileDialog.FileName
    }
})

# Define the action for the token button
$tokenButton.Add_Click({
    # Show the folder browse dialog
    $folderBrowserDialog = New-Object System.Windows.Forms.OpenFileDialog
    $folderBrowserDialog.Filter = "Token files (*.txt)|*.txt|All files (*.*)|*.*"
    $folderBrowserDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $folderBrowserDialog.Title = "Select the token file"

    if ($folderBrowserDialog.ShowDialog() -eq "OK") {
        # Set the token text box to the selected directory
        $tokenTextBox.Text = $folderBrowserDialog.FileName
    }
})

# Define the action for the generate button
$generateButton.Add_Click({
    # Get the values from the text boxes
    $public = $publicTextBox.Text
    $token = $tokenTextBox.Text

    # Validate the input
    if ($public -eq "" -or $token -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Please enter a value for all variables.", "Error", "OK", "Error")
        return
    }

    # Verify the token
    $executable = "C:\Program Files\Avecto\Privilege Guard Management Consoles\AgentProtectionUtility.exe"
    $arguments = "VERIFY /TOKEN $token /PUBLIC $public"
    $result = Start-Process -FilePath $executable $arguments -Wait -PassThru
  # Check the exit code of the utility
    if ($result.ExitCode -eq 0) {
        # Display a success message
        [System.Windows.Forms.MessageBox]::Show("Token verified successfully!", "Success", "OK", "Information")

    } else {
        # Display an error message
        [System.Windows.Forms.MessageBox]::Show("Token verification failed.", "Error", "OK", "Error")
    }
})

# Add the controls to the form
$form.Controls.Add($publicLabel)
$form.Controls.Add($publicButton)
$form.Controls.Add($publicTextBox)
$form.Controls.Add($tokenLabel)
$form.Controls.Add($tokenButton)
$form.Controls.Add($tokenTextBox)
$form.Controls.Add($generateButton)

# Show the form
$form.ShowDialog() | Out-Null
