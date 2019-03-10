Function New-MdtPackagesFolder {
    <#
        .SYNOPSIS
            Creates a folder in the MDT Packages node.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .PARAMETER Drive
            An existing PS drive letter mapped to an MDT deployment share.

        .PARAMETER Path
            A new folder to create below the Packages node in the MDT deployment share.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [String] $Drive,

        [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $True)]
        [String] $Path
    )

    # If $Path does not exist, attempt to create it
    If (!(Test-Path -Path "$($Drive):\Packages\$Path" -Type 'Container')) {

        # If path with multiple folders specified, create each one
        $folders = $Path -split "\\"
        $parent = "$($Drive):\Packages"
        
        ForEach ($folder in $folders) {
            If (!(Test-Path -Path "$parent\$folder" -Type 'Container')) {
                If ($pscmdlet.ShouldProcess("$parent\$folder", "Creating")) {
                    Try {
                        New-Item -Path $parent -Enable "True" -Name $folder `
                            -Comments "Created by 'New-MdtPackagesFolder'" `
                            -ItemType "Folder"
                    }
                    Catch {
                        Throw "Failed to create Packages folder."
                    }
                }
            }
            $parent = "$parent\$folder"

            # Return status from New-Item
            Write-Output $?
        }
    }
    Else {
        Write-Verbose "Path exists: $($Drive):\Packages\$Path"
    }
}
