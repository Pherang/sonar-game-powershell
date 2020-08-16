function Get-NewBoard {
    $column = 60
    $row = 15
    [string[,]]$board = [string[,]]::new($column,$row) 
    for($x = 0; $x -lt $column; $x++){
            for ($y = 0; $y -lt $row; $y++) {
                if ((Get-Random -Minimum 0 -Maximum 2) -eq 1) {
                    $board[$x,$y] = '~'
                }
                else {
                    $board[$x,$y] = '^'
                }
            }
    }
    Write-Output -NoEnumerate $board 
}

function Write-Board{

    param(
        [string[,]]$board
    )
    # Draw the board data structure
    $tens_digits_line = '    ' # Initial space down the left side of the board
    for ($i = 1; $i -lt 6; $i++){
        $tens_digits_line += (' ' * 9) + $i
    } 

    # Print the numbers across the top of the board
    write-output($tens_digits_line)
    write-output('   ' + ('0123456789' * 6))
    #write-output "`n" 

    # Print each of the 15 rows.
    $extra_space = ''
    for ($row = 0; $row -lt 15; $row++){
        $board_row = '' #initialize row to be printed
        if ($row -lt 10) {
            $extra_space = ' '
        }else{
            $extra_space = ''
        }
        for ($column = 0; $column -lt 60; $column++){
            $board_row += $board[$column,$row]
        }
        write-output "$extra_space$row $board_row $row"
    }
        
    # Print the numbers across the botto of the board
    #write-output()
    write-output ('   ' + ('0123456789' * 6))
    write-output $tens_digits_line
}

function get-chests{
    param (
        [int]$num_chests 
    )

    $chests = [System.Collections.ArrayList]@()
    while ($chests.count -lt $num_chests) {
        $coords = New-Object -TypeName PSCustomObject -Property @{
            x = (get-random -minimum 0 -maximum 60)
            y = (get-random -minimum 0 -maximum 15)
        }

        # Need to find out if a chest with same coordinates is already in the list 
        $chest_exists = $chests | Where-Object {$_.x -eq $coords.x -and $_.y -eq $coords.y}
        if ($null -eq $chest_exists) {
            $chests.add($coords) | Out-Null  # Powershell quirk where the index is returned and added to the array.
        } 
    }
    return [System.Collections.ArrayList]$chests
}


function check-onboard {
    param(
        [pscustomobject]$coords
    )
    return ($coords.x -ge 0 -and $coords.x -le 59 -and $coords.y -ge 0 -and $coords.y -le 14)
}

function make-move{

    param(
        [string[,]]$board, 
        [System.Collections.Arraylist]$chests,
        [pscustomobject]$userCoords
    )

    $smallestDistance = 100
    $lastChest
    foreach ($chest in $chests){
        $distance = [System.Math]::sqrt(($chest.x - $userCoords.x) * ($chest.x - $userCoords.x) + ($chest.y -$userCoords.y) * ($chest.y - $userCoords.y))

        if ($distance -lt $smallestDistance){
            $smallestDistance = $distance
            # We need a reference to the actual chest object in the list of chests if we remove it later
            $lastChest = $chest
        }
    }
    $smallestDistance = [System.Math]::Round($smallestDistance)

    if ($smallestDistance -eq 0){
        #xy is on a treasure chest!
        $chests.remove($lastChest)

        $board[$userCoords.x,$userCoords.y] = 'C'
        return 'You have found a sunken treasure chest!'
    }elseif ($smallestDistance -lt 10){
            if ($board[$userCoords.x,$userCoords.y] -ne 'C'){
                $board[$userCoords.x,$userCoords.y] = [String]$smallestDistance
            }
            return ("Treasure detected at a distance of {0} from the sonar device `n" -f $smallestDistance)
    }else {
            if ($board[$userCoords.x,$userCoords.y] -ne 'C'){
                $board[$userCoords.x,$userCoords.y] = 'X'
            }            
            return "Sonar didn't detect anthing. All treasure chests out of range `n"
    }
    
}

function Enter-PlayerMove{
    param(
        [pscustomobject[]]$previous_moves
    )

    # Let player enter their move. Return a two-item list of integer xy coordinates.
    write-host 'Where do you want to drop the next sonar device? or type quit)' 
    while ($true) {
        write-host ('Enter a number from 0 to 59, a space, then a number from 0 to 14')
        $move = read-host
        if ($move.ToLower() -eq 'quit') {
            write-output('Thanks for playing!')
            exit #When used in a function in a script, this will exit the script and not exit the entire PSSession
        }
        $move = $move.split()
        $coords = @{x=$move[0]; y=$move[1]} 
        if ($move.Length -eq 2 -and ($null -ne ($move[0] -as [int])) -and ($null -ne ($move[1] -as [int])) -and
            (check-onboard -coords @{x = [int]$move[0]; y = [int]$move[1]})) {
                $inPreviousMoves = $previous_moves | where-object {$_.x -eq $move[0] -and $_.y -eq $move[1]}
                if ($inPreviousMoves.Count -ge 1) {
                    write-host ('You already moved there')
                    continue
                } 
                return @{x = [int]$move[0]; y = [int]$move[1]}
        }
    }
}

function show-instructions{
    write-output 'Instructions:
        You are the captain of the Simon, a treasure-hunting ship. Your current mission is to use
        sonar devices to find three sunken treasure chests at the bottom of the ocean. But
        you only have cheap sonar that finds distance, not direction.

        Enter the coordinates to drop a sonar device. The ocean map will be marked with 
        how far away the nearest chest is, or an X if it is beyond the sonar device''s range.
        
        For example, the C marks are where chests are. The sonar device shows a 3 because
        the closest chest is 3 spaces away.

                   1         2         3
         0123456789012345678901234567890123
        0~~^~~^^^~^~^~^~^~~~^^~~~^^^~~~^^^~0
        1~^~^~^^^~~~^~^~^~^~~^~^^^^^~~^^^^~1
        2~^^C~^3^~~^^~C~^~~~~^^^~~~^~~~^^^~2
        3~~~^~^^^^~~^~^~^~~~^^~^^~^^^~~^^^~3
        4~~1~~^^^~^~^~C~^~~~^^^^~^^^~~~^^^~4
         0123456789012345678901234567890123

        (In the real game you can''t see the C''s that mark chests) 

        Press enter to continue...'
    read-host

    write-output "
        When you drop a sonar device directly on a chest, you retrive it and the other
        sonar devices update to show how far away the next nearest chest is. The 
        chests are beyond the range of the sonar device on the left, so it shows an X.

            1         2         3
         0123456789012345678901234567890123
        0~~^~~^^^~^~^~^~^~~~^^~~~^^^~~~^^^~0
        1~^~^~^^^~~~^~^~^~^~~^~^^^^^~~^^^^~1
        2~^^X~^7^~~^^~C~^~~~~^^^~~~^~~~^^^~2
        3~~~^~^^^^~~^~^~^~~~^^~^^~^^^~~^^^~3
        4~~1~~^^^~^~^~C~^~~~^^^^~^^^~~~^^^~4
         0123456789012345678901234567890123

        The treasure chests don't moev around. Sonar devices can detect treasure chests up 
        to a distance of 9 spaces. Try to collect all 3 chests before running out of sonar devices.
        Good luck!
        
        Press enter to continue..."
    read-host
}

function start-game {

    write-output 'S O N A R !'
    write-output 'Would you like to view the instructions? (yes/no)'
    if ((read-host).tolower() -like "y*"){
        show-instructions
    }

    while ($true){
        # Game setup
        $sonarDevices = 20
        $theBoard = Get-NewBoard
        $the_chests = [System.Collections.ArrayList](get-chests -num_chests 3)
        write-board -board $theBoard
        $previous_moves = [System.Collections.ArrayList]@()

        while ($sonarDevices -gt 0) {
            write-host ('You have {0} sonar device(s) left. And {1} treasure chest(s) remaining.' -f $sonarDevices, $the_chests.Count)

            $move = Enter-PlayerMove $previous_moves
            $previous_moves.add($move) # Track previous moves so that sonar devices can be updated.

            $move_result = make-move -board $theBoard -chests $the_chests -userCoords $move
            if ($move_result -eq $false){
                continue
            }else{
                if ($move_result -eq 'You have found a sunken treasure chest!'){
                    #Updates all sonar devices currently on the map.
                    foreach ($move in $previous_moves){
                        make-move -board $theBoard -chests $the_chests -userCoords $move
                    }
                }
                write-board $theBoard
                write-output($move_result)
            }

            if ($the_chests.count -eq 0){
                write-host "You have found all the sunken treasure chests!
                    Congratulations and good game!`n"
                write-host 'Do you want to play again? (yes/no)'
                    if ((read-host).tolower() -like "y*"){
                        break
                    } else {
                        return
                }    
            }

            $sonarDevices--
        }

        if ($sonarDevices -eq 0){
            write-host "We`'ve run out of sonar devices! Now we have to turn the ship around and head"
            write-host 'for home with treasure chests still out there! Game over.'
            write-host '   The remaining chests were here:'
            foreach ($chest in $the_chests){
                write-host ('    {0}, {1}' -f $chest.x, $chest.y)
            }
            write-host 'Do you want to play again? (yes/no)'
            if ((read-host).tolower() -like "y*"){
                continue
            } else {
                break
            }
        }
    }
}