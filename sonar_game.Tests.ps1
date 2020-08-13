$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Tests for check-coords function" {

    It "Returns true if coordinates are on the board" {
        $move = "10 5"     
        $move = $move.Split()
        check-onboard @{x=$move[0];y=$move[1] }  | Should Be $true
    }

    It "It returns a board that is a multi dimensional array of strings"{
        Get-NewBoard | should beoftype string[,]
    }


}
