$topThree = @(0, 0, 0)
$currentSum = 0

# Iterate through all elf calorie reports
foreach($line in Get-Content ".\input.txt"){
	if ($line -eq "") {   # Elf has reported all calories
		for ($sumIndex = 0; $sumIndex -lt 3; $sumIndex = $sumIndex + 1) { # Sum belongs among the top three
			$topSum = $topThree[$sumIndex]
			if ($currentSum -gt $topSum) {
				# Move all subsequent sums ahead by one
				for ($moveIndex = 1; $moveIndex -ge $sumIndex; $moveIndex = $moveIndex - 1) {
					$topThree[$moveIndex + 1] = $topThree[$moveIndex]
				}
				$topThree[$sumIndex] = $currentSum
				break
			}
		}
		$currentSum = 0
	} else {
		$currentSum += [int]$line
	}
}

# Get sum of top three
$topThreeSum = 0
foreach ($top in $topThree) {
	$topThreeSum += $top
}

Write-Host "Solution 1: "$topThree[0]
Write-Host "Solution 2: "$topThreeSum
