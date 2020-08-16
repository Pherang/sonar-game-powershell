$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Tests for check-coords function" {

    It "Returns true if coordinates are on the board" {
        $move = "10 5"     
        $move = $move.Split()
        check-onboard -coords @{x=[int]$move[0];y=[int]$move[1]}  | Should Be $true
    }

    It "Returns false if coordinates aren't on the board"{
        $move = "10 15"     
        $move = $move.Split()
        check-onboard -coords @{x=[int]$move[0];y=[int]$move[1]}  | Should Be $false
    }

}
Describe "Tests the get-chests function" {

    It "Returns an array containing 3 chests"{
        $chests = get-chests -num_chests 3
        $chests.count | Should Be 3
    }
}
